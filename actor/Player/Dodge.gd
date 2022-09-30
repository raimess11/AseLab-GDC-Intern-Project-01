extends Node2D

#list enemy yang lagi aim player beserta state indikasi
var enemyList: Array = []
var enemyNeedToBeDodged: Array = []
var enemyListWithIndication: Dictionary = {}
var bulletList: Array = []
var listOfBulletNeedToBeDodged: Dictionary = {}

#bullet yang perlu didodge
var bullet

#weakref
var wr

#jika player gagal dodge
var enemyDodgingFailed: Array = []
var dodgingFailed = false

#untuk chain attack
var isDodging = false
var index = 0

#timer dan cooldown
onready var timer = $Timer
onready var cooldown = $Cooldown
var isCooldown = false

enum INDICATION_STATE{
	black,
	yellow,
	red
}

func _process(delta):
	bulletList = get_tree().get_nodes_in_group("bullets")
	#jika dodgingFailed maka fitur dodging di pause
	if dodgingFailed:
		if enemyDodgingFailed == [] or enemyDodgingFailed[1] == INDICATION_STATE.black:
			enemyDodgingFailed.clear()
			dodgingFailed = false
			return
		else:
			enemyDodgingFailed[1] = enemyListWithIndication[enemyDodgingFailed[0]]

#add enemy pada list, panggil fungsi jika player di aim
func addEnemyList(enemyName: String, indicatorState):
	enemyListWithIndication[enemyName] = indicatorState
	if !enemyList.has(enemyName):
		enemyList.append(enemyName)
	

#delete enemy pada list, panggil jika enemy tidak aim player lagi
func deleteEnemyList(enemyName: String):
	enemyListWithIndication.erase(enemyName)
	enemyList.erase(enemyName)


#mengatur input
func _input(event):
	var x = enemyNeedToBeDodged.size() > 0
	if !dodgingFailed:
		if Input.is_action_just_pressed("dodge") and x:
			dodging()
	else:
		print("failed")

#jika enemy kuning, maka add enemy dan bullet pada list yang harus didodge
func yellowTriggered(enemyName, bullet):
	enemyNeedToBeDodged.append(enemyName)
	listOfBulletNeedToBeDodged[bullet.name.split("_", true)[1]] = bullet

func redTriggered(bullet):
	pass

#jika enemy hitam
func blackTriggered(enemyName, bulletName):
	if enemyNeedToBeDodged.has(enemyName):
		enemyNeedToBeDodged.erase(enemyName)
	if listOfBulletNeedToBeDodged.has(enemyName):
		listOfBulletNeedToBeDodged.erase(enemyName)

#jika bullet hilang, maka bullet dan enemy didelete dari list yang harus didodge
func bulletQueueFree(bulletName):
	print("bullet deleted")
	if enemyNeedToBeDodged.has(bulletName):
		enemyNeedToBeDodged.erase(bulletName)
	if listOfBulletNeedToBeDodged.has(bulletName):
		listOfBulletNeedToBeDodged.erase(bulletName)


func dodging():
	if !enemyListWithIndication.has(enemyNeedToBeDodged[0]):
		print("enemy doesn't exist")
		endDodging()
		return
	if enemyListWithIndication[enemyNeedToBeDodged[0]] == INDICATION_STATE.yellow:
		print("dodging failed, too early")
		endDodging()
		dodgingFailed = true
	elif enemyListWithIndication[enemyNeedToBeDodged[0]] == INDICATION_STATE.red:
		if !isDodging:
			isDodging = true
			bullet = listOfBulletNeedToBeDodged[enemyNeedToBeDodged[0]]
			wr = weakref(bullet)
			if (!wr.get_ref()):
				print("bullet doesn't exist")
				endDodging()
				return
			bullet.get_node("Sprite").modulate = Color(1.0,0.0,0.0,1.0)
			beginDodging()
			return
		bullet = listOfBulletNeedToBeDodged[enemyNeedToBeDodged[0]]
		var wr = weakref(bullet)
		if (!wr.get_ref()):
			print("bullet doesn't exist")
			endDodging()
			return
		print(bullet)
		bullet.get_node("Sprite").modulate = Color(1.0,1.0,1.0,1.0)
		bullet.set_collision_mask_bit(1,false)
		bullet.isDodged = true
		bullet.isUneffectedByDodge = true
		listOfBulletNeedToBeDodged.erase(enemyNeedToBeDodged[0])
		enemyNeedToBeDodged.pop_at(0)
		if enemyNeedToBeDodged.size() > 0:
			if listOfBulletNeedToBeDodged.has(enemyNeedToBeDodged[0]):
				bullet = listOfBulletNeedToBeDodged[enemyNeedToBeDodged[0]]
			elif enemyList.has(enemyNeedToBeDodged[0]) and enemyListWithIndication[enemyNeedToBeDodged[0]] == INDICATION_STATE.yellow:
				beginDodging()
				return
			else:
				endDodging()
				return
			wr = weakref(bullet)
			if (!wr.get_ref()):
				print("bullet doesn't exist")
				endDodging()
				return
			print(bullet)
			bullet.get_node("Sprite").modulate = Color(1.0,0.0,0.0,1.0)
			if !isDodging:
				isDodging = true
				beginDodging()
		else:
			endDodging()

func _on_Timer_timeout():
	endDodging()

#memulai dodging
func beginDodging():
	Engine.time_scale = 0.05
	timer.wait_time = 1000000.0 * Engine.time_scale
	timer.start()

func beginCooldown():
	cooldown.wait_time = 1.0
	cooldown.start()

func endDodging():
	isDodging = false
	Engine.time_scale = 1.0
	listOfBulletNeedToBeDodged.clear()
	enemyNeedToBeDodged = []
