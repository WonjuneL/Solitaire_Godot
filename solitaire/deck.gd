extends Node2D
#Deck.gd는 카드의 생성, 셔플 및 배치에 관한 스크립트
#게임 시작 전의 모든 카드 배치에 관여

@export var card_scene: PackedScene  # 카드 프리팹
@onready var sprite = $Sprite2D

var deck: Array = []  # 카드 덱 (1~52)
var table: Array = [[], [], [], [], [], [], []]  # 7개의 카드 스택
var stock: Array = [[],[]]  # 남은 카드, 스톡 내부/오픈된 카드

func _ready():
    set_texture()
    create_deck()
    shuffle_deck()
    deal_cards()

func set_texture():     #실행 시 텍스쳐를 설정
    var texture = ResourceManager.get_texture(Constants.texture_path)

    if texture:
        sprite.texture = texture  # 스프라이트에 적용
    else:
        print("텍스처 로드 실패")

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

        var top_card = empty_card  # 스택의 최상단 카드 추적

        for j in range(1, table[i].size()):
            var card_number = table[i][j]  # 저장된 카드 번호 가져오기
            var card = card_scene.instantiate()  # 카드 객체 생성
            add_child(card)  # 씬에 추가
            card.set_card_info(card_number)  # 카드 정보 설정
            card.z_index = j + 1        # z_index 추가, 최소치 1에서 1씩 증가됨.

            if j == 1:      #첫 번째 카드 배치
                card.position = empty_card.position  # 0번 카드와 같은 위치
            else:
                card.position = Vector2(Constants.CARD_TABLE_X + i * Constants.CARD_OFFSET_X, Constants.CARD_TABLE_Y + j * Constants.CARD_OVERLAP)  # 위치 지정

            top_card = card  # 최상단 카드 저장

        # 루프 종료 후, 최상단 카드는 앞면 공개
        if top_card:
            top_card.set_face_up(true)
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



func setup_stock():
    # 스톡 카드 배치
    var stock_switch = card_scene.instantiate()

    for i in range(stock.size()):
        var card_number = stock.pop_front()  # 스톡에서 카드 번호 가져오기
        var card = card_scene.instantiate()  # 카드 객체 생성
        add_child(card)         # 필수.
        card.z_index = i    # z_index 설정, 역순으로 설정.
        card.set_card_info(card_number)  # 카드 정보 설정
        card.position = Constants.STOCK_POSITION
        card.set_face_up(true)

    add_child(stock_switch)     #마찬가지로 필수.
    stock_switch.set_card_info(-1)  # 뒷면 스프라이트를 가진 카드
    stock_switch.position = Constants.STOCK_POSITION
    stock_switch.set_face_up(true)
    stock_switch.z_index = 100
