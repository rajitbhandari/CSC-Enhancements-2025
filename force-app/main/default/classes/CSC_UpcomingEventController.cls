public without sharing class CSC_UpcomingEventController {
    public CSC_UpcomingEventController() {}

    @AuraEnabled(cacheable=true)
    public static List<Event> getUpcomingEvents(String startDate, String endDate, String subject, Boolean showNextUpcomingOnly) {
        DateTime now = System.now();
        DateTime startDt;
        DateTime endDt;
        if (showNextUpcomingOnly == true) {
            startDt = now;
            endDt = now.addDays(30); // Only 1 week ahead
        } else {
            try {
                // Fix: Replace 'T' with ' ' and remove 'Z' for DateTime.valueOf compatibility
                String safeStartDate = (startDate != null && startDate != '') ? startDate.replace('T', ' ').replace('Z', '') : null;
                startDt = (safeStartDate != null && safeStartDate != '') ? DateTime.valueOf(safeStartDate) : now.addDays(-30*7);
            } catch (Exception e) {
                System.debug('rohith error found'+e);
                startDt = now.addDays(-30*7);
            }
            try {
                String safeEndDate = (endDate != null && endDate != '') ? endDate.replace('T', ' ').replace('Z', '') : null;
                endDt = (safeEndDate != null && safeEndDate != '') ? DateTime.valueOf(safeEndDate) : now.addDays(30*7);
            } catch (Exception e) {
                System.debug('rohith error found'+e);
                endDt = now.addDays(30*7);
            }
        }
        // Debug: log the date range used for filtering
        System.debug('DEBUG: Filtering Events from ' + startDt.date() + ' to ' + endDt.date());
        List<Event> events = new List<Event>();
        if (subject != null && subject.trim() != '') {
            // Use SOSL to search both Subject and Description, filter by date only (ignore time zone)
            List<List<SObject>> searchResults = [FIND :subject IN ALL FIELDS RETURNING Event(Id, Subject, StartDateTime, EndDateTime, Description, OwnerId WHERE DAY_ONLY(StartDateTime) >= :startDt.date() AND DAY_ONLY(StartDateTime) <= :endDt.date())];
            if (!searchResults.isEmpty()) {
                events = (List<Event>)searchResults[0];
            }
        } else {
            events = [SELECT Id, Subject, StartDateTime, EndDateTime, Description, OwnerId,Type FROM Event WHERE DAY_ONLY(StartDateTime) >= :startDt.date() AND DAY_ONLY(StartDateTime) <= :endDt.date() ORDER BY StartDateTime ASC];
        }
        if (showNextUpcomingOnly == true && events.size() > 0) {
            Integer count = Math.min(2, events.size());
            List<Event> result = new List<Event>();
            for (Integer i = 0; i < count; i++) {
                result.add(events[i]);
            }
            return result;
        }
        return events;
    }
}