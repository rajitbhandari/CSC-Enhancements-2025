/**
 * (c) Tony Scott. This code is provided as is and without warranty of any kind.
 *
 * This work by Tony Scott is licensed under a Creative Commons Attribution 3.0 Unported License.
 * http://creativecommons.org/licenses/by/3.0/deed.en_US
 */
({
    /**
     * load selected value in init 
     */
    
    init : function(cmp, event, helper){
        var spinnerimg = cmp.find('spinnerimg');
        $A.util.addClass(spinnerimg, 'slds-hide');
        helper.showSelectedLabel(cmp, event);  
    },
    
    /**
     * Search an SObject for a match
     */
	search : function(cmp, event, helper) {
        console.log('in search');
		helper.doSearch(cmp);        
    },
	/**
     * onblur an SObject for a match
     */
	blur : function(cmp, event, helper) {
        var noresult = cmp.find('lookuplist');
        var matchesVal = cmp.get('v.matches');
        var lookupVal = cmp.find('lookup').get('v.value');
        if(lookupVal==''){
            cmp.set('v.orgCodeObject', null);
        }
        if(matchesVal==null){
        // Hide the lookuplist
            $A.util.addClass(noresult, 'slds-hide');
            // MO: fix for slds202
            $A.util.removeClass(noresult, 'slds-show');
            cmp.set('v.orgCodeObject', null);
            cmp.set('v.errorMessageValue', '');
        }
		  
    },

    /**
     * Select an SObject from a list
     */
    select: function(cmp, event, helper) {
       
        console.log('in select');
    	helper.handleSelection(cmp, event);
    }
    
    
})