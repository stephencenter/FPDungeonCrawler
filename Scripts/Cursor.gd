extends Node2D

const CURSOR_SPEED : float = 1000.0
const GRAB_DISTANCE : float = 20.0
const THROW_FORCE : float = 10.0

var cursor_position : Vector2
var held_object : RigidBody
var held_origscale : Vector3

var moved_manually : bool = false
var inventory : Control
var player : KinematicBody
var camera : Camera
var held_sprite : Sprite

func _ready():
    inventory = get_parent().get_node("Inventory")
    player = get_parent().get_parent()
    camera = player.get_node("RotationHelper/Camera")
    held_sprite = $HeldSprite
    
    action_reset_cursor()

func _process(delta):
    if are_cursor_keys_pressed():
        action_move_cursor(delta)
    
    if Input.is_action_just_pressed("reset_cursor"):
        action_reset_cursor()
        
    if Input.is_action_just_pressed("interact"):
        if held_object != null:
            action_throw_object()
        else:
            action_grab_object()
        
    update_cursor_pos()
    
func _input(event):
    if event is InputEventMouseMotion:
        if moved_manually:
            moved_manually = false
            return
            
        cursor_position = event.position
        inventory.current_slot_index = null
        
    else:
        get_viewport().warp_mouse(cursor_position)
        moved_manually = true

func update_cursor_pos():
    global_position = cursor_position
    
func are_cursor_keys_pressed() -> bool:
    return Input.is_action_pressed("move_cursor_up") or \
           Input.is_action_pressed("move_cursor_down") or \
           Input.is_action_pressed("move_cursor_left") or \
           Input.is_action_pressed("move_cursor_right")

func get_object_at_cursor(max_distance : float, ignored : Array = []) -> RigidBody:
    var state = player.get_world().direct_space_state
    var ray_start = camera.project_ray_origin(cursor_position)
    var ray_end = ray_start + camera.project_ray_normal(cursor_position)*max_distance
    var ray_result = state.intersect_ray(ray_start, ray_end, [self] + ignored)
    
    if !ray_result.empty() and ray_result["collider"] is RigidBody:
        return ray_result["collider"]
        
    return null
  
func action_reset_cursor():
    cursor_position = get_viewport().size / 2
    
func action_move_cursor(delta):
    var cursor_vector : Vector2 = Vector2(0, 0)
    
    if Input.is_action_pressed("move_cursor_up"):
        cursor_vector.y -= Input.get_action_strength("move_cursor_up")*CURSOR_SPEED*delta
        
    if Input.is_action_pressed("move_cursor_down"):
        cursor_vector.y += Input.get_action_strength("move_cursor_down")*CURSOR_SPEED*delta
        
    if Input.is_action_pressed("move_cursor_left"):
        cursor_vector.x -= Input.get_action_strength("move_cursor_left")*CURSOR_SPEED*delta
        
    if Input.is_action_pressed("move_cursor_right"):
        cursor_vector.x += Input.get_action_strength("move_cursor_right")*CURSOR_SPEED*delta
        
    cursor_position += cursor_vector

func action_grab_object():
    var obj : RigidBody = get_object_at_cursor(GRAB_DISTANCE)
    
    if obj == null:
        return
        
    held_object = obj
    held_sprite.texture = obj.get_node("Sprite3D").texture
    
    obj.visible = false

func action_throw_object():
    var impulse_vec = camera.project_ray_normal(cursor_position).normalized()
    held_object.global_transform.origin = camera.global_transform.origin    
    held_object.apply_impulse(Vector3(0, 0, 0), impulse_vec*THROW_FORCE)
    
    held_object.visible = true
    held_object = null
    held_sprite.texture = null
