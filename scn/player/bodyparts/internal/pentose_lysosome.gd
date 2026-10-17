@tool
extends ActiveBodypart

func _physics_process(delta: float) -> void:
	super(delta)
	if provided_charge > 0.0:
		%Progress.value = $Timer.time_left / getChargeDuration()
	else:
		%Progress.value = 1.0

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
		AudioManager.active_charged.play()
		blink()
		activate()

func activate() -> void:
	provided_charge = getChargeMult()
	$Timer.start($Timer.time_left + getChargeDuration())

func _on_timer_timeout() -> void:
	provided_charge = 0.0

func getChargeMult() -> float:
	return 2.0 + rarity

func get_stats_after_text() -> String:
	if stats_after_text:
		return tr(stats_after_text)
	return ""

func getChargeDuration() -> float:
	return 5.0 + rarity

func get_format_dict() -> Dictionary:
	return super().merged({
		"provided_charge": "%s× " % Utils.snapped(getChargeMult(), 0.1),
		"duration": roundi(getChargeDuration()),
	})
