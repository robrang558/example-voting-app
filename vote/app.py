from flask import Flask, render_template, request, make_response, g
from redis import Redis
import os
import socket
import random
import json

option_a = os.getenv('OPTION_A', "Emacs")
option_b = os.getenv('OPTION_B', "Vi")
hostname = socket.gethostname()
version = 'v1'

app = Flask(__name__)

def get_redis():
    if not hasattr(g, 'redis'):
        g.redis = Redis(host="redis", db=0, socket_timeout=5)
    return g.redis

@app.route("/", methods=['POST','GET'])
def hello():
    resultr_id = request.cookies.get('resultr_id')
    if not resultr_id:
        resultr_id = hex(random.getrandbits(64))[2:-1]

    result = None

    if request.method == 'POST':
        redis = get_redis()
        result = request.form['result']
        data = json.dumps({'resultr_id': resultr_id, 'result': result})
        redis.rpush('results', data)

    resp = make_response(render_template(
        'index.html',
        option_a=option_a,
        option_b=option_b,
        hostname=hostname,
        result=result,
        version=version,
    ))
    resp.set_cookie('resultr_id', resultr_id)
    return resp


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80, debug=True, threaded=True)
