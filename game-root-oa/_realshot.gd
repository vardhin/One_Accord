extends SceneTree
var frames := 0
var cam: Camera3D
var world
func _init():
	world = load("res://scenes/world.tscn").instantiate()
	get_root().add_child(world)
	cam = Camera3D.new(); cam.far = 2000.0
	get_root().add_child(cam); cam.current = true
func _process(_d):
	frames += 1
	if frames == 4:
		var t = world.get_node("Terrain3D")
		var gh = t.get_data().get_height(Vector3(400,0,400))
		if is_nan(gh): gh = 1.0
		# 1.8m red reference pole at the look point.
		var pole = CSGBox3D.new()
		pole.size = Vector3(0.25, 1.8, 0.25)
		pole.position = Vector3(400, gh + 0.9, 396)
		var m = StandardMaterial3D.new(); m.albedo_color = Color(1,0,0); pole.material = m
		world.add_child(pole)
		cam.look_at_from_position(Vector3(400, gh+1.4, 401), Vector3(400, gh+0.6, 395), Vector3.UP)
	if frames == 90:
		get_root().get_texture().get_image().save_png("res://_real.png")
		print("REAL SHOT SAVED"); quit()
