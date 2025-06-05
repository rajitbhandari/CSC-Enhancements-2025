import { LightningElement,api,wire,track } from 'lwc';

import keyResourceConfig from '@salesforce/apex/KeyResourceController.getKeyResourceConfig';

export default class KeyResources extends LightningElement {
    
    @api title;
    @track resourceData =[];
    
    connectedCallback() {
        console.log('inside connected callback');
        
        keyResourceConfig()
            .then(result=>{
                //console.log('result: '+ JSON.stringify(result));
                this.resourceData = result;
                //for(var key in result){        
                //    this.resourceData.push({value:result[key], key:key});
                //} 
                console.log(JSON.stringify(this.resourceData));
            })
            .catch(error=>{
                console.log('An Error has been occured while submitting the request, please try again or contact salesforce administrator.');
                console.log(error);
            }
            );
        }
        
}