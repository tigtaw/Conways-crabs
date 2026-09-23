extends Area2D

const GRID_STEP = 64

# Should probably use something other than RayCast2D. These don't just check one
# point, they find the closest object within the range?
@onready var down: RayCast2D = $Down
@onready var back: RayCast2D = $Left
@onready var front: RayCast2D = $Right
@onready var up: RayCast2D = $Up

@onready var wait_before_checking_neighbors: Timer = $WaitBeforeCheckingNeighbors
@onready var wait_before_moving: Timer = $WaitBeforeMoving

var step := Vector2i.RIGHT * GRID_STEP
var direction := rotate_vec2i(step, rotation)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func apply_rules() -> Vector2i:
	# TODO: Do this in two steps so that rule application isn't dependant upon the
	# which crab node runs their code first!
	# TODO: Make this a pure function that returns the rotation instead of applying it
	var neighbors: Array[bool] = [front.is_colliding(), up.is_colliding(),
								down.is_colliding(), back.is_colliding()]
	match neighbors:
		[true, false, false, false]:
			rotate(PI)
		[false, true, false, false]:
			rotate(-PI/2)
		[false, false, true, false]:
			rotate(PI/2)
		[true, false, false, true]:
			# Right and left are blocked, so stop
			return Vector2i.ZERO
		[true, true, false, _]:
			return Vector2i.DOWN * GRID_STEP
		[true, false, true, _]:
			return Vector2i.UP * GRID_STEP
		[true, true, true, true]:
			return Vector2i.ZERO
	return step

func rotate_vec2i(vec: Vector2i, radians: float) -> Vector2i:
	assert(vec.x == 0 or vec.y == 0)
	assert(abs(fmod(radians, PI/2)) < .1)
	return Vector2i(Vector2(vec).rotated(radians))

func _on_timer_timeout() -> void:
	direction = rotate_vec2i(apply_rules(), rotation)
	wait_before_moving.start()
	#print("Timer went. Direction is " + str(direction))
	#global_translate(direction)


func _on_wait_before_moving_timeout() -> void:
	translate(direction)
	wait_before_checking_neighbors.start()
