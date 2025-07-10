# app.py
from flask import Flask, render_template, request, redirect, url_for, session, jsonify
from flask_mysqldb import MySQL
from flask_bcrypt import Bcrypt
from gtts import gTTS
import random
import io
import numpy as np
import pickle
import textstat
import threading

app = Flask(__name__)
app.secret_key = 'elikem'

# MySQL configurations
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''
app.config['MYSQL_DB'] = 'vocabulary_tutor'
app.config['MYSQL_HOST'] = 'localhost'
mysql = MySQL(app)
bcrypt = Bcrypt(app)

with open('application_words.txt', 'r') as file:
    words = file.read().splitlines()

with open('kmeans_model.pkl', 'rb') as file:
    kmeans_model = pickle.load(file)

with open('word_vectors.pkl', 'rb') as file:
    word_vectors = pickle.load(file)

vector_size = len(next(iter(word_vectors.values())))

def get_word_vector(word):
    return word_vectors.get(word, np.zeros(vector_size))

def extract_features(word):
    ari = textstat.automated_readability_index(word)
    length = len(word)
    return [ari, length]

def get_word_cluster(word):
    word_vector = get_word_vector(word)
    additional_features = extract_features(word)
    combined_features = np.concatenate([word_vector, additional_features])
    cluster = kmeans_model.predict([combined_features])[0]
    return cluster

# Cache for word clusters
word_clusters = {}

def precompute_clusters():
    global word_clusters
    for word in words:
        word_clusters[word] = get_word_cluster(word)

# Run precompute_clusters in a separate thread
threading.Thread(target=precompute_clusters).start()

@app.route('/')
def index():
    if 'user_id' in session:
        return redirect(url_for('game'))
    return render_template('index.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')
        
        cursor = mysql.connection.cursor()
        cursor.execute("INSERT INTO users (username, password) VALUES (%s, %s)", (username, hashed_password))
        mysql.connection.commit()
        cursor.close()
        
        return redirect(url_for('login'))
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        cursor = mysql.connection.cursor()
        cursor.execute("SELECT id, password FROM users WHERE username = %s", (username,))
        user = cursor.fetchone()
        cursor.close()
        
        if user and bcrypt.check_password_hash(user[1], password):
            session['user_id'] = user[0]
            session['score'] = 0
            session['question_count'] = 0
            session['time_spent'] = {}
            session['power_ups'] = {'double_points': 1, 'extra_time': 1, 'skip_question': 1}  # Initialize power-ups
            return redirect(url_for('game'))
        else:
            return 'Invalid credentials'
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.pop('user_id', None)
    session.pop('score', None)
    session.pop('question_count', None)
    session.pop('time_spent', None)
    session.pop('power_ups', None)
    return redirect(url_for('index'))

@app.route('/game')
def game():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    return render_template('game.html')

@app.route('/get_question', methods=['GET'])
def get_question():
    user_id = session['user_id']
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT cluster FROM wrong_clusters WHERE user_id = %s", (user_id,))
    wrong_clusters = cursor.fetchall()
    cursor.close()

    if wrong_clusters:
        # Fetch words from the user's wrong clusters
        wrong_clusters = [cluster[0] for cluster in wrong_clusters]
        words_from_wrong_clusters = [word for word, cluster in list(word_clusters.items()) if cluster in wrong_clusters]
        random_words = random.sample(words_from_wrong_clusters, 4)
    else:
        # Fetch random words if no wrong clusters
        random_words = random.sample(words, 4)

    word_to_pronounce = random.choice(random_words)
    tts = gTTS(text=word_to_pronounce, lang='en', slow=False)
    audio_buffer = io.BytesIO()
    tts.write_to_fp(audio_buffer)
    audio_data = audio_buffer.getvalue()
    return jsonify({
        'words': random_words,
        'audio': audio_data.decode('latin1'),
        'correct_word': word_to_pronounce  # Send the correct word to the client
    })

@app.route('/submit_answer', methods=['POST'])
def submit_answer():
    data = request.get_json()
    user_answer = data['answer']
    correct_word = data['correct_word']
    time_spent = data['time_spent']
    user_id = session['user_id']
    double_points = data.get('double_points', False)

    if user_answer == correct_word:
        points = max(0, 30 - time_spent)
        if double_points and session['power_ups']['double_points'] > 0:
            points *= 2
            session['power_ups']['double_points'] -= 1
        session['score'] += points
    else:
        cluster = word_clusters[correct_word]
        cursor = mysql.connection.cursor()
        cursor.execute("INSERT INTO wrong_clusters (user_id, cluster) VALUES (%s, %s)", (user_id, cluster))
        mysql.connection.commit()
        cursor.close()
    
    session['question_count'] += 1
    if 'time_spent' not in session:
        session['time_spent'] = {}
    session['time_spent'][correct_word] = time_spent

    # Store the score in the database
    cursor = mysql.connection.cursor()
    cursor.execute("INSERT INTO scores (user_id, score) VALUES (%s, %s)", (user_id, session['score']))
    mysql.connection.commit()
    cursor.close()

    return jsonify({'result': 'success', 'score': session['score'], 'question_count': session['question_count'], 'power_ups': session['power_ups']})

@app.route('/get_scores', methods=['GET'])
def get_scores():
    user_id = session['user_id']
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT score FROM scores WHERE user_id = %s ORDER BY id DESC LIMIT 5", (user_id,))
    scores = cursor.fetchall()
    cursor.close()
    scores = [score[0] for score in scores]
    return jsonify({'scores': scores})

@app.route('/reset_game', methods=['POST'])
def reset_game():
    session['score'] = 0
    session['question_count'] = 0
    session['time_spent'] = {}
    session['power_ups'] = {'double_points': 1, 'extra_time': 1, 'skip_question': 1}  # Reset power-ups
    return jsonify({'result': 'success'})

if __name__ == '__main__':
    app.run(debug=True)