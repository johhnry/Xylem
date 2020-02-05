extends KinematicBody

#Player max speed
export(int) var MAX_SPEED = 8
var player_speed = MAX_SPEED

#Amount of earth particles emitted
export(int) var MAX_EARTH_PARTICLES = 20

#Animation tree
var animation_tree

#Mouse input variables
var viewport_center
var min_mouse_distance
var max_mouse_distance

var seed_scene

func _ready():
	var viewport_size = get_viewport().size
	viewport_center = viewport_size / 2
	min_mouse_distance = viewport_center.y / 5
	max_mouse_distance = viewport_center.y
	
	#Get Animation Tree
	animation_tree = $AnimationTree
	
	#seed_scene
	seed_scene = load("res://scenes/botanist/Seed.tscn")


#func _process(delta):
#	pass

func set_walk_speed(speed):
	animation_tree.set("parameters/blend_walk/blend_amount", speed)

func set_run_speed(speed):
	animation_tree.set("parameters/blend_run/blend_amount", speed)

func throw_seed():
	#Playing throw animation
	animation_tree.set("parameters/shot_throw_seed/active", true)
	var s = seed_scene.instance()
	var seed_transform = self.get_transform().translated(Vector3(0, 0.62, 0))
	s.set_transform(seed_transform)
	#Setting seed velocity (direction)
	s.linear_velocity = (get_transform().basis.z * (-player_speed*1.2 - 1)) + Vector3.UP*3
	#Adding the seed to the tree
	get_tree().get_root().add_child(s)

func process_input(delta):
	var mouse_position = get_viewport().get_mouse_position()
	
	var direction = mouse_position - viewport_center
	var distance = direction.length()
	direction = direction.normalized()

	rotation.y = -direction.angle() - PI/2
	
	direction = Vector3(direction.x, 0, direction.y)
	
	var speed = 0
	#If the distance is greater that a certain value, we move
	if distance > min_mouse_distance:
		speed = clamp(distance / max_mouse_distance, 0, 1)
		speed = pow(speed, 2.5)
	
	#Handling walk and run animations
	if speed < 0.5 :
		set_walk_speed(speed)
		set_run_speed(0)
	else:
		set_walk_speed(1)
		set_run_speed(speed)
	
	#Storing the player speed
	player_speed = speed * MAX_SPEED
	
	#Move and slide
	move_and_slide(direction * player_speed)

func _input(event):
	if event.is_action_pressed("throw_seed"):
		throw_seed()

func _physics_process(delta):
	process_input(delta)
	
	#Player input movement vector
#	var input_movement = Vector3.ZERO
#
#	if Input.is_action_pressed("player_left"):
#		input_movement.x -= 1
#	if Input.is_action_pressed("player_right"):
#		input_movement.x += 1
#	if Input.is_action_pressed("player_up"):
#		input_movement.z -= 1
#	if Input.is_action_pressed("player_down"):
#		input_movement.z += 1
#
#	input_movement = input_movement.normalized()
#	input_movement = input_movement.rotated(Vector3.UP, rotation.y)
#
#	move_and_slide(input_movement * MAX_SPEED)
	pass
