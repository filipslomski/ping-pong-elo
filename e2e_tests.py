from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
import unittest


class RankingDisplay(unittest.TestCase):

    def setUp(self):
        self.driver = webdriver.Chrome('chromedriver')

    def test_search_in_python_org(self):
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

    def test_search_in_python_org(self):
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

    def test_search_in_python_org(self):
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

if __name__ == "__main__":
    unittest.main()