-- CourseSetup: Automatically sets the CFrame value for tiles with the AutoSetCFrame tag.

local blockHeight = game.ReplicatedStorage.StarterBlock.Size.Y / 2

for _, v in workspace.Course:GetDescendants() do
	if v.Name == "AutoSetCFrame" then
		local cfValue = v.Parent:FindFirstChildWhichIsA("CFrameValue")
		local cfLocation = CFrame.new(v.Parent.Position + Vector3.new(0, blockHeight + v.Parent.Size.Y / 2, 0))
		if cfValue then
			cfValue.Value = cfLocation
		else
			cfValue = Instance.new("CFrameValue")
			cfValue.Value = cfLocation
			cfValue.Parent = v.Parent
			warn("Missing CFrame value for "..v.Parent.Name..", auto CFrame value has been used")
		end
		v:Destroy()
	end
end
