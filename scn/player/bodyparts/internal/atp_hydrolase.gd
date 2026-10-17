@tool
extends Bodypart

func _physics_process(delta: float) -> void:
	super(delta)
	%Progress.value = lerp(%Progress.value, minf(charge / 3.0, 1.0), 0.04)

func modify_attack(attack, chain: Array) -> void:
	var bonus := get_charge_bonus()
	if bonus > 0.0:
		attack.damage += attack.base_damage * bonus
		animate_connection_to(chain[-1])
	if charge > 0.0:
		for c in connections:
			if c in chain:
				continue
			if c.has_tag(G.BodypartTags.AttackModifier) or c.has_tag(G.BodypartTags.BulletModifier):
				c.modify_attack(attack, _extend_chain(chain))
	want_charge = true

func get_charge_bonus() -> float:
	var step := maxf(1.0 - 0.1 * rarity, 0.1)
	return charge / step * (0.04 + 0.03 * rarity)

func get_format_dict() -> Dictionary:
	return super().merged({
		"damage_mult": roundi((0.04 + 0.03 * rarity) * 100),
	})
