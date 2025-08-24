

---@class PendingDamage
---@field value number
---@field alpha number
---@field particle_exist boolean

---@enum WEAPON
WEAPON = {
	NONE = 0,
	SWORD = 1
}

---@enum ELEMENT
ELEMENT = {
	FIRE = 0,
	RESTORATION = 1,
	CHAOS = 2,
	PROTECTION = 3,
	LIGHT = 4,
	BLOOD = 5,
	ELECTRO = 6
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

---@class MetaActorWrapper
---@field def MetaActor
---@field unlocked boolean
---@field lineup_position number
---@field experience number
---@field level number
---@field skill_points number
---@field additional_weapon_mastery number
---@field skills ActiveSkill[]
---@field gemstones number[]

---@class GemstoneWrapper
---@field def number
---@field actor number

---@class Actor
---@field x number
---@field y number
---@field w number
---@field h number
---@field definition MetaActor
---@field wrapper MetaActorWrapper|nil
---@field visible boolean
---@field HP number
---@field HP_view number?
---@field energy number
---@field SHIELD number
---@field pos number
---@field pending_damage PendingDamage[]
---@field status_effects Effect[]
---@field action_number number
---@field team number
---@field battle_order number
---@field battle_id number

---@class EffectDef
---@field description string
---@field target_effect fun(state: GameState, battle: Battle, origin: Actor, target: Actor, scene_data: table)
---@field target_effect_on_kill (fun(state: GameState, battle: Battle, origin: Actor, target: Actor, scene_data: table))?
---@field scene_update fun(state: GameState, battle: Battle, time_passed: number, dt: number, origin: Actor, target: Actor, scene_data: table): boolean
---@field scene_render fun(state: GameState, battle: Battle, time_passed: number, origin: Actor, target: Actor, scene_data: table)
---@field scene_on_start fun(state: GameState, battle: Battle, origin: Actor, target: Actor, scene_data: table)
---@field max_times_activated number?
---@field target_selection (fun(state: GameState, battle: Battle, origin: Actor): Actor)?
---@field multi_target_selection (fun(state: GameState, battle: Battle, origin: Actor) : Actor[])?
---@field ignore_description boolean?

---@class GemstoneDefinition
---@field name string
---@field description string
---@field on_kill_effect fun(state: GameState, battle: Battle, origin: Actor, target: Actor)
---@field on_damage_dealt_effect fun(state: GameState, battle: Battle, origin: Actor, target: Actor, damage_dealt: number)
---@field on_damage_received_effect fun(state: GameState, battle: Battle, origin: Actor, target: Actor, damage_dealt: number)
---@field on_turn_start fun(state: GameState, battle: Battle, origin: Actor)
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


---@class ActiveSkill
---@field name string
---@field description fun(actor: Actor): string
---@field icon love.Image?
---@field effects_sequence number[]
---@field targeted boolean
---@field required_strength number
---@field required_magic number
---@field required_elements ELEMENT[]
---@field allowed_weapons WEAPON[]
---@field required_energy number
---@field cost number