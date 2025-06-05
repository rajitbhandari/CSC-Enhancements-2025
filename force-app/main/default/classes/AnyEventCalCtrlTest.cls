/**
*————————————————————————————————————————————————————
* @Name             AnyEventCalCtrlTest
* @Author           vpolavarapu
*
*
* @Changes
*
**/

@isTest(seeAllData=false)
public class AnyEventCalCtrlTest {
    
    static testMethod void getEventsTest() {
        AnyEventCalCtrl.getEvents('Event', 'Subject', 'StartDateTime', 'EndDateTime', 'Description', 'OwnerId', true,'Registration_Website__c');
        AnyEventCalCtrl.getEvents('Event', 'Subject', 'StartDateTime', 'EndDateTime', 'Description', 'OwnerId', false,'Registration_Website__c');
        list<event> lstE = TestFactory.returnEvents;
        System.assertEquals(lstE.size(), 2);
        AnyEventCalCtrl.getEvents('Event', 'Subject', 'StartDateTime', 'EndDateTime', 'Description', 'OwnerId', true,'Registration_Website__c');
        AnyEventCalCtrl.getEvents('Event', 'Subject', 'StartDateTime', 'EndDateTime', 'Description', 'OwnerId', false,'Registration_Website__c');
    }
    
    static testMethod void crudSecurityTest() {
        System.assertEquals(AnyEventCalCtrl.isAccessible('Event'),true);
        AnyEventCalCtrl.isAccessible('Event','Subject');
        System.assertEquals(AnyEventCalCtrl.isCreateable('Event'),true);
        AnyEventCalCtrl.isDeletable('Event');
    }
    
    

}