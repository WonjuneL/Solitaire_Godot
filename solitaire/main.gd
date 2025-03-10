extends Node2D

@onready var deck = $Deck

var setup

func _ready():
    setup = preload("res://Setup.tscn").instantiate()
    add_child(setup)

    print("setup executed.")
    # Setup -> Main 신호 연결
    var setup_connected = setup.connect("deck_setup", Callable(self, "_on_deck_ready"))
    var deck_connected = deck.connect("deck_updated", Callable(self, "_on_deck_updated"))
    deck.connect("deck_set", Callable(self, "_on_deck_set"))

    if setup_connected != OK:
        print("Error: Failed to connect setup")
    else:
        print("(main)setup connected")
    if deck_connected != OK:
        print("Error: Failed to connect deck")
    else:
        print("(main)deck connected")
    setup.init()  # Setup 초기화 실행


func _on_deck_ready(table, stock, foundation, switch):
    deck._on_deck_ready(table, stock, foundation, switch)
    print("(main) Init deck")
    deck.initialize()  # deck 실행.


func _init_after_deck():
    await get_tree().process_frame  # 한 프레임 뒤 실행 (Card의 생성 및 Deck로딩 이후)

func _on_deck_set(cards):
    print("Deck updated, updated_cards type:", cards)
    if cards is Array:
        for card in cards:
            SpriteManager.update_sprite(card)  # SpriteManager에 전달
    if setup:
        setup._free()
