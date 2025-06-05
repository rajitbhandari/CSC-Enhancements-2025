/**
*————————————————————————————————————————————————————
* @Name            ViewSurveyController
* @Author          from SurveyforceManaged Package
*
*————————————————————————————————————————————————————
* @Changes
*
**/
/* Controller associated with pages rendering the survey.
 * Used by SurveyPage, ResultsPage, TakeSurvey
 */
global virtual without sharing class ViewSurveyController {
    public String  qQuestion                      {get; set;}
  public Boolean qRequired                      {get; set;}
  public String  qChoices                       {get; set;}
    public String surveyName                        {get; set;}
    public String surveyHeader                {get; set;}
    public Boolean hideSurveyName                {get; set;}
    public String surveyId                          {get; 
        set{
            this.surveyId = value;
            init();
        }
    }   
    public String renderSurveyPreview           {get; set;}  
    public String questionName                    {get; set;}  
    public String questionType                    {get; set;}
    public Boolean questionRequired             {get; set;}
  public List<SelectOption> singleOptions   {get; set;} 
    public List<SFQuestion> allQuestions        {get; set;}
    public List<String> responses                   {get; set;}
    public Integer allQuestionsSize               {get; set;}
    public String  templateURL                {get; set;}
    public String  surveyThankYouText         {get; set;}
    public String surveyContainerCss {get; set;}
    public String  surveyThankYouURL          {get; set;}
  public String  caseId                     {get; set;}
  public String contactId {get;set;}
    public String anonymousAnswer {get;set;}
    public List<SelectOption> anonymousOrUser {get;set;}
    public Boolean isInternal {get;set;}
    public String baseURL {get;set;}
    
    public String userId{get;set;}
    public String userName{get;set;}
    public String surveyTakerId {get;set;}
    public Boolean thankYouRendered{get;set;}
    public List<String> newOrder {get;set;}
    
    /* Retrieves the list of questions, the survey name, after retrieving the 
       necessary parameters from the url.
    */
 //------------------------------------------------------------------------------// 
    public ViewSurveyController(ApexPages.StandardController stdController) {
        // Get url parameters
        surveyId = Apexpages.currentPage().getParameters().get('id');
        caseId   = Apexpages.currentPage().getParameters().get('caId');
        contactId = Apexpages.currentPage().getParameters().get('cId'); 
    
        if(caseId ==null || caseId.length()<15){
            caseId = 'none';
        }
        if(contactId ==null || contactId.length()<15){
            contactId = 'none';
        }           
        // By default the preview is not showing up
        renderSurveyPreview = 'false';

        init();
    } 
    
    public ViewSurveyController(viewShareSurveyComponentController controller)
    {
        surveyId = Apexpages.currentPage().getParameters().get('id');
        caseId   = Apexpages.currentPage().getParameters().get('caId');
        contactId = Apexpages.currentPage().getParameters().get('cId'); 
        if(caseId ==null || caseId.length()<15){
            caseId = 'none';
        }
        if(contactId ==null || contactId.length()<15){
            contactId = 'none';
        }       
        // By default the preview is not showing up
        renderSurveyPreview = 'false';
        init();
    }
    
    
    public void init()
    {
        if (surveyId != null){ 
            // Retrieve all necessary information to be displayed on the page
            allQuestions = new List<SFQuestion>();
            setupQuestionList();
            setSurveyNameAndThankYou(surveyId);
            anonymousOrUser = new List<SelectOption>();
            anonymousOrUser.add(new SelectOption('Anonymous',System.Label.LABS_SF_Anonymous));
            anonymousOrUser.add(new SelectOption('User','User ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName()));
            anonymousAnswer = 'Anonymous';
            isInternal =true;
            newOrder = new List<String>();
            String urlBase = URL.getSalesforceBaseUrl().toExternalForm();
            baseURL = urlBase;
            
            userId = UserInfo.getUserId();
            userName = UserInfo.getName();
            
            String profileId = UserInfo.getProfileId();
            try
            {
                Profile p = [select Id, UserType from Profile where Id=:profileId];
                if (p.UserType == 'Guest')
                {
                    isInternal = false;
                }
                else
                {
                    isInternal = true;
                }
            }
            catch (Exception e){
                isInternal = false;
            }
            
            
            thankYouRendered=false;
            
            
        }       
    }
    
    
    


//----------------------------------------------------------------------------//    
    
    /* Called during the setup of the page. 
       Retrieve questions and responses from DB and inserts them in 2 lists. */
    public Integer setupQuestionList(){

        getAQuestion();
        return allQuestions.size();
    }
    
    
   /** Sets the survey's name variable
    *  param: sID   The survey ID as specified in the DB
    */
    public void setSurveyNameAndThankYou(String sId){
        SObjectAccessDecision securityDecision = 
        Security.stripInaccessible(AccessType.READABLE,
        [SELECT Name, 
                Id, 
                URL__c, 
                Thank_You_Text__c, 
                thankYouText__c, 
                thankYouLink__c, 
                Survey_Header__c,
                Hide_Survey_Name__c, 
                Survey_Container_CSS__c 
        FROM Survey__c 
        WHERE Id =:surveyId],
             true);

        Survey__c s = (Survey__c)securityDecision.getRecords()[0];
        surveyName = s.Name;
        surveyHeader = s.Survey_Header__c;
        hideSurveyName = s.Hide_Survey_Name__c;
        templateURL = s.URL__c+'id='+sId;//+'&cId={!Contact.Id}'+'&caId='+'{!Case.id}';
        surveyThankYouText = s.Thank_You_Text__c;
        if (surveyThankYouText == null)
        {
            surveyThankYouText = System.Label.LABS_SF_Survey_Submitted_Thank_you;
        }
        surveyThankYouURL = s.thankYouLink__c;
        surveyContainerCss = s.Survey_Container_CSS__c;
    }
    
//------------------------------------------------------------------------------//   
  public Pagereference updateSurveyName(){
    SObjectAccessDecision securityDecision = 
    Security.stripInaccessible(AccessType.UPDATABLE,
        [SELECT Name, 
                Id, 
                URL__c, 
                thankYouText__c, 
                thankYouLink__c 
        FROM Survey__c 
        WHERE Id =:surveyId],
         true);
      Survey__c s = (Survey__c)securityDecision.getRecords()[0];
      s.Name = surveyName;
      try{
        update s;
      }catch (Exception e){
        Apexpages.addMessages(e);
      }
      return null;
  } 

//------------------------------------------------------------------------------//      
    public Pagereference updateSurveyThankYouAndLink(){
        SObjectAccessDecision securityDecision = 
        Security.stripInaccessible(AccessType.UPDATABLE,
            [SELECT Name, 
                    Id, 
                    URL__c, 
                    thankYouText__c, 
                    thankYouLink__c 
            FROM Survey__c 
            WHERE Id =:surveyId],
             true);
        Survey__c s = (Survey__c)securityDecision.getRecords()[0];
        s.thankYouText__c = surveyThankYouText;
        s.thankYouLink__c = surveyThankYouURL;
        try{
            update s;
        }catch(Exception e){
            Apexpages.addMessages(e);
        }
        return null;
    }

  //------------------------------------------------------------------------------//    
  /** When requested from the page - when the user clicks on 'Update Order' -
      this function will reorganize the list so that it is displayed in the new order
   */
   public Pagereference refreshQuestionList(){
    setupQuestionList();
    return null;
   }
   
   
 
//------------------------------------------------------------------------------//      

    

//------------------------------------------------------------------------------//    
  private static boolean checkRequired(String response, Survey_Question__c question){
    if(question.Required__c == true){
        if(response == null || response =='NO RESPONSE')
          return false;
    }
    return true;
  } 

   /** Redirects the page that displays the detailed results of the survey, 
       from all users who took the survey.
    */
    public PageReference resultPage() {
        return new PageReference('/apex/ResultsPage?id='+surveyId);
    }

 
//------------------------------------------------------------------------------//  

//------------------------------------------------------------------------------//  

   /** 
    */
    public List<String> getResponses() {
        SObjectAccessDecision securityDecision = 
        Security.stripInaccessible(AccessType.READABLE,
            [SELECT Survey_Question__c, 
                    SurveyTaker__c, 
                    Response__c, 
                    Name 
            FROM SurveyQuestionResponse__c 
            LIMIT 100],
             true);
        List<SurveyQuestionResponse__c> qr = securityDecision.getRecords();
        List<String> resp = new List<String>();
        for (SurveyQuestionResponse__c r : qr) {
            resp.add(r.Response__c);
        }
        
        return resp;
    }  


    
  /** Fills up the List of questions to be displayed on the Visualforce page
   */   
    public List<SFQuestion> getAQuestion() {
            qQuestion = '';
            qChoices ='';
        SObjectAccessDecision securityDecision = 
        Security.stripInaccessible(AccessType.READABLE,
            [SELECT s.Type__c, 
                    s.Id, 
                    s.Survey__c, 
                    s.Required__c, 
                    s.Question__c, 
                    s.OrderNumber__c, 
                    s.Name, 
                    s.Choices__c 
            FROM Survey_Question__c s 
            WHERE s.Survey__c =: surveyId ORDER BY s.OrderNumber__c],
                true);
        List<Survey_Question__c> allQuestionsObject = securityDecision.getRecords();
        allQuestions = new List<SFQuestion>();
        
        Double old_OrderNumber = 0;
        Double new_OrderNumber;
        Double difference = 0;
        /* Make sure that the order number follow each other (after deleting a question, orders might not do so) */
        for (Survey_Question__c q : allQuestionsObject){ 
            new_OrderNumber = q.OrderNumber__c;
            difference = new_OrderNumber - old_OrderNumber - 1;
            if (difference > 0) {
                Double dd = double.valueOf(difference);
                Integer newOrderInt = dd.intValue();
                q.OrderNumber__c -= Integer.valueOf(newOrderInt); 
            }
            old_OrderNumber = q.OrderNumber__c;
            SFQuestion theQ = new SFQuestion(q);
            allQuestions.add(theQ);
        }
        allQuestionsSize = allQuestions.size();
        return allQuestions;
    }   
    
    public void submitResults()
    {
        try {
            List <SurveyQuestionResponse__c> sqrList = new List<SurveyQuestionResponse__c>();
             boolean showErrorMessage = true;
            for (SFQuestion q : allQuestions) {
                SurveyQuestionResponse__c sqr = new SurveyQuestionResponse__c();
                if (q.renderSelectRadio == 'true') {

                    if ((q.selectedOption == null || q.selectedOption == '')) {
                        if(q.required)
                        {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out required Question: '+'#'+q.orderNumber+'.'+q.question));
                            showErrorMessage = true;
                            return;
                        }
                    }else{
                        showErrorMessage = false;
                        
                    }
                system.debug('showErrorMessage1-->'+showErrorMessage);
                    if (q.selectedOption == null || q.selectedOption == '') {
                        sqr.Response__c = '';
                    } else {
                        sqr.Response__c = q.singleOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                    }
                    sqr.Survey_Question__c = q.Id;
                    sqrList.add(sqr);
                } 
                if (q.renderFreeText == 'true') {
                    if (q.choices == '') {
                        if(q.required)
                        {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out required Question: '+'#'+q.orderNumber+'.'+q.question));
                            showErrorMessage = true;
                            return;
                        }
                    }else{
                        showErrorMessage = false;
                    }

                    sqr.Response__c = q.choices;
                    sqr.Survey_Question__c = q.Id;
                    if(q.question=='Approximately how many total minutes did it take you to resolve this case?')
                    {
                        if(q.choices!=null )
                        {
                             if(q.choices.isNumeric())
                             {
                                 sqr.Number_of_Hours_Worked__c = integer.valueof(q.choices);
                             }else{
                                // Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'User need to enter only hours(number) while answering this question - Approximately how many total hours did it take you to resolve this case?"'));
                                // showErrorMessage = true;
                             }
                        }
                        
                    }
                    sqrList.add(sqr);
                } 
                if (q.renderSelectCheckboxes == 'true') {
                    if ((q.selectedOptions == null || q.selectedOptions.size() == 0)) {
                        if(q.required)
                        {
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out required Question: '+'#'+q.orderNumber+'.'+q.question));
                            showErrorMessage = true;
                            return;
                        }
                    }else{
                        showErrorMessage = false;
                    }
                    system.debug('showErrorMessage3-->'+showErrorMessage);
                    for (String opt : q.selectedOptions) {
                        sqr = new SurveyQuestionResponse__c();
                        
                        if (opt == '' || opt == null) {
                            sqr.Response__c = '';
                        } else {
                            sqr.Response__c = q.multiOptions.get(Integer.valueOf(opt)).getLabel();
                        }
                        sqr.Survey_Question__c = q.Id;
                        sqrList.add(sqr);
                    }
                } 
                if (q.renderSelectRow == 'true') {
                    if ( (q.selectedOption == null || q.selectedOption == '')) {
                            if(q.required)
                            {
                                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out required Question: '+'#'+q.orderNumber+'.'+q.question));
                                showErrorMessage = true;
                                return;
                            }
                    }else{
                        showErrorMessage = false;
                    }
                    if (q.selectedOption == null || q.selectedOption == '') {
                        sqr.Response__c = '';
                    } else {
                        sqr.Response__c = q.rowOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                    }
                    sqr.Survey_Question__c = q.Id;
                    sqrList.add(sqr);
                }
            }
            system.debug('showErrorMessage5-->'+showErrorMessage);
            if(showErrorMessage){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please answer at least one question'));
                return;
            }
            if(AddSurveyTaker())
            {
                for (SurveyQuestionResponse__c sqr : sqrList)
                {
                    sqr.SurveyTaker__c = surveyTakerId;
                }
                insert sqrList;
                thankYouRendered=true;
            }
        }catch(Exception e){
            if(isInternal) {
                Apexpages.addMessages(e);
            }else{
                System.debug('Exception: ' + e.getMessage());
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Some error occured while saving response'+e));
            }
        }

    }
    
    
    private Boolean AddSurveyTaker()
    {
        String userId;
        
        if (surveyId == null)
        {
            return false;
        }
        if(caseId.toUpperCase() =='NONE'|| caseId.length()<5)
          caseId = null;    
        if(contactId.toUpperCase() =='NONE'|| contactId.length()<5)
          contactId = null;         
        userId = UserInfo.getUserId();
        
        if( (contactId != null || caseId != null))
        {
            List<SurveyTaker__c> check = [Select Contact__c, Survey__c, Case__c, User__c From SurveyTaker__c Where Contact__c=:contactId and (Survey__r.Name != 'Survey for SME Documentation' and Survey__r.Name != 'Quarterly CDC SME Feedback' )and Survey__c=:surveyId and Case__c = :caseId and User__c=:UserId];
            if(check != null && check.size()>0){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_You_have_already_taken_this_survey));
                
                return false;       
            }
        }
        
     
        
        SurveyTaker__c st = new SurveyTaker__c();
        if(contactId==null){
        List<User> userRec = [select contactId from User where id = :userinfo.getuserid()];
        if(userRec!=null && userRec.size()>0){
            st.Contact__c = userRec[0].contactId;
        }
        }else{
        st.Contact__c = contactId;
        }
        st.Survey__c = surveyId;
        st.Taken__c = 'true';
        st.Case__c = caseId;
        st.User__c = userId;
        insert st;  
        surveyTakerId = st.Id;
        return true;    
    }
}