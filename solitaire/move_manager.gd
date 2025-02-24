extends Node2D

var selected_card = null  # 첫 번째 클릭한 카드

func select_card(card):
    if selected_card == null:
        selected_card = card  # 첫 번째 클릭된 카드 저장
    else:
        attempt_move(selected_card, card)
        selected_card = null  # 선택 초기화

func card_clicked(card):
    # 기존 선택된 카드가 있으면 선택 해제
    if selected_card:
        selected_card.set_selected(false)

    # 같은 카드를 다시 클릭하면 선택 해제하고 종료
    if selected_card == card:
        selected_card = null
        return

    # 새로운 카드 선택
    selected_card = card
    selected_card.set_selected(true)


func attempt_move(from_card, to_card):
    if is_valid_move(from_card, to_card):
        move_card(from_card, to_card)
    else:
        print("🚫 잘못된 이동")

func is_valid_move(from_card, to_card) -> bool:
    # 예제: 카드 색상 번갈아 배치 & 숫자 순서 확인 (K -> Q -> J ... 2 -> A)
    var valid_suits = {
        "Hearts": ["Clubs", "Spades"],
        "Diamonds": ["Clubs", "Spades"],
        "Clubs": ["Hearts", "Diamonds"],
        "Spades": ["Hearts", "Diamonds"]
    }

    if from_card.rank != to_card.rank - 1:
        return false  # 숫자 순서가 맞지 않음

    if to_card.suit not in valid_suits[from_card.suit]:
        return false  # 색상 규칙이 맞지 않음

    return true

func move_card(from_card, to_card):
    from_card.get_parent().remove_child(from_card)
    to_card.add_child(from_card)
    from_card.position = Vector2(0, 30)  # 카드 아래로 이동
