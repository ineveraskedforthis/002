---@type GemstoneDefinition[]
local data = {}
local available_id = 1

local collection = {}

function collection.new_gemstone(name)
	-- print("new effect ", available_id)
	---@type GemstoneDefinition
	local new = {
		name = name,
		description = "",
		additional_hp = 0,
		additional_mag = 0,
		on_damage_dealt_effect = function (origin, target, damage_dealt)

		end,
		on_kill_effect = function (origin, target)

		end,
		on_turn_start = function (origin)

		end
	}
	table.insert(data, new)
	available_id = available_id + 1
	return available_id - 1, new
end

---@param id number
---@return GemstoneDefinition
function collection.get(id)
	-- print("get effect", id)
	return data[id]
end

return collection