extends Node

@onready var extension_api: Node  ## A variable for easy reference to the Api

var search_edit: LineEdit
var global: Node
var timeline

## This script acts as a setup for the extension
func _enter_tree() -> void:
	# NOTE: Use get_node_or_null("/root/ExtensionsApi") to access api.
	# NOTE: See https://www.oramainteractive.com/Pixelorama-Docs/extension_system/extension_api for
	# detailed documentation.
	extension_api = get_node_or_null("/root/ExtensionsApi")

	# |==== Your code goes here ====|
	global = extension_api.general.get_global()
	timeline = global.animation_timeline
	if timeline:
		search_edit = LineEdit.new()
		search_edit.placeholder_text = "Find layer..."
		search_edit.right_icon = load("res://assets/graphics/misc/search.svg")
		var search_parent = timeline.layer_settings_container
		if search_parent:
			search_edit.text_changed.connect(_initiate_search)
			global.project_switched.connect(project_changed)
			global.project_data_changed.connect(project_changed)
			search_parent.add_child(search_edit)
	# |=============================|


func project_changed(_args = null):
	if search_edit:
		_initiate_search(search_edit.text)


func _initiate_search(new_text: String):
	new_text = new_text.strip_edges().to_lower().replace(" ", "")
	for layer_button in timeline.layer_vbox.get_children():
		var layer = extension_api.project.current_project.layers[layer_button.layer_index]
		var is_related = new_text in layer.name.to_lower().replace(" ", "")
		if new_text.is_empty():
			is_related = layer.is_expanded_in_hierarchy()
		layer_button.visible = is_related
		timeline.cel_vbox.get_child(layer_button.get_index()).visible = is_related


## Gets called when the extension is being disabled or uninstalled (while enabled).
func _exit_tree() -> void:
	# Remember to remove things that you added using this extension
	# Disconnect any signals and queue_free() any nodes that got added.
	if search_edit:
		search_edit.queue_free()
