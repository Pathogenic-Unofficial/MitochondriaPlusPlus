@tool
extends Bodypart

const GRAZE_RADIUS = 220.0

var restGrazeTime = 0.0

func _ready() -> void:
	super()
	SignalBus.bodypart_modify_tick.connect(tickModify)

func _physics_process(delta: float) -> void:
	super(delta)
	restGrazeTime = maxf(restGrazeTime - delta, 0.0)
	checkGraze()
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

func checkGraze() -> void:
	if restGrazeTime > 0.0:
		return
	if not is_instance_valid(G.player) or not is_instance_valid(G.player.center_body):
		return
	for b in G.get_tree().get_nodes_in_group("enemy_bullets"):
		if not is_instance_valid(b) or not (b is Node2D):
			continue
		if b.global_position.distance_to(G.player.center_body.global_position) < GRAZE_RADIUS:
			restGrazeTime = getTriggerDuration()
			blink()
			break

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
