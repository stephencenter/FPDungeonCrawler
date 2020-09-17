extends Area2D

# Constants
const INVENTORY_NUM_ROWS = 3
const INVENTORY_NUM_COLUMNS = 27

# Variables
var inventory_slots : Array
var current_slot_index = null

# Nodes
var cursor : Node2D
var player : KinematicBody

func _ready():
    cursor = get_parent().get_node("Cursor")
    player = get_parent().get_parent()
    
    for slot in $ItemSlots.get_children():
        inventory_slots.append([slot, null])
        
    if inventory_slots.size() != INVENTORY_NUM_ROWS*INVENTORY_NUM_COLUMNS:
        push_error("NUM_ROWS and NUM_COLUMNS do not match inventory size!")

func _process(_delta):
    if are_ui_directions_pressed():
        action_cycle_item_slots()
        
    if player.are_cursor_keys_pressed():
        current_slot_index = null
    
    move_cursor_to_itemslot()
    
func are_ui_directions_pressed():
    return Input.is_action_just_pressed("ui_up") or \
           Input.is_action_just_pressed("ui_down") or \
           Input.is_action_just_pressed("ui_left") or \
           Input.is_action_just_pressed("ui_right")
    return Input.is_action_pressed("move_cursor_up") or \
           Input.is_action_pressed("move_cursor_down") or \
           Input.is_action_pressed("move_cursor_left") or \
           Input.is_action_pressed("move_cursor_right")

func get_current_slot() -> Array:
    return inventory_slots[current_slot_index]
    
func move_cursor_to_itemslot():
    if current_slot_index != null:
        cursor.set_cursor_position(get_current_slot()[0].global_position)
    
func get_hovered_itemslot():
    # Returns the index of the hovered itemslot,
    # or null if nothing is found
    var slot_counter = 0
    for slot in inventory_slots:
        if cursor.is_cursor_inside_area(slot[0]):
            return slot_counter
        slot_counter += 1        
        
    return null

func is_hovering_inventory():
    return cursor.is_cursor_inside_area(self)
    
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
        
func put_item_in_slot(index : int, item : RigidBody):
    var slot = inventory_slots[index]
    slot[1] = item
    slot[0].get_node("Sprite").texture = item.get_node("Sprite3D").texture
    
func get_item_in_slot(index : int) -> RigidBody:
    return inventory_slots[index][1]
    
func set_slot_empty(index : int):
    var slot = inventory_slots[index]
    slot[1] = null
    slot[0].get_node("Sprite").texture = null
