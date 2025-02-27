extends Node

var selected_card = null  # 현재 선택된 카드
var target_card = null    # 이동할 목표 카드
var stock_last_card = null
var clicked_cards := []

func _ready():
    var cards = get_tree().get_nodes_in_group("Cards")
    for card in cards:
        if card.has_signal("clicked"):  # 신호가 있는지 체크
            card.clicked.connect(_on_card_clicked)
        else:
            print("Card without signal: ", card)

#클릭시 처리
func _on_card_clicked(card):
    clicked_cards.append(card)  # 클릭된 카드 추가
    await get_tree().process_frame  #동시에 클릭된 카드들을 위해 대기
    var top_card = highest_z_index_card(clicked_cards)
    clicked_cards.clear()  # 클릭된 카드 리스트 초기화

    if top_card == null:
        return

    print("Selected top card:", top_card.get_card_number())

    if selected_card == null:
        if top_card.is_face_up and top_card.get_card_number() != 0:
            select_card(top_card)
        else:
            print("Card is not set as front or card is '0'")

    # 두 번째 클릭이면 target_card로 설정
    else:   #카드가 선택되어 있는 경우
        if top_card.next_card == null: # 목표 카드에 next_card가 없는 경우에만 이동 가능
            target_card = top_card
            print("Target card :", target_card.get_card_number())
        else:
            print("Target is not the last card of stack.")
            deselect_card()
        if selected_card == top_card:
            deselect_card()
            print("Deselected.")
            return
        if can_move(selected_card, target_card):
            move_card(selected_card, target_card)  # 이동 수행
            return
        else :
            print("Invalid movement.")
            deselect_card()
            return

#z_index 처리 관련

func highest_z_index_card(clicked_cards):
    if clicked_cards.size() == 0:
        return

    var highest_card = clicked_cards[0]  # 첫 번째 카드를 기준으로 설정
    for card in clicked_cards:
        if card.z_index > highest_card.z_index:
            highest_card = card  # 더 높은 z_index가 있으면 변경
    print("Highest card: ", highest_card.get_card_number())
    return highest_card



func can_move(card_from, card_to):  #일반적인 이동에 관여.
    # 이동 가능 여부 확인
    if card_from == null:
        print("Card_from is null.(canmove)")
        return false
    if card_to == null:
        print("Null destination.(canmove)")
        return false
    if card_to.get_card_number() == 0:
        print("card_to is 0 (canmove)")
        if card_from.is_face_up and card_from.rank == 13:
            return true
        else:
            print("Slot is not empty(canmove)")
    if card_to.get_card_number() == -1:
        print("Can't move to stock. (canmove)")
        return false
    if card_to.get_card_number() == -2:  # 파운데이션 이동
        print("to foundation, first (canmove)")
        if card_from.is_face_up and card_from.rank == 1:
            card_from.set_foundation(true)  # 조건 만족 시에만 파운데이션 플래그 활성화
            return true
        else:
            print("Unknown issue(canmove)")
            return false
    if card_to.is_foundation:
        print("Foundation, again")
        return card_from.is_face_up and card_from.next_card == null and card_from.rank == card_to.rank + 1 and card_from.suit == card_to.suit
    # 숫자가 1 낮고, 색상이 다르면 이동 가능
    # 색이 다르고 숫자가 1 작은 경우만 이동 가능
    else:
        return ((abs(card_from.suit - card_to.suit) == 1 or abs(card_from.suit - card_to.suit) == 3) and card_from.rank == card_to.rank - 1)

func select_card(card):
    print("selected card(selectcard) : ", card.get_card_number())
    if selected_card == card:
        deselect_card()
        return
    if card.get_card_number() == -2:    #빈 파운데이션 공간 선택시
        print("Selected Foundation")
        return
    if card.get_card_number() == -1:    #스톡 스위치 작동시
        if card.prev_card:
            draw_stock(card)
        else:
            refill_stock(card)
        return
    deselect_card()
    selected_card = card
    selected_card.border.visible = true
    print("Card selected : ", card.get_card_number())
    print("card z_index: ", card.z_index)

func deselect_card():
    if selected_card:
        selected_card.border.visible = false  # 선택 해제 시 테두리 숨김
        print("Card deselected : ", selected_card.get_card_number())
        selected_card = null
    return

