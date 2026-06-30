---@class JournalEntryFlag
---@field text string

---@class GameFlags
---@field asked_merchant_about_his_situation boolean?

---@class Journal
---@field known_names table<number, string>
---@field actor_index_to_object_index table<number, number>
---@field location_index_to_object_index table<number, number>
---@field commodity_index_to_object_index table<number, number>
---@field social_group_to_object_index table<number, number>
---@field log JournalEntry[]
---@field objects JournalObject[]
---@field available_id number
---@field available_log_id number
---@field flags GameFlags
---@field topics TopicInstance[]
---@field topic_functors table<string, Topic>
---@field new_topic_on_battle_won TopicInstance
---@field new_topic_on_battle_lost TopicInstance

---@enum JOURNAL_OBJECT_TYPE
JOURNAL_OBJECT_TYPE = {
	LOCATION = 1,
	ACTOR = 2,
	SKILL = 3,
	COMMODITY = 4,
	ITEM = 5,
	EVENT = 6,
	RULE = 7,
	STATUS = 8
}

---@enum OCCUPATION_TYPE
OCCUPATION_TYPE = {
	NONE = 0,
	GUARD = 1,
	MERCHANT = 2,
	CITIZEN = 3,
	FOREST_VILLAGER = 4,
	FOREST_VILLAGE_ELDER = 5
}

---@enum SOCIAL_STATUS
SOCIAL_STATUS = {
	CITIZEN = 1,
	LORD = 2,
	KNIGHT = 3,
	MERCHANT = 4
}

---@enum LOCATION
LOCATION = {
	CITY = 1,
	AT_CITY_GATES = 2,
	FOREST_VILLAGE = 3,
	FOREST_VILLAGE_NEIGHBOURHOOD = 4,
	ESTATE_LORD_B = 5,
	ESTATE_LORD_B_GUARDHOUSE_NEAR_FOREST = 6,
	ESTATE_LORD_B_BAKERY = 7,
	ESTATE_LORD_B_WELL_OFF_SERF = 8,
	FOREST_VILLAGE_SWAMP = 9,
	ESTATE_LORD_A = 100,
}


---@class JournalObject
---@field id number
---@field type JOURNAL_OBJECT_TYPE
---@field associated_actor number?
---@field occupation OCCUPATION_TYPE?
---@field social_status SOCIAL_STATUS?
---@field location? LOCATION
---@field factions? FACTION[]
---@field commodity? COMMODITY
---@field price? number


---@class JournalEntry
---@field id number
---@field text_key string
---@field objects number[]
---@field information_origin number

---@alias TextGenerator fun(state: GameState, journal: Journal, log_entry : JournalEntry) : string

---comment
---@param occupation OCCUPATION_TYPE?
function OCCUPATION_STRING(occupation)
	if occupation == OCCUPATION_TYPE.GUARD then
		return "guard"
	elseif occupation ==OCCUPATION_TYPE.MERCHANT then
		return "merchant"
	elseif occupation == OCCUPATION_TYPE.CITIZEN then
		return "citizen"
	elseif occupation == OCCUPATION_TYPE.FOREST_VILLAGER then
		return "villager"
	elseif occupation == OCCUPATION_TYPE.FOREST_VILLAGE_ELDER then
		return "village elder"
	else
		return "unknown"
	end
end

