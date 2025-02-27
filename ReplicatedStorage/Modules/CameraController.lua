--[[
	CameraController module: An object used to control the movements and positioning of a camera.
]]

-- SERVICES
local rep = game:GetService("ReplicatedStorage")
local runServ = game:GetService("RunService")

-- MODULES
local universal = require(rep.Modules.Universal)

-- CONSTANTS
-- Camera types
local FOLLOW_TYPE = "Follow" -- Stays at a fixed angle but moves to keep the part in the center.
local STATIC_TYPE = "Static" -- Goes to and stays motionless at a specific CFrame
local PAN_TYPE = "Pan" -- Stays at a fixed position but rotates to keep the part in the center

-- SETUP
local CameraController = {}
CameraController.__index = CameraController

-- FUNCTIONS

-- Creates a new CameraController from the given parameters.
-- camera: the camera instance to control
-- focusPart: the part this camera should focus on
-- focusYLevel: if this camera is focusing on a part, the Y position it will look at will be this value
function CameraController.new(camera: Camera, focusPart: Part, focusYLevel: number?): CameraController
	local self = setmetatable({}, CameraController)
	self.Camera = camera
	self.FocusPart = focusPart
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = rep.DefaultCameraOffset.Value
	camera.FieldOfView = 30
	
	self.Type = STATIC_TYPE
	
	self.TargetCFrame = rep.DefaultCameraOffset.Value
	
	if focusYLevel then
		self.FocusYLevel = focusYLevel
	end
	
	return self
end

-- Moves the camera to its target CFrame, taking the specified duration to move. this is only to be used when the type is Static
function CameraController:panToCFrame(duration: number)
	universal.tween(self.Camera, TweenInfo.new(duration or 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = self.TargetCFrame})
end

-- Sets the Y coordinate to focus on if this camera is focused on a block.
function CameraController:setFocusYLevel(yLevel: number)
	self.FocusYLevel = yLevel
end

-- Sets the camera controller type to the given one. Read the type descriptions in the constants section
function CameraController:setType(newType: string)
	self.Type = newType
	if self.RenderEvent then
		self.RenderEvent:Disconnect()
	end
	
	-- do the appropriate actions based on the new camera type
	if newType == FOLLOW_TYPE then
		self.RenderEvent = runServ.RenderStepped:Connect(function(deltaTime: number)
			local focusPartPosition = self.FocusPart.Position
			local position = Vector3.new(focusPartPosition.X, self.FocusYLevel and self.FocusYLevel or focusPartPosition.Y, focusPartPosition.Z)
			self.Camera.CFrame = self.Camera.CFrame:Lerp(self.TargetCFrame + position, deltaTime)
		end)
		
	elseif newType == STATIC_TYPE then
		self:panToCFrame()
		
	elseif newType == PAN_TYPE then
		self.RenderEvent = runServ.RenderStepped:Connect(function(deltaTime: number)
			local focusPartPosition = self.FocusPart.Position
			local position = Vector3.new(focusPartPosition.X, self.FocusYLevel and self.FocusYLevel or focusPartPosition.Y, focusPartPosition.Z)
			self.Camera.CFrame = self.Camera.CFrame:Lerp(CFrame.lookAt(self.TargetCFrame.Position, position), deltaTime)
		end)
		
	end
end

-- Sets the CFrame of this camera.
function CameraController:setCFrame(newCFrame: CFrame)
	self.TargetCFrame = newCFrame
	if self.Type == STATIC_TYPE then
		self:panToCFrame()
	end
end

-- Sets the focused part of this camera.
function CameraController:setFocusPart(newFocusPart: Part)
	self.FocusPart = newFocusPart
end

return CameraController
