extends Node

const CARD_SPRITE_SHEET = "res://textures/cards.png"  # 카드 스프라이트 시트 경로
var atlas_texture: AtlasTexture = null  # 카드 텍스처 저장용

# 카드 뒷면 좌표
const BACK_UV_X = 2 + 1 * (Constants.CARD_WIDTH + 2)  # 2번째 행
const BACK_UV_Y = 2 + 4 * (Constants.CARD_HEIGHT + 2)  # 5번째 열

# 카드 뒷면 좌표(검정)
const BACK_K_UV_X = 2 + 11 * (Constants.CARD_WIDTH + 2)  # 2번째 행
const BACK_K_UV_Y = 2 + 4 * (Constants.CARD_HEIGHT + 2)  # 5번째 열

# 조커
const JOKER_UV_X = 2 + 2 * (Constants.CARD_WIDTH + 2)  # 3번째 행
const JOKER_UV_Y = 2 + 4 * (Constants.CARD_HEIGHT + 2)  # 5번째 열

func _ready():
    atlas_texture = load(CARD_SPRITE_SHEET)  # 스프라이트 시트 로드

# 카드의 UV 좌표 계산
func get_card_uv(rank_index: int, suit_index: int) -> Vector2:
    var column = (rank_index % 3) + (suit_index * 3)  # suit마다 그룹 배치
    var row = rank_index / 3  # 행 계산
    return Vector2(2 + column * (Constants.CARD_WIDTH + 2),
                   2 + row * (Constants.CARD_HEIGHT + 2))

# 특정 카드의 스프라이트 설정
func set_card_texture(sprite: Sprite2D, card_number: int):
    var uv_pos = Vector2()  # UV 좌표

    if card_number == 0:  # 빈 스택
        uv_pos = Vector2(BACK_K_UV_X, BACK_K_UV_Y)
    elif card_number == -1:  # 덱 카드
        uv_pos = Vector2(BACK_UV_X, BACK_UV_Y)
    elif card_number == -2:  # 파운데이션 위치
        uv_pos = Vector2(JOKER_UV_X, JOKER_UV_Y)
    else:  # 일반 카드
        var rank_index = (card_number - 1) % 13  # 0~12 (A~K)
        var suit_index = (card_number - 1) / 13  # 0~3 (하트, 클로버, 다이아, 스페이드)
        uv_pos = get_card_uv(rank_index, suit_index)

    # 텍스처 설정
    var texture = AtlasTexture.new()
    texture.atlas = atlas_texture
    texture.region = Rect2(uv_pos.x, uv_pos.y, Constants.CARD_WIDTH, Constants.CARD_HEIGHT)

    sprite.texture = texture  # 스프라이트에 적용
