extends Node

var export := false
var scene_controller = null
var elapsed_time : float = 0.0

var player
var dialog

var preloads = { 
	"choice" : preload("res://Assets/Icons/Choice.png"),
	"choice_none": preload("res://Assets/Icons/ChoiceNone.png")
}

# SETTINGS
var sense : float = 1.0
var volume : float = 0.5
var fps : int = 0
