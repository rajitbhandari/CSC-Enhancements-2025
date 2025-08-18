import { NavigationMixin } from 'lightning/navigation';
import { LightningElement, track, wire } from 'lwc';
import searchCases from '@salesforce/apex/MyActivityController.searchCases';

export default class MyActivityLwc extends NavigationMixin(LightningElement) {
    @track searchKey = '';
    @track caseWrappers = [];
    @track showModal = false;
    @track selectedCase = null;
    @track selectedComments = [];
    @track currentPage = 1;
    @track showOnlyWithComments = false;
    pageSize = 3;

    @wire(searchCases, { searchKey: '$searchKey' })
    wiredCases({ error, data }) {
        if (data) {
        // Add statusClass to each wrapper
        this.caseWrappers = data.map(w => ({
            ...w,
            statusClass: w.caseRecord.Status === 'Closed' ? 'status-closed' : 'status-open'
        }));
        this.currentPage = 1;
    } else if (error) {
        this.caseWrappers = [];
    }
    }

    handleToggle(event) {
        this.showOnlyWithComments = event.target.checked;
        this.currentPage = 1;
    }

    get filteredCases() {
        if (this.showOnlyWithComments) {
            return this.caseWrappers.filter(w => w.comments && w.comments.length > 0);
        }
        return this.caseWrappers;
    }

    get pagedCases() {
        const start = (this.currentPage - 1) * this.pageSize;
        return this.filteredCases.slice(start, start + this.pageSize);
    }

    get hasNext() {
        return this.filteredCases.length > this.currentPage * this.pageSize;
    }

    get hasPrev() {
        return this.currentPage > 1;
    }

    handleNext() {
        if (this.hasNext) {
            this.currentPage++;
        }
    }

    handlePrev() {
        if (this.hasPrev) {
            this.currentPage--;
        }
    }

    handleSearch(event) {
        this.searchKey = event.target.value;
        this.currentPage = 1;
    }

    closeModal() {
        this.showModal = false;
        this.selectedCase = null;
        this.selectedComments = [];
    }

    updateRequest(event) {
        const caseId = event.target.dataset.id;
        // Navigate to the Case record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseId,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
    }

    get formattedDateOpened() {
        return this.selectedCase && this.selectedCase.CreatedDate
            ? this.selectedCase.CreatedDate.split('T')[0]
            : '';
    }
    get formattedLastModified() {
        return this.selectedCase && this.selectedCase.LastModifiedDate
            ? this.selectedCase.LastModifiedDate.split('T')[0]
            : '';
    }
    get formattedSubmittedOn() {
        return this.selectedCase && this.selectedCase.CreatedDate
            ? this.selectedCase.CreatedDate.split('T')[0]
            : '';
    }
}