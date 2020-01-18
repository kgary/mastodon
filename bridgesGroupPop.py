import sys
import psycopg2
import json
import requests
import time
from datetime import datetime
#set x to the parameters being passed to the script then jsonify it
print("getting args")
print(sys.argv)
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
    print("getting ID")
    global id
    execId = "SELECT id FROM accounts WHERE username = %s"
    print(type(payload['username']))
    con.execute(execId, (payload['username'], ))
    id = con.fetchone()[0]
    return id

def get_group(con):
    global group
    execGroup = "SELECT comment FROM invites WHERE code = %s"
    print(type(payload['invite_end']))
    invite = (payload['invite_end'], )
    con.execute(execGroup, invite)
    group = con.fetchone()[0]
    return group

def mod_user(con):
    execMod = "UPDATE users SET invite_end = %s, heal_group_name = %s, confirmed_at = now() WHERE account_id = %s;"
    con.execute(execMod, (payload['invite_end'], get_group(con), get_account(con),))
    print("getting groups")
    group_follows(con)

def group_follows(con):
    global group
    global id
    tokenExec = "SELECT token FROM oauth_access_tokens WHERE resource_owner_id = %s;"
    con.execute(tokenExec, (id, ))
    oauth = con.fetchone()[0]

    gListExec = "SELECT account_id FROM users WHERE heal_group_name = %s;"
    con.execute(gListExec, (group, ))
    groupList = con.fetchall()

    fListExec = "SELECT target_account_id FROM follows WHERE account_id = %s;"
    con.execute(fListExec, (id, ))
    followList = con.fetchall()
    follow_user(groupList, oauth)

def follow_user(u, oauth):
    form = {'authenticity_token': payload['auth_token']}
    headers = {'Authorization': 'Bearer ' + oauth}
    endpoint = '/api/v1/accounts/{id}/follow'
    for user in u:
        if user[0] != id:
            r = requests.post('http://localhost:3000' + endpoint.replace('{id}', str(user[0])), headers=headers, data=form)
            print("Followed: " + str(user[0]))

with connection.cursor() as con:
    mod_user(con)

con.close()
