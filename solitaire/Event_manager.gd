extends Node2D

var selected_card
signal card_selected(card, bool)    #true:선택, false:선택 해제
signal card_move(from_card, to_card)

func _input(event):
    if event is InputEventMouseButton and event.pressed:
        var mouse_pos = get_global_mouse_position()
        print("Mouse Clicked at:", mouse_pos)  #디버그 코드
        var clicked_card = _get_card_at_position(mouse_pos) #가장 위의 카드를 clicked_card로 설정

        if clicked_card and clicked_card.is_face_up == true:
            if clicked_card.get_card_number() == -1:    #스톡 선택시
                _deselect_card()    #선택된 카드와 관계없이 스위치를 누르면 선택을 해제하고 스톡 처리를 진행
                emit_signal("card_selected", clicked_card, false)
                print("stock switch")   #디버그
                pass    #스톡 스위치 처리를 move_manager에 요청
                return

            if clicked_card.get_card_number() == -2:    #파운데이션 선택시
                if selected_card == null:
                    print("It's empty foundation.")
                else:
                    print("call move_manager, move to foundation")    #move_manager를 호출해 파운데이션에 대한 이동 처리 요청
                    _deselect_card()    #처리 후 선택은 해제
                    emit_signal("card_selected", clicked_card, false)
                return
            if selected_card == null:
                _select_card(clicked_card)
                emit_signal("card_selected", clicked_card, true)
            else:
                #selected_card와 clicked_card를 이용해 move_manager호출
                if selected_card==clicked_card:
                    print("Deselect card : ", clicked_card.get_card_info())
                    _deselect_card()
                    emit_signal("card_selected", clicked_card, false)
                    return
                emit_signal("card_move", selected_card, clicked_card)
                _deselect_card()
                emit_signal("card_selected", clicked_card, false)


        else:
            print("No card is on that position.")

# 특정 위치에 있는 카드를 찾는 함수
func _get_card_at_position(position):
    var deck = get_node("/root/Main/Deck")
    var cards = deck.return_all_cards()
    var candidates = [] # 해당 위치의 선택 '후보군'
    var top_card = null
    for card in cards:  # "cards" 그룹에 속한 모든 카드 검사
        var bounds = get_card_bound(card)
        #print("Checking card:", card.get_card_info(), ", Bounds:", bounds) #디버그 코드
        var min_x = bounds[0]
        var max_x = bounds[1]
        var min_y = bounds[2]
        var max_y = bounds[3]

        if position.x >= min_x and position.x <= max_x and position.y >= min_y and position.y <= max_y:
             candidates.append(card)

    if candidates.size() == 0:  # 후보군이 없으면 null 반환
        return null
    for card in candidates:  # 후보군에서 가장 높은 z_index 카드 찾기
        if top_card == null or card.z_index > top_card.z_index:
            top_card = card
    if top_card:
        return top_card

# 카드의 경계를 반환하는 함수
func get_card_bound(card):
    if card:
        var width = Constants.CARD_WIDTH
        var height = Constants.CARD_HEIGHT
        var pos = card.global_position

        var bounds = [
            pos.x - width / 2,  # min_x
            pos.x + width / 2,  # max_x
            pos.y - height / 2,  # min_y
            pos.y + height / 2 # max_y
            ]
        return bounds
    else:
        print("Error: get_rect() returned null for card ", card.get_card_info())

    return []

# 카드 선택 기능
func _select_card(card):
    if selected_card == card:
        print("Deselect card : ", selected_card.get_card_info())
        _deselect_card()
        return  # 이미 선택된 카드면 무시
    if selected_card:   #이미 선택된 카드가 있었던 경우에
        _deselect_card()
    selected_card = card
    print("Card Selected:", card.get_card_info())

# 카드 선택 해제 기능
func _deselect_card():
    if selected_card:
        selected_card = null
        print("Deselected") #디버그
