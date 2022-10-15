extends Label

var time = 0

func _process(delta):
	time += delta
	var mils = fmod(time,1)*100
	var secs = fmod(time,60)
	var mins = fmod(time,60*60)/60
	
	var time_passed = "%02d:%02d:%02d" % [mins,secs,mils]
	text = time_passed

