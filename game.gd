extends Node2D

var pilect:int = 10
var suitct:int = 8
var rankct:int = 13
var piles = []
var stock = []
var homes = []
var stockpile = []

func _init():
	
	for i in range(0, rankct):
		for j in range(0,suitct):
			var card = preload("res://card.tscn").instantiate()
			card.rank = i
			card.suit = j
			card.complete = true
			card.position = Vector2(30*i+3, 43*j)
			stock.append(card)
			add_child(card)
			
