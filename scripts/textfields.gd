extends Control

var top

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top = get_parent().get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func step():
	#get selected object
	var s = top.selected
	if s:
		%PosX.text = String.num(s.position.x, 2)
		%PosY.text = String.num(s.position.y, 2)
		%VelX.text = String.num(s.velocity.x, 2)
		%VelY.text = String.num(s.velocity.y, 2)
		%AccX.text = String.num(s.acceleration.x, 2)
		%AccY.text = String.num(s.acceleration.y, 2)
		%ForceX.text = String.num(s.force_acc.x, 2)
		%ForceY.text = String.num(s.force_acc.y, 2)
		%Mass.text = String.num(s.mass, 1)
		%Radius.text = String.num(s.radius, 1)


func _on_pause_button_toggled(toggled_on: bool) -> void:
	%PosX.editable = toggled_on
	%PosY.editable = toggled_on
	%VelX.editable = toggled_on
	%VelY.editable = toggled_on
	%AccX.editable = toggled_on
	%AccY.editable = toggled_on
	%ForceX.editable = toggled_on
	%ForceY.editable = toggled_on
	%Mass.editable = toggled_on
	%Radius.editable = toggled_on

#Set new input as the value of selected particle
func _on_pos_x_text_submitted(new_text: String) -> void:
	top.selected.position.x = float(new_text)
func _on_vel_x_text_submitted(new_text: String) -> void:
	top.selected.velocity.x = float(new_text)
func _on_acc_x_text_submitted(new_text: String) -> void:
	top.selected.acceleration.x = float(new_text)
func _on_force_x_text_submitted(new_text: String) -> void:
	top.selected.force_acc.x = float(new_text)
func _on_mass_text_submitted(new_text: String) -> void:
	top.selected.mass = float(new_text)
func _on_radius_text_submitted(new_text: String) -> void:
	top.selected.radius = float(new_text)
	top.selected.queue_redraw()
func _on_pos_y_text_submitted(new_text: String) -> void:
	top.selected.position.y = float(new_text)
func _on_vel_y_text_submitted(new_text: String) -> void:
	top.selected.velocity.y = float(new_text)
func _on_acc_y_text_submitted(new_text: String) -> void:
	top.selected.acceleration.y = float(new_text)
func _on_force_y_text_submitted(new_text: String) -> void:
	top.selected.force_acc.x = float(new_text)
