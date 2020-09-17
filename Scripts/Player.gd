extends KinematicBody

# Constants
const PLAYER_GRAVITY : float = -100.0
const PLAYER_MAX_SPEED : float = 15.0
const PLAYER_TURN_SPEED : float = 100.0
const PLAYER_ACCELERATION : float = 10.0
const PLAYER_MAX_SLOPE : float = 40.0
const PLAYER_MAX_LOOKANGLE : float = 50.0
const PLAYER_DEF_LOOKANGLE : float = -10.0
const PLAYER_JUMP_FORCE : float = 30.0
const PLAYER_GRAB_DISTANCE : float = 20.0
const PLAYER_THROW_FORCE : float = 10.0

# Variables
var current_velocity : Vector3
var held_object : RigidBody

# Nodes
var camera : Camera
var rotation_helper : Spatial
var cursor : Node2D
var inventory : Area2D

# Update Methods
func _ready():
    rotation_helper = $RotationHelper
    camera = $RotationHelper/Camera
    cursor = $HUD/Cursor
    inventory = $HUD/Inventory
    
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    
func _physics_process(delta):
    var movement_info = process_input(delta)
    process_movement(delta, movement_info[0])
    process_camera(delta, movement_info[1])
    
func process_input(delta) -> Array:
    var walk_vector : Vector3
    var turn_vector : Vector2
        
    if are_walk_keys_pressed():
        walk_vector = action_walk_around()
    
    if are_turn_keys_pressed():
        turn_vector = action_turn_camera()
        
    if Input.is_action_just_pressed("jump"):
        action_jump()
        
    if Input.is_action_just_pressed("interact"):
        determine_interaction()
        
    if are_cursor_keys_pressed():
        action_move_cursor(delta)
    
    if Input.is_action_just_pressed("reset_cursor"):
        cursor.reset_cursor_position()
        
    return [walk_vector, turn_vector]
    
func process_movement(delta, walk_vector : Vector3):    
    walk_vector.y = 0
    current_velocity.y += delta*PLAYER_GRAVITY
    
    var horizontal_velocity = current_velocity
    horizontal_velocity.y = 0
    
    var target = walk_vector
    target *= PLAYER_MAX_SPEED
    
    if is_grounded():
        current_velocity.y = max(0, current_velocity.y)
        
    horizontal_velocity = horizontal_velocity.linear_interpolate(target, PLAYER_ACCELERATION*delta)
    current_velocity.x = horizontal_velocity.x
    current_velocity.z = horizontal_velocity.z
    current_velocity = move_and_slide(current_velocity, Vector3(0, 1, 0), 0.05, 4, deg2rad(PLAYER_MAX_SLOPE))
 
func process_camera(delta, turn_vector : Vector2):
    rotation_helper.rotation_degrees.y -= turn_vector.y*delta
    rotation_helper.rotation_degrees.x += turn_vector.x*delta
    
    rotation_helper.rotation_degrees.x = clamp(
        rotation_helper.rotation_degrees.x, 
        -PLAYER_MAX_LOOKANGLE, 
        PLAYER_MAX_LOOKANGLE
    )
    
    if Input.is_action_pressed("glance_down"):
        return
    
    if abs(rotation_helper.rotation_degrees.x - PLAYER_DEF_LOOKANGLE) < PLAYER_TURN_SPEED*delta:
        rotation_helper.rotation_degrees.x = PLAYER_DEF_LOOKANGLE
        
    else:
        if rotation_helper.rotation_degrees.x > PLAYER_DEF_LOOKANGLE:
            rotation_helper.rotation_degrees.x -= PLAYER_TURN_SPEED*delta
        else:
            rotation_helper.rotation_degrees.x += PLAYER_TURN_SPEED*delta
           
# Helper Methods
func are_walk_keys_pressed() -> bool:
    return Input.is_action_pressed("walk_forward") or \
           Input.is_action_pressed("walk_backward") or \
           Input.is_action_pressed("strafe_left") or \
           Input.is_action_pressed("strafe_right")

func are_turn_keys_pressed() -> bool:            
    return Input.is_action_pressed("turn_left") or \
           Input.is_action_pressed("turn_right") or \
           Input.is_action_pressed("glance_up") or \
           Input.is_action_pressed("glance_down")
        
