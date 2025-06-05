@isTest
public class certHeaderUserTest{

    static testMethod void testRunAs() {

     Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', 
                          Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', 
                          FirstName = 'Test',
                          LastName='User', 
                          LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='standarduser@testorg.com',
                          IsActive = true);
        certHeaderUser.fetchUser();
	}
}