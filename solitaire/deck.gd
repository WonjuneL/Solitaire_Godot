extends Node2D

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
        for j in range(table[i].size()):
            var card_number = table[i][j]  # 저장된 카드 번호 가져오기
            var card = card_scene.instantiate()  # 카드 객체 생성
            add_child(card)  # 씬에 추가
            card.set_card_info(card_number)  # 카드 정보 설정
            card.position = Vector2(i * 100, j * 30)  # 위치 지정

            # 최상단 카드만 앞면으로 설정
            if j == table[i].size() - 1:
                card.set_face_up(true)
