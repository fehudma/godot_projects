extends Control



func _on_location_1_button_pressed() -> void:
	print("Location1 button pressed")
	GameData.selected_location = "Location 1"
	print("GameData selected location is: ")
	print(GameData.selected_location)
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_location_2_button_pressed() -> void:
	print("Location2 button pressed")
	GameData.selected_location = "Location 2"
	print("GameData selected location is: ")
	print(GameData.selected_location)
	get_tree().change_scene_to_file("res://scenes/main.tscn")
