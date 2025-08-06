import showCmp from '@salesforce/apex/AV_InterlocutionGroup_Controller.retrieveGroupsList';
import countOppTaskEv from '@salesforce/apex/AV_InterlocutionGroup_Controller.countRecords'

import { LightningElement,track,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord} from 'lightning/uiRecordApi';

import NAME from '@salesforce/schema/Account.Name';

export default class Av_grupoInterLocutorFlexi extends NavigationMixin(LightningElement) {

@track interlocExist = false;
@track title = "   Grupo de interlocución";
@api recordId;
@api objectApiName;
@track countOppos;
@track countEvents;
@track countTasks;
@track mainInterloc;
@track members = [];
@track membersCount;
@track groupId;
recordName;

	
@wire(getRecord , { recordId:'$recordId', fields:[NAME]})
wiredAccount({data}){
    if(data){
        this.recordName = data.fields.Name.value;
    }
}

connectedCallback(){
    this.renderCmp();
}




renderCmp(){
    showCmp({clientId:this.recordId})
    .then(list => {
        this.interlocExist = list.length > 0;
        if(this.interlocExist){
            let groupName = list[0].Name;
            list.forEach(client =>{
                if(client.AV_IsInterlocutor__c){
                    this.mainInterloc = {Id:client.AV_Numper__c,Name:client.AV_Numper__r.Name};
                    this.groupId = client.Id;
                }
                    if(client.AV_Numper__c == this.recordId){
                        this.recordName = client.AV_Numper__r.Name;
                    }else{
                        this.members.push({id:client.AV_Numper__c,name:client.AV_Numper__r.Name});
                    }
                })
            this.members.unshift({id:this.recordId,name:this.recordName});
            this.membersCount = list.length;
            countOppTaskEv({grpName:groupName})
                .then(records => {
                    this.countOppos = records.oppos;
                    this.countEvents = records.events;
                    this.countTasks = records.tasks;
                }).catch(error => {
                    console.log(error)
                })
        }
    }).catch(error => {
        console.log(error);
    })
}
getUserLink(event){
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            objectApiName:'user',
            recordId:event.target.name,
            actionName:'view'
        }

    })
}

getGroupFlexi(event){
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            objectApiName:'AV_GrupoInterlocucion__c',
            recordId:event.target.name,
            actionName:'view'
        }

    })

}



}