extends Camera2D

@export var max_speed: float = 300.0  ## Maximum camera movement speed
@export var offset_from_center: Vector2 = Vector2(0, -50)  ## Camera offset

var _target: Node2D

func _ready() -> void:
	_target = get_parent()
	if _target:
		global_position = _target.global_position + offset_from_center

func _physics_process(delta: float) -> void:
	if not _target:
		return
	
	var target_pos: Vector2 = _target.global_position + offset_from_center
	var distance: Vector2 = target_pos - global_position
	
	# Move toward target, but cap the speed
	if distance.length() > 0:
		var move_distance: float = min(distance.length(), max_speed * delta)
		global_position += distance.normalized() * move_distance
