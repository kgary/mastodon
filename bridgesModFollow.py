import sys
import os
import psycopg2
import json
import requests
import configparser
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
import time
from datetime import datetime
import functools
#set x to the parameters being passed to the script then jsonify it
x = sys.argv[1]
payload = json.loads(x)
global id
global oauth
global auth_token

config = configparser.ConfigParser()
config.read('config.ini')
connection = psycopg2.connect(
    host=config['database']['host'],
    database=config['database']['database'],
    user=config['database']['user'],
    password=config['database']['password']
)

connection.autocommit = True

def get_users():
    tokenExec = "SELECT token FROM oauth_access_tokens WHERE resource_owner_id = %s;"
    with connection.cursor() as con:
        con.execute(tokenExec, (payload['id'], ))
        try:
            oauthPayload = con.fetchone()
            oauth = oauthPayload[0]
        except TypeError:
            con.close()
            sys.exit('unable to get user auth token')

        userListExec = "SELECT account_id FROM users;"
        con.execute(userListExec)
        userList = con.fetchall()

        fListExec = "SELECT target_account_id FROM follows WHERE account_id = %s;"
        con.execute(fListExec, (payload['id'], ))
        followList = con.fetchall()

        modExec = "SELECT account_id FROM users where admin = 't' or moderator = 't';"
        con.execute(modExec)
        modList = con.fetchall()
    con.close()

    followNonTup = []
    for tup in followList:
        followNonTup.append(tup[0])

    userList += modList
    nonTupList = []
    for tup in userList:
        nonTupList.append(tup[0])

    follow_user(nonTupList, followNonTup, oauth)

def follow_user(u, f, oauth):
    form = {'authenticity_token': payload['auth_token']}
    headers = {'Authorization': 'Bearer ' + oauth}
    endpoint = '/api/v1/accounts/{id}/follow'
    req = requests_retry_session()
    for user in u:
        if user not in f:
            r = req.post('http://localhost:3000' + endpoint.replace('{id}', str(user)), headers=headers, data=form)
            print("Followed: " + str(user))

def requests_retry_session(
    retries=3,
    backoff_factor=0.3,
    status_forcelist=(500, 502, 504),
    session=None,
):
    session = session or requests.Session()
    retry = Retry(
        total=retries,
        read=retries,
        connect=retries,
        backoff_factor=backoff_factor,
        status_forcelist=status_forcelist,
        method_whitelist=frozenset(['GET', 'post'])
    )
    adapter = HTTPAdapter(max_retries=retry)
    session.mount('http://', adapter)
    session.mount('https://', adapter)
    for method in ('get', 'post'):
        setattr(session, method, functools.partial(getattr(session, method), timeout=1))
    return session

get_users()
