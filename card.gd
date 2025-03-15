extends Area2D

var suit:int = 0
var rank:int = 0
var faceup:bool = false
var complete:bool = false
var hovered:bool = false
var dragged:bool = false 
var whereami = null

@onready var sprite:Sprite2D = $Sprite2D
@onready var suitrender:CPUParticles2D = $Sprite2D/suitparticles
@onready var rankrender:CPUParticles2D = $Sprite2D/rankparticles



func _ready():
	sprite.texture = preload("res://sprites/card.png")
	position = Vector2(30*(rank)+3, 43*(suit+1))
	while !complete:
		pass
	readyup()
	suitrender.emitting = true


func readyup():
	suitrender.texture = load("res://sprites/suits/"+str(suit)+".tres")
	rankrender.texture = load("res://sprites/ranks/"+str(rank)+".tres")
	var awaaga:PackedVector2Array = suitrender.emission_points
	for i in range(0,rank+1):
		awaaga.append(Vector2(main.suitpositions[rank][i]))
	suitrender.emission_points = awaaga

func flip():
	faceup = !faceup
	suitrender.visible = faceup
	rankrender.visible = faceup
	if faceup:
		sprite.texture = preload("res://sprites/card.png")
	else:
		sprite.texture = preload("res://sprites/back.png")

func _process(_delta):
	whereami = main.stock.find(self) 
	if !Input.is_action_pressed("leftclick") and hovered:
		dragged = false
	if Input.is_action_just_pressed("leftclick") and hovered and faceup:
		dragged = true
	if dragged:
		position = get_global_mouse_position()-Vector2(13,-20)


func _on_mouse_entered() -> void:
	hovered = true

func _on_mouse_exited() -> void:
	hovered = false
