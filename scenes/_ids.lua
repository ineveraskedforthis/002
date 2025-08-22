local manager = require "scenes._manager"

local scenes = {
	select_battle = manager.new_scene("Battle selector"),
	battle = manager.new_scene("Battle"),
	gemstones = manager.new_scene("Gemstones"),
	lineup = manager.new_scene("Lineup"),
	gacha = manager.new_scene("Hiring"),
	learning = manager.new_scene("Learning")
}

return scenes
