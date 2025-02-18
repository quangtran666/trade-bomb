extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DOUBLE_JUMP_VELOCITY = -300.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum PlayerState { IDLE, RUN, JUMP, FALL, DOUBLE_JUMP, HIT }
var current_state: PlayerState = PlayerState.IDLE
var can_double_jump: bool = true
var is_hit: bool = false

func _physics_process(delta: float) -> void:
	# Áp dụng gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
	match current_state:
		PlayerState.IDLE:
			handle_idle_state()
		PlayerState.RUN:
			handle_run_state()
		PlayerState.JUMP, PlayerState.DOUBLE_JUMP:
			handle_jump_state()
		PlayerState.FALL:
			handle_fall_state()
		PlayerState.HIT:
			handle_hit_state()
			
	# Cập nhật animation
	update_animation()
	
	# Áp dụng movement
	move_and_slide()
	
func handle_idle_state():
	# Reset double jump khi ở floor
	if is_on_floor():
		can_double_jump = true
		
	# Xử lý nhảy
	if Input.is_action_just_pressed("jump") and is_on_floor():
		change_state(PlayerState.JUMP)
		velocity.y = JUMP_VELOCITY
		
	# Xử lý horizontal movement
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		change_state(PlayerState.RUN)
		
	velocity.x = move_toward(velocity.x, 0, SPEED)			
	
func handle_run_state():
	# Xử lý nhảy during run
	if Input.is_action_just_pressed("jump") and is_on_floor():
		change_state(PlayerState.JUMP)
		velocity.y = JUMP_VELOCITY
		return
		
	# Xử lý horizontal movement
	var direction = Input.get_axis("move_left", "move_right")
	if direction == 0:
		change_state(PlayerState.IDLE)
		
	velocity.x = direction * SPEED
	animated_sprite.flip_h = direction < 0
	
func handle_jump_state():
	# Xử lý double jump
	if Input.is_action_just_pressed("jump") and can_double_jump and current_state == PlayerState.JUMP:
		change_state(PlayerState.DOUBLE_JUMP)
		velocity.y = DOUBLE_JUMP_VELOCITY
		can_double_jump = false
		
	if velocity.y > 0:
		change_state(PlayerState.FALL)
	
	# Xử lý horizontal movement trên không
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
		
func handle_fall_state():
	if is_on_floor():
		change_state(PlayerState.IDLE)
		
	# Xử lý horizontal movement while falling
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
		
func handle_hit_state():
	if not is_hit:
		change_state(PlayerState.IDLE)
		
func change_state(new_state: PlayerState):
	current_state = new_state
	
func update_animation():
	match current_state:			
		PlayerState.IDLE:
			animated_sprite.play("Idle")
		PlayerState.RUN:
			animated_sprite.play("Run")
		PlayerState.JUMP:
			animated_sprite.play("Jump")
		PlayerState.DOUBLE_JUMP:
			animated_sprite.play("Double Jump")
		PlayerState.FALL:
			animated_sprite.play("Fall")
		PlayerState.HIT:
			animated_sprite.play("Hit")

# Hàm xử lý khi player nhận sát thương
func take_hit():
	is_hit = true
	change_state(PlayerState.HIT)
	# Thêm hit logic ở đây (chẳng hạn như invincibility frames)
	await get_tree().create_timer(0.5).timeout
	is_hit = false
