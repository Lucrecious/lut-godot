class_name STring
extends Node

static func split_sentences(text: String) -> PoolStringArray:
	var sentences := PoolStringArray([])
	
	var atoms := text.split(' ')
	
	if atoms.empty():
		return sentences
	
	var current_atom := 0
	var current_sentence := PoolStringArray([])
	while current_atom < atoms.size():
		var atom := atoms[current_atom]
		current_sentence.push_back(atom)
		if _ends_with_sentence_ender(atom):
			sentences.push_back(current_sentence.join(' '))
			current_sentence.resize(0)
		
		current_atom += 1
		
	return sentences

static func _ends_with_sentence_ender(text: String) -> bool:
	return text.ends_with('!') or text.ends_with('.') or text.ends_with('?')
