⚠️🚧`UNDER CONSTRUCTION`🚧⚠️

#### Who follows who

The following table represents how users, moderators, and admins will follow and be followed based on their group and role. `GroupX` is meant to represent `[Group 1, Group 2, Group 3]` meaning the way follows work is the same for anyone in a Group, **NOT** that they will follow all people in Groups. GroupX users and moderators _only follow people in their **same** group_.
| follows/followed by | **User_GroupX** | **User_Global** | **Moderator_GroupX** | **Moderator_Global** | **Admin_GroupX** | **Admin_Global** |
| --- | --- | --- | --- | --- | --- | --- |
| **User_GroupX** | x |  | x |  | x | x |
| **User_Global** |  |  |  |  | x | x |
| **Moderator_GroupX** | x |  | x |  | x | x |
| **Moderator_Global** | x | x | x | x | x | x |
| **Admin_GroupX** | x | x | x | x | x | x |
| **Admin_Global** | x | x | x | x | x | x |

#### Backend roles : Frontend Roles

`Admin` : PI and CO\
`Moderator_Global` : RAs, technical support\
`Moderator_GroupX` : Group leaders\
`User_GroupX` : group members\
`User_Global` : does not map to any known role

#### Create a Moderator
logged in as Admin, navigate to [Preferences > Moderation > Accounts](https://heal3.poly.asu.edu/admin/accounts), select user you wish to promote and in the Permissions field click 'Promote', confirm promotion and now user should be shown as 'Moderator'

#### Allow Moderators to Create Invite Links
In mastodon, logged in as an `ADMIN`, navigate to `Preferences -> Administration -> Site Settings`, find "Allow invitations by" and set to `Moderator`
