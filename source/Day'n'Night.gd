extends CanvasModulate

export var gradient: GradientTexture
export var INGAME_SPEED = 14.4 # = x.0 means that 1 sec. in real life will pass x minutes in the game
export var INITIAL_HOUR = 20

# 12 h
# 12*60 min
# 12*60 / 50 min/moves
# 12*6 / 5 = 72 / 5 = 14.4 min / moves

const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY

var time = 0.0
var value

func _ready():
	time = INGAME_TO_REAL_MINUTE_DURATION * INITIAL_HOUR * MINUTES_PER_HOUR
	value = (sin(time - PI / 2.0) + 1.0) / 2.0
	self.color = gradient.gradient.interpolate(value)

func pass_time():
	var delta = 1.0
	time += delta * INGAME_TO_REAL_MINUTE_DURATION * INGAME_SPEED
	value = (sin(time - PI / 2.0) + 1.0) / 2.0
	self.color = gradient.gradient.interpolate(value)
