public with sharing class MyActivityController {

    public class CaseWithComments {
        @AuraEnabled public Case caseRecord;
        @AuraEnabled public List<CaseComment> comments;
    }

    @AuraEnabled(cacheable=true)
    public static List<CaseWithComments> searchCases(String searchKey) {
        List<Case> cases;
        if (String.isBlank(searchKey)) {
            List<Case> openCases = [
                SELECT Id, CaseNumber, Status, Subject, CreatedDate, LastModifiedDate, Description, OwnerId, ContactId
                FROM Case
                WHERE IsClosed = false
                ORDER BY CreatedDate DESC
                LIMIT 20
            ];
            List<Case> closedCases = [
                SELECT Id, CaseNumber, Status, Subject, CreatedDate, LastModifiedDate, Description, OwnerId, ContactId
                FROM Case
                WHERE IsClosed = true
                ORDER BY CreatedDate DESC
                LIMIT 20
            ];
            cases = new List<Case>();
            cases.addAll(openCases);
            cases.addAll(closedCases);
        } else {
            List<List<SObject>> searchResults = Search.query(
                'FIND \'' + String.escapeSingleQuotes(searchKey) + '*\' IN ALL FIELDS RETURNING Case(Id, CaseNumber, Status, Subject, CreatedDate, LastModifiedDate, Description, OwnerId, ContactId)'
            );
            cases = searchResults.isEmpty() ? new List<Case>() : (List<Case>)searchResults[0];
        }

        // Get current user Id
        Id currentUserId = UserInfo.getUserId();

        // Query CaseComments for all cases, only if there are cases
        Map<Id, List<CaseComment>> caseIdToComments = new Map<Id, List<CaseComment>>();
        Set<Id> caseIds = new Set<Id>();
        Map<Id, Id> caseIdToContactId = new Map<Id, Id>();
        for (Case c : cases) {
            caseIds.add(c.Id);
            caseIdToContactId.put(c.Id, c.ContactId);
        }
        if (!caseIds.isEmpty()) {
            for (CaseComment cc : [
                SELECT Id, CommentBody, CreatedDate, CreatedById, CreatedBy.Name, ParentId
                FROM CaseComment
                WHERE ParentId IN :caseIds
                ORDER BY CreatedDate DESC
            ]) {
                // Only add comment if CreatedById != ContactId of the case
                if (caseIdToContactId.containsKey(cc.ParentId) && cc.CreatedById != currentUserId) {
                    if (!caseIdToComments.containsKey(cc.ParentId)) {
                        caseIdToComments.put(cc.ParentId, new List<CaseComment>());
                    }
                    caseIdToComments.get(cc.ParentId).add(cc);
                }
            }
        }

        List<CaseWithComments> result = new List<CaseWithComments>();
        for (Case c : cases) {
            CaseWithComments wrap = new CaseWithComments();
            wrap.caseRecord = c;
            wrap.comments = caseIdToComments.containsKey(c.Id) ? caseIdToComments.get(c.Id) : new List<CaseComment>();
            result.add(wrap);
        }
        return result;
    }
}