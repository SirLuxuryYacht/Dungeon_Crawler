extends Node

####### Weapons
const unarmed_desc = "Your bare hands."

const rusty_bar_desc = "A repurposed steel beam, unusually well preserved. It is not made in this land and should well serve as a rudimentary means of defense."

const test_sword_desc = "A white stick of undeterminable material. Maybe it originated from outside the confines of this world."

const longsword_desc = "Sturdy and reliable longsword. The blades alloy faintly sparkles, revealing its extraordinary composition. Deals lightning damage in addition to standard damage."

const rifle_desc = "A blackpowder-driven bolt action rifle. Extremely accurate, but somewhat lacking in damage. Be careful where you aim."

const katana_desc = "Large eastern sword with a very sharp blade."

const chinese_blade_desc = "Heavy and effective two-handed blade."

const poleaxe_desc = "Some description."

const bellhammer_desc = "Bellhammer used to toll the great bell."
####### Usables
const health_potion_desc = "A bottle filled with rejuvenating vigor. The art of creating these is all but lost, though rumors tell of similar potions of a new make appearing here and there."

const stamina_potion_desc = "A bottle filled with green rejuvenating vigor. Rather than healing, it gives the user a sometimes bitterly neccessary renewed resolve."

const stone_key_desc = "Heavily eroded, this key seems to have been used to loosely secure crude doors in older times."

const iron_key_desc = "Its sturdy iron make reveals this key to be able to open heavy iron doors."

const institute_wood_key_desc = "Non-critical doors are opened with this key. Seldomly used, only few depended on this key to keep secrets forever."

const institute_heavy_key_desc = "Sturdy metal key designed for elaborate lock mechanisms. A single letter \"A\" has been worked inside."

const lantern_desc = "Navigate darkness."

const none_desc = "No item."

####### functions
func getDescription(item) -> String:
	return get(item+"_desc")
	
