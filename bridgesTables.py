import psycopg2

connection = psycopg2.connect(
    host="postgresql://",
    database="mastodon_development",
    user="mastodon",
    password="t",
)
connection.autocommit = True

def heal_group(con):
    con.execute("""
       CREATE TABLE heal_groups (
       auth_token VARCHAR (9) PRIMARY KEY,
       group_name VARCHAR (50) NOT NULL
);
""")

def mod_user_group(con):
    con.execute("""
       ALTER TABLE users
       ADD COLUMN IF NOT EXISTS invite_end VARCHAR(80) NOT NULL DEFAULT 'No link',
       ADD COLUMN IF NOT EXISTS heal_group_name VARCHAR(20) NOT NULL DEFAULT 'No Group';
""")

 with connection.cursor() as con:
    heal_group(con)
    mod_user_group(con)

con.close()