func move_card(card_from, card_to):
    # 1. 카드 이동
    if card_from.is_foundation:
        #card_from.prev_card.get_node("Area2D/CollisionShape2D").set_deferred("disabled", false) #파운데이션에서 카드를 꺼낼 때 꺼내지는 카드의 바로 아래 카드의 충돌판정을 활성화한다.
        card_from.set_foundation(false)
        print("card is not in foundation now")

    if card_to.is_foundation:
        card_from.position = card_to.position
        #card_to.get_node("Area2D/CollisionShape2D").set_deferred("disabled", true) #파운데이션에 넣은 카드 중 밑에 깔리는 부분은 충돌판정을 비활성화한다.
        card_from.set_foundation(true)
        print("card is at foundation now", card_from.prev_card.get_card_number())

    elif card_from.rank == 13:  #K가 움직이는 유일한 경우는 빈 공간으로 이동할 때이므로, 해당 자리에 배치한다.
        card_from.position = card_to.position
        #card_to.get_node("Area2D/CollisionShape2D").set_deferred("disabled", true)  # 이 위치에 이동시 0 카드를 비활성화한다.
    else:
        card_from.position = card_to.position + Vector2(0, Constants.CARD_OVERLAP)

    # 2. prev_card의 face_up 설정
    if card_from.prev_card.get_card_number():
        card_from.prev_card.set_face_up(true)
        #card_from.prev_card.get_node("Area2D/CollisionShape2D").set_deferred("disabled", false)

    # 3. 연결 관계 변경

    if card_from != stock_last_card:    #스톡에서는 예외처리 필요
        card_from.prev_card.next_card = null  # 이전 카드의 next_card를 비움
    elif card_from == stock_last_card:
        if stock_last_card.next_card:
            stock_last_card.next_card.prev_card = stock_last_card.prev_card
            stock_last_card.prev_card.next_card = stock_last_card.next_card
            stock_last_card = stock_last_card.next_card

        else:
            stock_last_card = null
        card_from.next_card = null  #스톡에서 꺼낸 카드의 nextcard는 항상 비어있음.

    #z_index 처리
    card_from.z_index = card_to.z_index + 1

    #if card_from.prev_card.get_card_number() == 0:      #옮기는 카드 밑의 카드가 0인 경우, collisionshape를 활성화해준다.
        #card_from.prev_card.get_node("Area2D/CollisionShape2D").set_deferred("disabled", false)
    #if card_to.get_card_number() == 0:                  #목표 카드가 0인 경우, collisionshape를 비활성화해준다.
        #card_to.get_node("Area2D/CollisionShape2D").set_deferred("disabled", true)



    # 4. 렌더링 순서 조정 (move_child 사용)
    var parent = card_from.get_parent()
    parent.move_child(card_from, -1)

    # 4. next_card 확인 후 연쇄 이동 수행
    if card_from.next_card != null:
        if can_move(card_from.next_card, card_from):
            move_card(card_from.next_card, card_from)
            card_from.prev_card = card_to
            card_to.next_card = card_from
        else:
            return  #이동 불가능한 경우 그냥 취소
    deselect_card()     #이동 완료 후 선택 자동으로 해제

func draw_stock(card):
    if card.prev_card:  #스톡에 남은 공개되지 않은 카드가 있다면
        stock_last_card = card.prev_card
        stock_last_card.position = Constants.STOCK_OPEN_POSITION
        #stock_last_card.get_node("Area2D/CollisionShape2D").set_deferred("disabled", false)
        #if stock_last_card.next_card and stock_last_card.next_card.get_card_number() != -1:
            #stock_last_card.next_card.get_node("Area2D/CollisionShape2D").set_deferred("disabled", true)
        #var parent = stock_last_card.get_parent()
        #parent.move_child(card.prev_card, parent.get_child_count() - 1)

    if stock_last_card.prev_card:  # 다음 카드가 있는 경우
        card.prev_card = stock_last_card.prev_card
    else:  # 마지막 카드를 뽑은 경우
        print("debug: last stock card")
        card.prev_card = null

func refill_stock(switch):
    var card = stock_last_card
    while card.next_card:
        card.position = Constants.STOCK_POSITION
        #card.get_node("Area2D/CollisionShape2D").set_deferred("disabled", true)
        if card.next_card.get_card_number() == -1:
            switch.prev_card = card
        card = card.next_card
