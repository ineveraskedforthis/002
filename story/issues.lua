local battle_manager = require "fights._battle-system"
local scenes = require "scenes._ids"

--[[

Topic A: Want to sell X in city
Topic B: Can't enter the city
Topic C: Middleman is required

More abstractly,
Topic A: Want to sell X in M
Topic B: Can't enter M
Topic C: Need someone who can enter M and sell X there
Topic D: Waits nearby M

We can't discover the root of the issue/topic immediately:
it would be strange if we could ask "hey, do you need someone to sell stuff in the city for you?"

We want interactions to be like this:
We can talk about the obvious topic of "waiting nearby the city"
The merchant exposes some info about "can't enter the city" which unlocks a new dialog option asking about why he wants to enter the city
They respond with info about "want to sell cloth" and that they "need a middleman"
Several new topics appear: about cloth, prices of cloth and middleman

Basically it's a directed graph where every vertex
is a parametrised "topic" while edges are decided
by some internal logic of "topic" depending on parameters and game state.

For some topics, the edges could be redirected to generic "sorry, I can't talk about it" due to lack of trust?

--]]

---@enum SEVERITY
SEVERITY = {
	NONE = 0,
	MILD = 1,
	EXTREME = 2,
	LIFE_THREAT = 3
}

---@enum TOPIC_KIND
TOPIC_KIND = {
	MOVEMENT = 0,
	TALK = 1,
	UTILITY = 2,
	INFO = 3
}

---@class TopicParam
---@field is_actor boolean?
---@field is_location boolean?
---@field description string

---@class Topic
---@field severity SEVERITY
---@field name string
---@field kind TOPIC_KIND
---@field trigger_on_meeting_character fun(state : GameState, journal : Journal, object_index : number) : boolean
---@field params_description TopicParam[]
---@field text fun(state: GameState, journal : Journal, params : number[]): string
---@field effect fun(state: GameState, journal : Journal, params : number[])
---@field has_journal_note boolean
---@field has_journal_note_even_if_not_done boolean?
---@field journal_text fun(state: GameState, journal : Journal, params : number[], param_index): string
---@field repeatable boolean

---@class TopicInstance
---@field name string
---@field params number[]
---@field done boolean

---@param journal Journal
---@param topic Topic
function REGISTER_TOPIC(journal, topic)
	journal.topic_functors[topic.name] = topic
end

-- UTILITY TOPICS

---@type Topic
local back_to_action_choice = {
	severity = SEVERITY.NONE,
	kind = TOPIC_KIND.UTILITY,
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	effect = function (state, journal, params)
		state.options_state = OPTIONS_STATE.NONE
		state.current_dialog_actor = nil
	end,
	name = "UTILITY_back_to_action",
	params_description = {},
	text = function (state, journal, params)
		return "Back"
	end,
	repeatable = true,
	has_journal_note = false,
	journal_text = function (state, journal, params, param_index)
		return ""
	end
}

---@type Topic
local movement_choice = {
	severity = SEVERITY.NONE,
	kind = TOPIC_KIND.UTILITY,
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	effect = function (state, journal, params)
		state.options_state = OPTIONS_STATE.MOVE
	end,
	name = "UTILITY_move",
	params_description = {},
	text = function (state, journal, params)
		return "Go to ..."
	end,
	repeatable = true,
	has_journal_note = false,
	journal_text = function (state, journal, params, param_index)
		return ""
	end
}

---@type Topic
local talk_choice = {
	severity = SEVERITY.NONE,
	kind = TOPIC_KIND.UTILITY,
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	effect = function (state, journal, params)
		state.options_state = OPTIONS_STATE.TALK
	end,
	name = "UTILITY_talk",
	params_description = {},
	text = function (state, journal, params)
		return "Talk to ..."
	end,
	repeatable = true,
	has_journal_note = false,
	journal_text = function (state, journal, params, param_index)
		return ""
	end
}

