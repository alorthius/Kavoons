extends TextureButton

export(float, 1) var focus_scale
export(float, 1) var butt_darkened
export(float, 1) var icon_darkened

onready var _icon: TextureRect = $Icon
onready var _tween: Tween = $Tween

onready var _scale_init: Vector2 = rect_scale
onready var _scale_final: Vector2 = rect_scale + focus_scale * Vector2.ONE

onready var _position_init: Vector2 = rect_position
onready var _position_final: Vector2 = rect_position - rect_size * focus_scale * Vector2.ONE / 2.0

onready var _modulate_init := modulate
onready var _modulate_butt_final := modulate.darkened(butt_darkened)
onready var _modulate_icon_final := modulate.darkened(icon_darkened)

var _scale_time: float = 0.05
var _modulate_time: float = 0.1


func _ready():
	# Godot bug? On _ready rect_position is (0, 0), but yielding one frame fixes it
	# https://github.com/godotengine/godot/issues/20896
	yield(get_tree(), "idle_frame") 
	_position_init = rect_position
	_position_final = rect_position - rect_size * focus_scale * Vector2.ONE / 2.0


func _on_MyButt_mouse_entered():
	# There is no pretty way to keep button centered on changing its rect
	# https://godotengine.org/qa/10047/how-to-scale-button-when-pressed
	assert(_tween.interpolate_property(self, "rect_scale", _scale_init, _scale_final, _scale_time, Tween.TRANS_LINEAR, Tween.EASE_OUT))
	assert(_tween.interpolate_property(self, "rect_position", _position_init, _position_final, _scale_time, Tween.TRANS_LINEAR, Tween.EASE_OUT))
	assert(_tween.start())

func _on_MyButt_mouse_exited():
	assert(_tween.interpolate_property(self, "rect_scale", _scale_final, _scale_init, _scale_time, Tween.TRANS_LINEAR, Tween.EASE_OUT))
	assert(_tween.interpolate_property(self, "rect_position", _position_final, _position_init, _scale_time, Tween.TRANS_LINEAR, Tween.EASE_OUT))
	assert(_tween.start())


func enable():
	disabled = false
	assert(_tween.interpolate_property(self,  "self_modulate", _modulate_butt_final, _modulate_init, _modulate_time, Tween.TRANS_LINEAR, Tween.EASE_OUT))
	assert(_tween.interpolate_property(_icon, "self_modulate", _modulate_icon_final, _modulate_init, _modulate_time, Tween.TRANS_LINEAR, Tween.EASE_OUT))
	assert(_tween.start())

func disable():
	disabled = true
	assert(_tween.interpolate_property(self,  "self_modulate", _modulate_init, _modulate_butt_final, _modulate_time, Tween.TRANS_LINEAR, Tween.EASE_OUT))
	assert(_tween.interpolate_property(_icon, "self_modulate", _modulate_init, _modulate_icon_final, _modulate_time, Tween.TRANS_LINEAR, Tween.EASE_OUT))
	assert(_tween.start())


func butt_name(new_name: String):
	name = new_name
	return self

func butt_icon(texture_path: String):
	_icon.texture = load(texture_path)
	return self

func color(new_color: Color):
	self_modulate = new_color
	return self
