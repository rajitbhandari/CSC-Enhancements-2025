@isTest public class CaseTriggerHelperTest {

    @testSetup static void setup() {
        Account closedAccount = new Account(
            Name = 'Case Account',
            ShippingPostalCode= '48105');
        insert closedAccount;
         
        Case parentCase = new Case(
            Status ='Closed',
            Type = 'National DPP Technical Assistance',
            Type_of_Inquiry__c = 'I have a data related question',
            Origin = 'Email',
            AccountId = closedAccount.Id);
        insert parentCase;
      
        EmailMessage parentEmailMessage = new EmailMessage(
            status = '3',
            parentId = parentCase.Id,
            fromAddress = 'sender@example.com',
            fromName = 'Dan Perkins',
            subject = 'This is the Subject!',
            htmlBody = '<html><body><b>Hello</b></body></html>',
            textBody = 'Hello',
            toAddress = 'emailnotinsalesforce@toexample.com, anotherone@toexample.com');
        insert parentEmailMessage;
    }

    @IsTest public static void copyRecentEmailAddressFromParentToChildInsert () {                                                   
        
        Case parentCase = [SELECT Id FROM Case LIMIT 1];
       
        Case childCase = new Case(
            Status ='New', 
            parentId = parentCase.Id , 
            Origin = 'Email');
        insert childCase;
        
        List<EmailMessage> childEmailMessage = [SELECT Id FROM EmailMessage WHERE parentId =: childCase.Id];
        System.assertEquals(1,childEmailMessage.size(),'No Email Message is created for child case');
    }
    
    /*@IsTest public static void copyRecentEmailAddressFromParentToChildUpdate () {                                                   
        Case parentCase = [SELECT Id,AccountId FROM Case LIMIT 1];
        
        Case childCase = new Case(
            Status ='Closed', 
            Type = 'National DPP Technical Assistance',
            Type_of_Inquiry__c = 'I have a data related question',
            parentId = parentCase.Id , 
            Origin = 'Email',
            AccountId = parentCase.AccountId);
        insert childCase;
        
        //Before status Update
        List<EmailMessage> childEmailMessage = [SELECT Id FROM EmailMessage WHERE parentId =: childCase.Id];
        System.assertEquals(0,childEmailMessage.size());
        
        childCase.status='New';
        update childCase;
        
        List<EmailMessage> childEmailMessage1 = [SELECT Id FROM EmailMessage WHERE parentId =: childCase.Id];
        System.assertEquals(1,childEmailMessage1.size());
    }*/
}