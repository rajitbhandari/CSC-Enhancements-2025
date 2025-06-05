/**
*————————————————————————————————————————————————————
* @Name            CaseModel
* @Author          from Vploavarapu
*
*————————————————————————————————————————————————————
* @Description
* Controller to Handle trigger transactions. This class can -
* 1. send email to sme when a case closes (deprecated/not in use)
* 2. Helps to create a contact when a case comes into salesforce from E2C feauture
* 3.Helps to spilt the first and last name of the contactName.
*————————————————————————————————————————————————————
* @Changes
*
**/
public class CaseModel
{
    private Map<Id, case> oldRecords;
    private list<case> newRecords;
    private static boolean run = true;
    public static boolean runOnce() {
        if (run) {
            run = false;
            return true;
        } else {
            return run;
        }
    }

    /*******************************************************************************************************
   * @description Init function to map variables and begin processing.
   * @param oldRecords Map of trigger.oldmap values.
   * @param newRecords List of new records in trigger.new context.
   * @return None.
   */
    public static void processCases(Map<Id, sobject> oldRecords, list<sobject> newRecords) {
        // system.debug('new'+newRecords);
        CaseModel engine = new CaseModel((Map<Id, case>) oldRecords, (list<case>) newRecords);
        if (trigger.isInsert) {
            engine.processNewContactAndModifyCaseRecs() ; // used for email2Cases contact creation
        }
        if (trigger.isUpdate) {
            engine.changeRTofCasesOnIsclosedChange() ; // if a case is reopened need to rollback the Recordtype.
        }
    }

    /*******************************************************************************************************
   * @description Init function to map variables and send SME Survey emails.
   * @param oldRecords Map of trigger.oldmap values.
   * @param newRecords List of new records in trigger.new context.
   */
    public static void sendEmailToSME(Map<Id, sobject> oldRecords, list<sobject> newRecords) {
        CaseModel engine = new CaseModel((Map<Id, case>) oldRecords, (list<case>) newRecords);
       // engine.sendSMESurveyEmails() ;
    }
    /*******************************************************************************************************
   * @description parameter constructor used to assign oldRecords,newRecords.
   */
    private CaseModel(Map<Id, case> oldRecords, list<case> newRecords) {

        this.oldRecords = oldRecords == null ? new Map<Id, case>() : oldRecords;
        this.newRecords = newRecords;
    }

    /*******************************************************************************************************
   * @description Used to change the recordtype of case when case reopens.
   */

    private void changeRTofCasesOnIsclosedChange() {

        set<string> caseClosedStatuses = new set<string>();
        // identify the Case statuses which are tied to Closed status.
        for (caseStatus cs : [Select Id, MasterLabel From CaseStatus Where IsClosed = true]) {
            caseClosedStatuses.add(cs.MasterLabel);
        }
        for (case aCase : newRecords) {
            system.debug(aCase.isClosed + '   old value' + oldRecords.get(aCase.id).isClosed);
            if (!caseClosedStatuses.contains(aCase.status) && oldRecords.get(aCase.id).isClosed) {
                if (aCase.origin == 'Email') {
                    aCase.recordTypeid = CaseEmailRT;
                } else {
                    aCase.recordTypeid = CaseTASupportRT;
                }
            }
        }
    }

    /** @description Get 'Community Contacts' recordtypeID, we may need to refactor after Summer'18 release */
    private Id CommunityContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Community Contacts').getRecordTypeId();

    /** @description Get 'Email Cases' recordtypeID,we may need to refactor after Summer'18 release */
    private Id CaseEmailRT = Schema.SObjectType.case.getRecordTypeInfosByName().get('Email Cases').getRecordTypeId();

    /** @description Get 'Community Contacts' recordtypeID ,we may need to refactor after Summer'18 release */
    private Id CaseTASupportRT = Schema.SObjectType.case.getRecordTypeInfosByName().get('TA & User Support').getRecordTypeId();

