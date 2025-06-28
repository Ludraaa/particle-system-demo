extends Node2D

var history = []

var mass = 1.0
var velocity = Vector2(0, 0)
var acceleration = Vector2(0, 0)
var force_acc = Vector2(0, 0)
var radius = 8.0

var frozen = false
var pred_acceleration = Vector2(0, 0)
var pred_velocity = Vector2(0, 0)
var pred_position = Vector2(0, 0)

#Counts the time steps since the ball was last seen, deleted at 500
var offScreenCount = 0

#Controls visibility of arrows, set by 2d / button
var showArrows = false

#UI handling
var moused = false
var selected = false

#Function predicting velocity to check whether the particle would move too fast
#In such a case, the time step would be adjusted, so that the particle moves just the maximum distance allowed
func step1():
	#Stop update if particle is frozen
	if frozen:
		return
		
	#Update Predicted Values based on force
	pred_acceleration = force_acc / mass
	pred_velocity = velocity + pred_acceleration
	pred_position  = position + pred_velocity
	

#Function that actually moves the particle with respect to a possibly shrunk h
func step2(time_step_ratio):
	#Stop update if particle is frozen
	if frozen:
		return
		
	#Update Values based on force and time step ratio
	acceleration = (force_acc / mass) * time_step_ratio
	velocity += acceleration  * time_step_ratio
	position += velocity *time_step_ratio
	
	#Update history
	update_history()
	#print("PH: " + str(history))
		
	#print("\nAcc: " + str(acceleration))
	#print("Vel: " + str(velocity))
	#print("Pos: " + str(position) + "\nTSR: " + str(time_step_ratio) + "\n")
	
	#Reset forces
	force_acc = Vector2.ZERO
	
	queue_redraw()

func update_history():
	if history[0].size() <= 500:
		history[0].append(acceleration)
		history[1].append(velocity)
		history[2].append(position)
	else:
		history[0].pop_front()
		history[1].pop_front()
		history[2].pop_front()
		history[0].append(acceleration)
		history[1].append(velocity)
		history[2].append(position)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var shape = CircleShape2D.new()
	shape.radius = radius
	%Shape.shape = shape


func _on_draw() -> void:
	#Different color depending on state
	var circle_color = Color.DARK_ORANGE if !moused else Color.DARK_ORANGE.lightened(0.3)
	if selected:
		circle_color = Color.GOLD

	#Draw circle itself
	draw_circle(to_local(global_position), radius, circle_color, true)
	if showArrows:
		#Draw velocity and acceleration
		draw_line(Vector2(0, 0), velocity * 2, Color(0, 0, 1, 0.7), 4)
		draw_line(Vector2(0, 0), acceleration * 20, Color(1, 0, 0, 0.7), 4)


func _on_hitbox_mouse_entered() -> void:
	get_parent().get_parent().mousedOver = self
	queue_redraw()
	print(moused)
	


func _on_hitbox_mouse_exited() -> void:
	get_parent().get_parent().mousedOver = null
	moused = false
	queue_redraw()
