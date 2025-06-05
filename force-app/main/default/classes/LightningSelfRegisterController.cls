/**
*————————————————————————————————————————————————————
* @Name            LightningSelfRegisterController
* @Author          from Salesforce additional updates based on the org requirement by Vpolavarapu
* @Description    1. helps a site user create a new Contact + Account + User record
*                 2. helps retrieve constants during inIt of page load
*
*————————————————————————————————————————————————————
* @Changes
*
**/
global without sharing class LightningSelfRegisterController {

    @auraenabled
    public static Account getAccountRec(id accRecId) {
        SObjectAccessDecision securityDecision = 
         Security.stripInaccessible(AccessType.READABLE,
            [SELECT ShippingPostalCode,
                      BillingPostalCode,
                      id,
                      type,
                      Org_Code__c,
                      Is_this_Organization_CDC_Recognized__c
            FROM Account
            WHERE id = :accRecId],
              true);
        Account accRec = (Account)securityDecision.getRecords()[0];
        return accRec;
    }
    public LightningSelfRegisterController() {

    }

    @TestVisible
    private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }

    @TestVisible
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl, '');
        return authConfig.isCommunityUsingSiteAsContainer();
    }

    @TestVisible
    private static void validatePassword(User u, String password, String confirmPassword) {
        if (!Test.isRunningTest()) {
            Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }

    @AuraEnabled
    public static String selfRegister(User userDetails, 
                                      String otherOrgType, 
                                      String password, 
                                      String confirmPassword, 
                                      String accountId, 
                                      String regConfirmUrl, 
                                      String extraFields, 
                                      String startUrl, 
                                      Boolean includePassword,
                                      String recaptchaResponse) {

        String recaptchaSecretKey = System.Label.RecaptchaSecretkey; //'6LdPBgkjAAAAAFv-JUhyh4IgqqXeFsj2Rp9O4SuI';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
        request.setMethod('POST');
        request.setBody('secret=' + recaptchaSecretKey + '&response=' + recaptchaResponse);
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200){
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            system.debug('result'+result);
            if ((result.containsKey('success') && result.get('success') == true) ||  Test.isRunningTest()) {       
                if (result.containsKey('score') ||  Test.isRunningTest()) {
                    system.debug('Test2');  
                    //score logic is only needed/returned for v3 (0.0 - 1.0)                    
                    String action = (String)result.get('action');
                    //get threshold configuration for each action
                    
                    Decimal threshold = Decimal.valueOf(System.Label.CSC_Recaptcha_Threshold_Loginpage);
                    Decimal score = (Decimal)result.get('score');
                     if (Test.isRunningTest()){
                     	score = 0.8; 
                    }
                    if (score > threshold){
                        Account tempa = new account();
                        Savepoint sp = null;
                        string debugger = 'Debug Begin, complete User Params' + userDetails + '~~~ Accid~~ received' + accountId; //used for debugging
                        string accountonwerID; // used for assigning the new account owner id
                        list<user> lstuser = [select Id,UserRole.Name from User where UserRoleId != null and UserRole.Name = 'CSC Agent'];
                        if (!lstuser.isempty()) {
                            accountonwerID = lstuser[0].id;
                        }
                        try {
                            sp = Database.setSavepoint();

                            list<contact> conRec = [select id,accountid from contact where Email = :userDetails.Email limit 1];
                            userDetails.LocaleSidKey = 'en_US';
                            userDetails.Username = userDetails.Email;
                            userDetails.TimeZoneSidKey = 'GMT';
                            userDetails.LanguageLocaleKey = 'en_US';
                            userDetails.EmailEncodingKey = 'UTF-8';
                            String nickname = ((userDetails.FirstName != null && userDetails.FirstName.length() > 0) ? userDetails.FirstName.substring(0, 1) : '') + userDetails.LastName.substring(0, 1);
                            nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
                            userDetails.put('CommunityNickname', nickname);
                            userDetails.Alias = nickname;
                            account newacc = new account();
                            if (accountId != null) {
                                account at = [select id,Org_Code__c from account where id = :accountId limit 1];
                                newacc = at;
                            } 
                            else if (userDetails.Org_Code__c != null && userDetails.Org_Code__c != '' && accountId == null) {
                                // check if any account is associated withe org code provided by user
                                list<account> at = [select id,Org_Code__c from account where Org_Code__c = :userDetails.Org_Code__c limit 1];
                                if (!at.isempty()) {
                                    newacc = at[0];
                                }
                            } 
                            else {

                            }
                            debugger += 'Old Account--->' + newacc;
                            //begining of save point of account, this take cares of any roll back functionality 
                            Savepoint Accountsp = Database.setSavepoint();
                            //checking to see  if their was a account related to org code, if their was no account associated continue to create a new account
                            if (newacc.id == null) {
                                newacc.name = userDetails.CompanyName;
                                newacc.Other_Type__c =otherOrgType;
                                newacc.Is_this_Organization_CDC_Recognized__c = userDetails.CDC_Recognized_org__c;
                                newacc.type = userDetails.CDC_User_Profile_Type__c;
                                if (userDetails.Org_Code__c != '') {
                                    newacc.Org_Code__c = userDetails.Org_Code__c ;
                                }
                                newacc.ShippingPostalCode = userDetails.Zip_Code__c;
                                newacc.ownerid = accountonwerID ;
                                try {
                                    insert newacc;
                                    debugger += 'Save point on Account --->' + newacc; // variable for debug purpose
                                    tempa = newacc ;// variable for debug purpose
                                } catch (exception ex) {
                                    return ex + 'ex';
                                }
                            }
                            //check for the validity of password provided by end user. We are doing a check to make sure the passwords are meeting the system requirements
                            if (includePassword) {
                                if (!isValidPassword(password, confirmPassword)) {
                                    return Label.site.passwords_dont_match;
                                }
                                validatePassword(userDetails, password, confirmPassword);
                            } else {
                                password = null;
                            }

                            if (!conRec.isempty()) {
                                system.debug(conRec);
                                userDetails.contactId = conRec[0].id;
                                if (newacc != null) {
                                    conRec[0].accountid = newacc.id;
                                    update conRec[0];
                                }
                            }
                            String userId; // variable to store the user id
                            if (userDetails.contactId == null) {
                                userId = Site.createPortalUser(userDetails, newacc.id, password);//call this method to create user, contact
                            } else {
                                // return 'contact match'+u.contactId+conRec[0]+newacc;
                                userDetails.profileid = [select id from profile where name = 'Customer Community Login User-Custom' limit 1].id;
                                insert userDetails;
                                userId = userDetails.id;
                            }

                            // create a fake userId for test.
                            if (Test.isRunningTest()) {
                                userId = 'fakeUserId';
                            }
                            // check if the user got created.
                            if (userId != null) {

                                
                                if (password != null && password.length() > 1) {
                                    ApexPages.PageReference lgn = Site.login(userDetails.Email, password, startUrl); // direct page reference method which helps to take user to login page 
                                    if (!Test.isRunningTest()) {
                                        aura.redirect(lgn); // auto direct teh user to landing page of community
                                    }
                                } 
                                else {
                                    ApexPages.PageReference confirmRef = new PageReference(regConfirmUrl);
                                    if (!Test.isRunningTest()) {
                                        //aura.redirect(confirmRef);
                                        return regConfirmUrl;
                                    }
                                }
                            } 
                            else {
                                Database.rollback(Accountsp); // do a roll back on account inserted (newacc ). When a user creation fails we dont need dummy accounts
                                return debugger + newacc + 'We were not able to register you , please contact admin'; // for debug prupose
                            }
                            debugger += '<<<<USER ID IS>>>>' + userId + '<<<<<<complete Userinformation received>>>>' + userDetails;
                            return debugger;
                        } catch (Exception ex) {
                            Database.rollback(sp);
                            return debugger + tempa + ex.getmessage() + ex.getlinenumber() + '()';//+'--'+ex+'--'+ex.getLineNumber();
                        }
                    }
                    else {return 'Invalid Verification1';}
                }
                else {
                    return 'Invalid Verification2';
                }
            }
            else {
                return 'Invalid Verification3';
            }
        }
        else {
            return 'Invalid Verification4';
        }
    }

    @AuraEnabled
    public static Result[] lookup(String searchString,
            String sObjectAPIName,
            String whereClause,
            String rawSOQL,
            String context) {
        // Sanitze the input
        String sanitizedSearchString = String.escapeSingleQuotes(searchString);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);

        List<Result> results = new List<Result>();
        if (String.isBlank(rawSOQL)) {
            String returningFields = '(id,name,Org_Code__c,Type,Is_this_Organization_CDC_Recognized__c)';
            whereClause = 'IsCustomerPortal = true';
            if (String.isNotBlank(whereClause)) {
                returningFields = ' (id,name,Org_Code__c,Type,Is_this_Organization_CDC_Recognized__c WHERE ' + whereClause + ') ';
            }

            // Build our SOSL query
            String searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + returningFields + ' Limit 50';


            // Execute the Query
            List<List<SObject>> searchList = search.query(searchQuery);
			system.debug('searchList-->'+searchList);
            // Create a list of matches to return
            for (SObject so : searchList[0]) {
                results.add(new Result((String) so.get('Name'), so.Id, (String) so.get('Org_Code__c'), (String) so.get('Type'), 'test', (String) so.get('Is_this_Organization_CDC_Recognized__c')));
            }
        } else {

            rawSOQL = rawSOQL.replace('searchString', sanitizedSearchString);
            if (String.isNotBlank(context) && String.isNotBlank(rawSOQL)) {
                //run quieries specific context wise
            } else {
                for (Sobject so : Database.query(rawSOQL)) {
                    results.add(new Result((String) so.get('Name'), so.Id, (String) so.get('Org_Code__c'), (String) so.get('Type'), 'test', (String) so.get('Is_this_Organization_CDC_Recognized__c')));
                }
            }
        }

        return results;
    }

    /**
     * Inner class to wrap up an SObject Label and its Id
     */
    public class Result {
        @AuraEnabled public String SObjectLabel { get; set; }
        @AuraEnabled public Id SObjectId { get; set; }
        @AuraEnabled public string Org_Code { get; set; }
        @AuraEnabled public string Org_Type { get; set; }
        @AuraEnabled public string Org_SubType { get; set; }
        @AuraEnabled public string Org_CDCRecog { get; set; }

        public Result(String sObjectLabel, Id sObjectId, string Org_Code, string Org_Type, string Org_SubType, string Org_CDCRecog) {
            this.SObjectLabel = sObjectLabel;
            this.SObjectId = sObjectId;
            this.Org_Code = Org_Code;
            this.Org_Type = Org_Type;
            this.Org_SubType = Org_SubType;
            this.Org_CDCRecog = Org_CDCRecog;
        }
    }

    @auraenabled
    public static list<string> getprofileTypeValues() {
        return CDC_ApexUtilities.getPickValuesMap('Account', 'type', '-None-').values();
    }
    @auraenabled
    public static list<string> cdcRecognizedValues() {
        return CDC_ApexUtilities.getPickValuesMap('Account', 'Is_this_Organization_CDC_Recognized__c', '-None-').values();
    }
    @auraenabled
    public static list<string> getReferralQuestions() {
        return CDC_ApexUtilities.getPickValuesMap('User', 'User_Referred_to_CSC_by__c', '-None-').values();
    }

    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null;
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }
}