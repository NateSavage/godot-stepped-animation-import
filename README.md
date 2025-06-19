### Stepped Animation Importer

By default,  [Godot](https://godotengine.org/)'s animation system assumes all imported animations should interpolate between key frames using linear interpolation. If you wish to stylize your animations in a way that lets people see each individual key frame. You would want your animations to use nearest/no interpolation. Godot has features for this, however it doesn't yet have nice UX to make importing your stepped animations easy.

This plugin simply adds a post process step to imported animations marking all the tracks on them to use [`InterpolationType.INTERPOLATION_NEAREST`](https://docs.godotengine.org/en/stable/classes/class_animation.html#enum-animation-interpolationtype).

### Installation
1. Copy the `addons` folder into your godot project.
2. Under `project -> plugins` check enable for the Stepped Animation Import plugin.

### Usage
How many animations do you want stepped in your project?

- **ALL**: 
	Simply by having the plugin enabled, all newly imported/reimported assets will have stepped animation.
- **MOST**: 
	Find and select each asset you want smooth animations on, and in the import tab uncheck `animations/stepped`.
 - **SOME**: 
	 In the editor under `project -> project settings -> Import Defaults` go to `animations/stepped` and uncheck it. You may now select stepped animation on individually imported assets in the import tab when you have an asset(s) selected.


### Limitations
This plugin works on all versions of Godot 4.x, and is currently untested on Godot 3.x

It also operates on a *per asset* basis. It only allows for toggling all animations on an asset between stepped and linear. If you need some smooth animations, and some stepped animations on the same asset, you will need to export the animations into separate assets.
