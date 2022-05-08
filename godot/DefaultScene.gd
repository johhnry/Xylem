extends Spatial

var pine_tree = load("res://scenes/environment/GeneratedTree.tscn")

func _ready():
	#instance_trees(10, 10)
	pass

func instance_trees(n: int, area: int) -> void:
	for i in range(n):
		var tree = pine_tree.instance()
		var tree_transform = tree.get_transform()
		tree_transform.origin = Vector3(rand_range(-area, area), 0, rand_range(-area, area))
		tree.set_transform(tree_transform)
		tree.rotation.y = rand_range(0, PI*2)
		add_child(tree)
