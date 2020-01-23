import sys
import psycopg2
import json
import requests
import time
from datetime import datetime
#set x to the parameters being passed to the script then jsonify it
x = sys.argv[1]
payload = json.loads(x)
global id
global group
global oauth
global username
global invite_end
connection = psycopg2.connect(
    host="localhost",
    database="mastodon_development",
    user="mastodon",
    password="t",
)

connection.autocommit = True

def get_account(con):
    global id
    execId = "SELECT id FROM users WHERE email = %s"
    con.execute(execId, (payload['email'], ))
    id = con.fetchone()[0]
    return id

def get_group(con):
    global group
    execGroup = "SELECT heal_group_name FROM users WHERE id = %s"
    invite = (id, )
    con.execute(execGroup, invite)
    group = con.fetchone()[0]
    return group

def group_follows(con):
    get_account(con)
    get_group(con)
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
    groupList += modList
    follow_user(groupList, followList, oauth)

def follow_user(u, f, oauth):
    con.close()
    form = {'authenticity_token': payload['auth_token']}
    headers = {'Authorization': 'Bearer ' + oauth}
    endpoint = '/api/v1/accounts/{id}/follow'
    for user in u:
        if user[0] != id and user[0] not in f:
            r = requests.post('http://localhost:3000' + endpoint.replace('{id}', str(user[0])), headers=headers, data=form)
            print("Followed: " + str(user[0]))

with connection.cursor() as con:
    group_follows(con)

con.close()
