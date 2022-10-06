extends Node2D

#Variabel untuk menggerakkan sprite
var velocity = Vector2.ZERO

#Atur kecepatan enemy
var run_speed = 50

#Atur akselerasi enemy
var accel = 300

#Membuat enemy bergerak saat wander dalam posisi yang sudah ditetapkan (target_position)
func accelerate_to_point(point, acceleration_scalar):
	var direction = (point - global_position).normalized()
	var acceleration_vector = direction * acceleration_scalar
	accelerate(acceleration_vector)

#Memungkinkan enemy untuk bergerak
func accelerate(acceleration_vector):
	velocity += acceleration_vector
	velocity = velocity.clamped(run_speed)
