## TestBlockDestroy verifica que los bloques puedan destruirse de forma explícita.
extends Node

const BlockScene: PackedScene = preload("res://scenes/entities/Block.tscn")
const Enums = preload("res://scripts/utils/enums.gd")

func run_tests() -> Array:
    """Ejecuta los casos relacionados con la destrucción de bloques."""
    return [
        _test_destroy_marks_block_for_removal(),
    ]


func _test_destroy_marks_block_for_removal() -> Dictionary:
    var block: Block = BlockScene.instantiate()
    add_child(block)
    block.destroy_block()
    var result := {
        "name": "La destrucción del bloque lo marca como eliminado",
        "passed": block.current_state == Enums.BlockState.DESTROYED and block.is_queued_for_deletion(),
    }
    block.queue_free()
    return result
