/**
*————————————————————————————————————————————————————
* @Name            CaseTriggerHelper
* @Author          from Yeswanth CH
*————————————————————————————————————————————————————
* @Description
* This class can -
* 1. Copies the most recent email message from parent case to the child case
*————————————————————————————————————————————————————
* @Changes
*
**/
public class CaseTriggerHelper {
    
   /*******************************************************************************************************
   * @description Creates Email Address record for child case.
   * @param oldRecords Map of trigger.oldmap values.
   * @param newRecords List of new records in trigger.new context.
   * @return None.
   */
    public static void copyRecentEmailAddressFromParentToChild(Map<Id,SObject> oldRecords,
                                                               List<SObject> newRecords){
                                                               
        List<EmailMessage> emailMessagesToInsert = new List<EmailMessage>();                                  
        Map<Id,Id> mapOfParentIdToChildId = new Map<Id,Id>();
        
        List<Case> newCases = (List<Case>)newRecords;
        Map<Id,Case> oldCasesMap = (Map<Id,Case>)oldRecords;
       
        for(Case newCase : newCases) {
            if(newCase.status == 'New' && newCase.ParentId != null && newCase.Origin == 'Email'){
                   if(oldCasesMap == null){//on insert
                       mapOfParentIdToChildId.put(newCase.ParentId,newCase.Id);
                   }  
                   /*else if(oldCasesMap != null 
                           && newCase.status != oldCasesMap.get(newCase.id).status){//on update
                       mapOfParentIdToChildId.put(newCase.ParentId,newCase.Id);  
                   }*/
            }
        }
                                                
        for(Case parentCase : [SELECT Id,
                                (SELECT status,
                                             parentId,//Case Id
                                             fromAddress,
                                             fromName,
                                             subject,
                                             htmlBody,
                                             textBody,
                                             toAddress
                                      FROM EmailMessages
                                      ORDER BY createdDate DESC LIMIT 1)
                            FROM Case
                            WHERE Id IN:mapOfParentIdToChildId.keyset()
                            AND (Status = 'Closed' 
                                OR Status = 'Case Closed through Referral')]) {
            if(parentCase.EmailMessages.size()>0) {
                EmailMessage emailMessage = new EmailMessage();
                emailMessage.status = '3';//sent
                emailMessage.parentId =  mapOfParentIdToChildId.get(parentCase.Id);
                emailMessage.fromAddress = parentCase.EmailMessages[0].fromAddress;
                emailMessage.fromName = parentCase.EmailMessages[0].fromName;
                emailMessage.subject = parentCase.EmailMessages[0].subject;
                emailMessage.htmlBody = parentCase.EmailMessages[0].htmlBody;
                emailMessage.textBody = parentCase.EmailMessages[0].textBody;
                emailMessage.toAddress = parentCase.EmailMessages[0].toAddress;
                emailMessagesToInsert.add(emailMessage);  
            }                            
        }
        if(emailMessagesToInsert.size()>0){
            insert emailMessagesToInsert;
        }                                               
    }
}