@tool
extends Bodypart

const OVERCHARGE_BONUS = 0.1
const BONUS_ONHIT = 0.4
const BONUS_ONGRAZE = 0.3
const GRAZE_RADIUS = 220.0

var restHitTime = 0.0
var restGrazeTime = 0.0

func _ready() -> void:
	super()
	SignalBus.bodypart_modify_tick.connect(tickModify)
	SignalBus.player_pre_hit.connect(prehitTest)
	G.get_tree().node_added.connect(addNodeTest)

func _physics_process(delta: float) -> void:
	super(delta)
	restHitTime = maxf(restHitTime - delta, 0.0)
	restGrazeTime = maxf(restGrazeTime - delta, 0.0)
	%Progress.value = minf(getCurrentBonus(), 1.0)

func tickModify(b) -> void:
	if b == self or not is_instance_valid(b):
		return
	if not is_instance_valid(slot):
		return
	if not b.has_tag(G.BodypartTags.EnergyGenerator):
		return
	if not (b in connections):
		return
	b.energy_generation_mult += getCurrentBonus()

func getCurrentBonus() -> float:
	var ret = getBaseBonus()
	var overcharged = charge > 0.0
	if overcharged:
		ret += OVERCHARGE_BONUS
	if restHitTime > 0.0:
		ret += getHitBonus() + (BONUS_ONHIT if overcharged else 0.0)
	if restGrazeTime > 0.0:
		ret += getGrazeBonus() + (BONUS_ONGRAZE if overcharged else 0.0)
	return ret

func getBaseBonus() -> float:
	return 0.1 + 0.09 * rarity

func getHitBonus() -> float:
	return 0.6 + 0.3 * rarity

func getGrazeBonus() -> float:
	return 0.3 + 0.2 * rarity

func getExtraBonusDurationTimeWhilePlayerIsOnHitOrOnGraze() -> float:
	return 4.0 + rarity

func prehitTest(_player, _damage, attack) -> void:
	if attack is Beam:
		restHitTime = getExtraBonusDurationTimeWhilePlayerIsOnHitOrOnGraze()

func addNodeTest(n: Node) -> void:
	if not (n is Beam):
		return
	var beam = n as Beam
	var shape = beam.get_node_or_null("ShapeCast2D") as ShapeCast2D
	if shape == null or not (shape.collision_mask & G.CollisionLayers.PLAYER):
		return
	beam.missed_hit.connect(missBeam.bind(beam))

func missBeam(end_point: Vector2, beam: Beam) -> void:
	if not is_instance_valid(beam) or not is_instance_valid(G.player):
		return
	if not is_instance_valid(G.player.center_body):
		return
	var from = beam.global_position
	var dist = pointToSegment(G.player.center_body.global_position, from, end_point)
	if dist < GRAZE_RADIUS:
		restGrazeTime = getExtraBonusDurationTimeWhilePlayerIsOnHitOrOnGraze()
		blink()

static func pointToSegment(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab = b - a
	var t = clampf((p - a).dot(ab) / maxf(ab.length_squared(), 0.001), 0.0, 1.0)
	return p.distance_to(a + ab * t)

func get_format_dict() -> Dictionary:
	return super().merged({
		"base_bonus": roundi(getBaseBonus() * 100),
		"trigger_duration": roundi(getExtraBonusDurationTimeWhilePlayerIsOnHitOrOnGraze()),
	})
