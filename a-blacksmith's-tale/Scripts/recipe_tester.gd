class_name RecipeTester extends Node2D

func test_inventory(recipe: RecipeData, inventory: InventoryData = null) -> bool:
	if inventory:
		for ingredient in recipe.ingredients:
			var amount_of_ing = recipe.ingredients.count(ingredient)
			var held_count: int = 0
			print(amount_of_ing)
			for slot in inventory.inventory_slots:
				if slot:
					if slot.item_data == ingredient:
						held_count += slot.quantity
						if held_count >= amount_of_ing:
							return true
	
	return false

func test_item(recipe: RecipeData, item: ItemData) -> bool:
	for ingredient in recipe.ingredients:
		if item == ingredient:
			return true
	
	return false
