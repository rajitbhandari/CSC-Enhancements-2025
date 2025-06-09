import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CscTileMenu extends NavigationMixin(LightningElement) {
    cscButton(event){
        window.open(window.location.href.substring(0,
            window.location.href.indexOf("/s/") + 3) +
            "about-the-customer-service-center","_blank");
    }
    async discussionBoard(event){
        event.preventDefault();
        // Check login status by attempting to get the user Id from the session
        let isLoggedIn = false;
        try {
            // This will throw if not logged in
            const result = await fetch('/services/data/v59.0/chatter/users/me', { credentials: 'same-origin' });
            if (result.ok) {
                isLoggedIn = true;
            }
        } catch (e) {
            isLoggedIn = false;
        }
        if (isLoggedIn) {
            window.open(window.location.href.substring(0,
                window.location.href.indexOf("/s/") + 3) +
                "discussion-board", "_blank");
        } else {
            // Redirect to login page
            window.location.href = '/s/login';
        }
    }
    contactSupport(event){
        window.open(window.location.href.substring(0,
            window.location.href.indexOf("/s/") + 3) +
            "contactsupport","_blank");
    }
}