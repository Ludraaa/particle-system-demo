extends VBoxContainer

var top

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top = get_parent().get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func step():
	%GravityField.text = String.num(%Gravity.gravity.y, 2)
	%DragField.text = str(%Drag.drag_koeff)
	%SolidRestitution.text = str(%Bounds.restitution)
	%PartRestitution.text = str(%ParticleCollision.restitution)

func _on_pause_button_toggled(toggled_on: bool) -> void:
	%GravityField.editable = toggled_on
	%DragField.editable = toggled_on
	%SolidRestitution.editable = toggled_on
	%PartRestitution.editable = toggled_on

#Edit the forces on submission
func _on_gravity_field_text_submitted(new_text: String) -> void:
	%Gravity.gravity.y = float(new_text)
func _on_drag_field_text_submitted(new_text: String) -> void:
	%Drag.drag_koeff = float(new_text)

#Reset-buttons
func _on_gravity_reset_pressed() -> void:
	%Gravity.gravity.y = float(0.3)
	step()
func _on_drag_reset_pressed() -> void:
	%Drag.drag_koeff = 0.02
	step()

func _on_solid_restitution_text_submitted(new_text: String) -> void:
	%Bounds.restitution = float(new_text)

func _on_part_restitution_text_submitted(new_text: String) -> void:
	%ParticleCollision.restitution = float(new_text)

func _on_s_restitution_reset_pressed() -> void:
	%Bounds.restitution = 0.4
	step()
func _on_part_restitution_reset_pressed() -> void:
	%ParticleCollision.restitution = 0.4
	step()
