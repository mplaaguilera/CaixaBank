import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class Cc_Timeline_Item extends LightningElement {
    @api msg;
    @api isexpanded;
    @track isTask=false;
    @track isCase=false;
    @track isChat=false;
    @track isMail=false;
    @track isSocial=false;
    @track isTwitter=false;

    @track inIn=false;
    @track inOut=false;

    
    urlcase;

    connectedCallback() {
        this.isIn =this.msg.Entrante;  
        this.isOut=!this.msg.Entrante;

        switch(this.msg.ActivityTimelineType) {
            case 'Case' : 
              this.isCase = true;
              this.isIn=false;
              this.isOut=false;
              break;
            case 'Chat-Agente' : 
              this.isChat = true;
              break;
            case 'Chat-Chatbot' : 
              this.isChat = true;
              break;
            case 'Email' : 
              this.isMail = true;
              break;
            case 'Twitter' : 
              this.isTwitter = true;
              break;
            case 'Other' : 
              this.isSocial = true;
              break;              
            default:
                this.isTask = true;
          }


    }

    changeState(){ 
        this.isexpanded=!this.isexpanded;
    }

    navigateToCase() {
        console.log('Ini');
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: '5006E00000A9EyZQAV',
                objectApiName: 'Case',
                actionName: 'view'
            }
        });    
        console.log('Fin');   
    }
    

}