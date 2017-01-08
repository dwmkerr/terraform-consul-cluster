from flask import Flask
import random

app = Flask(__name__)

quotes = [
    'I am the man with no name. Zapp Brannigan at your service.',
    'If we hit that bullseye, the rest of the dominoes should fall like a house of cards. Checkmate.',
    'Spare me your space-age techno-babble, Atilla the Hun!',
    'We\'ll simply set a new course, for that empty region over there near that blackish, holish thing.',
    'We have failed to uphold Brannigan\'s Law. However I did make it with a hot alien babe. And in the end, is that not what man has dreamt of since first he looked up at the stars?',
    'I surrender and volunteer for treason.',
    'In the game of chess, you must never let your opponent see your peices',
    'Once again my lies have been proven true.',
    'We heard your distress call and I came as fast as I wanted to.'
]

@app.route('/')
def hello_world():
    return random.choice(quotes)

if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0')
