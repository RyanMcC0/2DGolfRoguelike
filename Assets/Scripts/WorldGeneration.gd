extends Node2D

# Parameters for level generation
const LEVEL_WIDTH = 1000
const HEIGHT_OFFSET = 50
const NOISE_ZOOM = 0.1
const AMPLITUDE = 200


@export var genWorld:bool = false
var noise = FastNoiseLite.new()
var heightmap = []

func _ready():
	noise.seed = randi()  # Randomize the noise seed
	if genWorld:
		clear_level()
		generate_level()
		draw_level()
		apply_post_process()
		genWorld = false

func generate_level() -> void:
	for x in range(LEVEL_WIDTH):
		var height = HEIGHT_OFFSET + int(noise.get_noise_1d(x * NOISE_ZOOM) * AMPLITUDE)
		heightmap.append(height)

func draw_level() -> void:
	var tilemap:TileMapLayer = $LevelForeground    # Reference your TileMap node
	for x in range(heightmap.size()):
		var surface_y = heightmap[x]
		for y in range(surface_y, 100):  # 100 is your max map height in tiles
			if y == surface_y:
				tilemap.set_cell(Vector2i(x, y),0, Vector2i(0, 0))  # Top tile (e.g., grass)
			else:
				tilemap.set_cell(Vector2i(x, y),0, Vector2i(1, 0))  # Below tile (e.g., dirt)

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