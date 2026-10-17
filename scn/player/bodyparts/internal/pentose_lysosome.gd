@tool
extends ActiveBodypart

func _physics_process(delta: float) -> void:
	super(delta)
	if provided_charge > 0.0:
		%Progress.value = $Timer.time_left / get_duration()
	elif max_energy > 0.0:
		%Progress.value = energy / max_energy

func can_activate() -> bool:
	if not is_instance_valid(G.player):
		return super()
	return G.player.dna >= 1 and super()

func activate_pressed() -> void:
	if G.editor.state == G.EditorState.HIDDEN and slot != null and G.player.should_listen_to_events and not G.player.dead:
		if not can_activate():
			return
		G.player.dna -= 1
		G.dna_mesh.set_level(G.player.level + G.player.dna / float(G.player.dna_to_level_up()))
		energy -= get_activation_cost()
		AudioManager.active_charged.play()
		blink()
		activate()

func activate() -> void:
	provided_charge = get_charge()
	$Timer.start(get_duration())

func _on_timer_timeout() -> void:
	provided_charge = 0.0

func get_charge() -> float:
	return 2.0 + rarity

func get_duration() -> float:
	return 8.0

func get_format_dict() -> Dictionary:
	return super().merged({
		"provided_charge": "%s× " % Utils.snapped(get_charge(), 0.1),
		"duration": roundi(get_duration()),
	})
