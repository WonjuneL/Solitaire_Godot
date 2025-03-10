extends Node2D
#Deck.gd는 카드의 생성, 셔플 및 배치에 관한 스크립트
#게임 시작 전의 모든 카드 배치에 관여

@export var card_scene: PackedScene  # 카드 프리팹

#초기값 설정용 어레이
var deck: Array = []  # 카드 덱 (1~52), 셔플용
var table: Array = [[], [], [], [], [], [], []]  # 7개의 카드 스택(초기값)
var stock: Array = []   #초기 스톡의 카드
var stock_index = 0     #스톡 어레이 액세스용 변수

#게임 데이터 실시간 저장용 어레이
var table_instances: Array = [[], [], [], [], [], [], []]  # 카드 객체를 저장하는 배열
var stock_instances: Array = []  # 스톡 카드 객체를 저장하는 배열
var foundation_instances: Array = [[], [], [], []] #파운데이션의 객체 저장용 배열
var stock_switch_instance

signal deck_setup(deck_I, table_I, stock_I, stock_switch)

func init():
    create_deck()
    shuffle_deck()
    deal_cards()

    emit_signal ("deck_setup", table_instances, stock_instances, foundation_instances, stock_switch_instance)
    print("(setup)Type of updated_cards:", typeof(stock_switch_instance))

func _free():
    for array in table_instances:
        for card in array:
            remove_child(card)
    for card in stock_instances:
        remove_child(card)
    for array in foundation_instances:
        for card in array:
            remove_child(card)
    remove_child(stock_switch_instance)
    queue_free()    #전달 후 삭제

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
        table[i].append(0)  #가장 밑에 깔리게 될 위치 표시 카드를 스택에 배치
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
        empty_card.set_face_up(true)
        table_instances[i].append(empty_card)

        for j in range(1, table[i].size()):
            var card_number = table[i][j]  # 저장된 카드 번호 가져오기
            var card = card_scene.instantiate()  # 카드 객체 생성
            add_child(card)  # 씬에 추가
            card.set_card_info(card_number)  # 카드 정보 설정
            card.z_index = j + 1        # z_index 추가, 최소치 1에서 1씩 증가됨.
            table_instances[i].append(card)

            if j == 1:      #첫 번째 카드 배치
                card.position = empty_card.position  # 0번 카드와 같은 위치
            else:
                card.position = Vector2(Constants.CARD_TABLE_X + i * Constants.CARD_OFFSET_X, Constants.CARD_TABLE_Y + (j - 1) * Constants.CARD_OVERLAP)  # 위치 지정


        # 루프 종료 후, 최상단 카드는 앞면 공개
        if table_instances[i].back():
            table_instances[i].back().set_face_up(true)
    #남은 카드로 스톡을 생성
    setup_stock()

    for i in range(4):
        # -2번 카드를 파운데이션 용으로 추가
        var empty_card = card_scene.instantiate()
        add_child(empty_card)
        empty_card.set_card_info(-2)  # 파운데이션 카드로 설정
        empty_card.position = Vector2(Constants.CARD_TABLE_X + Constants.CARD_WIDTH * 4.5 + Constants.CARD_OFFSET_X * i, Constants.CARD_TABLE_Y - Constants.CARD_HEIGHT * 2)
        empty_card.set_face_up(true)
        empty_card.z_index = 0
        empty_card.set_foundation(true)
        foundation_instances[i].append(empty_card)

func setup_stock():
    # 스톡 카드 배치
    stock_switch_instance = card_scene.instantiate()

    for i in range(stock.size()):
        var card_number = stock.pop_front()  # 스톡에서 카드 번호 가져오기
        var card = card_scene.instantiate()  # 카드 객체 생성
        add_child(card)         # 필수.
        card.z_index = i    # z_index 설정, 역순으로 설정.
        card.set_card_info(card_number)  # 카드 정보 설정
        card.position = Constants.STOCK_POSITION
        card.set_face_up(true)
        stock_instances.append(card)


    add_child(stock_switch_instance)     #마찬가지로 필수.
    stock_switch_instance.set_card_info(-1)  # 뒷면 스프라이트를 가진 카드
    stock_switch_instance.position = Constants.STOCK_POSITION
    stock_switch_instance.set_face_up(true)
    stock_switch_instance.z_index = 100
