extends StaticBody2D
class_name Forge

# --- SIGNALS ---

signal temperature_changed(new_temp : int)
signal heated_item_ready(slot_index : int) # fired when an item finishes smelting and becomes "heated"

# --- Editable / Exports

@export var size: Array[int] = [4, 3]

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var forge_manager: ForgeManager = $Forge_Manager
@onready var bellows_manager: BellowsManager = $Bellows_Manager
@onready var recipe_tester: RecipeTester = $RecipeTester

@export var recipes: Array[RecipeData]

@export var active_recipe: RecipeData

@onready var fuel_inventory: InventorySystem = %fuel_inventory
@onready var smeltable_inventory: InventorySystem = %smeltable_inventory

const ITEM_NOTIFICATION = preload("res://Scenes/item_notification.tscn")
@onready var item_noti_location: Node2D = $ItemNotiLocation

# --- Forge State

enum FORGE_STATES { OFF, HEATING, SMELTING, COOLING }
var current_state: FORGE_STATES = FORGE_STATES.OFF

@export var bellows_boost: float = 1.0        # extra deg/sec when bellows pumped
@export var bellows_buffer_decay_rate: float = 0.5 # how quickly bellows buffer decays (deg/sec)
@export var bellows_buffer_max: float = 8.0   # maximum temporary boost from bellows

var current_temp: float = 0.0
var current_max_temp: int = 0                # target temp from current fuel(s)
var current_fuel: ItemStack = null
var next_fuel: ItemStack = null
var all_fuel: Array[ItemStack] = []

var output_queue: Array[ItemStack] = []
var current_noti: ItemNotification = null

# smelting bookkeeping
# Each entry: { slot_index:int, remaining_time:float, melting_point:int, source_slot:SlotData, heated_result_item_data:ItemData (optional) }
var smelt_jobs: Array = []

# bellows state
var bellows_buffer: float = 0.0              # temporary heat maintain boost (decays over time)

# internal
var fuel_slot_index_in_use: int = -1         # index in fuel_inventory currently consuming
var fuel_burn_time_remaining: float = 0.0    # time remaining on current fuel piece (seconds)

# constants / tuning
const SMELT_TICKS_PER_SECOND := 1.0

# --- Ready ---
func _ready() -> void:
	bellows_manager.bellows_interacted.connect(_bellows_interacted)
	forge_manager.forge_interacted.connect(_forge_interacted)
	
	recipes = Global.load_recipes("res://Data/Recipes/ForgeRecipes/")
	
	fuel_inventory.inventory_updated.connect(fuel_inventory_interacted)
	smeltable_inventory.inventory_updated.connect(smeltable_inventory_interacted)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("test_input"):
		debug_status()
	
	if Global.game_paused:
		return
	
	# heating/cooling behavior every frame
	match current_state:
		FORGE_STATES.OFF:
			_passive_cool(delta)
		FORGE_STATES.HEATING:
			_heating_process(delta)
			_process_smelt_jobs(delta)
		FORGE_STATES.SMELTING:
			_heating_process(delta)
			_process_smelt_jobs(delta)
		FORGE_STATES.COOLING:
			_passive_cool(delta)

	# bellows buffer decay
	if bellows_buffer > 0.0:
		bellows_buffer = max(0.0, bellows_buffer - bellows_buffer_decay_rate * delta)

	# Emit temperature change to any listeners on significant change
	emit_signal("temperature_changed", int(round(current_temp)))

# --- Heating process specifics ---
func _heating_process(delta: float) -> void:
	var effective_heating_rate = Global.base_heating_rate * (1.0 + (bellows_buffer / bellows_buffer_max))
	var target = current_max_temp
	if target <= 0:
		# no fuel to aim for - switch to cooling state
		print("No fuel to aim for")
		out_of_fuel()
		return

	if current_temp < target:
		current_temp += effective_heating_rate * 10.0 * delta
		if current_temp >= target:
			current_temp = target
			# If we reached the current fuel's max, check for higher tier fuels in other fuel slots
			var higher = higher_temp_fuel()
			if higher:
				current_max_temp = higher.item_data.burn_temp
				next_fuel = higher
			else:
				pass
	
	elif current_temp > target:
		current_temp = max(target, current_temp - Global.base_cooling_rate * delta * 5.0)
		if current_temp <= target:
			current_temp = target
	
	if current_fuel:
		#var consumption_rate = delta / current_fuel.item_data.burn_time # fraction per secon
		fuel_burn_time_remaining = max(0.0, fuel_burn_time_remaining - (delta * (1.0 / current_fuel.item_data.burn_time) * 1.0))
		fuel_burn_time_remaining -= delta
		if fuel_burn_time_remaining <= 0.0:
			if has_fuel():
				_prepare_next_fuel()
			else:
				print("After consumption, out of fuel")
				out_of_fuel()

