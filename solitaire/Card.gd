extends Node2D

#Card.gd는 카드의 텍스쳐를 지정하는 스크립트

@export var card_number: int = 0  # 카드 번호 (1~52)

var suit_index = 0  # hearts=0, clubs=1, diamonds=2, spades=3
var rank_index = 0  # A=0, 2=1, ..., K=12
var suit := "null"
var rank := 0
var is_face_up: bool = false  # 앞면 상태 여부
var is_selected = false  # 카드 선택 여부
var suit_names = ["Hearts", "Clubs", "Diamonds", "Spades"]
var original_position = Vector2()

# 카드 정보 설정
func set_card_info(card_no: int):
    card_number = card_no
    if card_no<1:
        suit = "Extra"
        rank = card_number
    else:
        suit_index = ((card_number - 1) / 13)
        suit = suit_names[suit_index]

        rank_index = ((card_number - 1) % 13)
        rank = rank_index + 1
    set_face_up(false)  # 기본적으로 뒷면

#파운데이션 플래그
var is_foundation = false  # 기본적으로 일반 카드 (파운데이션 아님)

func set_foundation(flag: bool):
    is_foundation = flag

# 카드 앞/뒷면 설정
func set_face_up(face_up: bool):
    is_face_up = face_up

# 카드 번호 반환 함수
func get_card_number() -> int:
    return card_number

# 카드 문양/번호 반환 함수(디버그 편의용)
func get_card_info() -> String:
    return suit + " " + str(rank)

func get_card_position():
    return position

func _ready():
    z_index = 1     #디폴트값 설정
    original_position = position
    add_to_group("Cards")
