# BlockKombat

BlockKombat is a 3D arcade fighting game built with Godot. Choose a character, enter the ring, and fight your opponent using movement, attacks, blocking, and a special move.

## Requirements

- Godot 4.7 or later
- A desktop system supported by Godot's GL Compatibility renderer

## Run the game

1. Open the project in Godot.
2. Import or scan the project directory if prompted.
3. Press **Run Project**. The project starts at the main menu.

You can also run the project from a terminal with:

```bash
godot --editor project.godot
godot --path .
```

## Controls

| Action | Keyboard | Mouse |
| --- | --- | --- |
| Move | `W` `A` `S` `D` | - |
| Punch | `J` | Left click |
| Kick | `K` | Middle click |
| Block | `L` or `Space` | - |
| Run | `Shift` | - |
| Special | `E` or `U` | Right click |
| Debug heal | `H` | - |
| Cancel selection | `Esc` | - |

## Project structure

- `Scenes/` contains the main menu, character selection, character showcase, battle HUD, and boxing ring scenes.
- `Scripts/` contains gameplay, combat, AI, camera, audience, and UI logic.
- `Assets/` contains characters, models, fonts, and UI artwork.

## Development

The project uses Jolt Physics and the GL Compatibility renderer. Open `project.godot` in the Godot editor to change input mappings, project settings, or the startup scene.
