from flask import Flask, render_template, request
from elopy import *

app = Flask(__name__)
i = Implementation()
try:
    file = open('ratings.txt', 'r')
    for player_data in file.readlines():
        player_data_array = player_data.split(' ')
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
            i.addPlayer(request.form['playername'])
        else:
            i.recordMatch(request.form['victorious'], request.form['defeated'], winner=request.form['victorious'])
            f = open("ratings.txt", "w+")
            for (player, ranking, matches) in i.getRatingList():
                f.write("{} {} {}\n".format(player, ranking, matches))
            f.close()

    return render_template('admin.html', rating_list=i.getRatingList())

@app.route('/ping-pong')
def ping_pong():
    return render_template('ping-pong.html', rating_list=i.getRatingList())

@app.route('/fifa')
def fifa():
    return render_template('fifa.html')