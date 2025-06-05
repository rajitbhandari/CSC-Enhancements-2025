/**
 * Created by vpolavarapu on 9/19/2019.
 */

({
    doInit: function (component, event, helper) {
          var action = component.get("c.getOrganizedArticlesStructure");
          action.setParams({
             TopicId : component.get("v.recordId")
         });
          action.setCallback(this, function(response){
              var state = response.getState();
              var newItems=[];
              if(state === 'SUCCESS'){
                  let returnValue = response.getReturnValue();
                  console.log(returnValue);
                  if(returnValue.length!=0)
                  {
                        component.set('v.ArticlesIdentified', returnValue);
                      if(returnValue[0].PriorityArticlesForTheTopic != '' && returnValue[0].PriorityArticlesForTheTopic != null)
                      {
                      newItems.push(returnValue[0].PriorityArticlesForTheTopic);
                      }
                      if(newItems.length >0)
                      {
                          component.set('v.ShowKeyArticle',true);
                      }
                        var parent =  returnValue[0];
                        if(parent.childTopicsAssociated.length==0)
                        {
                            component.find("accordion").set('v.activeSectionName', parent.TopicId);
                        }
                  }
              }else if (state === 'ERROR'){
                  var errors = response.getError();
                  if (errors) {
                      if (errors[0] && errors[0].message) {
                          console.log("Error message: " +errors[0].message);
                      }
                  } else {
                      console.log("Unknown error");
                  }
              }else{
                  console.log('Something went wrong, Please check with your admin');
              }
          });
          $A.enqueueAction(action);
    },

});