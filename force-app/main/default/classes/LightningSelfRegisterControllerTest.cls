/**
*————————————————————————————————————————————————————
* @Name            LightningSelfRegisterControllerTest
* @Author          from Vpolavarapu
* @Description     testing LightningSelfRegisterController
*
*————————————————————————————————————————————————————
* @Changes
*
**/
@IsTest(SeeAllData = false)
public with sharing class LightningSelfRegisterControllerTest {

 /* Verifies that IsValidPassword method with various password combinations. */
 @IsTest
 static void testIsValidPassword() {
  System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'password?@12334') == true);
  System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'dummyPassword') == false);
  System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', null) == false);
  System.assert(LightningSelfRegisterController.isValidPassword(null, 'fakePwd') == false);
  System.assert(LightningSelfRegisterController.validatePassword(new user(),'test','test') == null);
 }

 @IsTest
 static void testSiteAsContainerEnabled() {
  System.assertNotEquals(null, LightningSelfRegisterController.siteAsContainerEnabled('https://portaleu1-developer-edition.eu11.force.com'));
 }

 /* Verifies the selfRegistration method flow with various invalid inputs */
 @IsTest
 static void testSelfRegistration() {
 List<Account> accList = TestFactory.returnAccounts;
  System.assert(accList.size() >= 1);
  LightningSelfRegisterController.getAccountRec(accList[0].id);
  System.assert(TestFactory.returnContact !=null);
  Map < String, String > paramsMap = initializeParams();
  System.assertNotEquals(null, paramsMap);
  string extraField = '[{"dbRequired":false,"fieldPath":"Color__c","label":"Color","required":false,"type":{},"value":"454"},{"dbRequired":true,"fieldPath":"Alias","label":"Alias","required":false,"type":{},"value":"546fg"}]';
 
  user us1 = new User(CompanyName = 'cmp 1',
                      CDC_User_Profile_Type__c='CDC-Recognized Organizations',
                      Zip_Code__c = '21212',
                      Alias = 'standt1',
                      Email='Test@test.com', 
            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', Org_Code__c='567545',
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@testorg.com');

 // LightningSelfRegisterController.selfRegister(us1,'other Value', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), accList[0].id, paramsMap.get('regConfirmUrl'), extraField, paramsMap.get('startUrl'), false,'test');
  
         user us = new User(CompanyName = 'cmp 2',CDC_User_Profile_Type__c='CDC-Recognized Organizations',Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',  Org_Code__c='567099',Zip_Code__c = '21212',
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');

  user sysuser = new user();
        sysuser.firstName = 'testrun';
        sysuser.CompanyName = 'cmp 1';
        sysuser.CDC_User_Profile_Type__c='CDC-Recognized Organizations';
        sysuser.Zip_Code__c = '21212';
        sysuser.Org_Code__c='567545';
        sysuser.lastName='lstname';
        sysuser.Alias='tstlst';
        sysuser.email='testrunbpc@test.com';
        sysuser.userName= 'testrunbpc@test.com';
        sysuser.EmailEncodingKey='UTF-8'; 
        sysuser.LanguageLocaleKey='en_US';
        sysuser.LocaleSidKey='en_US';
        sysuser.TimeZoneSidKey='America/Los_Angeles';
        sysuser.profileId= [SELECT Id FROM Profile where Name = 'System Administrator'].id;
        insert sysuser;
         system.runAs(sysuser)
         {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new GoogleHTTPCalloutMock());
             LightningSelfRegisterController.selfRegister(us1,'other Value', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), string.valueof(accList[0].id), paramsMap.get('regConfirmUrl'), extraField, paramsMap.get('startUrl'), false,'test1234'); 
             Test.stopTest();
         }
 
 }
    