---@type Topic
local talk_choice_2 = {
	severity = SEVERITY.NONE,
	kind = TOPIC_KIND.UTILITY,
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	effect = function (state, journal, params)
		local journal_object = journal.objects[params[1]]
		state.current_dialog_actor = journal_object.associated_actor
	end,
	text = function (state, journal, params)
		return string.format("Talk to %s", SHORT_DESCRIPTION(state, journal, journal.objects[params[1]]))
	end,
	name = "UTILITY_talk_select",
	params_description = {
		{
			description = "Who you are going to talk with",
			is_actor = true
		}
	},
	repeatable = true,
	has_journal_note = false,
	journal_text = function (state, journal, params, param_index)
		return ""
	end
}

-- NORMAL TOPICS

---@type Topic
local learn_name = {
	severity = SEVERITY.NONE,
	kind = TOPIC_KIND.TALK,
	name = "learn_name",
	trigger_on_meeting_character = function (state, journal, trigger_target)
		local journal_index = journal.actor_index_to_object_index[trigger_target]
		if journal.known_names[journal_index] then
			return false
		end
		return true
	end,
	params_description = {
		{
			description = "Person you want to learn the name of",
			is_actor = true
		}
	},
	effect = function (state, journal, params)
		local actor_journal_index = params[1]
		local actor_journal_object = journal.objects[actor_journal_index]
		local actor_object = state.playable_actors[actor_journal_object.associated_actor]
		local name = actor_object.def.name
		journal.known_names[actor_journal_index] = name
		state.current_text = "The name was recorded into the journal."
	end,
	text = function (state, journal, params)
		return "What is your name?"
	end,
	repeatable = false,
	has_journal_note = true,
	journal_text = function (state, journal, params, param_index)
		return string.format("%s has told me their name", journal.known_names[params[param_index]])
	end
}

---@type Topic
local buy_commodity = {
	severity =SEVERITY.NONE,
	name = "buy_commodity",
	trigger_on_meeting_character = function (state, journal, trigger_target)
		return false
	end,
	kind = TOPIC_KIND.TALK,
	params_description = {
		{
			is_actor = true,
			description = "Who is selling"
		},
		{
			is_actor = false,
			description = "Sold commodity"
		},
		{
			is_actor = false,
			description = "Price"
		}
	},
	effect = function (state, journal, params)

	end,
	text =function (state, journal, params)
		local commodity_object = journal.objects[params[2]]
		return string.format("Buy %s for %s", COMMODITY_STRING(commodity_object.commodity), params[3])
	end,
	repeatable = true,
	has_journal_note = true,
	has_journal_note_even_if_not_done = true,
	journal_text = function (state, journal, params, param_index)
		if param_index == 1 then
			return string.format("They sell %s", SHORT_DESCRIPTION(state, journal, journal.objects[params[2]]))
		elseif  param_index == 2 then
			return string.format("Sold by %s", SHORT_DESCRIPTION(state, journal, journal.objects[params[1]]))
		end

		return "???"
	end
}

---@type Topic
local wares = {
	severity =SEVERITY.NONE,
	name = "learn_wares",
	trigger_on_meeting_character = function (state, journal, trigger_target)
		local actor = state.playable_actors[trigger_target]
		if #actor.wares == 0 then
			return false
		end
		return true
	end,
	kind = TOPIC_KIND.TALK,
	params_description = {
		{
			is_actor = true,
			description = "Seller"
		}
	},
	effect = function (state, journal, param)
		local actor_journal_index = param[1]
		local actor_journal_object = journal.objects[actor_journal_index]
		local actor_index = actor_journal_object.associated_actor
		local actor_object = state.playable_actors[actor_index]
		for index, value in ipairs(actor_object.wares) do
			local commodity_journal_index = ENCOUNTER_COMMODITY(journal, value.commodity)
			NEW_TOPIC_INSTANCE(state, journal, "buy_commodity",  {actor_journal_index, commodity_journal_index})
		end
	end,
	text = function (state, journal, param)
		return "What are you selling here?"
	end,
	repeatable = false,
	has_journal_note = true,
	journal_text = function (state, journal, params, param_index)
		return string.format("They can sell something to me.")
	end
}

