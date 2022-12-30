extends Node2D

var direction
var speed
var prev_dir
var tail

func _ready():
	speed = 32
	direction = Vector2(1,0)
	prev_dir = Vector2(1,0)
	tail = preload("res://Tail.tscn")
	randomize()

func _process(delta):
	if(Input.is_action_pressed("ui_up")):
		direction = Vector2(0, -1)
	if(Input.is_action_pressed("ui_down")):
		direction = Vector2(0, 1)
	if(Input.is_action_pressed("ui_right")):
		direction = Vector2(1, 0)
	if(Input.is_action_pressed("ui_left")):
		direction = Vector2(-1, 0)
		
func move_snake():
	var head_pos = get_node("Head").position
	get_node("Head").position += direction * speed
	if (prev_dir != direction):
		prev_dir = direction
		for i in range(2, get_child_count()):
			get_child(i).add_direction(head_pos, direction)
	head_pos = get_node("Head").position
	if (head_pos.x < 0 or head_pos.x > get_viewport_rect().size.x):
		get_parent().game_over()
	if (head_pos.y < 0 or head_pos.y > get_viewport_rect().size.y):
		get_parent().game_over()

func _on_MoveTimer_timeout():
	move_snake()


func _on_Head_area_entered(area):
	print(area.name)
	if (area.name == "Snack"):
		var game = get_tree().get_root().get_node("Game")
		game.get_node("Snack").position.x = rand_range(0, game.width)
		game.get_node("Snack").position.y = rand_range(0, game.height)
		add_tail()
		game.get_node("Chomp").play()
	if ("Tail" in area.name):
		get_parent().game_over()
		
func add_tail():
	var newTail = tail.instance()
	var prev_tail = get_child(get_child_count() - 1)
	if (prev_tail.name != "Head"):
		newTail.cur_dir = prev_tail.cur_dir
		for i in range(0, prev_tail.turn_locations.size()):
			newTail.turn_locations.append(prev_tail.turn_locations[i])
			newTail.directions_turned.append(prev_tail.directions_turned[i])
		newTail.position = prev_tail.position - (prev_tail.cur_dir * speed)
	else:
		newTail.cur_dir = direction
		newTail.position = prev_tail.position - (direction * speed)
	call_deferred("add_child", newTail)
	