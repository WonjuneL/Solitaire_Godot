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
    else:
        if can_select(card):
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
    # 카드 선택이 가능한지 검사 (예: 최상단 카드인지, 특정 조건을 만족하는지)
    return card.is_face_up

func can_move(card_from, card_to):
    # 이동 가능 여부 확인
    # 빈 칸에 놓는 경우 → 킹(K)만 가능
    if card_from == null:
        print("No card has been selected.")
        return false
    if card_to == null:
        #빈 공간에 충돌판정 추가 필요.
        return card_from.is_face_up and card_from.rank == 13

    # 숫자가 1 낮고, 색상이 다르면 이동 가능
    # 색이 다르고 숫자가 1 작은 경우만 이동 가능
    else:
        return (card_from.suit != card_to.suit and card_from.rank == card_to.rank - 1)



func select_card(card):
    selected_card = card
    selected_card.border.visible = true  # 선택된 카드의 테두리 활성화
    print("Card selected : ", card)

func deselect_card():
    if selected_card:
        selected_card.border.visible = false  # 선택 해제 시 테두리 숨김
        print("Card deselected : ", selected_card)
        selected_card = null
    else:
        print("Selected card does not exist.")

func move_card(card_from, card_to):
    print("카드 이동: ", card_from, " → ", card_to)

    var old_parent = card_from.get_parent()  # 이동 전 부모
    var new_parent = card_to.get_parent()  # 새 부모

    if new_parent == null:
        print("이동 실패: target_card의 부모가 없음.")
        return
#수정중
    # 부모 변경
    card_from.reparent(new_parent)


    # z_index 가장 위로 조정
    card_from.z_index = get_highest_z_index(new_parent) + 1

    # 기존 부모에서 가장 위 카드가 있으면 face_up
    if old_parent:
        var top_card = get_top_card(old_parent)
        if top_card:
            top_card.is_face_up = true

    # 강제 화면 갱신
    card_from.queue_redraw()
    new_parent.queue_redraw()

    # 선택 해제
    deselect_card()


func get_highest_z_index(parent):
    var highest_z = -1  # 초기값을 -1로 설정
    for card in parent.get_children():
        if card.z_index > highest_z:
            highest_z = card.z_index
    return highest_z

func get_top_card(parent):
    var top_card = null
    var highest_z = -1  # z_index는 0 이상이므로 -1로 초기화

    for card in parent.get_children():
        if card.z_index > highest_z:
            highest_z = card.z_index
            top_card = card

    return top_card
