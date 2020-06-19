Reset Server
--- 

To reset an instance is to purge it of all user data, there are 3 sources of user data:
- PostgreSQL
- public/system/* 
- Redis Database

To begin the purge:
1. re-load the PostgreSQL DB\
```RAILS_ENV=production bundle exec rake db:schema:load DISABLE_DATABASE_ENVIRONMENT_CHECK=1 SAFETY_ASSURED=1```\
**TODO include info on how to create initial admin account**
2. delete public/system/* `rm -R public/system/*`
**If you make it this far you can rest easy**
3. TODO find best/safe way to purge redis
