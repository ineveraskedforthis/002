local manager = require "scenes._manager"
local style = require "ui._style"
local scenes = require "scenes._ids"
local battle_manager = require "fights._battle-system"


local ids = require "scenes._ids"
local id = ids.location
local def = manager.get(id)

local rect = require "ui.rect"

local MAP = {}

local camera_center_x = 0
local camera_center_y = 0

local cell_width = 30
local cell_height = 30

local margin = 2

local shift_x = cell_height * 10
local shift_y = cell_width * 10

---@class EnemyPack
---@field alive boolean
---@field x number
---@field y number

---@type EnemyPack[]
local enemies = {}

local function register_pack(x, y)
	---@type EnemyPack
	local v = {
		alive = true,
		x = x,
		y = y
	}

	table.insert(enemies, v)
end

register_pack(1, 1)
register_pack(3, 5)
register_pack(-5, 1)

function def.render(state)
	local center_x = math.floor(camera_center_x / cell_width)
	local center_y = math.floor(camera_center_y / cell_height)

	for i = -10, 10 do
		for j = -10, 10 do
			local tile_i = center_x + i
			local tile_j = center_y + j

			local tile_x = shift_x + tile_i * cell_width - camera_center_x
			local tile_y = shift_y + tile_j * cell_height - camera_center_y

			local is_there = tile_i == state.current_location_x and tile_j == state.current_location_y

			local can_move_there = math.abs(tile_i - state.current_location_x) <= 1 and math.abs(tile_j - state.current_location_y) <= 1

			if (can_move_there) then
				love.graphics.setColor(1, 1, 0, 1)
			else
				love.graphics.setColor(0, 0, 0, 1)
			end

			love.graphics.rectangle("line", tile_x + margin, tile_y + margin, cell_width - margin * 2, cell_width - margin * 2)

			if (is_there) then
				love.graphics.rectangle("line", tile_x + margin *2, tile_y + margin * 2, cell_width - margin * 2 *2, cell_height - margin * 2 * 2)
			end
		end
	end

	love.graphics.setColor(1, 0, 0, 1)
	for index, value in ipairs(enemies) do
		if value.alive then
			local tile_i = value.x
			local tile_j = value.y
			local tile_x = shift_x + tile_i * cell_width - camera_center_x
			local tile_y = shift_y + tile_j * cell_height - camera_center_y

			love.graphics.rectangle("fill", tile_x + margin *3, tile_y + margin * 3, cell_width - margin * 3 *2, cell_height - margin * 3 * 2)
		end
	end
end


function def.on_click(state, x, y)
	local center_x = math.floor(camera_center_x / cell_width)
	local center_y = math.floor(camera_center_y / cell_height)

	for i = -10, 10 do
		for j = -10, 10 do
			local tile_i = center_x + i
			local tile_j = center_y + j

			local tile_x = shift_x + tile_i * cell_width - camera_center_x
			local tile_y = shift_y + tile_j * cell_height - camera_center_y

			local is_there = tile_i == state.current_location_x and tile_j == state.current_location_y

			local can_move_there = math.abs(tile_i - state.current_location_x) <= 1 and math.abs(tile_j - state.current_location_y) <= 1

			if can_move_there and rect(tile_x, tile_y, cell_width, cell_height, x, y) then
				state.current_location_x = tile_i
				state.current_location_y = tile_j
			end
		end
	end

	for index, value in ipairs(enemies) do
		local tile_i = value.x
		local tile_j = value.y

		if value.alive and state.current_location_x == tile_i and state.current_location_y == tile_j then
			battle_manager.start_battle(state, state.last_battle)
			battle_manager.put_player_into_battle(state)
			for i =1, 3 do
				local strong_enemy = battle_manager.new_actor(require "meta-actors.amogus", i, 1)
				battle_manager.add_actor_to_battle(state.last_battle, strong_enemy, false)
			end
			state.wandering = true
			state.enemy_pack = value
			state.set_scene(state, scenes.battle)
		end

	end
end