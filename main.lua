require "types"
require "mechanics.basic"
require "scenes._loader"
require "story.game-start"
require "story.journal"

local scene_manager = require "scenes._manager"


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

---@type GameState
local state = require "state.state"
---@type Journal
local journal = {
	actor_index_to_object_index = {},
	available_id = 1, available_log_id = 1,
	known_names = {},
	log = {},
	objects = {},
	flags = {},
	topic_functors = {},
	topics = {},
	location_index_to_object_index = {},
	commodity_index_to_object_index = {},
	social_group_to_object_index = {}
}

require "story.game-start"(state, journal)

local style = require "ui._style"

function love.load()
	require "state.init-state-release"(state)
	love.window.setMode( 1280, 720, {msaa = 0} )

	state.current_location = LOCATION.AT_CITY_GATES

	journal.actor_index_to_object_index = {}
	journal.available_id = 1
	journal.known_names = {}
	journal.log = {}
	journal.objects = {}
	journal.topics = {}
	journal.topic_functors = {}
	journal.location_index_to_object_index = {}
	journal.commodity_index_to_object_index = {}
	journal.available_log_id = 1
	journal.flags = {}
	journal.social_group_to_object_index = {}

	require "story.issues"(journal)

	local city = LEARN_ABOUT_LOCATION(journal, LOCATION.CITY)
	local gates = VISIT_LOCATION(state, journal, LOCATION.AT_CITY_GATES)
	NEW_TOPIC_INSTANCE(state, journal, "travel", {gates, city})
	NEW_TOPIC_INSTANCE(state, journal, "travel", {city, gates})
end

function love.update(dt)
	state.vfx.update(dt)
	scene_manager.get(state.current_scene).update(state, journal, dt)
end

function love.draw()
	style.basic_bg_color()
	scene_manager.get(state.current_scene).render(state, journal)
	state.vfx.render()
	-- love.graphics.print(state.currency .. " points", 5, 700)
end

function love.mousepressed(x, y, button, istouch, presses)
	scene_manager.get(state.current_scene).on_click(state, journal, x, y)
end