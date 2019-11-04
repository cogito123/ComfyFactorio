local Public = {}
local math_random = math.random

Public.starting_items = {['iron-plate'] = 32, ['iron-gear-wheel'] = 16, ['stone'] = 25}

function Public.set_force_attributes()
	game.forces.west.set_friend("spectator", true)
	game.forces.east.set_friend("spectator", true)
	game.forces.spectator.set_friend("west", true)
	game.forces.spectator.set_friend("east", true)
	game.forces.west.share_chart = true
	game.forces.east.share_chart = true
	
	game.forces.west.research_queue_enabled = true
	game.forces.west.technologies["artillery"].enabled = false
	game.forces.west.technologies["artillery-shell-range-1"].enabled = false					
	game.forces.west.technologies["artillery-shell-speed-1"].enabled = false
	
	game.forces.east.research_queue_enabled = true
	game.forces.east.technologies["artillery"].enabled = false
	game.forces.east.technologies["artillery-shell-range-1"].enabled = false					
	game.forces.east.technologies["artillery-shell-speed-1"].enabled = false
end

function Public.create_forces()
	game.create_force("west")
	game.create_force("east")
	game.create_force("spectator")
end

function Public.assign_random_force_to_active_players()
	local player_indexes = {}
	for _, player in pairs(game.connected_players) do
		if player.force.name ~= "spectator" then	player_indexes[#player_indexes + 1] = player.index end
	end
	if #player_indexes > 1 then table.shuffle_table(player_indexes) end
	local a = math_random(0, 1)
	for key, player_index in pairs(player_indexes) do
		if key % 2 == a then
			game.players[player_index].force = game.forces.west
		else
			game.players[player_index].force = game.forces.east
		end
	end
end

function Public.assign_force_to_player(player)
	if math_random(1, 2) == 1 then
		if #game.forces.east.connected_players > #game.forces.west.connected_players then
			player.force = game.forces.west
		else
			player.force = game.forces.east 
		end
	else
		if #game.forces.east.connected_players < #game.forces.west.connected_players then
			player.force = game.forces.east
		else
			player.force = game.forces.west 
		end
	end
end

function Public.teleport_player_to_active_surface(player)
	local surface = game.surfaces[global.active_surface_index]
	player.teleport(surface.find_non_colliding_position("character", player.force.get_spawn_position(surface), 32, 0.5), surface)
end

function Public.put_player_into_random_team(player)
	if player.character then
		if player.character.valid then
			player.character.destroy()
		end
	end		
	player.character = nil
	player.set_controller({type=defines.controllers.god})
	player.create_character()
	for item, amount in pairs(Public.starting_items) do
		player.insert({name = item, count = amount})
	end
end

function Public.set_player_to_spectator(player)
	if player.character then player.character.die() end
	player.force = game.forces.spectator	
	player.character = nil
	player.spectator = true
	player.set_controller({type=defines.controllers.spectator})
end

return Public