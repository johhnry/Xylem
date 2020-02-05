extends StaticBody

var skel
var animation_seed
var animation_speed
var bone_initial_transforms

func _ready():
	#Get the tree skeleton
	skel = $PineTreeArmature
	
	#Randomize tree bones orientation
	randomize_tree_skel()
	
	#Randomize scale
	var random_scale = rand_range(0.8, 2)
	scale = Vector3(clamp(random_scale, 1, 1.2), random_scale, clamp(random_scale, 1, 1.2))
	
	#Randomize rotation
	rotation = Vector3(0, randf() * PI*2, 0)
	
	#Initialize animation parameters
	animation_seed = rand_range(0, 100)
	animation_speed = rand_range(0.1, 2.5)
	
	#Get bones initial transforms
	bone_initial_transforms = []
	for i in range(1,6):
		bone_initial_transforms.append(skel.get_bone_pose(i))

func _process(delta):
	for i in range(1, 6):
		var bone_transform = bone_initial_transforms[i-1]
		var bone_rotation_x = cos(animation_seed + i/10) * PI/50
		var bone_rotation_y = sin(animation_seed + i/10) * PI/50
		bone_transform = bone_transform.rotated(Vector3.RIGHT, bone_rotation_x)
		bone_transform = bone_transform.rotated(Vector3.BACK, bone_rotation_y)
		skel.set_bone_pose(i, bone_transform)
	
	animation_seed += (delta * animation_speed)

#This function randomize bones orientation for diversity
func randomize_tree_skel():
	var bone_base_name = "Tree_"
	
	for i in range(1,6):
		var bone_name = bone_base_name + str(i)
		var bone_id = skel.find_bone(bone_name)
		var bone_transform = skel.get_bone_pose(bone_id)
		
		bone_transform = randomize_transform_axis(bone_transform, PI/10)
		skel.set_bone_pose(bone_id, bone_transform)

#Randomize a transform by rotating it in both axis
func randomize_transform_axis(t, max_rot):
	t = t.rotated(Vector3.RIGHT, rand_range(-max_rot, max_rot))
	t = t.rotated(Vector3.BACK, rand_range(-max_rot, max_rot))
	return t
