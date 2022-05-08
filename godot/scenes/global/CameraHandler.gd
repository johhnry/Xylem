extends Spatial

var follow
var default_basis
var initial_location

func _ready():
	#Getting the botanist
	follow = get_parent()
	
	default_basis = Basis(Vector3.RIGHT, Vector3.UP, Vector3.BACK)
	initial_location = get_global_transform().origin
	print(initial_location)

func _process(delta):
	#Getting the origin point of the target
	var follow_origin = follow.get_global_transform().origin
	
	#Creating the new transform with world basis (no rotation)
	var new_transform = Transform(default_basis, follow_origin)
	
	#Apply the transform to the camera
	set_global_transform(new_transform)
