# ET_user_eai

# ET_user_statuses

# quick_provision

# user_engagement_report

user engagement report gets user, group, or all passive, active, and/or bridges engagement events either as a count or with detailed information on each event when running with the optional `-v[erbose]` flag.

```Usage: user_engagement_report.rb { --group-id:integer | --group-name:string | --account-id:integer | --username:string } [options]
   
   To filter by group or user, provide either a healgroup id, healgroup name, an account id or a username:
       -d, --group-id id                Find all users in a healgroup by id
       -g, --group-name healgroup       Find all users in a healgroup by name
       -i, --account-id id              Find account by id
       -u, --username username          Find account by username
       -l, --min-date DateTime          Minimum value for date range: 'YYYY-MM-DD' OR 'YYYY-MM-DD hh:mm:ss +offset' (-7 for MST)
       -m, --max-date DateTime          Maximum value for date range: 'YYYY-MM-DD' OR 'YYYY-MM-DD hh:mm:ss +offset' (-7 for MST)
       -f, --file FILE.json             Name of file. Default: testy.json
   
   Options:
       -b, --bridges                    Get Bridges Specific Events
       -e, --active                     Get Active Engagement Events
       -p, --passive                    Get Passive Engagement Events
       -a, --all                        Get all Engagement Events: Active, Passive, and Bridges
       -v, --verbose                    Run verbosely
```

ex in production: get detailed report on all engagement events for username `kgary` from 7/11 at 3:00pm AZ to 7/13 at 1:00pm AZ (inclusive)
 
`RAILS_ENV=production ruby scripts/user_engagement_report.rb -u kgary --min-date '2020-07-11 16:00:00 -7' --max-date '2020-07-13 13:00:00 -7' -av`

