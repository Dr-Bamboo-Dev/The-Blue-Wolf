extends Node
class_name GameConst

enum gem_type {EMERALD, RUBY, AMETHYST}
var gem_names:PackedStringArray = []
var gems_collected:PackedInt32Array = []
const all_gems:PackedInt32Array = [1,1,1]


#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _init() -> void:
	gem_names = gem_type.keys()

	for type in gem_type.values().size():
		gems_collected.append(0)

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_gem_collected(type:gem_type) -> void:
	gems_collected[type] += 1
	print(gem_names[type], " collected - ", gems_collected)
	if gems_collected == all_gems:
		WolfStats.hunger_drain_paused = true
		get_tree().current_scene.ascension_flash()
		print_debug("All gems collected! Play end jingle.")
	else:
		AudioManager.duck_music(10.0, 0.4, 0.3)
		AudioManager.play_sfx(&"gem_get", 0.0, 1.0)
