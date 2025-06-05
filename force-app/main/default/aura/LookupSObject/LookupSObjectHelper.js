/**
 * (c) Tony Scott. This code is provided as is and without warranty of any kind.
 *
 * This work by Tony Scott is licensed under a Creative Commons Attribution 3.0 Unported License.
 * http://creativecommons.org/licenses/by/3.0/deed.en_US
 */
({
    /**
     * Perform the SObject search via an Apex Controller
     */
    doSearch : function(cmp) {
        // Get the search string, input element and the selection container
        var searchString = cmp.get('v.searchString');
        var inputElement = cmp.find('lookup');
        var lookupList = cmp.find('lookuplist');
        var whereClause = cmp.get('v.whereClause');
        var rawSOQL = cmp.get('v.rawSOQL');
        var context = cmp.get('v.context');
        var spinnerimg = cmp.find('spinnerimg');

        // Clear any errors and destroy the old lookup items container
        inputElement.set('v.errors', null);
        
        console.log('searchString', searchString);

        // We need at least 2 characters for an effective search
        if (typeof searchString === 'undefined' || searchString.length < 3) {
            // Hide the lookuplist
            $A.util.addClass(lookupList, 'slds-hide');
            // MO: fix for slds202
            $A.util.removeClass(lookupList, 'slds-show');
            return;
        }
			
      
        $A.util.addClass(spinnerimg, 'slds-show');
        $A.util.removeClass(spinnerimg, 'slds-hide');
        
        // Show the lookuplist
        $A.util.removeClass(lookupList, 'slds-hide');

        // MO: fix for slds202
        $A.util.addClass(lookupList, 'slds-show');

        // Get the API Name
        var sObjectAPIName = cmp.get('v.sObjectAPIName');

        // Create an Apex action
        var action = cmp.get('c.lookup');

        // Mark the action as abortable, this is to prevent multiple events from the keyup executing
        action.setAbortable();

        // Set the parameters
        action.setParams({ 'searchString' : searchString, 'sObjectAPIName' : sObjectAPIName, 'whereClause' : whereClause, 'rawSOQL': rawSOQL, 'context': context});
                          
        // Define the callback
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response', response);
           // alert(state);
            // Callback succeeded
             $A.util.removeClass(spinnerimg, 'slds-show');
        	$A.util.addClass(spinnerimg, 'slds-hide');
            if (cmp.isValid() && state === 'SUCCESS') {
                // Get the search matches
                var matches = response.getReturnValue();

                // If we have no matches, return nothing
                if (matches.length == 0) {
                    cmp.set('v.matches', null);
                    return;
                }
                
                // Store the results
                cmp.set('v.matches', matches);
        	
            } else if (state === 'ERROR') { // Handle any error by reporting it
                
                var errors = response.getError();
                
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.displayToast('Error', errors[0].message);
                    }
                } else {
                    this.displayToast('Error', 'Unknown error.');
                }
            }
        });
        
        // Enqueue the action                  
        $A.enqueueAction(action);                
    },

    /**
     * Hide not related elements if value is already assigned
     * on load
     */
    showSelectedLabel : function(cmp, objectLabel){
        var searchString = cmp.get("v.searchString");
        if (!$A.util.isEmpty(searchString)){
            // Hide the Lookup List
            var lookupList = cmp.find('lookuplist');
            $A.util.addClass(lookupList, 'slds-hide');
            // MO: fix for slds202
            $A.util.removeClass(lookupList, 'slds-show');

            // Hide the Input Element
            var inputElement = cmp.find('lookup');
            $A.util.addClass(inputElement, 'slds-hide');
            // MO: fix for slds202
            $A.util.removeClass(inputElement, 'slds-show');

            // Show the Lookup pill
            var lookupPill = cmp.find('lookup-pill');
            $A.util.removeClass(lookupPill, 'slds-hide');
            // MO: fix for slds202
            $A.util.addClass(lookupPill, 'slds-show');

            // Lookup Div has selection
            var inputElement = cmp.find('lookup-div');
            $A.util.addClass(inputElement, 'slds-has-selection');
        }
    },

    /**
     * Handle the Selection of an Item
     */
    handleSelection : function(cmp, event) {
          console.dir(event);
        var addnewValue =event.currentTarget.id;
        //  alert('hi');
       // alert(addnewValue);
        //alert('hi');
        if(addnewValue=='AddNewValue'){
            //alert('inside if condition');
            var matchesVal = cmp.get('v.matches');
            for (var i = 0; i < matchesVal.length; i++) { 
                var searchText = cmp.find("lookup").get("v.value").trim();
                if(matchesVal[i].SObjectLabel.toLowerCase()==searchText.toLowerCase()){
                    //alert('Their is already an organization with the same name');
                    cmp.set('v.errorMessageValue','Their is already an organization with the same name');
                    return;
                }
            }
            var addNewresult = cmp.find('lookuplist');
            $A.util.addClass(addNewresult, 'slds-hide');
            // MO: fix for slds202
            $A.util.removeClass(addNewresult, 'slds-show');
            cmp.set('v.orgCodeObject', null);
            return;
        }
        var objectId = this.resolveId(event.currentTarget.id);
		var objectD = event.currentTarget.value;
        console.dir(objectD);
        // The Object label is the inner text)
      
        	var objectLabel = event.currentTarget.innerText;

        // Log the Object Id and Label to the console
       // console.log('objectId=' + objectId);
       // console.log('objectLabel=' + objectLabel);
                
        // Create the UpdateLookupId event
        var updateEvent = cmp.getEvent('updateLookupIdEvent');
        
        // Get the Instance Id of the Component
       var instanceId = cmp.get('v.instanceId');

        //Get index of component
        var index = cmp.get('v.index');

        // Populate the event with the selected Object Id and Instance Id
        updateEvent.setParams({
            'sObjectId' : objectId, 'instanceId' : instanceId, 'index' : index
        });

        // Fire the event
        updateEvent.fire();

        // Update the Searchstring with the Label
        cmp.set('v.searchString', objectLabel);
        cmp.set('v.orgCodeObject', objectId);
        cmp.set('v.errorMessageValue', '');
		
        // Hide the Lookup List
        var lookupList = cmp.find('lookuplist');
        $A.util.addClass(lookupList, 'slds-hide');
        // MO: fix for slds202
        $A.util.removeClass(lookupList, 'slds-show');

        // Hide the Lookup pill
        var lookupPill = cmp.find('lookup-pill');
        $A.util.addClass(lookupPill, 'slds-hide');
        // MO: fix for slds202
        $A.util.removeClass(lookupPill, 'slds-show');

        // Show the Input Element
        var inputElement = cmp.find('lookup');
        $A.util.removeClass(inputElement, 'slds-hide');
        // MO: fix for slds202
        $A.util.addClass(inputElement, 'slds-show');

        // Lookup Div has no selection
        var inputElement = cmp.find('lookup-div');
        // MO: fix for slds202
        $A.util.removeClass(inputElement, 'slds-has-selection');
        
    },

    
    /**
     * Resolve the Object Id from the Element Id by splitting the id at the _
     */
    resolveId : function(elmId) {
        
        var i = elmId.lastIndexOf('_');
        return elmId.substr(i+1);
    },

    /**
     * Display a message
     */
    displayToast : function (title, message) {
        var toast = $A.get('e.force:showToast');

        // For lightning1 show the toast
        if (toast) {
            //fire the toast event in Salesforce1
            toast.setParams({
                'title': title,
                'message': message
            });

            toast.fire();
        } else { // otherwise throw an alert        
            alert(title + ': ' + message);
        }
    }
})