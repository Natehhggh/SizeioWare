extends Node

#thinking the theme 

enum state{
	gamePick, 				#Select Random Game to play TODO: does this split for bosses?
	gameTransitionIn,		#Wait some time before starting, Play some animation probably
	gamePlaying,			#Call into selected game until finished
	gameTransitionOut,		#Wait for some transition out effect shrink the player if they lose
	gameTransitionLoss,		#Players health reached 0, do some loss animation
	gameLost,				#return to menu or something, I dunno
}
var stateStrs:Array = [
	"Pick",
	"TransIn",
	"playGame",
	"TransOut",
	"TransLoss",
	"GameOver"
]


#TODO: remove values
var gamesList:Array = [1,1,1,1,1]



var gameState_State: state = state.gamePick
var gameState_GlobalPause: bool = false
var gameState_PlayerTookDamage: bool = false
var gameState_PlayerHealth: int = 4
var gameState_PlayerScore:int = 0
var gameState_SelectedGame

@onready var healthlbl:Label = %lbl_health_val
@onready var timerlbl:Label = %lbl_timer_val
@onready var statelbl:Label = %lbl_gamestate_val
@onready var Player:Node2D = %Player

#TODO: Temp solution this could work, but it would be nice if the transition state gets to decide
	   #any replacement would need the ability to also speed up any transition effects to match keep in mind
var gameState_transitionTimer:float = 0.0
#TODO: this would need to scale with player score, probably sample a difficulty curve, 
var timerReset:float = 3.0 
var difficultyLevel:float = 1.0
var shrinkTime:float = 1.0
var shrinkTimer:float = 0.0

#load all games in minigame directory
func _ready() -> void:
	var dir = DirAccess.open("res://MinigameScenes/")
	dir.list_dir_begin()
	for file: String in dir.get_files():
		var resource:Resource = load(dir.get_current_dir() + file)
		gamesList.append(resource)

func _process(delta: float) -> void:
	
	
	if(Input.is_action_just_pressed("Pause")):
		gameState_GlobalPause = !gameState_GlobalPause
		#TODO: test with a physics based game, would be cool if it works
				#otherwise look for other ways godot can pause physics
				#pause menus that can still play animations are nice
		#Engine.physics_ticks_per_second = 60 * int(gameState_GlobalPause)
	
	
	#TODO: decide if this stays, dunno if this pattern will work well in godot or not
	var animDelta:float = delta
	delta *= int(!gameState_GlobalPause)
	
	#TODO: formula or sample graph for difficulty curve
	difficultyLevel = 1.0
	
	healthlbl.text = str(gameState_PlayerHealth)
	timerlbl.text = str("%0.1f" % gameState_transitionTimer, "s")
	statelbl.text = stateStrs[gameState_State]
	
	#TODO: give complex states functions to help with [readability | skill issues], jk :)
	match (gameState_State):
		state.gamePick:
			gameState_SelectedGame = gamesList.pick_random()
			gameState_State = state.gameTransitionIn
			gameState_transitionTimer = (timerReset * difficultyLevel)
#			gameState_SelectedGame.load()
		state.gameTransitionIn:
			gameState_transitionTimer -= delta
			if(gameState_transitionTimer <= 0.0):
				gameState_State = state.gamePlaying
		state.gamePlaying:
			#clear on play state so every other state gets a chance to see player got hit?
			gameState_PlayerTookDamage = false
			
			
			#TODO: no games,
			#var result:Global.MiniGameUpdateResult =  (TODO-ref).GameUpdate(delta, deltaAnim,gameState_GlobalPause, %Camera2D)
			#pretend we actually played a game and lost
			var result:Global.MiniGameUpdateResult = Global.MiniGameUpdateResult.End_PlayerLose
			
			
			
			if(result == Global.MiniGameUpdateResult.End_PlayerWin):
				gameState_PlayerScore+=1
			if(result == Global.MiniGameUpdateResult.End_PlayerLose):
				gameState_PlayerTookDamage = true
				gameState_PlayerHealth -= 1
				gameState_transitionTimer = (timerReset * difficultyLevel)
				gameState_State = state.gameTransitionOut
				
			if(result == Global.MiniGameUpdateResult.End_Error):
				printerr("fix yo shit")
				gameState_transitionTimer = (timerReset * difficultyLevel)
				gameState_State = state.gameTransitionOut
			
				
		state.gameTransitionOut:
			gameState_transitionTimer -= delta
			if(gameState_PlayerTookDamage):
				shrinkTimer = min(delta + shrinkTimer, shrinkTime)
				#not really how you lerp, but it doesn't look that bad tbh TODO:fix
				Player.scale = Player.scale.lerp(Vector2.ONE / (5 - gameState_PlayerHealth), shrinkTimer)
				
			if(gameState_transitionTimer <= 0.0):
				shrinkTimer = 0.0
				if(gameState_PlayerHealth == 0):
					gameState_State = state.gameTransitionLoss
					gameState_transitionTimer = (timerReset) #This probably doesn't want to scale faster
				else:
					gameState_State = state.gamePick
		state.gameTransitionLoss:
			gameState_transitionTimer -= delta
			if(gameState_transitionTimer <= 0.0):
				gameState_State = state.gameLost
		state.gameLost:
			get_tree().change_scene_to_file('res://scenes/StartMenu.tscn')
