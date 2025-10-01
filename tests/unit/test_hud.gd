## TestHUD verifica que el HUD actualiza sus elementos visuales y el temporizador.
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
    var registered_hud: HUD
    var high_score_value := 0
    var submitted_initials: Array[String] = []

    func register_hud(hud: HUD) -> void:
        registered_hud = hud

    func get_high_score() -> int:
        return high_score_value

    func submit_final_score(initials: String) -> void:
        submitted_initials.append(initials)


func run_tests() -> Array:
    """Ejecuta los tests asociados al HUD."""
    return [
        await _test_score_and_lives_update_labels(),
        await _test_level_timer_formats_and_stops(),
        await _test_high_score_entry_panel(),
    ]


func _test_score_and_lives_update_labels() -> Dictionary:
    var original_game_manager := GameManager
    var stub := GameManagerStub.new()
    stub.high_score_value = 1200
    GameManager = stub
    add_child(stub)
    var hud: HUD = HUDScene.instantiate()
    add_child(hud)
    await get_tree().process_frame
    stub.score_changed.emit(450)
    stub.lives_changed.emit(2)
    var score_label: Label = hud.get_node("Root/ScoreContainer/ScoreValue")
    var lives_label: Label = hud.get_node("Root/LivesContainer/LivesValue")
    var high_score_label: Label = hud.get_node("Root/HighScoreContainer/HighScoreValue")
    var initial_high_score := high_score_label.text
    stub.high_score_value = 2000
    stub.high_score_changed.emit(2000)
    await get_tree().process_frame
    var result := {
        "name": "HUD refleja las actualizaciones de score, vidas y high score",
        "passed": score_label.text == "450"
            and lives_label.text == "2"
            and stub.registered_hud == hud
            and initial_high_score == "1200"
            and high_score_label.text == "2000",
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


func _test_high_score_entry_panel() -> Dictionary:
    var original_game_manager := GameManager
    var stub := GameManagerStub.new()
    GameManager = stub
    add_child(stub)
    var hud: HUD = HUDScene.instantiate()
    add_child(hud)
    await get_tree().process_frame
    stub.game_over.emit()
    await get_tree().process_frame
    var panel: Panel = hud.get_node("Root/HighScorePanel")
    var line_edit: LineEdit = hud.get_node("Root/HighScorePanel/PanelContainer/VBoxContainer/InitialsInput")
    line_edit.text = "abc"
    line_edit.emit_signal("text_submitted", line_edit.text)
    await get_tree().process_frame
    var result := {
        "name": "HUD muestra panel de high score y envía iniciales",
        "passed": panel.visible and stub.submitted_initials == ["ABC"],
    }
    hud.queue_free()
    stub.queue_free()
    GameManager = original_game_manager
    return result
