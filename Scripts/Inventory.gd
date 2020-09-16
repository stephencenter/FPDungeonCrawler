extends Control

const INVENTORY_NUM_ROWS = 3
const INVENTORY_NUM_COLUMNS = 27

var inventory_slots : Array
var cursor : Node2D
var point_helper : Sprite
var current_slot_index = null

func _ready():
    cursor = get_parent().get_node("Cursor")
    point_helper = $PointHelper
    
    for slot in $ItemSlots.get_children():
        inventory_slots.append([slot, null])
        
    if inventory_slots.size() != INVENTORY_NUM_ROWS*INVENTORY_NUM_COLUMNS:
        push_error("NUM_ROWS and NUM_COLUMNS do not match inventory size!")

func _process(_delta):
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

func get_current_slot() -> Array:
    return inventory_slots[current_slot_index]
    
func move_cursor_to_itemslot():
    if current_slot_index != null:
        cursor.cursor_position = get_current_slot()[0].global_position
    
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
        
