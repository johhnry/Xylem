extends Spatial

var pine_tree = load("res://scenes/environment/PineTree.tscn")

func _ready():
	instance_trees(20)

func instance_trees(n):
	var area = 10
	for i in range(n):
		var tree = pine_tree.instance()
		var tree_transform = tree.get_transform()
		tree_transform.origin = Vector3(rand_range(-area, area), 0, rand_range(-area, area))
		tree.set_transform(tree_transform)
		add_child(tree)
