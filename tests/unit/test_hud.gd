## TestHUD verifica que el HUD actualiza sus elementos visuales y el temporizador.
extends Node

const HUDScene: PackedScene = preload("res://scenes/core/HUD.tscn")

class GameManagerStub:
    extends Node
    signal score_changed(new_score: int)
    signal lives_changed(new_lives: int)
    signal level_started(level_name: String)
    signal game_over()
    var registered_hud: HUD

    func register_hud(hud: HUD) -> void:
        registered_hud = hud


func run_tests() -> Array:
    """Ejecuta los tests asociados al HUD."""
    return [
        await _test_score_and_lives_update_labels(),
        await _test_level_timer_formats_and_stops(),
    ]


func _test_score_and_lives_update_labels() -> Dictionary:
    var original_game_manager := GameManager
    var stub := GameManagerStub.new()
    GameManager = stub
    add_child(stub)
    var hud: HUD = HUDScene.instantiate()
    add_child(hud)
    await get_tree().process_frame
    stub.score_changed.emit(450)
    stub.lives_changed.emit(2)
    var score_label: Label = hud.get_node("Root/ScoreContainer/ScoreValue")
    var lives_label: Label = hud.get_node("Root/LivesContainer/LivesValue")
    var result := {
        "name": "HUD refleja las actualizaciones de score y vidas",
        "passed": score_label.text == "450" and lives_label.text == "2" and stub.registered_hud == hud,
    }
    hud.queue_free()
    stub.queue_free()
    GameManager = original_game_manager
    return result


func _test_level_timer_formats_and_stops() -> Dictionary:
    var original_game_manager := GameManager
    var stub := GameManagerStub.new()
    GameManager = stub
    add_child(stub)
    var hud: HUD = HUDScene.instantiate()
    add_child(hud)
    await get_tree().process_frame
    var level_label: Label = hud.get_node("Root/LevelValue")
    var timer_label: Label = hud.get_node("Root/TimerLabel")
    var initial_timer_text := timer_label.text
    stub.level_started.emit("Nivel 1")
    hud._process(65.2)
    var running_timer_text := timer_label.text
    var running_level_name := level_label.text
    stub.game_over.emit()
    hud._process(1.0)
    var stopped_timer_text := timer_label.text
    var result := {
        "name": "HUD reinicia el temporizador por nivel y lo detiene en Game Over",
        "passed": initial_timer_text == "00:00"
            and running_level_name == "Nivel 1"
            and running_timer_text == "01:05"
            and stopped_timer_text == "01:05",
    }
    hud.queue_free()
    stub.queue_free()
    GameManager = original_game_manager
    return result
