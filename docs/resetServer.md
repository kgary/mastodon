Reset Server
--- 

To reset an instance is to purge it of all user data, there are 3 sources of user data:
- PostgreSQL
- public/system/* 

To begin the purge:
0. backup psql db and public/system
```
pg_dump mastodon_production | gzip > [filename].gz
cp -r public/system [destination]
```
1. re-load the initial PostgreSQL DB\
    ```RAILS_ENV=production bundle exec rake db:schema:load DISABLE_DATABASE_ENVIRONMENT_CHECK=1 SAFETY_ASSURED=1```\
    If desired, you can auto gen the `Gloabl` group and Admin by adding and defining these `.env` variables and running `RAILS_ENV=production bundle exec rake db:seed`. 
      ```bash
      ADMIN_USERNAME=<username>
      ADMIN_EMAIL=<email@email.email>
      ADMIN_PASSWORD=<password>
      ```
    If you do not do this, your first step will be creating an admin. Next create the Global group and move the admin to Global. Then be sure to disable sign in from the admin settings to prevent users signing up without a link.
 
2. delete public/system/* `rm -R public/system/*`

**Note: to reload a gzip db make sure the database exists and then load the dump** 
```
dropdb [dbname]
createdb [dbname]
gunzip -c [FILENAME.gz] | psql [dbname]
```

