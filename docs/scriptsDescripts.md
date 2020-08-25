### ET_user_eai

create xlsx(s) (excel workbook(s)) to analyze a users engagement, adherence, and response to interventions.

Two tables, one with general User info and the second with all User statuses, General Bot statuses, DM Bot statuses to the user, and Group Leader statuses sorted by created_at date.

Through filtering and other means, one can use this data to determine what, if any, intervention triggered an adherence event.

You can pass in a path for where to save the file ex `my/special/data/folder`, it defaults to `data_export`.

**NOTE: this --pwd is the path but NOT the file name it should point to a directory without a closing slash.** 

```
Usage: ET_user_eai.rb { --all | --group-name:string | --account-id:integer | --username:string }

To filter by group or user, provide either a healgroup id, healgroup name, an account id or a username:
    -a, --all                        Find all users in the database
    -g, --group-name healgroup       Find all users in a healgroup by name
    -i, --account-id id              Find account by id
    -u, --username username          Find account by username
    -p, --pwd path/to/dir            Where to save the files
```

### ET_user_statuses

create a xlsx (excel workbook) with two sheets. `Users` and `Statuses`.

`Users` is a summary of a user with role:user along with aggregates for posts, pinned statuses, favourites, bridges posts, 'maybe bridges posts', engagement, etc

`Statuses` are all statuses for the Users along with if they post type.

You can pass in a path for where to save the file ex `my/special/data/folder`, it defaults to `data_export`.

**NOTE: this --pwd is the path but NOT the file name it should point to a directory without a closing slash.** 

```
Usage: ET_user_eai.rb --pwd path/to/folder

       -p, --pwd path/write/directory   Where to save the file
```

### quick_provision

creates groups and users. 

args
- FILE.json : a properly formatted json file for generating groups and users

**Note: this is an ad hoc solution for the summer pilots with no handling for situations where a group or user already exists. If something goes wrong during the execution of this script you will have to 'clean up' what got through before trying to use it again.**

ex in production:
 ```
RAILS_ENV=production exec ruby scripts/quick_provision.rb FILENAME.json
```

ex json for group formation:

an array of groups, with group name, start date, the initial password for accounts, and the id numbers for each account.
This is based on the Summer pilots where each account was of the form bridgesX@asu.edu. 
```json
[
          {
            "name":"SMART",
            "start_date":"2020-07-12",
            "password":"Bridges2020",
            "ids":[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
          },
          {
            "name":"BOLD",
            "start_date":"2020-07-11",
            "password":"Bridges2020",
            "ids":[ 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 ]
          }
        ]
```

### user_engagement_report

user engagement report gets user, group, or all passive, active, and/or bridges engagement events either as a count or with detailed information on each event when running with the optional `-v[erbose]` flag.

```
Usage: user_engagement_report.rb { --group-id:integer | --group-name:string | --account-id:integer | --username:string } [options]
   
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

