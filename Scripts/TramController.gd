extends Node



@export var tram: Node2D
var start_speed:int = 80
const  min_speed:int = 50
const abs_max_speed:int = 150
var max_speed: int = 80:
	set(value):
		max_speed = clamp(value,min_speed,abs_max_speed)
var speed:int
var dist:float = 0

@onready var audio_moving: AudioStreamPlayer = $TramRunning

@export var level: Node2D
var network: Array
var nodes_out: Array[int]
var curr_rail_idx: int
var curr_node_idx:int #this is the node that the tram is heading towards
var curr_rail: Path2D
var follower:PathFollow2D

var update_tram:bool = false

signal track_ended


func init_network()-> void:
	#clear network
	network.clear()
	nodes_out.clear()
	dist = 0
	
	
	#meta data stored as nodepaths not nodes
	var rail_network:Node2D = level.rail_network
	#set current rail to the starting rail of the level(rail network)
	curr_rail_idx = rail_network.get_meta('start_rail')
	curr_node_idx = rail_network.get_meta('start_node')
	#populate network with the path nodes
	for node: Array in rail_network.get_meta('Nodes'):
		#assign all nodes the first output track as the ouput (first element reserved for input track)
		nodes_out.append(1)
		var node_rails: Array[Path2D] = [] #the child rails of each path
		for rail:NodePath in node:
			node_rails.append(rail_network.get_node(rail)) #append the path2D
		network.append(node_rails)
	
	curr_rail = network[curr_node_idx][curr_rail_idx]
	follower.reparent(curr_rail)

func find_next_node(_curr_rail:Path2D) -> int:
	#the next node will have the same path as being used but not the 'previous' node
	#this will need expanding on to cover tracks that merge again, ie it wont select the in rail for a node
	for i:int in range(network.size()):
		#loop through nodes
		if i != curr_node_idx and network[i].has(_curr_rail):
			#check its not previous node and cointains the curr rail
			return i
	
	#if no other node is found with the rail then its a dead end
	return -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	follower = PathFollow2D.new()
	add_child(follower)
	speed = start_speed

	#assumes node has a path follower node 

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if update_tram:
		var rail_len:float = curr_rail.curve.get_baked_length()
		if speed == 0:
			audio_moving.stop()
		elif audio_moving.playing == false:
			audio_moving.play()

		#dist along current rail
		dist += speed * delta
		if dist > rail_len:
			#if dist switch to next rail

			if curr_node_idx == -1:
				#if no more nodes, stop tram
				dist = rail_len
				update_tram = false
				#emit signal once frame is done
				track_ended.emit()

			else:
				#will have issues if the next path length < dist - rail_len
				dist = dist - rail_len #preserve the distance it needs to travel to maintain constant speed
				
				curr_rail_idx = nodes_out[curr_node_idx] #get next rail
				curr_rail = network[curr_node_idx][curr_rail_idx] 
				
				rail_len = curr_rail.curve.get_baked_length()
				follower.reparent(curr_rail)
				curr_node_idx = find_next_node(curr_rail)
		
		#update tram position
		if follower.rotation == 0:
			tram.straight()
		elif follower.rotation < 0:
			tram.up()
		elif follower.rotation > 0:
			tram.down()
		follower.progress_ratio = dist/rail_len
		tram.position = follower.position

func toggle_switch() -> void:
	if curr_node_idx != -1:
		$SwitchTrack.play()
		var line_idx:int = nodes_out[curr_node_idx] 
		line_idx += 1
		line_idx = wrap(line_idx,1,3)
		nodes_out[curr_node_idx] = line_idx
		if line_idx == 1:
			level.rail_network.signals[curr_node_idx].up()
		else: 
			level.rail_network.signals[curr_node_idx].down()
		
