extends Node2D
#Deck.gd는 카드의 생성, 셔플 및 배치에 관한 스크립트
#게임 시작 전의 모든 카드 배치에 관여

@export var card_scene: PackedScene  # 카드 프리팹

var stock_index = 0     #스톡 어레이 액세스용 변수
signal deck_updated(cards)
signal deck_set

#게임 데이터 실시간 저장용 어레이
var table_instances: Array = [[], [], [], [], [], [], []]  # 카드 객체를 저장하는 배열
var stock_instances: Array = []  # 스톡 카드 객체를 저장하는 배열
var foundation_instances: Array = [[], [], [], []] #파운데이션의 객체 저장용 배열
var stock_switch
var all_cards = get_all_cards()

func initialize():
    print("(deck) deck initialized")
    all_cards = get_all_cards()             #전역변수에 모든 카드를 저장한다.
    for card in all_cards:
        add_child(card)
    emit_signal("deck_set", all_cards)      #최초 실행이므로 반드시 모두 업데이트 신호를 보낸다.

func return_all_cards():
    return all_cards

#정보 수정 함수(임시)
func add_table_card(table_index, card):
    if table_instances[table_index]:
        table_instances[table_index].append(card)
        var updated_cards
        updated_cards.append(card)
        emit_signal("deck_updated", card)
    else:
        return null



func _on_deck_ready(table_I, stock_I, foundation_I, switch_I):
    table_instances = table_I
    stock_instances = stock_I
    foundation_instances = foundation_I
    stock_switch = switch_I

func get_table_card(table_index, card_index):
    if table_instances[table_index][card_index]:
        return table_instances[table_index][card_index]
    else:
        return null

func get_foundation_card(foundation_index, card_index):
    if table_instances[foundation_index][card_index]:
        return table_instances[foundation_index][card_index]
    else:
        return null

func get_stock_card(stock_index):
    var index = stock_index
    stock_index = stock_index + 1
    if stock_instances[index]:
        print("Stock : ", stock_instances[index].get_card_info())
        return stock_instances[index]
    else:
        print("Stock is empty")
        return null

#스프라이트 설정된 모든 카드
func get_all_cards() -> Array:
    var all_cards = []

    for column in table_instances:
        all_cards.append_array(column)


    all_cards.append_array(stock_instances)

    for foundation in foundation_instances:
        all_cards.append_array(foundation)

    all_cards.append(stock_switch)
    return all_cards
