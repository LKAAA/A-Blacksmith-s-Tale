# A Blacksmith's Tale
**Built with:** Godot 4 · GDScript · Aseprite · Git

[Game Design Document](https://docs.google.com/document/d/18OwW4vAFyJ17F60p2HXdpYzGm3l00GWUh6i5hAP_SC0/edit?usp=sharing)

*A Blacksmith's Tale* is a fantasy blacksmithing RPG and life simulator built from the ground up in Godot 4. You inherit a small forge outside the walled city of Koran and build a life around gathering materials, crafting custom weapons, running your storefront, and navigating relationships with the local guild.

## Gameplay previews

<img width="426" height="240" alt="Video2" src="https://github.com/user-attachments/assets/c1b50653-f074-499a-8598-196bc7efa613" />

*Small preview of the inventory and item systems*

<img width="426" height="240" alt="Video3" src="https://github.com/user-attachments/assets/10dfd903-691e-4637-9eea-ede77ba9afe3" />

*Preview of the expansive dialogue system; Including giving the player items, updating variables, and player choices*

<img width="426" height="240" alt="Video 4 (1)" src="https://github.com/user-attachments/assets/ec88756e-cc58-4ba9-b788-4a7ef111c13d" />

*Preview of the day/night cycle and npc systems*

---

## Core Architecture & Systems

The primary engineering goal of this project is **data-driven modularity**—ensuring new weapons, recipes, NPCs, and dialogue can be added via data resources rather than hardcoding multiple scripts.

### Modular Item & Equipment Framework
Instead of writing isolated logic for individual tools or weapons, items are assembled dynamically from reusable resource components:
* **Data Structure:** `Item` $\rightarrow$ `Material` + `Type` + `Components` (e.g., Blade, Hilt, Guard, Pommel, Shaft) + `Stats` + `Behaviors`.
* **Runtime Handling:** Resource-based definitions drive stackable inventories, crafting stations, and modular weapon/tool assembly.

### Multi-Stage Forging State Machine
Blacksmithing is built around an interactive thermal state machine (`OFF` $\rightarrow$ `HEATING` $\rightarrow$ `SMELTING` $\rightarrow$ `COOLING`). Players manage bellows airflow, coal/coke fuel, clinker buildup, temperature thresholds, quenching, and rune etching to determine final item stats and quality.

### Data-Driven NPC & Dialogue Systems
* **Schedules & Navigation:** NPCs follow dynamic daily schedules using obstacle-aware pathfinding.
* **Conditional Dialogue:** Conversations evaluate live world-state flags—including time of day, weather, friendship tier, schedule state, and prior choices—to branch dialogue, trigger events, and grant items without hardcoded NPC scripts.

### World & Progression
* **10 Independent Skills:** Mining, Foraging, Leather-working, Woodworking, Forging, Assembling, Rune Etching, Combat, Cooking, and Fishing—each scaling independently while feeding into overall character stats.
* **World Simulation:** Global calendar tracking days, seasons, weather states, and persistent save/load serialization.

---

## Repository Structure
* `/a-blacksmith's-tale` — Core Godot 4 project files, GDScript systems, scenes, and in-game assets.
* `/Aseprite` — Source pixel art and sprite animation files.
* `/Leonardo` — Visual layout sketches and planning diagrams.
