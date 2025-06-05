/**
*————————————————————————————————————————————————————
* @Name             Attachment_invocableClass
* @Author           vpolavarapu
*
*————————————————————————————————————————————————————
* @Description
* Controller class to modify modify Atatchment type
*————————————————————————————————————————————————————
* @Changes
*
**/
public class Attachment_invocableClass
{
    @InvocableMethod
    public static void modifyAtatchment(List<Id> ids)
    {
        //callFuture(AttachmentIds);
         String sObjName = ids[0].getSObjectType().getDescribe().getName();
         list<sobject> records = new list<sobject>();
         list<sobject> scopedResults= database.query('SELECT id, ArticleType, Attachment__ContentType__s, Attachment__Length__s FROM '+ sObjName +' where PublishStatus = \'draft\' and Attachment__Name__s != null and id=:ids'); // temporary variable to add only the records which we change 
         for(Sobject s : scopedResults){
                          system.debug(s);
                          string  AttachmentLength;
                          AttachmentLength =Batch_File_Type_Update.FileSizeToString(long.valueof(string.valueof(s.get('Attachment__Length__s')))) ;
                          string AttachmentTypeInfo;
                          AttachmentTypeInfo = string.valueof(s.get('Attachment__ContentType__s'));
                          s.put('Attachment_Info__c','Size-'+AttachmentLength+' ; Type- '+ AttachmentTypeInfo.replace('application/', '') );
                          records.add(s); 
         }
         
         if(!records.isempty())
         {
             system.debug('records-->'+records);
             update records;
         }
    }
}