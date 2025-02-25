extends Node

var selected_card = null  # 현재 선택된 카드
var target_card = null    # 이동할 목표 카드

func _ready():
    var cards = get_tree().get_nodes_in_group("Cards")
    for card in cards:
        if card.has_signal("clicked"):  # 신호가 있는지 체크
            card.clicked.connect(_on_card_clicked)
        else:
            print("Card without signal: ", card)

func _on_card_clicked(card):
    print("Clicked : ", card)
    if selected_card == null:
        if can_select(card):
            select_card(card)
        else:
            print("Check the card.")
        # 두 번째 클릭이면 target_card로 설정
    else:   #카드가 선택되어 있는 경우
        if can_select(card) and card.next_card == null: # 목표 카드에 next_card가 없는 경우에만 이동 가능
            target_card = card
            print("Target card selected.", target_card)
        else:
            print("Check the card.")
        if selected_card == card:
                print("Deselected.")
                deselect_card()
        if can_move(selected_card, target_card):
            move_card(selected_card, target_card)  # 이동 수행
        else :
            print("Invalid movement.")
            deselect_card()

func can_select(card):
    # 카드 선택이 가능한지 검사
        return card.is_face_up  #보이는 카드이면 선택가능.

func can_move(card_from, card_to):
    # 이동 가능 여부 확인
    if card_from == null:
        print("No card has been selected.")
        return false
    if card_to == null:
        print("Null destination.")
        return false
    if card_to.get_card_number() == 0:
        return card_from.is_face_up and card_from.rank == 13
    if card_to.get_card_number() == -1:
        return false
    if card_to.get_card_number() == -2:     #파운데이션 이동
        card_from.set_foundation(true) #파운데이션 플래그 활성화
        return card_from.is_face_up and card_from.rank == 1
    if card_to.is_foundation:
        return card_from.is_face_up and card_from.next_card == null and card_from.rank == card_to.rank + 1 and card_from.suit == card_to.suit
    # 숫자가 1 낮고, 색상이 다르면 이동 가능
    # 색이 다르고 숫자가 1 작은 경우만 이동 가능
    else:
        return ((abs(card_from.suit - card_to.suit) == 1 or abs(card_from.suit - card_to.suit) == 3) and card_from.rank == card_to.rank - 1)

func select_card(card):
    if selected_card == card:
        deselect_card()
        return
    deselect_card()
    selected_card = card
    selected_card.border.visible = true
    print("Card selected : ", card)

func deselect_card():
    if selected_card:
        selected_card.border.visible = false  # 선택 해제 시 테두리 숨김
        print("Card deselected : ", selected_card)
        selected_card = null
    else:
        print("Selected card does not exist.")

func move_card(card_from, card_to):
    # 1. 카드 이동
    if card_to.is_foundation:
        card_from.position = card_to.position
    else:
        card_from.position = card_to.position + Vector2(0, Constants.CARD_OVERLAP)

    # 2. prev_card의 face_up 설정 (단, prev_card가 0번 카드가 아닐 경우)
    if card_from.prev_card.get_card_number() != -1 and card_from.prev_card.get_card_number() != 0:
        card_from.prev_card.set_face_up(true)

    # 3. 연결 관계 변경
    if card_from.prev_card != null:
        card_from.prev_card.next_card = null  # 이전 카드의 next_card를 비움

    card_from.prev_card = card_to
    card_to.next_card = card_from

    # 4. 렌더링 순서 조정 (move_child 사용)
    var parent = card_from.get_parent()
    parent.move_child(card_from, -1)

    # 4. next_card 확인 후 연쇄 이동 수행
    if card_from.next_card != null:
        move_card(card_from.next_card, card_from)
    deselect_card()
