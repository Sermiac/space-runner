extends Control

func _ready() -> void:
	self.visible = false
	if OS.get_name().to_lower() == "android":
		self.visible = true

func _on_left_button_down() -> void:
	Input.action_press("left")
func _on_left_button_up() -> void:
	Input.action_release("left")

func _on_right_button_down() -> void:
	Input.action_press("right")
func _on_right_button_up() -> void:
	Input.action_release("right")

func _on_jump_button_down() -> void:
	Input.action_press("jump")
func _on_jump_button_up() -> void:
	Input.action_release("jump")
