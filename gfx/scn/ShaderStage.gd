@tool
extends Node2D
class_name ShaderStage

@export var size: Vector2 = Vector2.ONE * 100
@export var background: Color = Color.WHITE
@export var shader: ShaderMaterial = null

@onready var rect: ColorRect = $%rect

func _ready():
	rect.material = shader
func _process(_delta):
	rect.position = size / -2
	rect.size = size
