extends Node2D


@export_category("Enemy Spawn Timing")
@export_group("AI Pirate")
@export var AIPirateMinimumTime: float
@export var AIPirateMaximumTime: float
@export_group("Hammerhead")
@export var hammerheadMinimumTime: float
@export var hammerheadMaximumTime: float

@export_category("Enemy Spawn Location")
@export_group("X Range")
@export var minX: int
@export var maxX: int
@export_group("Y Range")
@export var minY: int
@export var maxY: int


var AIPirateSpawnTimer: Timer
var AIPirateScene: PackedScene
var hammerheadSpawnTimer: Timer
var hammerheadScene: PackedScene

var UIController: Control


# Called when the node enters the scene tree for the first time.
func _ready():
	AIPirateSpawnTimer = get_node("Spawn Timers/AI Pirate Spawn Timer")
	AIPirateScene = preload("res://Scenes/ai_pirate.tscn")
	hammerheadSpawnTimer = get_node("Spawn Timers/Hammerhead Spawn Timer")
	hammerheadScene = preload("res://Scenes/Hammerhead.tscn")
	UIController = get_node("UI Controller")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	pass


func _on_laser_shoot(pew, targetDir, instanceLocation, whoDis):
	var theBoi = pew.instantiate()
	theBoi.rotation = targetDir
	theBoi.position = instanceLocation
	theBoi.IFF = whoDis
	add_child(theBoi)


func _enemy_time():
	var lastSpawned = AIPirateScene.instantiate()
	lastSpawned.position = Vector2(randi_range(minX, maxX), randi_range(minY, maxY))
	add_child(lastSpawned)
	lastSpawned.shoot.connect(_on_laser_shoot)
	lastSpawned.gotGot.connect(Callable(UIController, "somebody_got_got"))
	
	AIPirateSpawnTimer.wait_time = randf_range(AIPirateMinimumTime, AIPirateMaximumTime)
	AIPirateSpawnTimer.start()


func _hammerhead_time():
	var lastSpawned = hammerheadScene.instantiate()
	lastSpawned.position = Vector2(randi_range(minX, maxX), randi_range(minY, maxY))
	add_child(lastSpawned)
	lastSpawned.gotGot.connect(Callable(UIController, "somebody_got_got"))
	
	hammerheadSpawnTimer.wait_time = randf_range(hammerheadMinimumTime, hammerheadMaximumTime)
	hammerheadSpawnTimer.start()


func _ouchie(sparky, where):
	var lastSpark = sparky.instantiate()
	lastSpark.position = where
	add_child(lastSpark)
