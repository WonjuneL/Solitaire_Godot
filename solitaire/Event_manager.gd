extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func _unhandled_input(event):
    if event is InputEventMouseButton and event.pressed:
        var mouse_pos = get_global_mouse_position()  # 현재 마우스 위치 가져오기
        print("마우스 클릭 위치:", mouse_pos)
