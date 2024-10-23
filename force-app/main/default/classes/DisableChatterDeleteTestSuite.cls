@isTest
private class DisableChatterDeleteTestSuite
{
    static void deleteAllCustomSettings()
    {
        Chatter_Delete_Settings__c[] settings = [SELECT Id
                                                FROM Chatter_Delete_Settings__c];
        Database.delete(settings);
    }
    
    static User insertAdminUser()
    {
        Profile prof = [SELECT Id
                        FROM Profile
                        WHERE Name = 'System Administrator'];

        User u = new User (
            Alias = 'systadm',
            Email = 'deleteblockersystemAdmin@testorg.com',
            FirstName = 'Admin User',
            LastName = 'Testing',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles',
            ProfileId = prof.Id,
            Username = 'deleteblockersystemAdmin@testorg.com'
        );
        Database.SaveResult sr = Database.Insert(u);
        System.assertEquals(true, sr.isSuccess(), 'System Admin User failed to create');
        User newAdminUser = [SELECT Id
                            FROM User
                            WHERE Id = :sr.getId()
                            LIMIT 1];
        return newAdminUser;
    }

    static User insertNonAdminUser()
    {
        Profile prof = [SELECT Id
                        FROM Profile
                        WHERE Name = 'Standard User'];

        User u = new User (
            Alias = 'stduser',
            Email = 'DeleteBlockerStandardUser@testorg.com',
            FirstName = 'Standard User',
            LastName = 'Testing',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles',
            ProfileId = prof.Id,
            Username = 'DeleteBlockerStandardUser@testorg.com'
        );
        Database.SaveResult sr = Database.Insert(u);
        System.assertEquals(true, sr.isSuccess(), 'Non System Admin User failed to create');
        User newStdUser = [SELECT Id
                            FROM User
                            WHERE Id = :sr.getId()
                            LIMIT 1];
        return newStdUser;
    }

    static Case insertCase()
    {
        Case c = new Case(
            Subject = 'Test Case'
        );
        Database.SaveResult sr = Database.Insert(c);
        System.assertEquals(true, sr.isSuccess(), 'Test Case failed to create');
        Case newCase = [SELECT Id
                        FROM Case
                        WHERE Id = :sr.getId()
                        LIMIT 1];
        return newCase;
    }

    @isTest
    static void testFeedItemDeleteSysAdmin()
    {
        // Test Deleting a Feed Item as a System Admin
        deleteAllCustomSettings();
        User adminUser = insertAdminUser();
        Case testCase = insertCase();

        System.runAs(adminUser)
        {
            FeedItem p = new FeedItem(
                parentId = testCase.Id,
                Body = 'This is a Feed Item!'
            );
            Database.SaveResult sr = Database.insert(p);

            FeedItem newFeedItem = [SELECT Id
                                    FROM FeedItem
                                    WHERE Id = :sr.getId()
                                    LIMIT 1];
            Database.DeleteResult dr = Database.delete(newFeedItem);
            System.assertEquals(true, dr.isSuccess(), 'System Admin failed to delete Feed Item');
        }
    }

    @isTest
    static void testFeedCommentDeleteSysAdmin()
    {
         // Test Deleting a Feed Comment as a System Admin
        deleteAllCustomSettings();
        User adminUser = insertAdminUser();
        Case testCase = insertCase();

        System.runAs(adminUser)
        {
            FeedItem p = new FeedItem(
                parentId = testCase.Id,
                Body = 'This is a Feed Item!');
            Database.Insert(p);

            FeedComment c = new FeedComment(
                feedItemId = p.id,
                CommentBody = 'This is a Feed Comment!'
            );
            Database.insert(c);

            Database.DeleteResult dr = Database.delete(c);
            System.assertEquals(true, dr.isSuccess(), 'System Admin failed to delete Feed Comment');
        }
    }

    @isTest
    static void testFeedItemDeleteStandardUser()
    {
        // Test Deleting a Feed Item as a Standard User without Custom Settings
        deleteAllCustomSettings();
        User standardUser = insertNonAdminUser();
        Case testCase = insertCase();

        System.runAs(standardUser)
        {
            FeedItem p = new FeedItem(
                parentId = testCase.Id,
                Body = 'This is a Feed Item!'
            );
            Database.insert(p);
            try {
                Database.delete(p);
            } catch (System.DmlException e) {
                System.assertEquals('Your administrator has disabled feed post and comment deletions.', e.getDmlMessage(0), 'Standard User was able to delete Feed Item.');
            }
        }
    }

