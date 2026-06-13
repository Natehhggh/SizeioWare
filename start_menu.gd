extends Control



func _ready() -> void:
	%btn_play.pressed.connect(PlayCallBack)
	%btn_quit.pressed.connect(QuitCallBack)

func PlayCallBack() -> void:
	get_tree().change_scene_to_file('res://scenes/GameMain.tscn')

func QuitCallBack() -> void:
	get_tree().quit()
	
