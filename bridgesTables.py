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

with connection.cursor() as con:
    heal_group(con)
