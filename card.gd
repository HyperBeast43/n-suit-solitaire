extends Area2D

var suit:int = 0
var rank:int = 0
var faceup:bool = false
var complete:bool = false
var hovered:bool = false
var dragged:bool = false 
var stockindex:int = -1
var pile:int = -1
var pileindex:int = -1
var home:int = -1
var homeindex:int = -1
var dragindex:int = -1
var guh = []
var athome:bool = false
var zind:int = 0

@onready var sprite:Sprite2D = $Sprite2D
@onready var suitrender:CPUParticles2D = $Sprite2D/suitparticles
@onready var rankrender:CPUParticles2D = $Sprite2D/rankparticles



func _ready():
	if suit != -1: sprite.texture = preload("res://sprites/card.png")
	position = Vector2(30*(rank)+3, 43*(suit+1))
	while !complete:
		pass
	readyup()
	flip()
	flip()
	if suitrender: suitrender.emitting = true


func readyup():
	if suit == -1:
		suitrender.free()
		rankrender.free()
		return
	suitrender.texture = load("res://sprites/suits/"+str(suit)+".tres")
	rankrender.texture = load("res://sprites/ranks/"+str(rank)+".tres")
	var awaaga:PackedVector2Array = suitrender.emission_points
	for i in range(0,rank+1):
		awaaga.append(Vector2(main.suitpositions[rank][i]))
	suitrender.emission_points = awaaga

func flip():
	faceup = !faceup
	if suitrender: suitrender.visible = faceup
	if rankrender: rankrender.visible = faceup
	if suit == -1:
		sprite.texture = preload("res://sprites/border.png")
	elif faceup:
		sprite.texture = preload("res://sprites/card.png")
	else:
		sprite.texture = preload("res://sprites/back.png")

func _process(_delta):
	if dragged: z_index = zind+main.cardcount
	else: z_index = zind 
	athome = (home != -1)
	if !Input.is_action_pressed("leftclick"):
		main.once = true
	if self in main.stockpile: 
		zind = main.stockpile.find(self)
	else:
		pileindex = main.piles[pile].find(self)
#		print(str(self)+","+str(main.stockpile.front())+","+str(self==main.stockpile.front()))
	stockindex = main.stock.find(self) 
	homeindex = main.homes[home].find(self)
	if not(self in main.stockpile): zind = max(stockindex, pileindex)
	if Input.is_action_just_pressed("leftclick") and hovered and faceup and suit != -1 and (not(self in main.stockpile) or self == main.stockpile.back()):
		if main.move == null:
			main.move = self
			if self in main.stockpile:
				if self == main.stockpile.back():
					main.dragged = [self]
					dragged = true
			elif home != -1:
				main.dragged = [self]
				dragged = true
			else:
				main.dragged = main.piles[pile].slice(pileindex, main.piles[pile].size())
				var i = 0
				for card in main.dragged:
					card.dragindex = len(main.dragged) - i
					card.zind = i
					i += 1
					card.dragged = true
		return
	if Input.is_action_just_pressed("leftclick") and hovered and stockindex == 0 and main.once:
		main.once = false
		main.stockpile.push_back(main.stock.pop_front())
		stockindex = -1
		flip()
		return
	if dragged:
		position = get_global_mouse_position()-Vector2(13,-20+dragindex*8)
	elif main.move == self: 
		main.move=null 
		checkmove()
	if !dragged and pile>=0 and pileindex != -1:
		position = Vector2(pile*30+3,86+(pileindex-1)*8)
		if suit == -1: position = position+Vector2(0,8)
		return
	if !dragged and home>=0:
		position = Vector2(home*30+63,43)
		return
	if self in main.stockpile and !dragged:
		position = Vector2(33,43)
		return
	if stockindex != -1:
		position = Vector2(3,43)
		return
	if !Input.is_action_pressed("leftclick"):
		dragged = false
		return
	

func checkmove():
	
	var overlapping_areas = get_overlapping_areas()
	if len(overlapping_areas) == 0: return
	var target = null
	var distance = null
	var min_distance = 9999999.9
	var target_pile = -1
	for area in overlapping_areas:
		if area != self and area.faceup:  
			distance = position.distance_to(area.position)
			if distance < min_distance and (
				area.pileindex+1 == len(main.piles[area.pile])
				and
				(
					not area.athome and (
						(area.rank == rank + 1 and area.suit % 2 != suit % 2)
						or
						(rank == main.rankct - 1)
					)
				)
				or
				(
					area.athome and (
						(area.suit == suit or area.suit == -1)
					and area.rank == rank - 1)
				)
			):
				min_distance = distance
				target = area
			else: pass
	if target == null: 
		dragged = false
		main.dragged = []
		main.move = null
		return
	if target.home != -1 and len(main.dragged)>1:
		main.dragged = []
		main.move = null
		return
	if target.home == -1: target_pile = target.pile  
	else: target_pile = target.home

	if !target.athome:
		if target_pile >= 0:
			if not(self in main.stockpile):
				if !main.piles[pile][pileindex-1].faceup and main.piles[pile][pileindex-1].suit != -1:
					main.piles[pile][pileindex-1].flip()
				for tomove in main.dragged:
					main.piles[target_pile].append(tomove)
					main.piles[tomove.pile].erase(tomove)  
					tomove.pile = target_pile  
			else:
				main.piles[target_pile].append(main.stockpile.pop_back())
				pile = target_pile 
	else:
		if target_pile >= 0:
			if not(self in main.stockpile):
				if !main.piles[pile][pileindex-1].faceup and main.piles[pile][pileindex-1].suit != -1 and self.home == -1:
					main.piles[pile][pileindex-1].flip()
				main.homes[target_pile].append(self)
				main.piles[pile].erase(self)  
			else:
				main.homes[target_pile].append(main.stockpile.pop_back())
			pile = -1
			home = target_pile  
			main.dragged = []
	main.dragged = []
	main.move = null
	return

func _on_mouse_entered():
	hovered = true

func _on_mouse_exited():
	hovered = false
