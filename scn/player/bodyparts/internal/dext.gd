@tool
extends Bodypart

const FREEZED_MEAT := preload("res://mods-unpacked/FallingShrimp-adenosine_hexaphosphate/scn/player/projectiles/freezed_meat.tscn")

var last_meat_time := -1000.0

func _ready() -> void:
	super()
	SignalBus.on_attack.connect(applyFinalMult)

func _physics_process(delta: float) -> void:
	super(delta)
	%Progress.value = minf(charge, 1.0)

func applyFinalMult(attack, source) -> void:
	if not slot or not is_instance_valid(attack) or not is_instance_valid(source):
		return
	if not source.connections.has(self):
		return
	attack.damage *= getDamageMult()
	spawnMeat(attack, source)

func spawnMeat(attack, source) -> void:
	if not is_instance_valid(G.main):
		return
	var now := Time.get_ticks_msec() / 1000.0
	var elapsed := now - last_meat_time
	last_meat_time = now
	var meat := FREEZED_MEAT.instantiate()
	if meat is Bullet:
		G.main.bullet_layer.add_child(meat)
		meat.global_position = source.global_position
		var mult = randf_range(0.5, 2.0) * getMeatChargeMult(elapsed)
		meat.speed *= mult
		meat.spin_speed *= mult
		meat.set_base_damage(meat.base_damage * mult)
		var dir := Vector2.UP
		var vel = attack.get("linear_velocity")
		if vel is Vector2 and vel.length_squared() > 1.0:
			dir = vel.normalized()
		meat.shoot(dir, source)

func getMeatChargeMult(elapsed: float) -> float:
	return minf(1.0 + elapsed * 0.5, 8.0)

func getDamageMult() -> float:
	return 0.1 - (0.09 if charge > 0.0 else 0.0)

func get_format_dict() -> Dictionary:
	return super().merged({
		"base_mult": roundi((1.0 - 0.1) * 100),
		"charge_mult": roundi(0.09 * 100),
	})
