import sys
import os
sys.path.append(os.getcwd())
from elopy import *
import pytest


@pytest.fixture
def empty_rating():
    return Implementation()


@pytest.fixture
def filled_rating():
    return Implementation(1000, [Player('Player1', 1200, 2, 2), Player('Player2', 900, 2, 0)],
                          [('Player1', 'Player2'), ('Player1', 'Player2')])


@pytest.mark.unit_test
def test_default_rating(empty_rating):
    assert empty_rating.base_rating == 1000


@pytest.mark.unit_test
def test_add_players_and_get_ratings(empty_rating):
    empty_rating.addPlayer('Name1', 1500, 5, 0)
    empty_rating.addPlayer('Name2', 1600, 6, 2)
    assert len(empty_rating.getRatingList()) == 2
    assert ('Name1', 1500, 5, 0) in empty_rating.getRatingList()
    assert ('Name2', 1600, 6, 2) in empty_rating.getRatingList()


@pytest.mark.unit_test
def test_remove_players_and_get_ratings(filled_rating):
    filled_rating.removePlayer('Player2')
    assert len(filled_rating.getRatingList()) == 1
    assert ('Player2', 900, 2, 0) not in filled_rating.getRatingList()


@pytest.mark.unit_test
def test_save_ratings_to_file():
    pass


@pytest.mark.unit_test
def test_load_rantings_from_file():
    pass
