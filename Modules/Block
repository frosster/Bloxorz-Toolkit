--[[
	Block module: Controls the functionality for a Block instance.
	Movement commands for a Block may originate from player input or scripted values.
]]

-- TYPE
export type Block = {}

-- CONSTANTS
local UP = Vector3.new(0, 0, -1)
local RIGHT = Vector3.new(1, 0, 0)
local DOWN = Vector3.new(0, 0, 1)
local LEFT = Vector3.new(-1, 0, 0)
local ALL_DIRECTIONS = {UP, RIGHT, DOWN, LEFT}
local GRAVITY_DIRECTION = Vector3.new(0, -1, 0)

local NONE_TILE = "none"
local TILE = "Tile"
local ALL_TOUCHING = "allTouching"
local PARTIAL_TOUCHING = "partialTouching"

local NINETY_DEGREES = math.rad(90)

-- SERVICES
local sounds = game:GetService("SoundService")
local debris = game:GetService("Debris")

-- MODULES
local universal = require(game.ReplicatedStorage.Modules.Universal)
local tileBehaviour = require(game.ReplicatedStorage.Modules.TileBehaviour)
local partialTouchTiles = require(game.ReplicatedStorage.Modules.TileBehaviour.PartialTouchedTiles)

-- SETUP
local Block = {}
Block.__index = Block

-- FUNCTIONS

-- Creates a new block instance.
-- blockPart: the part to be moved and controlled as a block
-- configuration: an optional table of properties to use.
-- any properties will override the default values, any missing properties will use the default value.
function Block.new(blockPart: Part, configuration: {string: any}?): Block
	local self = setmetatable({}, Block)
	-- setting up the block part
	self.BlockPart = blockPart
	blockPart.Anchored = true

	-- creating the pivot part
	self.Pivot = Instance.new("Part")
	self.Pivot.Anchored = true
	self.Pivot.CanCollide = false
	self.Pivot.CanTouch = false
	self.Pivot.CanQuery = false
	self.Pivot.Transparency = 1
	self.Pivot.Size = Vector3.new(1, 1, 1)
	self.Pivot.Name = "Pivot"
	self.Pivot.Material = Enum.Material.SmoothPlastic
	self.Pivot.Parent = blockPart

	-- creating the weld for the pivot and the block
	self.Weld = Instance.new("WeldConstraint")
	self.Weld.Enabled = false
	self.Weld.Part0 = self.Pivot
	self.Weld.Part1 = blockPart
	self.Weld.Parent = blockPart
	
	-- various required block properties
	self.HeldDirections = {}
	self.MovementQueue = {}
	self.MoveDebounce = true
	--self.SpawnCFrame = workspace.Course.Spawn.SpawnCFrame.Value

	-- setting the configurable properties to the defaults or the provided values
	for property, value in require(script.DefaultConfiguration) do
		self[property] = value
		if configuration and configuration[property] ~= nil then
			self[property] = configuration[property]
		end
	end
	self.YPosition = self.SpawnCFrame.Position.Y - self.BlockPart.Size.Y / 2
	
	-- go to spawn CFrame
	blockPart.CFrame = self.SpawnCFrame

	return self
end

-- Returns the table of direction vectors used by this block
function Block.getDirectionVectors(): {Vector3}
	return ALL_DIRECTIONS
end

-- Returns the camera controller associated with this block (if any)
function Block:getCameraController()
	return self.CameraController
end

-- Sets the CFrame of this block's pivot to the provided one, the block will move with it
function Block:setPivotCFrame(cf: CFrame)
	self.Weld.Enabled = false
	self.Pivot.CFrame = cf
	self.Weld.Enabled = true
end

-- returns this block's respawn CFrame
function Block:getSpawnCFrame(): CFrame
	return self.SpawnCFrame
end

-- sets the block's respawn CFrame to the one provided
function Block:setSpawnCFrame(cf: CFrame)
	self.SpawnCFrame = cf
end

-- sets this block's base Y position to the one provided. only use this when the block is changing platform elevations
function Block:setYPosition(yPosition: number)
	self.YPosition = yPosition
end

-- Returns this block's position at a specific height relative to the base of the block
function Block:getPositionAtHeight(height: number): Vector3
	return Vector3.new(self.BlockPart.Position.X, self.YPosition + height, self.BlockPart.Position.Z)
end

-- Returns the tile names that this block is resting on.
-- The vector3 direction keys indicate the name of the tile type under the block in the associated direction.
-- The string keys indicate the number of a specific type of tile that the block is resting on.
-- The returned dictionary also indicates if all tiles are the same tile with the ALL_TOUCHING key.
-- All partially touched tiles are stored in the PARTIAL_TOUCHING dictionary.
function Block:getTouchingTiles(): {Vector3: string, string: number, ALL_TOUCHING: Instance?}
	-- raycast properties
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {workspace.Course}
	local origin = self:getPositionAtHeight(1)
	local direction = GRAVITY_DIRECTION * 3

	local allResults = {[PARTIAL_TOUCHING] = {}}
	-- raycast for directly under the center of the block
	local centerTest = workspace:Spherecast(origin, 0.05, direction, params)
	local centerResult = centerTest == nil and NONE_TILE or centerTest.Instance
	allResults[GRAVITY_DIRECTION] = centerResult
	allResults[centerResult] = 1
	if centerTest then
		allResults[PARTIAL_TOUCHING][centerTest.Instance] = true
	end
	
	-- raycasts for slight offsets to the sides of the block
	for _, moveDirection in ALL_DIRECTIONS do
		local sideTest = workspace:Spherecast(origin + moveDirection / 2, 0.05, direction, params)
		local sideResult = sideTest == nil and NONE_TILE or sideTest.Instance
		allResults[moveDirection] = sideResult
		allResults[sideResult] = allResults[sideResult] and allResults[sideResult] + 1 or 1
		
		if sideTest then
			allResults[PARTIAL_TOUCHING][sideTest.Instance] = true
		end
		if allResults[sideResult] == #ALL_DIRECTIONS + 1 then
			allResults[ALL_TOUCHING] = sideTest and sideTest.Instance or nil
		end
	end

	return allResults