---comment
---@param state GameState
---@param journal Journal
---@param object JournalObject
---@return string
function SHORT_DESCRIPTION(state, journal, object)
	if object == nil then
		return "nil_object"
	end

	local name = journal.known_names[object.id]

	if object.type == JOURNAL_OBJECT_TYPE.COMMODITY then
		return COMMODITY_STRING(object.commodity)
	end

	if object.type == JOURNAL_OBJECT_TYPE.LOCATION then
		if object.location == nil then
			return "the unknown location"
		elseif  object.location == LOCATION.CITY then
			return "Old Fortress City"
		elseif  object.location == LOCATION.AT_CITY_GATES then
			return "outside of the gates of Old Fortress City"
		elseif object.location ==LOCATION.FOREST_VILLAGE then
			return "Forest Village"
		elseif object.location == LOCATION.FOREST_VILLAGE_NEIGHBOURHOOD then
			return "Area around The Forest Village"
		end
	end

	if object.type == JOURNAL_OBJECT_TYPE.STATUS then
		if object.social_status == SOCIAL_STATUS.CITIZEN then
			return "CITIZEN"
		elseif  object.social_status == SOCIAL_STATUS.LORD then
			return "LORD"
		elseif  object.social_status == SOCIAL_STATUS.KNIGHT then
			return "KNIGHT"
		elseif  object.social_status == SOCIAL_STATUS.MERCHANT then
			return "MERCHANT GUILD"
		end
	end

	if object.type ==JOURNAL_OBJECT_TYPE.ACTOR then
		local actor = state.playable_actors[object.associated_actor]
		local gender = actor.def.gender
		local occupation = object.occupation

		if name == nil and occupation == nil then
			if gender == GENDER.MALE then
				return "the unknown man"
			end
			if gender == GENDER.FEMALE then
				return "the unknown woman"
			end
			if gender == GENDER.FUTANARI then
				return "the unknown futa"
			end
			return "the stranger"
		elseif name == nil and occupation ~= nil then
			return "the " .. GENDER_TO_STRING(gender) .. " " .. OCCUPATION_STRING(occupation)
		end

		if name ~= nil and occupation ~= nil then
			-- both name and occupation are known
			return string.format("%s %s", OCCUPATION_STRING(occupation), name)
		end
	end

	return "???"
end

---@param state GameState
---@param journal Journal
---@param object_index number
---@return string
function SHORT_DESCRIPTION_INDEX(state, journal, object_index)
	local obj = journal.objects[object_index]
	return SHORT_DESCRIPTION(state, journal, obj)
end

---@type table<string, TextGenerator>
TEXT_GENERATOR = {}

---comment
---@param who number
---@param where number
---@return number[]
local function pack_encounter_args(who, where)
	return {who, where}
end

---comment
---@param state GameState
---@param journal Journal
---@param name string
---@param params number[]
function NEW_TOPIC_INSTANCE(state, journal, name, params)
	-- ensure that all params are numbers
	for index, value in ipairs(params) do
		if type(value) ~= "number" then
			error("Non number parameter")
		end
	end

	-- ensure that there are no duplicates
	for index, value in ipairs(journal.topics) do
		if value.name == name then
			local params_are_the_same = true
			for i, param_i in ipairs(value.params) do
				if param_i ~= params[i] then
					params_are_the_same = false
				end
			end
			if params_are_the_same then
				return
			end
		end
	end

	-- add new topic
	---@type TopicInstance
	local new_instance = {
		done = false,
		name = name,
		params = params
	}
	table.insert(journal.topics, new_instance)
end

---comment
---@param state GameState
---@param journal Journal
---@param actor_index number
---@param location number
function MEET_ACTOR(state, journal, actor_index, location)
	local location_journal_index = journal.location_index_to_object_index[location]

	for index, value in ipairs(journal.objects) do
		if value.type ==JOURNAL_OBJECT_TYPE.ACTOR and value.associated_actor == actor_index then
			return value.id
		end
	end

	---@type JournalObject
	local new_object = {
		associated_actor = actor_index,
		id = journal.available_id,
		occupation = nil,
		type = JOURNAL_OBJECT_TYPE.ACTOR,
		location = location_journal_index
	}

	journal.available_id = journal.available_id + 1
	table.insert(journal.objects, new_object)
	journal.actor_index_to_object_index[actor_index] = new_object.id

	for key, value in pairs(journal.topic_functors) do
		if value.trigger_on_meeting_character(state, journal, actor_index) then
			NEW_TOPIC_INSTANCE(state, journal, value.name, {new_object.id})
		end
	end


	print("register journal actor object ", new_object.id , " -> ", new_object.associated_actor)

	---@type JournalEntry
	local temp = {
		id = journal.available_log_id,
		objects = pack_encounter_args(new_object.id, location_journal_index),
		text_key = "meet",
		information_origin = 0
	}
	journal.available_log_id = journal.available_log_id + 1
	table.insert(journal.log, temp)

	return new_object.id
