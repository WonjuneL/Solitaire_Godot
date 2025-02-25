extends Node2D
#Deck.gd는 카드의 생성, 셔플 및 배치에 관한 스크립트

@export var card_scene: PackedScene  # 카드 프리팹

var deck: Array = []  # 카드 덱 (1~52)
var table = [[], [], [], [], [], [], []]  # 7개의 카드 스택
var stock = []  # 남은 카드들 (Stock)

func _ready():
    create_deck()
    shuffle_deck()
    deal_cards()

# 1. 카드 덱 생성 (1~52)
func create_deck():
    deck = range(1, 53)

# 2. 카드 셔플
func shuffle_deck():
    deck.shuffle()

# 3. 카드 배치 (Tableau & Stock)
func deal_cards():
    # 7개의 스택에 카드 배치
    for i in range(7):
        for j in range(i + 1):
            var card_number = deck.pop_front()
            table[i].append(card_number)

    # 남은 카드를 Stock에 저장
    stock = deck.duplicate()

    # 배치된 카드의 실제 씬을 생성하고 추가
    place_cards()

# 4. 카드 씬을 생성하여 배치
func place_cards():
    for i in range(7):
        # 0번 카드를 빈 공간용으로 추가
        var empty_card = card_scene.instantiate()
        add_child(empty_card)
        empty_card.set_card_info(0)  # 0번 카드로 설정
        empty_card.position = Vector2((2 + 1.5 * i) * Constants.CARD_WIDTH, 200)
        empty_card.set_face_up(false)  # 빈 카드 자체는 비공개 (투명 또는 회색 카드)

        var prev_card = empty_card  # 첫 번째 prev_card를 0번 카드로 설정
        var top_card = null  # 스택의 최상단 카드 추적

        for j in range(table[i].size()):
            var card_number = table[i][j]  # 저장된 카드 번호 가져오기
            var card = card_scene.instantiate()  # 카드 객체 생성
            add_child(card)  # 씬에 추가
            card.set_card_info(card_number)  # 카드 정보 설정

            # 0번 카드 위에 배치해야 하는 경우
            if prev_card.get_card_number() == 0:
                card.position = empty_card.position  # 0번 카드와 같은 위치
            else:
                card.position = Vector2((2 + 1.5 * i) * Constants.CARD_WIDTH, 200 + j * Constants.CARD_OVERLAP)  # 위치 지정

            # prev_card가 존재하면 연결
            if prev_card:
                prev_card.set_next_card(card)
                card.set_prev_card(prev_card)

            prev_card = card  # 현재 카드를 prev_card로 설정
            top_card = card  # 최상단 카드 저장

        # 루프 종료 후, 최상단 카드는 앞면 공개
        if top_card and top_card.get_next_card() == null:
            top_card.set_face_up(true)
