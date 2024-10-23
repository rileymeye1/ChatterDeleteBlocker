public with sharing class DisableChatterDeleteHandler
{
    public static boolean allowDelete()
    {
        Chatter_Delete_Settings__c settings = Chatter_Delete_Settings__c.getInstance();
        if (settings.Allow_Feed_Post_and_Comment_Deletes__c == false || settings == null)
        {
            // do default settings
            String profileId = UserInfo.getProfileId();
            Boolean modifyAllData = [SELECT PermissionsModifyAllData FROM Profile WHERE Id = :profileId].PermissionsModifyAllData;
            
            if (modifyAllData)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        else
        {
            // use custom defined settings
            return settings.Allow_Feed_Post_and_Comment_Deletes__c;
        }
    }
}