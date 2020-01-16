import sys
import psycopg2

#get string from args, remove escape chars and split since it duplicates, parse to username and invite
x = sys.argv[2]
z = x.decode('string_escape').split('\n')[0].strip('{}')
username = z.split(',')[0].split(':')[1]
invite = z.split(',')[1].split(':')[1].strip()
print('user:' + username + " invite_code:" + invite)
global id
global group

connection = psycopg2.connect(
    host="localhost",
    database="mastodon_development",
    user="mastodon",
    password="t",
)

connection.autocommit = True

def get_account(con):
    con.execute("""
       SELECT id
       FROM accounts
       WHERE username = '%s';
    """ % username)
    id = int(con.fetchone()[0])
    print(type(id))
    return id

def get_group(con):
    con.execute("""
       SELECT comment
       FROM invites
       WHERE code = '%s';
    """ % invite)
    group = con.fetchone()[0]
    return group

def mod_user(con):
    con.execute("""
       UPDATE users
       SET invite_end = '%s',
       heal_group_name = '%s'
       WHERE account_id = %d;
    """ % (invite, get_group(con), get_account(con)))

with connection.cursor() as con:
    mod_user(con)

con.close()

