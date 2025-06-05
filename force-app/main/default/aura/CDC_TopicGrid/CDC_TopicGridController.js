({
	doInit: function (component, event, helper) {
          var action = component.get("c.getTopics");
          action.setCallback(this, function(response){
              var state = response.getState();
              if(state === 'SUCCESS'){
                  let returnValue = response.getReturnValue();
                  console.log(returnValue);
                  
                  component.set('v.Topics',returnValue);
              }
                  
          });
          $A.enqueueAction(action);
    },
})