/**
 * Created by vpolavarapu on 9/19/2019.
 */

({
        navigateToKnowledgeURL : function(component, event, helper) {
            var sObectEvent = $A.get("e.force:navigateToSObject");
             sObectEvent .setParams({
                "recordId": event.currentTarget.id ,
                "slideDevName": "detail"
             }).fire();
        }
});