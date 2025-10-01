## TestMapCentering valida que el offset calculado centre el grid en el viewport.
extends Node

const GameHelpers = preload("res://scripts/utils/helpers.gd")
const Consts = preload("res://scripts/utils/constants.gd")

func run_tests() -> Array:
    return [
        _test_offset_is_centered_when_viewport_is_larger(),
        _test_offset_is_clamped_when_viewport_is_smaller(),
    ]

func _test_offset_is_centered_when_viewport_is_larger() -> Dictionary:
    var grid_size := Vector2i(5, 4)
    var viewport_size := Vector2(1280, 720)
    var expected := (viewport_size - Vector2(grid_size) * Consts.TILE_SIZE) * 0.5
    var offset := GameHelpers.calculate_center_offset(grid_size, viewport_size)
    return {
        "name": "El offset centra el mapa cuando el viewport es amplio",
        "passed": offset.is_equal_approx(expected),
    }

func _test_offset_is_clamped_when_viewport_is_smaller() -> Dictionary:
    var grid_size := Vector2i(10, 8)
    var viewport_size := Vector2(200, 150)
    var offset := GameHelpers.calculate_center_offset(grid_size, viewport_size)
    return {
        "name": "El offset se ajusta a cero cuando el viewport es menor al mapa",
        "passed": offset == Vector2.ZERO,
    }
