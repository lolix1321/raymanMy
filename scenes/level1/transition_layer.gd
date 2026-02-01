# Skrypt Transition.gd
extends CanvasLayer

func fade_in():
	$AnimationPlayer.play("death_animation")
	await $AnimationPlayer.animation_finished

func fade_out():
	$AnimationPlayer.play_backwards("death_animation")
