extends Node2D

var deck: Array = []

func _ready():
    create_deck()
    shuffle_deck()
    spawn_cards()

# 1. 카드 덱 생성 (1~52 숫자)
func create_deck():
    deck = range(1, 53)

# 2. 카드 셔플
func shuffle_deck():
    deck.shuffle()