    /*******************************************************************************************************
   * @description below method will help to send out emails to SME.
   *  Based on requirements
   */
    private void sendSMESurveyEmails() {
        set<id> checkForcontactRoles = new set<id>();
        for (Case caseObj : newRecords) {
            if (trigger.isupdate && caseObj.IsClosed && oldRecords != null && oldRecords.get(caseObj.id) != null && oldRecords.get(caseObj.id).IsClosed != caseObj.IsClosed) {
                checkForcontactRoles.add(caseObj.id);
            }
        }
        map<id, list<CaseContactRole>> contactIDsToSendEMail = new map<id, list<CaseContactRole>>();
        if (!checkForcontactRoles .isempty()) {
            list<CaseContactRole> lstCRs = [select id,ContactId,CasesId,Contact.Email,Cases.CaseNumber from CaseContactRole where /*Role='SME- Needs Survey' and */ CasesId = :checkForcontactRoles and Contact.Email != '' and Contact.Account.name != 'cdc'];
            for (CaseContactRole c : lstCRs) {
                system.debug(c);
                list<CaseContactRole> caseIDs = contactIDsToSendEMail.get(c.CasesId);
                if (caseIDs == null) {
                    contactIDsToSendEMail.put(c.CasesId, caseIDs = new list<CaseContactRole>());
                }
                caseIDs.add(c);
                system.debug(contactIDsToSendEMail);
            }
        }
        system.debug(contactIDsToSendEMail);
        OrgWideEmailAddress owd = new OrgWideEmailAddress();
        if(!Test.isRunningTest()){
            owd = [select Id,Address, DisplayName from OrgWideEmailAddress where DisplayName = 'NationalDPPAsk' limit 1];
        }
        if (!contactIDsToSendEMail.isempty()) {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            system.debug(contactIDsToSendEMail.keyset());
            for (id cs : contactIDsToSendEMail.keyset()) {
                system.debug(cs);
                for (CaseContactRole f : contactIDsToSendEMail.get(cs)) {
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
                    body += cs;
                    body += '" target="_blank">here&nbsp;</a>to provide brief documentation of the resolution process.</p> <p>We appreciate your involvement in addressing this user&rsquo;s inquiry.</p><p>Sincerely,<br />The National DPP Customer Service Center Team</p>';
                    system.debug('mails to send to' + sendTo);
                    mail.setHtmlBody(body);
                    mails.add(mail);
                }

            }
            system.debug(mails);
          //  Messaging.sendEmail(mails);
        }
    }
    // below method will help to- create a new contact if a contact does not exist already
    private void processNewContactAndModifyCaseRecs() {
        List<String> emailAddresses = new List<String>();
       // List<Account> unRecognizedAccount = [SELECT Id,Name FROM Account WHERE Name=:Label.Non_Recognized_Contacts LIMIT 1];
       // Account unRecognizedAccountID = (unRecognizedAccount.size() == 1) ? unRecognizedAccount.get(0) : null;
        List<User> E2cOwnerUsers = [SELECT Id FROM User where Alias=:Label.User_Name_to_Associate_Contact_OwnerID_E2C_Cases LIMIT 1];
        User E2cUserUsr = (E2cOwnerUsers.size() == 1) ? E2cOwnerUsers.get(0) : null;
        //First exclude any cases where the contact is set
        for (Case caseObj : newRecords) {
            if (trigger.isinsert && caseObj.origin == 'Email') {
                caseObj.description = null;
                if (caseObj.ContactId == null &&
                        caseObj.SuppliedEmail != '') {
                    emailAddresses.add(caseObj.SuppliedEmail);
                }
            }
        }
        //Now we have a nice list of all the email addresses.  Let's query on it and see how many contacts already exist.
        List<Contact> listContacts = [Select Id,Email From Contact Where Email in :emailAddresses];
        Set<String> takenEmails = new Set<String>();
        for (Contact c : listContacts) {
            takenEmails.add(c.Email);
        }
        Map<String, Contact> emailToContactMap = new Map<String, Contact>();
        List<Case> casesToUpdate = new List<Case>();
        for (Case caseObj : newRecords) {
            if (caseObj.ContactId == null &&
                    caseObj.SuppliedName != null &&
                    caseObj.SuppliedEmail != null &&
                    caseObj.SuppliedName != '' &&
                    !caseObj.SuppliedName.contains('@') &&
                    caseObj.SuppliedEmail != '' && CommunityContactRT != null &&
                    !takenEmails.contains(caseObj.SuppliedEmail)) {
                //The case was created with a null contact
                //Let's make a contact for it
                system.debug('Supplied Name-->'+caseObj.SuppliedName);
                if (caseObj.SuppliedName.contains(' ')) {
                    String[] nameParts = caseObj.SuppliedName.split(' ', 2);
                    if (nameParts != null && nameParts.size() == 2) {
                        Contact cont = new Contact(LastName  = nameParts[1].replaceAll('[,]', '').capitalize(),
                                FirstName = nameParts[0].replaceAll('[,]', '').capitalize(),
                                Email = caseObj.SuppliedEmail, recordtypeid = CommunityContactRT

                        );
                        if(E2cUserUsr!=null)
                        {
                            cont.OwnerId =E2cUserUsr.id;
                        }
                       /* if(unRecognizedAccountID!=null)
                        {
                          //  cont.AccountId=unRecognizedAccountID.id;
                        }*/
                        emailToContactMap.put(caseObj.SuppliedEmail, cont);
                        casesToUpdate.add(caseObj);
                    }
                } else {
                    Contact cont = new Contact( FirstName  = caseObj.SuppliedName.capitalize(),
                            LastName  = 'LNU',
                            Email = caseObj.SuppliedEmail, recordtypeid = CommunityContactRT
                    );
                    if(E2cUserUsr!=null)
                    {
                        cont.OwnerId =E2cUserUsr.id;
                    }
                    /*if(unRecognizedAccountID!=null)
                    {
                       // cont.AccountId=unRecognizedAccountID.id;
                    }*/
                    emailToContactMap.put(caseObj.SuppliedEmail, cont);
                    casesToUpdate.add(caseObj);
                }
            }
        }
        if (!emailToContactMap.values().isempty()) {
            insert emailToContactMap.values();
            for (Case caseObj : casesToUpdate) {
                if (emailToContactMap != null && emailToContactMap.get(caseObj.SuppliedEmail) != null) {
                    Contact newContact = emailToContactMap.get(caseObj.SuppliedEmail);
                    caseObj.ContactId = newContact.Id;
                    //caseObj.AccountId = null;
                }
            }
        }
    }
}