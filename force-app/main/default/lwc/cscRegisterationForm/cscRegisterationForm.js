import { LightningElement, track, wire, api } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import TYPE_FIELD from '@salesforce/schema/Account.Type';
import selfRegister from '@salesforce/apex/LightningSelfRegisterController.selfRegister';
import lookup from '@salesforce/apex/LightningSelfRegisterController.lookup';
import getAccountRec from '@salesforce/apex/LightningSelfRegisterController.getAccountRec';


export default class CscRegisterationForm extends LightningElement {
    @track step = 1;
    @track firstName = '';
    @track lastName = '';

    get lastNameCapitalized() {
        if (!this.lastName) return '';
        return this.lastName.charAt(0).toUpperCase() + this.lastName.slice(1);
    }
    @track email = '';
    @track password = '';
    @track confirmPassword = '';
    @track errorMessage = '';
    @track mailingList = false;
    @track cdcRecognized = '';
    @track organizationName = '';
    @track organizationType = '';
    @track zipCode = '';
    @track orgCdcRecognized = '';
    @track organizationTypeOptions = [];
    @track organizationCode = '';
    @track otherOrgType = '';
    @api regConfirmUrl; 
    showBox = false;

    /**/ 
    accountSearchTerm = '';
    accountResults = [];
    showAccountResults = false;
    selectedAccountId = '';
    selectedAccountName = '';
    noAccountResults = false;
    showManualEntry = false; // <-- Track manual entry mode

    toggleBox() {
        this.showBox = true;
    }

    handleSubscribeClick() {
        window.location.href = 'https://tools.cdc.gov/campaignproxyservice/subscriptions.aspx';
    }

    handlemanageSubscribeClick() {
        window.location.href = 'https://tools.cdc.gov/campaignproxyservice/subscriptions.aspx?topic_id=USCDC_2110';

    }
    
    hideModalBox() {
       
        this.showBox = false;
    }

handleAccountSearchChange(event) {
    this.accountSearchTerm = event.target.value;
    if (this.accountSearchTerm && this.accountSearchTerm.length > 1) {
        lookup({
            searchString: this.accountSearchTerm,
            sObjectAPIName: 'Account',
            whereClause: '', // or your filter
            rawSOQL: '',
            context: ''
        })
        .then(results => {
            this.accountResults = results;
            // Add "Add New Organization" option at the end
            this.accountResults.push({
                SObjectId: 'add_new_org',
                SObjectLabel: '+ Add New Organization'
            });
            this.showAccountResults = true;
            this.noAccountResults = results.length === 0;
        })
        .catch(() => {
            this.accountResults = [];
            this.showAccountResults = false;
            this.noAccountResults = false;
        });
    } else {
        this.accountResults = [];
        this.showAccountResults = false;
        this.noAccountResults = false;
    }
}

