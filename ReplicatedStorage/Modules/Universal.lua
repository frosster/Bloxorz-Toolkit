--[[
	Universal module: Contains functions with broad use cases
]]

-- SERVICES
local tweenServ = game:GetService("TweenService")

return {
	
	-- Creates and plays a new tween from the given parameters. The tween is also returned
	tween = function(object: Instance, info: TweenInfo, goal: {any}): Tween
		local newTween = tweenServ:Create(object, info, goal)
		newTween:Play()
		return newTween
	end,
	
	-- Returns a random float between the two specified numbers.
	randomFloat = function(low: number, high:number): number
		return low + (high - low) * math.random()
	end,
	
	-- Returns a player's associated random color, which is based on their user ID.
	getPlayerColor = function(player: Player): Color3
		local colors = {
			Color3.fromRGB(122, 0, 0),
			Color3.fromRGB(144, 113, 0),
			Color3.fromRGB(109, 131, 0),
			Color3.fromRGB(18, 118, 0),
			Color3.fromRGB(0, 126, 95),
			Color3.fromRGB(0, 121, 132),
			Color3.fromRGB(0, 63, 131),
			Color3.fromRGB(89, 0, 141),
			Color3.fromRGB(121, 0, 93),
		}
		return colors[math.fmod(game.Players.LocalPlayer.UserId, #colors) + 1]
	end,
	
}