end

---comment
---@param journal Journal
---@param commodity COMMODITY
function ENCOUNTER_COMMODITY(journal, commodity)
	local journal_index = journal.commodity_index_to_object_index[commodity]
	if journal_index ~= nil then
		return journal_index
	end

	---@type JournalObject
	local new_object = {
		id = journal.available_id,
		type = JOURNAL_OBJECT_TYPE.COMMODITY,
		commodity = commodity
	}

	journal.available_id = journal.available_id + 1

	table.insert(journal.objects, new_object)
	journal.commodity_index_to_object_index[commodity] = new_object.id

	print("register journal commodity object ", new_object.id , " -> ", new_object.commodity)
	return new_object.id
end

---@param journal Journal
---@param role SOCIAL_STATUS
function LEARN_ABOUT_SOCIAL_STATUS (journal, role, origin)
	for index, value in ipairs(journal.objects) do
		if value.type ==JOURNAL_OBJECT_TYPE.STATUS and value.social_status == role then
			return value.id
		end
	end

	-- we don't know about this role yet:

	---@type JournalObject
	local new_object = {
		id = journal.available_id,
		type = JOURNAL_OBJECT_TYPE.STATUS,
		social_status = role
	}
	journal.available_id = journal.available_id + 1

	journal.social_group_to_object_index[role] = new_object.id

	table.insert(journal.objects, new_object)

	print("register journal role object ", new_object.id , " -> ", role)

	---@type JournalEntry
	local temp = {
		id = journal.available_log_id,
		objects = {new_object.id},
		text_key = "social_status",
		information_origin = origin
	}
	journal.available_log_id = journal.available_log_id + 1
	table.insert(journal.log, temp)

	return new_object.id
end

