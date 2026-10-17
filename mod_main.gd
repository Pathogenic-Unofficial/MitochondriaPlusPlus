extends Node

const MOD_DIR := "FallingShrimp-MitochondriaPlusPlus"
const LOG_NAME := "FallingShrimp-MitochondriaPlusPlus:Main"

const BODYPART_IDS := [
	"pulse_mitochondrion",
	"chloroplast",
	"pentose_lysosome",
	"block_ring",
	"atp_hydrolase",
	"atp_transferase",
]

const MESSAGES := {
	"en": {
		"o_pulse_mito_name": "Pulse Mitochondrion",
		"o_pulse_mito_desc": "Every {period}s, connected organelles gain {ccol}{provided_charge}{charge} overcharge{/ccol} for {ccol}[b]{duration}s[/b]{/ccol}. Inactive outside of combat.",
		"o_pulse_mito_stats": "Every {period}s: {ccol}{provided_charge}{charge} overcharge for {duration}s{/ccol}",
		"o_pulse_mito_flavor": "Always ready.",
		"o_chloroplast_name": "Chloroplast",
		"o_chloroplast_desc": "Connected {mitochondria} gain {pos}+{base_bonus}%{/pos} overcharge strength (+10% while overcharged). When hit by a laser or ray attack: {pos}+60%{/pos} (+40% while overcharged). When a laser grazes you: {pos}+30%{/pos} (+30% while overcharged). Lasts {trigger_duration}s.",
		"o_chloroplast_flavor": "\"Borrowed\" from an unlucky plant.",
		"o_pentose_lysosome_name": "Pentose Lysosome",
		"o_pentose_lysosome_desc": "On activation, hydrolyzes 1 {dna}DNA; connected organelles gain {ccol}{provided_charge}{charge} overcharge{/ccol} for {ccol}[b]{duration}s[/b]{/ccol}.",
		"o_pentose_lysosome_stats": "{ccol}{provided_charge}{charge} overcharge{/ccol} {ccol}[b]{duration}s[/b]{/ccol}",
		"o_pentose_lysosome_flavor": "\"Sugars\" are the body's primary energy source... right?",
		"o_block_ring_name": "Fibrotic Chitin",
		"o_block_ring_desc": "Press {activate_key} to block: invulnerable for 1s, {cooldown}s cooldown. Blocking a hit within 0~0.5s grants {ccol}{provided_charge}{charge} overcharge{/ccol} for {ccol}[b]{duration}s[/b]{/ccol}; blocks between 0.5~1s have a 50% chance to fail.",
		"o_block_ring_stats": "{ccol}{provided_charge}{charge} overcharge{/ccol} {ccol}[b]{duration}s[/b]{/ccol}",
		"o_block_ring_flavor": "Sekiro: Phosphates Die Thrice",
		"o_atp_hydrolase_name": "ATP Hydrolase",
		"o_atp_hydrolase_desc": "Damage {pos}+{damage_mult}%{/pos} per second of overcharge. While overcharged, attacks also gain the bonuses of connected modifiers.",
		"o_atp_hydrolase_stats": "Damage {pos}+{damage_mult}%{/pos} per {charge} overcharge",
		"o_atp_hydrolase_flavor": "ATP → hydrolase → ADP + Pi + RAGE.",
		"o_atp_transferase_name": "ATP Transferase",
		"o_atp_transferase_desc": "While overcharged, passes overcharge on to connected organelles.",
		"o_atp_transferase_flavor": "We don't make ATP. We're just the mitochondria's porters.",
	},
	"zh_CN": {
		"o_pulse_mito_name": "脉冲线粒体",
		"o_pulse_mito_desc": "每{period}秒使已连接的细胞器获得{ccol}{provided_charge}{charge}过载{/ccol} {ccol}[b]{duration}秒[/b]{/ccol}。战斗外不生效。",
		"o_pulse_mito_stats": "每{period}秒：{ccol}{provided_charge}{charge} 过载 {duration}秒{/ccol}",
		"o_pulse_mito_flavor": "时刻准备着。",
		"o_chloroplast_name": "叶绿体",
		"o_chloroplast_desc": "已连接{mitochondria}的过载强度{pos}+{base_bonus}%{/pos}（{charge}+10%）。受到激光或射线伤害时{pos}+60%{/pos}（{charge}+40%），擦过激光时{pos}+30%{/pos}（{charge}+30%），持续{trigger_duration}秒。",
		"o_chloroplast_flavor": "从某株倒霉的植物那里“借”来的。",
		"o_pentose_lysosome_name": "五碳溶糖体",
		"o_pentose_lysosome_desc": "触发主动技能时水解1个{dna}DNA，使已连接的细胞器获得{ccol}{provided_charge}{charge}过载{/ccol} {ccol}[b]{duration}秒[/b]{/ccol}。",
		"o_pentose_lysosome_stats": "{ccol}{provided_charge}{charge} 过载{/ccol} {ccol}[b]{duration}秒[/b]{/ccol}",
		"o_pentose_lysosome_flavor": "“糖类”是生物体的主要供能物质...？",
		"o_block_ring_name": "纤维化几丁质",
		"o_block_ring_desc": "按下{activate_key}格挡：无敌1秒，冷却{cooldown}秒。在0~0.5秒内格挡伤害，获得{ccol}{provided_charge}{charge}过载{/ccol} {ccol}[b]{duration}秒[/b]{/ccol}；0.5~1秒内格挡有50%概率失败。",
		"o_block_ring_stats": "{ccol}{provided_charge}{charge} 过载{/ccol} {ccol}[b]{duration}秒[/b]{/ccol}",
		"o_block_ring_flavor": "多糖：磷逝三度",
		"o_atp_hydrolase_name": "ATP水解酶",
		"o_atp_hydrolase_desc": "每过载1秒，伤害{pos}+{damage_mult}%{/pos}。过载时，攻击会额外获得已连接修改器的加成。",
		"o_atp_hydrolase_stats": "每{charge}过载，伤害{pos}+{damage_mult}%{/pos}",
		"o_atp_hydrolase_flavor": "ATP →水解酶→ ADP + Pi + 怒火",
		"o_atp_transferase_name": "ATP转移酶",
		"o_atp_transferase_desc": "自身过载时，将过载传递给已连接的细胞器。",
		"o_atp_transferase_flavor": "我们不生产ATP，我们只做线粒体的搬运工。",
	},
}

func _init() -> void:
	ModLoaderLog.info("Init", LOG_NAME)
	_register_bodyparts()
	_add_translations()

func _ready() -> void:
	ModLoaderLog.info("Ready", LOG_NAME)

func _register_bodyparts() -> void:
	var group = load("res://scn/player/bodyparts/all_bodyparts.tres")
	group.includes.append("res://mods-unpacked/%s/scn/player/bodyparts/internal/**.tres" % MOD_DIR)
	for id in BODYPART_IDS:
		group.paths.append("res://mods-unpacked/%s/scn/player/bodyparts/internal/%s.tres" % [MOD_DIR, id])

func _add_translations() -> void:
	for locale in MESSAGES:
		var t := Translation.new()
		t.locale = locale
		for key in MESSAGES[locale]:
			t.add_message(key, MESSAGES[locale][key])
		TranslationServer.add_translation(t)
