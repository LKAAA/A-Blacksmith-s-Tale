class_name CuringRack extends StaticBody2D

@export var size: Array[int] = [2, 2]

@onready var interact_area: Interactable = $InteractArea
@onready var recipe_tester: RecipeTester = $RecipeTester
@onready var timer: Timer = $Timer
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

@export var recipes: Array[RecipeData]

var active_recipe: RecipeData
var active: bool = false
var ready_to_pickup: bool = false

func _ready() -> void:
	interact_area.interact = Callable(self, "_on_interact")
	recipes = Global.load_recipes("res://Data/Recipes/TanningRecipes/")
	
	Global.unpaused.connect(unpaused_game)
	Global.paused.connect(paused_game)

func _on_interact() -> void:
	if not active:
		if ready_to_pickup:
			print("Pick up")
			for output in active_recipe.output:
				var item_stack = ItemStack.new()
				item_stack.item_data = output
				item_stack.quantity = 1
				if Global.player.inventory.pick_up_item_stack(item_stack):
					ready_to_pickup = false
					active_recipe = null
					sprite_2d.play("Idle")
					print("Picked up")
				else:
					print("Inventory Full")
		else:
			print("Try to start curing")
			if Global.active_slot_stack:
				for recipe in recipes:
					if recipe_tester.test_item(recipe, Global.active_slot_stack.item_data):
						active_recipe = recipe
						begin_curing()
						break
	else:
		print("Already on")

func begin_curing() -> void:
	# Remove ingredient from inventory
	# Start timer equivalent to recipe's time
	for slot in Global.player.inventory.inventory_slots_stacks:
		if slot:
			if slot.item_data == active_recipe.ingredients[0]:
				Global.player.inventory.remove_single_item(active_recipe.ingredients[0])
				timer.start(active_recipe.time_to_make)
				active = true
				sprite_2d.play("Active")
				print("Start Curing")

# Change this to check active item vs inventory
# Add ya know actually turning the item into something different

func paused_game() -> void:
	if active:
		print("Paused tanning")
		timer.paused = true

func unpaused_game() -> void:
	if active:
		print("unpaused tanning")
		timer.paused = false

func _on_timer_timeout() -> void:
	print("DONE")
	active = false
	ready_to_pickup = true
