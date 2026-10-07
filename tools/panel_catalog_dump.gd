extends SceneTree
## Dumps every control of the debug panel (section, type, name, value) to a JSON
## file, so the list can be reviewed in an Excel sheet (tools/panel_catalog.py).
##   godot --headless --path slavs --script ../tools/panel_catalog_dump.gd -- out.json

var _f: int = 0
var _out: String = "panel_catalog.json"


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		_out = args[0]
	var m = load("res://scenes/main.tscn").instantiate()
	m.name = "Main"
	root.add_child(m)


func _process(_delta: float) -> bool:
	_f += 1
	if _f < 5:
		return false
	var overlay: Node = _find_overlay(root)
	if overlay == null:
		printerr("panel not found")
		return true
	var items: Array = []
	var section: String = ""
	var labels_by_node: Dictionary = {}
	for key in overlay.value_labels.keys():
		labels_by_node[overlay.value_labels[key]] = key
	var visible_only: bool = OS.get_cmdline_user_args().has("--visible")
	for row in overlay.rows.get_children():
		if visible_only and not row.visible:
			continue
		if row is Label:
			section = row.text
			items.append({"section": section, "type": "section", "name": row.text, "value": ""})
		elif row is CheckButton:
			items.append({"section": section, "type": "switch", "name": row.text,
				"value": "ZAP" if row.button_pressed else "VYP"})
		elif row is Button:
			items.append({"section": section, "type": "button", "name": row.text, "value": ""})
		elif row is VBoxContainer:
			var lbl: Label = null
			var sl: HSlider = null
			for c in row.get_children():
				if c is Label and labels_by_node.has(c):
					lbl = c
				elif c is HSlider:
					sl = c
			if lbl != null and sl != null:
				var name: String = labels_by_node.get(lbl, lbl.text)
				items.append({"section": section, "type": "slider", "name": name,
					"value": str(snappedf(sl.value, 0.0001))})
			else:
				items.append({"section": section, "type": "other", "name": row.name, "value": ""})
		else:
			items.append({"section": section, "type": "other", "name": str(row.name), "value": ""})
	var f := FileAccess.open(_out, FileAccess.WRITE)
	f.store_string(JSON.stringify(items, "\t"))
	f.close()
	print("catalog: %d items -> %s" % [items.size(), _out])
	return true


func _find_overlay(n: Node) -> Node:
	if "value_labels" in n and "rows" in n:
		return n
	for c in n.get_children():
		var r: Node = _find_overlay(c)
		if r != null:
			return r
	return null
