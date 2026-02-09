extends Area2D

signal damage_dealt(amount:float)

#-----------------------------------------
# Inherited Functions
#-----------------------------------------


#-----------------------------------------
# Local Functions
#-----------------------------------------
func take_damage(damage:float) -> void:
	damage_dealt.emit(damage)

#-----------------------------------------
# Signal Functions
#-----------------------------------------
