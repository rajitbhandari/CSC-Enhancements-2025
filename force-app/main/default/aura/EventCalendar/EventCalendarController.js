({
    created : function(component, event, helper) {
        helper.created(component, event);
    },
    renderCalendar : function(component, event, helper) {
        var eventsMap = component.get("v.events");
        $(document).ready(function(){
            var eventArray = [];
            $.each(eventsMap, function(index, value){
                var newEvent = {
                    id : value.Id,
                    title : value.title,
                    start : moment(value.startDateTime),
                    end : moment(value.endDateTime),
                    description : value.description,
                    owner : value.owner
                }
                eventArray.push(newEvent);
            });
            var calendarButtons = component.get('v.calendarButtons');
            $('#calendar').fullCalendar({
                header: {
                    left: 'today prev,next',
                    center: 'title',
                    right: calendarButtons
                },
                defaultDate: moment().format("YYYY-MM-DD"),
                navLinks: false, // can click day/week names to navigate views
                editable: false,
                eventLimit: true, // allow "more" link when too many events
                weekends: component.get('v.weekends'),
                eventBackgroundColor: component.get('v.eventBackgroundColor'),
                eventBorderColor: component.get('v.eventBorderColor'),
                eventTextColor: component.get('v.eventTextColor'),
                events: eventArray,
                eventClick: function(calEvent, jsEvent, view) {
                    component.set('v.titleVal', calEvent.title);
                    component.set('v.descriptionVal', calEvent.description);
                    if(calEvent.start._d!=null) component.set('v.startDateTimeVal', moment(calEvent.start._d).format());
                    if(calEvent.end!=null) component.set('v.endDateTimeVal', moment(calEvent.end._d).format());
                   component.set('v.idVal', calEvent.id);
                    component.set('v.newOrEdit', 'Edit');
                    helper.openModal(component, event);
                },
                eventDrop: function(event, delta, revertFunc) {
                    var evObj = {
                        "Id" : event.id,
                        "title" : event.title,
                        "startDateTime" : moment(event.start._i).add(delta).format(),
                        "endDateTime" : moment(event.end._i).add(delta).format(),
                        "description" : event.description
                    };
                    helper.upsertEvent(component, evObj);
                },
                eventResize: function(event, delta, revertFunc) {
                    var evObj = {
                        "Id" : event.id,
                        "title" : event.title,
                        "startDateTime" : moment(event.start._i).format(),
                        "endDateTime" : moment(event.end._i).add(delta).format(),
                        "description" : event.description
                    };
                    helper.upsertEvent(component, evObj);
                },
                dayClick: function(date, jsEvent, view) {
                   
                }
            });
        });
    },
    navigate : function(component, event, helper) {
	
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": 'https://www.google.com'
    });
    urlEvent.fire(); 
	},
    
    createRecord : function(component, event, helper) {
        
    },
    deleteRecord : function(component, event, helper) {
       
    },
    openModal : function(component, event, helper) {
        helper.openModal(component, event);
    },
    closeModal : function(component, event, helper) {
        helper.closeModal(component, event);
    }
})