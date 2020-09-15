extends Control

const INVENTORY_NUM_ROWS = 3
const INVENTORY_NUM_COLUMNS = 27

var inventory_slots : Array
var cursor : Node2D
var point_helper : Sprite
var player : KinematicBody

var current_slot_index = null

func _ready():
    inventory_slots = $ItemSlots.get_children()
    cursor = get_parent().get_node("Cursor")
    point_helper = $PointHelper
    player = get_tree().get_root().get_node("Player")

func _process(delta):
    if are_ui_directions_pressed():
        action_cycle_item_slots()
        
    if cursor.are_cursor_keys_pressed():
        current_slot_index = null
        
    move_cursor_to_itemslot()
    
func are_ui_directions_pressed():
    return Input.is_action_just_pressed("ui_up") or \
           Input.is_action_just_pressed("ui_down") or \
           Input.is_action_just_pressed("ui_left") or \
           Input.is_action_just_pressed("ui_right")

func are_cursor_keys_pressed() -> bool:
    return Input.is_action_pressed("move_cursor_up") or \
           Input.is_action_pressed("move_cursor_down") or \
           Input.is_action_pressed("move_cursor_left") or \
           Input.is_action_pressed("move_cursor_right")

func get_current_slot() -> Area2D:
    return inventory_slots[current_slot_index]
    
func move_cursor_to_itemslot():
    if current_slot_index != null:
        cursor.cursor_position = get_current_slot().global_position
    
func get_hovered_itemslot() -> Area2D:
    for slot in inventory_slots:
        var size = slot.get_node("CollisionShape2D").shape.extents
        var pos = slot.global_position
        
        var min_x = pos.x - size.x
        var max_x = pos.x + size.x
        var min_y = pos.y - size.y
        var max_y = pos.y + size.y
        
        var cursor_pos = cursor.global_position
        
        if cursor_pos.y > min_y and cursor_pos.y < max_y:
            if cursor_pos.x > min_x and cursor_pos.x < max_x:
                return slot
        
    return null

func action_cycle_item_slots():
    if current_slot_index == null:
        current_slot_index = 0
        return
        
    if Input.is_action_just_pressed("ui_up"):
        if current_slot_index >= INVENTORY_NUM_COLUMNS:
            current_slot_index -= INVENTORY_NUM_COLUMNS
        else:
            var x = INVENTORY_NUM_ROWS - 1
            current_slot_index += INVENTORY_NUM_COLUMNS*x
            
    if Input.is_action_just_pressed("ui_down"):
        var x = INVENTORY_NUM_ROWS - 1
        print("c_index ", current_slot_index)
        print("x ", INVENTORY_NUM_COLUMNS*x)
        if current_slot_index < INVENTORY_NUM_COLUMNS*x:
            current_slot_index += INVENTORY_NUM_COLUMNS
        else:
            current_slot_index = current_slot_index % INVENTORY_NUM_COLUMNS
        
    if Input.is_action_just_pressed("ui_left"):
        if current_slot_index % INVENTORY_NUM_COLUMNS > 0:
            current_slot_index -= 1
        else:
            current_slot_index += INVENTORY_NUM_COLUMNS - 1
        
    if Input.is_action_just_pressed("ui_right"):
        if (current_slot_index + 1) % INVENTORY_NUM_COLUMNS > 0:
            current_slot_index += 1
        else:
            current_slot_index -= INVENTORY_NUM_COLUMNS - 1
        
