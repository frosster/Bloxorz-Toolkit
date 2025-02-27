--[[
	ManagePlayer: creates instances of Block and CameraController to be used by the player, and detects inputs to move the block.
]]

-- CONSTANTS
local MOVE_UP = "moveUp"
local MOVE_RIGHT = "moveRight"
local MOVE_DOWN = "moveDown"
local MOVE_LEFT = "moveLeft"
local ALL_DIRECTIONS = {MOVE_UP, MOVE_RIGHT, MOVE_DOWN, MOVE_LEFT}

local ASSET_ID_PREFIX = "rbxassetid://"

-- SERVICES
local contextActions = game:GetService("ContextActionService")
local rep = game:GetService("ReplicatedStorage")
local tweenServ = game:GetService("TweenService")
local sounds = game:GetService("SoundService")
local runServ = game:GetService("RunService")

-- MODULES
local universal = require(rep.Modules.Universal)
local blockModule = require(rep.Modules.Block)
local cameraModule = require(rep.Modules.CameraController)

-- SETUP
-- create the block part for the player to use
local blockPart = rep.StarterBlock:Clone()
blockPart.Parent = workspace
blockPart.Transparency = 1
blockPart.Color = universal.getPlayerColor(game.Players.LocalPlayer)

-- set up the camera controller
local cameraController = cameraModule.new(workspace.Camera, blockPart, -2)
--cameraController:panToCFrame(0)
cameraController:setType("Follow")

-- set up the block, creates a copy of the default configuration table to modify and use for the block
local configClone = rep.Modules.Block.DefaultConfiguration:Clone()
configClone.Parent = script
configClone.Name = "PlayerConfiguration"
local configTable = require(configClone)
configTable.CameraController = cameraController
local block = blockModule.new(blockPart, configTable)
	
-- make the sound listening location originate at the block
sounds:SetListener(Enum.ListenerType.ObjectPosition, blockPart)

-- the following sections of code are relevant for the menu and spawning of the block.
-- create the menu button and enable blur
game.Lighting.MenuBlur.Enabled = true
local spawnButtonGui = game.StarterGui.SpawnButtonGUI:Clone()
spawnButtonGui.Parent = game.Players.LocalPlayer.PlayerGui
spawnButtonGui.Enabled = true
local spawnButton = spawnButtonGui.SpawnButton

-- visual changes when the user hovers over the button
spawnButton.InputBegan:Connect(function()
	spawnButton.UIStroke.Color = Color3.new(0.5, 0.5, 0.5)
end)
local ending = spawnButton.InputEnded:Connect(function()
	spawnButton.UIStroke.Color = Color3.new(0, 0, 0)
end)

-- FUNCTIONS
-- receives a string name for a direction and returns the associated vector direction
local function getDirectionFromName(name: string): Vector3
	return block.getDirectionVectors()[table.find(ALL_DIRECTIONS, name)]
end

-- handles movement inputs for the block
-- direction: the name of the direction that was inputted
-- inputState: the state of the input (beginning or ending)
-- input: unused InputObject
local function handleMovement(direction: string, inputState: Enum.UserInputState, input: InputObject)
	local directionVector = getDirectionFromName(direction)
	if inputState == Enum.UserInputState.End then
		block:removeHeldDirection(directionVector)
	elseif inputState == Enum.UserInputState.Begin then
		block:move(directionVector)
		block:addHeldDirection(directionVector)
	end
end

-- binds movement controls so that the player is able to move
local function bindMovement()
	-- binding movement keys, WASD and arrow keys
	contextActions:BindAction(MOVE_UP, handleMovement, true, Enum.KeyCode.W, Enum.KeyCode.Up)
	contextActions:BindAction(MOVE_RIGHT, handleMovement, true, Enum.KeyCode.D, Enum.KeyCode.Right)
	contextActions:BindAction(MOVE_DOWN, handleMovement, true, Enum.KeyCode.S, Enum.KeyCode.Down)
	contextActions:BindAction(MOVE_LEFT, handleMovement, true, Enum.KeyCode.A, Enum.KeyCode.Left)
	-- mobile compatibility, touch buttons
	contextActions:SetPosition(MOVE_UP, UDim2.new(0.5, 0, 0, 0))
	contextActions:SetPosition(MOVE_RIGHT, UDim2.new(0.75, 0, 0.3, 0))
	contextActions:SetPosition(MOVE_DOWN, UDim2.new(0.5, 0, 0.6, 0))
	contextActions:SetPosition(MOVE_LEFT, UDim2.new(0.25, 0, 0.3, 0))
	contextActions:SetTitle(MOVE_UP, "Up")
	contextActions:SetTitle(MOVE_RIGHT, "Right")
	contextActions:SetTitle(MOVE_DOWN, "Down")
	contextActions:SetTitle(MOVE_LEFT, "Left")
end

-- unbinds movement controls so that the player may no longer make inputs
local function unbindMovement()
	contextActions:UnbindAllActions() -- might need to stop using this if other controls are added.
	--[[contextActions:UnbindAction(MOVE_UP)
	contextActions:UnbindAction(MOVE_RIGHT)
	contextActions:UnbindAction(MOVE_DOWN)
	contextActions:UnbindAction(MOVE_LEFT)]]
	block:clearHeldDirections()
end

-- executed when the Spawn button is pressed
spawnButton.Activated:Connect(function()
	
	ending:Disconnect()
	
	-- button click effects
	spawnButtonGui.Click:Play()
	spawnButton.Active = false
	spawnButton.UIStroke.Color = Color3.new(1, 1, 1)
	local info = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	universal.tween(spawnButtonGui.Outline, info, {Size = spawnButtonGui.Outline.Size + UDim2.new(0, 100, 0, 100), Position = spawnButtonGui.Outline.Position - UDim2.new(0, 50, 0, 50)})
	universal.tween(spawnButtonGui.Outline.UIStroke, info, {Transparency = 1})
	
	-- menu fade out
	task.wait(0.5)
	universal.tween(game.Lighting.MenuBlur, info, {Size = 0})
	universal.tween(spawnButton, info, {BackgroundTransparency = 1, TextTransparency = 1})
	universal.tween(spawnButton.UIStroke, info, {Transparency = 1})
	
	-- visual block spawning effect
	task.wait(info.Time)
	local effectClone = blockPart:Clone()
	effectClone.Size = Vector3.new(0.005, 0.005, 0.005)
	effectClone.Material = Enum.Material.Neon
	effectClone.Transparency = 0.5	
	effectClone.Parent = workspace
	universal.tween(effectClone, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = blockPart.Size + Vector3.new(0.1, 0.1, 0.1)})
	
	-- showing the actual block, binding player movement controls
	task.wait(2)
	effectClone.Color = Color3.new(1, 1, 1)
	effectClone.Transparency = 0.9
	sounds.Effects.Spawn:Play()
	universal.tween(effectClone, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {Transparency = 1, Size = blockPart.Size * 6, Color = blockPart.Color})
	blockPart.Transparency = 0
	bindMovement()
	
	-- cleanup
	task.wait(1)
	effectClone:Destroy()
	spawnButtonGui:Destroy()
end)
