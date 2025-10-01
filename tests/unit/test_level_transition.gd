## TestLevelTransition valida el flujo de transición entre niveles del GameManager.
extends Node

const GameManagerScript = preload("res://scripts/core/GameManager.gd")
const EnemyScript = preload("res://scripts/entities/Enemy.gd")
const Consts = preload("res://scripts/utils/constants.gd")

func run_tests() -> Array:
    """Ejecuta los casos para el sistema de transición de niveles."""
    return [
        _test_queue_next_level_when_enemies_cleared(),
        _test_sequence_wraps_back_to_first_level(),
        _test_start_new_game_resets_level_queue(),
    ]


func _test_queue_next_level_when_enemies_cleared() -> Dictionary:
    var manager: GameManager = GameManagerScript.new()
    manager.start_level("Orchard-01", "level_01.json")
    var enemy_a: Enemy = EnemyScript.new()
    var enemy_b: Enemy = EnemyScript.new()
    manager.register_enemy(enemy_a)
    manager.register_enemy(enemy_b)
    manager.on_enemy_defeated(enemy_a)
    manager.on_enemy_defeated(enemy_b)
    return {
        "name": "GameManager cola el siguiente nivel al derrotar a todos los enemigos",
        "passed": manager.get_queued_level_file() == Consts.LEVEL_SEQUENCE[1],
    }


func _test_sequence_wraps_back_to_first_level() -> Dictionary:
    var manager: GameManager = GameManagerScript.new()
    manager.start_level("Orchard-03", "level_03.json")
    var solo_enemy: Enemy = EnemyScript.new()
    manager.register_enemy(solo_enemy)
    manager.on_enemy_defeated(solo_enemy)
    return {
        "name": "La secuencia vuelve al primer nivel tras el último archivo",
        "passed": manager.get_queued_level_file() == Consts.LEVEL_SEQUENCE[0],
    }


func _test_start_new_game_resets_level_queue() -> Dictionary:
    var manager: GameManager = GameManagerScript.new()
    manager.start_level("Orchard-02", "level_02.json")
    manager.start_new_game()
    return {
        "name": "StartNewGame prepara el primer nivel de la secuencia",
        "passed": manager.get_queued_level_file() == Consts.LEVEL_SEQUENCE[0],
    }
