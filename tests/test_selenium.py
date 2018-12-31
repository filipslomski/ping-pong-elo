from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
import pytest


@pytest.fixture
def driver():
    return webdriver.Chrome('chromedriver')


@pytest.mark.selenium
def test_ranking_display(driver):
    driver.get('localhost:5000')
    driver.find_element_by_id('ping-pong').click()
    assert driver.find_element_by_xpath('.//h1').text == 'Player Elo Ranking'


@pytest.mark.selenium
def test_adding_player(driver):
    f = open('token.txt', 'r')
    token = f.read().strip()
    f.close()
    driver.get('localhost:5000/admin')
    driver.find_element_by_id('playername').clear()
    driver.find_element_by_id('playername').send_keys('{} player1'.format(token))
    driver.find_element_by_id('addplayer').click()
    assert is_visible(driver.find_element_by_xpath(
        ".//table//tr[./td[text()='player1']][./td[text()='1000']][./td[text()='0']]")) is True


@pytest.mark.selenium
def test_token(driver):
    driver.get('localhost:5000/admin')
    driver.find_element_by_id('playername').clear()
    driver.find_element_by_id('playername').send_keys('player33')
    driver.find_element_by_id('addplayer').click()
    assert is_visible(driver.find_element_by_xpath(
        ".//table//tr[./td[text()='player33']][./td[text()='1000']][./td[text()='0']]")) is False


def is_visible(elem):
    try:
        elem.is_displayed()
        return True
    except NoSuchElementException:
        return False
