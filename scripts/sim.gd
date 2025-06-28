extends Node2D

var simulation = preload("res://scenes/2d.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Quit game logic
func _on_quit_pressed() -> void:
	get_tree().quit()

#Load simulation logic
func _on_start_pressed() -> void:
	%StartScreen.hide()
	var sim = simulation.instantiate()
	add_child(sim)
