class_name MinigameBase
extends Node2D #TODO: Node2d for transform, so the camera can move over

var difficultyLevel:float
var started:bool = false

	
#TODO: any extra information a game would need? this is just so transition doesn't have to be frame perfect
func Init(difficulty:float):
	difficultyLevel = difficulty
	

#TODO: is there anything else the game needs?
func GameUpdate(delta:float, deltaAnim:float, paused:bool, camera:Camera2D) -> Global.MiniGameUpdateResult:
	assert(true, "GameUpdate Not Overriden in: " + type_string(typeof(self))) #hopefully it gets the subclass name
	return Global.MiniGameUpdateResult.End_Error #hey it came in use
