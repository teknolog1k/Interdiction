extends Control

var player: RigidBody2D
var playerHP: float
var score: int

var HPlabel: Label
var scoreLabel: Label
var HPbar: TextureProgressBar

var lowHealthAlarm: AudioStreamPlayer

@export_category("Base Points")
@export var AIPirateScore: int
@export var hammerheadScore: int


@export_category("Multipliers")
@export var shot: float
@export var headbutted: float


# Called when the node enters the scene tree for the first time.
func _ready():
	HPlabel = get_node("Health Label")
	scoreLabel = get_node("Score Label")
	HPbar = get_node("Panel/Health Bar")
	lowHealthAlarm = get_node("Low Health Alarm")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player == null:
		var playerTree = get_tree().get_nodes_in_group("Player")
		if playerTree.is_empty():
			HPlabel.text = "GAME OVER"
			return
		else:
			player = playerTree[0]
	else:
		playerHP = player.HP
		HPlabel.text = str(roundf(playerHP))
		scoreLabel.text = str(score)
		HPbar.value = playerHP
	if playerHP <= 25:
		lowHealthAlarm.playing = true
	else:
		lowHealthAlarm.playing = false


func somebody_got_got(who_was_it, howd_it_happen):
	var scoreAdd = 0
	match (who_was_it):
		"AI Pirate":
			scoreAdd += AIPirateScore
		"Hammerhead":
			scoreAdd += hammerheadScore
		_:
			scoreAdd += 999999
	match (howd_it_happen):
		"shot":
			scoreAdd = scoreAdd * shot
		"headbutted":
			scoreAdd = scoreAdd * headbutted
		_: 
			scoreAdd = scoreAdd * 1
	score += scoreAdd
