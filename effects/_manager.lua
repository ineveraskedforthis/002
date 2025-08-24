

---@type EffectDef[]
local data = {}
local available_id = 1

local collection = {}

function collection.new_effect(duration)
	---@type EffectDef
	local new = {
		description = "",
		scene_on_start = function (state, battle, origin, target, scene_data)

		end,
		scene_render = function (state, battle, time_passed, origin, target, scene_data)

		end,
		scene_update = function (state, battle, time_passed, dt, origin, target, scene_data)
			if (time_passed > duration) then
				return true
			end
			return false
		end,
		target_effect = function (state, battle, origin, target, scene_data)

		end,
	}
	table.insert(data, new)
	available_id = available_id + 1
	return available_id - 1, new
end

---@param id number
---@return EffectDef
function collection.get(id)
	return data[id]
end

return collection