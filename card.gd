extends Area2D

var suit:int = 0
var rank:int = 0
var faceup:bool = true
var complete:bool = false
const suitpositions = {
0 : [Vector2(.5,0)],
1 : [Vector2(.5,0),Vector2(.5,1)],
2 : [Vector2(.5,0),Vector2(.5,1),Vector2(.5,2)],
3 : [Vector2(.5,0),Vector2(.5,1),Vector2(.5,2),Vector2(.5,3)],
4 : [Vector2(.5,0),Vector2(.5,1),Vector2(.5,2),Vector2(.5,3),Vector2(.5,4)],
5 : [Vector2(.5,0),Vector2(.5,1),Vector2(.5,2),Vector2(.5,3),Vector2(.5,4),Vector2(.5,5)],
6 : [Vector2(.5,0),Vector2(.5,1),Vector2(.5,2),Vector2(.5,3),Vector2(.5,4),Vector2(.5,5),Vector2(.5,6)],
7 : [Vector2(.5,0),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1)],
8 : [Vector2(.5,0),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1)],
9 : [Vector2(.5,0),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1)],
10 : [Vector2(.5,0),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1)],
11 : [Vector2(.5,0),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1)],
12 : [Vector2(.5,0),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1),Vector2(.5,1)]
}

@onready var suitrender:CPUParticles2D = $Sprite2D/suitparticles
@onready var rankrender:CPUParticles2D = $Sprite2D/rankparticles

func _ready():
	while !complete:
		pass
	readyup()
	suitrender.emitting = true


func readyup():
	suitrender.texture = load("res://sprites/suits/"+str(suit)+".tres")
	rankrender.texture = load("res://sprites/ranks/"+str(rank)+".tres")
	var awaaga:PackedVector2Array = suitrender.emission_points
	for i in range(0,suit):
		awaaga.append(suitpositions[suit][i])
	suitrender.emission_points = awaaga
	print(suitrender.emission_points)
		
