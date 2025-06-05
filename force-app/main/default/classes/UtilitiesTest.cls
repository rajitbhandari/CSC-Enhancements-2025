@isTest private class UtilitiesTest { 
    @testSetup static void setupTestData() { 
        // Test data setup is not required as Organization object data is already available in Salesforce. 
        // However, if needed, you can create test user or test records here. 
        // 
    } 
    @isTest static void testGetInstance() { 
        // Set the current page context to mock Visualforce page 
        Test.startTest(); PageReference pageRef = Page.SurveyPage; 
        // Create a Visualforce Page named 'TestPage' in your org Test.setCurrentPage(pageRef); 
        // Mocking the header values 
        ApexPages.currentPage().getHeaders().put('Host', 'cs123.salesforce.com'); 
        // Call the method 
        String instanceName = Utilities.getInstance(); // Validate the instance name for sandbox 

        Test.stopTest(); 
    } 
    @isTest static void testGetSubdomainPrefix() { 
        Test.startTest(); 
        // Mock the user info to simulate sandbox username 
        System.runAs(new User(Id = UserInfo.getUserId(), Username = 'test.user@sandbox.org')) { 
            String subdomainPrefix = Utilities.getSubdomainPrefix(); 
        } Test.stopTest(); 
    } 
}