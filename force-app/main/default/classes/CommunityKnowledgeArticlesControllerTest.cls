@isTest public with sharing class CommunityKnowledgeArticlesControllerTest {
    static testMethod void testKnowledgeArticlesList (){
        List<Knowledge__kav> knowledgeArticleVersions = new List<Knowledge__kav>();

        for (Integer count = 0; count < 50; count++) {
            knowledgeArticleVersions.add(
                new Knowledge__kav (
                    Title = 'CSCArticles'+count,
                    UrlName = 'CSCArticles'+count,
                    IsVisibleInCsp = TRUE ));
        }  
        insert knowledgeArticleVersions;

        Test.startTest();
            CommunityKnowledgeArticlesController.getCommunityKnowledgeArticles();
        Test.stopTest();

        Knowledge__kav ka = [SELECT Title FROM Knowledge__kav LIMIT 1];
        System.assertEquals(ka.Title ,'CSCArticles0','Code is not working');
    }
    
    static testMethod void testKnowledgeArticlesListUpdated (){
        List<Knowledge__kav> knowledgeArticleVersions = new List<Knowledge__kav>();

        for (Integer count = 0; count < 50; count++) {
            knowledgeArticleVersions.add(
                new Knowledge__kav (
                    Title = 'CSCArticles'+count,
                    UrlName = 'CSCArticles'+count,
                    IsVisibleInCsp = TRUE ));
        }  
        insert knowledgeArticleVersions;

        Test.startTest();
            CommunityKnowledgeArticlesController.getCommunityKnowledgeArticlesUpdated();
        Test.stopTest();

        Knowledge__kav ka = [SELECT Title FROM Knowledge__kav LIMIT 1];
        System.assertEquals(ka.Title ,'CSCArticles0','Code is not working');
    }
}