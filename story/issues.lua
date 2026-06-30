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
	INFO = 3,
	ATTACK = 4
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
---@field option_text fun(state: GameState, journal : Journal, params : number[], param_index: number): string
---@field has_option fun(state: GameState, journal : Journal, params : number[], param_index: number): boolean
---@field effect fun(state: GameState, journal : Journal, params : number[], param_index: number)
---@field has_journal_note boolean
---@field has_journal_note_even_if_not_done boolean?
---@field journal_text fun(state: GameState, journal : Journal, params : number[], param_index: number): string
---@field effect_on_parameter_actor_death fun(state: GameState, journal : Journal, params : number[], param_index)
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
	option_text = function (state, journal, params)
		return "Back"
	end,
	repeatable = true,
	has_journal_note = false,
	journal_text = function (state, journal, params, param_index)
		return ""
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

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
	option_text = function (state, journal, params)
		return "Go to ..."
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	repeatable = true,
	has_journal_note = false,
	journal_text = function (state, journal, params, param_index)
		return ""
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

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
	option_text = function (state, journal, params)
		return "Talk to ..."
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	repeatable = true,
	has_journal_note = false,
	journal_text = function (state, journal, params, param_index)
		return ""
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

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
	option_text = function (state, journal, params)
		return string.format("Talk to %s", SHORT_DESCRIPTION(state, journal, journal.objects[params[1]]))
	end,
	has_option = function (state, journal, params, param_index)
		return true
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
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

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
	option_text = function (state, journal, params)
		return "What is your name?"
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	repeatable = false,
	has_journal_note = true,
	journal_text = function (state, journal, params, param_index)
		return string.format("%s has told me their name", journal.known_names[params[param_index]])
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

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
	option_text =function (state, journal, params)
		local commodity_object = journal.objects[params[2]]
		return string.format("Buy %s for %s", COMMODITY_STRING(commodity_object.commodity), params[3])
	end,
	has_option = function (state, journal, params, param_index)
		return true
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
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

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
			NEW_TOPIC_INSTANCE(state, journal, "buy_commodity",  {actor_journal_index, commodity_journal_index, value.price})
		end
	end,
	option_text = function (state, journal, param)
		return "What are you selling here?"
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	repeatable = false,
	has_journal_note = true,
	journal_text = function (state, journal, params, param_index)
		return string.format("They can sell something to me.")
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

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
	option_text = function (state, journal, params)
		return "Can I enter the city?"
	end,
	has_option = function (state, journal, params, param_index)
		return true
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
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

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
	option_text = function (state, journal, params)
		return "So, who can enter the city?"
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	effect = function (state, journal, params)
		local location = journal.objects[params[1]]
		local group = journal.objects[params[2]]
		state.current_text = "Knights, lords and citizens can enter. Esteemed guests as well."

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
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

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
	option_text = function (state, journal, params)
		return ""
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

	end
}

---@type Topic
local job_suggestion_guard = {
	severity = SEVERITY.NONE,
	kind = TOPIC_KIND.TALK,
	name = "job_suggestion_guard",
	params_description = {
		{
			description = "Guard",
			is_actor = true
		}
	},
	repeatable = false,
	trigger_on_meeting_character = function (state, journal, object_index)
		if state.current_guard == object_index then
			return true
		end
		return false
	end,
	option_text = function (state, journal, params)
		return "Do you have any jobs for me?"
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	effect = function (state, journal, params)
		state.current_text = "No. Get lost."
		state.playable_actors[state.current_guard].trust = state.playable_actors[state.current_guard].trust - 10
	end,
	has_journal_note = true,
	journal_text = function (state, journal, params, param_index)
		return "They don't have any jobs for me."
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

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
	option_text = function (state, journal, params)
		return "And if I will try it to do it anyway?"
	end,
	has_option = function (state, journal, params, param_index)
		return true
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
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

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
	option_text = function (state, journal, params)
		return "(Attack the guard)"
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	effect = function (state, journal, params)
		local journal_object = journal.objects[params[1]]
		local actor_index = journal_object.associated_actor
		local actor_object = state.playable_actors[actor_index]

		state.current_text = ""
		state.die_on_battle_lost = true
		battle_manager.start_battle(state, state.last_battle)
		battle_manager.put_player_into_battle(state)
		local enemy = battle_manager.new_actor(actor_object.def, 1, 1)
		battle_manager.add_actor_to_battle(state.last_battle, enemy, false)

		state.set_scene(state, scenes.battle)
	end,
	has_journal_note = true,
	journal_text = function (state, journal, params, param_index)
		-- local location = journal.objects[params[1]]
		-- local group = journal.objects[params[2]]
		return string.format("I have attacked them")
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

	end
}

