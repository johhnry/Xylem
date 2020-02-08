extends RigidBody

var life
var tree_scene

func _ready():
	life = OS.get_ticks_msec()
	
	tree_scene = load("res://scenes/environment/GeneratedTree.tscn")

func _process(delta):
	if (OS.get_ticks_msec() - life) > 1500:
		var tree = tree_scene.instance()
		var x = get_transform().origin.x
		var z = get_transform().origin.z
		var tree_transform = Transform(get_transform().basis, Vector3(x, 0, z))
		tree.set_transform(tree_transform)
		get_tree().get_root().add_child(tree)
		
		queue_free()
