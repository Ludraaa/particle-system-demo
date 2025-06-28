extends Node2D

var particleScene = preload("res://scenes/2d_particle.tscn")
var mousePos = Vector2.ZERO
#Moused Particle
var mousedOver
#Selected Particle
var selected

#0.0167
var max_time_step = 0.0167
var time_step_history = []

#This will be the actual time step, accounted for very fast particles that need a smaller step
var time_step = max_time_step

#bool for summoning logic and object to store summoned particle to give force on release
var summoning = false
var to_summon

#Stuff for time tracking and ui
var elapsed_time = 0
var elapsed_steps = 0
var particle_count

var viewRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%TimeStepper.start(time_step)
	viewRect = get_viewport().get_visible_rect()
	

func step():
	#Skip computation if no particle exists
	if %Particles.get_child_count() == 0:
		return
	
	#Increment step counter
	elapsed_steps += 1
	
	#Predict velocity of every particle
	for par in %Particles.get_children():
		par.step1()

	#Check for wall collisions to get the smallest time step allowed
	var time_step_ratio_bounds = get_node("Bounds").get_min_time_fraction()
	#Check for particle-particle collisions to get the smallest time step allowed
	var time_step_ratio_particles = %ParticleCollision.get_min_time_fraction()
	
	#Get the minimum of both
	var time_step_ratio = min(time_step_ratio_bounds, time_step_ratio_particles)
	
	#Calculate time step length for display
	time_step = max_time_step * time_step_ratio
	
	
	#Update history
	update_history()
	
	#Actually perform the euler step with safe time step
	for par in %Particles.get_children():
		par.step2(time_step_ratio)
		do_culling(par)
	
	
	#Apply the forces for next frame (this is done after particle update to be able to see the forces when paused)
	get_node("Gravity").step()
	get_node("Drag").step()
	get_node("Bounds").step()
	get_node("ParticleCollision").step()
	
	#try to fix particles stuck inside each other
	get_node("ParticleCollision").iterative_overlap_correction()
	
	#Add elapsed time if the autoTimeStepper is paused
	if %TimeStepper.paused:
		elapsed_time += time_step
		
	#Update the UI panel for the selected particle and forces
	%Textfields.step()
	%ForcesColumn.step()

func do_culling(par):
	#Not in view -> count time steps
	if not viewRect.grow(par.radius * 2).has_point(par.position):
		par.offScreenCount += 1
	#In view -> reset them to 0
	else:
		par.offScreenCount = 0
	if par.offScreenCount > 500:
		if selected == par:
			selected = null
		par.queue_free()


func step_back():
	#Skip computation if no particle exists
	if %Particles.get_child_count() == 0 or elapsed_steps == 0:
		return
	
	elapsed_steps -= 1
	elapsed_time -= time_step_history.pop_back()
	
	for particle in %Particles.get_children():
		#Remove the last entry if it is the current state
		#This is true for the first step back after stepping forward
		for i in range(3):
			if particle.history[2][-1] == particle.position:
				particle.history[i].pop_back()
		
		if particle.history[0].size() == 0:
			particle.queue_free()
			continue
		particle.acceleration = particle.history[0].pop_back()
		particle.velocity = particle.history[1].pop_back()
		particle.global_position = particle.history[2].pop_back()
		
		#Add last position back if history was emptied
		particle.history[0].append(particle.acceleration)
		particle.history[1].append(particle.velocity)
		particle.history[2].append(particle.position)
		
		#Draws the particle anew (important for the arrows)
		particle.queue_redraw()
		#print("PH after step back: " + str(particle.history))
		#Update the UI panel for the selected particle and forces
		%Textfields.step()
		%ForcesColumn.step()
	

func update_history():
	#print("TSH: " + str(time_step_history))
	if time_step_history.size() > 500:
		time_step_history.pop_front()
	time_step_history.append(time_step)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Get mouse pos every frame
	mousePos = get_global_mouse_position()
	
	#Add to elapsed time if the simulation is unpaused
	if !%TimeStepper.paused and !%Particles.get_child_count() == 0:
		elapsed_time += delta 
	
	#get particle num
	particle_count = %Particles.get_child_count()
	
	#Draw the connecting line when a particle is being summoned
	queue_redraw()


#Input handling
func _unhandled_input(event: InputEvent) -> void:
	#Check for unhandled clicks to summon particle
	if event.is_action_pressed("lmb") and !summoning:
		if !mousedOver:
			summoning = true
			var particle = particleScene.instantiate()
			particle.position = mousePos
			particle.frozen = true
			get_node("Particles").add_child(particle)
			to_summon = particle
		else:
			selected = mousedOver
			#Clear selection from every particle
			for par in %Particles.get_children():
				par.selected = false
			#Set the only right one to be selected
			selected.selected = true
			#Redraw every particle
			for par in %Particles.get_children():
				par.queue_redraw()
			#Refresh Panel
			%Textfields.step()
		
	#Check for unhandled click releases and let the particle go
	if event.is_action_released("lmb") and summoning:
		to_summon.frozen = false
		summoning = false
		to_summon.velocity += Vector2(to_summon.position - mousePos)
		#Add spawn point to history entries
		to_summon.history.append([to_summon.acceleration])
		to_summon.history.append([to_summon.velocity])
		to_summon.history.append([to_summon.position])
		to_summon.showArrows = %VelAccArrowButton.showArrows
		#Selection handling
		selected = to_summon
		for par in %Particles.get_children():
				par.selected = false
				par.queue_redraw()
		to_summon.selected = true
		to_summon.queue_redraw()
		#Refresh panel
		%Textfields.step()
		
	if event.is_action_pressed("rmb") and summoning:
		to_summon.queue_free()
		summoning = false
	
	if event.is_action_pressed("rmb") and !summoning:
		if mousedOver:
			mousedOver.queue_free()
			if selected == mousedOver:
				selected.queue_free()
				selected = null
			mousedOver = null
	
	#Trigger buttons via key presses
	if event.is_action_pressed("arrows"):
		%VelAccArrowButton.button_pressed = !%VelAccArrowButton.button_pressed
	if event.is_action_pressed("pause"):
		%PauseButton.button_pressed = !%PauseButton.button_pressed
	if event.is_action_pressed("step"):
		%StepForwardButton.emit_signal("pressed")
	if event.is_action_pressed("step_back"):
		%StepBackButton.emit_signal("pressed")
	if event.is_action_pressed("quit"):
		%Leave.emit_signal("pressed")

func _draw() -> void:
	if summoning:
		draw_line(to_summon.position, mousePos, Color.CYAN)

func _on_time_stepper_timeout() -> void:
	step()
	%TimeStepper.start(time_step)

func _on_pause_button_toggled(toggled_on: bool) -> void:
	%TimeStepper.paused = toggled_on

func _on_step_forward_button_pressed() -> void:
	if %TimeStepper.paused:
		step()


func _on_step_back_button_pressed() -> void:
	if %TimeStepper.paused:
		step_back()

#Back to start screen logic
func _on_leave_pressed() -> void:
	get_parent().get_node("StartScreen").show()
	queue_free()