---@type Topic
local caravan_at_gates = {
	severity = SEVERITY.MILD,
	has_journal_note = true,
	kind = TOPIC_KIND.TALK,
	name = "caravan_at_gates",
	repeatable = false,
	params_description = {
		{
			description = "Trader",
			is_actor = true
		}
	},
	trigger_on_meeting_character = function (state, journal, object_index)
		return object_index == state.caravan_master
	end,
	effect = function (state, journal, params)
		state.current_text = "They would not let me into the city... And even if I could enter, I don't have the license for trade."
		NEW_TOPIC_INSTANCE(state, journal, "caravan_at_gates_issue", params)
		NEW_TOPIC_INSTANCE(state, journal, "caravan_at_gates_job", params)
	end,
	journal_text = function (state, journal, params, param_index)
		return "They are unable to enter the city"
	end,
	option_text = function (state, journal, params)
		return "Why is your caravan standing here, at the gates?"
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

	end
}

---@type Topic
local caravan_at_gates_issue = {
	severity = SEVERITY.MILD,
	has_journal_note = true,
	kind = TOPIC_KIND.TALK,
	name = "caravan_at_gates_issue",
	repeatable = false,
	params_description = {
		{
			description = "Trader",
			is_actor = true
		}
	},
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	effect = function (state, journal, params)
		state.current_text = "I want to sell my high quality cloth there. But I need a middleman who has connections with local guilds. For now I am just waiting there, but if I will not find a fitting person, I will just leave."
	end,
	journal_text = function (state, journal, params, param_index)
		return "They need a middleman who has connections in the city"
	end,
	option_text = function (state, journal, params)
		return "So, what are you going to do?"
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

	end
}

---@type Topic
local caravan_at_gates_job = {
	severity = SEVERITY.MILD,
	has_journal_note = false,
	kind = TOPIC_KIND.TALK,
	name = "caravan_at_gates_job",
	repeatable = false,
	params_description = {
		{
			description = "Trader",
			is_actor = true
		}
	},
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	effect = function (state, journal, params)
		state.current_text = "I don't think you can help me personally, but folks in the forest could use some help."
		local forest = LEARN_ABOUT_LOCATION(journal, LOCATION.FOREST_VILLAGE, params[1])
		local gates = LEARN_ABOUT_LOCATION(journal, LOCATION.AT_CITY_GATES, params[1])
		NEW_TOPIC_INSTANCE(state, journal, "travel", {forest, gates})
		NEW_TOPIC_INSTANCE(state, journal, "travel", {gates, forest})

		local village_elder = MEET_ACTOR(state, journal, state.village_elder, LOCATION.FOREST_VILLAGE)

		NEW_TOPIC_INSTANCE(state, journal, "village_issues_introduction", {forest, village_elder})
	end,
	journal_text = function (state, journal, params, param_index)
		return "They told me that people in the forest could use some help."
	end,
	option_text = function (state, journal, params)
		return "Do you need any help?"
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

	end
}

---@type Topic
local village_issues_introduction = {
	severity = SEVERITY.MILD,
	has_journal_note = true,
	kind = TOPIC_KIND.TALK,
	name = "village_issues_introduction",
	repeatable = false,
	params_description = {
		{
			description = "Village",
			is_location = true
		},
		{
			description = "Elder",
			is_actor = true
		}
	},
	effect = function (state, journal, params)
		state.current_text = "Wolves. A lot of wolves. We need someone to get rid of them. I am too old to do it myself."
		local village = LEARN_ABOUT_LOCATION(journal, LOCATION.FOREST_VILLAGE, params[2])
		local village_area = LEARN_ABOUT_LOCATION(journal, LOCATION.FOREST_VILLAGE_NEIGHBOURHOOD, params[2])
		NEW_TOPIC_INSTANCE(state, journal, "travel", {village, village_area})
		NEW_TOPIC_INSTANCE(state, journal, "travel", {village_area, village})

		NEW_TOPIC_INSTANCE(state, journal, "attack_wolves", {village_area})
	end,
	journal_text =function (state, journal, params, param_index)
		if param_index == 1 then
			return string.format("Area around the village is plagued with wolves.", SHORT_DESCRIPTION_INDEX(state, journal, params[param_index]))
		else
			return string.format("They asked me to get rid of wolves around the village.")
		end
	end,
	option_text = function (state, journal, params)
		return "Are there any issues in the village?"
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	trigger_on_meeting_character =function (state, journal, object_index)
		return false
	end,
	has_journal_note_even_if_not_done = false,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

	end
}



