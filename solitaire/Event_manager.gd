extends Node2D

var selected_card

func _input(event):
    if event is InputEventMouseButton and event.pressed:
        var mouse_pos = get_global_mouse_position()
        print("Mouse Clicked at:", mouse_pos)

        var clicked_card = _get_card_at_position(mouse_pos)

        if clicked_card:
            if selected_card:
                _deselect_card()
            _select_card(clicked_card)
            _highlight_card(clicked_card, true)         #디버그 코드
        else:
            print("No card is on that position.")

# 특정 위치에 있는 카드를 찾는 함수
func _get_card_at_position(position):
    var cards = get_tree().get_nodes_in_group("Cards")
    var candidates = [] # 해당 위치의 선택 '후보군'
    var top_card = null
    for card in cards:  # "cards" 그룹에 속한 모든 카드 검사
        var bounds = get_card_bound(card)
        print("Checking card:", card.get_card_info(), ", Bounds:", bounds)
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
        var width = Constants.CARD_WIDTH * card.scale.x
        var height = Constants.CARD_HEIGHT * card.scale.y
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
        print("Card already selected:", card.get_card_info())
        return  # 이미 선택된 카드면 무시

    if selected_card:
        _deselect_card()  # 기존 선택 해제

    selected_card = card
    print("Card Selected:", card.get_card_info())

# 카드 선택 해제 기능
func _deselect_card():
    _highlight_card(selected_card, false)       #디버그 코드
    selected_card = null
    print("Deselecting Card")


#이하 임시 코드(추후 이동 혹은 삭제 필요)
func _add_overlay(card):
    var overlay = ColorRect.new()
    overlay.position -= Vector2(Constants.CARD_WIDTH / 2, Constants.CARD_HEIGHT / 2)
    overlay.color = Color(1, 0, 0, 0.5)  # 반투명 빨간색
    overlay.size = Vector2(Constants.CARD_WIDTH, Constants.CARD_HEIGHT)
    overlay.name = "HighlightOverlay"
    overlay.z_index = 100
    card.add_child(overlay)

func _remove_overlay(card):

    var overlay = card.get_node_or_null("HighlightOverlay")
    if overlay:
        overlay.queue_free()
        card.remove_child(overlay)

func _highlight_card(card, switch):
    if switch == false:
        _remove_overlay(card)  # 기존 선택된 카드 효과 제거

    if switch == true:
        _add_overlay(card)  # 새 카드에 효과 추가
