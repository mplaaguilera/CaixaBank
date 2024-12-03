import { LightningElement, api,wire }   from 'lwc';
import { NavigationMixin }              from 'lightning/navigation';
import getName                          from '@salesforce/apex/AV_Header_Controller.getAccountInfo';
import NEWOPPREPORT 	                from '@salesforce/customPermission/AV_ReportClienteCP';

import { CurrentPageReference } from "lightning/navigation";


export default class av_ReportOpp extends NavigationMixin(LightningElement){
    @api recordId;
    @api objectApiName;
    isExecuting = false;    
    recordType;
    name;
    isIntouch;
    isExecuting = false;  
    nameRecord;
    account;
    @wire(CurrentPageReference)
    wirePageRef(data){
        if(data){
            this.recordId = data.attributes.recordId;
            getName({recordId:this.recordId})
                .then(data =>{
                    if (data) {
                        this.name = data[0];
                        this.recordType = data[1];
                        this.isIntouch = data[2];
                        this.nameRecord = (this.objectApiName == 'Account') ? data[0] : data[3];
                        this.account = data[4];
                    } else if (error) {
                        console.log(error);
                    }
                }).catch(error => {
                    console.log(error)
                })
        }
    }

    @api async invoke() {
        if (this.isExecuting) {
            return;
        }  
        let tabToGo = (NEWOPPREPORT) ? 'AV_ReportClientFromOppo' : 'AV_ReportOpportunityParentTab';
        this[NavigationMixin.Navigate]({ 
            type: 'standard__navItemPage',
            attributes: {
                //Name of any CustomTab. Visualforce tabs, web tabs, Lightning Pages, and Lightning Component tabs
                apiName: tabToGo
            },state: {
                c__recId:this.recordId,
				c__id:this.name,
				c__rt:this.recordType,
				c__intouch:this.isIntouch,
				c__account:this.account,
                c__objectname:this.objectApiName
			}
        });
        this.isExecuting = true;
        await this.sleep(1000);
        this.isExecuting = false;
    }  sleep(ms) {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }
}