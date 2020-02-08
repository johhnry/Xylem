extends MeshInstance

func _ready():
	#Creating the L-System and adding rules
	var lsystem = LSystem.new("X", deg2rad(20))
	lsystem.add_rule(Rule.new("X", "F-[XFX]+[FFX--FX]"))
	
	lsystem.steps(3)
	mesh = lsystem.generate_mesh(Transform.IDENTITY)
	
	#Animate the tree scale
	animate_scale(randf()+0.5, log(lsystem.size()))

"""
Animate the scale of the tree

@param scale_to final scale of the tree
@param duration the animation duration
@return void
"""
func animate_scale(scale_to: float, duration: float) -> void:
	scale = Vector3.ZERO
	var tween = get_node("Tween")
	tween.interpolate_property(self, "scale",
		Vector3.ZERO, Vector3(scale_to, scale_to, scale_to), duration,
		Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
	tween.start()

class LSystem:
	var state: String
	var rules = []
	var angle
	
	func _init(start: String, angle: float) -> void:
		state = start
		self.angle = angle
	
	func add_rule(rule: Rule) -> void:
		rules.append(rule)
	
	func step() -> String:
		for rule in rules:
			state = state.replace(rule.pattern, rule.replace)
		return state
	
	func steps(n: int) -> String:
		for i in range(n):
			step()
		return state
	
	func compute_vertex(angle: float, radius: float, height: float, transf: Transform) -> Vector3:
		return transf.xform(Vector3(cos(angle) * radius, height, sin(angle) * radius))
	
	func draw_branch(mesh: ArrayMesh, transf: Transform, length: float, radius: Array, colors: Array, sides: int) -> void:
		#Creating the surface tool
		var st: SurfaceTool = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		
		if(sides <= 2):
			sides = 3
		
		var radius_from = radius[0]
		var radius_to = radius[1]
		var color_from = colors[0]
		var color_to = colors[1]
		
		var angle_incr = (PI*2)/sides
		var z_normal_rotation: float = PI - atan((radius_from-radius_to)/length)
		
		for i in range(sides):
			var vert0 = compute_vertex(angle_incr * (i+1), radius_to, length, transf)
			var vert1 = compute_vertex(angle_incr * (i+1), radius_from, 0, transf)
			var vert2 = compute_vertex(angle_incr * i, radius_from, 0, transf)
			var vert3 = compute_vertex(angle_incr * i, radius_to, length, transf)
			
			var y_normal_rotation = (PI - angle_incr/2) - (angle_incr * i)
			var normal: Vector3 = transf.basis.x.rotated(transf.basis.z, z_normal_rotation)
			normal = normal.rotated(transf.basis.y, y_normal_rotation)
			
			#st.add_normal(normal)
			st.add_color(color_to)
			st.add_vertex(vert0)
			
			#st.add_normal(normal)
			st.add_color(color_from)
			st.add_vertex(vert1)
			
			#st.add_normal(normal)
			st.add_color(color_from)
			st.add_vertex(vert2)
			
			#st.add_normal(normal)
			st.add_color(color_to)
			st.add_vertex(vert3)
			
			#Adding indices
			var face_index = i*4
			st.add_index(face_index)
			st.add_index(face_index+1)
			st.add_index(face_index+2)
			
			st.add_index(face_index)
			st.add_index(face_index+2)
			st.add_index(face_index+3)
		
		st.generate_normals()
		st.commit(mesh)
	
	func rotate_transform_basis(transf: Transform, angle: float) -> Transform:
		var new_transform = transf
		var new_basis = new_transform.basis
		new_basis = new_basis.rotated(new_basis.z, angle)
		new_basis = new_basis.rotated(new_basis.y, randf()*PI/2)
		new_basis = new_basis.rotated(new_basis.x, randf()*PI/4) 
		return Transform(new_basis, transf.origin)
	
	func generate_mesh(initial_transform: Transform) -> ArrayMesh:
		#Creating the mesh
		var mesh: ArrayMesh = ArrayMesh.new()
		
		#The stack is storing the transforms
		var stack = [initial_transform]
		var initial_radius = 1
		var radius_decr = 0.8
		var radius_stack = [initial_radius]
		
		#We iterate through the string
		for op in state:
			match(op):
				#Move forward
				"F":
					var tree_depth = radius_stack.back()
					var branch_length = 2.4/tree_depth
					var radius = [0.2/(tree_depth*1.2), 0.2/(tree_depth*1.2+radius_decr)]
					var colors = [Color(1, 0.5/tree_depth, randf()), Color(randf(), 1.0/(tree_depth+radius_decr), 0)]
					draw_branch(mesh, stack.back(), branch_length, radius, colors, 10)
					
					var new_transform = stack.back()
					new_transform = new_transform.translated(Vector3(0, branch_length, 0))
					stack[stack.size()-1] = new_transform
					
					radius_stack[radius_stack.size()-1] = tree_depth + radius_decr
				
				#Rotate on positive direction
				"+":
					stack[stack.size()-1] = rotate_transform_basis(stack.back(), angle)
				
				"-":
					stack[stack.size()-1] = rotate_transform_basis(stack.back(), -angle)
				
				#Save current transform
				"[":
					stack.push_back(Transform(stack.back().basis, stack.back().origin))
					radius_stack.push_back(radius_stack.back())
				
				#Restore the last transform
				"]":
					stack.pop_back()
					radius_stack.pop_back()
		
		return mesh
	
	func size() -> int:
		return state.length()
	
	func depth() -> int:
		var max_depth = 0
		var depth = 0
		for op in state:
			match(op):
				"[":
					depth += 1
					if(depth > max_depth):
						max_depth = depth
				"]":
					depth -= 1
		return max_depth

class Rule:
	var pattern: String setget ,get_pattern
	var replace: String setget ,get_replace
	
	func _init(pattern: String, replace: String) -> void:
		self.pattern = pattern
		self.replace = replace
	
	func get_pattern() -> String:
		return pattern
	
	func get_replace() -> String:
		return replace