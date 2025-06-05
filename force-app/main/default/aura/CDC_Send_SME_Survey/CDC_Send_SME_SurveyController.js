({
	doInit: function (component, event, helper) {
          var action = component.get("c.SendSurveyEmail");
        var pageReference = component.get("v.pageReference");
        var sURL = window.location.href;
		var caseIds = sURL.split('CaseId=')[1];
        console.log('before ' + caseIds);
        
        if(caseIds == 'undefined' || caseIds == undefined)
        {
          caseIds = component.get("v.recordId");
        }
        else
        {
            component.set("v.type", true);
        }
        console.log('after ' + caseIds);
        console.log(component.get("v.recordId"));
        
          action.setParams({
             caseID : caseIds
         });
          action.setCallback(this, function(response){
              var state = response.getState();
              if(state === 'SUCCESS'){
                  var returnValue = response.getReturnValue();
                  console.log(returnValue);
                  component.set("v.response",returnValue);
              }
          });
        $A.enqueueAction(action);
    },
    closeFocusedTab : function(component, event, helper) {
        window.self.close();

    }

})