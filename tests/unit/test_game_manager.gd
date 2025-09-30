extends Node

## Pruebas unitarias para validar la API básica del GameManager.
const GameManagerScript = preload("res://scripts/core/GameManager.gd")

func run_tests() -> Array:
    return [
        _test_register_player(),
        _test_add_score_emits_signal(),
    ]


func _test_register_player() -> Dictionary:
    var manager: Node = GameManagerScript.new()
    var player := Player.new()
    manager.register_player(player)
    return {
        "name": "GameManager guarda la referencia del jugador", 
        "passed": manager.get_player() == player,
    }


func _test_add_score_emits_signal() -> Dictionary:
    var manager: Node = GameManagerScript.new()
    var emitted_values: Array = []
    manager.score_changed.connect(func(value: int): emitted_values.append(value))
    manager.add_score(5)
    return {
        "name": "GameManager emite score_changed al sumar puntos",
        "passed": emitted_values == [5],
    }