---@type Topic
local travel = {
	severity = SEVERITY.NONE,
	has_journal_note = true,
	kind = TOPIC_KIND.MOVEMENT,
	name = "travel",
	repeatable = true,
	has_journal_note_even_if_not_done = true,
	params_description = {
		{
			description = "From",
			is_location = true
		},
		{
			description = "To",
			is_location = true
		}
	},
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	effect =function (state, journal, params)
		local from = journal.objects[params[1]].location
		local to = journal.objects[params[2]].location
		print(from, LOCATION.AT_CITY_GATES)
		print(to, LOCATION.CITY)

		VISIT_JOURNAL_LOCATION(state, journal, params[2])

		if (from == LOCATION.AT_CITY_GATES) and (to == LOCATION.CITY) then
			state.die_on_battle_lost = true
			battle_manager.start_battle(state, state.last_battle)
			battle_manager.put_player_into_battle(state)
			local guard = state.playable_actors[state.current_guard]
			local enemy = battle_manager.new_actor(guard.def, 1, 1)
			battle_manager.add_actor_to_battle(state.last_battle, enemy, false)
			state.set_scene(state, scenes.battle)
		end

		if (from == LOCATION.FOREST_VILLAGE) and (to == LOCATION.ESTATE_LORD_B_GUARDHOUSE_NEAR_FOREST) then
			state.die_on_battle_lost = true
			battle_manager.start_battle(state, state.last_battle)
			battle_manager.put_player_into_battle(state)
			local guard = state.playable_actors[state.forest_guard]
			local enemy = battle_manager.new_actor(guard.def, 1, 1)
			battle_manager.add_actor_to_battle(state.last_battle, enemy, false)
			state.set_scene(state, scenes.battle)

			KILL(state, journal, state.forest_guard)
		end
		state.current_text = string.format("You have arrived to %s", SHORT_DESCRIPTION(state, journal, journal.objects[params[2]]))
		state.current_time = state.current_time + 1
	end,
	journal_text = function (state, journal, params, param_index)
		if param_index == 1 then
			return string.format("I can travel to %s.", SHORT_DESCRIPTION(state, journal, journal.objects[params[2]]))
		else
			return string.format("I can travel here from %s.", SHORT_DESCRIPTION(state, journal, journal.objects[params[1]]))
		end
	end,
	option_text = function (state, journal, params)
		return string.format("Travel to the %s", SHORT_DESCRIPTION_INDEX(state, journal, params[2]))
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

	end
}


---@type Topic
local attack_wolves = {
	severity = SEVERITY.MILD,
	has_journal_note = true,
	kind = TOPIC_KIND.ATTACK,
	name = "attack_wolves",
	repeatable = false,
	has_journal_note_even_if_not_done = false,

	effect = function (state, journal, params)
		state.die_on_battle_lost = true

		journal.new_topic_on_battle_won = {
			done = false,
			name = "attack_wolves_success",
			params = {
				journal.actor_index_to_object_index[state.village_elder]
			}
		}

		state.current_text = ""
		battle_manager.start_battle(state, state.last_battle)
		battle_manager.put_player_into_battle(state)

		local enemy = require "meta-actors.wolf"
		battle_manager.add_actor_to_battle(state.last_battle, battle_manager.new_actor(enemy, 1, 1), false)
		battle_manager.add_actor_to_battle(state.last_battle, battle_manager.new_actor(enemy, 2, 1), false)
		battle_manager.add_actor_to_battle(state.last_battle, battle_manager.new_actor(enemy, 3, 1), false)

		state.set_scene(state, scenes.battle)
	end,
	journal_text = function (state, journal, params, param_index)
		return "I was fighting wolves here"
	end,
	params_description = {
		{
			description = "Location",
			is_location = true
		}
	},
	option_text = function (state, journal, params)
		return "Attack wolves"
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

	end
}

