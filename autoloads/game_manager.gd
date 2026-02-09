extends Node


#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var all_nodes:Array[Node] = get_tree().get_root().find_children("*","",true,false)
		for node in all_nodes:
			if ((node is AudioStreamPlayer) 
			or ( node is AudioStreamPlayer2D)
			or ( node is AudioStreamPlayer3D)):
				print("Deleting AudioStrem Player leaker: ", node); node.queue_free()
		await get_tree().create_timer(0.1).timeout
		print("All leakers deleted. Quitting.")
		get_tree().quit()

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
