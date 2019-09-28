from flask import Flask, request, g
from pytrends.request import TrendReq
import requests
import json
from datetime import datetime
from time import mktime
import sqlite3
import math
import statistics

app = Flask(__name__)
pytrends = TrendReq()

DATABASE = '/home/luka/Desktop/pineapple/pineapple.sqlite'


def make_dicts(cursor, row):
    return dict((cursor.description[idx][0], value)
                for idx, value in enumerate(row))


def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = sqlite3.connect(DATABASE, isolation_level=None)
        db.row_factory = make_dicts
    return db


def query_db(query, args=(), one=False):
    cur = get_db().execute(query, args)
    rv = cur.fetchall()
    cur.close()
    return (rv[0] if rv else None) if one else rv


@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()


@app.route('/trend', methods=['GET'])
def trend():
    pytrends.build_payload(["grippe"], cat=0, timeframe='today 12-m', geo='CH-ZH', gprop='')
    response = pytrends.interest_over_time()
    return response['grippe'][-1] / 10


@app.route('/weather/<lat>/<lon>', methods=['GET'])
def weather(lat, lon):
    weather_forecast = json.loads(requests.get(
        'http://api.openweathermap.org/data/2.5/forecast?lat=' + lat + '&lon=' + lon + '&appid=a5a6619306cab76d5164937aa70c2410').content.decode(
        "utf-8"))
    temperature_avg_pred = (weather_forecast["list"][0]["main"]["temp"] + weather_forecast["list"][1]["main"]["temp"] + \
                            weather_forecast["list"][2]["main"]["temp"] + weather_forecast["list"][3]["main"]["temp"] + \
                            weather_forecast["list"][4]["main"]["temp"] + weather_forecast["list"][5]["main"]["temp"] + \
                            weather_forecast["list"][6]["main"]["temp"] + weather_forecast["list"][7]["main"]["temp"] + \
                            weather_forecast["list"][8]["main"]["temp"] + weather_forecast["list"][9]["main"]["temp"] + \
                            weather_forecast["list"][10]["main"]["temp"] + weather_forecast["list"][11]["main"][
                                "temp"] + \
                            weather_forecast["list"][12]["main"]["temp"] + weather_forecast["list"][13]["main"][
                                "temp"] + \
                            weather_forecast["list"][14]["main"]["temp"] + weather_forecast["list"][15]["main"][
                                "temp"] + \
                            weather_forecast["list"][16]["main"]["temp"] + weather_forecast["list"][17]["main"][
                                "temp"] + \
                            weather_forecast["list"][18]["main"]["temp"] + weather_forecast["list"][19]["main"][
                                "temp"] + \
                            weather_forecast["list"][20]["main"]["temp"] + weather_forecast["list"][21]["main"][
                                "temp"] + \
                            weather_forecast["list"][22]["main"]["temp"] + weather_forecast["list"][23]["main"][
                                "temp"]) / 24
    temperature = abs(weather_forecast["list"][0]["main"]["temp"] - temperature_avg_pred)
    temperature = min(temperature, 10)
    humidity = abs(50 - weather_forecast["list"][0]["main"]["humidity"]) / 5
    wind = 10 / (1 + math.exp(-0.15 * (weather_forecast["list"][0]["wind"]["speed"] - 15)))
    rain = 0
    if "rain" in weather_forecast["list"][0]:
        rain = 10 / (1 + math.exp(-0.04 * (weather_forecast["list"][0]["3h"] - 50)))
    return {"temperature": temperature, "humidity": humidity, "wind": wind, "rain": rain}


@app.route('/bmi', methods=['GET'])
def bmi():
    response = []
    for row in query_db('''
    SELECT weight, height
    FROM PhoneMeasurements
    ORDER BY timestamp DESC
    LIMIT 1'''):
        response.append(row)
    if len(response) == 0:
        return 'No measurements taken'
    weight = response[0]["weight"]
    height = response[0]["height"]
    bmi = weight / (height / 100) ** 2
    if bmi < 18.5:
        bmi = 10
    elif bmi > 30:
        bmi = 4 * math.log(bmi - 30)
        bmi = min(bmi, 10)
    else:
        bmi = 10 - 1.53846 * (bmi - 18.5)
    return bmi


@app.route('/heartrate', methods=['GET'])
def heartrate():
    response = []
    for row in query_db('''
    SELECT resting_heartrate
    FROM PhoneMeasurements
    ORDER BY timestamp DESC
    LIMIT 1'''):
        response.append(row)
    if len(response) == 0:
        return 'No measurements taken'
    heartrate = response[0]['resting_heartrate']
    if heartrate < 70:
        heartrate = 0
    else:
        heartrate = 10 / (1 + math.exp(-0.5 * (heartrate - 80)))
    return heartrate


