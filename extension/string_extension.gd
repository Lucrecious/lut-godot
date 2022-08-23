class_name STring
extends Node

# returns manually autowrapped lines
static func autowrap(text: String, width: float, font: Font) -> PoolStringArray:
	var sentences := PoolStringArray([])
	
	var words := text.split(' ')
	var i := 0
	while i < words.size():
		var current_width := 0.0
		var sentence := PoolStringArray([])
		
		while i < words.size():
			var w := words[i]
			current_width += _get_text_width(w + ' ', font)
			if current_width > width:
				sentences.push_back(sentence.join(' '))
				sentence.resize(0)
				break
			else:
				sentence.push_back(w)
				i += 1
		
		if sentence.empty():
			continue
		sentences.push_back(sentence.join(' '))
		sentence.resize(0)
	
	return sentences

static func _get_text_width(text: String, font: Font) -> float:
	var width := 0.0
	var length := text.length()
	for i in text.length():
		var c := text.ord_at(i)
		var n := 0
		if i + 1 < length:
			n = text.ord_at(i + 1)
		
		width += font.get_char_size(c, n).x
	
	return width

static func split_phrases(text: String) -> PoolStringArray:
	var sentences := PoolStringArray([])
	
	var atoms := text.split(' ')
	
	if atoms.empty():
		return sentences
	
	var current_atom := 0
	var current_sentence := PoolStringArray([])
	while current_atom < atoms.size():
		var atom := atoms[current_atom]
		current_sentence.push_back(atom)
		if _ends_with_phrase_ender(atom):
			sentences.push_back(current_sentence.join(' '))
			current_sentence.resize(0)
		
		current_atom += 1
		
	return sentences

static func _ends_with_phrase_ender(text: String) -> bool:
	return text.ends_with('!') or text.ends_with('.') or text.ends_with('?') or text.ends_with('\n')
