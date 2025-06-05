({
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap2}).fire();        
     
         helper.getUserProfilePicklistval(component, event, helper);
        helper.cdcRecognizedValues(component, event, helper);
        helper.getReferredByPicklistval(component, event, helper);
    },
     valueChanged: function (component, event, helper) {
        var accountObject = component.get('v.orgCodeObject');
        console.dir(accountObject);
		 //alert(accountObject);
         component.set('v.accountId',accountObject);
        if(accountObject!=null){
           var accountRecValue = helper.getAccountDetails(component, event, helper);
            component.set('v.orgfieldVisiblility',true);
        }else{
            
            if(component.get("v.orgfieldVisiblility")==true){
                component.set('v.userObject.Org_Code__c',null);
                component.set('v.userObject.CDC_User_Profile_Type__c',null);
                component.set('v.userObject.CDC_Recognized_org__c',null);
                component.set('v.userObject.Zip_Code__c',null);
                component.set('v.userObject.CDC_Recognized__c',null);
                component.set("v.isCDCRecognized",false); 
            }
            component.set('v.orgfieldVisiblility',false);
        }
        
    },
    handleSelfRegister: function (component, event, helpler) {
        component.set("v.Spinner", true);
        component.set("v.checkSuccess", false);
        document.dispatchEvent(new CustomEvent("grecaptchaExecute", {"detail": {action: "selfLoginCSC"}}));
        document.addEventListener("grecaptchaVerified", function(e) {
            if (component.get("v.checkSuccess") == false)
            {
            if (e.detail.action !== 'selfLoginCSC') 
            {
                return;
            }
            else
            {
                component.set("v.response",e.detail.response);
                component.set("v.checkSuccess", true);
                helpler.handleSelfRegister(component, event, helpler);
                
                
            }
           }
        });
        
        //helpler.handleSelfRegister(component, event, helpler);
    },
    redirectToHome: function (component, event, helpler) {
        
        window.open("/s","_self");
    },
    onCheck: function(cmp, evt) {
        console.log('is it running?');
        cmp.set("v.termsAndConditions",cmp.find("termscheckbox").get("v.checked"));
        console.log('data test',cmp.get("v.termsAndConditions"));
    },
    setStartUrl: function (component, event, helpler) {
        
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    
    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component, event, helper);
    },
        
    onKeyUp: function(component, event, helpler){
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helpler.handleSelfRegister(component, event, helpler);
        }
    },
    OtherOrgType: function(component, event, helpler){
        if(component.get("v.userObject.CDC_User_Profile_Type__c")!='Other')
        {
            component.set("v.otherOrgType",''); 
        }
    },
    OtherReferred: function(component, event, helpler){
        if(component.get("v.userObject.User_Referred_to_CSC_by__c")!='Other')
        {
            component.set("v.otherOrgType1",''); 
        }
    },
    CheckCDCRecognized: function(component, event, helpler){
        //checks for "enter" key
      // alert(component.get("v.userObject.CDC_Recognized_org__c"));
        if(component.get("v.userObject.CDC_Recognized_org__c")=='Yes')
        {
            component.set("v.isCDCRecognized",true); 
        }else{
            component.set("v.isCDCRecognized",false); 
            component.set("v.userObject.Org_Code__c",null); 
           
        }
    },
    CheckIfCDCRecognized: function(component, event, helpler){
        //checks for "enter" key
       // alert(component.get("v.userObject.CDC_Recognized__c"));
        if(component.get("v.userObject.CDC_Recognized__c")==true)
        {
            //alert(component.get("v.isCDCRecognized"));
            component.set("v.isCDCRecognized",true); 
             
            	
           // alert(component.get("v.isCDCRecognized"));
        }else{
            component.set("v.isCDCRecognized",false); 
            component.set("v.userObject.Org_Code__c",null); 
            //component.set("v.userRec.Org_Code__c" , null);
            //alert(component.get("v.userRec.Org_Code__c") );
        }
    },
    
     validateEmail:  function (component, event, helper) {
        helper.compareEMailFields(component, event, helper);
        //var currentEl = event.getSource().get("v.value");
        //var isValidEmail = true; 
        var emailField = component.find("email");
        var emailFieldValue = emailField.get("v.value");
        if(emailFieldValue!=null){
       		var atpos = emailFieldValue.indexOf("@");
            var dotpos = emailFieldValue.lastIndexOf(".");
            if (atpos<1 || dotpos<atpos+2 || dotpos+2>=emailFieldValue.length) {
                console.log('email error');
                $A.util.addClass(emailField, 'slds-has-error');
             	emailField.set("v.errors", [{message: "Please Enter a Valid Email Address"}]);
                //isValidEmail = false; 
            }else{
                console.log('email no error');
                emailField.set("v.errors", [{message: null}]);
              	$A.util.removeClass(emailField, 'slds-has-error');
                //isValidEmail = true; 
                helper.compareEMailFields(component, event, helper);
            }
        }
    },
    validateConEmail:  function (component, event, helper) {
        
        var CemailField = component.find("Cemail");
        var CemailFieldValue = CemailField.get("v.value");
        if(CemailFieldValue!=null){
       		var atpos1 = CemailFieldValue.indexOf("@");
            var dotpos1 = CemailFieldValue.lastIndexOf(".");
            if (atpos1<1 || dotpos1<atpos1+2 || dotpos1+2>=CemailFieldValue.length) {
                console.log('Cemail serror');
                $A.util.addClass(CemailField, 'slds-has-error');
             	CemailField.set("v.errors", [{message: "Please Enter a Valid Confirm Email Address"}]);
                //isValidEmail = false; 
            }else{
                console.log('Cemail no error');
                CemailField.set("v.errors", [{message: null}]);
              $A.util.removeClass(CemailField, 'slds-has-error');
                //isValidEmail = true; 
                helper.compareEMailFields(component, event, helper);
            }
        }
    }
    
    // showSpinner: function(component, event, helper) {
    //     component.set("v.Spinner", true);
    //  },
    //  hideSpinner : function(component,event,helper){
    //   component.set("v.Spinner", false);
    //  }
})