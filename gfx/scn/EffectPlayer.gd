extends Node2D
class_name EffectPlayer

@export var oneShot: bool = false
@export var autoplayAnimation: StringName = ""
@export var autoplayFrames: StringName = ""
@export var autoplaySound: StringName = ""
@export var autoplayShake: float = 0

@onready var sounds: SoundStage = $%sounds
@onready var animator: AnimationPlayer = $%animator
@onready var shaderStage: ShaderStage = $%shader
@onready var frameSprite: AnimatedSprite2D = $%frames
@onready var texture: Sprite2D = $%texture
@onready var particles: GPUParticles2D = $%particles

func _ready():
	particles.one_shot = oneShot
	particles.emitting = false
	hide()
	await get_tree().process_frame
	spawn()
func _physics_process(delta):
	ai(delta)

func spawn():
	pass
func ai(_delta: float):
	pass

func shake(pos: Vector2, idensity: float):
	G.main.screen_shake((pos - global_position).normalized() * idensity, global_position)
func millseconds(duration: float):
	return await get_tree().create_timer(duration / 1000).timeout
func timeScale(value: float, millseconds: float):
	Engine.time_scale *= value
	await millseconds(millseconds)
	Engine.time_scale /= value
func shot():
	show()
	particles.emitting = true
	if autoplayAnimation:
		animator.play(autoplayAnimation)
	if autoplayFrames:
		frameSprite.play(autoplayFrames)
	if autoplaySound:
		sounds.play(autoplaySound)
	if autoplayShake > 0:
		shake(global_position, autoplayShake)
	
	if oneShot:
		if frameSprite.is_playing():
			if !frameSprite.sprite_frames.get_animation_loop(frameSprite.animation):
				await frameSprite.animation_finished
				frameSprite.hide()
		if animator.is_playing():
			await animator.animation_finished
		if sounds.isPlaying():
			await sounds.soundStopped
		if particles.emitting:
			await particles.finished
		queue_free()
