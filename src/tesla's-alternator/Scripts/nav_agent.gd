extends NavigationAgent2D

@onready var target = get_node("../../Player")
var enabled = true

var path_update_timer = randf_range(0.0, 0.49)
const PATH_UPDATE_INTERVAL = 0.5
var movement_speed: float = 40.0  # edit in enemy_manager export

func _ready() -> void:
	velocity_computed.connect(Callable(_on_velocity_computed))

func set_movement_target(movement_target: Vector2):
	set_target_position(movement_target)

func _physics_process(delta):
	if enabled:
		# Recalculate path periodically
		path_update_timer -= delta
		if path_update_timer <= 0:
			path_update_timer = PATH_UPDATE_INTERVAL
			set_target_position(target.global_position)
			
		# Do not query when the map has never synchronized and is empty.
		if NavigationServer2D.map_get_iteration_id(get_navigation_map()) == 0:
			return
		if is_navigation_finished():
			return

		var next_path_position: Vector2 = get_next_path_position()
		var new_velocity: Vector2 = owner.global_position.direction_to(next_path_position) * movement_speed
		if avoidance_enabled:
			set_velocity(new_velocity)
		else:
			_on_velocity_computed(new_velocity)
	else:
		path_update_timer = PATH_UPDATE_INTERVAL

func _on_velocity_computed(safe_velocity: Vector2):
	owner.velocity = safe_velocity
	owner.move_and_slide()
