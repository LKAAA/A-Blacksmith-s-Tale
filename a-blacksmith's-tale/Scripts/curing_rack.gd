class_name CuringRack extends StaticBody2D

@onready var interact_area: Interactable = $InteractArea
@onready var recipe_tester: RecipeTester = $RecipeTester

@export var recipes: Array[RecipeData]

func _ready() -> void:
	interact_area.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	print("result: " + str(recipe_tester.test_inventory(recipes[0], Global.player.inventory)))
	print("Use Curing Rack")

# Change this to check active item vs inventory
# Add ya know actually turning the item into something different
