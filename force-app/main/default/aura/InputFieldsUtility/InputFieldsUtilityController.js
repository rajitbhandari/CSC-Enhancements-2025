({
	changeSelect : function(component, event, helper) {
		 var selected = event.getSource().get("v.label"); 
        component.set("v.FieldValue",selected);
    },
    changemultiSelect : function(component, event, helper) {
        var Selectedvalues = component.get("v.FieldValue");
        if(Selectedvalues==null){
            Selectedvalues = '';
        }
		 var selected = event.getSource().get("v.label"); 
        Selectedvalues = Selectedvalues + selected +';';
        component.set("v.FieldValue",Selectedvalues);
    }
})