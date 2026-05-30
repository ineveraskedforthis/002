local battle_manager = require "fights._battle-system"
local scenes = require "scenes._ids"

---@class StoryOption
---@field text fun(state: GameState, actor: MetaActorWrapper): string
---@field effect fun(state: GameState, actor: MetaActorWrapper)

---@class StoryAtom
---@field text fun(state: GameState, actor: MetaActorWrapper): string
---@field options fun(state: GameState, actor: MetaActorWrapper): StoryOption[]

---@param state GameState
return function (state)
	---@type StoryAtom
	state.story_atoms["greeting"] = {
		text = function (state, actor)
			return "Greetings, traveller. How can I help you?"
		end,
		options = function (state, actor)
			---@type StoryOption
			local option_1 = {
				text = function (state, actor)
					return "Can I enter the city?"
				end,
				effect = function (state, actor)
					state.current_story_atom = "refusal"
				end
			}

			return {
				option_1
			}
		end
	}

	state.story_atoms["refusal"] = {
		text = function (state, actor)
			return "Of course not. You are not a citizen."
		end,
		options = function (state, actor)
			---@type StoryOption
			local option_1 = {
				text = function (state, actor)
					return "And if I will try it to do it anyway?"
				end,
				effect = function (state, actor)
					state.current_story_atom = "aggression"
				end
			}

			return {
				option_1
			}
		end
	}

	state.story_atoms["aggression"] = {
		text = function (state, actor)
			return "I will murder you and report the trespassing accident."
		end,
		options = function (atom_state, atom_actor)
			---@type StoryOption
			local option_1 = {
				text = function (state, actor)
					return "I am not so sure about it (Fight)"
				end,
				effect = function (state, actor)
					battle_manager.start_battle(state, state.last_battle)
					battle_manager.put_player_into_battle(state)
					local enemy = battle_manager.new_actor(actor.def, 1, 1)
					battle_manager.add_actor_to_battle(state.last_battle, enemy, false)
					state.set_scene(state, scenes.battle)
					-- current_story_atom = "???"
				end
			}

			return {
				option_1
			}
		end
	}

end

