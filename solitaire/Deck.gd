extends Node2D

var deck: Array = []

func _ready():
    create_deck()
    shuffle_deck()
    start()

# 1. 카드 덱 생성 (1~52 숫자)
func create_deck():
    deck = range(1, 53)

# 2. 카드 셔플
func shuffle_deck():
    deck.shuffle()

var table = [[], [], [], [], [], [], []]  # 7개의 줄 스택
var stock = []  # 남은 카드(덱)
func start():
    # 7개의 줄 스택에 카드 배치
    for i in range(7):  # 줄 스택 7개
        for j in range(i + 1):  #줄 스택에 1, 2, 3,..., 7개의 카드 배치
            var card = deck.pop_front()  # 앞에서 카드 가져오기
            table[i].append(card)
    for stack in table:
        if stack.size() > 0:
            stack[-1].is_face_up = true
    stock = deck #남은 패를 그대로 스톡에 저장
    #디버그 출력
    print("Tableau 배치 상태:")
    for i in range(7):
        print("줄 %d: %s" % [i + 1, table[i]])

    print("남은 덱(Stock):", stock)
