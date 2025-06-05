/**
*————————————————————————————————————————————————————
* @Name             AnyEventCalCtrl
* @Author           vpolavarapu
*
*————————————————————————————————————————————————————
* @Description
* Controller class to populate all the events which are in the system
*————————————————————————————————————————————————————
* @Changes
*
**/

public without sharing class AnyEventCalCtrl {
    /*
        Getevents will be called from the front end to retreive all the events which are to be displayed in communtiy
    */
    @AuraEnabled
    public static List<EventObj> getEvents(String sObjectName, String titleField, String startDateTimeField, String endDateTimeField, String descriptionField, String userField, Boolean filterByUserField,string webURL){
      //display all events to user         
         String q = 'SELECT Id,' + 
                String.valueOf(titleField) + ',' + 
            String.valueOf(startDateTimeField) + ',' +
            String.valueOf(endDateTimeField) + ',' +
            String.valueOf(descriptionField) + ',' +String.valueOf(webURL)+','+
            String.valueOf(userField) + ' FROM ' + 
            String.valueOf(sObjectName);
        system.debug(q);
        List<sObject> sObjectList = Database.query(q);
        system.debug(sObjectList);
        List<EventObj> eventRecords = new List<EventObj>();//wrapper list to hold Event records
       
         if(isAccessible(sObjectName)&&sObjectList.size()>0 ) {
         system.debug('has access');
            for (sObject obj : sObjectList) {
                EventObj newEv = new EventObj(obj.Id,
                                              String.valueOf(obj.get(titleField)),
                                              DateTime.valueOf(obj.get(startDateTimeField)),
                                              DateTime.valueOf(obj.get(endDateTimeField)),
                                              String.valueOf(obj.get(descriptionField)),
                                              String.valueOf(obj.get(userField)),
                                              String.valueOf(obj.get(webURL))
                                             );
                eventRecords.add(newEv);
            }
       }else{
       system.debug('no access');

       }
        return eventRecords;
    }    
    public class EventObj {
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public DateTime startDateTime {get;set;}
        @AuraEnabled
        public DateTime endDateTime {get;set;}
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled
        public String owner {get;set;}
         @AuraEnabled
        public String webURL {get;set;}
        
        public EventObj(String i,String t, DateTime s, DateTime e, String d, String o,string w){
            this.Id = i;
            this.title = t;
            this.startDateTime = s;
            this.endDateTime = e;
            this.description = d;
            this.owner = o;
            this.webURL=w;
        }
        
    }
    public static Boolean isAccessible(String sObjectType, String fieldName){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
        DescribeFieldResult fieldDescribe = fields.get(fieldName).getDescribe();
        return fieldDescribe.isAccessible();
    }
    public static Boolean isAccessible(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isAccessible();
    }
    public static Boolean isCreateable(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isCreateable();
    }
    public static Boolean isDeletable(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isDeletable();
    }
}