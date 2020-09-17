extends Node2D

var rotation_helper : Spatial

func _ready():
    rotation_helper = get_parent().get_parent().get_node("RotationHelper")

func _process(_delta):
    rotation = rotation_helper.rotation.y
