---@class PendingDamage
---@field value number
---@field alpha number

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
}

---@class MetaActor
---@field MAX_HP number
---@field STR number
---@field MAG number
---@field DEF number
---@field SPD number
---@field weapon WEAPON
---@field weapon_mastery number
---@field alignment table<ELEMENT, boolean|nil>
---@field name string
---@field image love.Image
---@field image_action_bar love.Image?
---@field image_skills love.Image?
---@field attack_sound love.Source?
---@field damaged_sound love.Source?
---@field skills ActiveSkill[]

---@class MetaActorWrapper
---@field def MetaActor
---@field unlocked boolean
---@field lineup_position number
---@field experience number
---@field level number
---@field skill_points number
---@field additional_weapon_mastery number

---@class Actor
---@field x number
---@field y number
---@field definition MetaActor
---@field wrapper MetaActorWrapper|nil
---@field visible boolean
---@field HP number
---@field HP_view number?
---@field SHIELD number
---@field pos number
---@field pending_damage PendingDamage[]
---@field status_effects Effect[]
---@field action_number number
---@field team number

---@class EffectDef
---@field description string
---@field target_effect fun(origin: Actor, target: Actor)
---@field scene_update fun(time_passed: number, dt: number, origin: Actor, target: Actor, scene_data: table): boolean
---@field scene_render fun(time_passed: number, origin: Actor, target: Actor, scene_data: table)
---@field scene_on_start fun(origin: Actor, target: Actor, scene_data: table)
---@field max_times_activated number?
---@field target_selection (fun(origin: Actor): Actor)?
---@field multi_target_selection (fun(origin: Actor) : Actor[])?
---@field multitarget boolean?
---@field ignore_description boolean?

---@class Effect
---@field def EffectDef
---@field data table
---@field time_passed number
---@field origin Actor
---@field target Actor
---@field started boolean
---@field times_activated number


---@class ActiveSkill
---@field name string
---@field description fun(actor: Actor): string
---@field effects_sequence EffectDef[]
---@field targeted boolean