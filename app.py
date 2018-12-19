from flask import Flask, render_template, request
from elopy import *

app = Flask(__name__)

i = Implementation()


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/ping-pong',  methods=('GET', 'POST'))
def ping_pong():
    if request.method == 'POST':
        if len(request.form) == 1:
            i.addPlayer(request.form['playername'])
        else:
            i.recordMatch(request.form['victorious'], request.form['defeated'], winner=request.form['victorious'])

    return render_template('ping-pong.html', rating_list=i.getRatingList())


@app.route('/fifa')
def fifa():
    return render_template('fifa.html')