---@param journal Journal
---@param location LOCATION
function LEARN_ABOUT_LOCATION (journal, location, origin)
	for index, value in ipairs(journal.objects) do
		if value.type ==JOURNAL_OBJECT_TYPE.LOCATION and value.location == location then
			return value.id
		end
	end

	-- we don't know about this role yet:

	---@type JournalObject
	local new_object = {
		id = journal.available_id,
		type = JOURNAL_OBJECT_TYPE.LOCATION,
		location = location
	}
	journal.available_id = journal.available_id + 1
	journal.location_index_to_object_index[location] = new_object.id

	table.insert(journal.objects, new_object)

	print("objects count: ", #journal.objects)

	print("register journal location object ", new_object.id , " -> ", location)

	---@type JournalEntry
	local temp = {
		id = journal.available_log_id,
		objects = {new_object.id},
		text_key = "location",
		information_origin = origin
	}
	journal.available_log_id = journal.available_log_id + 1
	table.insert(journal.log, temp)
	return new_object.id
end

---@param state GameState
---@param journal Journal
---@param location LOCATION
function VISIT_LOCATION (state, journal, location)
	state.playable_actors[state.main_character].location = location

	local value = LEARN_ABOUT_LOCATION(journal, location)
	for index, value in ipairs(state.playable_actors) do
		if value.location == location then
			local actor_index_journal = MEET_ACTOR(state, journal, index, location)
			journal.objects[actor_index_journal].occupation = value.occupation
		end
	end
	return value
end

---@param state GameState
---@param journal Journal
---@param location number
function VISIT_JOURNAL_LOCATION (state, journal, location)
	local obj = journal.objects[location]
	print(state.playable_actors[state.main_character].location, "MOVE TO", obj.location)
	return VISIT_LOCATION(state, journal, obj.location)
end

---comment
---@param state GameState
---@param journal Journal
---@param actor number
function LEARN_NAME (state, journal, actor, origin)
	journal.known_names[journal.actor_index_to_object_index[actor]] = state.playable_actors[actor].def.name

	---@type JournalEntry
	local temp = {
		id = journal.available_log_id,
		objects = { journal.actor_index_to_object_index[actor] },
		text_key = "learn_name",
		information_origin = -1
	}
	journal.available_log_id = journal.available_log_id + 1
	table.insert(journal.log, temp)
end

function LEARN_LOCATION_ACCESS (journal, social_status, location, origin)
	local tmp1 = LEARN_ABOUT_SOCIAL_STATUS(journal, social_status, origin)
	local tmp2 = LEARN_ABOUT_LOCATION(journal, location, origin)

	---@type JournalEntry
	local temp = {
		id = journal.available_log_id,
		objects = { tmp1, tmp2 },
		text_key = "location_access",
		information_origin = origin
	}
	journal.available_log_id = journal.available_log_id + 1
	table.insert(journal.log, temp)
end

---comment
---@param state GameState
---@param journal Journal
---@param actor number
function LEARN_ABOUT_DEATH(state, journal, actor, killer)
	print("LEARN ABOUT DEATH", actor)
	local dead = journal.actor_index_to_object_index[actor]

	if dead == nil then
		return
	end


	for index, value in ipairs(journal.topics) do
		local topic_template = journal.topic_functors[value.name]
		for param_index, param in ipairs(value.params) do
			print(value.name, param, dead)
			if param == dead then
				topic_template.effect_on_parameter_actor_death(state, journal, value.params, param_index)
			end
		end
	end
end

---comment
---@param state GameState
---@param journal Journal
---@param actor number
---@param killer number?
function KILL(state, journal, actor, killer)
	print("LEARN ABOUT DEATH", actor)
	state.playable_actors[actor].dead = true

	if state.playable_actors[state.main_character].location ~= state.playable_actors[actor].location then
		return
	end

	LEARN_ABOUT_DEATH(state, journal, actor, killer)
end


TEXT_GENERATOR["meet"] = function (state, journal, log)
	local who_idx = log.objects[1]
	local where_idx = log.objects[2]
	return string.format(
		"I have met %s at %s.",
		SHORT_DESCRIPTION(state, journal, journal.objects[who_idx]),
		SHORT_DESCRIPTION(state, journal, journal.objects[where_idx])
	)
end

TEXT_GENERATOR["social_status"] = function (state, journal, log)
	local who_idx = log.objects[1]
	return string.format(
		"I have learnt from %s that some people are considered as a part of %s group in these lands.",
		SHORT_DESCRIPTION(state, journal, journal.objects[log.information_origin]),
		SHORT_DESCRIPTION(state, journal, journal.objects[who_idx])
	)
end

TEXT_GENERATOR["location"] = function (state, journal, log)
	local tmp = log.objects[1]
	return string.format(
		"Thanks to %s i have learnt about the %s location.",
		SHORT_DESCRIPTION(state, journal, journal.objects[log.information_origin]),
		SHORT_DESCRIPTION(state, journal, journal.objects[tmp])
	)
end

TEXT_GENERATOR["learn_name"] = function (state, journal, log)
	local tmp = log.objects[1]
	return string.format(
		"Now I know the name of %s.",
		SHORT_DESCRIPTION(state, journal, journal.objects[tmp])
	)
end

TEXT_GENERATOR["location_access"] = function (state, journal, log)
	local who_idx = log.objects[1]
	local where_idx = log.objects[2]
	return string.format(
		"%s told me that persons with %s status are allowed to enter %s.",
		SHORT_DESCRIPTION(state, journal, journal.objects[log.information_origin]),
		SHORT_DESCRIPTION(state, journal, journal.objects[who_idx]),
		SHORT_DESCRIPTION(state, journal, journal.objects[where_idx])
	)
end