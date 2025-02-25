extends Node2D
#Deck.gd는 카드의 생성, 셔플 및 배치에 관한 스크립트
#게임 시작 전의 모든 카드 배치에 관여

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
        empty_card.position = Vector2(Constants.CARD_TABLE_X + i * Constants.CARD_OFFSET_X, Constants.CARD_TABLE_Y)

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
                card.position = Vector2(Constants.CARD_TABLE_X + i * Constants.CARD_OFFSET_X, Constants.CARD_TABLE_Y + j * Constants.CARD_OVERLAP)  # 위치 지정

            # prev_card가 존재하면 연결
            if prev_card:
                prev_card.set_next_card(card)
                card.set_prev_card(prev_card)

            prev_card = card  # 현재 카드를 prev_card로 설정
            top_card = card  # 최상단 카드 저장

        # 루프 종료 후, 최상단 카드는 앞면 공개
        if top_card and top_card.get_next_card() == null:
            top_card.set_face_up(true)

    setup_stock()

    for i in range(4):
        # -1번 카드를 파운데이션 용으로 추가
        var empty_card = card_scene.instantiate()
        add_child(empty_card)
        empty_card.set_card_info(-2)  # 0번 카드로 설정
        empty_card.position = Vector2(Constants.CARD_TABLE_X + Constants.CARD_WIDTH * 4.5 + Constants.CARD_OFFSET_X * i, Constants.CARD_TABLE_Y - Constants.CARD_HEIGHT * 2)
        empty_card.set_face_up(true)
        empty_card.set_foundation(true)

var stock_switch

func setup_stock():
    # 스톡 카드 배치
    stock_switch = card_scene.instantiate()
    add_child(stock_switch)
    stock_switch.set_card_info(-1)  # 가짜 카드
    stock_switch.position = Vector2(Constants.CARD_TABLE_X, Constants.CARD_TABLE_Y - Constants.CARD_HEIGHT * 2)

    # 클릭 이벤트 연결

func _on_stock_switch_pressed():
    var stock_top_card = 0
    if stock.size() > 0:
        var card_number = stock.pop_back()
        var new_card = card_scene.instantiate()
        add_child(new_card)
        new_card.set_card_info(card_number)
        new_card.position = Vector2(4 * Constants.CARD_WIDTH, Constants.CARD_HEIGHT * 0.5)
        new_card.set_face_up(true)

        # prev_card 설정 (이전에 뽑힌 카드와 연결)
        if stock_top_card:
            new_card.prev_card = stock_top_card

        stock_top_card = new_card  # 새로 뽑은 카드를 최상단으로 설정

    # 스톡이 비었을 경우, 뒷면 카드 숨기거나 색상 변경
    if stock.size() == 0:
        stock_switch.visible = false
