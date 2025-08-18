import { LightningElement } from 'lwc';

export default class MycscActivity extends LightningElement {
    handleNavigation() {
        const href = window.location.href;
        const sIndex = href.indexOf('/s/');
        let siteUrl = window.location.origin;
        if (sIndex !== -1) {
            siteUrl = href.substring(0, sIndex + 3); 
        }
        window.location.href = `${siteUrl}case/Case/Default`;
    }
}