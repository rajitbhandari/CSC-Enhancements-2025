/**
 * Created by vpolavarapu on 9/19/2019.
 */


@istest
private class CustomArticleViewControllerTest {


    @testSetup

    static void setupTestData() {


         List<Network> networks = [SELECT Id FROM Network LIMIT 1];
        Network network = (networks.size() == 1) ? networks.get(0) : null;
  

        

        // Create Topic (like Knowledge Topics)

        Topic testTopic = new Topic(Name = 'Test Topic');

        insert testTopic;



        // Create a Knowledge Article (for Topic)

        Knowledge__kav article = new Knowledge__kav(

            Title = 'Test Article',
            UrlName = 'test-article',
            Priority__c = '1'

        );

        insert article;



        // Assign Topic to Article using TopicAssignment

        TopicAssignment topicAssignment = new TopicAssignment(

            EntityId = article.Id,

            TopicId = testTopic.Id

        );

        insert topicAssignment;

    }



 

   @IsTest

    static void testGetArticles() {

        // Fetch the Topic created in setup

        Topic testTopic = [SELECT Id FROM Topic LIMIT 1];

        

        Test.startTest();

        // Call the method to get articles for the topic

        CustomArticleViewController.ArticleDTO[] articles = 

            CustomArticleViewController.getArticles(testTopic.Id);



        // Assertions

       // System.assertNotEquals(articles, null, 'Articles should not be null');

      //  System.assertEquals(articles.size(), 1, 'There should be one article');

       // System.assertEquals(articles[0].knowledgeTitle, 'Test Article', 'Article title should match');

       // System.assertEquals(articles[0].knowledgeUrlName, 'test-article', 'Article URL should match');

        Test.stopTest();

    }



    @isTest

    static void testGetPriorityArticles() {

        // Fetch the Topic created in setup

        Topic testTopic = [SELECT Id, Name FROM Topic LIMIT 1];

        

        Test.startTest();

        // Call the method to get priority articles

        CustomArticleViewController.ArticleDTO[] priorityArticles = 

            CustomArticleViewController.getPriorityArticles(testTopic.Id, testTopic.Name);



        // Assertions

       // System.assertNotEquals(priorityArticles, null, 'Priority Articles should not be null');

       // System.assertEquals(priorityArticles.size(), 1, 'There should be one priority article');

       // System.assertEquals(priorityArticles[0].knowledgeTitle, 'Test Article', 'Article title should match');

        Test.stopTest();

    }



    @isTest

    static void testNoArticlesFound() {

        // Create a new Topic without any Articles

        Topic noArticleTopic = new Topic(Name = 'No Article Topic');

        insert noArticleTopic;

        

        Test.startTest();

        // Call the method for a Topic with no Articles

        CustomArticleViewController.ArticleDTO[] articles = 

            CustomArticleViewController.getArticles(noArticleTopic.Id);



        // Assertions

        //System.assertEquals(articles.size(), 0, 'There should be no articles');

        Test.stopTest();

    }




}