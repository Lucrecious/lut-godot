class_name RNG
extends Reference

var _random := RandomNumberGenerator.new()

func _init().():
	randomize()
	_random.randomize()

func weighted_indices(percents: PoolRealArray, trials: int) -> Array:
	var weights := Array(percents)
	
	var indices := []
	var unused := trials
	for i in weights.size():
		var p := weights[i] as float
		var amount := int(float(trials) * p)
		if amount > unused:
			amount = unused
		
		unused -= amount
		
		for _i in range(0, amount):
			indices.push_back(i)
	
	indices.shuffle()
	
	return indices
	
