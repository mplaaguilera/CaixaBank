import { LightningElement, api, wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


import getInterlocutionGroup from '@salesforce/apex/AV_InterlocutionGroupDetails_Controller.getInterlocutionGroup';

export default class Av_interlocutionGroupDetails extends NavigationMixin(LightningElement) {

    @api recordId;
    membersNumber;
    interlocutor;
    @track memberList = [];
    result;
    @track showDetail = true;


    @wire(getInterlocutionGroup, {recordId: '$recordId'})
	wiredGetRecords({ error, data }){

        if(data != null){
            this.result = true;
            data.forEach(member =>{
                if(member.AV_IsInterlocutor__c){
                    this.interlocutor = {Id:member.AV_Numper__c,Name:member.AV_Numper__r.Name};
                }
                this.memberList.push({Id:member.AV_Numper__c,name:member.AV_Numper__r.Name});
            })
            this.membersNumber = this.memberList.length;
        }
        if(error){
            console.log(error);
        }

    }

    redirectToClient(event){
        console.log('eri redirect');
        console.log(event.target.name);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                objectApiName:'user',
                recordId:event.target.name,
                actionName:'view'
            }
    
        })
    }

	toggleShow() {
		if(this.showDetail === true){
            this.showDetail = false;
        }else{
            this.showDetail = true;
        }
	}

}