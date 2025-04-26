extends Node2D

# Parameters for level generation
const LEVEL_WIDTH = 1000
const HEIGHT_OFFSET = 110
const NOISE_ZOOM = 0.1
const AMPLITUDE = 200
const WATER_LEVEL = 20
const MAX_MAP_HEIGHT = 150


@export var genWorld:bool = false
var noise = FastNoiseLite.new()
var heightmap = []

func _ready():
	noise.seed = randi()  # Randomize the noise seed # -48441400 for a test default
	if genWorld:
		clear_level()
		generate_level()
		draw_level()
		draw_background()
		apply_post_process()
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
					tilemap.set_cell(Vector2i(x, y), 0, Vector2i(8, 0))  # Replace with your left water slant tile index
				elif right_tile == Vector2i(2, 0):  # Water on the right
					tilemap.set_cell(Vector2i(x, y), 0, Vector2i(7, 0))  # Replace with your right water slant tile index

	# Remove tiles directly above the water level and slanted dirt-to-water tiles
	for x in range(heightmap.size()):
		var water_surface_y = MAX_MAP_HEIGHT - WATER_LEVEL
		var above_tile_coords = Vector2i(x, water_surface_y - 1)
		var tile_state = tilemap.get_cell_atlas_coords(Vector2i(x, water_surface_y))

		if tile_state in [Vector2i(2, 0)]:
			if tilemap.get_cell_atlas_coords(above_tile_coords) != null:
				tilemap.set_cell(above_tile_coords, 0, Vector2i(-1,-1))  # Remove the tile directly above
		elif tile_state in  [Vector2i(7, 0), Vector2i(8, 0)]:
			tilemap.set_cell(Vector2i(x,water_surface_y), 0, Vector2i(1,0))  # Remove the tile directly above
			if tilemap.get_cell_atlas_coords(Vector2i(x,water_surface_y - 1)) == Vector2i(0,0):
				if tilemap.get_cell_atlas_coords(Vector2i(x - 1,water_surface_y)) == Vector2i(1,0):
					tilemap.set_cell(Vector2i(x,water_surface_y - 1), 0, Vector2i(4,0))
				else:
					tilemap.set_cell(Vector2i(x,water_surface_y - 1), 0, Vector2i(3,0))
func clear_level() -> void:
	var tilemap:TileMapLayer = $LevelForeground  # Reference your TileMap node
	tilemap.clear()
	heightmap.clear()

func create_noise_image(width: int, height: int, pixel_scale: float = 0.05) -> Image:
	var img = Image.create(width, height, false, Image.FORMAT_RF)
	for y in range(height):
		for x in range(width):
			var n = noise.get_noise_2d(x * pixel_scale, y * pixel_scale) * 0.5 + 0.5
			img.set_pixel(x, y, Color(n, n, n))
	return img

func apply_post_process() -> void:
	# Render the TileMap to an image and assign it to a child Sprite
	pass

func draw_prefab_start() -> void:
	pass

func draw_prefab_end() -> void:
	pass

func draw_background() -> void:
	pass
