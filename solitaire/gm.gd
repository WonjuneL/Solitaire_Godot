extends Node2D

@export var card_scene: PackedScene  # 카드 프리팹
@export var card_front_folder: String = "res://Cards_Asset/Front"  # 카드 이미지 폴더
@export var card_front_textures: Dictionary = {}  # 카드 이름별 텍스처 저장
@export var card_back_texture: Texture  # 공통 뒷면 이미지
@onready var card_container = $CardContainer

var card_positions = []  # 카드가 배치될 좌표 리스트



func _ready():
    load_card_textures()  # 자동 로드 함수 실행

func load_card_textures():
    var suits = ["Spade", "Heart", "Diamond", "Club"]
    var ranks = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

    for suit in suits:
        for rank in ranks:
            var filename = suit + " " + rank + ".png"
            var path = card_front_folder + filename
            var texture = load(path)
            if texture:
                card_front_textures[suit + rank] = texture
            else:
                print("Error: 파일 없음 -> " + path)


# 📌 카드가 배치될 위치들을 생성
func generate_card_positions():
    var start_x = 100  # 첫 카드의 x 좌표
    var start_y = 200  # 첫 카드의 y 좌표
    var spacing_x = 120  # 카드 간격 (가로)
    var spacing_y = 160  # 카드 간격 (세로)

    # 4 x 13 형태로 배치 (예시: 솔리테어 배치)
    for row in range(4):
        for col in range(13):
            var pos = Vector2(start_x + col * spacing_x, start_y + row * spacing_y)
            card_positions.append(pos)

# 📌 카드 인스턴스를 생성하고 배치
func spawn_cards():
    if card_scene == null:
        print("Error: card_scene is not assigned!")
        return

    if card_front_textures.size() < card_positions.size():
        print("Warning: Not enough front textures assigned for the number of cards!")

    var shuffled_textures = card_front_textures.duplicate()
    shuffled_textures.shuffle()  # 앞면 이미지 랜덤 섞기

    for i in range(min(card_positions.size(), shuffled_textures.size())):
        var card_instance = card_scene.instantiate() as Node2D
        card_instance.position = card_positions[i]

        # 카드의 앞면과 뒷면 설정
        card_instance.set_textures(shuffled_textures[i], card_back_texture)

        card_container.add_child(card_instance)

var card_texture = load("res://Cards_Asset/Front/Spade_A.png")
print("카드 로드 상태:", card_texture)
