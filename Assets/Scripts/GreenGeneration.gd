extends Node3D

@export var green_size: Vector2 = Vector2(30, 30) # Size of the green (width, height)
@export var green_height: float = 10.0 # Maximum height variation
@export var noise_scale: float = 0.5 # Scale of the noise
@export var green_texture: Texture2D # Texture for the green
@export var uv_scale: float = 10.0 # UV scaling factor for texture repetition
@export var radius: float = 10.0 # Radius of the circular green
@export var friction: float = 0.0 #Friction of green

var noise: FastNoiseLite

func _ready():
	noise = FastNoiseLite.new()
	noise.seed = randi() # Randomize the seed for different results each time
	var mesh = generate_green_mesh()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh

	# Create a material and assign the texture
	if green_texture:
		var material = StandardMaterial3D.new()
		material.albedo_texture = green_texture
		mesh_instance.material_override = material

	$Floor.add_child(mesh_instance)

	# Add a collider
	var collision_shape = CollisionShape3D.new()
	var concave_shape = ConcavePolygonShape3D.new()
	concave_shape.data = mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] # Use the vertices of the mesh
	collision_shape.shape = concave_shape
	$Floor.add_child(collision_shape)

func generate_green_mesh() -> ArrayMesh:
	var array_mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var center_x = green_size.x / 2.0
	var center_y = green_size.y / 2.0

	for x in range(green_size.x - 1):
		for y in range(green_size.y - 1):
			# Calculate distance from center for each point
			var dist00 = Vector2(x - center_x, y - center_y).length()
			var dist01 = Vector2(x - center_x, y + 1 - center_y).length()
			var dist10 = Vector2(x + 1 - center_x, y - center_y).length()
			var dist11 = Vector2(x + 1 - center_x, y + 1 - center_y).length()
			
			# Skip vertices outside the circle
			if dist00 > radius and dist01 > radius and dist10 > radius and dist11 > radius:
				continue
				
			# Generate noise values
			var raw_height00 = noise.get_noise_2d(x * noise_scale, y * noise_scale)
			var raw_height01 = noise.get_noise_2d(x * noise_scale, (y + 1) * noise_scale)
			var raw_height10 = noise.get_noise_2d((x + 1) * noise_scale, y * noise_scale)
			var raw_height11 = noise.get_noise_2d((x + 1) * noise_scale, (y + 1) * noise_scale)

			# Apply thresholding for plateaus
			var height00 = apply_plateau(raw_height00) * green_height
			var height01 = apply_plateau(raw_height01) * green_height
			var height10 = apply_plateau(raw_height10) * green_height
			var height11 = apply_plateau(raw_height11) * green_height
			
			# Create the vertices
			var v0 = create_vertex(x, height00, y, center_x, center_y, radius)
			var v1 = create_vertex(x, height01, y + 1, center_x, center_y, radius)
			var v2 = create_vertex(x + 1, height10, y, center_x, center_y, radius)
			var v3 = create_vertex(x + 1, height11, y + 1, center_x, center_y, radius)

			# UV coordinates for texture mapping
			var uv0 = Vector2(x / green_size.x * uv_scale, y / green_size.y * uv_scale)
			var uv1 = Vector2(x / green_size.x * uv_scale, (y + 1) / green_size.y * uv_scale)
			var uv2 = Vector2((x + 1) / green_size.x * uv_scale, y / green_size.y * uv_scale)
			var uv3 = Vector2((x + 1) / green_size.x * uv_scale, (y + 1) / green_size.y * uv_scale)

			# First triangle
			surface_tool.set_uv(uv0)
			surface_tool.add_vertex(v0)
			surface_tool.set_uv(uv2)
			surface_tool.add_vertex(v2)
			surface_tool.set_uv(uv1)
			surface_tool.add_vertex(v1)

			# Second triangle
			surface_tool.set_uv(uv1)
			surface_tool.add_vertex(v1)
			surface_tool.set_uv(uv2)
			surface_tool.add_vertex(v2)
			surface_tool.set_uv(uv3)
			surface_tool.add_vertex(v3)

	# Automatically generate normals and tangents
	surface_tool.generate_normals()
	surface_tool.generate_tangents()

	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_tool.commit_to_arrays())
	return array_mesh

# Helper function to adjust vertices to form a circular shape
func create_vertex(x: float, height: float, z: float, center_x: float, center_y: float, radiusLoc: float) -> Vector3:
	var dx = x - center_x
	var dz = z - center_y
	var distance = Vector2(dx, dz).length()
	
	# Get direction to the center
	var direction_to_center = Vector2(-dx, -dz).normalized()
	var inner_distance = 0.2 * radiusLoc  # How far to look inward for height reference
	
	if distance > radiusLoc * 0.8:
		# For edge vertices, sample the height from a point closer to the center
		var inner_x = x + direction_to_center.x * inner_distance
		var inner_z = z + direction_to_center.y * inner_distance
		
		# Sample noise at the inner position (simulating what the height would be there)
		var inner_noise = noise.get_noise_2d(inner_x * noise_scale, inner_z * noise_scale)
		var inner_height = apply_plateau(inner_noise) * green_height
		
		# The closer to the edge, the more we use the inner height
		var blend_factor = min(1.0, (distance - radiusLoc * 0.8) / (radiusLoc * 0.2))
		height = lerp(height, inner_height * 0.5, blend_factor)  # Reduce height by 50% for smoother edges
	
	# Now handle the position adjustment
	if distance > radiusLoc * 0.8 and distance < radiusLoc:
		var direction = Vector2(dx, dz).normalized()
		var new_x = center_x + direction.x * radiusLoc
		var new_z = center_y + direction.y * radiusLoc

		# Smooth transition from inside to edge
		var blend_factor = (distance - radiusLoc * 0.8) / (radiusLoc - radiusLoc * 0.8)
		x = lerp(x, new_x, blend_factor)
		z = lerp(z, new_z, blend_factor)
	elif distance >= radiusLoc:
		# Ensure vertices outside the radius are exactly on the circle edge
		var direction = Vector2(dx, dz).normalized()
		x = center_x + direction.x * radiusLoc
		z = center_y + direction.y * radiusLoc

	return Vector3(x, height, z)

# Helper function to create plateaus
func apply_plateau(noise_value: float) -> float:
	# Define thresholds for plateaus
	if noise_value < -0.2:
		return -0.2 # Lower plateau
	elif noise_value > 0.2:
		return 0.2 # Upper plateau
	else:
		return noise_value # Keep slopes in between
