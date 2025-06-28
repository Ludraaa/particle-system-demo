extends Button
var showArrows = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_toggled(toggled_on: bool) -> void:
	for particle in %Particles.get_children():
		showArrows = toggled_on
		particle.showArrows = showArrows
		particle.queue_redraw()
	if toggled_on:
		text = "Hide arrows"
	else:
		text = "Show arrows"
