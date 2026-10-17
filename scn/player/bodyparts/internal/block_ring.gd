@tool
extends ActiveBodypart

const PERFECT_WINDOW = 0.5
const PERFECT_PARRY = preload("res://mods-unpacked/FallingShrimp-adenosine_hexaphosphate/sfx/PerfectParry.tscn")
const UNEXACT_PARRY = preload("res://mods-unpacked/FallingShrimp-adenosine_hexaphosphate/sfx/UnexactParry.tscn")

var isBlocking = false
var canCounter = false
var lastStartTime = -100.0
var parryCooldownRest = 0.0

func _ready() -> void:
	super()
	attack_button = G.AttackButton.SECONDARY
	SignalBus.player_pre_hit.connect(prehitTest)

func prehitTest(player, _damage, attack) -> void:
	if not isBlocking:
		return
	var elapsed = Time.get_ticks_msec() / 1000.0 - lastStartTime
	if elapsed >= getParryDuration():
		isBlocking = false
		return
	if elapsed <= getPerfectWindow() or randf() < unexactParryRate():
		player.damage_blocked = true
		if canCounter:
			canCounter = false
			provided_charge = getChargeMult()
			$Timer.start(getChargeDuration())
			blink()
		var hit_pos = player.center_body.global_position
		if attack != null and "affected_body" in attack and is_instance_valid(attack.affected_body):
			hit_pos = attack.affected_body.global_position
		spawnSpark(hit_pos, elapsed <= getPerfectWindow())
	else:
		isBlocking = false

func _physics_process(delta: float) -> void:
	super(delta)
	parryCooldownRest = maxf(parryCooldownRest - delta, 0.0)
	if isBlocking and Time.get_ticks_msec() / 1000.0 - lastStartTime >= getParryDuration():
		isBlocking = false
	if isBlocking:
		%Progress.value = 1.0
	elif parryCooldownRest > 0.0:
		%Progress.value = 1.0 - parryCooldownRest / getCooldownTime()
	elif max_energy > 0.0:
		%Progress.value = energy / max_energy

func can_activate() -> bool:
	return parryCooldownRest <= 0.0 and energy >= get_activation_cost() - 0.1

func activate_pressed() -> void:
	if G.editor.state == G.EditorState.HIDDEN and slot != null and G.player.should_listen_to_events and not G.player.dead:
		if not can_activate():
			return
		energy -= get_activation_cost()
		parryCooldownRest = getCooldownTime()
		AudioManager.active_charged.play()
		blink()
		activate()

func activate() -> void:
	isBlocking = true
	canCounter = true
	lastStartTime = Time.get_ticks_msec() / 1000.0
	parryEffect()

func _on_timer_timeout() -> void:
	provided_charge = 0.0

func spawnSpark(pos: Vector2, perfect: bool) -> void:
	if not is_instance_valid(G.player) or not is_instance_valid(G.player.center_body):
		return
	var effect: Node2D = (PERFECT_PARRY if perfect else UNEXACT_PARRY).instantiate()
	G.main.add_child(effect)
	effect.global_position = G.player.center_body.global_position
	effect.rotation = G.player.center_body.global_position.angle_to_point(pos)
	effect.shot()

func parryEffect() -> void:
	var c = Color(1.0, 1.0, 2.0)
	var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_IDLE).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(func(x):
		if not is_instance_valid(G.player):
			return
		if G.player.hit_tween:
			G.player.hit_tween.kill()
		if G.player.get_node("CanvasGroup").material:
			G.player.get_node("CanvasGroup").set_instance_shader_parameter("hit_value", x)
			G.player.get_node("CanvasGroup").set_instance_shader_parameter("hit_color", c)
	, 1.0, 0.5, getParryDuration() - 0.3)
	tween.tween_callback(func():
		if is_instance_valid(G.player):
			G.player._hit_anim(c, 0.2, 0.5)
	)

func getChargeMult() -> float:
	return 3.0 + rarity

func get_stats_after_text() -> String:
	if stats_after_text:
		return tr(stats_after_text)
	return ""

func getParryDuration() -> float:
	return 1.0 + 0.25 * rarity

func getPerfectWindow() -> float:
	return PERFECT_WINDOW * getParryDuration()

func unexactParryRate() -> float:
	return maxf(0.5 - 0.04 * rarity, 0.0)

func getChargeDuration() -> float:
	return 3 + 1.0 * rarity

func getCooldownTime() -> float:
	return 1.0 - 0.15 * rarity

func get_format_dict() -> Dictionary:
	return super().merged({
		"provided_charge": "%s× " % Utils.snapped(getChargeMult(), 0.1),
		"duration": roundi(getChargeDuration()),
		"cooldown": roundi(getCooldownTime()),
		"perfect_parry_window": Utils.snapped(getPerfectWindow(), 0.1),
	})
