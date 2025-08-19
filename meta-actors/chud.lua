---@type MetaActor
local def = {
	MAX_HP = 50,
	ATK = 40,
	DEF = 0,
	SPD = 120,
	name = "Chud",
	skills = {require "skills.poison-strike"},
	image = love.graphics.newImage("assets/chud.png"),
	MAG = 10,
	STR = 10,
	alignment = {},
	weapon = WEAPON.NONE,
	weapon_mastery = 0,
}

def.alignment[ELEMENT.CHAOS] = true

return def