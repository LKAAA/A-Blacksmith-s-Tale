class_name ItemData extends Resource

@export var pretty_name: String
@export var id: int                            # Currently at 16
@export var description: String
@export var sprite: Texture2D = preload("res://Assets/debug_texture.png")
@export var type: ItemManager.ITEM_TYPES = ItemManager.ITEM_TYPES.MATERIAL
@export var rarity: String = "Common"
@export var sellable: bool = true
@export var buy_price: int = 1
@export var sell_price: int = 1

@export var stack_size: int = 999
@export var quest_item: bool = false

@export_category("Material Info")

@export var burnable: bool = false
@export var burn_time: int = 0000
@export var burn_temp: int = 0000

@export var smeltable: bool = false
@export var melting_point: int = 0000 # CELSIUS
