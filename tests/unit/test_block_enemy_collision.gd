## TestBlockEnemyCollision valida que los bloques aplasten enemigos correctamente.
extends Node

const BlockScene: PackedScene = preload("res://scenes/entities/Block.tscn")
const EnemyScene: PackedScene = preload("res://scenes/entities/Enemy.tscn")
const Consts = preload("res://scripts/utils/constants.gd")
const Enums = preload("res://scripts/utils/enums.gd")


func run_tests() -> Array:
    """Ejecuta los tests relacionados con colisiones de bloques y enemigos."""
    return [
        _test_block_crushes_enemy(),
    ]


func _test_block_crushes_enemy() -> Dictionary:
    var block: Block = BlockScene.instantiate()
    var enemy: Enemy = EnemyScene.instantiate()
    add_child(block)
    add_child(enemy)
    var start_position: Vector2 = GameHelpers.grid_to_world(Vector2i.ZERO)
    block.global_position = start_position
    block.target_position = start_position
    enemy.global_position = start_position + Vector2(Consts.TILE_SIZE, 0.0)
    enemy.target_position = enemy.global_position
    var slide_started: bool = block.request_slide(Vector2i.RIGHT)
    for _i: int in range(5):
        block._physics_process(Consts.BLOCK_SLIDE_TIME * 0.25)
    var result: Dictionary = {
        "name": "El bloque aplasta al enemigo y queda en estado Static",
        "passed": slide_started
            and enemy.current_state == Enums.EnemyState.DEAD
            and block.current_state == Enums.BlockState.STATIC,
    }
    block.queue_free()
    enemy.queue_free()
    return result
