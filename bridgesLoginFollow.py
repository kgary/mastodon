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
global group
global oauth
global username
global invite_end

config = configparser.ConfigParser()
config.read('config.ini')
connection = psycopg2.connect(
    host=config['database']['host'],
    database=config['database']['database'],
    user=config['database']['user'],
    password=config['database']['password']
)

connection.autocommit = True

def get_account():
    print(payload)
    global id
    execId = "SELECT id FROM users WHERE email = %s"
    with connection.cursor() as con:
        con.execute(execId, (payload['email'], ))
        id = con.fetchone()[0]
    con.close()
    return id

def is_globalModOrAdmin():
    execMod = "SELECT admin, moderator FROM users WHERE id = %s and heal_group_name = 'Global';"
    with connection.cursor() as con:
        con.execute(execMod, (id, ))
        modFlags = con.fetchone()
    if modFlags[0] == True or modFlags[1] == True:
        return True
        con.close()
    else:
        return False
        con.close()

def get_group():
    global group
    execGroup = "SELECT heal_group_name FROM users WHERE id = %s"
    invite = (id, )
    with connection.cursor() as con:
        con.execute(execGroup, invite)
        group = con.fetchone()[0]
    con.close()
    return group

def group_follows():
    get_group()
    tokenExec = "SELECT token FROM oauth_access_tokens WHERE resource_owner_id = %s;"
    with connection.cursor() as con:
        con.execute(tokenExec, (id, ))
        try:
            oauthPayload = con.fetchone()
            oauth = oauthPayload[0]
        except TypeError:
            con.close()
            sys.exit('No auth token for user, cannot login/modify')

        if "Group" in group:
            gListExec = "SELECT account_id from users where heal_group_name = %s;"
            con.execute(gListExec, (group, ))
            groupList = con.fetchall()
        else:
            con.close()
            sys.exit('User is not part of a group for study, no follows will be performed')

        fListExec = "SELECT target_account_id FROM follows WHERE account_id = %s;"
        con.execute(fListExec, (id, ))
        followList = con.fetchall()

        modExec = "SELECT account_id FROM users where admin = 't' or (moderator = 't' and heal_group_name = 'Global');"
        con.execute(modExec)
        modList = con.fetchall()

    con.close()

    followNonTup = []
    for tup in followList:
        followNonTup.append(tup[0])

    groupList += modList
    nonTupList = []
    for tup in groupList:
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

def mod_follows():
    tokenExec = "SELECT token FROM oauth_access_tokens WHERE resource_owner_id = %s;"
    with connection.cursor() as con:
        con.execute(tokenExec, (id, ))
        try:
            oauthPayload = con.fetchone()
            oauth = oauthPayload[0]
        except TypeError:
            con.close()
            sys.exit('No auth token for user, cannot login/modify')

        # duplicate code?
#         modExec = "SELECT account_id FROM users where admin = 't' or moderator = 't';"
#         con.execute(modExec)
#         modList = con.fetchall()

        # get all user ids
        userListExec = "SELECT id FROM users;" 
        con.execute(userListExec)
        userList = con.fetchall()

        # get all ids user is already following
        fListExec = "SELECT target_account_id FROM follows WHERE account_id = %s;"
        con.execute(fListExec, (id, ))
        followList = con.fetchall()

        # get all ids for admins and Global moderators is not needed if we are already getting all user ids
#         modExec = "SELECT account_id FROM users where admin = 't' or (moderator = 't' and heal_group_name = 'Global');"
#         con.execute(modExec)
#         modList = con.fetchall()
#         con.close()

    followNonTup = []
    for tup in followList:
        followNonTup.append(tup[0])

#     userList # redundant?
    nonTupList = []
    for tup in userList:
        nonTupList.append(tup[0])

    follow_user(nonTupList, followNonTup, oauth)

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

get_account()

if is_globalModOrAdmin():
    mod_follows()
else:
    group_follows()
