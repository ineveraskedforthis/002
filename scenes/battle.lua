local manager = require "scenes._manager"
local style = require "ui._style"

local ids = require "scenes._ids"
local id = ids.battle
local def = manager.get(id)

local rect = require "ui.rect"

local effects_manager = require "effects._manager"
local battle_manager = require "fights._battle-system"
local main_render = require "fights.battle-render"
local battle_loader = require "fights._loader"

local BATTLE_SYSTEM_RESPONSE = require "fights._response"
local learn_skill = require "effects-campaign.learn-skills"


local battle_actor_widget = require "ui.actor"

local await_input = false

function def.update(state, journal, dt)
	dt = dt * 10

	local battle = state.last_battle

	for key, value in ipairs(battle.actors) do
		if (value.visible) then
			battle_actor_widget.update(state, battle, dt)
		end
	end


	local res = battle_manager.update_battle_state(state, battle, dt)
	if res == BATTLE_SYSTEM_RESPONSE.AWAIT_USER_INPUT then
		await_input = true
	else
		await_input = false
	end
	if res == BATTLE_SYSTEM_RESPONSE.REQUEST_NEW_WAVE then
		print("new wave")
		battle.wave = battle.wave + 1
		local battle_in_progress = battle_loader(
			state, state.current_scripted_fight, false
		)
		for index, value in ipairs(state.playable_actors) do
			if (value.unlocked) then
				learn_skill(value)
			end
		end
		if not battle_in_progress then
			battle_manager.stop_battle(state, battle)
			if (state.enemy_pack) then
				state.enemy_pack.alive = false
				ON_BATTLE_END(state, BATTLE_RESULT.VICTORY)
			else
				ON_BATTLE_END(state, BATTLE_RESULT.VICTORY)
			end
		else
			battle_manager.begin_new_wave(state, battle)
		end
	end
	if res == BATTLE_SYSTEM_RESPONSE.BATTLE_WON then
		print("win")
		battle_manager.stop_battle(state, battle)
		for index, value in ipairs(state.playable_actors) do
			if (value.unlocked) then
				learn_skill(value)
			end
		end
		if (state.enemy_pack) then
			state.enemy_pack.alive = false
			ON_BATTLE_END(state, BATTLE_RESULT.VICTORY)
		else
			ON_BATTLE_END(state, BATTLE_RESULT.VICTORY)
		end
	end
	if res == BATTLE_SYSTEM_RESPONSE.BATTLE_LOST then
		print("lose")
		battle_manager.stop_battle(state, battle)
		if state.die_on_battle_lost then
			state.set_scene(state, ids.game_over)
		else
			ON_BATTLE_END(state, BATTLE_RESULT.DEFEAT)
		end
	end
end


function def.on_click(state, journal, x, y)
	local battle = state.last_battle
	local offset_x = 150
	local offset_y = 50

	for key, value in ipairs(battle.actors) do
		if battle.actors[key].team == 1 and battle.actors[key].HP > 0 and battle.actors[key].visible then
			local rx, ry, w, h = battle_actor_widget.get_rect(state, battle, value.x, value.y, value)
			if (rect(rx, ry, w, h, x, y)) then
				battle.selected_actor = value
			end
		end
	end
	skills_panel.on_click(state, battle, x, y)
end



function def.render(state, journal)
	style.basic_bg_color()
	style.basic_element_color()

	main_render(state, state.last_battle)

	local effect = state.last_battle.effects_queue[1]
	if effect then
		local def = effects_manager.get(effect.def)
		def.scene_render(
			state, state.last_battle,
			effect.time_passed,
			effect.origin,
			effect.target,
			effect.data
		)
		return
	end


	if await_input then
		style.default_font()
		love.graphics.print("YOUR TURN", 150, 10)
	end

end