# --- Passive cooling (no active fuel) ---
func _passive_cool(delta: float) -> void:
	# If bellows_buffer exists, it will slow down cooling
	var effective_cooling = Global.base_cooling_rate * (1.0 - min(0.9, bellows_buffer / bellows_buffer_max))
	current_temp = max(0.0, current_temp - effective_cooling * delta * 10.0)
	if current_temp <= 0.0:
		current_temp = 0.0
		current_state = FORGE_STATES.OFF

# --- Fuel handling utilities ---
func has_fuel() -> bool:
	for stack in fuel_inventory.inventory_slots_stacks:
		if not stack:
			continue
		if not stack.item_data:
			continue
		if stack.item_data.burnable and stack.quantity > 0:
			return true
	return false

func get_fuel() -> Array[ItemStack]:
	var fuel: Array[ItemStack] = []
	for stack in fuel_inventory.inventory_slots_stack:
		if not stack:
			continue
		if not stack.item_data:
			continue
		if stack.item_data.burnable and stack.quantity > 0:
			fuel.append(stack)
	return fuel

func _prepare_next_fuel() -> void:
	debug_status()
	print("Preparing fuel")
	if next_fuel:
		current_fuel = next_fuel
		print("Next fuel already queued. Using it.")
	else:
		print("No fuel queued. Getting a new one.")
		all_fuel = get_fuel()
		print(get_fuel())
		if all_fuel.size() == 0:
			print("Prepared size = 0")
			out_of_fuel()
			return
		current_fuel = all_fuel[0]
	current_max_temp = current_fuel.item_data.burn_temp
	fuel_burn_time_remaining = current_fuel.item_data.burn_time
	fuel_slot_index_in_use = fuel_inventory.inventory_slots_stacks.find(current_fuel)
	if fuel_slot_index_in_use < 0:
		fuel_slot_index_in_use = -1
	_consume_current_fuel_unit()

func _consume_current_fuel_unit() -> void:
	# remove one unit of current_fuel from inventory. Then if there is more in all_fuel, continue; else check overall fuel.
	if not current_fuel:
		return
	var index = fuel_inventory.inventory_slots_stacks.find(current_fuel)
	if index >= 0:
		fuel_inventory.remove_single_item(current_fuel.item_data, index)
	else:
		# fallback: try to find item by identity in all_fuel and remove
		for i in fuel_inventory.inventory_slots_stacks.size():
			var s = fuel_inventory.inventory_slots_stacks[i]
			if s == current_fuel:
				fuel_inventory.remove_single_item(current_fuel.item_data, i)
				break

func higher_temp_fuel() -> ItemStack:
	# check queued fuel in inventory (other than current_fuel) to see if any has higher burn_temp than current_max_temp
	for stack in get_fuel():
		if stack == null:
			continue
		if stack == current_fuel:
			continue
		if stack.item_data.burnable:
			if stack.item_data.burn_temp > current_max_temp:
				return stack
	return null

func out_of_fuel() -> void:
	current_state = FORGE_STATES.COOLING
	current_fuel = null
	current_max_temp = 0
	fuel_burn_time_remaining = 0.0
	print("Out of fuel; forge cooling")

# --- Smeltables Systems ---
func _process_smelt_jobs(delta: float) -> void:
	if current_temp <= 0: 
		return
	
	# Cleanup invalid jobs (items removed)
	smelt_jobs = smelt_jobs.filter(func(job):
		for slot_index in job["slot_indexes"]:
			var stack = smeltable_inventory.inventory_slots_stacks[slot_index]
			if not stack or not stack.item_data:
				return false
		return true
	)
	
	var smeltables = get_smeltables()
	if smeltables.is_empty():
		smelt_jobs.clear()
		current_state = FORGE_STATES.HEATING
		return
	
	for i in range(smeltable_inventory.inventory_slots_stacks.size()):
		var stack = smeltable_inventory.inventory_slots_stacks[i]
		if not stack or not stack.item_data:
			continue

		# Skip if this stack is already in a job
		var already_in_job := false
		for j in smelt_jobs:
			if i in j["slot_indexes"]:
				already_in_job = true
				break
		if already_in_job:
			continue

		# --- Try combination recipe (multi-slot)
		var combo_recipe := recipe_tester._find_combination_recipe(smeltable_inventory, recipes)
		if combo_recipe:
			var required_indexes: Array[int] = []
			for ing in combo_recipe.ingredients:
				for idx in range(smeltable_inventory.inventory_slots_stacks.size()):
					var s = smeltable_inventory.inventory_slots_stacks[idx]
					if s and s.item_data == ing and idx not in required_indexes:
						required_indexes.append(idx)
						break

			if required_indexes.size() == combo_recipe.ingredients.size():
				_start_smelt_job(required_indexes, combo_recipe)
				continue

		# --- Try single-item recipe
		var single_recipe := recipe_tester._find_single_recipe(stack.item_data, recipes)
		if single_recipe:
			_start_smelt_job([i], single_recipe)
			continue

	# --- Process active jobs
	for job in smelt_jobs:
		var melt_point: int = job["melting_point"]
		if current_temp >= melt_point:
			job["remaining_time"] -= delta
			if job["remaining_time"] <= 0.0:
				_complete_smelting_job(job)

	# Remove finished jobs
	smelt_jobs = smelt_jobs.filter(func(job): return job["remaining_time"] > 0.0)

