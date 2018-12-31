from flask import Flask, render_template, request
import sys
import os
sys.path.append(os.getcwd())
from elopy import *

app = Flask(__name__)
i = Implementation()

try:
    token_file = open('token.txt', 'r')
    token = token_file.read().strip()
    rating_file = open('ratings.txt', 'r')
    for player_data in rating_file.readlines():
        player_data_array = player_data.split('_')
        i.addPlayer(player_data_array[0], float(player_data_array[1]), int(player_data_array[2]), int(player_data_array[3]))
    rating_file.close()
    match_file = open('matches.txt', 'r')
    for match_data in match_file.readlines():
        if '_' in match_data:
            match_data_array = match_data.split('_')
            i.addMatchToList(match_data_array[0], match_data_array[1])
    match_file.close()
except FileNotFoundError:
    pass


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/admin',  methods=('GET', 'POST'))
def admin():
    if request.method == 'POST':
        if len(request.form) == 1:
            if request.form['playername'].split(' ', 1)[0] == token:
                i.addPlayer(request.form['playername'].split(' ', 1)[1])
        else:
            if request.form['victorious'].split(' ', 1)[0] == token:
                victorious = request.form['victorious'].split(' ', 1)[1]
                record_match_and_update_files(victorious, request.form['defeated'])

    return render_template('admin.html', rating_list=i.getRatingList(), matches_list = i.getMatchesList())


@app.route('/ping-pong')
def ping_pong():
    return render_template('ping-pong.html', rating_list=i.getRatingList(), matches_list = i.getMatchesList())


@app.route('/fifa')
def fifa():
    return render_template('fifa.html')


def record_match_and_update_files(victorius, defeated):
    i.recordMatch(victorius, defeated, winner=victorius)
    save_ratings_to_file()
    save_matches_to_file()


def save_ratings_to_file(file_name="ratings.txt"):
    rating_file = open(file_name, "w+")
    for (player, ranking, matches, win_streak) in i.getRatingList():
        rating_file.write("{}_{}_{}_{}\n".format(player, ranking, matches, win_streak))
    rating_file.close()


def save_matches_to_file(file_name="matches.txt"):
    match_file = open(file_name, "w+")
    for (winner, defeated) in i.getMatchesList():
        match_file.write("{}_{}\n".format(winner, defeated))
    match_file.close()