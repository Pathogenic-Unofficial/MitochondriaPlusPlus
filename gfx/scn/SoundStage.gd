extends Node2D
class_name SoundStage

signal soundStopped(soundName: String)

var playings: Array[AudioStreamPlayer2D] = []

func _ready():
	for child in get_children():
		if child is AudioStreamPlayer2D:
			child.finished.connect(func(): soundStopped.emit(child.name))
func getPlayer(namx: StringName) -> AudioStreamPlayer2D:
	return get_node_or_null(namx as String as NodePath)
func play(namx: StringName, repeatable: bool = false):
	var player = getPlayer(namx)
	if player is AudioStreamPlayer2D:
		if repeatable:
			player.play()
		else:
			var cloned = player.duplicate() as AudioStreamPlayer2D
			get_parent().add_child(cloned)
			cloned.play()
			playings.append(cloned)
func isPlaying(namx: String = "") -> bool:
	if namx:
		return getPlayer(namx).playing
	else:
		for child in get_children():
			if child is AudioStreamPlayer2D:
				if child.playing:
					return true
		return false
func stop(namx: String = "all"):
	for player in playings:
		if player is AudioStreamPlayer2D:
			if namx == "all" || player.name == namx:
				player.stop()
