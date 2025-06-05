({
    upsertEvent : function(component, evObj, callback) {
        var action = component.get("c.upsertEvents");
        
        action.setParams({ 
            "sEventObj": JSON.stringify(evObj),
            "sObjectName" : component.get("v.sObjectName"),
            "titleField" : component.get("v.titleField"),
            "startDateTimeField" : component.get("v.startDateTimeField"),
            "endDateTimeField" : component.get("v.endDateTimeField"),
            "descriptionField" : component.get("v.descriptionField"),
            "userField" : component.get("v.userField")
        });
        
        if (callback) {
            action.setCallback(this, callback);
        }
        
        $A.enqueueAction(action);
    },
    deleteEvent : function(component, event, eventId, callback){
        var action = component.get("c.deleteEvent");
        
        action.setParams({ 
            "eventId": eventId,
            "sObjectName" : component.get("v.sObjectName"),
            "titleField" : component.get("v.titleField"),
            "startDateTimeField" : component.get("v.startDateTimeField"),
            "endDateTimeField" : component.get("v.endDateTimeField"),
            "descriptionField" : component.get("v.descriptionField"),
            "userField" : component.get("v.userField")
        }); 
        
        if (callback) {
            action.setCallback(this, callback);
        }
        
        $A.enqueueAction(action);
    },
    openModal : function(component, event) {
       
        component.set("v.isOpen", true);
    },
    closeModal : function(component, event) {
       
        component.set("v.isOpen", false);
    }
})