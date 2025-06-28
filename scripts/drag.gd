extends Node2D

var drag_koeff = 0.02

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func step():
	for par in %Particles.get_children():
		par.force_acc += -drag_koeff * par.velocity
