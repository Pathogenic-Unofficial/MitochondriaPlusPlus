@tool
extends Bodypart

func _ready() -> void:
	super()
	SignalBus.room_started.connect(startPlyse)

func _physics_process(delta: float) -> void:
	super(delta)
	if provided_charge > 0.0:
		%Progress.value = 1.0
	else:
		%Progress.value = 1.0 - $Timer.time_left / getPulsePeriod()

func startPlyse(_room: Room) -> void:
	if not slot:
		return
	provided_charge = 0.0
	$Timer.start(getPulsePeriod())

func _on_timer_timeout() -> void:
	$Timer.start(getPulsePeriod())
	if G.current_room == null or not slot:
		return
	provided_charge = getChargeMult()
	$DurationTimer.start(getChargeDuration())
	blink()

func _on_duration_timer_timeout() -> void:
	provided_charge = 0.0

func getChargeMult() -> float:
	return 1.0 + rarity

func getPulsePeriod() -> float:
	return 5.0

func getChargeDuration() -> float:
	return 1.0 + 0.8 * rarity

func get_format_dict() -> Dictionary:
	return super().merged({
		"provided_charge": "" if getChargeMult() == 1.0 else "%s× " % Utils.snapped(getChargeMult(), 0.1),
		"period": Utils.snapped(getPulsePeriod(), 0.1),
		"duration": Utils.snapped(getChargeDuration(), 0.1),
	})
