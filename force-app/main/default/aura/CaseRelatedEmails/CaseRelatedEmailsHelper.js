({
    getData : function(cmp) {
        var action = cmp.get('c.getEmails');
        action.setParams({
            'parentId' : cmp.get('v.recordId') 
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.mydata', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },
    
    // Fetch the accounts from the Apex controller
  getEmailList: function(component,NoOfRecordsToDisplay) {
    var action = component.get('c.getEmails');
    action.setParams({
           //limitCount: NoOfRecordsToDisplay,
        	'parentId' : component.get("v.recordId")
        });
    // Set up the callback
    var self = this;
    action.setCallback(this, function(actionResult) {
    
     component.set('v.EmailMessageList', actionResult.getReturnValue());
      //  if(NoOfRecordsToDisplay>actionResult.getReturnValue().length){
            component.set("v.disableLoadMoreButton",true);
        	component.set("v.sizeofMails",actionResult.getReturnValue().length);
        console.log(actionResult.getReturnValue());
        
       // }
    });
    $A.enqueueAction(action);
  }
    
})