-- NOTE: This should be parented under the Block module with the name DefaultConfiguration

-- The default configuration settings for a Block
return {
	
	-- Whether this block should, after moving, automatically move again based on held and queued directions
	AllowRepeatedMovement = true,
	
	-- How long this block spends rotating to move
	MoveDuration = 0.25,
	
	-- The camera controller associated with this block, useful for the block to control the camera automatically
	CameraController = false,
	
	-- Where the block's spawn point is located
	SpawnCFrame = workspace.Course.Spawn.SpawnCFrame.Value,
	
}
