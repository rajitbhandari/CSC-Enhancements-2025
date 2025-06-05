@IsTest (SeeAllData=true) Public class Customlogin_CSC_Test {
   @IsTest public Static void Customlogin_CSC_Test() 
     {
        Customlogin_CSC_Test controller = new Customlogin_CSC_Test();       
        user sysuser = new user();
        sysuser.firstName = 'testrun';
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
         Customlogin_CSC.login('testrunbpc@test.com', 'Test@Password', 'testurl', 'Recaptcha1234');
         Customlogin_CSC.getIsUsernamePasswordEnabled();
         Customlogin_CSC.getIsSelfRegistrationEnabled();
         Customlogin_CSC.getSelfRegistrationUrl();
         Customlogin_CSC.getForgotPasswordUrl();
         Customlogin_CSC.getAuthConfig();
         Customlogin_CSC.setExperienceId('testnetid');
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
}