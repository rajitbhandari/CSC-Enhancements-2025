/**
*————————————————————————————————————————————————————
* @Name            EventTriggerHandlerTest
* @Author          from Vploavarapu
*
*
*————————————————————————————————————————————————————
* @Changes
*
**/
@IsTest
private class EventTriggerHandlerTest{
  
    static testMethod void test_NewCase() {
        list<event> lstE = TestFactory.returnEvents;
        System.assert(lstE.size()==2); 
        system.debug(lstE[0].IsVisibleInSelfService);
        
        lstE[0].IsVisibleInSelfService = true;
        update lstE[0];
        system.debug(lstE[0].IsVisibleInSelfService);
        System.assertEquals(lstE[0].IsVisibleInSelfService, true);
        
    }
   
}