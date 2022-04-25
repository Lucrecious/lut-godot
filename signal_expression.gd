class_name SignalExpression
extends Node

signal conditions_met()
signal conditions_unmet()

export(String) var condition_key := ''
export(Array, NodePath) var _nodes_path := []
export(Array, String) var _properties := []
export(String) var _expression_format := ''

export(bool) var debug_print := false

var _nodes := []

var _expression: Expression

func _ready() -> void:
	assert(_nodes_path.size() == _properties.size(), 'must be the same size')
	
	var property_strs := []
	for i in _nodes_path.size():
		_nodes.push_back(get_node_or_null(_nodes_path[i]))
		property_strs.push_back('_nodes[%d].%s' % [i, _properties[i]])
	
	if debug_print:
		print(property_strs)
	
	if _expression_format.empty():
		_expression_format = 'false'
	
	var expression_str := _expression_format.format(property_strs)
	
	var expression := Expression.new()
	expression.parse(expression_str)
	_expression = expression

var _is_true := false
func on_condition_changed(_1=null,_2=null,_3=null,_4=null,_5=null,_6=null) -> void:
	var new_is_true := is_true()
	if new_is_true == _is_true: return
	_is_true = new_is_true
	
	if debug_print:
		print('%s - on_condition_changed - is_true(): %s' % [get_path(), new_is_true])
		print('  Expression: %s' % [_expression_format])
		print()
	
	if _is_true:
		emit_signal('conditions_met')
		return
	
	if not _is_true:
		emit_signal('conditions_unmet')
		return

func is_true() -> bool:
	return bool(_expression.execute([], self))










