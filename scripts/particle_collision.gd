extends Node2D

#stores collisions to handle next step
var collision_pairs = []

var restitution = 0.4


func step():
	for pair in collision_pairs:
		resolve_collision(pair[0], pair[1])
		correct_overlap(pair[0], pair[1])
		collision_pairs.clear()

#correct positions x times after all movement
#hoping to prevent particles stuck inside each other
func iterative_overlap_correction():
	const PENETRATION_ITERATIONS := 3
	for i in range(PENETRATION_ITERATIONS):
		for j in %Particles.get_children():
			for k in %Particles.get_children():
				if j != k:
					correct_overlap(j, k)


#Resolves the actual collision
func resolve_collision(a, b):
	var normal = (b.position - a.position).normalized()
	var relative_velocity = b.velocity - a.velocity
	var vel_along_normal = relative_velocity.dot(normal)
	
	
	if vel_along_normal > 0:
		return  # Already separating; do nothing

	var m1 = a.mass
	var m2 = b.mass

	var impulse_mag = -(1.0 + restitution) * vel_along_normal / (1.0 / m1 + 1.0 / m2)
	var impulse = normal * impulse_mag

	a.velocity -= impulse / m1
	b.velocity += impulse / m2

#To fix particles stuck in collision without sufficient velocity
func correct_overlap(a, b):
	var delta = b.position - a.position
	var dist = delta.length()
	var min_dist = a.radius + b.radius
	if dist == 0.0:
		delta = Vector2(randf(), randf()).normalized()
		dist = 0.001

	var penetration = min_dist - dist
	if penetration > 0:
		var percent = 0.8  # tune between 0.5–0.8
		var slop = 0.01
		var correction = delta.normalized() * (percent * (penetration - slop) / 2.0)
		a.position -= correction
		b.position += correction



#Check for collision between every pair of balls and return the smallest time fraction
func get_min_time_fraction():
	var min_t = 1.0
	#Iterate through every pair of particles (not optimized at all)
	for par1 in %Particles.get_children():
		for par2 in %Particles.get_children():
			if par1 != par2:
				var t = get_normalized_time_of_impact(par1, par2)
				if t <= min_t and t < 1:
					min_t = t
					collision_pairs.append([par1, par2])
	return min_t
			

#small epsilon controlling minimum t, to prevent lockups
const EPSILON := 0.001

#Function returning the time of impact fraction between par a and par b (utility)
func get_normalized_time_of_impact(a, b) -> float:
	var rel_pos = b.position - a.position
	var rel_vel = b.velocity - a.velocity
	var r = a.radius + b.radius

	var a_coeff = rel_vel.dot(rel_vel)
	var b_coeff = 2.0 * rel_pos.dot(rel_vel)
	var c_coeff = rel_pos.dot(rel_pos) - r * r

	var discriminant = b_coeff * b_coeff - 4.0 * a_coeff * c_coeff
	if discriminant < 0.0 or a_coeff == 0.0:
		return 1.0  # No collision this frame

	var sqrt_d = sqrt(discriminant)
	var t1 = (-b_coeff - sqrt_d) / (2.0 * a_coeff)
	var t2 = (-b_coeff + sqrt_d) / (2.0 * a_coeff)

	# Return smallest valid t_frac in [0,1]
	if EPSILON <= t1 and t1 <= 1.0:
		return t1
	elif EPSILON <= t2 and t2 <= 1.0:
		return t2
	else:
		return 1.0  # can go full step without collision

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
