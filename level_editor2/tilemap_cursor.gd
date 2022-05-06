class_name TileMapCursor
extends Node2D

export(Vector2) var offset := Vector2.ZERO
export(Vector2) var cell_size := Vector2.ONE * 16.0
export(Color) var color := Color.white
export(int) var density := 10

export(float) var width := 2.0

func regenerate() -> void:
	update()
	
	for i in get_child_count():
		get_child(i).queue_free()
	
	var gradient := Gradient.new()
	gradient.offsets = PoolRealArray([0.0, 0.25, 0.75, 1.0])
	var transparent_color := color
	transparent_color.a = 0
	gradient.colors = PoolColorArray([transparent_color, color, color, transparent_color])
	
	var line_count := 2
	var margin_x := cell_size.x
	var margin_y := cell_size.y
	
	# rows
	for i in line_count:
		var row := Line2D.new()
		row.default_color = color
		row.gradient = gradient
		row.width = width
		for j in density + 1:
			row.add_point(Vector2(
				(-margin_x / 2.0) + j * ((cell_size.x + margin_x) / density),
				i * cell_size.y) + offset)
		
		add_child(row)
	
	# column
	for i in line_count:
		var column := Line2D.new()
		column.default_color = color
		column.gradient = gradient
		column.width = width
		for j in density + 1:
			column.add_point(Vector2(
				i * cell_size.x,
				(-margin_y / 2.0) + j * ((cell_size.y + margin_y) / density)) + offset)
		
		add_child(column)
