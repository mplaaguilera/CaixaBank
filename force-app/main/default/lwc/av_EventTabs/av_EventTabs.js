import { LightningElement, track, api, wire }  from 'lwc';
import { NavigationMixin }          from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import isBankTeller from '@salesforce/apex/AV_AppUtilities.isBankTeller';
import oldReports from '@salesforce/customPermission/AV_OldReports';
import getName      from '@salesforce/apex/AV_Header_Controller.getAccountInfo';

export default class Av_EventTabs extends NavigationMixin(LightningElement) {

    @api recid;
    @api recordId;
    @track showDetail = true;
    @track disableBtn = false;
    @track name;
    @track recordType;
    @track isIntouch;
    @track account;
    @track eventDateTime;
    showSpinner = true;
    nameRecord;
    fecha;
    preventClick = false;
    showOldReports = oldReports;

    connectedCallback() {
		var today = new Date();
		this.fecha=today.toISOString().substring(0,10);
        this.disableTabs();
        this.getNameData();
	}

    getNameData(){
        getName({recordId:this.recordId})
            .then(data => {
                if (data) {
                    this.name = data.accountName;
                    this.recordType = data.rtDevName;
                    this.isIntouch = data.isIntouch;
                    this.nameRecord = data.nameRecord;
                    this.account = data.accountId;
                    this.showSpinner = false;

                } 
            }).catch(error => {
                console.log(error);
            })
	}

    toggleShow() {
		if (this.showDetail === true) {
            this.showDetail = false;
        } else {
            this.showDetail = true;
        }
	}

    navigateToTab() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                //Name of any CustomTab. Visualforce tabs, web tabs, Lightning Pages, and Lightning Component tabs
                apiName: 'AV_CloseEventAndNewOpp'
            },state: {
				c__recId: this.recid
			}
        });
    }

    navigateToTabVersion2() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                //Name of any CustomTab. Visualforce tabs, web tabs, Lightning Pages, and Lightning Component tabs
                apiName: 'AV_EventReportParentTab'
            },state: {
				c__recId: this.recid,
				c__id:this.name,
				c__rt:this.recordType,
				c__intouch:this.isIntouch,
				c__account:this.account
			}
        });
    }

    @wire(CurrentPageReference)
	getStateParameters(currentPageReference) {
		if (currentPageReference) {
			this.recid = currentPageReference.attributes.recordId;
		}	
	}

    disableTabs() {
		isBankTeller()
			.then((result) => {
				if (result) {
                    this.preventClick = true;}
			})
			.catch((error) => {
				console.error('Disable tabs error', JSON.stringify(error));
				this.errors = [error];
			});
	}
}