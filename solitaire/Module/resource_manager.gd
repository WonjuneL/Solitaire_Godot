extends Node

## 캐시 저장소
var textures := {}

## 텍스처 가져오기 (이미 로드된 경우 캐시 사용)
func get_texture(path: String) -> Texture2D:
    if textures.has(path):
        return textures[path]  # 캐싱된 텍스처 반환

    var texture = load(path) as Texture2D
    if texture:
        textures[path] = texture  # 캐시에 저장
        return texture
    else:
        push_error("Fail to load : " + path)
        return null

## 텍스처 해제 (더 이상 사용하지 않는 경우)
func unload_texture(path: String):
    if textures.has(path):
        textures.erase(path)