end

-- Adds a movement direction to the held directions for this block
function Block:addHeldDirection(direction: Vector3)
	if not table.find(self.HeldDirections, direction) then
		table.insert(self.HeldDirections, direction)
	end
end

-- Removes a movement direction from the held directions for this block
function Block:removeHeldDirection(direction: Vector3)
	table.remove(self.HeldDirections, table.find(self.HeldDirections, direction))
end

-- Removes all held directions for this block. Generally use this when unbinding movement inputs
function Block:clearHeldDirections()
	table.clear(self.HeldDirections)
end

-- Adds a movement direction to the queue of movements.
function Block:addToMovementQueue(direction: Vector3, amount: number)
	for i = 1, amount or 1 do
		table.insert(self.MovementQueue, direction)
	end
end

-- Moves based on a provided direction vector.
-- If no direction is provided, the first held direction or the first queued movement will be used instead.
function Block:move(direction: Vector3?)
	
	if not self.MoveDebounce then return end
	self.MoveDebounce = false
	-- Finding the direction to use if none is provided
	if not direction then
		if #self.HeldDirections == 0 and #self.MovementQueue == 0 then
			self.MoveDebounce = true
			return
		end
		direction = self.HeldDirections[1]
		if not direction then
			direction = self.MovementQueue[1]
			table.remove(self.MovementQueue, 1)
		end
	end
	
	-- Finding where to set the pivot part
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {self.BlockPart}
	local edgePoint = workspace:Raycast(self.BlockPart.Position + direction * 20, -direction * 20, params)
	self:setPivotCFrame(CFrame.new(Vector3.new(edgePoint.Position.X, self.YPosition, edgePoint.Position.Z)))
	
	-- Tweening the pivot, which will appear to be the block rolling on the ground
	self.BlockPart.Anchored = false
	local movementCF = self.Pivot.CFrame * CFrame.Angles(math.rad(90 * direction.Z), 0, -math.rad(90 * direction.X))
	local movementTween = universal.tween(
		self.Pivot,
		TweenInfo.new(self.MoveDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		{CFrame = movementCF} -- oh my goodness this [movementCF] actually nearly worked first try. i am a genius
	)
	
	-- Spawn the waiting things in a new thread to let the calling scripts continue doing things
	task.spawn(function()
		movementTween.Completed:Wait()
		self.Pivot.CFrame = movementCF
		task.wait() -- ensure the block is in the correct place
		self.BlockPart.Anchored = true
		
		local touchingTiles = self:getTouchingTiles()
		-- Check if the block is over air
		if touchingTiles[NONE_TILE] then
			
			-- If the block is not directly above air, find the direction above air and lean the block toward it
			if touchingTiles[GRAVITY_DIRECTION] ~= NONE_TILE then
				for _, moveDirection in pairs(ALL_DIRECTIONS) do
					if touchingTiles[moveDirection] == NONE_TILE then
						-- leaning over tween
						self.BlockPart.Anchored = false
						local position = self:getPositionAtHeight(0)
						self:setPivotCFrame(CFrame.lookAt(position, position + moveDirection))
						universal.tween(self.Pivot, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {CFrame = self.Pivot.CFrame * CFrame.Angles(-math.rad(90), 0, 0)})
						task.wait(0.2)
						self.BlockPart.Anchored = true
					end
				end
			end
			
			self:fall()
			self.MoveDebounce = true
			
		else
			
			-- Play the block hitting noise
			local sound = sounds.Effects.BlockSound
			sound.TimePosition = 0
			sound:Play()
			
			-- Activate a tile effect if the block is completely on top of it
			if touchingTiles[ALL_TOUCHING] then
				tileBehaviour.activateTile(touchingTiles[ALL_TOUCHING], self.BlockPart, self)
			else
				-- Activating partial touched tiles
				for tile: BasePart, _ in touchingTiles[PARTIAL_TOUCHING] do
					if partialTouchTiles[tile.Name] then
						tileBehaviour.activateTile(tile, self.BlockPart, self)
					end
				end
			end
			
			-- Allow movement to occur again
			self.MoveDebounce = true
			if self.AllowRepeatedMovement then
				task.spawn(function()
					self:move() -- don't know if it's possible to put :move() itself as the argument. jank stuff.
				end)
			end
			
		end
	end)
end

-- Causes the block to fall directly down and respawn if MoveDebounce is currently false.
function Block:fall()
	
	if self.MoveDebounce then return end
	
	local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	-- falling down tween, and respawning
	local fallTween = universal.tween(
		self.BlockPart,
		tweenInfo,
		{CFrame = self.BlockPart.CFrame + GRAVITY_DIRECTION * 100}
	)
	fallTween.Completed:Wait()

	self.BlockPart.CFrame = self.SpawnCFrame - GRAVITY_DIRECTION * 100
	local respawnTween = universal.tween(
		self.BlockPart,
		tweenInfo,
		{CFrame = self.SpawnCFrame}
	)
	respawnTween.Completed:Wait()
	sounds.Effects.HeavyBlock:Play()
	self.BlockPart.CFrame = self.SpawnCFrame

	-- correct Y position functions
	local yPosition = self.SpawnCFrame.Position.Y - self.BlockPart.Size.Y / 2
	self:setYPosition(yPosition)
	if self.CameraController then
		self.CameraController:setFocusYLevel(yPosition - 2)
	end
	
end

return Block
