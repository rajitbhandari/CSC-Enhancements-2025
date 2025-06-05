({
    init: function (cmp, event, helper) {
        
        cmp.set('v.mycolumns', [
            {label: 'View', fieldName: 'Id', type: 'url',typeAttributes :{ label: 'view',onclick:"alert('this will not work')" }},
                {label: 'Email date', fieldName: 'MessageDate', type: 'Text'},
                {label: 'subject', fieldName: 'Subject', type: 'Text'},
            	{label: 'Body', fieldName: 'TextBody', type: 'Text'}
            
            ]);
        helper.getData(cmp);
        },
    
    createRecord : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": "02sr0000000fXTWAA2",
          "slideDevName": "related"
        });
        navEvt.fire();
	},
    doInit: function(component, event, helper) {      
    // Fetch the account list from the Apex controller 
    helper.getEmailList(component,component.get("v.NoOfRecordsToDisplay"));
  },
    loadRecord: function(component, event, helper) {      
    // Fetch the account list from the Apex controller   
   //alert(event.currentTarget.id);
        var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParam("recordId", event.currentTarget.id);
         navEvt.fire();
  },
   loadMoreRecord: function(component, event, helper) {      
    	var EmailMessageCount = component.get("v.EmailMessageList").length;
       var noofRecord = component.get("v.NoOfRecordsToDisplay");
       	var offsetRecord = Number(noofRecord) + EmailMessageCount;
       helper.getEmailList(component,String(offsetRecord));
  }
    
    
})