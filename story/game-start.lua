local battle_manager = require "fights._battle-system"
local scenes = require "scenes._ids"


---@param state GameState
---@param journal Journal
return function (state, journal)
	-- -@type StoryAtom

	state.story_atoms["game_start"] = {
		text = function (state, actor)
			return "Finally, you have arrived to the gates. A lone watchman guards the gates while a small caravan stays nearby."
		end,

		options = function (state, actor)
			---@type StoryOption
			local option_approach_city = {
				text = function (state, actor)
					return "Approach the guard"
				end,
				effect = function (state, actor)
					SET_STORY_ATOM(state, "city_guard_greeting")
					local guard = state.current_guard
					print("current guard: " .. tostring(guard))
					state.current_dialog_actor = state.available_guards[guard]
					print("current guard character: " .. tostring(state.current_dialog_actor))
					MEET_ACTOR(state, journal, state.current_dialog_actor, state.playable_actors[state.main_character].location)
					journal.objects[journal.actor_index_to_object_index[state.current_dialog_actor]].occupation = OCCUPATION_TYPE.GUARD
				end
			}

			---@type StoryOption
			local option_approach_caravan = {
				text = function(state, actor)
					return "Visit the caravan master"
				end,
				effect = function (state, actor)
					SET_STORY_ATOM(state, "caravan_master_greeting")
					state.current_dialog_actor = state.caravan_master
					MEET_ACTOR(state, journal, state.current_dialog_actor, state.playable_actors[state.main_character].location)
				end

			}

			return {
				option_approach_city,
				option_approach_caravan
			}
		end
	}

	---@type StoryOption
	local to_master_atom_travel =  {
		text = function (state, actor)
			return "I will travel to"
		end,
		effect = function (state, actor)
			SET_STORY_ATOM(state, "master_atom_travel")
		end
	}

	local to_master_atom_talk = {
		text = function (state, actor)
			return "I will talk to"
		end,
		effect = function (state, actor)
			SET_STORY_ATOM(state, "master_atom_talk")
		end
	}

	local to_master_atom = {
		text = function (state, actor)
			return "I will consider doing something else"
		end,
		effect = function (state, actor)
			SET_STORY_ATOM(state, "master_atom")
		end
	}

	state.story_atoms["master_atom"] = {
		options = function (state, actor)
			return {
				to_master_atom_travel,
				to_master_atom_talk
			}
		end,
		text = function (state, actor)
			return "I pondering about my further actions"
		end
	}

	state.story_atoms["master_atom_travel"] = {
		options = function (state, actor)
			return {
				to_master_atom
			}
		end,
		text = function (state, actor)
			return "Where will I go?"
		end
	}

	state.story_atoms["master_atom_talk"] = {
		options = function (state, actor)
			return {
				to_master_atom
			}
		end,
		text = function (state, actor)
			return "Maybe I can talk to"
		end
	}

	---@type StoryOption
	local have_to_go_option = {
		text = function (state, actor)
			return "I have to go"
		end,
		effect = function (state, actor)
			SET_STORY_ATOM(state, "master_atom")
			state.current_dialog_actor = nil
		end
	}

	---@type StoryOption
	local caravan_trade_option =  {
		text = function (state, actor)
			return "What can you offer?"
		end,
		effect = function (state, actor)
			SET_STORY_ATOM(state, "caravan_master_trade")
		end
	}

	local caravan_talk_option = {
		text = function (state, actor)
			return "I want to ask you something..."
		end,
		effect = function (state, actor)
			SET_STORY_ATOM(state, "caravan_master_talk_information")
		end
	}

	---@type StoryAtom
	state.story_atoms["caravan_master_greeting"] = {
		text = function (state, actor)
			return "Greetings, traveller. I am a humble master of this caravan. Are you interested in my wares?"
		end,
		options = function (state, actor)
			return {
				caravan_trade_option,
				caravan_talk_option,
				have_to_go_option
			}
		end
	}

	---@type StoryAtom
	state.story_atoms["caravan_master_talk"] = {
		text = function (state, actor)
			return "Anything else?"
		end,
		options = function (state, actor)
			return {
				caravan_trade_option,
				caravan_talk_option,
				have_to_go_option
			}
		end
	}

	---@type StoryOption
	local caravan_reason_for_standing_outside_the_city_option =  {
		text = function (state, actor)
			return "Why is your caravan standing here, at the gates?"
		end,
		effect = function (state, actor)
			SET_STORY_ATOM(state, "caravan_master_information_no_access")
		end
	}

	---@type StoryOption
	local caravan_stop_discussion_option =  {
		text = function (state, actor)
			return "That's all what I wanted to know"
		end,
		effect = function (state, actor)
			SET_STORY_ATOM(state, "caravan_master_talk")
		end
	}

	---@type StoryOption
	local caravan_merchant_name =  {
		text = function (state, actor)
			return "What is your name?"
		end,
		effect = function (state, actor)
			SET_STORY_ATOM(state, "caravan_master_name")
		end
	}

	local merchant_info_options = function (state, actor)
		local options = {}
		if not journal.flags.asked_merchant_about_his_situation then
			table.insert(options, caravan_reason_for_standing_outside_the_city_option)
		end
		if journal.known_names[journal.actor_index_to_object_index[state.current_dialog_actor]] == nil then
			table.insert(options, caravan_merchant_name)
		end
		table.insert(options, caravan_stop_discussion_option)
		return options
	end

	---@type StoryAtom
	state.story_atoms["caravan_master_talk_information"] = {
		text = function (state, actor)
			return "Hmm?"
		end,
		options = merchant_info_options
	}

	---@type StoryAtom
	state.story_atoms["caravan_master_information_no_access"] = {
		initial_effect = function (state, actor)
			LEARN_LOCATION_ACCESS(
				journal, SOCIAL_STATUS.CITIZEN, LOCATION.CITY,
				journal.actor_index_to_object_index[state.current_dialog_actor]
			)
			LEARN_LOCATION_ACCESS(journal, SOCIAL_STATUS.LORD, LOCATION.CITY,
				journal.actor_index_to_object_index[state.current_dialog_actor]
			)
			LEARN_LOCATION_ACCESS(journal, SOCIAL_STATUS.KNIGHT, LOCATION.CITY,
				journal.actor_index_to_object_index[state.current_dialog_actor]
			)
			LEARN_LOCATION_ACCESS(journal, SOCIAL_STATUS.MERCHANT, LOCATION.CITY,
				journal.actor_index_to_object_index[state.current_dialog_actor]
			)
			journal.flags.asked_merchant_about_his_situation = true
		end,
		text = function (state, actor)
			return "I can't enter the city. Only citizens, knights and lords have the right to visit it. And only members of the Merchant Guild are allowed to trade inside."
		end,
		options = merchant_info_options
	}

	---@type StoryAtom
	state.story_atoms["caravan_master_name"] = {
		initial_effect = function (state, actor)
			LEARN_NAME(state, journal, state.current_dialog_actor)
		end,
		text = function (state, actor)
			return "The name was recorded in journal."
		end,
		options = merchant_info_options
	}



	state.story_atoms["caravan_master_trade"] = {
		text = function (state, actor)
			return "I sell luxury cloth and various trinkets."
		end,
		options = function (state, actor)
			---@type StoryOption
			local option_1 = {
				text = function (state, actor)
					return "Buy luxury cloth (10 coins)."
				end,
				effect = function (state, actor)
					SET_STORY_ATOM(state, "caravan_master_trade")
					error("not implemented")
				end
			}

			---@type StoryOption
			local option_2 = {
				text = function (state, actor)
					return "Let's talk about something else."
				end,
				effect = function (state, actor)
					SET_STORY_ATOM(state, "caravan_master_talk")
				end
			}



			return {
				option_1,
				option_2
			}
		end
	}

	---@type StoryAtom
	state.story_atoms["city_guard_greeting"] = {
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
					SET_STORY_ATOM(state, "city_enter_refusal")
				end
			}

			---@type StoryOption
			local option_2 = {
				text = function (state, actor)
					return "I want to ask something"
				end,
				effect = function (state, actor)
					SET_STORY_ATOM(state, "city_guard_talk")
				end
			}

			return {
				option_1,
				option_2,
				have_to_go_option
			}
		end
	}

	state.story_atoms["city_enter_refusal"] = {
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
					SET_STORY_ATOM(state, "city_enter_refusal_aggression")
					actor.trust = actor.trust - 10
				end
			}

			return {
				option_1
			}
		end
	}

	state.story_atoms["city_enter_refusal_aggression"] = {
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

			---@type StoryOption
			local option_2 = {
				text = function (state, actor)
					return "Uh, okay, sorry for asking."
				end,
				effect = function (state, actor)
					SET_STORY_ATOM(state, "city_guard_talk")
				end
			}

			return {
				option_1, option_2
			}
		end
	}

end

