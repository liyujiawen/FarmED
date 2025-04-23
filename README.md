# FarmED - Sustainable Agriculture Education Game  

## Overview
FarmED is an educational farming simulation game developed in Lua using the LÖVE2D framework. The game aims to teach players about sustainable agriculture practices through engaging gameplay mechanics. Players will plant crops, manage resources, and progress through different levels while learning about food security and agricultural practices.

## Table of Contents
- [Game Installation](#game-installation)
- [Game Features](#game-features)
- [How to Play](#how-to-play)
- [Controls](#controls)
- [Crop Information](#crop-information)
- [Game Mechanics](#game-mechanics)
- [Level Progression](#level-progression)
- [File Structure](#file-structure)
- [Credits](#credits)

## Game Installation

### Requirements
- [LÖVE2D](https://love2d.org/) (version 11.3 or newer recommended)

### Installation Steps
1. Download and install LÖVE2D from [the official website](https://love2d.org/)
2. Download the FarmED game repository from GitHub:
   - **Using Git**: 
     ```
     git clone https://github.com/yourusername/FarmED.git
     ```
   - **Without Git**:
     - Go to the GitHub repository page (https://github.com/yourusername/FarmED)
     - Click the green "Code" button
     - Select "Download ZIP"
     - Extract the ZIP file to your preferred location
3. Run the game using one of these methods:
   - Drag the game folder onto the LÖVE2D executable
   - Use the command line: `love path/to/game/folder`
   - On Windows, you can drag the folder onto a shortcut to love.exe
   - On macOS, drag the folder onto the LÖVE application

## Game Features
- Educational farming simulator with focus on sustainable agriculture
- Resource management (water, action points, health)
- Dynamic weather system affecting gameplay
- Multiple crop types with different characteristics
- Simple cooking system to restore health
- Progressive difficulty with 3 gameplay levels
- Visual growth stages for plants
- In-game guidance system

## How to Play
1. **Start the game** by pressing ENTER at the main menu
2. **Plant seeds** in empty plots by selecting a seed type and clicking on an empty plot
3. **Water your plants** to help them grow (press F when near a planted crop)
4. **Harvest crops** when they're fully grown (press SPACE near mature plants)
5. **Sell crops** at the warehouse for money
6. **Buy seeds** at the shop to plant more crops
7. **Cook meals** in the kitchen to restore health using harvested crops
8. **Advance to the next day** when you're done with your daily activities
9. **Complete objectives** to unlock more farmland and advance to the next level

## Controls

### Basic Controls
- **Arrow Keys**: Move character
- **SPACE**: Interact (plant/harvest/pick up seeds)
- **F**: Water plants
- **N**: Advance to next day
- **K**: Access kitchen menu (when near kitchen)

### Seed Selection
- **Q**: Select Cabbage seeds
- **W**: Select Beans seeds
- **E**: Select Maize seeds
- **R**: Select Sweet Potato seeds

### Interface Controls
- **S**: Open shop
- **C**: Open warehouse
- **H**: Open help screen
- **ESC**: Back/Cancel
- **T**: Toggle watering mode

## Crop Information

| Crop         | Growth Time | Water Needs | Value | Daily Watering Limit |
|--------------|-------------|-------------|-------|----------------------|
| Cabbage      | 2 days      | 4           | 15    | 4                    |
| Beans        | 3 days      | 2           | 30    | 2                    |
| Maize        | 4 days      | 6           | 50    | 6                    |
| Sweet Potato | 5 days      | 8           | 70    | 8                    |

## Game Mechanics

### Weather System
- **Sunny**: Provides 80 water for the day
- **Rainy**: Provides 100 water for the day and auto-waters plants

### Health System
- Health decreases by 5 points each day
- When health is below 30, action points are reduced to 10
- When health reaches 0, no actions can be performed
- Restore health by cooking meals in the kitchen

### Resource Management
- **Water**: Used for watering plants. Different plants require different amounts of water.
- **Action Points**: Each action (planting, harvesting, watering) costs 1 point. You have 20 points per day.
- **Money**: Used to buy seeds at the shop.

### Cooking System
The kitchen allows you to prepare meals from harvested crops to restore health:
- Vegetable Soup (Cabbage): +20 HP
- Bean Stew (Beans): +30 HP
- Corn Porridge (Maize): +25 HP
- Roasted Sweet Potato (Sweet Potato): +40 HP

A daily recommended meal provides 20% extra health restoration.

## Level Progression

### Level 1
- 2x2 grid (4 plots)
- Goal: Harvest 1 of each crop type

### Level 2
- 3x3 grid (9 plots)
- Goal: Harvest 3 of each crop type

### Level 3
- 4x4 grid (16 plots)
- Goal: Harvest 5 of each crop type

## File Structure
- **main.lua**: Main game file containing game logic and rendering
- **animation.lua**: Handles character animation and movement
- **anim8.lua**: Animation library for LÖVE (by Kikito)
- **conf.lua**: LÖVE configuration file
- **art/**: Directory containing game assets
  - Background images
  - Crop sprites at different growth stages
  - Character sprites
  - UI elements

## Credits
- Game Engine: [LÖVE2D](https://love2d.org/)
- Animation Library: [anim8](https://github.com/kikito/anim8) by Yihan Guo
- Game Development: [Yujiawen Li, Jiafan Luo, Wenshan Mu, Bingyan Huang, Yihan Guo]

---

This game was developed as an educational tool to teach sustainable agriculture practices. All content and assets are intended for educational purposes.
