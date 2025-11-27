class_name RecipeTester extends Node2D

func test_inventory(recipe: RecipeData, inventory: InventorySystem = null) -> bool:
	if inventory:
		for ingredient in recipe.ingredients:
			var amount_of_ing = recipe.ingredients.count(ingredient)
			var held_count: int = 0
			print(amount_of_ing)
			for slot in inventory.inventory:
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

func _find_single_recipe(item: ItemData, recipes: Array[RecipeData]) -> RecipeData:
	for recipe in recipes:
		if recipe.ingredients.size() == 1 and recipe.ingredients[0] == item:
			return recipe
	return null

func _find_combination_recipe(inventory: InventorySystem, recipes: Array[RecipeData]) -> RecipeData:
	for recipe in recipes:
		if recipe.ingredients.size() == 2:
			var first = recipe.ingredients[0]
			var second = recipe.ingredients[1]
			var has_first = false
			var has_second = false

			for slot in inventory.inventory:
				if not slot or not slot.item_data:
					continue
				if slot.item_data == first:
					has_first = true
				elif slot.item_data == second:
					has_second = true

			if has_first and has_second:
				return recipe
	return null
