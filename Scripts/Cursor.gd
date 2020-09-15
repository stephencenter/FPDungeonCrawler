extends Node2D

const CURSOR_SPEED : float = 1000.0
var cursor_position : Vector2
var moved_manually : bool = false
var inventory : Control

func _ready():
    inventory = get_parent().get_node("Inventory")
    action_reset_cursor()

func _process(delta):
    if are_cursor_keys_pressed():
        action_move_cursor(delta)
    
    if Input.is_action_just_pressed("reset_cursor"):
        action_reset_cursor()
        
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
