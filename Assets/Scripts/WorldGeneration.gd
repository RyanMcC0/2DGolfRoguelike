extends Node2D

# Parameters for level generation
const LEVEL_WIDTH = 1000
const HEIGHT_OFFSET = 110
const NOISE_ZOOM = 0.1
const AMPLITUDE = 100
const WATER_LEVEL = 30
const MAX_MAP_HEIGHT = 150

@export var genWorld:bool = false
@export var backgroundTilemap:Node2D
var noise = FastNoiseLite.new()
var heightmap = []

func _ready():
	noise.seed = randi() # Randomize the noise seed # -48441400 for a test default
	if genWorld:
		clear_level()
		generate_level()
		draw_level()
		draw_background()
		#draw_collider()
		genWorld = false

func generate_level() -> void:
	for x in range(LEVEL_WIDTH):
		var height = HEIGHT_OFFSET + int(noise.get_noise_1d(x * NOISE_ZOOM) * AMPLITUDE)
		heightmap.append(height)

func draw_level() -> void:
	var tilemap: TileMapLayer = $LevelForeground  # Reference your TileMap node

	# Draw the terrain
	for x in range(heightmap.size()):
		var surface_y = heightmap[x]
		for y in range(surface_y, MAX_MAP_HEIGHT):
			if y == surface_y:
				# Check neighbors to determine if a slant is needed for the grass
				var left_height = heightmap[x - 1] if x > 0 else surface_y
				var right_height = heightmap[x + 1] if x < heightmap.size() - 1 else surface_y

				if left_height > surface_y:
					# Use a slant tile for upward slope (e.g., top-left slant)
					tilemap.set_cell(Vector2i(x, y), 0, Vector2i(3, 0))  # Replace with your slant tile index
				elif right_height > surface_y:
					# Use a slant tile for downward slope (e.g., top-right slant)
					tilemap.set_cell(Vector2i(x, y), 0, Vector2i(4, 0))  # Replace with your slant tile index
				else:
					# Default top tile (e.g., grass)
					tilemap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
			else:
				# Below surface tiles (e.g., dirt)
				var above_y = y - 1
				if above_y == surface_y:
					# Check neighbors to determine if a slant is needed for the dirt
					var left_height = heightmap[x - 1] if x > 0 else surface_y
					var right_height = heightmap[x + 1] if x < heightmap.size() - 1 else surface_y

					if left_height > surface_y:
						# Use a slant tile for upward slope dirt (e.g., bottom-left slant)
						tilemap.set_cell(Vector2i(x, y), 0, Vector2i(6, 0))  # Replace with your slant tile index
					elif right_height > surface_y:
						# Use a slant tile for downward slope dirt (e.g., bottom-right slant)
						tilemap.set_cell(Vector2i(x, y), 0, Vector2i(5, 0))  # Replace with your slant tile index
					else:
						# Default dirt tile
						tilemap.set_cell(Vector2i(x, y), 0, Vector2i(1, 0))
				else:
					# Default dirt tile
					tilemap.set_cell(Vector2i(x, y), 0, Vector2i(1, 0))

	# Calculate and add water hazard
	for x in range(heightmap.size()):
		for y in range(MAX_MAP_HEIGHT - WATER_LEVEL, MAX_MAP_HEIGHT):
			if tilemap.get_cell_atlas_coords(Vector2(x, y)) != Vector2i(1, 0):
				tilemap.set_cell(Vector2i(x, y), 0, Vector2i(2, 0))  # Adding water level

	# Add slants for water and dirt transitions
	for x in range(heightmap.size()):
		for y in range(MAX_MAP_HEIGHT - WATER_LEVEL, MAX_MAP_HEIGHT):
			var left_tile = tilemap.get_cell_atlas_coords(Vector2i(x - 1, y)) if x > 0 else null
			var right_tile = tilemap.get_cell_atlas_coords(Vector2i(x + 1, y)) if x < heightmap.size() - 1 else null
			var current_tile = tilemap.get_cell_atlas_coords(Vector2i(x, y))

			# Check for dirt-to-water transitions
			if current_tile == Vector2i(1, 0):  # Dirt tile
				if left_tile == Vector2i(2, 0):  # Water on the left
					tilemap.set_cell(Vector2i(x, y), 0, Vector2i(14, 0))  # Replace with your left water slant tile index
				elif right_tile == Vector2i(2, 0):  # Water on the right
					tilemap.set_cell(Vector2i(x, y), 0, Vector2i(15, 0))  # Replace with your right water slant tile index

	# Remove tiles directly above the water level and slanted dirt-to-water tiles
	for x in range(heightmap.size()):
		var water_surface_y = MAX_MAP_HEIGHT - WATER_LEVEL
		var above_tile_coords = Vector2i(x, water_surface_y - 1)
		var tile_state = tilemap.get_cell_atlas_coords(Vector2i(x, water_surface_y))

		if tile_state in [Vector2i(2, 0)]:
			if tilemap.get_cell_atlas_coords(above_tile_coords) != null:
				tilemap.set_cell(above_tile_coords, 0, Vector2i(-1,-1))  # Remove the tile directly above
		elif tile_state in  [Vector2i(14, 0), Vector2i(15, 0)]:
			tilemap.set_cell(Vector2i(x,water_surface_y), 0, Vector2i(1,0))  # Remove the tile directly above
			if tilemap.get_cell_atlas_coords(Vector2i(x,water_surface_y - 1)) == Vector2i(0,0):
				if tilemap.get_cell_atlas_coords(Vector2i(x - 1,water_surface_y)) == Vector2i(1,0):
					tilemap.set_cell(Vector2i(x,water_surface_y - 1), 0, Vector2i(4,0))
				else:
					tilemap.set_cell(Vector2i(x,water_surface_y - 1), 0, Vector2i(3,0))
	
		# Replace solid dirt blocks with dirt connector blocks if a grass block is above
	for x in range(heightmap.size()):
		for y in range(MAX_MAP_HEIGHT - 1):  # Avoid checking out of bounds
			var current_tile = tilemap.get_cell_atlas_coords(Vector2i(x, y))
			var above_tile = tilemap.get_cell_atlas_coords(Vector2i(x, y - 1))
			if current_tile == Vector2i(1, 0) and above_tile == Vector2i(0, 0):  # Replace with your dirt and grass tile indices
				tilemap.set_cell(Vector2i(x, y), 0, Vector2i(9, 0))  # Replace with your dirt connector block index
			if current_tile == Vector2i(1,0) and (above_tile == Vector2i(3,0) or above_tile == Vector2i(4,0)):
				if above_tile == Vector2i(3,0):
					tilemap.set_cell(Vector2i(x, y), 0, Vector2i(19, 0))
				else:
					tilemap.set_cell(Vector2i(x, y), 0, Vector2i(20, 0))
	
	# Add grass detail above solid grass blocks using one of four grass textures
	for x in range(heightmap.size()):
		for y in range(MAX_MAP_HEIGHT):
			var current_tile = tilemap.get_cell_atlas_coords(Vector2i(x, y))
			# Check for solid grass block
			if current_tile == Vector2i(0, 0):
				var above_pos = Vector2i(x, y - 1)
				# Only place grass if the above cell is empty
				if tilemap.get_cell_atlas_coords(above_pos) == null or tilemap.get_cell_atlas_coords(above_pos) == Vector2i(-1, -1):
					# Randomly select one of four grass detail textures (atlas coords: (10,0), (11,0), (12,0), (13,0))
					var grass_variant = randi() % 4
					tilemap.set_cell(above_pos, 0, Vector2i(10 + grass_variant, 0))
	
	# Replace dirt blocks with a water block directly above with a random connective tile (atlas coords: (16,0), (17,0), (18,0))
	for x in range(heightmap.size()):
		for y in range(1, MAX_MAP_HEIGHT):  # Start from y=1 to avoid out-of-bounds above
			var current_tile = tilemap.get_cell_atlas_coords(Vector2i(x, y))
			var above_tile = tilemap.get_cell_atlas_coords(Vector2i(x, y - 1))
			if current_tile == Vector2i(1, 0) and above_tile == Vector2i(2, 0):
				var connective_variant = 16 + (randi() % 3)
				tilemap.set_cell(Vector2i(x, y), 0, Vector2i(connective_variant, 0))

	# Add a hole in the level for the player to spawn
	var holeX = heightmap.size()-20
	draw_prefab_end(Vector2i(holeX,heightmap[holeX] - 16))

