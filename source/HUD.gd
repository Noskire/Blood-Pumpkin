extends CanvasLayer

func _on_Continue_button_up():
	get_parent().continue_button_up()

func _on_TryAgain_button_up():
	get_parent().try_again_button_up()

func _on_RestartLevel_button_up():
	get_parent().restart_level_button_up()

func _on_RestartAll_button_up():
	get_parent().restart_all_button_up()
