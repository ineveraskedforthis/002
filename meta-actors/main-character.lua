---@type MetaActor
local def = {
	MAX_HP = 150,
	ATK = 50,
	DEF = 0,
	SPD = 100,
	name = "(You)",
	inherent_skills = {require "skills.wait", require "skills.attack"},
	image = love.graphics.newImage("assets/main-character.png"),
	image_action_bar = love.graphics.newImage("assets/main-character-h.png"),
	image_skills = love.graphics.newImage("assets/main-character-skills.png"),
	MAG = 5,
	STR = 15,
	alignment = {},
	weapon = WEAPON.SWORD,
	weapon_mastery = 0,
	STR_per_level = 4,
	MAG_per_level = 4,
	SPD_per_level = 1,
}

def.alignment[ELEMENT.FIRE] = true

return def