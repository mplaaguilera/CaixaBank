import { LightningElement, api,wire }   from 'lwc';
import { NavigationMixin }              from 'lightning/navigation';
import getName                          from '@salesforce/apex/AV_Header_Controller.getAccountInfo';
import oldReportPS 	                from '@salesforce/customPermission/AV_OldReports';

import { CurrentPageReference }         from "lightning/navigation";


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

    @api async invoke() {
        if (this.isExecuting) {
            return;
        }  
        try{
        const data = await getName({recordId:this.recordId});
        if (data) {
            this.name = data.accountName;
            this.recordType = data.rtDevName;
            this.isIntouch = data.isIntouch;
            this.nameRecord = (this.objectApiName == 'Account') ? data.accountName : data.nameRecord;
            this.account = data.accountId;
            }else{
                throw new Error('No data available');
            }    
        } catch(error) {
            console.log(error);
            return;
        }
        
        let tabToGo = (oldReportPS) ? 'AV_ReportOpportunityParentTab' : 'AV_ReportClientFromOppo';
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