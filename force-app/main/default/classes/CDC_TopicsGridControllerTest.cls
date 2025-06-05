@isTest(SeeAllData=true)

private class CDC_TopicsGridControllerTest {



    @isTest 

    static void testGetTopics() {

        // Ensure at least one Network record exists

        List<Network> networks = [SELECT Id FROM Network LIMIT 1];

        System.assert(networks.size() > 0, 'Test requires at least one Network record.');

        

        // Call the method under test

        Test.startTest();

        List<CDC_TopicsGridController.Topics> topicsList = CDC_TopicsGridController.getTopics();

        Test.stopTest();



        // Verify that the method returns a list (could be empty if there are no managed topics)

        System.assertNotEquals(null, topicsList, 'Returned list should not be null');



        // If managed topics exist, validate the topic structure.

        if (!topicsList.isEmpty()) {

            CDC_TopicsGridController.Topics firstTopic = topicsList[0];

            System.assertNotEquals(null, firstTopic.TopicName, 'TopicName should be set');

            // Verify the URL contains expected parts. (The topic URL is built using the topic id and name.)

            System.assert(firstTopic.TopicURL.contains('/s/topic/'), 'TopicURL should contain /s/topic/');

            // TopicImage is derived from custom metadata; if none exists for the topic, it may be appended as null.

            System.assertNotEquals(null, firstTopic.TopicImage, 'TopicImage should not be null');

        }

    }

}