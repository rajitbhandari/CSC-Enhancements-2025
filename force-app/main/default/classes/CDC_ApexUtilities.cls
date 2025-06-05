/**
*————————————————————————————————————————————————————
* @Name            CDC_ApexUtilities
* @Author          from Vploavarapu
*
*————————————————————————————————————————————————————
* @Description
* A utility class which has reusable functions within the project
*————————————————————————————————————————————————————
* @Changes
*
**/
global class CDC_ApexUtilities {

    webservice static String validateCaseRecords (list<id> conId){
        List<Contact> contactList = new List<Contact>();
        contactList = [select recordtype.Name,Account.Is_this_Organization_CDC_Recognized__c,account.name from Contact where Id In :conId];
        for(Contact conRec : contactList){
            if(conRec.recordtype.Name!='SME'){
                return 'No SMEs have been identified to receive a survey. To send a survey, edit the SME\'s role to "SME- Survey Required", and try again';
            }
            if(conRec.account.name!='CDC'){
                return 'All the contacts selected should be Internal SME';
            }
        }
        return 'No Error';
    }
    
	@AuraEnabled
    webservice static void SendEmailNotification (list<id> conId){
        EmailTemplate et = [select id from EmailTemplate where DeveloperName='DDT_Staff_Members_Quarterly' limit 1];
        list<Messaging.MassEmailMessage> mails = new list<Messaging.MassEmailMessage>();
        for(id con: conId)
        {
            Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
            mail.setTargetObjectIds(conId);
            mail.setSenderDisplayName('NationalDPPAsk');
            mail.setTemplateId(et.id);
            //mail.setwhatIds(con);
            mails.add(mail);
        }
        Messaging.sendEmail(mails);
    }
    
	@AuraEnabled
    webservice static string SendSurveyEmail (id caseID ){
        string response;
        map<id, list<CaseContactRole>> contactIDsToSendEMail = new map<id, list<CaseContactRole>>();
        list<CaseContactRole> caseCRList = new list<CaseContactRole>();
        if (caseID!=null) {
            caseCRList = [select id,ContactId,CasesId,Contact.Email,Cases.CaseNumber from CaseContactRole  where CasesId =:caseID and Contact.Email != '' and Role = 'SME- Survey Required'];
            OrgWideEmailAddress owd = new OrgWideEmailAddress();

            if(!Test.isRunningTest()){
                owd = [select Id,Address, DisplayName from OrgWideEmailAddress where DisplayName = 'NationalDPPAsk' limit 1];
                if(owd==null){
                    return 'Please Notify your administratior that their is no OrgWide Address with DIsplayName as NationalDPPAsk';
                }
            }
            if (caseCRList.size()>0) {
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                List<CaseContactRole> updateRoles = new  List<CaseContactRole>();
                for (CaseContactRole f : caseCRList) {
                    system.debug('case contact role' + f);
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    List<String> sendTo = new List<String>();
                    sendTo.add(f.Contact.Email);
                    mail.setToAddresses(sendTo);

                    if (owd != null) {
                        mail.setOrgWideEmailAddressId(owd.id);
                    } else {
                        system.debug('org wide adddress is not listed as NCCDP');
                        mail.setSenderDisplayName('NCCDP');
                    }

                    mail.setSubject('Resolution Documentation – Case#' + f.Cases.CaseNumber);
                    string envURL = System.Label.Case_Closed_SME_Survey_Constants;
                    system.debug(envURL);
                    String body = '<p>You are receiving this email as a follow-up to the resolution of Case#' + f.Cases.CaseNumber + '. Please click&nbsp;<a href="';
                    body += envURL;
                    body += '&amp;cId=';
                    body += f.ContactId;
                    body += '&amp;caId=';
                    body += caseID;
                    body += '" target="_blank">here&nbsp;</a>to provide brief documentation of the resolution process.</p> <p>We appreciate your involvement in addressing this user&rsquo;s inquiry.</p><p>Sincerely,<br />The National DPP Customer Service Center Team</p>';
                    system.debug('mails to send to' + sendTo);
                    mail.setHtmlBody(body);
                    mails.add(mail);
                    f.Role = 'Success! Survey has been sent to selected SMEs.';
                    updateRoles.add(f);
                }
                Messaging.sendEmail(mails);
                if(updateRoles.size()>0){
                    update updateRoles;
                    response = 'Survey has been sent';
                }
            }else{
                response = 'No Contacts Roles were Identified with role as SME- Survey Required';
            }

        }else{
            response = 'No Case Identified, Contact Administrator';
        }
        return      response;
    }

    // use this utility for only Picklist labels. Ideal if picklist api and label are same.
    public static List<string> getPickValues(string object_name, String field_name, String first_val) {
        try{
            List<string> options = new List<string>(); //new list for holding all of the picklist options
            if (first_val != null) { //if there is a first value being provided
                options.add(first_val); //add the first option
            }
            Schema.sObjectType sobject_type = Schema.getGlobalDescribe().get(object_name );//object_name.getSObjectType(); //grab the sobject that was passed
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
            List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
            for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list

                options.add(a.getlabel()); //add the value and label to our final list
            }

            return options; //return the List
        }catch(exception ex){
            Application_Error_Logs__c errorLog = new Application_Error_Logs__c(Apex_Class_Name__c='CDC_ApexUtilities',Exception_Received__c=string.valueof(ex));
            insert errorLog;
            return null;
        }
    }

    // use this utility to get a map of label,apiname. 
    public static Map<string,string> getPickValuesMap(string object_name, String field_name, String first_val) {
        try{
            Map<string,string> options = new Map<string,string>(); //new list for holding all of the picklist options
            if (first_val != null) { //if there is a first value being provided
                options.put(first_val, first_val); //add the first option
            }
            Schema.sObjectType sobject_type = Schema.getGlobalDescribe().get(object_name );//object_name.getSObjectType(); //grab the sobject that was passed
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
            List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
            for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list

                options.put(a.getLabel(), a.getValue()); //add the value and label to our final list
            }

            return options; //return the List
        }catch(exception ex){
            Application_Error_Logs__c errorLog = new Application_Error_Logs__c(Apex_Class_Name__c='CDC_ApexUtilities',Exception_Received__c=string.valueof(ex));
            insert errorLog;
            return null;
        }
    }

    public static Boolean isAccessible(String sObjectType, String fieldName){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
        DescribeFieldResult fieldDescribe = fields.get(fieldName).getDescribe();
        return fieldDescribe.isAccessible();
    }

    public static Boolean isAccessible(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isAccessible();
    }

    public static Boolean isCreateable(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isCreateable();
    }

    public static Boolean isDeletable(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isDeletable();
    }

}