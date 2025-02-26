--[[
	TileBehaviour module: controls what should occur when specific tile types are activated by a block.
]]

-- SERVICES
local sounds = game:GetService("SoundService")

-- MODULES
local universal = require(game.ReplicatedStorage.Modules.Universal)

-- FUNCTIONS
-- switches a bridge part to be collidable or uncollidable, depending on the switch.
local function toggleSwitch(tile: Part)
	local currentState: boolean = tile.CurrentState.Value
	local bridgePart: BasePart|Model = tile.Bridge.Value
	local tweenInfo = TweenInfo.new(0.5)
	sounds.Effects.SwitchToggle:Play()
	
	local partGoal = {Transparency = currentState and 1 or 0}
	local reversePartGoal = {Transparency = currentState and 0 or 1}
	local canQueryGoal = not currentState

	-- toggle the main part, if possible
	if bridgePart:IsA("BasePart") then
		if bridgePart:FindFirstChild("Reverse") then
			universal.tween(bridgePart, tweenInfo, reversePartGoal)
			bridgePart.CanQuery = currentState
		else
			universal.tween(bridgePart, tweenInfo, partGoal)
			bridgePart.CanQuery = canQueryGoal
		end
	end
	
	-- toggle children
	for _, child in bridgePart:GetDescendants() do -- totally didn't copy paste this whole loop causing 5 errors
		if child:IsA("BasePart") then
			if child:FindFirstChild("Reverse") then
				universal.tween(child, tweenInfo, reversePartGoal)
				child.CanQuery = currentState
			else
				universal.tween(child, tweenInfo, partGoal)
				child.CanQuery = canQueryGoal
			end
		end
	end

	-- set to the opposite state
	tile.CurrentState.Value = not currentState
end

local TILE_FUNCTIONS = {

	-- Modifies the camera to the type or CFrame provided by the tile
	CameraModifier = function(tile: Part, blockPart: Part, block: Block)
		local cameraController = block:getCameraController()
		if cameraController then
			if tile:FindFirstChild("NewType") then
				cameraController:setType(tile.NewType.Value)
			end
			if tile:FindFirstChild("NewCFrame") then
				cameraController:setCFrame(tile.NewCFrame.Value)
			end
		end
	end,

	-- Sets the spawn location of the block to the checkpoint
	Checkpoint = function(checkpoint: Part, blockPart: Part, block: Block)

		local checkpointCF = checkpoint:FindFirstChildWhichIsA("CFrameValue").Value
		if block:getSpawnCFrame() == checkpointCF then return end

		block:setSpawnCFrame(checkpointCF)
		checkpoint.Surface.Effect:Emit(1)
		sounds.Effects.Checkpoint:Play()

		-- glowy effect
		local currentColor = blockPart.Color
		blockPart.Color = Color3.new(1, 1, 1)
		universal.tween(blockPart, TweenInfo.new(0.75), {Color = currentColor})
	end,

	-- Performs a custom action provided via a script
	Custom = function(tile: Part, blockPart: Part, block: Block)
		if tile:FindFirstChild("ActivationLimit") then
			if tile.ActivationLimit.Value == 0 then return end
			tile.ActivationLimit.Value -= 1
		end
		require(tile:FindFirstChildWhichIsA("ModuleScript"))(blockPart, block) -- task.spawn goes inside of the custom scripts in case movement stopping is needed
	end,

	-- Moves the block to the other teleport part
	Teleporter = function(teleporter: Part, blockPart: Part, block: Block)
		local originalColor = blockPart.Color
		universal.tween(blockPart, TweenInfo.new(0.5), {Transparency = 0.5, Color = Color3.new(1, 1, 1)})
		sounds.Effects.Teleport:Play()
		task.wait(0.5)
		local tpCFrame = teleporter.Link.Value.SpawnCFrame.Value
		local tpTween = universal.tween(blockPart, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CFrame = tpCFrame})
		tpTween.Completed:Wait()
		blockPart.CFrame = tpCFrame -- probably not even necesasary
		universal.tween(blockPart, TweenInfo.new(0.5), {Transparency = 0, Color = originalColor})

		-- setting to the correct Y position
		local yPosition = tpCFrame.Position.Y - blockPart.Size.Y / 2
		block:setYPosition(yPosition)
		block:getCameraController():setFocusYLevel(yPosition - 2)
	end,

	-- Toggles a bridge if the block is at least partially on the switch
	SwitchLight = function(tile: Part)
		toggleSwitch(tile)
	end,

	-- Toggles a bridge only if the block is upright on the switch
	SwitchHeavy = function(tile: Part)
		toggleSwitch(tile)
	end,
	
	-- If the block is upright on an unstable tile, it will fall through.
	UnstableTile = function(tile: Part, _, block: Block)
		local fadeTween = universal.tween(tile, TweenInfo.new(0.25), {Transparency = 0.6})
		fadeTween.Completed:Wait()
		block:fall()
		task.delay(0.5, function()
			universal.tween(tile, TweenInfo.new(0.5), {Transparency = 0})
		end)
	end,

}

return {

	activateTile = function(tile: Part, blockPart: Part, block: Block)
		local tileFunction = TILE_FUNCTIONS[tile.Name]
		if tileFunction then
			tileFunction(tile, blockPart, block)
		end
	end,

}
