({
	CreateInitialCase : function(component,event,helper,FieldWrapper,Isfinal) {
    	var action = component.get("c.saveResults");
        var fsname = component.get('v.fieldSetName');
        //alert('fsname'+fsname);
        action.setParams({
             'DisplayFieldInfoJson'  : JSON.stringify(FieldWrapper),
             'recordId' : component.get("v.myRecordId"),
            'FieldSetName' : fsname,
            'IsfinalUpdate': Isfinal
        });
        action.setCallback(this,function(response){
            	var state = response.getState();
				if (state === "SUCCESS") {
                    console.log(response.getReturnValue());
					var deserializedString = response.getReturnValue();
                    if(deserializedString.isSuccess)
                    {
                        component.set("v.myRecordId", deserializedString.recordID);
                        if(!Isfinal)
                        {
                             component.set("v.currentStep", "2");
                        }
                        component.set("v.FinalStepComplete", !(deserializedString.recordinfo.Case_In_Draft_Mode__c));
                    	//alert(component.get('v.FinalStepComplete'));
                    }else{
                        component.set("v.errorMessage", 'Please contact admin, error Code :'+deserializedString.status); 
                    }
                    //showToast(component,event,helper);
                    if(component.get('v.FinalStepComplete'))
                    {
                        this.showToast(component,event,helper);
                        this.gotoURL(component, event, helper);
                    }
                    //component.set("v.processing",false); 
                }
        	}
        )
	$A.enqueueAction(action);
    },
    gotoURL : function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/"
        });
        urlEvent.fire();
    },
    
    deleteAttachments : function(component,event,helper,selectedRecordId) {
        
		var action = component.get("c.getAttachments");
        action.setParams({
            'parentId' : component.get("v.myRecordId"),
            'recordId' : selectedRecordId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            
				if (state === "SUCCESS") {
               		var deserializedString = response.getReturnValue();
                    console.dir(deserializedString);
                    component.set("v.AttachedFiles",deserializedString); 
                }
        })
	$A.enqueueAction(action);
    },  
    getFieldsToDisplay : function(component,event,feildsetName,FieldSetNumber) {
		var action = component.get("c.getfieldinfo");
        action.setParams({
            'fieldsetName' : feildsetName 
            
        });
        let helper = this;
        //alert('responding>>');
        action.setCallback(this,function(response){
            	var state = response.getState();
				if (state === "SUCCESS") {
               		var deserializedString = response.getReturnValue();
                    var arr_from_json = JSON.parse( deserializedString );
                    console.dir(arr_from_json);
                    if(FieldSetNumber==1)
                    {
                        component.set("v.FieldWrapper", arr_from_json);
                    }
                    if(FieldSetNumber==2)
                    {
                        component.set("v.FieldWrapper2", arr_from_json);
                    }
                    console.dir(component.get('v.FieldWrapper'));
        			console.dir(component.get('v.FieldWrapper2')); 
                }
        	}
        )
	$A.enqueueAction(action);
    },
    validateForm: function (component, FieldWrapper) {
        console.dir(FieldWrapper);
        var text ='Error(s)<br/>';
        for (var i = 0; i < FieldWrapper.length; i++) {            
            if(FieldWrapper[i].isRequired==true && (FieldWrapper[i].Value==null || FieldWrapper[i].Value==false )){
                text += FieldWrapper[i].question+" : Please enter value. <br/>";
                 document.body.scrollTop = 0;
       			 document.documentElement.scrollTop = 0;
            }
        }
        console.log(text);
        component.set("v.errorMessage", text);        
    },
     concatLists : function(component){
   		//alert(component.get("v.FieldWrapper2").length);
   		if(component.get("v.FieldWrapper2").length>0)
        {
          	var children = component.get("v.FieldWrapper").concat(component.get("v.FieldWrapper2")); 
            component.set("v.completeWrapper", children);
            console.log(component.get("v.completeWrapper"));  
        }else{
            component.set("v.completeWrapper", component.get("v.FieldWrapper"));
        }
        
        //alert(component.get("v.completeWrapper"));
       // component.set("v.currentStep", "3");
    },
    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
	},
    ValidateStep : function(component,event,helper,isNext,clicked,clickedLastPage){
         // control the next button based on 'currentStep' attribute value 
         //alert('r'); 
        var getCurrentStep = component.get("v.currentStep");
        //alert(getCurrentStep);
        if(getCurrentStep == "1" ){
        	this.validateForm(component,component.get("v.FieldWrapper")); 
        }else if(getCurrentStep == "2" ){
            //alert('r'); 
            this.validateForm(component,component.get("v.FieldWrapper2"));  
        }else{
            //alert('test');
            this.validateForm(component,component.get("v.completeWrapper"));
        }
        //alert(component.get("v.errorMessage")+'ddd');
        // if(component.get("v.errorMessage")=='Error(s)<br/>')
         {
            
             component.set("v.errorMessage", '');
                if(isNext) 
                {
                    var getCurrentStep = component.get("v.currentStep");
                   
                    if(getCurrentStep == "1"){
                        this.CreateInitialCase(component,event,helper,component.get("v.FieldWrapper"),false); 
                    }
                    else if(getCurrentStep == 2){
                        this.concatLists(component);
                        component.set("v.currentStep", "3");
                    }  
                }else{
                    if(clicked==1)
                    {                       
                        this.CreateInitialCase(component,event,helper,component.get("v.FieldWrapper"),false); 
                    }
                    else if(clicked==2)
                    {
                        this.CreateInitialCase(component,event,helper,component.get("v.FieldWrapper"),false);
                        
                      
                    }
            		else if(clicked==3)
                    {
                       
                        component.set("v.currentStep", "3");
                    }
                }
                
         }
    }
})