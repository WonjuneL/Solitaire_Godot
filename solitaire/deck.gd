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
        empty_card.z_index = 0
        empty_card.position = Vector2(Constants.CARD_TABLE_X + i * Constants.CARD_OFFSET_X, Constants.CARD_TABLE_Y)
        #empty_card.get_node("Area2D/CollisionShape2D").set_deferred("disabled", true)   #덱에서는 반드시 0번 위에 카드가 존재하므로 확인할 것 없이 충돌판정을 제거
        empty_card.set_face_up(true)

        var prev_card = empty_card  # 첫 번째 prev_card를 0번 카드로 설정
        var top_card = null  # 스택의 최상단 카드 추적

        for j in range(table[i].size()):
            var card_number = table[i][j]  # 저장된 카드 번호 가져오기
            var card = card_scene.instantiate()  # 카드 객체 생성
            add_child(card)  # 씬에 추가
            card.set_card_info(card_number)  # 카드 정보 설정
            card.z_index = j + 1        # z_index 추가, 최소치 1에서 1씩 증가됨.
            #card.get_node("Area2D/CollisionShape2D").set_deferred("disabled", true) #우선은 모두 충돌 판정이 없는 상태로
            # 0번 카드 위에 배치해야 하는 경우 == 첫 배치
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
        if top_card:
            top_card.set_face_up(true)
            #top_card.get_node("Area2D/CollisionShape2D").set_deferred("disabled", false)  #콜리전 활성

    setup_stock()

    for i in range(4):
        # -2번 카드를 파운데이션 용으로 추가
        var empty_card = card_scene.instantiate()
        add_child(empty_card)
        empty_card.set_card_info(-2)  # 파운데이션 카드로 설정
        empty_card.position = Vector2(Constants.CARD_TABLE_X + Constants.CARD_WIDTH * 4.5 + Constants.CARD_OFFSET_X * i, Constants.CARD_TABLE_Y - Constants.CARD_HEIGHT * 2)
        empty_card.set_face_up(true)
        empty_card.z_index = 0
        #empty_card.get_node("Area2D/CollisionShape2D").set_deferred("disabled", false) #콜리전 활성화
        empty_card.set_foundation(true)



func setup_stock():
    # 스톡 카드 배치
    var prev_card = null
    var stock_switch = card_scene.instantiate()

    for i in range(stock.size()):
        var card_number = stock.pop_front()  # 스톡에서 카드 번호 가져오기
        var card = card_scene.instantiate()  # 카드 객체 생성
        add_child(card)         # 필수.
        card.z_index = -i    # z_index 설정, 역순으로 설정.
        card.set_card_info(card_number)  # 카드 정보 설정
        card.position = Constants.STOCK_POSITION
        card.set_face_up(true)
        #card.get_node("Area2D/CollisionShape2D").set_deferred("disabled", true) #기본적으로는 모두 충돌 판정이 해제된 상태
        if prev_card:
            card.set_prev_card(prev_card)
            card.prev_card.set_next_card(card)  #앞뒤 카드의 연결
        if card.next_card == null:
            card.next_card = stock_switch
        prev_card = card
        stock_switch.set_prev_card(card)    #마지막에 배치된 카드를 prev_card로 스위치가 지님.

    add_child(stock_switch)     #마찬가지로 필수.
    stock_switch.set_card_info(-1)  # 스톡 뒷면 카드
    stock_switch.position = Constants.STOCK_POSITION
    stock_switch.set_face_up(true)
    stock_switch.z_index = 100
