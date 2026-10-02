# A Blacksmith's Tale

### A blacksmithing indie RPG / life simulator built in Godot

> **A Blacksmith's Tale** is a personal game-development project focused on building a complete, systems-driven RPG from the ground up.

The project combines **gameplay programming, systems architecture, game design, pixel art, worldbuilding, and technical problem solving** into a single long-term project.

**Built with:** Godot 4 · GDScript · Aseprite · Git

---

## Game Overview

**A Blacksmith's Tale** is a medieval fantasy blacksmithing RPG where the player inherits a small blacksmith shop and builds a life around crafting, exploration, relationships, and eventually competing with or working alongside the established blacksmithing guild.

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

# Repository Structure

```text
A-Blacksmith-s-Tale/
│
├── a-blacksmith's-tale/    # Godot game project
│
├── Aseprite/               # Pixel art and game assets
│
├── Leonardo/               # Worldbuilding / development documentation
│
└── README.md
```

The repository intentionally contains both the **game project** and supporting development material so the project can demonstrate more than the final game itself.

---

# Portfolio & Internship Project

A Blacksmith's Tale is being developed as a long-term **game-development project** alongside my university studies.

The project is intended to demonstrate my ability to:

* Design and implement gameplay systems
* Work with a modern game engine
* Structure larger codebases
* Build reusable systems
* Debug complex interactions between systems
* Design data-driven content
* Work with version control
* Create and integrate 2D game assets
* Design gameplay alongside programming
* Take a game from an initial idea toward a playable product

Rather than presenting the project as a finished commercial game, this repository documents the process of **building a game and learning how its systems should be structured as the project grows**.

---

# 📈 Development Philosophy

The project is intentionally being built incrementally.

Instead of attempting to create the entire game at once, individual systems are prototyped, tested, and refactored as the project grows.

Some examples include:

```text
Prototype
   ↓
Test
   ↓
Identify problems
   ↓
Refactor
   ↓
Convert into reusable system
   ↓
Integrate with the rest of the game
```

This approach allows the project to serve both as a game and as an ongoing exploration of game-engine architecture and gameplay programming.

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

---

## Why this project?

A Blacksmith's Tale is ultimately an experiment in answering a question:

> **How can a game be designed so that adding more content doesn't require rebuilding the systems underneath it?**

The project uses a relatively small blacksmithing RPG as a way to explore that problem through real gameplay systems, architecture, iteration, and development.

**Built to be played. Built to be learned from. Built to grow.**
