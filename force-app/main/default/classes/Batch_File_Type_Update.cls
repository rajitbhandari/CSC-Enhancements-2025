global class Batch_File_Type_Update implements Database.Batchable<sObject>{
    global  string query = '';
    global list<string> queries = new list<string>(); // this variable will hold all the queries 
    global list<sobject> scopedResults = new list<sobject>();

    public Batch_File_Type_Update()
    {
        this.queries.add('SELECT id, ArticleType, Attachment__ContentType__s, Attachment__Length__s FROM Covering_as_a_Benefit__kav where PublishStatus = \'draft\' and Attachment_Info__c = NULL');
        this.queries.add('SELECT id, ArticleType, Attachment__ContentType__s, Attachment__Length__s FROM Delivering_the_Lifestyle_Change_Program__kav where PublishStatus = \'draft\' and Attachment_Info__c = NULL');
        this.queries.add('SELECT id, ArticleType, Attachment__ContentType__s, Attachment__Length__s FROM Learning_About_the_National_DPP__kav where PublishStatus = \'draft\' and Attachment_Info__c = NULL');
        this.queries.add('SELECT id, ArticleType, Attachment__ContentType__s, Attachment__Length__s FROM Partnering_for_Success__kav where PublishStatus = \'draft\' and Attachment_Info__c = NULL');
        this.queries.add('SELECT id, ArticleType, Attachment__ContentType__s, Attachment__Length__s FROM Promoting_Awareness_and_Action__kav where PublishStatus = \'draft\' and Attachment_Info__c = NULL');
        this.queries.add('SELECT id, ArticleType, Attachment__ContentType__s, Attachment__Length__s FROM Screening_and_Referral__kav where PublishStatus = \'draft\' and Attachment_Info__c = NULL');
        system.debug('select:'+this.queries);
        for(string s :this.queries )
        {
            system.debug('select1:'+s);
            this.scopedResults.addall(database.query(s));
        }
        system.debug(this.scopedResults);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator('select id from user limit 1'); // returns the object records     */

    }
    
    public static String FileSizeToString(Long Value)
    {
        try{
            /* string representation if a file's size, such as 2 KB, 4.1 MB, etc */
            if (Value < 1024)
                return string.valueOf(Value) + ' Bytes';
            else
                if (Value >= 1024 && Value < (1024*1024))
            {
                //KB
                Decimal kb = Decimal.valueOf(Value);
                kb = kb.divide(1024,2);
                return string.valueOf(kb) + ' KB';
            }
            else
                if (Value >= (1024*1024) && Value < (1024*1024*1024))
            {
                //MB
                Decimal mb = Decimal.valueOf(Value);
                mb = mb.divide((1024*1024),2);
                return string.valueOf(mb) + ' MB';
            }
            else
            {
                //GB
                Decimal gb = Decimal.valueOf(Value);
                gb = gb.divide((1024*1024*1024),2);
                
                return string.valueOf(gb) + ' GB';
            }    
        }catch(exception ex){
            Application_Error_Logs__c errorLog = new Application_Error_Logs__c(Apex_Class_Name__c='Batch_File_Type_Update',Exception_Received__c=string.valueof(ex));
            insert errorLog;
            return null;
        }
    }
    
    global void execute(Database.BatchableContext BC,List<sObject> scope){ 
        try{
            system.debug('execute method reached ' + scopedResults+scope);
            if(!scopedResults.isempty())
            {
                list<sobject> records = new list<sobject>(); // temporary variable to add only the records which we change 
                for(Sobject s : scopedResults){
                    // make the transformations here
                    string  AttachmentLength;
                    AttachmentLength =FileSizeToString(long.valueof(string.valueof(s.get('Attachment__Length__s')))) ;
                    string AttachmentTypeInfo;
                    AttachmentTypeInfo = string.valueof(s.get('Attachment__ContentType__s'));
                    s.put('Attachment_Info__c','Size-'+AttachmentLength+' ; Type- '+ AttachmentTypeInfo.replace('application/', '') );
                    records.add(s); 
                }      
                if(!records.isempty())
                {
                    update records;
                }
                
            }                       
        }catch(exception ex){
            system.debug('ex-->'+ex);
            Application_Error_Logs__c errorLog = new Application_Error_Logs__c(Apex_Class_Name__c='Batch_File_Type_Update',Exception_Received__c=string.valueof(ex));
            insert errorLog;
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}