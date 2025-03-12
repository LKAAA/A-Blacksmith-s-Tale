class_name RecipeTester extends Node2D

func test_inventory(recipe: RecipeData, inventory: InventoryData = null) -> bool:
	var result: bool = false
	
	if inventory:
		for ingredient in recipe.ingredients:
			var amount_of_ing = recipe.ingredients.count(ingredient)
			for slot in inventory.inventory_slots:
				if slot:
					if slot.item_data == ingredient:
						if slot.quantity >= amount_of_ing:
							result = true
						else: 
							result = false
	
	return result

func test_item(recipe: RecipeData, item: ItemData) -> bool:
	var result: bool = false
	if item:
		if recipe.ingredients.count(item) == 1 and recipe.ingredients.size() == 1:
			result = true
		else:
			result = false
	
	return result
