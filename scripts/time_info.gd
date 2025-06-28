extends Label

var top

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#gets the node "2d"
	top = get_parent().get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = "Elapsed Time: " + String.num(top.elapsed_time, 2) + \
	"\n#Timestep: " + str(top.elapsed_steps) + \
	"\nMaxTimeStep: " + str(top.max_time_step) + \
	"\nLastTimeStep: " + str(top.time_step) + \
	"\nFPS: " + String.num(Engine.get_frames_per_second(), 2) + \
	"\n#Particles: " + str(top.particle_count)
	
