@tool
extends Bodypart

func _physics_process(delta: float) -> void:
	super(delta)
	want_charge = true
	provided_charge = _get_source_charge()
	%Progress.value = lerp(%Progress.value, minf(charge, 1.0), 0.04)

func _get_source_charge() -> float:
	var total := 0.0
	var nodes := [self]
	var sources := []
	var i := 0
	while i < nodes.size():
		if not is_instance_valid(nodes[i]):
			i += 1
			continue
		for c in nodes[i].connections:
			if not is_instance_valid(c):
				continue
			if c.get_id() == "atp_transferase":
				if c not in nodes:
					nodes.append(c)
			elif c not in sources:
				sources.append(c)
				total += c.provided_charge * c.energy_generation_mult
		i += 1
	return total

func get_consumers_text() -> String:
	return ""
