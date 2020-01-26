import sys
import os
import psycopg2
import json
import requests
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
global loggedIn

filepath = 'config.txt'

if not os.path.isfile(filepath):
    print('File does not exist, setting defaults')
    connection = psycopg2.connect(
        host="localhost",
        database="mastodon_development",
        user="mastodon",
        password="t"
    )
else:
    with open(filepath, 'r') as f:
        configVars = f.readlines()
        connection = psycopg2.connect(
            host=configVars[0].strip().split('=')[1],
            database=configVars[1].strip().split('=')[1],
            user=configVars[2].strip().split('=')[1],
            password=configVars[3].strip().split('=')[1]
        )

connection.autocommit = True

def get_account():
    global id
    idExec = "SELECT id FROM accounts WHERE username = %s;"
    with connection.cursor() as con:
        con.execute(idExec, (payload['username'], ))
        id = con.fetchone()[0]
    con.close()
    return id

def get_group():
    global group
    groupExec = "SELECT comment FROM invites WHERE code = %s;"
    with connection.cursor() as con:
        invite = (payload['invite_end'], )
        con.execute(groupExec, invite)
        group = con.fetchone()[0]
    con.close()
    return group

def get_logged_in():
    global loggedIn
    loggedExec = "SELECT token,resource_owner_id FROM oauth_access_tokens;"
    with connection.cursor() as con:
        con.execute(loggedExec)
        loggedIn = con.fetchall()
    con.close()
    return loggedIn

def mod_user():
    modifyExec = "UPDATE users SET invite_end = %s, heal_group_name = %s, confirmed_at = now() WHERE account_id = %s;"
    with connection.cursor() as con:
        con.execute(modifyExec, (payload['invite_end'], get_group(), get_account(),))
    con.close()
    group_follows()

def group_follows():
    global group
    global id
    global loggedIn
    get_logged_in()
    with connection.cursor() as con:
        tokenExec = "SELECT token FROM oauth_access_tokens WHERE resource_owner_id = %s;"
        con.execute(tokenExec, (id, ))
        oauth = con.fetchone()[0]
        if len(oauth) < 2:
            sys.exit('No auth token for user, cannot login/modify')

        gListExec = "SELECT account_id FROM users WHERE heal_group_name = %s;"
        con.execute(gListExec, (group, ))
        groupList = con.fetchall()

        fListExec = "SELECT target_account_id FROM follows WHERE account_id = %s;"
        con.execute(fListExec, (id, ))
        followList = con.fetchall()

        modExec = "SELECT account_id FROM users where admin = 't' or moderator = 't';"
        con.execute(modExec)
        modList = con.fetchall()
    con.close()

    #need just the group, no mods for later
    justGroupList = groupList.copy();
    #combine group and mod lists
    groupList += modList

    #strip the tuples list to just a list of values
    followNonTup = []
    for tup in followList:
        followNonTup.append(tup[0])

    nonTupListAll = []
    for tup in groupList:
        nonTupListAll.append(tup[0])

    nonTupListGroup = []
    for tup in justGroupList:
        nonTupListGroup.append(tup[0])

    groupLoggedin = []
    for tup in loggedIn:
        if tup[1] in nonTupListGroup:
            groupLoggedin.append(tup[0])
    #initiate follows both ways
    follow_user(nonTupListAll, followNonTup, oauth)
    follow_loggedin(groupLoggedin)

def follow_user(u, f, oauth):
    form = {'authenticity_token': payload['auth_token']}
    headers = {'Authorization': 'Bearer ' + oauth}
    endpoint = '/api/v1/accounts/{id}/follow'
    req = requests_retry_session()
    for user in u:
        if user not in f:
            r = req.post('http://localhost:3000' + endpoint.replace('{id}', str(user)), headers=headers, data=form)
            print("Followed: " + str(user))

def follow_loggedin(i):
    form = {'authenticity_token': payload['auth_token']}
    endpoint = '/api/v1/accounts/{id}/follow'.replace('{id}', str(id))
    req = requests_retry_session()
    for token in i:
        headers = {'Authorization': 'Bearer ' + token}
        r = req.post('http://localhost:3000' + endpoint, headers=headers, data=form)

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

mod_user()

