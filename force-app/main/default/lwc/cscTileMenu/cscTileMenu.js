import { LightningElement } from 'lwc';

export default class CscTileMenu extends LightningElement {
    cscButton(event){
        window.open(window.location.href.substring(0,
            window.location.href.indexOf("/s/") + 3) +
            "about-the-customer-service-center","_blank");
        /*window.location.assign(
        window.location.href.substring(0,
                                      window.location.href.indexOf("/s/") + 3) +
                                      "about-the-customer-service-center");*/
       }
       discussionBoard(event){
        window.open(window.location.href.substring(0,
                                      window.location.href.indexOf("/s/") + 3) +
                                      "discussion-board", "_blank");
        /*window.location.assign(
        window.location.href.substring(0,
                                      window.location.href.indexOf("/s/") + 3) +
                                      "discussion-board");*/
       }
       contactSupport(event){
        window.open(window.location.href.substring(0,
            window.location.href.indexOf("/s/") + 3) +
            "contactsupport","_blank");
        /*window.location.assign(
        window.location.href.substring(0,
                                      window.location.href.indexOf("/s/") + 3) +
                                      "contactsupport");*/
       }
}