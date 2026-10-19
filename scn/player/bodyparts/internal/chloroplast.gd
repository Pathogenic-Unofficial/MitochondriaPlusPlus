@tool
extends Bodypart

var restGrazeTime = 0.0
var last_player

func _ready() -> void:
	super()
	SignalBus.bodypart_modify_tick.connect(tickModify)

func _physics_process(delta: float) -> void:
	super(delta)
	restGrazeTime = maxf(restGrazeTime - delta, 0.0)
	updateGrazeArea()
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

func updateGrazeArea() -> void:
	if not slot or not G.player.is_dodging():
		$Area2D.collision_layer = 0
		$Area2D.collision_mask = 0
		return
	$Area2D.collision_layer = G.CollisionLayers.PLAYER
	$Area2D.collision_mask = G.CollisionLayers.ENEMY_BULLET
	setup_shapes()
	var bodies = G.player.softbody.get_rigid_bodies()
	for i in range(len(bodies)):
		$Area2D.get_child(i + 1).global_position = bodies[i].rigidbody.global_position

func setup_shapes():
	var bodies = G.player.softbody.get_rigid_bodies()
	if last_player == G.player and $Area2D.get_child_count() == len(bodies) + 1:
		return
	for c in $Area2D.get_children():
		if c == $Area2D/BaseShape:
			continue
		c.queue_free()
		$Area2D.remove_child(c)
	for r in bodies:
		var cs: CollisionShape2D
		if "shape" in r and r.shape:
			cs = r.shape.duplicate()
		else:
			cs = $Area2D/BaseShape.duplicate()
		$Area2D.add_child(cs)
	last_player = G.player

func _on_area_2d_body_entered(body: Node2D) -> void:
	restGrazeTime = getTriggerDuration()
	blink()

func getCurrentBonus() -> float:
	var ret = getBaseBonus()
	var overcharged = charge > 0.0
	if overcharged:
		ret += getBaseOverchargeBonus()
	if restGrazeTime > 0.0:
		ret += getGrazeBonus()
		if overcharged:
			ret += getGrazeOverchargeBonus()
	return ret

func getBaseBonus() -> float:
	return 0.25 + 0.1 * rarity

func getBaseOverchargeBonus() -> float:
	return 0.25

func getGrazeBonus() -> float:
	return 0.75 + 0.3 * rarity

func getGrazeOverchargeBonus() -> float:
	return 0.5

func getTriggerDuration() -> float:
	return 5.0 + 3.0 * rarity

func get_format_dict() -> Dictionary:
	return super().merged({
		"base_bonus": roundi(getBaseBonus() * 100),
		"base_charge_bonus": roundi(getBaseOverchargeBonus() * 100),
		"graze_bonus": roundi(getGrazeBonus() * 100),
		"graze_charge_bonus": roundi(getGrazeOverchargeBonus() * 100),
		"trigger_duration": roundi(getTriggerDuration()),
	})
