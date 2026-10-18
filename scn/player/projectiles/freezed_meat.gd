extends Bullet

const FREEZE_EFFECT := preload("res://scn/player/status_effects/freeze_effect.tscn")

@export var spin_speed := 6.0
@export var freeze_duration := 2.0

func _ready() -> void:
	super()
	enemy_hit.connect(freezeEnemy)

func _physics_process(delta: float) -> void:
	%Visual/Sprite2D.rotation += spin_speed * delta

func freezeEnemy(enemy, _pos) -> void:
	if not is_instance_valid(enemy) or enemy.has_node("freeze_effect"):
		return
	var freeze_effect = FREEZE_EFFECT.instantiate()
	freeze_effect.duration = freeze_duration
	freeze_effect.name = "freeze_effect"
	enemy.add_child(freeze_effect)