---@type Topic
local enter_the_city = {
	severity = SEVERITY.NONE,
	kind = TOPIC_KIND.TALK,
	name = "enter_the_city",
	params_description = {
		{
			description = "Guard",
			is_actor = true
		}
	},
	repeatable = true,
	trigger_on_meeting_character = function (state, journal, actor_index)
		-- local actor_object = state.playable_actors[actor_index]
		if state.current_guard == actor_index then
			return true
		end
		return false
	end,
	text = function (state, journal, params)
		return "Can I enter the city?"
	end,
	effect = function (state, journal, params)
		state.current_text = "Of course not. You are not a citizen."
		NEW_TOPIC_INSTANCE(state, journal, "enter_the_city_aggression", {
			params[1],
			journal.location_index_to_object_index[LOCATION.AT_CITY_GATES],
			journal.location_index_to_object_index[LOCATION.CITY]
		})
		NEW_TOPIC_INSTANCE(state, journal, "enter_the_city_info", params)
	end,
	has_journal_note = true,
	journal_text = function (state, journal, params, param_index)
		return string.format("They don't allow me to enter the city.")
	end
}

---@type Topic
local enter_the_city_info = {
	severity = SEVERITY.NONE,
	kind = TOPIC_KIND.TALK,
	name = "enter_the_city_info",
	params_description = {
		{
			description = "Guard",
			is_actor = true
		}
	},
	repeatable = false,
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	text = function (state, journal, params)
		return "So, who can enter the city?"
	end,
	effect = function (state, journal, params)
		local location = journal.objects[params[1]]
		local group = journal.objects[params[2]]
		state.current_text = "Knights, lords and citizens. Esteemed guests as well."

		LEARN_ABOUT_LOCATION(journal, LOCATION.CITY)
		LEARN_ABOUT_SOCIAL_STATUS(journal, SOCIAL_STATUS.CITIZEN)
		LEARN_ABOUT_SOCIAL_STATUS(journal, SOCIAL_STATUS.KNIGHT)
		LEARN_ABOUT_SOCIAL_STATUS(journal, SOCIAL_STATUS.LORD)
		LEARN_ABOUT_SOCIAL_STATUS(journal, SOCIAL_STATUS.MERCHANT)

		NEW_TOPIC_INSTANCE(state, journal, "enter_location_info", {
			journal.location_index_to_object_index[LOCATION.AT_CITY_GATES],
			journal.location_index_to_object_index[LOCATION.CITY],
			journal.social_group_to_object_index[SOCIAL_STATUS.CITIZEN]
		})
		NEW_TOPIC_INSTANCE(state, journal, "enter_location_info", {
			journal.location_index_to_object_index[LOCATION.AT_CITY_GATES],
			journal.location_index_to_object_index[LOCATION.CITY],
			journal.social_group_to_object_index[SOCIAL_STATUS.KNIGHT]
		})
		NEW_TOPIC_INSTANCE(state, journal, "enter_location_info", {
			journal.location_index_to_object_index[LOCATION.AT_CITY_GATES],
			journal.location_index_to_object_index[LOCATION.CITY],
			journal.social_group_to_object_index[SOCIAL_STATUS.LORD]
		})
		NEW_TOPIC_INSTANCE(state, journal, "enter_location_info", {
			journal.location_index_to_object_index[LOCATION.AT_CITY_GATES],
			journal.location_index_to_object_index[LOCATION.CITY],
			journal.social_group_to_object_index[SOCIAL_STATUS.MERCHANT]
		})
	end,
	has_journal_note = false,
	journal_text = function (state, journal, params, param_index)
		return ""
	end
}

---@type Topic
local enter_location_info = {
	name = "enter_location_info",
	kind = TOPIC_KIND.INFO,
	severity =  SEVERITY.NONE,
	params_description = {
		{
			description = "From",
			is_location = true
		},
		{
			description = "To",
			is_location = true
		},
		{
			description = "Allowed class"
		}
	},
	has_journal_note = true,
	has_journal_note_even_if_not_done = true,
	repeatable = false,
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	effect = function (state, journal, params)

	end,
	journal_text = function (state, journal, params, param_index)
		if param_index == 1 then
			return string.format(
				"Members of %s group are allowed to move to %s from here",
				SHORT_DESCRIPTION(state, journal, journal.objects[params[3]]),
				SHORT_DESCRIPTION(state, journal, journal.objects[params[2]])
			)
		end
		if param_index == 2 then
			return string.format(
				"Members of %s group are allowed to move here from %s",
				SHORT_DESCRIPTION(state, journal, journal.objects[params[3]]),
				SHORT_DESCRIPTION(state, journal, journal.objects[params[1]])
			)
		end
		return ""
	end,
	text = function (state, journal, params)
		return ""
	end
}

