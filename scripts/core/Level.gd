## Level configura la escena de juego cargando datos desde JSON y posiciona entidades en el grid.
extends Node2D
class_name Level

const Consts = preload("res://scripts/utils/constants.gd")
const LevelLoader = preload("res://scripts/utils/level_loader.gd")
const EnemyScene: PackedScene = preload("res://scenes/entities/Enemy.tscn")
const BlockScene: PackedScene = preload("res://scenes/entities/Block.tscn")
const PowerUpScene: PackedScene = preload("res://scenes/entities/PowerUp.tscn")
@export var level_file: String = ""
@onready var tile_map: TileMap = %GroundTileMap
@onready var player: Player = %Player
@onready var enemy_container: Node2D = %Enemies
@onready var block_container: Node2D = %Blocks
@onready var power_up_container: Node2D = %PowerUps
@onready var hud: HUD = %HUD
@onready var non_playable_background: ColorRect = %NonPlayableBackground
@onready var playable_area_rect: ColorRect = %PlayableArea
var _current_grid_size: Vector2i = Vector2i(Consts.GRID_WIDTH, Consts.GRID_HEIGHT)

func _ready() -> void:
    """Carga los datos del nivel y posiciona entidades según el layout."""
    _apply_level_data(_load_level_data())
    GameManager.start_level()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        _update_map_layout()

func _load_level_data() -> Dictionary:
    var path: String = level_file if level_file != "" else LevelLoader.get_default_level_path()
    var data: Dictionary = LevelLoader.load_level(path)
    if not data.is_empty():
        return data
    return {
        "grid_size": {"width": Consts.GRID_WIDTH, "height": Consts.GRID_HEIGHT},
        "player": {"start": Consts.PLAYER_START},
        "blocks": [Consts.BLOCK_START],
        "enemies": [Consts.ENEMY_START],
    }

func _apply_level_data(data: Dictionary) -> void:
    var grid_size: Dictionary = _get_dictionary(data, "grid_size")
    var width: int = int(grid_size.get("width", Consts.GRID_WIDTH))
    var height: int = int(grid_size.get("height", Consts.GRID_HEIGHT))
    _current_grid_size = Vector2i(width, height)
    _update_map_layout()
    GameHelpers.set_map_bounds(Rect2i(Vector2i.ZERO, Vector2i(width, height)))
    _populate_tile_map(width, height)
    _position_player(_get_dictionary(data, "player"))
    _spawn_entities(block_container, BlockScene, _get_array(data, "blocks"), Consts.BLOCK_START)
    _spawn_entities(enemy_container, EnemyScene, _get_array(data, "enemies"), Consts.ENEMY_START)
    _spawn_power_ups(_get_array(data, "power_ups"))
    hud.offset = Vector2.ZERO

func _update_map_layout() -> void:
    var viewport_size: Vector2 = get_viewport_rect().size
    var offset: Vector2 = GameHelpers.calculate_center_offset(_current_grid_size, viewport_size)
    GameHelpers.set_map_offset(offset)
    tile_map.position = offset
    if is_instance_valid(non_playable_background):
        non_playable_background.position = Vector2.ZERO
        non_playable_background.size = viewport_size
    if is_instance_valid(playable_area_rect):
        playable_area_rect.position = offset
        playable_area_rect.size = Vector2(_current_grid_size) * Consts.TILE_SIZE

func _populate_tile_map(width: int, height: int) -> void:
    tile_map.clear()
    for x: int in range(width):
        for y: int in range(height):
            tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i.ZERO)

func _position_player(player_data: Dictionary) -> void:
    var start: Vector2i = _extract_position(player_data.get("start", player_data), Consts.PLAYER_START)
    player.global_position = GameHelpers.grid_to_world(start)
    player.target_position = player.global_position

func _spawn_entities(container: Node2D, scene: PackedScene, entries: Array, fallback: Vector2i) -> void:
    _clear_container(container)
    var spawn_entries: Array = entries if not entries.is_empty() else [fallback]
    for entry: Variant in spawn_entries:
        var grid_position: Vector2i = _extract_position(entry, fallback)
        var instance: Node2D = scene.instantiate() as Node2D
        var world_position: Vector2 = GameHelpers.grid_to_world(grid_position)
        instance.global_position = world_position
        container.add_child(instance)
        instance.set("target_position", world_position)

func _spawn_power_ups(entries: Array) -> void:
    _clear_container(power_up_container)
    for entry: Variant in entries:
        var grid_position: Vector2i = _extract_position(entry, Vector2i.ZERO)
        var power_up: PowerUp = PowerUpScene.instantiate() as PowerUp
        if entry is Dictionary:
            var entry_dict: Dictionary = entry
            if entry_dict.has("type"):
                power_up.power_up_type = StringName(entry_dict["type"])
            if entry_dict.has("score"):
                power_up.score_value = int(entry_dict["score"])
        var world_position: Vector2 = GameHelpers.grid_to_world(grid_position)
        power_up.global_position = world_position
        power_up.target_position = world_position
        power_up_container.add_child(power_up)

func _clear_container(container: Node) -> void:
    for child: Node in container.get_children():
        if child is Enemy:
            GameManager.unregister_enemy(child)
        child.queue_free()

func _extract_position(value: Variant, fallback: Vector2i) -> Vector2i:
    if value is Dictionary:
        var value_dict: Dictionary = value
        if value_dict.has("start"):
            return _extract_position(value_dict["start"], fallback)
        if value_dict.has("position"):
            return _extract_position(value_dict["position"], fallback)
    if value is Array:
        var value_array: Array = value
        if value_array.size() >= 2:
            return Vector2i(int(value_array[0]), int(value_array[1]))
    if value is Vector2i:
        return value
    if value is Vector2:
        var value_vector: Vector2 = value
        return Vector2i(int(value_vector.x), int(value_vector.y))
    return fallback

func _get_dictionary(source: Dictionary, key: String) -> Dictionary:
    var value: Variant = source.get(key, {})
    return value if value is Dictionary else {}

func _get_array(source: Dictionary, key: String) -> Array:
    var value: Variant = source.get(key, [])
    return value if value is Array else []
