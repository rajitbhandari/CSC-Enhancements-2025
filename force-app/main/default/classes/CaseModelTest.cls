/**
*————————————————————————————————————————————————————
* @Name            CaseModel
* @Author          from Vploavarapu
*

*————————————————————————————————————————————————————
* @Changes
*
**/

@isTest
Private class CaseModelTest{
     static testMethod void CaseModelTestMethod1(){
         contact conn = TestFactory.returnContact;
         // case coming via email
         Case cs = new Case();
         cs.Origin = 'Email';
         cs.SuppliedName = 'test LN';
         cs.SuppliedEmail = 'test@test.com';
         cs.status = 'open';
         cs.Contactid = conn.id;
         insert cs;
         System.assertEquals(cs.status!=null, True);
         
         // check if their is a contact which got created 
         list<contact> conList = [select id from contact where email='test@test.com'];
         system.debug(conList );
         
         CaseContactRole cCR = new CaseContactRole();
         cCR.CasesId= cs.id;
         cCR.ContactId= conn.id;
         cCR.Role = 'SME';
         insert cCR;
         
         System.assertEquals(cs.id, cCR.CasesId);
         cs.Type ='Website Support';
         cs.Type_of_Inquiry__c ='Other';
         cs.accountid=  TestFactory.returnAccounts[0].id;
         update cs; 
         //now change the status of case to closed 
         cs.Case_Close_Reason__c='Closed by CSC Agent';
         cs.Level_of_Difficulty__c= 'Easy'; // to pass the validation
         cs.status = 'closed';
         update cs;
         System.assertEquals(cs.status, 'closed'); 
     }
     static testMethod void CaseModelTestMethod2(){
        //test no supplied name scenario
         Case cs1 = new Case();
         cs1.Origin = 'Email';
         cs1.SuppliedName = '';
         cs1.SuppliedEmail = 'test@test.com';
         insert cs1;
     }
     static testMethod void CaseModelTestMethod3(){
        //test supplied name contains scenario
         Case cs1 = new Case();
         cs1.Origin = 'Email';
         cs1.SuppliedName = 'testLN';
         cs1.SuppliedEmail = 'test2@test.com';
         insert cs1;
      } 
}