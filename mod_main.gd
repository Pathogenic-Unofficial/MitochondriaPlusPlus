extends Node

const MOD_DIR := "FallingShrimp-adenosine_hexaphosphate"
const LOG_NAME := "FallingShrimp-adenosine_hexaphosphate:Main"

const BODYPART_IDS := [
	"pulse_mitochondrion",
	"chloroplast",
	"pentose_lysosome",
	"block_ring",
	"atp_hydrolase",
	"atp_transferase",
	"dext",
]

const MESSAGES := {
	"en": {
		"o_pulse_mito_name": "Pulse Mitochondrion",
		"o_pulse_mito_desc": "Every {period}s, connected organelles gain {ccol}{provided_charge}{charge} overcharge{/ccol} for {ccol}[b]{duration}s[/b]{/ccol}. Inactive outside of combat.",
		"o_pulse_mito_flavor": "Always ready to contribute to the communist (ATP) cause!",
		"o_chloroplast_name": "Chloroplast",
		"o_chloroplast_desc": "Connected {mitochondria} gain {pos}+{base_bonus}%{/pos} overcharge strength. Dodging through enemy bullets: {pos}+{graze_bonus}%{/pos}. Lasts {trigger_duration}s.",
		"o_chloroplast_charged": "Overcharge strength {pos}+{base_charge_bonus}%{/pos}; dodging through enemy bullets grants an extra {pos}+{graze_charge_bonus}%{/pos}.",
		"o_chloroplast_flavor": "\"Borrowed\" from an unlucky plant.",
		"o_pentose_lysosome_name": "Pentose Lysosome",
		"o_pentose_lysosome_desc": "Press {activate_key} to hydrolyze 1 {dna}DNA: connected organelles gain {ccol}{provided_charge}{charge} overcharge{/ccol} for {ccol}[b]{duration}s[/b]{/ccol}.",
		"o_pentose_lysosome_flavor": "\"Sugars\" are the body's primary energy source... right?",
		"o_block_ring_name": "Fibrotic Chitin",
		"o_block_ring_desc": "Press {activate_key} to parry: invulnerable for {pos}1s{/pos}, {pos}{cooldown}s{/pos} cooldown. Parrying a hit within 0~{pos}{perfect_parry_window}s{/pos} grants {ccol}{provided_charge}{charge} overcharge{/ccol} {ccol}[b]{duration}s[/b]{/ccol}; damage parried after {perfect_parry_window}s has a {unexact_parry_rate}% chance to fail.",
		"o_block_ring_flavor": "Sekiro: Phosphates Die Thrice",
		"o_atp_hydrolase_name": "ATP Hydrolase",
		"o_atp_hydrolase_desc": "Damage {pos}+{damage_mult}%{/pos} per 50% of overcharge strength.",
		"o_atp_hydrolase_charged": "Damage {pos}+{damage_mult}%{/pos}",
		"o_atp_hydrolase_chainable": "When overcharged, connected attacks gain the bonuses of connected modifiers",
		"o_atp_hydrolase_flavor": "ATP → hydrolase → ADP + Pi + RAGE.",
		"o_atp_transferase_name": "ATP Transferase",
		"o_atp_transferase_desc": "Passes overcharge on to connected organelles.",
		"o_atp_transferase_charged": "Connected organelles also gain overcharge.",
		"o_dext_name": "Dext",
		"o_dext_desc": "Connected attacks deal {neg}-{base_mult}%{/neg} damage but fire a FreezedMeat with random speed that ignores terrain and deals {pos}{meat_mult}% of the attack's original damage{/pos} — faster meat and longer intervals between shots deal more damage. Freezes enemies for {pos}{freeze_time}s{/pos} on hit.",
		"o_dext_flavor": "Frozen meat incoming!",
		"o_dext_charged": "FreezedMeat damage {pos}+50%{/pos}",
		"o_atp_transferase_flavor": "We don't make ATP. We're just the mitochondria's porters.",
	},
	"zh_CN": {
		"o_pulse_mito_name": "脉冲线粒体",
		"o_pulse_mito_desc": "每{period}秒使已连接的细胞器获得{ccol}{provided_charge}{charge}过载{/ccol} {ccol}[b]{duration}秒[/b]{/ccol}。战斗外不生效。",
		"o_pulse_mito_flavor": "时刻准备着，为共产（ATP）主义做贡献！",
		"o_chloroplast_name": "叶绿体",
		"o_chloroplast_desc": "已连接{mitochondria}的过载强度{pos}+{base_bonus}%{/pos}。闪避穿过敌方子弹时{pos}+{graze_bonus}%{/pos}，持续{trigger_duration}秒。",
		"o_chloroplast_charged": "过载强度{pos}+{base_charge_bonus}%{/pos}；闪避穿过敌方子弹时额外{pos}+{graze_charge_bonus}%{/pos}。",
		"o_chloroplast_flavor": "从某株倒霉的植物那里“借”来的。",
		"o_pentose_lysosome_name": "五碳溶糖体",
		"o_pentose_lysosome_desc": "按下{activate_key}水解1个{dna}DNA，使已连接的细胞器获得{ccol}{provided_charge}{charge}过载{/ccol} {ccol}[b]{duration}秒[/b]{/ccol}。",
		"o_pentose_lysosome_flavor": "“糖类”是生物体的主要供能物质...？",
		"o_block_ring_name": "纤维化几丁质",
		"o_block_ring_desc": "按下{activate_key}格挡：无敌{pos}1秒{/pos}，冷却{pos}{cooldown}秒{/pos}。在0~{pos}{perfect_parry_window}秒{/pos}内格挡伤害，获得{ccol}{provided_charge}{charge}过载{/ccol}{ccol}[b]{duration}秒[/b]{/ccol}；在{perfect_parry_window}秒后格挡的伤害有{unexact_parry_rate}%概率失败。",
		"o_block_ring_flavor": "多糖：磷逝三度",
		"o_atp_hydrolase_name": "ATP水解酶",
		"o_atp_hydrolase_desc": "每50%强度的过载，伤害{pos}+{damage_mult}%{/pos}。",
		"o_atp_hydrolase_charged": "伤害{pos}+{damage_mult}%{/pos}",
		"o_atp_hydrolase_chainable": "当过载时，连接的攻击 获得 已连接的修改器 加成",
		"o_atp_hydrolase_flavor": "ATP →水解酶→ ADP + Pi + 怒火",
		"o_atp_transferase_name": "ATP转移酶",
		"o_atp_transferase_desc": "将过载传递给已连接的细胞器。",
		"o_atp_transferase_charged": "连接的细胞器也获得过载。",
		"o_atp_transferase_flavor": "我们不生产ATP，我们只做线粒体的搬运工。",
		"o_dext_name": "Dext",
		"o_dext_desc": "连接的攻击伤害{neg}-{base_mult}%{/neg}，但攻击会附带一块随机速度、无视地形穿透且造成{pos}{meat_mult}%原伤害{/pos}的冻肉，速度越快伤害越高，两次攻击间隔越久伤害越高，撞击后冰冻敌人{pos}{freeze_time}秒{/pos}。",
		"o_dext_flavor": "冻肉来袭！",
		"o_dext_charged": "冻肉伤害{pos}+50%{/pos}",
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
