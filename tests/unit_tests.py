import sys
import os
sys.path.append(os.getcwd())
from elopy import *
import unittest


class ShouldDisplayPlayersWhenAddingNewPlayers(unittest.TestCase):

    def setUp(self):
        self.i = Implementation()

    def add_players_and_get_ranking(self):
        self.i.addPlayer('Name1', 1500, 5, 0)
        self.i.addPlayer('Name2', 1600, 6, 2)
        assert len(self.i.getRatingList()) == 2
        assert ('Name1', 1500, 5, 0) in self.i.getRatingList()
        assert ('Name2', 1600, 6, 2) in self.i.getRatingList()


usuite = unittest.TestLoader().loadTestsFromTestCase(ShouldDisplayPlayersWhenAddingNewPlayers)
unittest.TextTestRunner(verbosity=2).run(usuite)