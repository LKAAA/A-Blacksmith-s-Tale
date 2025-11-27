extends Control

var active = false
var padding_x = 6
var padding_y = 12

const STAT_POPUP_LABEL = preload("uid://5whwtrtjevsn")

@onready var stat_section: VBoxContainer = %StatSection
@onready var item_popup: PopupPanel = %ItemPopup

@onready var item_sprite: TextureRect = %ItemSprite
@onready var item_name_label: RichTextLabel = %ItemNameLabel
@onready var item_type_label: RichTextLabel = %ItemTypeLabel
@onready var item_description_label: RichTextLabel = %ItemDescriptionLabel
@onready var item_rarity_label: RichTextLabel = %ItemRarityLabel

var grabbed_slot: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_popup.unfocusable = true
	item_popup.size = Vector2.ZERO

func _process(delta: float) -> void:
	if active:
		update_popup_position()

func update_popup_position() -> void:
	if grabbed_slot: 
		padding_x = 14
		padding_y = 14
	else:
		padding_x = 8
		padding_y = 10
	item_popup.size = Vector2.ZERO
	var mouse := get_viewport().get_mouse_position()
	var rect := get_viewport_rect()
	
	var popup_size = item_popup.size
	
	var x := clampf(mouse.x + padding_x, 0, rect.size.x - popup_size.x)
	var y := clampf(mouse.y + padding_y, 0, rect.size.y - popup_size.y)
	
	item_popup.position = Vector2(x, y)

func update_item_popup(item_data: ItemData) -> void:
	if not item_data: return
	
	clear_stats()
	
	item_sprite.texture = item_data.sprite
	item_name_label.text = item_data.pretty_name
	item_description_label.text = item_data.description
	item_rarity_label.text = item_data.rarity
	
	match item_data.type:
		ItemManager.ITEM_TYPES.MATERIAL:
			item_type_label.text = "Material"
		ItemManager.ITEM_TYPES.TOOL:
			item_type_label.text = "Tool"
		ItemManager.ITEM_TYPES.CONSUMABLE:
			item_type_label.text = "Consumable"
			fill_consumable_stats(item_data)
		ItemManager.ITEM_TYPES.WEAPON:
			item_type_label.text = "Weapon"

func fill_consumable_stats(cons: ItemDataConsumable) -> void:
	if cons.heal_value != 0:
		if cons.heal_value > 0:
			add_stat_label("+%d Health" % cons.heal_value, "green")
		else:
			add_stat_label("%d Health" % cons.heal_value, "red")
	
	if cons.stamina_value != 0:
		add_stat_label("+%d Stamina" % cons.stamina_value, "yellow")
	
	if cons.mana_value != 0:
		add_stat_label("+%d Mana" % cons.mana_value, "blue")

func add_stat_label(text: String, color: String) -> void:
	var lbl: RichTextLabel = STAT_POPUP_LABEL.instantiate()
	lbl.text = "[color=%s]%s[/color]" % [color, text]
	stat_section.add_child(lbl)

func clear_stats() -> void:
	for child in stat_section.get_children():
		child.queue_free()

func show_item_popup(item_data) -> void:
	update_item_popup(item_data)
	active = true
	
	update_popup_position()  # Ensures correct pos before showing
	item_popup.popup()

func hide_item_popup() -> void:
	active = false
	item_popup.hide()
