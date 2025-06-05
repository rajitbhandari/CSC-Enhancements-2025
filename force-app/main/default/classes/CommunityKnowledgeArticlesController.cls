public with sharing class CommunityKnowledgeArticlesController {

   @AuraEnabled(cacheable = true)
   public static List<Knowledge__kav> getCommunityKnowledgeArticles(){
      SObjectAccessDecision securityDecision = 
         Security.stripInaccessible(AccessType.READABLE,
              [SELECT Id,
                      Title
              FROM Knowledge__kav
              WHERE FirstPublishedDate = LAST_N_DAYS:30 
              AND IsVisibleInCsp = TRUE 
              AND PublishStatus = 'Online' 
              ORDER BY Title],
              true);
      return securityDecision.getRecords();
   }

   @AuraEnabled(cacheable = true)
   public static List<Knowledge__kav> getCommunityKnowledgeArticlesUpdated(){
      SObjectAccessDecision securityDecision = 
         Security.stripInaccessible(AccessType.READABLE,
               [SELECT Id,
                        Title
               FROM Knowledge__kav
               WHERE LastModifiedDate = LAST_N_DAYS:30
               AND FirstPublishedDate != LAST_N_DAYS:30
               AND IsVisibleInCsp = TRUE 
               AND PublishStatus = 'Online' 
               ORDER BY Title],
               true);
      return securityDecision.getRecords();
   }
}