func are_cursor_keys_pressed() -> bool:
    return Input.is_action_pressed("move_cursor_up") or \
           Input.is_action_pressed("move_cursor_down") or \
           Input.is_action_pressed("move_cursor_left") or \
           Input.is_action_pressed("move_cursor_right")

func is_grounded() -> bool:
    var ray = $Feet/RayCast
    return ray.is_colliding() or is_on_floor()
    
func determine_interaction():
    # This method uses the game state to determine which action to perform
    # when the interact button/key is pressed
    if !inventory.is_hovering_inventory():
        if held_object != null:
            action_throw_object()
        else:
            action_grab_object()
            
        return
    
    var slot_index = inventory.get_hovered_itemslot()
    if slot_index != null:
        action_manipulate_inventory(slot_index)
        return

func clear_held_object():
    held_object = null
    cursor.get_node("HeldSprite").texture = null
    
func set_held_object(object : RigidBody):
    held_object = object
    cursor.get_node("HeldSprite").texture = object.get_node("Sprite3D").texture
    
# Action methods
func action_walk_around() -> Vector3:
    var walk_vector = Vector3()
        
    var cam_xform = camera.get_global_transform()
    var input_walk_vector = Vector2()
    
    if Input.is_action_pressed("walk_forward"):
        input_walk_vector.y += Input.get_action_strength("walk_forward")
        
    if Input.is_action_pressed("walk_backward"):
        input_walk_vector.y -= Input.get_action_strength("walk_backward")
        
    if Input.is_action_pressed("strafe_left"):
        input_walk_vector.x -= Input.get_action_strength("strafe_left")
        
    if Input.is_action_pressed("strafe_right"):
        input_walk_vector.x += Input.get_action_strength("strafe_right")
 
    walk_vector += -cam_xform.basis.z * input_walk_vector.y
    walk_vector += cam_xform.basis.x * input_walk_vector.x
    
    return walk_vector
       
func action_turn_camera() -> Vector2:
    var turn_vector : Vector2 = Vector2(0, 0)
    
    if Input.is_action_pressed("turn_left"):
        turn_vector.y -= Input.get_action_strength("turn_left")*PLAYER_TURN_SPEED
        
    if Input.is_action_pressed("turn_right"):
        turn_vector.y += Input.get_action_strength("turn_right")*PLAYER_TURN_SPEED
        
    if Input.is_action_pressed("glance_down"):
        turn_vector.x -= Input.get_action_strength("glance_down")*PLAYER_TURN_SPEED 
    
    return turn_vector 

func action_jump():
    if is_grounded():
        current_velocity.y = PLAYER_JUMP_FORCE    
    
func action_move_cursor(delta):
    var cursor_vector : Vector2 = Vector2(0, 0)
    
    if Input.is_action_pressed("move_cursor_up"):
        cursor_vector.y -= Input.get_action_strength("move_cursor_up")
        
    if Input.is_action_pressed("move_cursor_down"):
        cursor_vector.y += Input.get_action_strength("move_cursor_down")
        
    if Input.is_action_pressed("move_cursor_left"):
        cursor_vector.x -= Input.get_action_strength("move_cursor_left")
        
    if Input.is_action_pressed("move_cursor_right"):
        cursor_vector.x += Input.get_action_strength("move_cursor_right")
        
    cursor.adjust_cursor_position(cursor_vector, delta)

func action_grab_object():
    var object : RigidBody = cursor.get_object_at_cursor(PLAYER_GRAB_DISTANCE)
    
    if object == null:
        return
    
    set_held_object(object)
    object.visible = false
    object.angular_velocity = Vector3.ZERO
    object.linear_velocity = Vector3.ZERO
    
func action_throw_object():
    var impulse_vec = camera.project_ray_normal(cursor.get_cursor_position()).normalized()
    held_object.global_transform.origin = camera.global_transform.origin    
    held_object.apply_impulse(Vector3(0, 0, 0), impulse_vec*PLAYER_THROW_FORCE)
    
    held_object.visible = true
    clear_held_object()

func action_manipulate_inventory(slot_index : int):
    if held_object != null:
        var old_item = inventory.get_item_in_slot(slot_index)
        inventory.put_item_in_slot(slot_index, held_object)
        
        if old_item != null:
            set_held_object(old_item)
            
        else:
            clear_held_object()
        
    else:
        var item = inventory.get_item_in_slot(slot_index)
        if item != null:
            set_held_object(item)
            inventory.set_slot_empty(slot_index)
