## GameHelpers proporciona utilidades comunes para conversiones de grid y búsqueda de nodos.
extends Object
class_name GameHelpers

const Consts = preload("res://scripts/utils/constants.gd")

static var _map_bounds: Rect2i = Rect2i(Vector2i.ZERO, Vector2i(Consts.GRID_WIDTH, Consts.GRID_HEIGHT))
static var _map_offset: Vector2 = Vector2.ZERO

static func grid_to_world(grid_position: Vector2i) -> Vector2:
    """Convierte una posición de grid a coordenadas globales."""
    var tile_size: float = Consts.TILE_SIZE
    var half_tile: Vector2 = Vector2.ONE * (tile_size * 0.5)
    var grid_position_vector: Vector2 = Vector2(grid_position)
    return grid_position_vector * tile_size + half_tile + _map_offset


static func world_to_grid(world_position: Vector2) -> Vector2i:
    """Convierte una posición global a coordenadas del grid."""
    var tile_size: float = Consts.TILE_SIZE
    var half_tile: Vector2 = Vector2.ONE * (tile_size * 0.5)
    var adjusted: Vector2 = world_position - half_tile - _map_offset
    return Vector2i(round(adjusted.x / tile_size), round(adjusted.y / tile_size))


static func find_node_at_position(group_name: StringName, world_position: Vector2) -> Node:
    """Devuelve el primer nodo del grupo indicado que coincida con la posición global proporcionada."""
    var nodes_in_group: Array = get_tree().get_nodes_in_group(group_name)
    for node: Node in nodes_in_group:
        if not node is Node2D:
            continue
        var node_2d: Node2D = node as Node2D
        if node_2d.has_method("occupies_world_position"):
            if node_2d.occupies_world_position(world_position):
                return node_2d
        if node_2d.global_position.distance_to(world_position) < 1.0:
            return node_2d
    return null


static func get_tree() -> SceneTree:
    """Permite acceder al árbol de escenas desde un contexto estático."""
    return Engine.get_main_loop() as SceneTree


static func set_map_bounds(bounds: Rect2i) -> void:
    """Define los límites actuales del grid disponible para el nivel."""
    _map_bounds = bounds


static func get_map_bounds() -> Rect2i:
    """Devuelve el rectángulo de límites configurado para el mapa."""
    return _map_bounds


static func is_within_bounds(grid_position: Vector2i) -> bool:
    """Indica si la posición en grid se encuentra dentro de los límites actuales."""
    return _map_bounds.has_point(grid_position)


static func set_map_offset(offset: Vector2) -> void:
    """Almacena el desplazamiento en píxeles usado para centrar el grid."""
    _map_offset = offset


static func get_map_offset() -> Vector2:
    """Devuelve el desplazamiento actual aplicado al grid en coordenadas mundiales."""
    return _map_offset


static func calculate_center_offset(grid_size: Vector2i, viewport_size: Vector2) -> Vector2:
    """Calcula el offset necesario para centrar el mapa dentro del viewport."""
    var grid_pixel_size: Vector2 = Vector2(grid_size) * Consts.TILE_SIZE
    var offset: Vector2 = (viewport_size - grid_pixel_size) * 0.5
    return Vector2(max(offset.x, 0.0), max(offset.y, 0.0))
