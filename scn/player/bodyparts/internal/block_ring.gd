@tool
extends ActiveBodypart

const parry_window := 0.5

const PERFECT_PARRY := preload("res://mods-unpacked/FallingShrimp-MitochondriaPlusPlus/sfx/PerfectParry.tscn")
const UNEXACT_PARRY := preload("res://mods-unpacked/FallingShrimp-MitochondriaPlusPlus/sfx/UnexactParry.tscn")

var _blocking := false
var _reward_available := false
var _block_start := -100.0
var _cooldown := 0.0

func _ready() -> void:
	super()
	attack_button = G.AttackButton.SECONDARY
	SignalBus.player_pre_hit.connect(_on_player_pre_hit)

func _on_player_pre_hit(player, _damage, attack) -> void:
	if not _blocking:
		return
	var elapsed := Time.get_ticks_msec() / 1000.0 - _block_start
	if elapsed >= get_block_window():
		_blocking = false
		return
	if elapsed <= parry_window or randf() < get_block_success_chance():
		player.damage_blocked = true
		if _reward_available:
			_reward_available = false
			provided_charge = get_charge()
			$Timer.start(get_block_duration())
			blink()
		var hit_pos = player.center_body.global_position
		if attack != null and "affected_body" in attack and is_instance_valid(attack.affected_body):
			hit_pos = attack.affected_body.global_position
		_spawn_parry_effect(hit_pos, elapsed <= parry_window)
	else:
		_blocking = false

func _physics_process(delta: float) -> void:
	super(delta)
	_cooldown = maxf(_cooldown - delta, 0.0)
	if _blocking and Time.get_ticks_msec() / 1000.0 - _block_start >= get_block_window():
		_blocking = false
	if _blocking:
		%Progress.value = 1.0
	else:
		%Progress.value = 1.0 - _cooldown / get_cooldown()

func can_activate() -> bool:
	return _cooldown <= 0.0

func activate_pressed() -> void:
	if G.editor.state == G.EditorState.HIDDEN and slot != null and G.player.should_listen_to_events and not G.player.dead:
		if not can_activate():
			return
		_cooldown = get_cooldown()
		AudioManager.active_charged.play()
		blink()
		activate()

func activate() -> void:
	_blocking = true
	_reward_available = true
	_block_start = Time.get_ticks_msec() / 1000.0
	_flash()

func _spawn_parry_effect(hit_pos: Vector2, perfect: bool) -> void:
	if not is_instance_valid(G.player) or not is_instance_valid(G.player.center_body):
		return
	var effect: Node2D = (PERFECT_PARRY if perfect else UNEXACT_PARRY).instantiate()
	G.main.add_child(effect)
	effect.global_position = G.player.center_body.global_position
	effect.rotation = G.player.center_body.global_position.angle_to_point(hit_pos)
	effect.shot()

func _flash() -> void:
	var c := Color(1.0, 1.0, 2.0)
	var tween := create_tween().set_process_mode(Tween.TWEEN_PROCESS_IDLE).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(func(x):
		if not is_instance_valid(G.player):
			return
		if G.player.hit_tween:
			G.player.hit_tween.kill()
		if G.player.get_node("CanvasGroup").material:
			G.player.get_node("CanvasGroup").set_instance_shader_parameter("hit_value", x)
			G.player.get_node("CanvasGroup").set_instance_shader_parameter("hit_color", c)
	, 1.0, 0.5, get_block_window() - 0.3)
	tween.tween_callback(func():
		if is_instance_valid(G.player):
			G.player._hit_anim(c, 0.2, 0.5)
	)

func get_charge() -> float:
	return 3.0 + rarity

func get_stats_after_text() -> String:
	var ret := ""
	if stats_after_text:
		ret += tr(stats_after_text) + "{hr}"
	ret += tr("organelle_active_cost")
	return ret

func get_block_window() -> float:
	return 1.0 + 0.25 * rarity

func get_block_success_chance() -> float:
	return maxf(0.5 - 0.04 * rarity, 0.0)

func get_block_duration() -> float:
	return 4.0 + 2.0 * rarity

func get_cooldown() -> float:
	return 2.0 - 0.15 * rarity

func get_format_dict() -> Dictionary:
	return super().merged({
		"provided_charge": "%s× " % Utils.snapped(get_charge(), 0.1),
		"duration": roundi(get_block_duration()),
		"cooldown": roundi(get_cooldown()),
	})
