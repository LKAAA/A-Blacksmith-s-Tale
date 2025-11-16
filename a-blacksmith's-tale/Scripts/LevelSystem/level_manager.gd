extends Node
class_name CharacterLevels

@export var skill_list: Array[Skill] = []
var skills: Dictionary = {}

signal level_up

func _ready() -> void:
	# Duplicate the skill list so that it is individual per character and not shared
	for skill in skill_list:
		var new_skill: Skill = skill.duplicate(true)
		skills[skill.name.to_lower()] = new_skill

func get_skill(skill_name: String) -> Skill:
	var skill_n = skill_name.to_lower()
	if skills[skill_n]: 
		return skills[skill_n]
	else:
		printerr("Skill does not exist on this object")
		return null

func gain_xp(skill_name: String, amount: int) -> void:
	var skill_n = skill_name.to_lower()
	if not skills.get(skill_n):
		print("Error: '%s' not found in skills." % skill_n)
		return
	var skill: Skill = skills[skill_n]
	if skill.cur_xp  == null: return
	skill.cur_xp  += amount
	if skill.cur_xp >= calculate_skill_xp_requirement(skill):
		skill.cur_xp = level_up_skill(skill) # Set to leftover xp
	print("%s at %d xp" % [skill_n, skill.cur_xp])

func calculate_skill_xp_requirement(skill: Skill) -> int:
	var calculated_xp: int = (80 * pow(skill.level, 3) - 400 * skill.level + 520)
	print("To reach the next level you require %d xp." % calculated_xp)
	return calculated_xp

func level_up_skill(skill: Skill) -> int:
	if skill.level == 20:
		print("At max")
		return skill.cur_xp
	
	var leftover_xp = skill.cur_xp - calculate_skill_xp_requirement(skill) 
	
	skill.level += 1
	level_up.emit()
	
	return leftover_xp
