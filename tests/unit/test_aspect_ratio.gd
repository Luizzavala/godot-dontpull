## TestAspectRatio valida la configuración de resolución y el escalado uniforme del nivel.
extends Node

const Consts = preload("res://scripts/utils/constants.gd")
const GameHelpers = preload("res://scripts/utils/helpers.gd")

func run_tests() -> Array:
    return [
        _test_project_settings_match_constants(),
        _test_zoom_respects_viewport_limits(),
    ]

func _test_project_settings_match_constants() -> Dictionary:
    var base_resolution: Vector2i = Consts.BASE_RESOLUTION
    var width := int(ProjectSettings.get_setting("display/window/size/viewport_width", 0))
    var height := int(ProjectSettings.get_setting("display/window/size/viewport_height", 0))
    var aspect_setting := String(ProjectSettings.get_setting("display/window/stretch/aspect", ""))
    var mode_setting := String(ProjectSettings.get_setting("display/window/stretch/mode", ""))
    var target_ratio := Consts.TARGET_ASPECT_RATIO.x / Consts.TARGET_ASPECT_RATIO.y if Consts.TARGET_ASPECT_RATIO.y != 0.0 else 1.0
    var base_ratio := float(base_resolution.x) / float(base_resolution.y) if base_resolution.y != 0 else 1.0
    var passed := width == base_resolution.x
        and height == base_resolution.y
        and is_equal_approx(base_ratio, target_ratio)
        and aspect_setting == "keep"
        and mode_setting == "2d"
    return {
        "name": "La resolución base y el aspecto coinciden con las constantes del proyecto",
        "passed": passed,
    }

func _test_zoom_respects_viewport_limits() -> Dictionary:
    var grid_size := Vector2i(13, 11)
    var base_resolution := Consts.BASE_RESOLUTION
    var viewport_size := Vector2(base_resolution.x, base_resolution.y) * 2.0
    var zoom := GameHelpers.calculate_zoom_to_fit(grid_size, viewport_size)
    var uniform := is_equal_approx(zoom.x, zoom.y)
    var zoom_value := zoom.x if zoom.x != 0.0 else 1.0
    var scale := 1.0 / zoom_value
    var grid_pixel_size := Vector2(grid_size) * Consts.TILE_SIZE
    var scaled_size := grid_pixel_size * scale
    var fits_width := scaled_size.x <= viewport_size.x + 0.5
    var fits_height := scaled_size.y <= viewport_size.y + 0.5
    return {
        "name": "El cálculo de zoom es uniforme y mantiene el nivel dentro del viewport",
        "passed": uniform and fits_width and fits_height,
    }
