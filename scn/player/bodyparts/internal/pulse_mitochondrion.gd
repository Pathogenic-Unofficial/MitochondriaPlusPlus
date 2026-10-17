@tool
extends Bodypart

func _ready() -> void:
	super()
	SignalBus.room_started.connect(_on_room_started)

func _physics_process(delta: float) -> void:
	super(delta)
	if provided_charge > 0.0:
		%Progress.value = 1.0
	else:
		%Progress.value = 1.0 - $Timer.time_left / get_period()

func _on_room_started(_room: Room) -> void:
	if not slot:
		return
	provided_charge = 0.0
	$Timer.start(get_period())

func _on_timer_timeout() -> void:
	$Timer.start(get_period())
	if G.current_room == null or not slot:
		return
	provided_charge = get_charge()
	$DurationTimer.start(get_duration())
	blink()

func _on_duration_timer_timeout() -> void:
	provided_charge = 0.0

func get_charge() -> float:
	return 1.0 + rarity

func get_period() -> float:
	return 5.0

func get_duration() -> float:
	return 1.0 + 0.8 * rarity

func get_format_dict() -> Dictionary:
	return super().merged({
		"provided_charge": "" if get_charge() == 1.0 else "%s× " % Utils.snapped(get_charge(), 0.1),
		"period": Utils.snapped(get_period(), 0.1),
		"duration": Utils.snapped(get_duration(), 0.1),
	})
