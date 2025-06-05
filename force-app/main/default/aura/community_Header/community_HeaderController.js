({
    doInit : function(component, event, helper) {
        
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
            
              
            }
        });
        $A.enqueueAction(action);
        var cscCommunity = $A.get("$Label.c.CommunityURL");
    
        component.set("v.cscPath", cscCommunity);
    },

    handleMessage: function (component) {
        component.set('v.hiddenClass', "slds-no-print");
    },

    handleReturnToTop: function (component) {
        var focusNumber = component.get("v.showFocus");
        var showFocus = "shwFocus" + focusNumber;
        setTimeout(function(){ 
            component.find(showFocus).getElement().focus();
        }, 100);
    },
   
    handleClick : function(component, event, helper) {
        component.set("v.accordian",true);
        component.set("v.showFocus", "2");
        setTimeout(function(){ 
            component.find("shwFocus2").getElement().focus();
        }, 200);
       
    },
    
    
    handleClick1 : function(component, event, helper){
        component.set("v.accordian", false);
        component.set("v.showFocus", "1");
        setTimeout(function(){ 
            component.find("shwFocus1").getElement().focus();
        }, 200);
    },
    
    
    openProfile: function(component, event, helper){        
        component.set('v.openProfile', true);
        var elem = component.find('prof');
        $A.util.removeClass(elem, 'prof');
        $A.util.addClass(elem, 'profileChange');
    },
    closeProfile: function(component, event, helper){       
        component.set('v.openProfile', false);
        var elem = component.find('prof');
        $A.util.removeClass(elem, 'profileChange');
        $A.util.addClass(elem, 'profile');
    },
    
    openHamburger: function(component, event, helper){
        
        component.set('v.hamburger', true);
    },
    
    closeHamburger: function(component, event, helper){
        component.set('v.hamburger', false);  
    },

    // Handle Mobile Menu Items
    mob1: function(component, event, helper){
        component.set('v.mobile1', true);  
    },
    Cmob1: function(component, event, helper){
        component.set('v.mobile1', false);  
    },
    mob2: function(component, event, helper){
        component.set('v.mobile2', true);  
    },
    Cmob2: function(component, event, helper){
        component.set('v.mobile2', false);  
    },
    mob3: function(component, event, helper){
        component.set('v.mobile3', true);  
    },
    Cmob3: function(component, event, helper){
        component.set('v.mobile3', false);  
    },
    mob4: function(component, event, helper){
        component.set('v.mobile4', true);  
    },
    Cmob4: function(component, event, helper){
        component.set('v.mobile4', false);  
    },
    mob5: function(component, event, helper){
        component.set('v.mobile5', true);  
    },
    Cmob5: function(component, event, helper){
        component.set('v.mobile5', false);  
    },
    mob6: function(component, event, helper){
        component.set('v.mobile6', true);  
    },
    Cmob6: function(component, event, helper){
        component.set('v.mobile6', false);  
    },


    hideOnBlur : function(component, event, helper){
        console.log('Inside blur event');
        var myMenu = component.find('myMenu');
        $A.util.removeClass(myMenu, 'slds-is-open');
    },
    openProfileTab: function(component, event, helper){
        if (event.keyCode === 13) {
            component.set('v.openProfile', true);
            var elem = component.find('prof');
            $A.util.removeClass(elem, 'prof');
            $A.util.addClass(elem, 'profileChange');
        }
    },
    closeProfileTab: function(component, event, helper){
        if (event.keyCode === 13) {           
            component.set('v.openProfile', false);
            var elem = component.find('prof');
            $A.util.removeClass(elem, 'profileChange');
            $A.util.addClass(elem, 'profile');
        }
    },
    tabOpen1 :function(component, event, helper){        
        if (event.keyCode === 13) {
            component.set('v.accordian1', true);
            component.set('v.accordian2', false);
            component.set('v.accordian3', false);
            component.set('v.accordian4', false);            
            var elem = component.find('test1');
            var elem2 = component.find('test2');
            var elem3 = component.find('test3');
            var elem4 = component.find('test4');            
            $A.util.removeClass(elem2, 'test');
            $A.util.removeClass(elem3, 'test');
            $A.util.removeClass(elem4, 'test');
            $A.util.removeClass(elem, 'test1');
            $A.util.addClass(elem, 'test');
        }
    },
    tabOpen2 :function(component, event, helper){
        if (event.keyCode === 13) {
            component.set('v.accordian2', true);        
            component.set('v.accordian1', false);
            component.set('v.accordian3', false);
            component.set('v.accordian4', false);            
            var elem = component.find('test2');
            var elem2 = component.find('test1');
            var elem3 = component.find('test3');
            var elem4 = component.find('test4');
            $A.util.removeClass(elem2, 'test');
            $A.util.removeClass(elem3, 'test');
            $A.util.removeClass(elem4, 'test');            
            $A.util.removeClass(elem, 'test2');
            $A.util.addClass(elem, 'test');
        }
    },    
    tabOpen3 :function(component, event, helper){
        if (event.keyCode === 13) {
            component.set('v.accordian3', true);
            component.set('v.accordian1', false);
            component.set('v.accordian2', false);
            component.set('v.accordian4', false);            
            var elem = component.find('test3');
            var elem2 = component.find('test1');
            var elem3 = component.find('test2');
            var elem4 = component.find('test4');            
            $A.util.removeClass(elem2, 'test');
            $A.util.removeClass(elem3, 'test');
            $A.util.removeClass(elem4, 'test');
            $A.util.removeClass(elem, 'test3');
            $A.util.addClass(elem, 'test');
        }
    }, 
    tabOpen4 :function(component, event, helper){
        if (event.keyCode === 13) {
            component.set('v.accordian4', true);
            component.set('v.accordian1', false);
            component.set('v.accordian3', false);
            component.set('v.accordian2', false);            
            var elem = component.find('test4');
            var elem2 = component.find('test1');
            var elem3 = component.find('test2');
            var elem4 = component.find('test3');            
            $A.util.removeClass(elem2, 'test');
            $A.util.removeClass(elem3, 'test');
            $A.util.removeClass(elem4, 'test');
            $A.util.removeClass(elem, 'test4');
            $A.util.addClass(elem, 'test');
        }
    },    
    tabClose1 :function(component, event, helper){
        if (event.keyCode === 13) {
            component.set('v.accordian1', false);
            var elem = component.find('test1');
            $A.util.removeClass(elem, 'test');
        }
    },
    tabClose2:function(component, event, helper){
        if (event.keyCode === 13) {
            component.set('v.accordian2', false);
            var elem = component.find('test2');
            $A.util.removeClass(elem, 'test');
        }
    },
    tabClose3:function(component, event, helper){
        if (event.keyCode === 13) {
            component.set('v.accordian3', false);            
            var elem = component.find('test3');
            $A.util.removeClass(elem, 'test');
        }
    },
    tabClose4:function(component, event, helper){
        if (event.keyCode === 13) {
            component.set('v.accordian4', false);            
            var elem = component.find('test4');
            $A.util.removeClass(elem, 'test');
        }
    },
    mobProfile1 :function(component, event, helper){
        component.set('v.myProfile', true); 
    },
    cmobProfile1 :function(component, event, helper){
        component.set('v.myProfile', false); 
    },
  	
    logout: function(component, event, helper){
        
        helper.logout();
  }
})