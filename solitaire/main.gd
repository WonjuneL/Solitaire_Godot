extends Node2D

var cards

func _ready():
    call_deferred("_init_after_deck")  # Deck이 로드된 후 실행되도록 예약

func _init_after_deck():
    await get_tree().process_frame  # 한 프레임 뒤 실행 (Card의 생성 및 Deck로딩 이후)

    cards = get_tree().get_nodes_in_group("Cards")

    if cards.is_empty():
        print("Error: 'Cards' is empty")
    else:
        render_cards()  # 카드 렌더링 실행


func render_cards():
    for card in cards:
        var sprite = Sprite2D.new()  # 새로운 스프라이트 생성
        add_child(sprite)  # main 씬에 추가

        sprite.position = card.position  # 카드의 위치 설정
        SpriteManager.set_card_texture(sprite, card)  # 텍스처 설정
