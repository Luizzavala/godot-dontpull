extends Node

##
# Pruebas unitarias para las reglas básicas de GameManager.
##

func run_tests() -> Array:
    return [
        _test_basic_block_push(),
    ]

func _test_basic_block_push() -> Dictionary:
    var manager := GameManager.new()
    manager.setup_level(Vector2i(5, 5), TileMap.new(), null)
    var player := Player.new()
    var block := Block.new()
    block.configure(manager, Vector2i(1, 0))
    manager.register_player(player, Vector2i.ZERO)
    manager.register_block(block, Vector2i(1, 0))
    var result := manager.try_player_move(Vector2i.RIGHT)
    return {
        "name": "GameManager permite empuje básico",
        "passed": result == GameManager.MoveType.PUSH,
    }
