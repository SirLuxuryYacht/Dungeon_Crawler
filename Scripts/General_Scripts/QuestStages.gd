extends Node

const quest_stage_reference = ["test","nomad","test_trader_1"]

const quest_stages = [[1,1],[1,1],[1,1]] #the second entry is the dialogue stage of the character


func get_const(var_name: String) -> Array:
	var getter = get(var_name)
	return getter


func getStage(character_name: String,quest_list: Array,is_dialogue: bool) -> int:
	var index = 0
	while character_name != quest_stage_reference[index]:
		index += 1
	if is_dialogue:
		return quest_list[index][1]
	else:
		return quest_list[index][0]


func setStage(character_name: String,quest_list: Array,stage: int,is_dialogue: bool) -> void:
	var index = 0
	while character_name != quest_stage_reference[index]:
		index += 1
	if is_dialogue:
		quest_list[index][1] = stage
	else:
		quest_list[index][0] = stage
		quest_list[index][1] = 1 #automatically resets the dialogue stage of this quest to 1
