from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
import unittest


class RankingDisplay(unittest.TestCase):

    def setUp(self):
        self.driver = webdriver.Chrome('chromedriver')

    def test_ranking_display(self):
        self.driver.get('localhost:5000')
        self.driver.find_element_by_id('ping-pong').click()
        assert self.driver.find_element_by_xpath('.//h1').text == 'Player Elo Ranking'

    def tearDown(self):
        self.driver.close()


class AddingPlayer(unittest.TestCase):

    def setUp(self):
        self.driver = webdriver.Chrome('chromedriver')
        f = open('token.txt', 'r')
        self.token = f.read().strip()
        f.close()

    def test_adding_player(self):
        self.driver.get('localhost:5000/admin')
        self.driver.find_element_by_id('playername').clear()
        self.driver.find_element_by_id('playername').send_keys('{} player1'.format(self.token))
        self.driver.find_element_by_id('addplayer').click()
        assert is_visible(self.driver.find_element_by_xpath(
            ".//table//tr[./td[text()='player1']][./td[text()='1000']][./td[text()='0']]")) is True

    def tearDown(self):
        self.driver.close()


class TokenAuthorization(unittest.TestCase):

    def setUp(self):
        self.driver = webdriver.Chrome('chromedriver')

    def test_token(self):
        self.driver.get('localhost:5000/admin')
        self.driver.find_element_by_id('playername').clear()
        self.driver.find_element_by_id('playername').send_keys('player33')
        self.driver.find_element_by_id('addplayer').click()
        assert is_visible(self.driver.find_element_by_xpath(
            ".//table//tr[./td[text()='player33']][./td[text()='1000']][./td[text()='0']]")) is False

    def tearDown(self):
        self.driver.close()


def is_visible(elem):
    try:
        elem.is_displayed()
        return True
    except NoSuchElementException:
        return False


suite = unittest.TestLoader().loadTestsFromTestCase(RankingDisplay)
suite2 = unittest.TestLoader().loadTestsFromTestCase(AddingPlayer)
suite3 = unittest.TestLoader().loadTestsFromTestCase(TokenAuthorization)
unittest.TextTestRunner(verbosity=2).run(suite)
unittest.TextTestRunner(verbosity=2).run(suite2)
unittest.TextTestRunner(verbosity=2).run(suite3)
#if __name__ == "__main__":
#    unittest.main()