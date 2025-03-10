extends Node

const CARD_SPRITE_SHEET = Constants.texture_path  # 카드 스프라이트 시트 경로
var atlas_texture: Texture2D = null  # 카드 텍스처 저장용
var card_sprites = {}

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
    atlas_texture = ResourceManager.get_texture(Constants.texture_path)  # 스프라이트 시트 로드
    if not atlas_texture:
        push_error("Error: Failed to load sprite sheet texture.")

    #클릭 이벤트 처리
    EventManager.connect("card_selected", Callable(self, "_on_card_selected"))


func get_card_sprite(card):
    return card_sprites.get(card, null)

# 카드의 UV 좌표 계산
func get_card_uv(rank_index: int, suit_index: int) -> Vector2:
    var column = (rank_index % 3) + (suit_index * 3)  # suit마다 그룹 배치
    var row = rank_index / 3  # 행 계산
    return Vector2(2 + column * (Constants.CARD_WIDTH + 2), 2 + row * (Constants.CARD_HEIGHT + 2))

# 특정 카드의 스프라이트 설정
func update_sprite(card):
    var uv_pos = Vector2()  # UV 좌표
    var sprite = card_sprites.get(card, null)
    var card_number = card.get_card_number()

    if not sprite:
        sprite = Sprite2D.new()
        card_sprites[card] = sprite
        add_child(sprite)
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

    if card.is_face_up == false:  # 뒷면 처리 (카드가 뒤집혀 있는 경우)
        uv_pos = Vector2(BACK_UV_X, BACK_UV_Y)
    # 텍스처 설정
    var texture = AtlasTexture.new()
    texture.atlas = atlas_texture
    texture.region = Rect2(uv_pos.x, uv_pos.y, Constants.CARD_WIDTH, Constants.CARD_HEIGHT)

    sprite.texture = texture  # 스프라이트에 적용
    update_position(card)

func update_position(card):
    var sprite = card_sprites.get(card, null)
    if sprite:
        sprite.position = card.get_position()

func _on_card_selected(card, status):
    print("selected : ", card.get_card_info())
    print("status : ", status)
    _highlight_card(card, status)

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
