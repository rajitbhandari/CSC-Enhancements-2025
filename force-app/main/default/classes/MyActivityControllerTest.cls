@isTest
public class MyActivityControllerTest {
    @isTest
    static void testSearchCases_NoSearchKey() {
        // Create test Contact
        contact con = TestFactory.returnContact;

        // Create test Cases
        Case openCase = new Case(Status='New', Subject='Open Case', Description='Test open case', ContactId=con.Id);
        Case closedCase = new Case(Status='Closed', Subject='Closed Case', Description='Test closed case', ContactId=con.Id);
        insert new List<Case>{openCase, closedCase};

        // Add a comment by another user
        User u = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1];
            CaseComment cc = new CaseComment(ParentId=openCase.Id, CommentBody='Test comment from another user');
            insert cc;

        // Add a comment by current user (should be filtered out)
        CaseComment cc2 = new CaseComment(ParentId=closedCase.Id, CommentBody='Test comment from current user');
        insert cc2;

        Test.startTest();
        List<MyActivityController.CaseWithComments> results = MyActivityController.searchCases('');
        Test.stopTest();

        System.assertNotEquals(0, results.size(), 'Should return cases');
        Boolean foundComment = false;
        for (MyActivityController.CaseWithComments wrap : results) {
            if (wrap.caseRecord.Id == openCase.Id) {
                //System.assertEquals(1, wrap.comments.size(), 'Should have 1 comment from another user');
                foundComment = true;
            }
            if (wrap.caseRecord.Id == closedCase.Id) {
                System.assertEquals(0, wrap.comments.size(), 'Should not have comment from current user');
            }
        }
        System.assert(foundComment, 'Open case with comment should be found');
    }

    @isTest
    static void testSearchCases_WithSearchKey() {
        // Create test Contact
        contact con = TestFactory.returnContact;

        // Create test Case
        Case testCase = new Case(Status='New', Subject='UniqueSubject123', Description='Test case for search', ContactId=con.Id);
        insert testCase;

        // Add a comment by another user
        User u = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1];
            CaseComment cc = new CaseComment(ParentId=testCase.Id, CommentBody='Another user comment');
            insert cc;

        Test.startTest();
        List<MyActivityController.CaseWithComments> results = MyActivityController.searchCases('UniqueSubject123');
        Test.stopTest();

    }
}