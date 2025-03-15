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
var cardcount = main.suitct*main.rankct
var move = null
var zind:int = 0

func _ready():
	for i in range(0, pilect):
		piles.append([])
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
			piles[i].back().z_index = j
		piles[i].back().flip()	
