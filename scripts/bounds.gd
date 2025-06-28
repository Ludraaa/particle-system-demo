extends Node2D

var restitution = 0.4

#Array containing all bounding boxes of the bounds
var bounds = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Get floor rect
	bounds.append(Rect2(get_node("Floor").position, get_node("Floor").size))
	bounds.append(Rect2(get_node("WallL").position, get_node("WallL").size))
	bounds.append(Rect2(get_node("WallR").position, get_node("WallR").size))

func step():
	# Check every particle for every bound for contact
	for bound in bounds:
		for particle in %Particles.get_children():
			var result = particle_intersects_rect(particle, bound.grow(1))
			if result[0]: #Collision = true
				var diff = particle.position - result[1]
				var dist = diff.length()
				if dist == 0:
					return  # stuck exactly on corner—skip
				if dist < particle.radius:
					var penetration = particle.radius - dist
					var normal = diff / dist
					# 1) move out of penetration
					particle.position += normal * penetration
					# 2) reflect velocity properly
					var v_dot_n = particle.velocity.dot(normal)
					if v_dot_n < 0:
						# reflect & damp
						particle.velocity -= (1 + restitution) * v_dot_n * normal


#Utility function detecting if a particle intersects a rectangle
#Returns an array with a bool for collision/no collision and the closest point
func particle_intersects_rect(particle: Node2D, rect: Rect2):
	var closest_point = Vector2(
		clamp(particle.position.x, rect.position.x, rect.position.x + rect.size.x),
		clamp(particle.position.y, rect.position.y, rect.position.y + rect.size.y)
	)
	return [particle.position.distance_squared_to(closest_point) < particle.radius * particle.radius,
	closest_point
	]

#Get minimum collision time fraction to resolve the first wall collision first
func get_min_time_fraction():
	var min_t = 1.0
	for bound in bounds:
		for particle in %Particles.get_children():
			#Position at time step start
			var start_pos = particle.position
			#Predicted position after full timestep
			var end_pos = particle.pred_position
			var radius = particle.radius
		
			min_t = min(min_t, get_collision_fraction(start_pos, end_pos, bound, radius))
			
	return min_t
		

#Gets the fraction of step time at which the collision actually resolves
func get_collision_fraction(start_pos: Vector2, end_pos: Vector2, rect: Rect2, radius: float) -> float:
	var expanded = rect.grow(radius)
	var dir = end_pos - start_pos
	var t_enter := 0.0
	var t_exit  := 1.0
	var eps     := 1e-8

	for axis in ["x", "y"]:
		var ds      = dir[axis]
		var s       = start_pos[axis]
		var min_e   = expanded.position[axis]
		var max_e   = min_e + expanded.size[axis]

		if abs(ds) < eps:
			if s < min_e or s > max_e:
				return 420
		else:
			var t0 = (min_e - s) / ds
			var t1 = (max_e - s) / ds
			var tmin = min(t0, t1)
			var tmax = max(t0, t1)

			t_enter = max(t_enter, tmin)
			t_exit  = min(t_exit, tmax)
			if t_enter > t_exit:
				return 420

	return t_enter if (t_enter >= 0.0 and t_enter <= 1.0) else -1.0





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
