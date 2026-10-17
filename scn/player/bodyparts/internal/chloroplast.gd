@tool
extends Bodypart

const overcharge_base_bonus := 0.1
const overcharge_extra_bonus := 0.1
const hit_bonus := 0.6
const hit_overcharge_bonus := 0.4
const graze_bonus := 0.3
const graze_overcharge_bonus := 0.3
const trigger_duration := 4.0
const graze_radius := 220.0

var _hit_time_left := 0.0
var _graze_time_left := 0.0

func _ready() -> void:
	super()
	SignalBus.bodypart_modify_tick.connect(_on_bodypart_modify_tick)
	SignalBus.player_pre_hit.connect(_on_player_pre_hit)
	G.get_tree().node_added.connect(_on_node_added)

func _physics_process(delta: float) -> void:
	super(delta)
	_hit_time_left = maxf(_hit_time_left - delta, 0.0)
	_graze_time_left = maxf(_graze_time_left - delta, 0.0)
	%Progress.value = minf(get_bonus(), 1.0)

func _on_bodypart_modify_tick(b) -> void:
	if b == self or not is_instance_valid(b):
		return
	if not is_instance_valid(slot):
		return
	if not b.has_tag(G.BodypartTags.EnergyGenerator):
		return
	if not (b in connections):
		return
	b.energy_generation_mult += get_bonus()

func get_bonus() -> float:
	var ret := overcharge_base_bonus
	var overcharged := charge > 0.0
	if overcharged:
		ret += overcharge_extra_bonus
	if _hit_time_left > 0.0:
		ret += hit_bonus + (hit_overcharge_bonus if overcharged else 0.0)
	if _graze_time_left > 0.0:
		ret += graze_bonus + (graze_overcharge_bonus if overcharged else 0.0)
	return ret

func _on_player_pre_hit(_player, _damage, attack) -> void:
	if attack is Beam:
		_hit_time_left = trigger_duration

func _on_node_added(n: Node) -> void:
	if not (n is Beam):
		return
	var beam := n as Beam
	var shape := beam.get_node_or_null("ShapeCast2D") as ShapeCast2D
	if shape == null or not (shape.collision_mask & G.CollisionLayers.PLAYER):
		return
	beam.missed_hit.connect(_on_beam_missed.bind(beam))

func _on_beam_missed(end_point: Vector2, beam: Beam) -> void:
	if not is_instance_valid(beam) or not is_instance_valid(G.player):
		return
	if not is_instance_valid(G.player.center_body):
		return
	var from := beam.global_position
	var dist := _point_segment_distance(G.player.center_body.global_position, from, end_point)
	if dist < graze_radius:
		_graze_time_left = trigger_duration
		blink()

static func _point_segment_distance(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var t := clampf((p - a).dot(ab) / maxf(ab.length_squared(), 0.001), 0.0, 1.0)
	return p.distance_to(a + ab * t)

func get_format_dict() -> Dictionary:
	return super().merged({
		"base_bonus": roundi(overcharge_base_bonus * 100),
		"trigger_duration": roundi(trigger_duration),
	})
