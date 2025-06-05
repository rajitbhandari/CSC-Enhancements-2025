/**
*————————————————————————————————————————————————————
* @Name            DisplayFormsThroughFieldSetController
* @Author          from Vploavarapu
*
*————————————————————————————————————————————————————
* @Description
* This class helps to create a wrapper which will generate dynamic forms (Used in DisplaySetForms
*————————————————————————————————————————————————————
* @Changes
*
**/

public with sharing class DisplayFormsThroughFieldSetController {
    // can help to create attachments and return the name&id of the newly created attachments
    @AuraEnabled
    public static List<AttachmentsDetails> getAttachments(ID parentId,Id recordId) {
        try{
            delete[select id from ContentDocument where id=:recordId];
            List<ContentDocumentLink> conDocLink =  [SELECT ContentDocumentId,ContentDocument.title FROM ContentDocumentLink WHERE LinkedEntityId =:parentId];
            List<AttachmentsDetails> attDetailsList = new List<AttachmentsDetails>();
            for(ContentDocumentLink conDOc : conDocLink){
                AttachmentsDetails attDetails = new AttachmentsDetails();
                attDetails.name = conDOc.ContentDocument.title;
                attDetails.documentId = conDOc.ContentDocumentId;
                attDetailsList.add(attDetails);
            }
            return attDetailsList;
        }catch(exception ex){
            Application_Error_Logs__c errorLog = new Application_Error_Logs__c(Apex_Class_Name__c='DisplayFormsThroughFieldSetController',Exception_Received__c=string.valueof(ex));
            insert errorLog;
            return null;
        }
    }
    public class AttachmentsDetails {
        @auraenabled public string name;
        @auraenabled public string documentId;        
    }
    public class DisplayFieldInfo {
        @AuraEnabled
        public string  fieldlLabel; // To be displayed as field label
        @AuraEnabled
        public string  fieldApiName; // Fields Api Name 
        @AuraEnabled
        public string  fieldType; // Field type
        @AuraEnabled
        public string  question;
        @AuraEnabled
        public boolean isRequired ;
        @AuraEnabled
        public  string Value;
        @AuraEnabled
        public  object noOfPages;
        @AuraEnabled
        public boolean hasPicklistValues;
        @AuraEnabled
        public list<string> picklistValues = new list<string>()  ;
        
        public DisplayFieldInfo(Schema.FieldSetMember f,Schema.DescribeSObjectResult r)
        {
            this.fieldlLabel = f.getLabel();
            this.fieldApiName = f.getFieldPath();
            this.fieldType = string.valueof(f.getType());
            if(this.fieldType=='PICKLIST' || this.fieldType=='MULTIPICKLIST')
            {
                this.picklistValues = CDC_ApexUtilities.getPickValues('Case',this.fieldApiName,null);
                this.hasPicklistValues = true;
            }
            Schema.DescribeFieldResult fdescribe = r.fields.getMap().get(this.fieldApiName.trim()).getDescribe();
            this.question = fdescribe.getInlineHelpText();
            if(this.question==null || this.question=='' )
            {
                this.question= this.fieldlLabel;
            }
            this.isRequired  = f.getRequired();
        } 
    }
    // this method will be called from front end. based on the field set passed we will return the questions to display.
    @auraenabled
    public static string getfieldinfo(string fieldsetName)
    {
        list<DisplayFieldInfo> lstDF = new list<DisplayFieldInfo>();
        Schema.SObjectType t = Schema.getGlobalDescribe().get('Case');
        Schema.DescribeSObjectResult r = t.getDescribe();
        
        Schema.FieldSet fs = Schema.SObjectType.Case.fieldSets.getMap().get(fieldsetName);
        for(Schema.FieldSetMember fsm : fs.getFields() ) 
        {
            lstDF.add(new DisplayFieldInfo(fsm,r));
        }
        
        return json.serialize(lstDF);
    }
    private  static final  id ArticleUploadRT= Schema.SObjectType.case.getRecordTypeInfosByName().get('Article Upload').getRecordTypeId();
    private  static final  id SuccessStories= Schema.SObjectType.case.getRecordTypeInfosByName().get('Success Stories').getRecordTypeId();
    private  static final  id queueID= [select Id from Group where developerName = 'Tier1' and Type = 'Queue' limit 1].id;

    // this method will be called from front end to let users save the form answers

    @auraenabled
    public static Status saveResults(string DisplayFieldInfoJson, string recordId, string FieldSetName, boolean IsfinalUpdate)
    {
        List<DisplayFieldInfo > DisplayFieldInfoToSaveDe = (List<DisplayFieldInfo >)System.JSON.deserialize(DisplayFieldInfoJson, List<DisplayFieldInfo>.class);
        Status stat = new  Status();
        try{
            Type t = Type.forName('Case'); //displayIn.objectfieldApiName
            Sobject  myObj =  (Sobject)t.newInstance();
            
            if(recordId!='')
            {
                myObj.put('id',id.valueof(recordId));
                if(FieldSetName=='Submit_Feedback_Success')
                {
                    myObj.put('Status','Submitted');
                }
                
            }
            
            if(IsfinalUpdate){
                myObj.put('Case_In_Draft_Mode__c',false);
                myObj.put('ownerid',queueID);
            }else{
                myObj.put('Case_In_Draft_Mode__c',true);
                myObj.put('ownerid',UserInfo.getUserId());
            }
            
            if(recordId=='' || recordId==null)
            {
                user[] u = [select Id,ContactId,name,isactive from User where isactive = true and ContactId!=null and id =:UserInfo.getUserId()];
                if(!u.isempty())
                {
                    myObj.put('Legacy_Contact__c',u[0].ContactId);
                    myObj.put('contactid',null);
                }
                
                if(FieldSetName=='Submit_Knowledge_Articles'&& recordId=='' )
                {
                    myObj.put('RecordTypeId',ArticleUploadRT);
                    myObj.put('Type','Resource Upload Request');
                }
                
                if(FieldSetName=='Submit_Feedback_Success'&& recordId=='')
                {
                    myObj.put('RecordTypeId',SuccessStories);
                    myObj.put('Type','Success Story');
                }
                myObj.put('Origin','Portal');
                
            }
            
            stat.recordID =   recordId;
            for(DisplayFieldInfo field : DisplayFieldInfoToSaveDe){
                
                if(field.fieldtype=='Date'){
                    String dayOrDate = field.Value;
                    if(dayOrDate!=null && dayOrDate!=''){
                        List<String> dateParts = dayOrDate.split('-');
                        Date dateV = Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
                        myObj.put(field.fieldApiName,dateV);
                    }else {
                        date d = null;
                        myObj.put(field.fieldApiName,d); 
                    } 
                }
                
                else if(field.fieldtype=='DATETIME') {
                    String dayOrDate = field.Value;
                    if(dayOrDate!=null && dayOrDate!=''){
                        system.debug(dayOrDate);
                        List<String> dateParts = dayOrDate.split('-');
                        Date myDate = Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2].substringBefore('T')));
                        List<String> timeParts= dayOrDate.substringafter('T').split(':');
                        Time myTime = Time.newInstance(Integer.valueOf(timeParts[0]), Integer.valueOf(timeParts[1]), 0, 0);
                        Datetime datewithTime = DateTime.newInstanceGMT(myDate, myTime);
                        myObj.put(field.fieldApiName,datewithTime);   
                        
                    }else{
                        date d = null;
                        myObj.put(field.fieldApiName,d); 
                    } 
                    
                }
                
                else if(field.fieldtype=='BOOLEAN') {
                    if(field.Value=='true'){
                        myObj.put(field.fieldApiName,true);
                    }else{
                        myObj.put(field.fieldApiName,false);
                    }
                }
                
                else if(field.fieldtype=='PICKLIST' || field.fieldtype=='MULTIPICKLIST'){
                    Map<string,string> picklistVal = new Map<string,string>();
                    picklistVal = CDC_ApexUtilities.getPickValuesMap('case',field.fieldApiName,null);
                    system.debug('PICKLIST-->'+field.Value+'---'+picklistVal.get(field.Value)+'--'+picklistVal);
                    
                    if(field.Value=='None' || field.Value==null ||field.Value=='null' || field.Value==''){
                        system.debug('-->'+field.Value);
                        myObj.put(field.fieldApiName,'');
                    }else{
                        if(field.fieldType=='MULTIPICKLIST'){
                            list<string> multiList = field.Value.split(';');
                            //system.debug('multiList-->'+multiList+'--'+field.fieldfieldApiName);
                            string multiselectValue = '';
                            for(string str: multiList){
                                multiselectValue = multiselectValue + picklistVal.get(str)+';';
                            }
                            system.debug('multiselectValue-->'+multiselectValue);
                            myObj.put(field.fieldApiName,multiselectValue);
                        }else{
                            myObj.put(field.fieldApiName,picklistVal.get(field.Value));
                        }
                    }                    
                }
                
                else if(field.fieldtype=='DOUBLE' || field.fieldtype=='CURRENCY')
                {
                    if (String.isNotBlank(field.Value)) {
                        myObj.put(field.fieldApiName,Decimal.valueOf(field.Value));
                    }
                    else {
                        myObj.put(field.fieldApiName,field.Value);
                    }    
                }
                
                else if (field.fieldtype=='PERCENT') {
                    myObj.put(field.fieldApiName, String.isNotBlank(field.Value) ? Decimal.valueOf(field.Value) : null);
                }
                
                else {
                    myObj.put(field.fieldApiName,field.Value);
                }
                
                if(field.Value!=null && field.Value!='')
                {
                    if(field.fieldApiName=='SuccessStoryTitle__c' || field.fieldApiName=='Resource_Name__c' )
                    {
                        myObj.put('subject',field.Value);
                    }
                }
            } 
            try{
                system.debug('obj to upsert~~'+myObj);
                upsert myObj;
                
                stat.isSuccess = true;
                stat.status = 'Success';
                stat.recordinfo = myObj;
                stat.recordID = string.valueof(myObj.get('id'));
                system.debug('STATUS~~'+stat);
                return stat;
            }catch(exception ex){
                Application_Error_Logs__c errorLog = new Application_Error_Logs__c(Apex_Class_Name__c='DisplayFormsThroughFieldSetController',Exception_Received__c=string.valueof(ex));
                insert errorLog;
                stat.isSuccess = false;
                stat.status = 'Exception Occured: ' + ex.getMessage();
                return stat;
            } 
        }catch(exception ex){
            Application_Error_Logs__c errorLog = new Application_Error_Logs__c(Apex_Class_Name__c='DisplayFormsThroughFieldSetController',Exception_Received__c=string.valueof(ex));
            insert errorLog;
            stat.isSuccess = false;
            stat.status = 'Exception Occured: ' + ex.getMessage();
            return stat;
        }
    }
    public static list<EmailMessage> emailst = new list<EmailMessage>();

    // this function is invoked from front end to retrieve the email messages to show on a custom list
    @AuraEnabled
    public static List<EmailMessage> getEmails(Id parentId) {
        List<EmailMessage> toReturn = new  List<EmailMessage>();
        
        case c = [select id,contactemail from case where id =:parentId limit 1];
        List<EmailMessage> EmailList = 
            [SELECT Id, ToAddress,CcAddress,FromAddress,MessageDate, Subject,SubjectURL__c,TextBody FROM EmailMessage where ParentId=:parentId];//
        //string contactEmail = [select ContactEmail from case where id=:parentId limit 1].ContactEmail ;        
        for(EmailMessage e: EmailList )
        {
            if(c!=null && c.contactemail!=null)
            {
                set<string> setemails = new set<string>();
                system.debug('setemails1'+setemails);
                if(e.ToAddress!=null)
                {
                    setemails.addall(e.ToAddress.split(';'));
                }
                
                if(e.CcAddress!=null)
                {
                    setemails.addall(e.CcAddress.split(';'));
                }
                
                if(e.FromAddress!=null)
                {
                    setemails.addall(e.FromAddress.split(';'));
                }
                system.debug('setemails2'+setemails);
                if(setemails.contains(c.contactemail))
                {
                    system.debug('setemails3'+setemails);  system.debug('c.contactemail'+c.contactemail);  
                    toReturn.add(e);
                }    
                
            }
        }
        system.debug(toReturn+'<<size sis >>'+toReturn.size());
        return toReturn;
    }
    
    public class Status {
        @auraenabled public boolean isSuccess;
        @auraenabled public sobject recordinfo ;
        @auraenabled public string status;
        @auraenabled public string recordID ;
        
    }
    
}