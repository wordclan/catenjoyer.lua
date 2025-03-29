# Catenjoyer Lua Script Documentation by Etee & Adam

![Menu Preview](https://media.discordapp.net/attachments/1264567204645437482/1355639956118175834/image.png?ex=67e9a998&is=67e85818&hm=1a58aa76e23a66a6011aa7827b27ec6af88447a0b6fad2cc96c1bf928ecf3b1e&=&format=webp&quality=lossless&width=629&height=1109)

## Overview
MenuLib is a feature-rich Lua script for game enhancement that provides:
- Customizable menu system
- Keybind management
- Visual indicators
- Configuration saving/loading
- Performance monitoring



## Features

### Visual Elements
- **Draggable Watermark** with FPS counter and username  
  ![Watermark Preview](https://media.discordapp.net/attachments/1264567204645437482/1355640034472099900/image.png?ex=67e9a9aa&is=67e8582a&hm=91f2c677bd6a87a8e7fd995cdfe5a8aaa3d9f854cde6aeb64d97a1313930f5aa&=&format=webp&quality=lossless&width=407&height=57)
- **Custom Crosshair**
- **Keybind Status Indicators**
- **Draggable Keybinds List**  
  ![Keybinds Preview](https://media.discordapp.net/attachments/1264567204645437482/1355640001756528761/image.png?ex=67e9a9a2&is=67e85822&hm=6908b92b540ba71014e5b5126b16cd66c6a58e1d34a2aef482992ab02c965c86&=&format=webp&quality=lossless&width=266&height=150)

### Keybind Management
- Configurable keys for:
    - Aimbot
    - Triggerbot
    - B-Hop
    - Indicators
- Visual feedback when keys are active

### Configuration System
- 5 config slots
- Save/Load functionality
- Note: Configs are only saved while the script is loaded

## Usage

### Basic Controls
- Toggle Menu: **END** key
- Drag Elements: Click and hold left mouse button
- Save/Load Configs: Use buttons in menu

### Keybind Options
Available key options include:
- Mouse buttons (Mouse1, Mouse2, Mouse4, Mouse5)
- Space
- Alt
- Shift
- Ctrl
- C

## API Requirements
This script requires the following Lua API functions:

```lua
-- Rendering
render.get_viewport_size()
render.create_font()
render.draw_rectangle()
render.draw_line()
render.draw_text()
render.measure_text()

-- Input
input.get_mouse_position()
input.is_key_pressed()
input.is_key_down()

-- Engine
engine.get_username()
engine.register_on_engine_tick()
engine.log()

-- Windows
winapi.get_tickcount64()