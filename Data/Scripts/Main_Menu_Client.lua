local MAIN_MENU = require(script:GetCustomProperty("MainMenu"))

local ROOT = script:GetCustomProperty("Root"):WaitForObject()

local MENU = script:GetCustomProperty("Menu"):WaitForObject()
local CONTAINER = script:GetCustomProperty("Container"):WaitForObject()
local MENU_BUTTON = script:GetCustomProperty("MenuButton")
local AUDIO = script:GetCustomProperty("Audio"):WaitForObject()

local MENU_OFFSET = ROOT:GetCustomProperty("MenuOffset")
local ENABLE_CURSOR = ROOT:GetCustomProperty("EnableCursor")
local NORMAL_COLOR = ROOT:GetCustomProperty("NormalColor")
local HOVERED_COLOR = ROOT:GetCustomProperty("HoveredColor")
local NORMAL_FONT_SIZE = ROOT:GetCustomProperty("NormalFontSize")
local HOVER_FONT_SIZE = ROOT:GetCustomProperty("HoverFontSize")
local FADE_IN_SPEED = ROOT:GetCustomProperty("FadeInSpeed")
local FADE_OUT_SPEED = ROOT:GetCustomProperty("FadeOutSpeed")

local height = 0
local fade_in = false
local fade_out = false
local value = 0
local last_panel = nil
local menu_showing = false

local function on_button_hovered(button, txt)
	if(last_panel ~= nil) then
		return
	end

	txt:SetColor(HOVERED_COLOR)
	txt.fontSize = HOVER_FONT_SIZE

	AUDIO.pitch = math.random(0, 600) - 300
	AUDIO:Play()
end

local function on_button_unhovered(button, txt)
	txt:SetColor(NORMAL_COLOR)
	txt.fontSize = NORMAL_FONT_SIZE
end

local function hide_menu()
	fade_out = true
	Events.BroadcastToServer("Player.Movement.Enable")

	if(last_panel ~= nil) then
		last_panel.visibility = Visibility.FORCE_OFF
		last_panel = nil
	end

	if(ENABLE_CURSOR) then
		UI.SetCanCursorInteractWithUI(false)
		UI.SetCursorVisible(false)
	end
end

local function show_menu(broadcast)
	fade_in = true

	if(broadcast) then
		Events.BroadcastToServer("Player.Movement.Disable")
	end

	if(ENABLE_CURSOR) then
		UI.SetCanCursorInteractWithUI(true)
		UI.SetCursorVisible(true)
	end
end

local function on_button_pressed(button, row, txt)
	if(last_panel ~= nil) then
		return
	end

	if(row.CloseUI) then
		hide_menu()
	elseif(row.Panel ~= nil) then
		if(last_panel ~= nil) then
			last_panel.visibility = Visibility.FORCE_OFF
		end

		last_panel = row.Panel:GetObject()
		last_panel.visibility = Visibility.FORCE_ON

		local close_button = last_panel:FindDescendantByName("Close")

		if(close_button ~= nil) then
			local close_event_handler = nil;
			close_event_handler = close_button.pressedEvent:Connect(function()
				AUDIO:Play()
				close_event_handler:Disconnect()
				last_panel.visibility = Visibility.FORCE_OFF
				last_panel = nil
			end)
		end
	end

	if(string.len(row.Event) > 0) then
		Events.Broadcast(row.Event, button, row)
	end
end

local function on_action_pressed(player, action)
	if(action == "Show/Hide Menu") then
		if(menu_showing) then
			hide_menu()
		else
			show_menu(true)
		end
	end
end

for index, row in ipairs(MAIN_MENU) do
	local button = World.SpawnAsset(MENU_BUTTON, { parent = MENU })
	local txt = button:FindDescendantByName("Text")

	txt.text = row.Text

	button.hoveredEvent:Connect(on_button_hovered, txt)
	button.unhoveredEvent:Connect(on_button_unhovered, txt)
	button.pressedEvent:Connect(on_button_pressed, row, txt)

	button.y = height

	if(#MAIN_MENU > 1) then
		height = height + MENU_OFFSET
	end

	height = height + button.height
end

MENU.height = height

function Tick(dt)
	if(fade_in and not menu_showing) then
		if(value < 1) then
			if(CONTAINER.visibility == Visibility.FORCE_OFF) then
				CONTAINER.visibility = Visibility.FORCE_ON
			end

			value = math.min(1, value + dt * FADE_IN_SPEED)
			CONTAINER.opacity = value
		else
			fade_in = false
			menu_showing = true
		end
	elseif(fade_out and menu_showing) then
		if(value > 0) then
			value = math.max(0, value - dt * FADE_OUT_SPEED)
			CONTAINER.opacity = value
		else
			fade_out = false
			menu_showing = false

			if(CONTAINER.visibility == Visibility.FORCE_ON) then
				CONTAINER.visibility = Visibility.FORCE_OFF
			end
		end
	end
end

show_menu(false)

Input.actionPressedEvent:Connect(on_action_pressed)
