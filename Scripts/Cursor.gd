extends Node2D

const CURSOR_SPEED : float = 1000.0
var moved_manually : bool = false
var player : KinematicBody

func _ready():
    player = get_parent().get_parent()
    reset_cursor_position()
    
func _input(event):
    if event is InputEventMouseMotion:
        if moved_manually:
            moved_manually = false
            return
            
        set_cursor_position(event.position)
        player.get_node("HUD/Inventory").current_slot_index = null
        
    else:
        get_viewport().warp_mouse(get_cursor_position())
        moved_manually = true

func get_cursor_position():
    return global_position
    
func set_cursor_position(new_position : Vector2):
    global_position = new_position
    
func adjust_cursor_position(cursor_vector : Vector2, delta : float):
    var adjustment = cursor_vector*delta*CURSOR_SPEED
    set_cursor_position(get_cursor_position() + adjustment)
    
func reset_cursor_position():
    set_cursor_position(get_viewport().size / 2)

func get_object_at_cursor(max_distance : float, ignored : Array = []) -> RigidBody:
    var state = player.get_world().direct_space_state
    var camera = player.get_node("RotationHelper/Camera")
    var ray_start = camera.project_ray_origin(get_cursor_position())
    var ray_end = ray_start + camera.project_ray_normal(get_cursor_position())*max_distance
    var ray_result = state.intersect_ray(ray_start, ray_end, [self] + ignored)
    
    if !ray_result.empty() and ray_result["collider"] is RigidBody:
        return ray_result["collider"]
        
    return null

func is_cursor_inside_area(area : Area2D) -> bool:
    var size = area.get_node("CollisionShape2D").shape.extents
    var pos = area.global_position
    
    var min_x = pos.x - size.x
    var max_x = pos.x + size.x
    var min_y = pos.y - size.y
    var max_y = pos.y + size.y
    
    var cursor_position = get_cursor_position()
    if cursor_position.y > min_y and cursor_position.y < max_y:
        if cursor_position.x > min_x and cursor_position.x < max_x:
            return true
            
    return false
