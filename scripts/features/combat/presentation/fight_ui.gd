class_name FightUI extends Control

@export var map_container : MapContainer
const _PRE_LOG : String = "FightUI> "

func _ready():
	close()

func open():
	Logger.log_i(_PRE_LOG + "Opening Fight UI...")
	map_container.generate_map(3)
	show()

func close():
	Logger.log_i(_PRE_LOG + "Closing Fight UI...")
	hide()	
