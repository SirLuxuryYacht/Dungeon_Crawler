extends Node

func composeDialogue(dialogue: String) -> Array:
	var dialogue_array = []
	var i = 1
	while dialogue+"_"+str(i) in self:
		dialogue_array.append(get(dialogue+"_"+str(i)))
		i += 1
	return dialogue_array


func getDialogueBunch(character_name: String,stage: int) -> Array:
	return [composeDialogue(character_name+"_"+str(stage)+"_1"),composeDialogue(character_name+"_"+str(stage)+"_2")]


func getDialogue(dialogue: String,index: int) -> String:
	var dialogue_array = composeDialogue(dialogue)
	if index <= dialogue_array.size():
		return dialogue_array[index]
	else:
		return ""
#nomenclature: name of dialogue constant: "who is talking"_"quest_stage"_"part of dialogue"

## test npc
const test_1_1_1 = "(This is a safe version of my dialogue) Hi, welcome to this world."
const test_1_1_2 = "This is a test message. It should appear in the correct order."
const test_1_1_3 = "This is the second to last message. The next one and this one should alternatively repeat."
const test_1_1_4 = "This is the last message. Now it is looping xD."
var test_1_1 = composeDialogue("test_1_1")

const test_1_2_1 = "This is the second dialogue."
const test_1_2_2 = "This is still the same quest stage, but I now only have these two dialogues."
var test_1_2 = composeDialogue("test_1_2")

#var test_1 = [test_1_1,test_1_2]

const test_2_1_1 = "I changed my mind. This quest sucks."
const test_2_1_2 = "This game sucks too."
const test_2_1_3 = "I'm just waiting for you to leave now."
const test_2_1_4 = "(ㆆ _ ㆆ)"
var test_2_1 = composeDialogue("test_2_1")

const test_2_2_1 = "Screw you!"
const test_2_2_2 = "This quest is over."
var test_2_2 = composeDialogue("test_2_2")

## test trader
const test_trader_1_1_1_1 = "Welcome to Peter Funny's Pawn Shop."
const test_trader_1_1_1_2 = "My neighbor Mr. Paschulky is about to arrive."
const test_trader_1_1_1_3 = "I'm going to convince him that the earth is hot. HAHAHAHAHAHHAHAH!!"
const test_trader_1_1_1_4 = "Please kindly leave now. Except if you want to buy something."
var test_trader_1_1_1 = composeDialogue("test_1_1")

const test_trader_1_1_2_1 = "Hello again. Buy now or face the wrath of Mr. Paschulky."
const test_trader_1_1_2_2 = "I won't say it again."
var test_trader_1_1_2 = composeDialogue("test_1_2")

#var test_trader_1_1 = [test_trader_1_1_1,test_trader_1_1_2]

const test_trader_1_2_1_1 = "Mr Paschulky was here. He sayd he wanted to found a new sprudel company."
const test_trader_1_2_1_2 = "If you want to join, we need about 1000000000000 coins, easily farmable from the strange mobs here."
const test_trader_1_2_1_3 = "Hello again."
const test_trader_1_2_1_4 = "And goodbye if you don't want to join."
var test_trader_1_2_1 = composeDialogue("test_2_1")

const test_trader_1_2_2_1 = "Mr Paschulky! Please help me!"
const test_trader_1_2_2_2 = "Mr Paschulky..."
var test_trader_1_2_2 = composeDialogue("test_2_2")
