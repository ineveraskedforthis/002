

---@class PendingDamage
---@field value number
---@field alpha number
---@field particle_exist boolean

---@enum WEAPON
WEAPON = {
	NONE = 0,
	SWORD = 1,
	DAGGER = 2,
}

---@class WEAPON_REQUIREMENT
---@field weapon WEAPON
---@field mastery number

---@enum ELEMENT
ELEMENT = {
	FIRE = 0,
	RESTORATION = 1,
	CHAOS = 2,
	PROTECTION = 3,
	LIGHT = 4,
	BLOOD = 5,
	ELECTRO = 6,
	RUPTURE = 7
}

---@class MetaActor
---@field MAX_HP number
---@field STR number
---@field STR_per_level number
---@field MAG number
---@field MAG_per_level number
---@field SPD number
---@field SPD_per_level number
---@field DEF number
---@field weapon WEAPON
---@field weapon_mastery number
---@field max_energy number
---@field alignment table<ELEMENT, boolean|nil>
---@field name string
---@field image love.Image
---@field image_battle love.Image?
---@field image_action_bar love.Image?
---@field image_skills love.Image?
---@field attack_sound love.Source?
---@field damaged_sound love.Source?
---@field inherent_skills ActiveSkill[]
---@field gender GENDER

---@enum GENDER
GENDER = {
	MALE = 1,
	FEMALE = 2,
	FUTANARI = 3,
	NONE = 4
}

function GENDER_TO_STRING (x)
	if x == GENDER.MALE then
		return "Male"
	elseif x == GENDER.FEMALE then
		return "Female"
	elseif x == GENDER.FUTANARI then
		return "Futa"
	end
end

---@enum FACTION
FACTION = {
	CITY_GUARD = 0,
	CARAVAN_MERCHANTS = 1,
	MAGE_GUILD = 2,
	ORDER_OF_LIGHT = 3,
	HIGHWAY_JESTERS = 4,
	ROGUE_MAGES = 5,
	MERCENARIES = 6
}

---@enum COMMODITY
COMMODITY = {
	LUXURY_CLOTH = 0
}

---comment
---@param c COMMODITY?
function COMMODITY_STRING (c)
	if c == COMMODITY.LUXURY_CLOTH then
		return "Luxury Cloth"
	else
		return "Unknown"
	end
end

---@class ItemForSell
---@field commodity COMMODITY
---@field amount number
---@field price number

---@class MetaActorWrapper
---@field def MetaActor
---@field actor_index number
---@field unlocked boolean
---@field lineup_position number
---@field experience number
---@field trust number
---@field level number
---@field skill_points number
---@field additional_weapon_mastery number
---@field additional_MAG number
---@field skills ActiveSkill[]
---@field gemstones number[]
---@field factions FACTION[]
---@field location LOCATION
---@field occupation OCCUPATION_TYPE
---@field wares? ItemForSell[]
---@field dead boolean

---@class GemstoneWrapper
---@field def number
---@field actor number

---@class RegisterFrame
---@field stack_pointer number
---@field acting_actor number
---@field target_actor number?
---@field target_x number
---@field target_y number
---@field origin_x number
---@field origin_y number
---@field timer number

---@class Actor
---@field x number
---@field y number
---@field view_x number
---@field view_y number
---@field w number
---@field h number
---@field definition MetaActor
---@field wrapper MetaActorWrapper|nil
---@field visible boolean
---@field HP number
---@field HP_view number?
---@field energy number
---@field SHIELD number
---@field pending_damage PendingDamage[]
---@field status_effects Effect[]
---@field action_number number
---@field battle_order number
---@field stack RegisterFrame[]
---@field stack_top number
---@field counterattack_count number
---@field lock boolean

---@class EffectDef
---@field description string
---@field target_effect fun(state: GameState, origin: Actor, target: Actor, scene_data: table)
---@field target_effect_on_kill (fun(state: GameState, origin: Actor, target: Actor, scene_data: table))?
---@field scene_update fun(state: GameState, time_passed: number, dt: number, origin: Actor, target: Actor, scene_data: table): boolean
---@field scene_render fun(state: GameState, time_passed: number, origin: Actor, target: Actor, scene_data: table)
---@field scene_on_start fun(state: GameState, origin: Actor, target: Actor, scene_data: table)
---@field max_times_activated number?
---@field target_selection (fun(state: GameState, origin: Actor): Actor)?
---@field multi_target_selection (fun(state: GameState, origin: Actor) : Actor[])?
---@field ignore_description boolean?
---@field do_not_skip boolean
---@field utility fun(state: GameState, origin: Actor, target: Actor, scene_data: table): number

---@class GemstoneDefinition
---@field name string
---@field description string
---@field on_kill_effect fun(state: GameState, origin: Actor, target: Actor)
---@field on_damage_dealt_effect fun(state: GameState, origin: Actor, target: Actor, damage_dealt: number)
---@field on_damage_received_effect fun(state: GameState, origin: Actor, target: Actor, damage_dealt: number)
---@field on_turn_start fun(state: GameState, origin: Actor)
---@field additional_hp number
---@field additional_mag number
---@field base_shield number

---@class Effect
---@field def number
---@field data table
---@field time_passed number
---@field origin Actor
---@field target Actor
---@field started boolean
---@field times_activated number

---@class Location
---@field name string

---@class LocationAdjacency
---@field origin number
---@field target number
---@field distance number

---@class PartyLocation
---@field position number
---@field party number

---@class Party
---@field name string

---@class ActiveSkill
---@field name string
---@field description fun(actor: Actor): string
---@field icon love.Image?
---@field on_skill_used_sequence (number[])|nil
---@field on_being_attacked_sequence (number[])|nil
---@field is_attack boolean
---@field targeted boolean
---@field required_strength number
---@field required_magic number
---@field required_elements ELEMENT[]
---@field allowed_weapons WEAPON_REQUIREMENT[]
---@field required_energy number
---@field cost number
---@field program PROGRAM
---@field movement boolean