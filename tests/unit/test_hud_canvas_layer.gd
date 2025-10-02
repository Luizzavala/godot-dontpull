## TestHUDCanvasLayer verifica que el HUD se renderiza en un CanvasLayer independiente y mantiene anclajes estables.
extends Node

const HUDScene: PackedScene = preload("res://scenes/core/HUD.tscn")

class GameManagerStub:
    extends Node
    signal score_changed(new_score: int)
    signal lives_changed(new_lives: int)
    signal level_started(level_name: String)
    signal level_cleared(level_name: String)
    signal game_over()
    signal high_score_changed(new_high_score: int)
    var high_score_value := 0

    func register_hud(_hud: HUD) -> void:
        pass

    func get_high_score() -> int:
        return high_score_value

    func submit_final_score(_initials: String) -> void:
        pass


func run_tests() -> Array:
    """Ejecuta los tests que validan la configuración del CanvasLayer del HUD."""
    return [
        await _test_hud_uses_canvas_layer(),
        await _test_hud_layout_anchors(),
    ]


func _test_hud_uses_canvas_layer() -> Dictionary:
    var original_game_manager := GameManager
    var stub := GameManagerStub.new()
    GameManager = stub
    add_child(stub)
    var hud := HUDScene.instantiate() as HUD
    add_child(hud)
    await get_tree().process_frame
    var result := {
        "name": "HUD se instancia como CanvasLayer independiente",
        "passed": hud is CanvasLayer
            and not hud.follow_viewport_enabled
            and not hud.follow_viewport_scale,
    }
    hud.queue_free()
    stub.queue_free()
    GameManager = original_game_manager
    return result


func _test_hud_layout_anchors() -> Dictionary:
    var original_game_manager := GameManager
    var stub := GameManagerStub.new()
    GameManager = stub
    add_child(stub)
    var hud := HUDScene.instantiate() as HUD
    add_child(hud)
    await get_tree().process_frame
    var root_control := hud.get_node("Root") as Control
    var level_label := hud.get_node("Root/LevelValue") as Control
    var high_score_container := hud.get_node("Root/HighScoreContainer") as Control
    var score_container := hud.get_node("Root/ScoreContainer") as Control
    var timer_label := hud.get_node("Root/TimerLabel") as Control
    var lives_container := hud.get_node("Root/LivesContainer") as Control
    var result := {
        "name": "HUD mantiene anclajes relativos al viewport",
        "passed": _is_fullscreen_anchor(root_control)
            and level_label.anchor_left == 0.0
            and level_label.anchor_top == 0.0
            and high_score_container.anchor_left == 0.5
            and high_score_container.anchor_right == 0.5
            and score_container.anchor_left == 1.0
            and score_container.anchor_right == 1.0
            and timer_label.anchor_left == 0.5
            and timer_label.anchor_right == 0.5
            and lives_container.anchor_top == 1.0
            and lives_container.anchor_bottom == 1.0,
    }
    hud.queue_free()
    stub.queue_free()
    GameManager = original_game_manager
    return result


func _is_fullscreen_anchor(control: Control) -> bool:
    return control.anchor_left == 0.0
        and control.anchor_top == 0.0
        and control.anchor_right == 1.0
        and control.anchor_bottom == 1.0