---@type Topic
local enter_the_city_aggression = {
	severity = SEVERITY.NONE,
	kind = TOPIC_KIND.TALK,
	name = "enter_the_city_aggression",
	params_description = {
		{
			description = "Guard",
			is_actor = true
		},
		{
			description = "From",
			is_location = true
		},
		{
			description = "To",
			is_location = true
		},
	},
	repeatable = false,
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	text = function (state, journal, params)
		return "And if I will try it to do it anyway?"
	end,
	effect = function (state, journal, params)
		state.current_text = "I will murder you and report the trespassing accident."
		NEW_TOPIC_INSTANCE(state, journal, "enter_the_city_aggression_attack", params)
	end,
	has_journal_note = true,
	journal_text = function (state, journal, params, param_index)
		local who = journal.objects[params[1]]
		local from_location = journal.objects[params[2]]
		local target_location = journal.objects[params[3]]
		if param_index == 1 then
			return string.format(
				"They will murder me if I will attempt to enter %s",
				SHORT_DESCRIPTION(state, journal, target_location)
			)
		end
		if param_index == 2 then
			return string.format(
				"%s will murder me if I will attempt to enter %s location",
				SHORT_DESCRIPTION(state, journal, who),
				SHORT_DESCRIPTION(state, journal, target_location)
			)
		end
		return ""
	end
}

---@type Topic
local enter_the_city_aggression_attack = {
	severity = SEVERITY.NONE,
	kind = TOPIC_KIND.TALK,
	name = "enter_the_city_aggression_attack",
	params_description = {
		{
			description = "Guard",
			is_actor = true
		}
	},
	repeatable = false,
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	text = function (state, journal, params)
		return "(Attack the guard)"
	end,
	effect = function (state, journal, params)
		local journal_object = journal.objects[params[1]]
		local actor_index = journal_object.associated_actor
		local actor_object = state.playable_actors[actor_index]

		state.current_text = ""
		battle_manager.start_battle(state, state.last_battle)
		battle_manager.put_player_into_battle(state)
		local enemy = battle_manager.new_actor(actor_object.def, 1, 1)
		-- battle_manager.add_actor_to_battle(state.last_battle, enemy, false)

		do
			local enemy = require "meta-actors.creation"
			battle_manager.add_actor_to_battle(state.last_battle, battle_manager.new_actor(enemy, 1, 1), false)
			battle_manager.add_actor_to_battle(state.last_battle, battle_manager.new_actor(enemy, 2, 1), false)
			battle_manager.add_actor_to_battle(state.last_battle, battle_manager.new_actor(enemy, 3, 1), false)
		end


		state.set_scene(state, scenes.battle)
	end,
	has_journal_note = true,
	journal_text = function (state, journal, params, param_index)
		-- local location = journal.objects[params[1]]
		-- local group = journal.objects[params[2]]
		return string.format("I have attacked them")
	end
}

---@param journal Journal
return function (journal)
	print("LOAD TOPICS")
	journal.topic_functors = {}
	REGISTER_TOPIC(journal, learn_name)
	REGISTER_TOPIC(journal, wares)
	REGISTER_TOPIC(journal, back_to_action_choice)
	REGISTER_TOPIC(journal, talk_choice)
	REGISTER_TOPIC(journal, talk_choice_2)
	REGISTER_TOPIC(journal, movement_choice)
	REGISTER_TOPIC(journal, buy_commodity)
	REGISTER_TOPIC(journal, enter_the_city)
	REGISTER_TOPIC(journal, enter_the_city_info)
	REGISTER_TOPIC(journal, enter_the_city_aggression)
	REGISTER_TOPIC(journal, enter_the_city_aggression_attack)
	REGISTER_TOPIC(journal, enter_location_info)
end