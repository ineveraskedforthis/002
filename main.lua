require "fights._common"
require "mechanics.basic"
require "types"

function CLAMP(x, a, b)
	if (x < a) then
		return a
	end
	if (x > b) then
		return b
	end
	return x
end

---comment
---@param t number
---@return number
function SMOOTHSTEP(t)
	return t * t * (3 - 2 * t)
end

---@param x number
---@return number
function SMOOTHERSTEP(x)
	return x * x * x * (x * (6 * x - 15) + 10);
end

DEFAULT_FONT = love.graphics.newFont(
	"assets/alte-din-1451-mittelschrift/din1451alt.ttf", 14
)
BIG_FONT = love.graphics.newFont(
	"assets/alte-din-1451-mittelschrift/din1451alt.ttf", 80
)

SCENE_BATTLE_SELECTOR = 0
SCENE_BATTLE = 1
SCENE_EDIT_LINEUP = 2
SCENE_PULL_ACTORS = 3
SCENE_LEARN_SKILLS = 4




local scene_data_battle = require "scenes.battle"
local scene_data_battle_select = require "scenes.battle-select"
local scene_data_edit_lineup = require "scenes.edit-lineup"
local scene_data_pull = require "scenes.hire-actor"
local scene_data_learn = require "scenes.learn-skills"

function love.load()
	---@type number
	CURRENCY = 5

	CURRENT_SCENE = SCENE_BATTLE_SELECTOR



	---@type MetaActorWrapper[]
	PLAYABLE_META_ACTORS = {
		{
			def = require "meta-actors.main-character",
			unlocked = true,
			lineup_position = 1,
			experience = 0,
			additional_weapon_mastery = 0,
			level = 0,
			skill_points = 0,
			skills = {},
			gemstones = {}
		},
		{
			def = require "meta-actors.chud",
			unlocked = false,
			lineup_position = 0,
			experience = 0,
			additional_weapon_mastery = 0,
			level = 0,
			skill_points = 10,
			skills = {},
			gemstones = {}
		},
		{
			def = require "meta-actors.basic-healer",
			unlocked = false,
			lineup_position = 0,
			experience = 0,
			additional_weapon_mastery = 0,
			level = 0,
			skill_points = 0,
			skills = {},
			gemstones = {}
		},
		{
			def = require "meta-actors.fire-mage",
			unlocked = false,
			lineup_position = 0,
			experience = 0,
			additional_weapon_mastery = 0,
			level = 0,
			skill_points = 0,
			skills = {},
			gemstones = {}
		},
		{
			def = require "meta-actors.rebe",
			unlocked = false,
			lineup_position = 0,
			experience = 0,
			additional_weapon_mastery = 0,
			level = 0,
			skill_points = 0,
			skills = {},
			gemstones = {}
		},
		{
			def = require "meta-actors.mohi",
			unlocked = false,
			lineup_position = 0,
			experience = 0,
			additional_weapon_mastery = 0,
			level = 0,
			skill_points = 0,
			skills = {},
			gemstones = {}
		}
	}

	---@type GemstoneWrapper[]
	COLLECTED_GEMSTONES = {
		{
			actor = 0,
			def = require "gemstones.scavenger"
		}
	}

	GIVE_GEMSTONE(1, 1)

	CHARACTER_LINEUP = {
		1,
		0,
		0,
		0
	}
end

function love.update(dt)
	if CURRENT_SCENE == SCENE_BATTLE then
		scene_data_battle.update(dt)
	elseif CURRENT_SCENE == SCENE_BATTLE_SELECTOR then
		scene_data_battle_select.update(dt)
	elseif CURRENT_SCENE == SCENE_EDIT_LINEUP then
		scene_data_edit_lineup.update(dt)
	elseif CURRENT_SCENE == SCENE_PULL_ACTORS then
		scene_data_pull.update(dt)
	elseif CURRENT_SCENE == SCENE_LEARN_SKILLS then
		scene_data_learn.update(dt)
	end
end

function love.draw()
	if CURRENT_SCENE == SCENE_BATTLE then
		scene_data_battle.render()
	elseif CURRENT_SCENE == SCENE_BATTLE_SELECTOR then
		scene_data_battle_select.render()
	elseif CURRENT_SCENE == SCENE_EDIT_LINEUP then
		scene_data_edit_lineup.render()
	elseif CURRENT_SCENE == SCENE_PULL_ACTORS then
		scene_data_pull.render()
	elseif CURRENT_SCENE == SCENE_LEARN_SKILLS then
		scene_data_learn.render()
	end

	love.graphics.print(CURRENCY .. " points", 5, 580)
end

function love.mousepressed(x, y, button, istouch, presses)
	if CURRENT_SCENE == SCENE_BATTLE then
		scene_data_battle.on_click(x, y)
	elseif CURRENT_SCENE == SCENE_BATTLE_SELECTOR then
		scene_data_battle_select.on_click(x, y)
	elseif CURRENT_SCENE == SCENE_EDIT_LINEUP then
		scene_data_edit_lineup.on_click(x, y)
	elseif CURRENT_SCENE == SCENE_PULL_ACTORS then
		scene_data_pull.on_click(x, y)
	elseif CURRENT_SCENE == SCENE_LEARN_SKILLS then
		scene_data_learn.on_click(x, y)
	end
end