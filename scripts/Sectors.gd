extends Node

signal _crashed

func _on_Sector_body_entered(body):
	emit_signal("_crashed", body)