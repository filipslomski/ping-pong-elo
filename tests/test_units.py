import sys
import os
sys.path.append(os.getcwd())
from elopy import *
from app import *
import pytest


@pytest.fixture
def empty_rating():
    return Implementation()


@pytest.fixture
def filled_rating():
    return Implementation(1000, [Player('Player1', 1200, 2, 2, 1200), Player('Player2', 900, 2, 0, 1000)])


@pytest.mark.unit_test
def test_default_rating(empty_rating):
    assert empty_rating.base_rating == 1000


@pytest.mark.unit_test
def test_add_players_and_get_ratings(empty_rating):
    empty_rating.addPlayer('Name1', 1500, 5, 0, 1700)
    empty_rating.addPlayer('Name2', 1600, 6, 2, 1800)
    assert len(empty_rating.getRatingList()) == 2
    assert ('Name1', 1500, 5, 0, 1700, 'https://upload.wikimedia.org/wikipedia/commons/2/23/US-O7_insignia.svg') in empty_rating.getRatingList()
    assert ('Name2', 1600, 6, 2, 1800, 'https://upload.wikimedia.org/wikipedia/commons/2/23/US-O7_insignia.svg') in empty_rating.getRatingList()


@pytest.mark.unit_test
def test_add_matches_and_get_match_history(filled_rating):
    filled_rating.recordMatch('Player1', 'Player2', 'Player1')
    assert ('Player1', 'Player2') in filled_rating.getMatchesList()


@pytest.mark.unit_test
def test_check_ratings_change(filled_rating):
    starting_player1_rating = filled_rating.getPlayerRating('Player1')
    starting_player2_rating = filled_rating.getPlayerRating('Player1')
    filled_rating.recordMatch('Player1', 'Player2', 'Player1')
    assert filled_rating.getPlayerRating('Player1') > starting_player1_rating
    assert filled_rating.getPlayerRating('Player2') < starting_player2_rating



@pytest.mark.unit_test
def test_remove_players_and_get_ratings(filled_rating):
    filled_rating.removePlayer('Player2')
    assert len(filled_rating.getRatingList()) == 1
    assert ('Player2', 900, 2, 0) not in filled_rating.getRatingList()


@pytest.mark.unit_test
def test_save_ratings_and_matches_to_file(filled_rating):
    record_match_and_update_files(filled_rating, 'Player1', 'Player2', 'test_ratings.txt', 'test_matches.txt')
    rating_file = open('test_ratings.txt', 'r')
    for player_data in rating_file.readlines():
        player_data_array = player_data.split('_')
        assert len(player_data_array) == 5
        assert player_data_array[0] in ('Player1', 'Player2')
        assert int(player_data_array[2]) == 3
        assert int(player_data_array[3]) in (0, 3)
    rating_file.close()
    os.remove('test_ratings.txt')
    match_file = open('test_matches.txt', 'r')
    for match_data in match_file.readlines():
        if '_' in match_data:
            match_data_array = match_data.split('_')
            assert len(match_data_array) == 2
            assert match_data_array[0] == 'Player1'
            assert match_data_array[1].rstrip() == 'Player2'
    match_file.close()
    os.remove('test_matches.txt')


@pytest.mark.unit_test
def test_load_rantings_from_file():
    pass
