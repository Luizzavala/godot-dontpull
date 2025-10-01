extends Node

func _ready() -> void:
    AudioManager.play_bgm()
    AudioManager.play_block_launch()
    AudioManager.play_block_destroy()
    AudioManager.play_enemy_crush()
    AudioManager.play_power_up()
    AudioManager.play_game_over()