    handleAccountSelect(event) {
        const selectedId = event.currentTarget.dataset.id;
        const selectedName = event.currentTarget.dataset.name;

        if (selectedId === 'add_new_org') {
            this.selectedAccountId = '';
            this.selectedAccountName = selectedName; // Use the name of the new organization
            this.accountSearchTerm = selectedName; // Use the name of the new organization
            this.showAccountResults = false;
            this.showManualEntry = true; // Show manual entry field
            // Clear fields for manual entry
            //this.organizationName = '';
            this.organizationType = '';
            this.zipCode = '';
            this.orgCdcRecognized = '';
            this.organizationCode = '';
            this.otherOrgType = '';
            this.organizationTypeReadOnly = false;
            this.otherOrgTypeReadOnly = false;
            this.zipCodeReadOnly = false;
        } else {
            this.selectedAccountId = selectedId;
            this.selectedAccountName = selectedName;
            this.accountSearchTerm = selectedName;
            this.showAccountResults = false;
            this.showManualEntry = false;
            getAccountRec({ accRecId: this.selectedAccountId })
                .then(account => {
                    if (account.Type) this.organizationType = account.Type;
                    if (account.Other_Type__c) this.otherOrgType = account.Other_Type__c;
                    if (account.ShippingPostalCode) this.zipCode = account.ShippingPostalCode;
                    if (account.Is_this_Organization_CDC_Recognized__c) this.orgCdcRecognized = account.Is_this_Organization_CDC_Recognized__c;
                    if (account.Org_Code__c) this.organizationCode = account.Org_Code__c;
                    this.organizationTypeReadOnly = true;
                    this.otherOrgTypeReadOnly = true;
                    this.zipCodeReadOnly = true;
                })
                .catch(() => {
                    this.organizationTypeReadOnly = false;
                    this.otherOrgTypeReadOnly = false;
                    this.zipCodeReadOnly = false;
                });
        }
    }
   /* */

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    accountObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$accountObjectInfo.data.defaultRecordTypeId',
        fieldApiName: TYPE_FIELD
    })
    typePicklistValues({ data, error }) {
        if (data) {
            this.organizationTypeOptions = data.values.map(option => ({
                label: option.label,
                value: option.value
            }));
        } else if (error) {
            this.organizationTypeOptions = [];
        }
    }

    get isStepOne() {
        return this.step === 1;
    }
    get isStepTwo() {
        return this.step === 2;
    }
    get isStepThree() {
        return this.step === 3;
    }
    get isStepFour() {
        return this.step === 4;
    }

    get cdcOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];
    }

    get showOrgCode() {
        return this.orgCdcRecognized === 'Yes';
    }
    get showOtherOrgType() {
    return this.organizationType === 'Other';
}

    handleInputChange(event) {
        const { name, type, checked, value } = event.target;
        if (type === 'checkbox') {
            this[name] = checked;
        } else {
            this[name] = value;
        }
    }
    handleZipCodeChange(event) {
        const value = event.target.value;
        // Allow only digits
        if (/^\d*$/.test(value)) {
            this.zipCode = value;
            this.errorMessage = '';
        } else {
            this.errorMessage = 'Please enter numbers only for Zip Code.';
        }
    }

    handleNext() 
    {
        if (this.step === 1) {
            if (
                !this.firstName ||
                !this.lastName ||
                !this.email ||
                !this.password ||
                !this.confirmPassword
            ) {
                this.errorMessage = 'Please fill in all required fields.';
                return;
            }
            // Validate first name and last name: only alphabets
            if (!/^[A-Za-z]+$/.test(this.firstName)) {
                this.errorMessage = 'First Name should contain only alphabets.';
                return;
            }
            if (!/^[A-Za-z]+$/.test(this.lastName)) {
                this.errorMessage = 'Last Name should contain only alphabets.';
                return;
            }
            if (this.password !== this.confirmPassword) {
                this.errorMessage = 'Password and Confirm Password do not match.';
                return;
            }
            // Password validation: at least 8 chars, at least one letter and one number
            if (
                this.password.length < 8 ||
                !/[A-Za-z]/.test(this.password) ||
                !/[0-9]/.test(this.password)
            ) {
                this.errorMessage = 'Password must be at least 8 characters and contain both letters and numbers.';
                return;
            }
            this.errorMessage = '';
            this.step = 2;
        }
    }

    handleNextStepTwo() {
        if (!this.cdcRecognized) {
            this.errorMessage = 'Please select Yes or No.';
            return;
        }
        this.errorMessage = '';
        this.step = 3;
    }

    handleBack() {
        this.step = 1;
    }

    handleBackStepThree() {
        this.step = 2;
    }

    // Add event-driven reCAPTCHA logic
    handleRecaptchaVerified = (event) => {
        console.debug('grecaptchaVerified event received:', event);
        // Support both .token and .response for compatibility with global handler
        const token = event.detail.token || event.detail.response;
        console.debug('token', token);
        this.recaptchaToken = token;
        if (this.recaptchaToken) {
            console.debug('reCAPTCHA token received:', this.recaptchaToken);
        } else {
            console.error('No reCAPTCHA token received!');
        }
        // After receiving the token, proceed with registration
        this.doSelfRegister();
    }

    connectedCallback() {
        document.addEventListener("grecaptchaVerified", this.handleRecaptchaVerified);
    }
    disconnectedCallback() {
        document.removeEventListener("grecaptchaVerified", this.handleRecaptchaVerified);
    }

    handleRegister() {
        const missingFields = [];
        if (!this.selectedAccountId && !this.organizationName) missingFields.push('Organization');
        if (!this.zipCode) missingFields.push('Zip Code');
        if (this.orgCdcRecognized === 'Yes') {
            if (!this.organizationCode) {
                missingFields.push('Organization Code');
            } else {
                // Validate organization code: must be numeric and 6 digits
                if (!/^\d{6}$/.test(this.organizationCode)) {
                    this.errorMessage = 'Organization Code must be a 6-digit number.';
                    return;
                }
            }
        }
        if (this.organizationType === 'Other' && !this.otherOrgType) missingFields.push('Other Organization Type');
        if (missingFields.length > 0) {
            this.errorMessage = `Please complete all organization details. (${missingFields.join(', ')})`;
            return;
        }
        this.errorMessage = '';
        // Dispatch event to trigger reCAPTCHA globally
        document.dispatchEvent(new CustomEvent("grecaptchaExecute", { detail: { action: "register" } }));
    }

    doSelfRegister() {
        const userDetails = {
            FirstName: this.firstName,
            LastName: this.lastName,
            Email: this.email,
            CompanyName: this.organizationName,
            CDC_User_Profile_Type__c: this.organizationType,
            Zip_Code__c: this.zipCode,
            CDC_Recognized_org__c: this.orgCdcRecognized,
            Org_Code__c: this.organizationCode
        };
        // ++Debug output for userDetails and selfRegister params
        console.log('User Details:', JSON.stringify(userDetails));
        console.log('AccountId being passed:', this.selectedAccountId);
        console.log('SelfRegister Params:', JSON.stringify({
            userDetails: userDetails,
            otherOrgType: this.otherOrgType,
            password: this.password,
            confirmPassword: this.confirmPassword,
            accountId: this.selectedAccountId,
            regConfirmUrl: this.regConfirmUrl,
            extraFields: '',
            startUrl: '',
            includePassword: true,
            recaptchaResponse: this.recaptchaToken
        })); // -- Debug output for userDetails and selfRegister params
        selfRegister({
            userDetails: userDetails,
            otherOrgType: this.otherOrgType,
            password: this.password,
            confirmPassword: this.confirmPassword,
            accountId: this.selectedAccountId,
            regConfirmUrl: this.regConfirmUrl,
            extraFields: '',
            startUrl: '',
            includePassword: true,
            recaptchaResponse: this.recaptchaToken
        })
        .then(result => {
            if (result && result.startsWith('Invalid')) {
                this.errorMessage = result;
            } else {
                this.step = 4;
            }
        })
        .catch(error => {
            this.errorMessage = error.body ? error.body.message : error.message;
        });
    }

    goToHome() {
        window.location.href = '/'; // Change this to your community home URL if needed
    }

    subscribeCscEmails() 
    {
        // Opens the CDC subscription page in a new tab
        window.open('https://tools.cdc.gov/campaignproxyservice/subscriptions.aspx', '_blank');
    }


    cscButton(event){
        window.open(window.location.href.substring(0,
            window.location.href.indexOf("/s/") + 3) +
            "about-the-customer-service-center","_blank");
    }

    discussionBoard(event){
        window.open(window.location.href.substring(0,
            window.location.href.indexOf("/s/") + 3) +
            "discussion-board", "_blank");
    }

    contactSupport(event){
        window.open(window.location.href.substring(0,
            window.location.href.indexOf("/s/") + 3) +
            "contactsupport","_blank");
    }
}