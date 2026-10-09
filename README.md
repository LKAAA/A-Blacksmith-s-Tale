# A Blacksmith's Tale

### A blacksmithing indie RPG / life simulator built in Godot

> **A Blacksmith's Tale** is a personal game-development project focused on building a complete, systems-driven RPG from the ground up.

The project combines **gameplay programming, systems architecture, game design, pixel art, worldbuilding, and technical problem solving** into a single long-term project.

**Built with:** Godot 4 · GDScript · Aseprite · Git

---

## Game Overview

**A Blacksmith's Tale** is a medieval fantasy blacksmithing RPG where the player inherits a small blacksmith shop and builds a life around crafting, exploration, relationships, and eventually competing with or working alongside the established blacksmithing guild.

<img width="426" height="240" alt="Video 4 (1)" src="https://github.com/user-attachments/assets/ec88756e-cc58-4ba9-b788-4a7ef111c13d" />

### Core Gameplay

* Blacksmithing and metalworking
* Resource gathering and mining

* Woodworking and foraging
* Leather-working
* Rune etching and magic
* Combat
* Cooking
* Fishing
* NPC schedules and relationships
* Expansive and immersive dialogue system
* Dynamic time, weather, and seasonal systems
* Shop management
* Item and inventory systems
* Modular crafting and equipment systems

---

# Technical Focus

### Systems

| System                   | Purpose                                                                   |
| ------------------------ | ------------------------------------------------------------------------- |
| **Item System**          | Resource-based item definitions and runtime item stacks                   |
| **Crafting System**      | Recipes, materials, components, and crafting stations                     |
| **Blacksmithing System** | Heating, smelting, cooling, quenching, and forging                        |
| **Skill System**         | Multiple player skills with progression and levels                        |
| **NPC System**           | Schedules, interactions, relationships, and dialogue                      |
| **Dialogue System**      | Context-sensitive dialogue based on time, weather, friendship, and events |
| **Time System**          | Global time, days, seasons, weather, and world events                     |
| **AI / Navigation**      | Dynamic navigation and obstacle-aware NPC movement                        |
| **Equipment System**     | Modular weapon/tool components                                            |
| **Magic System**         | Mana flow, rune etching, and magical objects                              |
| **World System**         | Locations designed to support future expansion                            |
| **Save/State Systems**   | Persistent game-world and player progression                              |

---

# Modular Game Architecture

One of the primary technical goals of the project is to avoid creating gameplay systems that only work for one specific object.

For example, rather than implementing a separate system for every individual axe, sword, or tool, the intended architecture allows an item to be constructed from reusable data:

```text
Item
├── Material
├── Type
├── Components
├── Stats
├── Recipe
└── Behaviors
```

This allows the same underlying systems to support many different items.

The same philosophy is being applied to:

* NPCs
* Dialogue
* Crafting recipes
* Interactable objects
* Tools
* Weapons
* Materials
* Locations
* World events

The goal is to make adding new content primarily a **data/content problem rather than a programming problem**.

<img width="426" height="240" alt="Video2" src="https://github.com/user-attachments/assets/c1b50653-f074-499a-8598-196bc7efa613" />

*Small preview of the inventory and item systems*

---

# Blacksmithing System

Blacksmithing is the central gameplay system and is being designed around multiple interacting stages.

### Forge States

```text
OFF
 ↓
HEATING
 ↓
SMELTING
 ↓
COOLING
```

The player manages heat using the forge and bellows, with additional mechanics involving:

* Coal and coke
* Temperature
* Heating and cooling
* Quenching
* Clinker
* Material properties
* Forging components
* Tool and weapon construction

Weapons and tools are constructed from reusable components such as:

```text
Blade
Head
Point
Shaft
Handle
One-Hand Hilt
Two-Hand Hilt
Guard
Pommel
```

This allows a single crafting framework to produce many different equipment configurations.

---

# Skills

The player has ten major skills:

```text
Mining
Foraging
Leather-working
Woodworking
Forging
Assembling
Rune Etching
Combat
Cooking
Fishing
```

Each skill can progress independently, while the player's overall progression affects additional character statistics.

The system is designed so that new skills can be added without requiring the entire progression system to be rewritten.

---

# NPC & Dialogue Systems

<img width="426" height="240" alt="Video3" src="https://github.com/user-attachments/assets/10dfd903-691e-4637-9eea-ede77ba9afe3" />

*Preview of the expansive dialogue system; Including giving the player items, updating variables, and player choices*

NPCs are being designed around data-driven schedules and conditional dialogue.

Dialogue can respond to factors such as:

* Time of day
* Date
* Weather
* Friendship
* Player progression
* Major world events
* NPC schedule
* Previous interactions

The goal is to allow NPC behavior and dialogue to be expanded through data rather than hardcoding every possible conversation into individual NPC scripts and make it easier for not only me as the developer to add new NPC behavior but anyone after me as well.

---

# World Design

The game takes place in a medieval fantasy kingdom containing several settlements and cultures.

The player begins in a small town outside the larger walled city of **Koran**.

Other planned locations include:

* **Illenal** — elven village
* **Urodh** — orc village
* Many more smaller zones and regions.

---

# Technology

### Game Engine

**Godot 4**

### Programming

**GDScript**

### Art

**Aseprite**

### Development Tools

* Git / GitHub
* Visual Studio Code
* Godot Editor
* Aseprite
* Leonardo
* Obsidian

### Concepts Being Applied

* Object-oriented programming
* Data-driven design
* Modular architecture
* Resource-based data structures
* State machines
* Event-driven systems
* Path-finding
* Dynamic navigation
* Component-based gameplay
* Version control
* Debugging and profiling

---

# Current Development

**Status:** In Development

Current development focuses on establishing the core architecture and gameplay systems that will support the larger game.

### Current priorities

* [x] Core player systems
* [x] Item / ItemStack architecture
* [x] Crafting framework
* [x] Blacksmithing mechanics
* [x] Inventory
* [x] NPC framework
* [x] Dialogue framework
* [x] Time and calendar system
* [x] NPC scheduling
* [ ] Skill progression
* [ ] Equipment system
* [ ] Save system
* [ ] Expanded playable village

Development is ongoing, and the architecture will continue to evolve as new gameplay requirements are discovered.

---

# Design Documentation

The project includes separate documentation covering the game's:

* World
* Characters
* Races
* Locations
* Magic
* Items
* Crafting
* Game systems
* Development plans

This documentation is maintained separately from the executable game project to keep design information organized and make larger systems easier to plan before implementation. 
*Available upon request*

# Repo Format

- Aseprite - Contains pixel art files used in the program Aseprite
- Leonardo - Contains planning documents and files drawn in the program Leonardo
- a-blacksmith's-tale - Contains all of Godot Project files including code, assets, etc

