from flask import Flask, render_template, request
from elopy import *

app = Flask(__name__)
i = Implementation()
try:
    file = open('ratings.txt', 'r')
    for player_data in file.readlines():
        player_data_array = player_data.split(' ')
    token_file = open('token.txt', 'r')
    token = token_file.read().strip()
    file = open('ratings.txt', 'r')
    for player_data in file.readlines():
        player_data_array = player_data.split('_')
        i.addPlayer(player_data_array[0], float(player_data_array[1]), int(player_data_array[2]))
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
                i.recordMatch(victorious, request.form['defeated'],
                              winner=victorious)
                f = open("ratings.txt", "w+")
                for (player, ranking, matches) in i.getRatingList():
                    f.write("{}_{}_{}\n".format(player, ranking, matches))
                f.close()

    return render_template('admin.html', rating_list=i.getRatingList())


@app.route('/ping-pong')
def ping_pong():
    return render_template('ping-pong.html', rating_list=i.getRatingList())


@app.route('/fifa')
def fifa():
    return render_template('fifa.html')