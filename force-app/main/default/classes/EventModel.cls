/**
*————————————————————————————————————————————————————
* @Name            EventModel
* @Author          from Vploavarapu
*
*————————————————————————————————————————————————————
* @Description
* This class is primarly is to make a record event.IsVisibleInSelfService as true if
* Available_on_CDC_Portal__c is True,doing this visa trigger because we were not able to update via workflow
*
*————————————————————————————————————————————————————
* @Changes
*
**/

public class EventModel {
    
      private Map<Id,Event> oldRecords;
      private list<event> newRecords;
    
      public static void processEvents(Map<Id,sobject> oldRecords, list<sobject> newRecords) {
        system.debug('new'+newRecords);
          EventModel engine = new EventModel((Map<Id,Event>)oldRecords,(list<event>) newRecords);
         engine.modifyEventRecs()  ;
      }
    
       private EventModel(Map<Id,Event> oldRecords, list<event> newRecords) {
        
        // since this should be called from a trigger, it assumes 
        //   1) all object are same type
        //   2) oldRecords and newRecords contain complimentary objects
        this.oldRecords = oldRecords == null ? new Map<Id,Event>() : oldRecords;
        this.newRecords = newRecords;

    }
    
    private void modifyEventRecs()
    {
        system.debug(newRecords);
        if(!newRecords.isEmpty())
        {
            for(Event so:newRecords)
            {
                if(so.Available_on_CDC_Portal__c)
                {
                    system.debug('make it visible in portal');
                    so.IsVisibleInSelfService = true;
                }
            }
        }
        
    }
    
    
}