/**
*————————————————————————————————————————————————————
* @Name            DisplayFormsControllerTest
* @Author          from Vploavarapu
*
*————————————————————————————————————————————————————
* @Changes
*
**/

@istest
private class DisplayFormsControllerTest{

    static testMethod void TestMethod1(){
    User u;
    User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
     System.runAs ( thisUser ) {
        EmailTemplate e = new EmailTemplate (developerName = 'test', isactive=true,FolderId = UserInfo.getUserId(),TemplateType= 'Text', Name = 'test'); // plus any other fields that you want to set
         insert e;
         Profile p = [select id from profile where name='System Administrator'];
        UserRole r = [Select id from userrole where name='CEO'];
        u = new User(alias = 'standt', email='standarduser1@testorg.com', 
            emailencodingkey='UTF-8', lastname='Testing', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, userroleid = r.Id,
            timezonesidkey='America/Los_Angeles', 
            username='test78@testorg.com');       
         }
        System.runAs(u) {
         contact conn = TestFactory.returnContact;
         list<id> conIds = new List<id>();
         conIds.add(conn.id);
         Case cs = new Case();
         cs.Origin = 'Email';
         cs.SuppliedName = 'test LN';
         cs.SuppliedEmail = 'test@test.com';
         cs.status = 'open';
         cs.Contactid = conn.id;
         insert cs;
         System.assertEquals(cs.status, 'open'); 
         list<id> caseIds = new List<id>();
         caseIds.add(cs.id);
         CDC_ApexUtilities.SendEmailNotification(conIds);
      
         System.assertEquals(caseIds.size()==1, true);
         CDC_ApexUtilities.getPickValues('Case','Status','None');
         CDC_ApexUtilities.getPickValuesMap('Case','Status','None');
         CDC_ApexUtilities.isAccessible('Case','Status');
         CDC_ApexUtilities.isAccessible('Case');
         CDC_ApexUtilities.isCreateable('Case');
         CDC_ApexUtilities.isDeletable('Case');
         }
     }
     static testMethod void TestMethod2(){
         contact conn = TestFactory.returnContact;
         Case cs = new Case();
         cs.Origin = 'Email';
         cs.SuppliedName = 'test LN';
         cs.SuppliedEmail = 'test@test.com';
         cs.status = 'open';
         cs.Contactid = conn.id;
         insert cs;
        DisplayFormsThroughFieldSetController.getfieldinfo('Submit_Feedback_Success');
        string jsonS = '[{"Value":"How the National DPP has impacted me as an individual","question":"I want to submit a success story about...","picklistValues":["How the National DPP has impacted my organization and those we serve","How the National DPP has impacted me as an individual","How the resources Ive accessed through the CSC have impacted my Organization and those we serve"],"noOfPages":null,"isRequired":true,"hasPicklistValues":true,"fieldType":"PICKLIST","fieldlLabel":"Success story about","fieldApiName":"success_story_is_about__c"},{"Value":"test","question":"What was the challenge you originally faced?","picklistValues":[],"noOfPages":null,"isRequired":true,"hasPicklistValues":null,"fieldType":"TEXTAREA","fieldlLabel":"Challenge faced:","fieldApiName":"Challengefaced__c"},{"Value":"test","question":"What was the solution to your challenge?","picklistValues":[],"noOfPages":null,"isRequired":true,"hasPicklistValues":null,"fieldType":"TEXTAREA","fieldlLabel":"Solution:","fieldApiName":"Solution__c"},{"Value":"test","question":"What were your results?","picklistValues":[],"noOfPages":null,"isRequired":true,"hasPicklistValues":null,"fieldType":"TEXTAREA","fieldlLabel":"Results:","fieldApiName":"Results__c"},{"Value":"test","question":"Would you like to highlight a particular quote that summarizes the impact youre describing?","picklistValues":[],"noOfPages":null,"isRequired":false,"hasPicklistValues":null,"fieldType":"TEXTAREA","fieldlLabel":"Impact quote:","fieldApiName":"Impact_quote__c"}]';
        DisplayFormsThroughFieldSetController.saveResults(jsonS,cs.id,'Submit_Feedback_Success',true);
        DisplayFormsThroughFieldSetController.saveResults(jsonS,'','Submit_Feedback_Success',false);
        DisplayFormsThroughFieldSetController.saveResults(jsonS,'','Submit_Knowledge_Articles',true);
        List<EmailMessage> newEmail = new List<EmailMessage>();
        newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = cs.Id));
        insert newEmail;
        DisplayFormsThroughFieldSetController.getEmails(cs.id);
        List<ContentVersion> conVer = new List<ContentVersion>();
        conVer = TestFactory.returnContentVersions;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = cs.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        System.assertEquals(cdl!=null, true); 
        DisplayFormsThroughFieldSetController.getAttachments(cs.id,conVer[0].id);
       }
       static testMethod void TestMethod3(){
         contact conn = TestFactory.returnContact;
         Case cs = new Case();
         cs.Origin = 'Email';
         cs.SuppliedName = 'test LN';
         cs.SuppliedEmail = 'test@test.com';
         cs.status = 'open';
         cs.Contactid = conn.id;
         insert cs;
         System.assertEquals(conn.Email, 'Test@test.com');
        string jsonS = '[{"Value":"fdf","question":"Resource Summary:","picklistValues":[],"noOfPages":null,"isRequired":false,"hasPicklistValues":null,"fieldType":"TEXTAREA","fieldlLabel":"Resource Summary:","fieldApiName":"Resource_Summary__c"},{"Value":"University / School;Health Care Organization / Pharmacy;","question":"Does this add value to one of the following groups of CSC target audiences?","picklistValues":["State, Local, Tribal, and Federal Government","Employer / Worksite","Insurer / Health Plan","University / School","Health Care Organization / Pharmacy","Community-Based Organization","Faith-Based Organization","Professional Organization / Association","Other - Private Business"],"noOfPages":null,"isRequired":false,"hasPicklistValues":true,"fieldType":"MULTIPICKLIST","fieldlLabel":"Target audiences:","fieldApiName":"Target_audiences__c"},{"Value":"Referred to DPRP Data Team","question":"Case Reason","picklistValues":["Closed by CSC Agent","Closed by CSC SME","Referred to CMS MDPP","Referred to DPRP Data Team","Referred to Other External Partner"],"noOfPages":null,"isRequired":false,"hasPicklistValues":true,"fieldType":"PICKLIST","fieldlLabel":"Case Reason","fieldApiName":"Reason"},{"Value":"sfsdg","question":"Subject","picklistValues":[],"noOfPages":null,"isRequired":false,"hasPicklistValues":null,"fieldType":"STRING","fieldlLabel":"Subject","fieldApiName":"Subject"},{"Value":"2018-02-14","question":"Resource Expiration Date","picklistValues":[],"noOfPages":null,"isRequired":false,"hasPicklistValues":null,"fieldType":"DATE","fieldlLabel":"Resource Expiration Date","fieldApiName":"Resource_Expiration_Date__c"},{"Value":true,"question":"Survey Generated","picklistValues":[],"noOfPages":null,"isRequired":false,"hasPicklistValues":null,"fieldType":"BOOLEAN","fieldlLabel":"Survey Generated","fieldApiName":"Survey_Generated__c"},{"Value":"2018-02-28T17:00:00.000Z","question":"Triaged Date","picklistValues":[],"noOfPages":null,"isRequired":false,"hasPicklistValues":null,"fieldType":"DATETIME","fieldlLabel":"Triaged Date","fieldApiName":"Triaged_Date__c"}]';
        DisplayFormsThroughFieldSetController.saveResults(jsonS,cs.id,'Submit_Feedback_Success',true);
        
       }

}