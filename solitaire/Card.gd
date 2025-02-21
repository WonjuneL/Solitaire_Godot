extends Node2D

@export var suit: String = ""  # 카드 무늬 (Hearts, Diamonds, Clubs, Spades)
@export var rank: int = 0  # 카드 숫자 (1~13, 1은 Ace)
var is_face_up: bool = false  # 앞면 상태 여부

@onready var sprite = $Sprite2D

# 카드 앞/뒷면 설정 함수
func set_face_up(face_up: bool):
    is_face_up = face_up
    if is_face_up:
        sprite.texture = load("res://Cards_Asset/Front/%s_%d.png" % [suit, rank])
    else:
        sprite.texture = load("res://Cards_Asset/Back/red_backing.png")
#이상 카드 로딩
