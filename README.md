# Bloxorz-Toolkit
The Bloxorz Toolkit is a game template for Roblox that allows you to quickly create your own game with mechanics based off of Bloxorz, an Adobe Flash game released in 2007.
Included in this repository are the necessary scripts and sample code snippets which may be used to create a Bloxorz-inspired game.
The Roblox game associated with this project can be found [here](https://www.roblox.com/games/14268535014/Bloxorz-Toolkit-Uncopylocked). It contains the same scripts along with a proper workspace map components. Copying the game is highly recommended instead of copying the scripts in this repository.
You are free to modify this code in any way and use it in your own games or projects.
## Usage
In order for a part to have an collisions/effects on the player, it must be located in the `Workspace -> Course` folder.
Any parts outside of this folder will not be included in collision checks with blocks.

If you're familiar with scripting, you can add your own tiles with unique behaviour. See below.

**Creating a new tile type:**
The script that handles what happens when each tile type is stepped on is located at `ReplicatedStorage -> Modules -> TileBehaviour`.
To add the behaviour for your own tile type, add a function in the `TILE_FUNCTIONS` dictionary, with the new tile type's name as the key.
A tile type's respective function contains these parameters in order:
\[The tile part that was stepped on, the block part that stepped on the tile, the Block module instance associated with the block part]

If you want to create a tile type that still activates when a block only partially stepped on it, add its name to the list at `ReplicatedStorage -> Modules -> TileBehaviour -> PartialTouchedTiles`.

Refer to the module `ReplicatedStorage -> Modules -> Block` for the functions that control a block.
Refer to the module `ReplicatedStorage -> Modules -> CameraController` for the functions that control the camera.
(Tip: You can get the CameraController associated to a Block with the `Block:getCameraController()` function.)

To create a tile which does a unique function that is too specific to have as a tile type, use the name `Custom` for the tile and put a module script under it which returns a custom function.

The starting menu sequence/input detection script is located at `StarterPlayer -> StarterPlayerScripts -> ManagePlayer`.

Have fun!