@IsTest
 static void testSelfRegistration2() {
 List<Account> accList = TestFactory.returnAccounts;
  System.assert(accList.size() >= 1);
  LightningSelfRegisterController.getAccountRec(accList[0].id);
  System.assert(TestFactory.returnContact !=null);
  Map < String, String > paramsMap = initializeParams();
  System.assertNotEquals(null, paramsMap);
  string extraField = '[{"dbRequired":false,"fieldPath":"Color__c","label":"Color","required":false,"type":{},"value":"454"},{"dbRequired":true,"fieldPath":"Alias","label":"Alias","required":false,"type":{},"value":"546fg"}]';
 
  user us1 = new User(CompanyName = 'cmp 1',
                      CDC_User_Profile_Type__c='CDC-Recognized Organizations',
                      Zip_Code__c = '21212',
                      Alias = 'standt1',
                      Email='Test@test.com', 
            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', Org_Code__c='567545',
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@testorg.com');

  
         user us = new User(CompanyName = 'cmp 2',CDC_User_Profile_Type__c='CDC-Recognized Organizations',Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',  Org_Code__c='567099',Zip_Code__c = '21212',
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');

  user sysuser = new user();
        sysuser.firstName = 'testrun';
        sysuser.CompanyName = 'cmp 1';
        sysuser.CDC_User_Profile_Type__c='CDC-Recognized Organizations';
        sysuser.Zip_Code__c = '21212';
        sysuser.Org_Code__c='567545';
        sysuser.lastName='lstname';
        sysuser.Alias='tstlst';
        sysuser.email='testrunbpc@test.com';
        sysuser.userName= 'testrunbpc@test.com';
        sysuser.EmailEncodingKey='UTF-8'; 
        sysuser.LanguageLocaleKey='en_US';
        sysuser.LocaleSidKey='en_US';
        sysuser.TimeZoneSidKey='America/Los_Angeles';
        sysuser.profileId= [SELECT Id FROM Profile where Name = 'System Administrator'].id;
        insert sysuser;
         system.runAs(sysuser)
         {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new GoogleHTTPCalloutMock());
             LightningSelfRegisterController.selfRegister(us, '','', '', '', paramsMap.get('regConfirmUrl'), extraField, paramsMap.get('startUrl'), true,'test');
 
             Test.stopTest();
         }
 
 }
    @IsTest
 static void testSelfRegistration3() {
 List<Account> accList = TestFactory.returnAccounts;
  System.assert(accList.size() >= 1);
  LightningSelfRegisterController.getAccountRec(accList[0].id);
  System.assert(TestFactory.returnContact !=null);
  Map < String, String > paramsMap = initializeParams();
  System.assertNotEquals(null, paramsMap);
  string extraField = '[{"dbRequired":false,"fieldPath":"Color__c","label":"Color","required":false,"type":{},"value":"454"},{"dbRequired":true,"fieldPath":"Alias","label":"Alias","required":false,"type":{},"value":"546fg"}]';
 
  user us1 = new User(CompanyName = 'cmp 1',
                      CDC_User_Profile_Type__c='CDC-Recognized Organizations',
                      Zip_Code__c = '21212',
                      Alias = 'standt1',
                      Email='Test@test.com', 
            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', Org_Code__c='567545',
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@testorg.com');

  
         user us = new User(CompanyName = 'cmp 2',CDC_User_Profile_Type__c='CDC-Recognized Organizations',Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',  Org_Code__c='567099',Zip_Code__c = '21212',
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');

  user sysuser = new user();
        sysuser.firstName = 'testrun';
        sysuser.CompanyName = 'cmp 1';
        sysuser.CDC_User_Profile_Type__c='CDC-Recognized Organizations';
        sysuser.Zip_Code__c = '21212';
        sysuser.Org_Code__c='567545';
        sysuser.lastName='lstname';
        sysuser.Alias='tstlst';
        sysuser.email='testrunbpc@test.com';
        sysuser.userName= 'testrunbpc@test.com';
        sysuser.EmailEncodingKey='UTF-8'; 
        sysuser.LanguageLocaleKey='en_US';
        sysuser.LocaleSidKey='en_US';
        sysuser.TimeZoneSidKey='America/Los_Angeles';
        sysuser.profileId= [SELECT Id FROM Profile where Name = 'System Administrator'].id;
        insert sysuser;
         system.runAs(sysuser)
         {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new GoogleHTTPCalloutMock());
             LightningSelfRegisterController.selfRegister(us, 'other Value',paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), extraField, paramsMap.get('startUrl'), true,'test'); 
             Test.stopTest();
         }
 
 }
    
    
    public class GoogleHTTPCalloutMock implements HttpCalloutMock 
{    
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) 
    {
      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"success":"true"}');          
      res.setStatusCode(200);          
      return res;          
    }
  }


 /* Verifies the selfRegistration flow for valid inputs */
 @IsTest
 static void testSelfRegisterWithProperCredentials() {
  Map < String, String > paramsMap = initializeParams();
  //System.assertEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
 }

 /* Verifies SelfRegistration flow with an accounId that is created within the test */
 @IsTest
 static void testSelfRegisterWithCreatedAccount() {
  
  Account acc = new Account(name = 'test acc',ShippingPostalCode ='20202');
  insert acc;
  List < Account > accounts = [SELECT Id FROM Account LIMIT 1];
  System.assert(!accounts.isEmpty(), 'There must be at least one account in this environment!');
  String accountId = accounts[0].Id;
  Map < String, String > paramsMap = initializeParams();
  //System.assertEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), accountId, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false));
 }



 @IsTest
 static void LightningSelfRegisterControllerInstantiation() {
  System.assert(TestFactory.returnAccounts.size() >= 1);
  LightningSelfRegisterController controller = new LightningSelfRegisterController();
  LightningSelfRegisterController.getprofileTypeValues();
  System.assert(LightningSelfRegisterController.cdcRecognizedValues().size() >= 1);
  System.assert(LightningSelfRegisterController.getReferralQuestions().size() >= 1);
  LightningSelfRegisterController.setExperienceId('3648376');
  System.assertNotEquals(controller, null);
  LightningSelfRegisterController.lookup('Account','Account','CDC_Recognized__c= true','','');
 }

 /* Helper method to initialize the parameters required for SelfRegistration. */
 private static Map < String, String > initializeParams() {
  Map < String, String > paramsMap = new Map < String, String > (); 
  String firstName = 'test';
  String lastName = 'User';
  String email = 'testUser@salesforce.com';
  String password = 'testuser123';
  String confirmPasswordCorrect = 'testuser123';
  String confirmPasswordWrong = 'wrongpassword';
  String accountId = 'testuser123';
  String regConfirmUrl = 'http://registration-confirm.com';
  String startUrl = 'http://my.company.salesforce.com';
  paramsMap.put('firstName', firstName);
  paramsMap.put('lastName', lastName);
  paramsMap.put('email', email);
  paramsMap.put('password', password);
  paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
  paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
  paramsMap.put('accountId', accountId);
  paramsMap.put('regConfirmUrl', regConfirmUrl);
  paramsMap.put('startUrl', startUrl);
  return paramsMap;
 }
}