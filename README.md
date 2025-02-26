# Bloxorz-Toolkit
The Bloxorz Toolkit is a game template for Roblox that allows you to quickly create your own game with mechanics based off of Bloxorz, an Adobe Flash game released in 2007.

Included in this repository are the necessary scripts and sample code snippets which may be used to create a Bloxorz-inspired game.

The Roblox game associated with this project can be found [here](https://www.roblox.com/games/14268535014/Bloxorz-Toolkit-Uncopylocked). It contains the same scripts along with proper workspace map components. Copying the game is highly recommended instead of copying the scripts in this repository.

You are free to modify this code in any way and use it in your own games or projects.
## Usage
In order for a part to have an collisions/effects on the player, it must be located in the `Workspace -> Course` folder. Any parts outside of this folder will not be included in collision checks with blocks.

**Tile usage**

Here is a reference list for all currently relevant tile types:
- **Bridge:** This can be toggled by switches, and can either be a part or a model containing parts. To toggle it, refer to SwitchLight and SwitchHeavy. It does not need to be named Bridge.
	- If you would like a bridge part to have the opposite state as normal, add a BoolValue under it named "Reverse".
- **CameraModifier:** Stepping on this tile changes the current camera positioning. Refer to the module `ReplicatedStorage -> Modules -> CameraController` for camera type information.
	- The optional StringValue named NewType changes the camera's movement behaviour. This can be "Follow", "Static", or "Pan".
	- The optional CFrameValue named NewCFrame changes where the camera is positioned or how it is offset.
- **Checkpoint:** Blocks that step on a checkpoint will respawn on it after falling.
	- The CFrameValue named SpawnCFrame indicates the location a block should respawn at.
	- To automatically set SpawnCFrame to be above the tile, add a BoolValue named "AutoSetCFrame" under the tile.
- **Custom:** When stepped on, a function provided by a ModuleScript under the tile will be executed.
	- The optional IntValue named ActivationLimit controls the maximum number of times this tile may be activated
- **InactiveTeleporter:** A tile that does nothing. It appears to be an inactive version of the Teleporter.
	- The CFrameValue named SpawnCFrame indicates the location a block should be placed when the teleporter gets teleported to.
	- To automatically set SpawnCFrame to be above the tile, add a BoolValue named "AutoSetCFrame" under the tile.
- **Spawn:** Upon spawning for the first time, the block will be placed on this tile. There should only be one Spawn.
	- The CFrameValue named SpawnCFrame indicates the location a block should spawn/respawn at.
	- To automatically set SpawnCFrame to be above the tile, add a BoolValue named "AutoSetCFrame" under the tile.
- **SwitchHeavy** and **SwitchLight:** When stepped on, a specific bridge will be toggled on or off.
	- SwitchHeavy requires the block to be fully touching the tile in order to activate. SwitchLight only needs the block to at least partially touch the tile.
	- The ObjectValue named Bridge links to the bridge parts that will be toggled when stepped on. Refer to Bridge for more information.
	- The BoolValue named CurrentState indicates the current state of the bridge.
- **Teleporter:** When stepped on, the block will be transported to the linked teleporter.
	- The ObjectValue named Link indicates what teleporter a block should be teleported to.
	- The CFrameValue named SpawnCFrame indicates the location a block should be placed when the teleporter gets teleported to.
	- To automatically set SpawnCFrame to be above the tile, add a BoolValue named "AutoSetCFrame" under the tile.
- **Tile:** This tile has no special behaviour.
- **UnstableTile:** If a block is upright on an unstable tile, it will fall through and respawn.

If you're familiar with scripting, you can add your own tiles with unique behaviour. See below.

**Creating a new tile type:**
The script that handles what happens when each tile type is stepped on is located at `ReplicatedStorage -> Modules -> TileBehaviour`.

To add the behaviour for your own tile type, add a function in the `TILE_FUNCTIONS` dictionary, with the new tile type's name as the key.
A tile type's respective function contains these parameters in order:
\[The tile part that was stepped on, the block part that stepped on the tile, the Block module instance associated with the block part]

If you want to create a tile type that still activates when a block only partially stepped on it, add its name to the list at `ReplicatedStorage -> Modules -> TileBehaviour -> PartialTouchedTiles`.

To create a tile which does a unique function that is too specific to have as a tile type, use the name `Custom` for the tile and put a module script under it which returns a custom function.

**Other stuff:**
Refer to the module `ReplicatedStorage -> Modules -> Block` for the functions that control a block.
Refer to the module `ReplicatedStorage -> Modules -> CameraController` for the functions that control the camera.
(Tip: You can get the CameraController associated to a Block with the `Block:getCameraController()` function.)

The starting menu sequence/input detection script is located at `StarterPlayer -> StarterPlayerScripts -> ManagePlayer`.

Have fun!
