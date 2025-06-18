import { LightningElement, api, track } from 'lwc';
import getUpcomingEvents from '@salesforce/apex/CSC_UpcomingEventController.getUpcomingEvents';

export default class CscUpcomingEvents extends LightningElement {
    @api noOfWeeksBefore = 30;
    @api noOfWeeksAfter = 30;
    @api showSearchBar = false; // default to false
    @api showNextUpcomingOnly;
    @track events = [];
    @track error;
    @track startDate;
    @track endDate;
    @track subjectFilter = '';
    @track showModal = false;
    @track selectedEvent = {};

    connectedCallback() {
        // If showNextUpcomingOnly is true, always hide the search bar
        if (this.showNextUpcomingOnly) {
            this.showSearchBar = false;
        }
        this.setDateRange();
        this.fetchEvents();
    }

    setDateRange() {
        const today = new Date();
        const start = new Date(today);
        const end = new Date(today);
        start.setDate(start.getDate() - Number(this.noOfWeeksBefore) * 7);
        end.setDate(end.getDate() + Number(this.noOfWeeksAfter) * 7);
        // Always set time to 00:00:00 for start and 23:59:59 for end to cover full days
        start.setHours(0,0,0,0);
        end.setHours(23,59,59,999);
        this.startDate = start.toISOString();
        this.endDate = end.toISOString();
    }

    fetchEvents() {
        const subjectParam = this.subjectFilter && this.subjectFilter.trim() !== '' ? this.subjectFilter : undefined;
        console.log('DEBUG: Calling getUpcomingEvents with:', {
            startDate: this.startDate,
            endDate: this.endDate,
            subject: subjectParam,
            showNextUpcomingOnly: this.showNextUpcomingOnly
        });
        getUpcomingEvents({
            startDate: this.startDate,
            endDate: this.endDate,
            subject: subjectParam,
            showNextUpcomingOnly: this.showNextUpcomingOnly
        })
            .then(result => {
                let events = result.map(e => {
                    let dateOnly = '';
                    let timeOnly = '';
                    if (e.StartDateTime) {
                        const dt = new Date(e.StartDateTime);
                        // Format as MM/DD/YYYY
                        dateOnly = dt.toLocaleDateString('en-US', { month: '2-digit', day: '2-digit', year: 'numeric' });
                        // Format as hh:mm AM/PM
                        timeOnly = dt.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: true });
                    }
                    return {
                        Id: e.Id,
                        Subject: e.Subject,
                        StartDateTime: e.StartDateTime ? new Date(e.StartDateTime).toLocaleString() : '',
                        EndDateTime: e.EndDateTime ? new Date(e.EndDateTime).toLocaleString() : '',
                        StartDateOnly: dateOnly,
                        StartTimeOnly: timeOnly,
                        Description: e.Description || ''
                    };
                });
                this.events = events;
                this.error = undefined;
                // Fire event to parent with the number of events
                this.dispatchEvent(new CustomEvent('upcomingeventsloaded', { detail: this.events.length, bubbles: true, composed: true }));
            })
            .catch(error => {
                this.error = (error && error.body && error.body.message) ? error.body.message : error.message || error;
                this.events = [];
                // Fire event to parent with 0 events
                this.dispatchEvent(new CustomEvent('upcomingeventsloaded', { detail: 0, bubbles: true, composed: true }));
            });
    }

    handleStartDateChange(event) {
        const val = event.target.value;
        if (val) {
            this.startDate = val.length === 10 ? `${val}T00:00:00.000Z` : val;
        } else {
            this.startDate = '';
        }
    }

    handleEndDateChange(event) {
        const val = event.target.value;
        if (val) {
            this.endDate = val.length === 10 ? `${val}T23:59:59.999Z` : val;
        } else {
            this.endDate = '';
        }
    }

    handleSubjectChange(event) {
        this.subjectFilter = event.target.value;
        this.fetchEvents();
    }

    handleSearch() {
        this.fetchEvents();
    }

    handleEventClick(event) {
        const eventId = event.currentTarget.dataset.id;
        const found = this.events.find(e => e.Id === eventId);
        if (found) {
            this.selectedEvent = found;
            this.showModal = true;
        }
    }

    closeModal() {
        this.showModal = false;
        this.selectedEvent = {};
    }
}