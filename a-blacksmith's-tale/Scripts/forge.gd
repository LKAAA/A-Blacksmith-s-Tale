extends StaticBody2D
class_name Forge

@export var size: Array[int] = [4, 3]

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var forge_manager: ForgeManager = $Forge_Manager
@onready var bellows_manager: BellowsManager = $Bellows_Manager
@onready var recipe_tester: RecipeTester = $RecipeTester

@export var recipes: Array[RecipeData]

@export var active_recipe: RecipeData

enum FORGE_STATES { INACTIVE, ACTIVE, COMPLETE }
var current_state: FORGE_STATES 

func _ready() -> void:
	bellows_manager.bellows_interacted.connect(_bellows_interacted)
	forge_manager.forge_interacted.connect(_forge_interacted)
	
	Global.unpaused.connect(unpaused_game)
	Global.paused.connect(paused_game)
	
	recipes = Global.load_recipes("res://Data/Recipes/ForgeRecipes/")

# When you interact with the forge section
# Check held item
# If held item is the required ingredients for any of the recipies
# Start forge timer and take items from your inventory
# After timer is complete
# If player clicks on forge
# Give player completed item

func _forge_interacted() -> void:
	match current_state:
		FORGE_STATES.INACTIVE:
			print("Try to start forging")
			if Global.active_slot:
				print(Global.active_slot.item_data.name)
				for recipe in recipes:
					print(recipe.recipe_name)
					if recipe_tester.test_item(recipe, Global.active_slot.item_data):
						print("Holding an item for " + recipe.recipe_name)
						if recipe_tester.test_inventory(recipe, Global.player.inventory):
							print("Has all items for " + recipe.recipe_name)
							active_recipe = recipe
							begin_forging()
		FORGE_STATES.ACTIVE:
			print("Currently Forging")
		FORGE_STATES.COMPLETE:
			print("Try to pick up")
			var output_count = active_recipe.output.size()
			for output in active_recipe.output:
				var slot_data = SlotData.new()
				slot_data.item_data = output
				slot_data.quantity = 1
				if Global.player.inventory.pick_up_slot_data(slot_data):
					print("Picked up")
					output_count -= 1
				else:
					print("Inventory Full")
			
			if output_count <= 0:
				active_recipe = null
				current_state = FORGE_STATES.INACTIVE
			else:
				print("Couldn't pick up completed items. Probably means inventory was full.")
		
		#if ready_to_pickup:
			
		#else:
			#print("Try to start curing")
			
	#else:
		#print("Already on")
	#animated_sprite_2d.play("On")

func begin_forging() -> void:
	# for each type of item in array
	# Remove the amount of that item from the inventory
	var item_count = {}
	
	for item in active_recipe.ingredients:
		if item_count.has(item):
			item_count[item] += 1
		else:
			item_count[item] = 1
	
	var ingredient_list = active_recipe.ingredients
	Global.player.inventory.remove_items(ingredient_list[0], ingredient_list.size())
	# This should only support items of the same type which 
	
	timer.start(active_recipe.time_to_make)
	current_state = FORGE_STATES.ACTIVE
	animated_sprite_2d.play("On")
	print("Start Forging")

func _bellows_interacted() -> void:
	print("Bellows interacted with")

func paused_game() -> void:
	if current_state == FORGE_STATES.ACTIVE: 
		timer.paused = true

func unpaused_game() -> void:
	if current_state == FORGE_STATES.ACTIVE: 
		timer.paused = false

func _on_timer_timeout() -> void:
	print("Forge done")
	animated_sprite_2d.play("Idle")
	current_state = FORGE_STATES.COMPLETE
