extends Node

##
# Pruebas unitarias simples para validar la FSM del jugador.
##

class MockManager:
    extends GameManager
    var responses: Array = []

    func try_player_move(direction: Vector2i) -> MoveType:
        if responses.is_empty():
            return MoveType.NONE
        return responses.pop_front()

    func grid_to_world(cell: Vector2i) -> Vector2:
        return Vector2(cell) * TILE_SIZE

func run_tests() -> Array:
    return [
        _test_walk_transition(),
        _test_push_transition(),
    ]

func _test_walk_transition() -> Dictionary:
    var manager := MockManager.new()
    manager.responses = [GameManager.MoveType.WALK]
    var player := Player.new()
    player.configure(manager, Vector2i.ZERO)
    player._attempt_move(Vector2i.RIGHT)
    return {
        "name": "Player cambia a MOVE al caminar",
        "passed": player.state == Player.State.MOVE,
    }

func _test_push_transition() -> Dictionary:
    var manager := MockManager.new()
    manager.responses = [GameManager.MoveType.PUSH]
    var player := Player.new()
    player.configure(manager, Vector2i.ZERO)
    player._attempt_move(Vector2i.RIGHT)
    return {
        "name": "Player cambia a PUSH al empujar",
        "passed": player.state == Player.State.PUSH,
    }