func _start_smelt_job(slot_indexes: Array[int], recipe: RecipeData) -> void:
	print("Starting smelt job for slots:", slot_indexes, "recipe:", recipe.recipe_name)
	var melt_point := 0
	for ing in recipe.ingredients:
		if ing.melting_point > melt_point:
			melt_point = ing.melting_point

	var new_job := {
		"slot_indexes": slot_indexes,
		"remaining_time": float(recipe.time_to_make),
		"melting_point": melt_point,
		"recipe": recipe
	}
	smelt_jobs.append(new_job)
	current_state = FORGE_STATES.SMELTING

func _complete_smelting_job(job: Dictionary) -> void:
	var slot_indexes: Array[int] = job["slot_indexes"]
	var recipe: RecipeData = job["recipe"]

	print("Completing smelt job for slots", slot_indexes, " → ", recipe.output[0].name)

	# Consume input items
	for idx in slot_indexes:
		var stack = smeltable_inventory.inventory_slots_stacks[idx]
		if stack:
			smeltable_inventory.remove_single_item(stack.item_data, idx)

	# Place result in the first slot (or next available)
	var output_item: ItemData = recipe.output[0]
	var item_stack: ItemStack = ItemStack.new()
	item_stack.item_data = output_item
	item_stack.cur_temp = current_temp
	item_stack.quantity = recipe.output.size()
	
	output_queue.append(item_stack)
	if not current_noti:
		spawn_item_notif(output_item)
	emit_signal("heated_item_ready", 0)
	
	#if smeltable_inventory.pick_up_slot_data(slot_data):
		#print("Successful")
		#
	#else:
		#print("No room")

	# If no smeltables left, go back to heating or cooling
	if not has_smeltable():
		current_state = FORGE_STATES.HEATING

func spawn_item_notif(item_data: ItemData) -> void:
	var noti = ITEM_NOTIFICATION.instantiate()
	add_child(noti)
	noti.position = item_noti_location.position
	noti.update_noti(item_data)
	current_noti = noti

# --- Inventory Interactions ---
func fuel_inventory_interacted(_inventory_system: InventorySystem, _index: int) -> void:
	print("Fuel inventory interacted")
	#if not has_fuel():
		#out_of_fuel()

func smeltable_inventory_interacted(_inventory_system: InventorySystem, _index: int) -> void:
	print("Smeltable inventory interacted")
	if has_smeltable():
		print(get_smeltables())

func _forge_interacted() -> void:
	var player_held_stack = Global.active_slot_stack
	if player_held_stack and player_held_stack.item_data is ItemDataTool:
		if output_queue.size() > 0:
			if player_held_stack.item_data.tool_type == "Tongs" and player_held_stack.item_data.held_slot == null: 
				print("Pick up item with tongs")
				player_held_stack.item_data = ItemManager.get_item_by_name("tongs")
				player_held_stack.item_data.held_slot = output_queue[0]
				ItemManager._start_cooling_job(output_queue[0].item_data, player_held_stack.item_data, Global.player.inventory)
				output_queue.remove_at(0)
				if output_queue.size() <= 0:
					current_noti.queue_free()
				else:
					current_noti.update_noti(output_queue[0].item_data)
				Global.player.inventory.inventory_updated.emit(Global.player.inventory, Global.active_slot_index)
	else:
		Global.core.toggle_forge_ui(self)

func light_forge() -> void:
	if has_fuel() and not current_state == FORGE_STATES.HEATING or not current_state == FORGE_STATES.SMELTING:
		_prepare_next_fuel()
		current_state = FORGE_STATES.HEATING
		print("Light Forge")
	else:
		print("No fuel available")
		return

# --- Smelting System ---
func has_smeltable() -> bool:
	for stack in smeltable_inventory.inventory:
		if not stack:
			continue
		if not stack.item_data:
			continue
		if stack.item_data.smeltable and stack.quantity > 0:
			return true
	return false

func get_smeltables() -> Array[ItemStack]:
	var smeltables: Array[ItemStack] = []
	for stack in smeltable_inventory.inventory:
		if not stack:
			continue
		if not stack.item_data:
			continue
		if stack.item_data.smeltable and stack.quantity > 0:
			smeltables.append(stack)
	return smeltables

# --- Bellows Interaction
func _bellows_interacted() -> void:
	print("Bellows used")
	if not current_state == FORGE_STATES.OFF:
		bellows_buffer = min(bellows_buffer_max, bellows_buffer + bellows_boost)
		debug_status()

# --- Helper debug method to print current status ---
func debug_status() -> void:
	print("\n---- Forge Debug ----")
	print("Forge status: state=", current_state, " temp=", current_temp, " max_target=", current_max_temp, " burn_time=", fuel_burn_time_remaining)
	print("Current fuel:", current_fuel)
	print("Bellows buffer:", bellows_buffer)
	print("Smelt jobs:", smelt_jobs.size())
