extends Node2D
#Card.gd는 카드의 텍스쳐를 지정하는 스크립트
@export var card_number: int = 0  # 카드 번호 (1~52)
var suit: int = 0  # 카드 무늬 (Hearts 1, Clubs 2, Diamonds 3, Spades 4)
var rank: int = 0  # 카드 숫자 (1~13, Ace=1)
var is_face_up: bool = false  # 앞면 상태 여부
var is_selected = false  # 카드 선택 여부

@onready var sprite = $Sprite2D  # 스프라이트 노드
@onready var MoveManager = get_node("/root/Main/MoveManager")
@onready var border: ColorRect = $ColorRect  # 테두리 노드 가져오기
@onready var area = $Area2D
@onready var collision_shape = $Area2D/CollisionShape2D

const CARD_SPRITE_SHEET = "res://full_page.png"  # 카드 이미지




# 카드 정보 설정
func set_card_info(card_num: int):
    card_number = card_num
    suit = ((card_num-1) / 13) + 1
    rank = ((card_num - 1) % 13) + 1
    set_face_up(false)  # 기본적으로 뒷면


# 카드 번호 반환 함수 (추가)
func get_card_number() -> int:
    return card_number

# 카드의 전, 후 카드 확
var prev_card = null
var next_card = null

func set_prev_card(card):
    prev_card = card
func set_next_card(card):
    next_card = card

func get_prev_card():
    return prev_card
func get_next_card():
    return next_card

# 카드 앞/뒷면 설정
func set_face_up(face_up: bool):
    is_face_up = face_up
    var texture = AtlasTexture.new()
    texture.atlas = load(CARD_SPRITE_SHEET)
    if card_number == 0 :    # 빈 스택 표시용 0번 카드 (뒷면 스프라이트 이용)
        texture.region = Rect2(Constants.BACK_K_UV_X, Constants.BACK_K_UV_Y, Constants.CARD_WIDTH, Constants.CARD_HEIGHT)
    elif card_number == -1 :    # 덱 표시용 -1번 카드 (뒷면 스프라이트 이용)
        texture.region = Rect2(Constants.BACK_UV_X, Constants.BACK_UV_Y, Constants.CARD_WIDTH, Constants.CARD_HEIGHT)
    elif card_number == -2 :    # 파운데이션 위치 표시용 -2번 카드 (뒷면 스프라이트 이용)
        texture.region = Rect2(Constants.JOCKER_UV_X, Constants.JOCKER_UV_Y, Constants.CARD_WIDTH, Constants.CARD_HEIGHT)
    else :
        if is_face_up:
            #get_node("Area2D/CollisionShape2D").set_deferred("disabled", false)
            var suit_index = (suit - 1)
            var rank_index = (rank - 1)  # A=1, 2=2, ..., K=13

        # **카드 스프라이트의 정확한 열, 행 계산**
            var column = (rank_index % 3) + (suit_index * 3)  # suit마다 그룹 배치
            var row = rank_index / 3  # 행 계산

            var x = 2 + column * (Constants.CARD_WIDTH + 2)
            var y = 2 + row * (Constants.CARD_HEIGHT + 2)

            texture.region = Rect2(x, y, Constants.CARD_WIDTH, Constants.CARD_HEIGHT)
        else:
            texture.region = Rect2(Constants.BACK_UV_X, Constants.BACK_UV_Y, Constants.CARD_WIDTH, Constants.CARD_HEIGHT)
            #get_node("Area2D/CollisionShape2D").set_deferred("disabled", true) #collision 비활성화

    sprite.texture = texture  # 스프라이트에 텍스처 적용



func _ready():
    z_index = 1
    # MoveManager 노드 찾기
    var move_manager_path = "/root/Main/MoveManager"
    if has_node(move_manager_path):
        MoveManager = get_node(move_manager_path)

    # 충돌 영역 자동 설정
    if area and collision_shape:
        var rect_shape = RectangleShape2D.new()
        rect_shape.size = Vector2(Constants.CARD_WIDTH, Constants.CARD_HEIGHT)
        collision_shape.shape = rect_shape  # 카드 크기로 설정
        collision_shape.position = Vector2.ZERO
        area.input_pickable = true  # 입력 감지 활성화
        area.connect("input_event", Callable(self, "_on_card_clicked"))
    else:
        print("Check CollisionShape2D/Area")

    if border:
        border.size = Vector2(Constants.CARD_WIDTH + Constants.BORDER_PADDING, Constants.CARD_HEIGHT + Constants.BORDER_PADDING)
        border.color = Color.GREEN
        border.position = -border.size / 2  # 위치 보정
        border.modulate.a = 0.5     #투명도 설정
        border.visible = false      # 기본적으로 숨김
    else:
        print("Check ColorRect")
    add_to_group("Cards")

signal clicked  # MoveManager에 보낼 신호 추가

func _on_card_clicked(_viewport, event, _shape_idx):
    if event is InputEventMouseButton and event.pressed:
        clicked.emit(self)  # MoveManager에 자신을 알림


var is_foundation = false  # 기본적으로 일반 카드 (파운데이션 아님)

func set_foundation(flag: bool):
    is_foundation = flag
