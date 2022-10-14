local ROOT = script:GetCustomProperty("Root"):WaitForObject()

local DISABLE_MOVEMENT = ROOT:GetCustomProperty("DisableMovement")

if(DISABLE_MOVEMENT) then
	local function on_player_joined(player)
		Task.Wait()
		player.isMovementEnabled = false
	end

	Game.playerJoinedEvent:Connect(on_player_joined)
end

local function enable_movement(player)
	player.isMovementEnabled = true
end

local function disable_movement(player)
	player.isMovementEnabled = false
end

Events.ConnectForPlayer("Player.Movement.Enable", enable_movement)
Events.ConnectForPlayer("Player.Movement.Disable", disable_movement)