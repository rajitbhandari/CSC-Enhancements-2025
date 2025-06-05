({
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    
    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },

    executeAction: function(component,userRec,otherOrgType,password,confirmPassword,accountId,regConfirmUrl,includePassword) {
        return new Promise($A.getCallback(function(resolve, reject) {
            
            var selfRegisteraction = component.get("c.selfRegister");
            var extraFields = JSON.stringify(component.get("v.extraFields"));   // somehow apex controllers refuse to deal with list of maps
            var startUrl = component.get("v.startUrl");
            var responseval= component.get("v.response"); 
            startUrl = decodeURIComponent(startUrl);
        
            selfRegisteraction.setParams({
            userDetails:userRec,
            otherOrgType:otherOrgType,
            password:password, 
            confirmPassword:confirmPassword, 
            accountId:accountId, 
            regConfirmUrl:regConfirmUrl, 
            extraFields:extraFields, 
            startUrl:startUrl, 
            includePassword:includePassword, 
            recaptchaResponse:responseval});

            selfRegisteraction.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var rtnValue=response.getReturnValue();
                    if (rtnValue != null && rtnValue !="./CheckPasswordResetEmail") {
                        component.set("v.errorMessage",rtnValue);
                        component.set("v.Spinner", false);
                        component.set("v.showError",true);
                    }
                    else{
                        console.log('success',component.get("v.termsAndConditions"));
                        component.set("v.Spinner", false);
                        if(component.get("v.termsAndConditions")){
                            
                            alert("Thank you for signing up to receive communications from the National DPP Mailbox! You will now be redirected to the CDC News and Updates page to complete the email sign-up process. When prompted, please type your full email address on the CDC News and Updates page to be added to the mailing list.");
                            const a = document.createElement('a');
                            a.href = "https://tools.cdc.gov/campaignproxyservice/subscriptions.aspx?topic_id=USCDC_2110";
                            a.target = "_blank";
                            document.body.appendChild(a);
                            console.log('a <<', a);
                            a.click();
                            
                            window.open("/s/login/CheckPasswordResetEmail","_self");
                            
                            //document.body.removeChild(a);
                            //window.open("https://tools.cdc.gov/campaignproxyservice/subscriptions.aspx?topic_id=USCDC_2110","_blank");
                            console.log('SuccessPageReload');
                        }
                        else{
                            //window.open("/s","_self");
                            window.open("/s/login/CheckPasswordResetEmail","_self");
                            console.log('SuccessReset');
                        }
                    }
                    resolve(retVal);
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            reject(Error("Error message: " + errors[0].message));
                        }
                    }
                    else {
                        reject(Error("Unknown error"));
                    }
                }
            });
        $A.enqueueAction(selfRegisteraction);
        }));
    },
        
    handleSelfRegister: function (component, event, helpler) {
        var userRec = component.get("v.userObject");
        var accountId = component.get("v.accountId");
        var regConfirmUrl = component.get("v.regConfirmUrl");
        var accountid = component.get("v.accountId");  
        var errorMessage='';
       
        if (userRec.FirstName == '') {
            errorMessage = errorMessage + 'First name is required.';
        }
        if (userRec.LastName == '') {
            errorMessage = errorMessage + '<br/>Last name is required.';
        }
        if (userRec.Email == '') {
            errorMessage = errorMessage + '<br/>Email is required.';
        }else{
            var atpos = userRec.Email.indexOf("@");
            var dotpos = userRec.Email.lastIndexOf(".");
            if (atpos<1 || dotpos<atpos+2 || dotpos+2>=userRec.Email.length) {
                errorMessage = errorMessage + '<br/>Invalid Email id.';
            }
        }
        var confirmEmail = component.get("v.confirmEmail");
        if(userRec.Email!=confirmEmail){
            errorMessage = errorMessage + '<br/>Email Address does not match.';
        } 
        if (userRec.CompanyName == null) {
           
            errorMessage = errorMessage + '<br/>Organization Name is required.';
        }

        if (userRec.User_Referred_to_CSC_by__c == 'Other' && userRec.User_Referred_to_CSC_Specified__c == null){
            errorMessage = errorMessage + '<br/>Please Specify how you learned about the CSC is required.';
        }else{
            component.set("v.errorMessage", '');
            component.set("v.showError",false);
        }

        if(accountid==null)
        {
            var userProfileId = userRec.CDC_User_Profile_Type__c;
         
            if (userRec.CDC_Recognized__c==true){
               if(userRec.Org_Code__c == '') {
                   errorMessage = errorMessage + '<br/>Org Code is required.';
                }
            }else{
                component.set("v.errorMessage", '');
                component.set("v.showError",false);
            }
            
            if (userRec.CDC_User_Profile_Type__c=='Other'){
               if(component.get("v.otherOrgType") == '') {
                   errorMessage = errorMessage + '<br/>Other organization type is required.';
                }
            }else{
                component.set("v.errorMessage", '');
                component.set("v.showError",false);
            }
            
            
            if (userRec.Zip_Code__c == '') {
                errorMessage = errorMessage + '<br/>Zip Code is required.';
            }
        }
        
        var includePassword = component.get("v.includePasswordField");
        var password = component.find("password").get("v.value");
        if (includePassword && (password == undefined || password == null || password == '')) {
            errorMessage = errorMessage + '<br/>Password is required.';
        }else{
            if (includePassword && password.length<8) {
                errorMessage = errorMessage + '<br/>Your password must be at least 8 characters long.';
            }
        }
        var confirmPassword = component.find("confirmPassword").get("v.value");
        if (includePassword && (confirmPassword == undefined || confirmPassword == null || confirmPassword == '')) {
            errorMessage = errorMessage + '<br/>Confirm Password is required.';
        }
        if(password!=confirmPassword){
            errorMessage = errorMessage + '<br/>Passwords did not match.';
            
        }
        if(errorMessage!=''){
        component.set("v.errorMessage", errorMessage);
        component.set("v.Spinner", false);
        component.set("v.showError",true);
             return;
        }
        this.executeAction(component,userRec,component.get("v.otherOrgType"),password,confirmPassword,accountId,regConfirmUrl,includePassword);
        console.log('here 1');

        
    //$A.enqueueAction(selfRegisteraction);
    },

    cdcRecognizedValues : function (component, event, helpler) {
        var action = component.get("c.cdcRecognizedValues");
        //action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue(); 
            if (rtnValue !== null) {
                component.set('v.CDCRecognizedValues',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getUserProfilePicklistval : function (component, event, helpler) {
        var action = component.get("c.getprofileTypeValues");
        //action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.userprofileValues',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getReferredByPicklistval : function (component, event, helpler) {
        var action = component.get("c.getReferralQuestions");
        //action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.referredByValues',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    

    setBrandingCookie: function (component, event, helpler) {        
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }        
    },

	compareEMailFields : function (component, event, helpler) {       
        var emailField = component.find("email");
        var emailFieldValue = emailField.get("v.value");
        var CemailField = component.find("Cemail");
        var CemailFieldValue = CemailField.get("v.value");
        if(CemailFieldValue!=null && emailFieldValue!=null && CemailFieldValue!=emailFieldValue){
                $A.util.addClass(CemailField, 'slds-has-error');
             	CemailField.set("v.errors", [{message: "Email Address does not match"}]);
                
             }else{
                 CemailField.set("v.errors", [{message: null}]);
              $A.util.removeClass(CemailField, 'slds-has-error');
               
             }
       
    },
    getAccountDetails: function (component, event, helper) {
      //  alert('helper');
        var accountObject = component.get('v.orgCodeObject');
        var action = component.get("c.getAccountRec");
		action.setParams({accRecId:accountObject});

       action.setCallback(this, function(a){
          var rtnValue = a.getReturnValue();
			console.dir(rtnValue);
            //alert(rtnValue);
          if (rtnValue !== null) {
             component.find("userProfileId").set("v.value",rtnValue.Type);
             component.find("ZipCode").set("v.value",rtnValue.ShippingPostalCode);
             
              if(rtnValue.Is_this_Organization_CDC_Recognized__c=='Yes')
              {
                  component.set("v.isCDCRecognized",true);
                  component.find("OrgCode").set("v.value",rtnValue.Org_Code__c);
                  component.find("cdcRecognizedValue").set("v.value","Yes");
              }else{
                  component.set("v.isCDCRecognized",false);
                  component.find("cdcRecognizedValue").set("v.value","No");
              }          
          }

       });

    $A.enqueueAction(action);
    }

})