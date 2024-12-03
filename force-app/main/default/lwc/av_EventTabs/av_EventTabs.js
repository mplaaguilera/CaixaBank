import { LightningElement, track, api, wire }  from 'lwc';
import { NavigationMixin }          from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import isBankTeller from '@salesforce/apex/AV_AppUtilities.isBankTeller';
import hasCustomPermission from '@salesforce/customPermission/AV_ReportClienteCP';

export default class Av_EventTabs extends NavigationMixin(LightningElement) {

    @api recid;
    @track showDetail = true;
    @track disableBtn = false;
    fecha;
    preventClick = false;
    isCustomPermission = hasCustomPermission;

    connectedCallback() {
		var today = new Date();
		this.fecha=today.toISOString().substring(0,10);
        this.disableTabs();
	}

    btnDisabled() {
        
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
				c__recId: this.recid
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