---@type Topic
local attack_wolves_success = {
	severity = SEVERITY.MILD,
	has_journal_note = true,
	kind = TOPIC_KIND.TALK,
	name = "attack_wolves_success",
	repeatable = false,
	has_journal_note_even_if_not_done = false,
	effect =function (state, journal, params)
		state.playable_actors[state.village_elder].trust = state.playable_actors[state.village_elder].trust + 20
		state.current_text = "Thank you. Sadly, we can't repay you with money, shelter or food, but I can provide you with blessing."
		NEW_TOPIC_INSTANCE(state, journal, "swamp_blessing_start", params)
	end,
	journal_text =function (state, journal, params, param_index)
		return "They are grateful for help but could not offer anything except a blessing."
	end,
	params_description = {
		{
			description = "Village elder",
			is_actor = true
		}
	},
	option_text = function (state, journal, params)
		return "I have defeated the wolves."
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

	end
}

---@type Topic
local swamp_blessing_start = {
	severity = SEVERITY.NONE,
	has_journal_note = true,
	kind = TOPIC_KIND.TALK,
	name = "swamp_blessing_start",
	repeatable = false,
	has_journal_note_even_if_not_done = false,
	effect =function (state, journal, params)
		state.playable_actors[state.village_elder].trust = state.playable_actors[state.village_elder].trust + 20
		state.current_text = "To get the blessing, go to swamps. Kill the shadows."
		local village = LEARN_ABOUT_LOCATION(journal, LOCATION.FOREST_VILLAGE, params[1])
		local swamp = LEARN_ABOUT_LOCATION(journal, LOCATION.FOREST_VILLAGE_SWAMP, params[1])
		NEW_TOPIC_INSTANCE(state, journal, "travel", {village, swamp})
		NEW_TOPIC_INSTANCE(state, journal, "travel", {swamp, village})

		NEW_TOPIC_INSTANCE(state, journal, "swamp_blessing", {swamp})
	end,
	journal_text =function (state, journal, params, param_index)
		return "They told me that to get a blessing, I have to kill shadows which live at swamps."
	end,
	params_description = {
		{
			description = "Village elder",
			is_actor = true
		}
	},
	option_text = function (state, journal, params)
		return "So what should I do to get a blessing?"
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

	end
}

---@type Topic
local swamp_blessing = {
	severity = SEVERITY.NONE,
	has_journal_note = true,
	kind = TOPIC_KIND.ATTACK,
	name = "swamp_blessing",
	repeatable = false,
	has_journal_note_even_if_not_done = false,

	effect = function (state, journal, params)
		state.die_on_battle_lost = true

		journal.new_topic_on_battle_won = {
			done = false,
			name = "swamp_blessing_success",
			params = {
				journal.actor_index_to_object_index[state.village_elder]
			}
		}

		state.current_text = ""
		battle_manager.start_battle(state, state.last_battle)
		battle_manager.put_player_into_battle(state)

		local enemy = require "meta-actors.shadow"
		battle_manager.add_actor_to_battle(state.last_battle, battle_manager.new_actor(enemy, 1, 1), false)
		battle_manager.add_actor_to_battle(state.last_battle, battle_manager.new_actor(enemy, 2, 1), false)

		state.set_scene(state, scenes.battle)
	end,
	journal_text = function (state, journal, params, param_index)
		return "I was fighting shadows here"
	end,
	params_description = {
		{
			description = "Location",
			is_location = true
		}
	},
	option_text = function (state, journal, params)
		return "Hunt shadows"
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

	end
}

---@type Topic
local swamp_blessing_success = {
	severity = SEVERITY.NONE,
	has_journal_note = true,
	kind = TOPIC_KIND.TALK,
	name = "swamp_blessing_success",
	repeatable = false,
	has_journal_note_even_if_not_done = false,
	effect =function (state, journal, params)
		state.playable_actors[state.village_elder].trust = state.playable_actors[state.village_elder].trust + 20
		state.playable_actors[state.village_girl].trust = state.playable_actors[state.village_girl].trust + 20
		state.current_text = "Good... You are strong. Talk with this girl nearby. Maybe she has some requests for you."
		state.playable_actors[state.main_character].additional_MAG = state.playable_actors[state.main_character].additional_MAG + 10
		NEW_TOPIC_INSTANCE(state, journal, "flower_request_1", {journal.actor_index_to_object_index[state.village_girl]})
	end,
	journal_text =function (state, journal, params, param_index)
		return "I have received the ancient blessing from the village elder."
	end,
	params_description = {
		{
			description = "Village elder",
			is_actor = true
		}
	},
	option_text = function (state, journal, params)
		return "The shadows are gone."
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

	end
}