    @isTest
    static void testFeedCommentDeleteStandardUser()
    {
        // Test Deleting a Feed Comment as a Standard User without Custom Settings
        deleteAllCustomSettings();
        User standardUser = insertNonAdminUser();
        Case testCase = insertCase();

        System.runAs(standardUser)
        {
            FeedItem p = new FeedItem(
                parentId = testCase.Id,
                Body = 'This is a Feed Item!'
            );
            Database.insert(p);

            FeedComment c = new FeedComment(
                feedItemId = p.id,
                CommentBody = 'This is a Feed Comment!'
            );
            Database.insert(c);

            try {
                Database.delete(c);
            } catch (System.DmlException e) {
                System.assertEquals('Your administrator has disabled feed post and comment deletions.', e.getDmlMessage(0), 'Standard User was able to delete Feed Comment.');
            }
        }
    }

    @isTest
    static void testFeedItemDeleteProfile()
    {
        // Test Deleting a Feed Item as a Standard User with Profile with Custom Setting
        deleteAllCustomSettings();
        User standardUser = insertNonAdminUser();
        Case testCase = insertCase();

        Profile prof = [SELECT Id
                        FROM Profile
                        WHERE Name = 'Standard User'];
        Chatter_Delete_Settings__c settings = new Chatter_Delete_Settings__c(
            Allow_Feed_Post_And_Comment_Deletes__c = true,
            SetupOwnerId = prof.id
        );
        Database.upsert(settings);

        System.runAs(standardUser)
        {
            FeedItem p = new FeedItem(
                parentId = testCase.id,
                Body = 'This is a Feed Item!'
            );
            Database.insert(p);
            Database.DeleteResult dr = Database.delete(p);
            System.assertEquals(true, dr.isSuccess(), 'Standard User Profile failed to delete Feed Item');
        }
    }

    @isTest
    static void testFeedCommentDeleteProfile()
    {
        // Test Deleting a Feed Comment as a Standard User with Profile with Custom Setting
        deleteAllCustomSettings();
        User standardUser = insertNonAdminUser();
        Case testCase = insertCase();

        Profile prof = [SELECT Id
                        FROM Profile
                        WHERE Name = 'Standard User'];
        Chatter_Delete_Settings__c settings = new Chatter_Delete_Settings__c(
            Allow_Feed_Post_And_Comment_Deletes__c = true,
            SetupOwnerId = prof.Id
        );
        Database.upsert(settings);

        System.runAs(standardUser)
        {
            FeedItem p = new FeedItem(
                parentId = testCase.Id,
                Body = 'This is a Feed Item!'
            );
            Database.insert(p);

            FeedComment c = new FeedComment(
                feedItemId = p.Id,
                CommentBody = 'This is a Feed Comment!'
            );
            Database.insert(c);

            Database.DeleteResult dr = Database.delete(c);
            System.assertEquals(true, dr.isSuccess(), 'Standard User Profile failed to delete Feed Comment');
        }
    }

    @isTest
    static void testFeedItemDeleteUser()
    {
        // Test Deleting a Feed Item as a Standard User with Custom Setting
        deleteAllCustomSettings();
        User standardUser = insertNonAdminUser();
        Case testCase = insertCase();

        Chatter_Delete_Settings__c settings = new Chatter_Delete_Settings__c(
            Allow_Feed_Post_And_Comment_Deletes__c = true,
            SetupOwnerId = standardUser.id
        );
        Database.upsert(settings);

        System.runAs(standardUser)
        {
            FeedItem p = new FeedItem(
                parentId = testCase.id,
                Body = 'This is a Feed Item!'
            );
            Database.insert(p);

            Database.DeleteResult dr = Database.delete(p);
            System.assertEquals(true, dr.isSuccess(), 'Standard User failed to delete Feed Item');
        }
    }

    @isTest
    static void testFeedCommentDeleteUser()
    {
        // Test Deleting a Feed Comment as a Standard User with Custom Setting
        deleteAllCustomSettings();
        User standardUser = insertNonAdminUser();
        Case testCase = insertCase();
    
        Chatter_Delete_Settings__c settings = new Chatter_Delete_Settings__c(
            Allow_Feed_Post_And_Comment_Deletes__c = true,
            SetupOwnerId = standardUser.Id
        );
        Database.upsert(settings);

        System.runAs(standardUser)
        {
            FeedItem p = new FeedItem(
                parentId = testCase.Id,
                Body = 'This is a Feed Item!'
            );
            Database.insert(p);

            FeedComment c = new FeedComment(
                feedItemId = p.Id,
                CommentBody = 'This is a Feed Comment!'
            );
            Database.insert(c);

            Database.DeleteResult dr = Database.delete(c);
            System.assertEquals(true, dr.isSuccess(), 'Standard User Profile failed to delete Feed Comment');
        }
    }
}