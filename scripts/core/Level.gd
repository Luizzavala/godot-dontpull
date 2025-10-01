## Level configura la escena de juego cargando datos desde JSON y posiciona entidades en el grid.
extends Node2D
class_name Level

const Consts = preload("res://scripts/utils/constants.gd")
const GameHelpers = preload("res://scripts/utils/helpers.gd")
const LevelLoader = preload("res://scripts/utils/level_loader.gd")
const EnemyScene: PackedScene = preload("res://scenes/entities/Enemy.tscn")
const BlockScene: PackedScene = preload("res://scenes/entities/Block.tscn")
@export var level_file: String = ""
@onready var tile_map: TileMap = %GroundTileMap
@onready var player: Player = %Player
@onready var enemy_container: Node2D = %Enemies
@onready var block_container: Node2D = %Blocks
@onready var hud: HUD = %HUD
func _ready() -> void:
    """Carga los datos del nivel y posiciona entidades según el layout."""
    _apply_level_data(_load_level_data())
    GameManager.start_level()


func _load_level_data() -> Dictionary:
    var path := level_file if level_file != "" else LevelLoader.get_default_level_path()
    var data := LevelLoader.load_level(path)
    if not data.is_empty():
        return data
    return {
        "grid_size": {"width": Consts.GRID_WIDTH, "height": Consts.GRID_HEIGHT},
        "player": {"start": Consts.PLAYER_START},
        "blocks": [Consts.BLOCK_START],
        "enemies": [Consts.ENEMY_START],
    }

func _apply_level_data(data: Dictionary) -> void:
    var grid_size := data.get("grid_size", {})
    var width := int(grid_size.get("width", Consts.GRID_WIDTH))
    var height := int(grid_size.get("height", Consts.GRID_HEIGHT))
    _populate_tile_map(width, height)
    _position_player(data.get("player", {}))
    _spawn_blocks(data.get("blocks", []))
    _spawn_enemies(data.get("enemies", []))
    hud.offset = Vector2.ZERO

func _populate_tile_map(width: int, height: int) -> void:
    tile_map.clear()
    for x in range(width):
        for y in range(height):
            tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i.ZERO)

func _position_player(player_data: Dictionary) -> void:
    var start := _extract_position(player_data.get("start", player_data), Consts.PLAYER_START)
    player.global_position = GameHelpers.grid_to_world(start)
    player.target_position = player.global_position

func _spawn_blocks(positions: Array) -> void:
    _clear_container(block_container)
    if positions.is_empty():
        _spawn_block(Consts.BLOCK_START)
        return
    for entry in positions:
        _spawn_block(_extract_position(entry, Consts.BLOCK_START))

func _spawn_enemies(positions: Array) -> void:
    _clear_container(enemy_container)
    if positions.is_empty():
        _spawn_enemy(Consts.ENEMY_START)
        return
    for entry in positions:
        _spawn_enemy(_extract_position(entry, Consts.ENEMY_START))

func _spawn_block(grid_position: Vector2i) -> void:
    var block_instance: Block = BlockScene.instantiate()
    block_instance.global_position = GameHelpers.grid_to_world(grid_position)
    block_container.add_child(block_instance)
    block_instance.target_position = block_instance.global_position

func _spawn_enemy(grid_position: Vector2i) -> void:
    var enemy_instance: Enemy = EnemyScene.instantiate()
    enemy_instance.global_position = GameHelpers.grid_to_world(grid_position)
    enemy_container.add_child(enemy_instance)
    enemy_instance.target_position = enemy_instance.global_position

func _clear_container(container: Node) -> void:
    for child in container.get_children():
        if child is Enemy:
            GameManager.unregister_enemy(child)
        child.queue_free()

func _extract_position(value, fallback: Vector2i) -> Vector2i:
    if value is Dictionary:
        if value.has("start"):
            return _extract_position(value["start"], fallback)
        if value.has("position"):
            return _extract_position(value["position"], fallback)
    if value is Array and value.size() >= 2:
        return Vector2i(int(value[0]), int(value[1]))
    if value is Vector2i:
        return value
    if value is Vector2:
        return Vector2i(int(value.x), int(value.y))
    return fallback