func clear_level() -> void:
	var tilemap:TileMapLayer = $LevelForeground  # Reference your TileMap node
	tilemap.clear()
	heightmap.clear()

func draw_prefab_start() -> void:
	pass

func draw_prefab_end(holeLocation:Vector2i) -> void:
	var prefabTilemap:TileMapLayer = $LevelPrefabs
	prefabTilemap.set_cell(holeLocation,0,Vector2i(0,0))

func draw_background() -> void:
	var backgroundLayer = backgroundTilemap.get_child(0) 
	for x in range(LEVEL_WIDTH):
		var ground_y = heightmap[x]
		for y in range(MAX_MAP_HEIGHT):
			var tile_type = 0  # 0 = sky, 1 = underground, 2 = underwater

			if y < ground_y + 1 and y < (MAX_MAP_HEIGHT - WATER_LEVEL):
				tile_type = 0  # Sky			
			else:
				tile_type = 1  # Underground

			# Set background tile based on type
			match tile_type:
				0:
					backgroundLayer.set_cell(Vector2i(x, y), 0, Vector2i(-1, 0))  # Above water background
				1:
					backgroundLayer.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))  # Underground background currently same as underwater
				2:
					backgroundLayer.set_cell(Vector2i(x, y), 0, Vector2i(1, 0))  # Underwater background

func draw_collider() -> void: #Draw collision shape on draw of level
	#Draw collision polygon
	var floorCollider:CollisionPolygon2D = $LevelForeground/StaticBody2D/CollisionPolygon2D
	# Build the floor collider polygon from the heightmap
	var points = []
	# Start from the left bottom
	points.append(Vector2i(0, MAX_MAP_HEIGHT))
	# Go along the surface
	for x in range(heightmap.size()):
		var changeByY = 0
		var changeByX = 0
		var current_height = heightmap[x]
		if x > 0:
			var previous_height = heightmap[x - 1]
			# Lower the height by 1 if there is an increase in gradient
			if current_height < previous_height:
				changeByY += 1
			if current_height > (MAX_MAP_HEIGHT - WATER_LEVEL - 1):
				current_height = MAX_MAP_HEIGHT - WATER_LEVEL + 2
				changeByY = 0
			current_height += changeByY
		points.append(Vector2i(x + changeByX, clamp(current_height, -9999, MAX_MAP_HEIGHT - 1)))
	# End at the right bottom
	points.append(Vector2i(heightmap.size() - 1, MAX_MAP_HEIGHT))
	# Close the polygon
	points.append(Vector2i(0, MAX_MAP_HEIGHT))
	
		 # Scale points to match TileMap cell size if needed
	var cell_size = $LevelForeground.tile_set.tile_size if $LevelForeground.tile_set else Vector2(1, 1)
	for i in range(points.size()):
		points[i] *= cell_size
	
	floorCollider.polygon = points
