extends Node2D

@export var card_number: int = 0  # 카드 번호 (1~52)
var suit: String = ""  # 카드 무늬 (Hearts, Diamonds, Clubs, Spades)
var rank: int = 0  # 카드 숫자 (1~13, Ace=1)
var is_face_up: bool = false  # 앞면 상태 여부

@onready var sprite = $Sprite2D  # 스프라이트 노드

const CARD_SPRITE_SHEET = "res://full_page.png"  # 카드 이미지

const CARD_WIDTH = 57  # 카드 한 장의 가로 크기
const CARD_HEIGHT = 79  # 카드 한 장의 세로 크기

# 카드 뒷면 좌표
const BACK_UV_X = 2 + 1 * (CARD_WIDTH + 2)  # 5번째 열
const BACK_UV_Y = 2 + 4 * (CARD_HEIGHT + 2)  # 2번째 행

# 카드 정보 설정
func set_card_info(card_num: int):
    card_number = card_num
    suit = ["Hearts", "Clubs", "Diamonds", "Spades"][((card_num - 1) / 13) as int]
    rank = ((card_num - 1) % 13) + 1
    set_face_up(false)  # 기본적으로 뒷면

# 카드 앞/뒷면 설정
func set_face_up(face_up: bool):
    is_face_up = face_up
    var texture = AtlasTexture.new()
    texture.atlas = load(CARD_SPRITE_SHEET)

    if is_face_up:
        var suit_index = ["Hearts", "Clubs", "Diamonds", "Spades"].find(suit)
        var rank_index = (rank - 1)  # A=1, 2=2, ..., K=13

        # **카드 스프라이트의 정확한 열, 행 계산**
        var column = (rank_index % 3) + (suit_index * 3)  # suit마다 그룹 배치
        var row = rank_index / 3  # 행 계산

        var x = 2 + column * (CARD_WIDTH + 2)
        var y = 2 + row * (CARD_HEIGHT + 2)

        texture.region = Rect2(x, y, CARD_WIDTH, CARD_HEIGHT)
    else:
        texture.region = Rect2(BACK_UV_X, BACK_UV_Y, CARD_WIDTH, CARD_HEIGHT)

    sprite.texture = texture  # 스프라이트에 텍스처 적용
