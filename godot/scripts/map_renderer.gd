class_name MapRenderer
extends Node3D

const LEVEL = [
	[13.5, 2, 1, 4], [13.5, 12, 1, 2], [12.5, 13.5, 3, 1], [2, 13.5, 4, 1],
	[11.5, 15, 1, 2], [11.5, 23.5, 1, 5],
	[10, 26.5, 4, 1], [6, 26.5, 4, 1],
	[2, 34.5, 4, 1], [12.5, 34.5, 3, 1], [13.5, 36, 1, 2], [15, 36.5, 2, 1],
	[13.5, 46, 1, 4],
	[23.5, 36.5, 5, 1], [26.5, 38, 1, 4], [26.5, 42, 1, 4],
	[34.5, 46, 1, 4], [34.5, 36, 1, 2], [35.5, 34.5, 3, 1], [36.5, 33, 1, 2],
	[46, 34.5, 4, 1],
	[36.5, 24.5, 1, 5], [38, 21.5, 4, 1], [42, 21.5, 4, 1],
	[46, 13.5, 4, 1], [35.5, 13.5, 3, 1], [34.5, 12, 1, 2], [33, 11.5, 2, 1],
	[34.5, 2, 1, 4],
	[24.5, 11.5, 5, 1], [21.5, 10, 1, 4], [21.5, 6, 1, 4],
	# center
	[18.5, 22, 1, 6], [19, 18.5, 2, 1], [26, 18.5, 6, 1], [29.5, 19, 1, 2],
	[29.5, 26, 1, 6], [29, 29.5, 2, 1], [22, 29.5, 6, 1], [18.5, 29, 1, 2],
]


func build() -> void:
	_build_ground()
	_build_blocks()
	_build_boundary()


func _build_ground() -> void:
	# Ground plane
	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(48, 48)
	ground_mesh.subdivide_width = 1
	ground_mesh.subdivide_depth = 48

	var ground := MeshInstance3D.new()
	ground.mesh = ground_mesh
	ground.position = Vector3(24, -0.01, 24)

	var ground_mat := StandardMaterial3D.new()
	ground_mat.vertex_color_use_as_albedo = true
	ground_mat.roughness = 0.4
	ground_mat.metallic = 0.05
	ground.material_override = ground_mat

	# Apply vertex colors via shader instead (simpler gradient approach)
	var shader_mat := ShaderMaterial.new()
	shader_mat.shader = _create_ground_shader()
	ground.material_override = shader_mat

	ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(ground)

	# Grid overlay
	var grid_mesh := PlaneMesh.new()
	grid_mesh.size = Vector2(48, 48)
	grid_mesh.subdivide_width = 48
	grid_mesh.subdivide_depth = 48

	var grid := MeshInstance3D.new()
	grid.mesh = grid_mesh
	grid.position = Vector3(24, 0.01, 24)

	var grid_mat := StandardMaterial3D.new()
	grid_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	grid_mat.albedo_color = Color(0.267, 0.533, 0.8, 0.12)
	grid_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	grid_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	# Wireframe not directly available in Godot materials - we'll use the grid shader
	var grid_shader_mat := ShaderMaterial.new()
	grid_shader_mat.shader = _create_grid_shader()
	grid.material_override = grid_shader_mat
	grid.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(grid)


func _create_ground_shader() -> Shader:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode cull_back;

void fragment() {
	// Gradient from white (#ebe8f0) at north to soft blue (#334d99) at south
	// UV.y goes 0->1 from north to south on a PlaneMesh
	float t = UV.y;
	vec3 north = vec3(0.92, 0.91, 0.94);
	vec3 south = vec3(0.2, 0.30, 0.6);
	ALBEDO = mix(north, south, t);
	ROUGHNESS = 0.4;
	METALLIC = 0.05;
}
"""
	return shader


func _create_grid_shader() -> Shader:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, cull_disabled;

void fragment() {
	// Draw grid lines at 1-unit intervals across 48x48
	vec2 world_uv = UV * 48.0;
	vec2 grid = abs(fract(world_uv - 0.5) - 0.5);
	float line = min(grid.x, grid.y);
	float edge = fwidth(line);
	float alpha = 1.0 - smoothstep(0.0, edge * 1.5, line);
	ALBEDO = vec3(0.267, 0.533, 0.8);
	ALPHA = alpha * 0.12;
}
"""
	return shader


func _build_blocks() -> void:
	var block_mat := StandardMaterial3D.new()
	block_mat.albedo_color = Color(0.133, 0.4, 0.667, 0.85)
	block_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	block_mat.roughness = 0.3
	block_mat.metallic = 0.2

	for block_data in LEVEL:
		var bx: float = block_data[0]
		var by: float = block_data[1]
		var bw: float = block_data[2]
		var bh: float = block_data[3]

		var box := BoxMesh.new()
		box.size = Vector3(bw, 1.2, bh)

		var instance := MeshInstance3D.new()
		instance.mesh = box
		instance.material_override = block_mat
		instance.position = Vector3(bx, 0.6, by)
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		add_child(instance)

		# Wireframe overlay via edges
		var wire_mat := StandardMaterial3D.new()
		wire_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		wire_mat.albedo_color = Color(0.4, 0.733, 1.0, 0.5)
		wire_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

		var wire_box := BoxMesh.new()
		wire_box.size = Vector3(bw + 0.02, 1.22, bh + 0.02)

		var wire := MeshInstance3D.new()
		wire.mesh = wire_box
		wire.material_override = wire_mat
		wire.position = Vector3(bx, 0.6, by)
		wire.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(wire)


func _build_boundary() -> void:
	var thickness := 1.5
	var height := 2.0

	var wall_mat := StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.1, 0.267, 0.533, 0.8)
	wall_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wall_mat.roughness = 0.3
	wall_mat.metallic = 0.3

	var walls := [
		# [posX, posZ, sizeX, sizeZ]
		[24.0, -thickness / 2.0, 48.0 + thickness * 2.0, thickness],  # North
		[24.0, 48.0 + thickness / 2.0, 48.0 + thickness * 2.0, thickness],  # South
		[-thickness / 2.0, 24.0, thickness, 48.0 + thickness * 2.0],  # West
		[48.0 + thickness / 2.0, 24.0, thickness, 48.0 + thickness * 2.0],  # East
	]

	for wall_data in walls:
		var wx: float = wall_data[0]
		var wz: float = wall_data[1]
		var sx: float = wall_data[2]
		var sz: float = wall_data[3]

		var box := BoxMesh.new()
		box.size = Vector3(sx, height, sz)

		var mesh := MeshInstance3D.new()
		mesh.mesh = box
		mesh.material_override = wall_mat
		mesh.position = Vector3(wx, height / 2.0, wz)
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		add_child(mesh)
