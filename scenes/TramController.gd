extends Node

@export var tram: Node2D
var speed:int = 100
var dist:float = 0

@export var level: Node2D
var network: Array
var nodes_out: Array[int]
var curr_rail_idx: int
var curr_node_idx:int #this is the node that the tram is heading towards
var curr_rail: Path2D
var follower:PathFollow2D


func init_network()-> void:
	#meta data stored as nodepaths not nodes
	var rail_network: = level.get_node("RailNetwork")
	#set current rail to the starting rail of the level(rail network)
	curr_rail_idx = rail_network.get_meta('start_rail')
	curr_node_idx = rail_network.get_meta('start_node')
	#populate network with the path nodes
	for node: Array in rail_network.get_meta('Nodes'):
		#assign all nodes the first output track as the ouput (first element reserved for input track)
		nodes_out.append(1)
		var node_rails: Array[Path2D] #the child rails of each path
		for rail:NodePath in node:
			node_rails.append(rail_network.get_node(rail)) #append the path2D
		network.append(node_rails)

func find_next_node(curr_rail:Path2D) -> int:
	#the next node will have the same path as being used but not the 'previous' node
	for i in range(network.size()):
		#loop through nodes
		if i != curr_node_idx and network[i].has(curr_rail):
			#check its not previous node and cointains the curr rail
			return i
	
	#if no other node is found with the rail then its a dead end
	return -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_network()	
	curr_rail = network[curr_node_idx][curr_rail_idx]
	#assumes node has a path follower node 
	#(should maybe have one that gets adopted by the pathnodes as needed?)
	follower = curr_rail.get_node('PathFollow2D')
	speed = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	var rail_len:float = curr_rail.curve.get_baked_length()
	#dist along current rail
	dist += speed * delta
	if dist > rail_len:
		#if dist switch to next rail

		if curr_node_idx == -1:
			#if no more nodes, stop tram
			dist = rail_len
			speed = 0
		else:
			#will have issues if the next path length < dist - rail_len
			dist = dist - rail_len #preserve the distance it needs to travel to maintain constant speed
			
			curr_rail_idx = nodes_out[curr_node_idx] #get next rail
			curr_rail = network[curr_node_idx][curr_rail_idx] 
			
			rail_len = curr_rail.curve.get_baked_length()
			follower = curr_rail.get_node('PathFollow2D')
			curr_node_idx = find_next_node(curr_rail)
	
	#update tram position
	follower.progress_ratio = dist/rail_len
	tram.position = follower.position
	tram.rotation = follower.rotation

func _input(event: InputEvent) -> void:
		if event.is_action_pressed("switch_tracks"):
			nodes_out[curr_node_idx] = 2
		if event.is_action_pressed("speed"):
			speed = 100
