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
var piles = []
var stock = []
var homes = []
var stockpile = []
const cardcount = main.suitct*main.rankct
var move = null
var zind:int = 0
var dragged = []
var once:bool = true

func _ready():
	for i in range(0, pilect):
		var a = empty_card()
		a.pile = i
		piles.append([a])
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
	stock.shuffle()
	for i in range(0, pilect):
		for j in range(0, i+1):
			piles[i].append(stock.pop_back())
			piles[i].back().pile = i
			piles[i].back().zind = j
		piles[i].back().flip()	

func empty_card():
	var empty = preload("res://card.tscn").instantiate()
	empty.rank = -1
	empty.suit = -1
	empty.faceup = true
	empty.complete = true
	return empty
