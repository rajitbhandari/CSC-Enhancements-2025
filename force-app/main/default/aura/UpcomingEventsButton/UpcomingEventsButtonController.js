({
    eventsCalendar : function(component, event, helper) {
        console.log("Events Calendar Function");
        //events-calender        
        var url = '/events-calendar';
        console.log(url);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    }
})