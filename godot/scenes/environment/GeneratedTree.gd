extends MeshInstance

var surface_tool

func _ready():
	surface_tool = SurfaceTool.new()
	
	var mat = SpatialMaterial.new()
	mat.albedo_color = Color(1.0, 0.0, 0.0)
	surface_tool.set_material(mat)
	
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	draw_branch(surface_tool, Transform.IDENTITY, 3, [1,0.2], [Color.tomato, Color.blueviolet], 4)
	mesh = surface_tool.commit()
	
	scale = Vector3.ZERO
	
	#Animating scale
	var tween = get_node("Tween")
	tween.interpolate_property(self, "scale",
		Vector3.ZERO, Vector3(1, 1, 1), 2,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT_IN)
	
	tween.start()

func draw_branch(st: SurfaceTool, transf: Transform, length: float, radius: Array, colors: Array, sides: int) -> void:
	if(sides <= 2):
		sides = 3
		
	var quat = Quat(transf.basis)
	var radius_from = radius[0]
	var radius_to = radius[1]
	var color_from = colors[0]
	var color_to = colors[1]
	
	var bottom_vertices = []
	var top_vertices = []
	
	#Creating vertices and rotating them
	for i in range(sides):
		var angle = ((PI*2)/sides) * i
		var bot_vertex = Vector3(cos(angle) * radius_from, 0, sin(angle) * radius_from) + transf.origin
		var top_vertex = Vector3(cos(angle) * radius_to, length, sin(angle) * radius_to) + transf.origin
		bot_vertex = quat.xform(bot_vertex)
		top_vertex = quat.xform(top_vertex)
		bottom_vertices.append(bot_vertex)
		top_vertices.append(top_vertex)
	
	for i in range(sides):
		st.add_color(color_from)
		st.add_vertex(bottom_vertices[i])
		
		st.add_color(color_from)
		st.add_vertex(bottom_vertices[(i+1)%sides])
		
		st.add_color(color_to)
		st.add_vertex(top_vertices[i])
		
		st.add_color(color_to)
		st.add_vertex(top_vertices[(i+1)%sides])
		
		#Adding indices
		var face_index = i*sides
		st.add_index(face_index)
		st.add_index(face_index+1)
		st.add_index(face_index+2)
		
		st.add_index(face_index+3)
		st.add_index(face_index+2)
		st.add_index(face_index+1)
	
	st.generate_normals()
