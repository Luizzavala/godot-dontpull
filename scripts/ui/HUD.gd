extends CanvasLayer
class_name HUD

##
# HUD gestiona la presentación de puntuación, vidas y mensajes temporales.
##

@onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var lives_label: Label = $MarginContainer/VBoxContainer/LivesLabel
@onready var message_label: Label = $MarginContainer/VBoxContainer/MessageLabel

##
# Actualiza el marcador mostrado en pantalla.
##
func update_score(value: int) -> void:
    score_label.text = "Score: %d" % value

##
# Actualiza el contador de vidas restante.
##
func update_lives(value: int) -> void:
    lives_label.text = "Vidas: %d" % value

##
# Muestra un mensaje temporal en la parte inferior del HUD.
##
func show_message(message: String) -> void:
    message_label.text = message
