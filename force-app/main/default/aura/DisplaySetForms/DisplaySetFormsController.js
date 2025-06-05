({
	myAction : function(component, event, helper) {
       var a = component.get("v.recordId");
       
       if(component.get('v.fieldSetName')!='')
       {
           helper.getFieldsToDisplay(component,event,component.get('v.fieldSetName'),1);
       }
       if(component.get('v.fieldSetName2')!='')
       {
           helper.getFieldsToDisplay(component,event,component.get('v.fieldSetName2'),2);
       }
       
	},
    handleUploadFinished: function (component, event) {
        // Get the list of uploaded files
        //component.set("v.processing",true);
        var uploadedFiles = event.getParam("files");
        console.log(uploadedFiles);
        component.set("v.AttachedFiles",uploadedFiles); 
        console.log(component.get('v.FieldWrapper'));
       // component.set("v.processing",false);
    },
	deleteAttach : function (component, event,helper) {
        var selectedRecordId =event.currentTarget.id;
        
        helper.deleteAttachments(component,event,helper,selectedRecordId);
},
    handleSubmit: function (component, event, helper) {       
        helper.validateForm(component,component.get("v.completeWrapper"));
    	if(component.get("v.errorMessage")=='Error(s)<br/>'){
            component.set("v.errorMessage", '');
           // component.set("v.processing",true); 
            helper.CreateInitialCase(component,event,helper,component.get("v.completeWrapper"),true); 
			
    	}
    },
    moveNext : function(component,event,helper){
        helper.ValidateStep(component,event,helper,true,null,false);
    },
    
    moveBack : function(component,event,helper){
      // control the back button based on 'currentStep' attribute value    
        var getCurrentStep = component.get("v.currentStep");
         if(getCurrentStep == "2"){
            component.set("v.currentStep", "1");
         }
         else if(getCurrentStep == 3 && !component.get("v.FinalStepComplete")){
            component.set("v.currentStep", "2");
             
         }
    },
   
   // when user click direactly on step 1,step 2 or step 3 indicator then showing appropriate step using set 'currentStep'   
    selectFromHeaderStep1 : function(component,event,helper){        
      if(!component.get("v.FinalStepComplete") )
      {
          
          helper.ValidateStep(component,event,helper,false,1,false);
      }
      
     
    },
    selectFromHeaderStep2 : function(component,event,helper){
        if(!component.get("v.FinalStepComplete"))
        {
            
            helper.ValidateStep(component,event,helper,false,1,false);
        }
    },
    selectFromHeaderStep3 : function(component,event,helper){
      
      /*  if(!component.get("v.FinalStepComplete"))
          {
               helper.concatLists(component);
               helper.ValidateStep(component,event,helper,false,1,true);
          } */
       
    },
    showSpinner: function(component, event, helper) {
       component.set("v.Spinner", true);
    },
    hideSpinner : function(component,event,helper){
     component.set("v.Spinner", false);
    }
    
    
   

})