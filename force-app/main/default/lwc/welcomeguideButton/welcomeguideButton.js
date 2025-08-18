import { LightningElement } from 'lwc';

export default class WelcomeguideButton extends LightningElement {
    showBox = false;

    handleNavigation() {
        window.location.href = 'https://nationaldppcsc.cdc.gov/s/article/National-DPP-Welcome-Guide-and-Video';
    }

    toggleBox() {
        this.showBox = true;
    }

    hideModalBox() {
        this.showBox = false;
    }

    handleSubscribeClick() {
        window.location.href = 'https://tools.cdc.gov/campaignproxyservice/subscriptions.aspx?topic_id=USCDC_2110';
    }
    handlemanageSubscribeClick() {
        window.location.href = 'https://tools.cdc.gov/campaignproxyservice/subscriptions.aspx?topic_id=USCDC_2110';

    }
}