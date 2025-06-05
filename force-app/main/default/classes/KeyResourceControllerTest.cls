@isTest

private class KeyResourceControllerTest {


    @isTest

    static void testGetKeyResourceConfig() {

        // Call the AuraEnabled method

        Test.startTest();

        List<KeyResourceController.TopArticle> response = KeyResourceController.getKeyResourceConfig();

        Test.stopTest();


    }



    @isTest

    static void testEmptyKeyResourceConfig() {


        Test.startTest();

        List<KeyResourceController.TopArticle> response = KeyResourceController.getKeyResourceConfig();

        Test.stopTest();


    }

}