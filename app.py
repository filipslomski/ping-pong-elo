from flask import Flask, render_template, request, jsonify
import sys
import os
sys.path.append(os.getcwd())
from elopy import *

app = Flask(__name__)
games = [ { "name": "Ping pong", "url": "ping-pong" }, { "name": "FIFA", "url": "fifa" } ]
ratings = {}

def load_ratings_from_file(game, rating):
    try:
        rating_file = open('ratings_' + game['url'] + '.txt', 'r')
        for player_data in rating_file.readlines():
            player_data_array = player_data.split('_')
            rating.addPlayer(player_data_array[0], float(player_data_array[1]), int(player_data_array[2]),
                        int(player_data_array[3]), float(player_data_array[4]), int(player_data_array[5]))
        rating_file.close()
        match_file = open('matches_' + game['url'] + '.txt', 'r')
        for match_data in match_file.readlines():
            if '_' in match_data:
                match_data_array = match_data.split('_')
                rating.addMatchToList(match_data_array[0], match_data_array[1].rstrip())
        match_file.close()
    except FileNotFoundError:
        print("File not found for " + game['name'])


def load_token_from_file():
    token = None
    try:
        token_file = open('token.txt', 'r')
        token = token_file.read().strip()
        token_file.close()
    except FileNotFoundError:
        if token is None:
            raise Exception('Token cannot be empty!')

    return token


for game in games:
    ratings[game['url']] = Implementation()
    load_ratings_from_file(game, ratings[game['url']])

token = load_token_from_file()


@app.route('/admin/<gameUrl>',  methods=('GET', 'POST'))
def admin(gameUrl):
    if request.method == 'POST':
        if len(request.form) == 1:
            if request.form['playername'].split(' ', 1)[0] == token:
                ratings[gameUrl].addPlayer(request.form['playername'].split(' ', 1)[1])
        else:
            if request.form['victorious'].split(' ', 1)[0] == token:
                victorious = request.form['victorious'].split(' ', 1)[1]
                record_match_and_update_files(ratings[gameUrl], victorious, request.form['defeated'], 'ratings_' + gameUrl + '.txt', 'matches_' + gameUrl + '.txt')

    return render_template('admin.html', rating_list=ratings[gameUrl].getRatingList(), matches_list = ratings[gameUrl].getMatchesList())


@app.route('/get_ratings/<game>')
def get_ratings(game):
    array = []
    gameUrl = next(filter(lambda g: g['url'] == game, games))['url']
    for player_rating in ratings[gameUrl].getRatingList():
        dict = {}
        dict['name'] = player_rating[0]
        dict['rating'] = player_rating[1]
        dict['matches'] = player_rating[2]
        dict['win_streak'] = player_rating[3]
        dict['highest_rating'] = player_rating[4]
        dict['rank_image'] = player_rating[5]
        dict['victories'] = player_rating[6]
        array.append(dict)

    return jsonify(array)


@app.route('/get_player/<game>/<player>')
def get_player(game, player):
    matches = []
    pl = {}
    gameUrl = next(filter(lambda g: g['url'] == game, games))['url']
    for match in ratings[gameUrl].getMatchesList():
        if player == match[0] or player == match[1]:
            dict = {}
            dict['victorious'] = match[0]
            dict['defeated'] = match[1]
            matches.append(dict)
    pos = 0
    for player_rating in ratings[gameUrl].getRatingList():
        pos += 1
        if player_rating[0] == player:
            pl['name'] = player_rating[0]
            pl['rating'] = player_rating[1]
            pl['rank_image'] = player_rating[5]
            pl['position'] = pos
            pl['matches'] = matches

    return jsonify(pl)


@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def index(path):
    return render_template('index.html', games=games, debug=app.debug)


def record_match_and_update_files(rating, victorius, defeated, rating_file='ratings.txt', match_file='matches.txt'):
    rating.recordMatch(victorius, defeated, winner=victorius)
    save_ratings_to_file(rating, rating_file)
    save_matches_to_file(rating, match_file)


def save_ratings_to_file(rating, file_name="ratings.txt"):
    rating_file = open(file_name, "w+")
    for (player, ranking, matches, win_streak, highest_rating, rank_image, victories) in rating.getRatingList():
        rating_file.write("{}_{}_{}_{}_{}_{}\n".format(player, ranking, matches, win_streak, highest_rating, victories))
    rating_file.close()


def save_matches_to_file(rating, file_name="matches.txt"):
    match_file = open(file_name, "w+")
    for (winner, defeated) in rating.getMatchesList():
        match_file.write("{}_{}\n".format(winner, defeated))
    match_file.close()
