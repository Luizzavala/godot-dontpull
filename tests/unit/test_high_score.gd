## TestHighScore verifica la persistencia y orden de la tabla de récords.
extends Node

const HighScoreService = preload("res://scripts/core/HighScoreService.gd")

func run_tests() -> Array:
    HighScoreService.clear_scores()
    var results := [
        _test_submit_and_sort_scores(),
        _test_max_entries_limit(),
    ]
    HighScoreService.clear_scores()
    return results


func _test_submit_and_sort_scores() -> Dictionary:
    HighScoreService.clear_scores()
    HighScoreService.submit_score("abc", 100)
    HighScoreService.submit_score("XYZ", 50)
    var scores := HighScoreService.get_high_scores()
    var passed := scores.size() == 2
        and scores[0].get("initials") == "ABC"
        and scores[0].get("score") == 100
        and scores[1].get("initials") == "XYZ"
        and scores[1].get("score") == 50
    return {
        "name": "HighScoreService guarda y ordena puntuaciones en mayúsculas",
        "passed": passed,
    }


func _test_max_entries_limit() -> Dictionary:
    HighScoreService.clear_scores()
    for index in 12:
        var initials := "A%02d" % index
        HighScoreService.submit_score(initials, index * 10)
    var scores := HighScoreService.get_high_scores()
    var passed := scores.size() == HighScoreService.MAX_ENTRIES
        and scores[0].get("score") == 110
        and scores[-1].get("score") == 20
    return {
        "name": "HighScoreService limita la tabla a las mejores 10 puntuaciones",
        "passed": passed,
    }
