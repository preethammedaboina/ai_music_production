from flask import Flask, request, jsonify
from flask_cors import CORS
import random
from googletrans import Translator

app = Flask(__name__)
CORS(app)
translator = Translator()

def generate_lyrical_structure(description, mood):
    if mood == 'Happy':
        lines = [
            f"In the joy of {description}, I find my way.",
            f"With every beat, I hear you say.",
            f"A happy melody plays in my mind,",
            f"The rhythm flows, it feels so kind.",
            f"In the bright night, we dance around,",
            f"To the {description} sounds that we found.",
            f"Sing along, don't let it fade,",
            f"A happy song that we've made."
        ]
    elif mood == 'Sad':
        lines = [
            f"In the sorrow of {description}, I feel astray.",
            f"Each note brings tears, yet I stay.",
            f"A sad melody echoes in my soul,",
            f"The rhythm breaks, it takes a toll.",
            f"In the dark night, we cry alone,",
            f"To the {description} sounds, now gone.",
            f"Whispers of love that fade away,",
            f"A sad song at the end of the day."
        ]
    elif mood == 'Funny':
        lines = [
            f"In the fun of {description}, I laugh all day.",
            f"Each note's a joke, as we sway.",
            f"A funny tune that's full of cheer,",
            f"The rhythm bounces, no room for fear.",
            f"In the silly night, we fool around,",
            f"To the {description} sounds, laughter-bound.",
            f"Sing with joy, let's have some fun,",
            f"A funny song for everyone!"
        ]
    elif mood == 'Serious':
        lines = [
            f"In the depth of {description}, I stand tall.",
            f"Each note's a mission, I heed the call.",
            f"A serious melody builds in my heart,",
            f"The rhythm strong, a work of art.",
            f"In the quiet night, we march ahead,",
            f"To the {description} sounds that lead, not dread.",
            f"Sing with purpose, no room for doubt,",
            f"A serious song, we'll carry it out."
        ]
    else:
        lines = [
            f"In the {mood} of {description}, I find my way.",
            f"With every beat, I hear you say.",
            f"A {mood.lower()} melody plays in my mind,",
            f"The rhythm flows, it's so refined.",
            f"In the {mood.lower()} night, we dance around,",
            f"To the {description} sounds that we found.",
            f"Sing along, don't let it fade,",
            f"A {mood.lower()} song we've made."
        ]

    return "\n".join(random.sample(lines, 6))

@app.route('/generate_lyrics', methods=['POST'])
def generate_lyrics():
    data = request.get_json()
    description = data.get('description', '')
    language = data.get('language', '')
    genre = data.get('genre', '')
    mood = data.get('mood', 'Neutral')

    if not description or not language or not genre:
        return jsonify({'lyrics': 'Please provide a valid description, language, and genre.'})

    # Generate creative lyrics based on mood
    lyrics = generate_lyrical_structure(description, mood)

    # Translate the lyrics to the specified language
    try:
        translated_lyrics = translator.translate(lyrics, dest=language).text
    except Exception as e:
        return jsonify({'lyrics': 'Translation failed. Please try again.'})

    return jsonify({'lyrics': translated_lyrics})

@app.route('/refine_lyrics', methods=['POST'])
def refine_lyrics():
    data = request.get_json()
    refined_lyrics = data.get('refined_lyrics', '')

    if not refined_lyrics:
        return jsonify({'lyrics': 'Please provide some lyrics to refine.'})

    # Example refinement - add some embellishments
    refined = f"Refined version: {refined_lyrics}... and it keeps getting better!"
    
    return jsonify({'lyrics': refined})

if __name__ == '__main__':
    app.run(debug=True)
