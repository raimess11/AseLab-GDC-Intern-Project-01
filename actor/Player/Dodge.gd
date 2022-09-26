extends Node2D

#list enemy yang lagi aim player beserta state indikasi
var enemyList: Array = []
var enemyNeedToBeDodged: Array = []
var enemyListWithIndication: Dictionary = {}
var bulletList: Array = []
var listOfBulletNeedToBeDodged: Dictionary = {}
var bullet

#jika player gagal dodge
var enemyDodgingFailed: Array = []
var dodgingFailed = false

#untuk chain attack
var chainAttack = false
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

#jika enemy kuning, maka add enemy pada list enemy yang harus didodge
func yellowTriggered(enemyName):
	enemyNeedToBeDodged.append(enemyName)

#jika enemy merah, maka add bullet pada list enemy yang harus didodge
func redTriggered(bullet):
	listOfBulletNeedToBeDodged[bullet.name.split("_", true)[1]] = bullet

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
		endChainAttack()
		return
	if enemyListWithIndication[enemyNeedToBeDodged[0]] == INDICATION_STATE.yellow:
		endChainAttack()
		dodgingFailed = true
	elif enemyListWithIndication[enemyNeedToBeDodged[0]] == INDICATION_STATE.red:
		bullet = listOfBulletNeedToBeDodged[enemyNeedToBeDodged[0]]
		var wr = weakref(bullet)
		if (!wr.get_ref()):
			print("bullet doesn't exist")
			endChainAttack()
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
			else:
				endChainAttack()
				return
			wr = weakref(bullet)
			if (!wr.get_ref()):
				print("bullet doesn't exist")
				endChainAttack()
				return
			print(bullet)
			bullet.get_node("Sprite").modulate = Color(1.0,0.0,0.0,1.0)
			if !chainAttack:
				chainAttack = true
				beginChainAttack()
		else:
			endChainAttack()

func _on_Timer_timeout():
	endChainAttack()

func beginChainAttack():
	Engine.time_scale = 0.05
	timer.wait_time = 10.0 * Engine.time_scale
	timer.start()

func beginCooldown():
	cooldown.wait_time = 1.0
	cooldown.start()

func endChainAttack():
	index = 0
	chainAttack = false
	Engine.time_scale = 1.0
	listOfBulletNeedToBeDodged.clear()
	enemyNeedToBeDodged = []
