# EloPy

Please reccomend any functionality you think should be added!

A python library for the Elo Rating System. Right now it only supports 1 vs 1 games.


## What is the Elo Rating System?
* The Elo Rating System (Elo) is a rating system used for rating players in games. Originally developed for chess by Arpad Elo, Elo has been applied to a large array of games.
* Each player is assigned a number as a rating. The system predicts the outcome of a match between two players by using an expected score formula (i.e. a player whose rating is 100 points greater than their opponent's is expected to win 64% of the time).
* Everytime a game is played, the Elo rating of the participants change depending on the outcome and the expected outcome. The winner takes points from the loser; the amount is determined by the players' scores and ratings
* A win is counts as a score of 1, loss is a score of 0, and draw is a score of 0.5


## Calculations
If Player A has a rating of R<sub>A</sub> and Player B a rating of R<sub>B</sub>, the exact formula for Player A's score is:

![alt text](https://wikimedia.org/api/rest_v1/media/math/render/svg/51346e1c65f857c0025647173ae48ddac904adcb)

And Player B's score is:

![alt text](https://wikimedia.org/api/rest_v1/media/math/render/svg/4b340e7d15e61ee7d90f428dcf7f4b3c049d89ff)

Supposing Player A was expected to score E<sub>A</sub> points but actually scored S<sub>A</sub> points. The formula for updating his/her rating is:

![alt text](https://wikimedia.org/api/rest_v1/media/math/render/svg/09a11111b433582eccbb22c740486264549d1129)

Right now the K factor is found by the number of player multiplied by 42 as a constant. Working on custom K factors.

## Syntax when using EloPy

#### Creating your own implementation
```python
from elopy import *

i = Implementation()
```

#### Adding players
```python
i.newPlayer("Hank") #default rating is 1000
i.newPlayer("Bill",rating=900)

print i.getPlayerRating("Hank"), i.getPlayerRating("Bill")
```
```shell
1000 900
```

#### Recording a match
```python
i.recordMatch("Hank","Bill",winner="Hank")

print i.getPlayerRating("Hank"), i.getPlayerRating("Bill")

i.recordMatch("Hank","Bill",winner="Bill")

print i.getPlayerRating("Hank"), i.getPlayerRating("Bill")

i.recordMatch("Hank","Bill",draw=True)

print i.getPlayerRating("Hank"), i.getPlayerRating("Bill")
```
```shell
1007.63636364 858.0
948.588723954 917.047639682
944.78629748 920.850066156
```
