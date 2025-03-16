extends Node2D

const suitpositions = {
0 : [Vector2i(0,0)],
1 : [Vector2i(0,3),Vector2i(0,-3)],
2 : [Vector2i(3,3),Vector2i(0,-3),Vector2i(-3,3)],
3 : [Vector2i(3,3),Vector2i(-3,3),Vector2i(3,-3),Vector2i(-3,-3)],
4 : [Vector2i(3,6),Vector2i(-3,6),Vector2i(0,0),Vector2i(3,-6),Vector2i(-3,-6)],
5 : [Vector2i(3,6),Vector2i(-3,6),Vector2i(3,0),Vector2i(-3,0),Vector2i(3,-6),Vector2i(-3,-6)],
6 : [Vector2i(3,6),Vector2i(-3,6),Vector2i(-6,0),Vector2i(0,0),Vector2i(6,0),Vector2i(3,-6),Vector2i(-3,-6)],
7 : [Vector2i(6,6),Vector2i(0,6),Vector2i(-6,6),Vector2i(3,0),Vector2i(-3,0),Vector2i(-6,-6),Vector2i(0,-6),Vector2i(6,-6)],
8 : [Vector2i(6,6),Vector2i(6,0),Vector2i(6,-6),Vector2i(0,6),Vector2i(0,0),Vector2i(0,-6),Vector2i(-6,6),Vector2i(-6,0),Vector2i(-6,-6)],
9 : [Vector2i(-3,9),Vector2i(3,9),Vector2i(-6,3),Vector2i(0,3),Vector2i(6,3),Vector2i(-6,-3),Vector2i(0,-3),Vector2i(6,-3),Vector2i(-3,-9),Vector2i(3,-9)],
10 : [Vector2i(-6,9),Vector2i(-6,3),Vector2i(-6,-3),Vector2i(-6,-9),Vector2i(0,6),Vector2i(0,0),Vector2i(0,-6),Vector2i(6,9),Vector2i(6,3),Vector2i(6,-3),Vector2i(6,-9)],
11 : [Vector2i(-6,9),Vector2i(-6,3),Vector2i(-6,-3),Vector2i(-6,-9),Vector2i(0,9),Vector2i(0,3),Vector2i(0,-3),Vector2i(0,-9),Vector2i(6,9),Vector2i(6,3),Vector2i(6,-3),Vector2i(6,-9)],
12 : [Vector2i(-6,9),Vector2i(0,9),Vector2i(6,9),Vector2i(-9,-3),Vector2i(0,-3),Vector2i(9,-3),Vector2i(-9,3),Vector2i(-3,3),Vector2i(3,3),Vector2i(9,3),Vector2i(-6,-9),Vector2i(0,-9),Vector2i(6,-9)]
}
const pilect:int = 10
const suitct:int = 8
const rankct:int = 13
const colors: int = 4
var piles: Array = []
var stock: Array = []
var homes: Array = []
var stockpile: Array = []
const cardcount = suitct*rankct
var move = null
var zind:int = 0
var dragged = []
var once:bool = true
var enis = null

func save_state():
	var state = {}
	
	var state_piles = []
	for i in range(piles.size()):
		var pile = piles[i]
		var pile_arr = []
		for card in pile:
			if card.suit == -1 or card.rank == -1: continue
			pile_arr.append(card.serialize())
		state_piles.append(pile_arr)
	state["piles"] = state_piles
	
	print(state)

func _ready():
	for i in range(0, pilect):
		var a = empty_card()
		a.pile = i
		piles.append([a])
		add_child(a)
	if true:
		var a = empty_card()
		a.stockrefresher = true
		add_child(a)
	for i in range(0, suitct):
		var a = empty_card()
		a.home = i
		homes.append([a])
		add_child(a)
	for i in range(0, rankct):
		for j in range(0,suitct):
			var card = preload("res://card.tscn").instantiate()
			card.rank = i
			card.suit = j
			card.complete = true
			stock.append(card)
			add_child(card)
	stock.reverse()#.shuffle()
	for i in range(0, pilect):
		for j in range(0, i+1):
			piles[i].append(stock.pop_back())
			piles[i].back().pile = i
			piles[i].back().zind = j
		piles[i].back().flip()	

func _process(_delta):
	var won = true
	for home in main.homes:
		if len(home) != rankct+1: won = false
	if !enis and won: 
		enis = preload("res://wiener.tscn").instantiate()
		add_child(enis)
	if enis: enis.position = Vector2i(151,151)

func empty_card():
	var empty = preload("res://card.tscn").instantiate()
	empty.rank = -1
	empty.suit = -1
	empty.faceup = true
	empty.complete = true
	return empty

func _input(event: InputEvent) -> void:
	if !event.is_pressed():
		return
	if event.is_action("debug.savestate"):
		save_state()
