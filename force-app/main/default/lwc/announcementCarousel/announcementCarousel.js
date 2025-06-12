import { LightningElement, track } from 'lwc';

export default class AnnouncementCarousel extends LightningElement {
    @track hasUpcomingEvents = true;

    handleUpcomingEventsLoaded(event) {
        // event.detail should be the number of events from the child
        this.hasUpcomingEvents = event.detail > 0;
    }
}