---@type Topic
local flower_request_1 = {
	severity = SEVERITY.MILD,
	has_journal_note = true,
	kind = TOPIC_KIND.TALK,
	name = "flower_request_1",
	repeatable = false,
	has_journal_note_even_if_not_done = false,
	effect =function (state, journal, params)
		state.playable_actors[state.village_girl].trust = state.playable_actors[state.village_girl].trust + 20
		state.current_text = "Yes. There is a very bad person outside of the forest who makes our lifes insufferable. He should go away. Encourage him to do it and you could join us. You need food and place to sleep, right?"

		local guard_position = LEARN_ABOUT_LOCATION(journal, LOCATION.ESTATE_LORD_B_GUARDHOUSE_NEAR_FOREST, params[1])
		local forest_village = LEARN_ABOUT_LOCATION(journal, LOCATION.FOREST_VILLAGE, nil)

		local guard = MEET_ACTOR(state, journal, state.forest_guard, LOCATION.ESTATE_LORD_B_GUARDHOUSE_NEAR_FOREST)

		NEW_TOPIC_INSTANCE(state, journal, "flower_request_2", {params[1], guard})
		NEW_TOPIC_INSTANCE(state, journal, "travel", {forest_village, guard_position})
		NEW_TOPIC_INSTANCE(state, journal, "travel", {guard_position, forest_village})
	end,
	journal_text =function (state, journal, params, param_index)
		return "I should make a person outside of the forest go away."
	end,
	params_description = {
		{
			description = "Flower",
			is_actor = true
		}
	},
	option_text = function (state, journal, params)
		return "The old man told me you have a request."
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

	end
}

---@type Topic
local flower_request_2 = {
	severity = SEVERITY.MILD,
	has_journal_note = true,
	kind = TOPIC_KIND.TALK,
	name = "flower_request_2",
	repeatable = false,
	has_journal_note_even_if_not_done = false,
	effect =function (state, journal, params)

	end,
	journal_text =function (state, journal, params, param_index)
		return "I should make a person outside of the forest go away."
	end,
	params_description = {
		{
			description = "Flower",
			is_actor = true
		},
		{
			description = "Guard",
			is_actor = true
		}
	},

	option_text = function (state, journal, params, param_index)
		return "I was told that you are messing with people living in the forest"
	end,
	has_option = function (state, journal, params, param_index)
		return param_index == 2
	end,
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)
		print("DEATH")
		if param_index == 1 then
			print("DEATH 1")
		else
			print("DEATH 2")
			NEW_TOPIC_INSTANCE(state, journal, "flower_request_success", {params[1]})
		end
	end
}

---@type Topic
local flower_request_success = {
	severity = SEVERITY.MILD,
	has_journal_note = true,
	kind = TOPIC_KIND.TALK,
	name = "flower_request_success",
	repeatable = false,
	has_journal_note_even_if_not_done = false,
	effect =function (state, journal, params)
		state.playable_actors[state.village_girl].trust = state.playable_actors[state.village_girl].trust + 20
		state.current_text = "Now you are truly one of us..."
	end,
	journal_text =function (state, journal, params, param_index)
		local journal_index = journal.location_index_to_object_index[LOCATION.FOREST_VILLAGE]
		local journal_object = journal.objects[journal_index]
		return string.format("I was accepted into %s", SHORT_DESCRIPTION(state, journal, journal_object))
	end,
	params_description = {
		{
			description = "Flower",
			is_actor = true
		}
	},
	option_text = function (state, journal, params)
		return "The guard is gone."
	end,
	has_option = function (state, journal, params, param_index)
		return true
	end,
	trigger_on_meeting_character = function (state, journal, object_index)
		return false
	end,
	effect_on_parameter_actor_death = function (state, journal, params, param_index)

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
	REGISTER_TOPIC(journal, caravan_at_gates)
	REGISTER_TOPIC(journal, caravan_at_gates_issue)
	REGISTER_TOPIC(journal, job_suggestion_guard)
	REGISTER_TOPIC(journal, travel)
	REGISTER_TOPIC(journal, caravan_at_gates_job)
	REGISTER_TOPIC(journal, village_issues_introduction)
	REGISTER_TOPIC(journal, attack_wolves)
	REGISTER_TOPIC(journal, attack_wolves_success)
	REGISTER_TOPIC(journal, swamp_blessing_start)
	REGISTER_TOPIC(journal, swamp_blessing)
	REGISTER_TOPIC(journal, swamp_blessing_success)
	REGISTER_TOPIC(journal, flower_request_1)
	REGISTER_TOPIC(journal, flower_request_2)
	REGISTER_TOPIC(journal, flower_request_success)
end