@app.route('/steps', methods=['GET'])
def steps():
    response = []
    for row in query_db('''
    SELECT steps
    FROM PhoneMeasurements
    ORDER BY timestamp DESC
    LIMIT 14'''):
        response.append(row)
    if len(response) == 0:
        return 'No measurements taken'
    steps_median = statistics.median([x['steps'] for x in response])
    steps = 0
    if steps_median < 6000:
        steps = (6000 - steps_median) / 600
    return steps


@app.route('/pollution/<lat>/<lon>', methods=['GET'])
def pollution(lat, lon):
    pollution = json.loads(requests.get(
        'http://api.airvisual.com/v2/nearest_city?lat=' + lat + '&lon=' + lon + '&key=5e94f1ac-37e1-412c-8660-15000713e46a').content.decode(
        "utf-8"))
    aqi = pollution['data']['current']['pollution']['aqius'] / 30
    return aqi


@app.route('/age', methods=['GET'])
def age():
    response = []
    for row in query_db('''
    SELECT age
    FROM PhoneMeasurements
    ORDER BY timestamp DESC
    LIMIT 1'''):
        response.append(row)
    if len(response) == 0:
        return 'No measurements taken'
    age = response[0]['age']
    if age >= 65:
        age = 10
    elif age < 7:
        age = 8
    elif age < 18:
        age = 2
    elif age < 65:
        age = 4
    return age


@app.route('/cigarettes', methods=['GET'])
def cigarettes():
    response = []
    for row in query_db('''
    SELECT cigarettes
    FROM PhoneMeasurements
    ORDER BY timestamp DESC
    LIMIT 30'''):
        response.append(row)
    if len(response) == 0:
        return 'No measurements taken'
    cigarettes = statistics.median([x['cigarettes'] for x in response])
    cigarettes = min(cigarettes, 10)
    return cigarettes


@app.route('/sleep', methods=['GET'])
def sleep():
    response = []
    for row in query_db('''
    SELECT sleep
    FROM PhoneMeasurements
    ORDER BY sleep DESC
    LIMIT 7'''):
        response.append(row)
    if len(response) == 0:
        return 'No measurements taken'
    sleep = abs(8 - statistics.mean([x['sleep'] for x in response]))
    sleep = min(sleep, 10)
    return sleep


@app.route('/event/<zip>', methods=['GET'])
def event(zip):
    response = []
    print(zip)
    for row in query_db('''
    SELECT capacity
    FROM Events
    WHERE zip=?
    LIMIT 1''', (int(zip),)):
        response.append(row)
    if len(response) == 0:
        return 'No events'
    event = 10 / (1 + math.exp(-0.03 * (response[0]['capacity'] - 200)))
    return event


@app.route(
    '/fusion/<lat>/<lon>/<zip>/<resting_heartrate_in>/<steps_in>/<cigarettes_in>/<sleep_in>/<calories_in>/<height_in>/<weight_in>/<age_in>',
    methods=['GET'])
def fusion(lat, lon, zip, resting_heartrate_in, steps_in, cigarettes_in, sleep_in, calories_in, height_in, weight_in,
           age_in):
    timestamp = mktime(datetime.now().replace(microsecond=0, second=0, minute=0, hour=0).timetuple())
    print(resting_heartrate_in, steps_in, cigarettes_in, sleep_in, calories_in, height_in, weight_in,
          age_in, timestamp)
    query_db(
        'INSERT INTO PhoneMeasurements (resting_heartrate, steps, cigarettes, sleep, calories, height, weight, age, timestamp) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        (resting_heartrate_in, steps_in, cigarettes_in, sleep_in, calories_in, height_in, weight_in, age_in, timestamp))
    weather_data = weather(lat, lon)
    scores = {'trend': trend(),
              'temperature': weather_data['temperature'],
              'humidity': weather_data['humidity'],
              'wind': weather_data['wind'],
              'rain': weather_data['rain'],
              'bmi': bmi(),
              'heartrate': heartrate(),
              'steps': steps(),
              'pollution': pollution(lat, lon),
              'age': age(),
              'cigarettes': cigarettes(),
              'sleep': sleep(),
              'event': event(zip)
              }
    print(scores)
    diagnostic = []
    for key, value in scores.items():
        if value > 5:
            diagnostic.append(key)
    scores = {'trend': scores['trend'] * 2,
              'temperature': scores['temperature'] * 1,
              'humidity': scores['humidity'] * 1.5,
              'wind': scores['wind'] * 1,
              'rain': scores['rain'] * 1,
              'bmi': scores['bmi'] * 0.5,
              'heartrate': scores['heartrate'] * 2,
              'steps': scores['steps'] * 1,
              'pollution': scores['pollution'] * 2,
              'age': scores['age'] * 2.5,
              'cigarettes': scores['cigarettes'] * 1,
              'sleep': scores['sleep'] * 1.25,
              'event': scores['event'] * 1
              }
    final_score = 0.0
    for key, value in scores.items():
        final_score = final_score + value
    final_score = int(final_score / 1.775)
    return json.dumps({'score': final_score, 'diagnostic': diagnostic})


if __name__ == '__main__':
    app.run()
