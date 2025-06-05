/**
*————————————————————————————————————————————————————
* @Name            TestFactory
* @Author          from vPolavarapu
* @Description    using singleton, lazy loading pattern to create the test data which can be reused across test clasess
*
*————————————————————————————————————————————————————
* @Changes
*
**/
public with sharing class TestFactory {
    
     /*******************************************************************************************************
    * @description generate events
    * @param   n/a
    * @return List<events> ; 
    */
    private static List<Event> EventLst = null;
    public static List<Event> returnEvents{
        get {
            if (EventLst == null) {
                    EventLst = new List<event>{
                        new event(Registration_Website__c = 'www.google.com',OwnerId = UserInfo.getUserId(),Subject= 'Test 1',Available_on_CDC_Portal__c=true,StartDateTime=datetime.now().addHours(23),EndDateTime=datetime.now().addhours(45)),
                        new event(Registration_Website__c = 'www.goole.com',OwnerId = UserInfo.getUserId(),Subject= 'Test 2',StartDateTime=datetime.now().addHours(123),EndDateTime=datetime.now().addhours(145))
                    };
                if(Test.isRunningTest()) {
                    insert EventLst;
                    system.debug(EventLst);
                }
            }
            
            return EventLst;
        }
    }
    
     /*******************************************************************************************************
    * @description generate Account
    * @param   n/a
    * @return List<Account> ; 
    */
    private static List<Account> AccountLst = null;
    public static List<Account> returnAccounts{
        get {
            if (AccountLst== null) {
                    AccountLst = new List<Account>{
                        new account(Name= 'Account 1',OwnerId = UserInfo.getUserId(),ShippingPostalCode='67863',Is_this_Organization_CDC_Recognized__c='Yes',Type='University / School',Org_Code__c='3432222'),
                        new account(Name= 'Account 2',OwnerId = UserInfo.getUserId(),ShippingPostalCode = '24244')
                    };
                if(Test.isRunningTest()) {
                    insert AccountLst;
                    
                }
            }
            
            return AccountLst;
        }
    }
    /*******************************************************************************************************
    * @description generate ContentVersion
    * @param   n/a
    * @return List<ContentVersion> ; 
    */
    private static List<ContentVersion> ContentVersionLst = null;
    public static List<ContentVersion> returnContentVersions{
        get {
            if (ContentVersionLst== null) {
                    ContentVersionLst= new List<ContentVersion>{
                        new ContentVersion(
              Title = 'Penguins',
              PathOnClient = 'Penguins.jpg',
              VersionData = Blob.valueOf('Test Content'),
              IsMajorVersion = true
            ),
                        new ContentVersion(
              Title = 'Penguins1',
              PathOnClient = 'Penguins1.jpg',
              VersionData = Blob.valueOf('Test Content1'),
              IsMajorVersion = true
            )
                    };
                if(Test.isRunningTest()) {
                    insert ContentVersionLst;
                    
                }
            }
            
            return ContentVersionLst;
        }
    }
    /*******************************************************************************************************
    * @description generate Contact
    * @param   n/a
    * @return Contact ; 
    */
    private static Contact cont= null;
    public static Contact returnContact{
        get {
            if (cont== null) {
                        cont = new Contact();
                        cont.FirstName='Test';
                        cont.LastName='Test';
                        cont.Email='Test@test.com';
                        cont.Accountid= returnAccounts[0].id;
                        
                   
                if(Test.isRunningTest()) {
                    insert cont;
                }
            }
            
            return cont;
        }
    }
        
    /*******************************************************************************************************
    * @description generate users
    * @param   n/a
    * @return List<users> ; 
    */
    private static List<user> UserLst = null;
    public static List<user> returnUsers{
        get {
            if (UserLst == null) {
                     Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
                     UserRole roleId= new UserRole(Name = 'CSC Agent');
                    UserLst = new List<user>{
                        new user(Alias = 'standt1', Email='standarduser1@testorg.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = p.Id, Org_Code__c='567545',UserRoleId = roleId.id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@testorg.com'),
                        new user(Alias = 'standt2', Email='standarduser2@testorg.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = p.Id, Org_Code__c='567545',UserRoleId = roleId.id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@testorg.com')
                    };
                if(Test.isRunningTest()) {
                    system.debug(UserLst);
                }
            }
            
            return UserLst ;
        }
    }
    
    
}