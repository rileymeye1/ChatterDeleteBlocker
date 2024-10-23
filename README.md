# Chatter Delete Blocker

This package will limit Feed Post and Comment deletes to Users with a Profile that has the Modify All Data permission.

1. Create a Custom Setting (Setup > Quick Find > Custom Settings > New)
     - **Label** = Chatter Delete Settings
     - **Object Name** = Chatter_Delete_Settings
     - **Setting Type** = Hierarchy
     - **Visibility** = Public
     - **Description** = Allows for org-wide, profile, and user based settings for Disable Chatter Delete application.

2. Create a Custom Field on the Custom Setting
     - **Data Type** = Checkbox
     - **Field Label** = Allow Feed Post and Comment Deletes
     - **Default Value** = Unchecked
     - **Field Name** = Allow_Feed_Post_and_Comment_Deletes
     - **Description** = Allows users specified in this hierarchy to delete Feed Posts and Comments.
     - **Help Text** = This may be set to org-wide, profile, or user level. If it is checked for a particular hierarchy, all users specified to that hierarchy will be able to delete Feed Posts and Comments.

3. Add the Apex Classes and Triggers from this project to the Org.
4. If you need to allow a specific Profile or User to delete Feed Post and Comments then you will need to navigate to the Chatter Delete Settings and click Manage. Here you can add a Profile or User to be authorized to delete Feed Post and Comments.
