extends Node

var scale_factor = 1.0
signal scale_factor_changed(new_scale)

func _ready():
    call_deferred("_update_scale_factor")
    _update_scale_factor()
    get_tree().get_root().connect("size_changed", Callable(self, "_update_scale_factor"))  # 화면 크기 변경 감지

func _update_scale_factor():
    var base_width = 1152.0  # 기준 해상도
    var base_height = 648.0
    var current_width = get_viewport().size.x
    var current_height = get_viewport().size.y
    print("Current viewport size:", current_width, "x", current_height)  # 디버깅용 출력

    var width_ratio = current_width / base_width
    var height_ratio = current_height / base_height
    scale_factor = min(width_ratio, height_ratio)

    print("Updated scale factor:", scale_factor)
    emit_signal("scale_factor_changed", scale_factor)
