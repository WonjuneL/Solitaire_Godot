extends Node2D

var cards = []  # deck에서 가져올 카드 리스트

func _ready():
    var deck = get_node("/root/Main/Deck")  # deck 노드 가져오기
    if deck:
        cards = deck.get_cards()  # 카드 리스트 가져오기
        render_cards()  # 카드 렌더링 함수 호출

func render_cards():
    for card in cards:
        var sprite = Sprite2D.new()  # 새로운 스프라이트 생성
        add_child(sprite)  # main 씬에 추가

        sprite.position = card.position  # 카드의 위치 설정
        SpriteManager.set_card_texture(sprite, card)  # 텍스처 설정
