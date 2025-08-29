class_name RoomProperties

const CATEGORY : Dictionary = {
	TONE = "tone",
	INFO = "info"
}


const TONE_ID : Dictionary = {
	# Size goes first, this matters in the description
	# their descriptions get added with the order here
	SIZE = "size",
	AIR_QUALITY = "air_quality",
	SMELL = "smell",
	# Removed for now, obsolete (me 1 week into any project)
	# LIGHTNING = "lightning",
	# SOUNDSCAPE = "soundscape",
	TEMPERATURE = "temperature"
}

const INFO_ID : Dictionary = {
	POPULATION = "population"
} 

## Category > attribute > property > value
## tone > air_quality > dry > {"description" : "penis balls hahaha"}
