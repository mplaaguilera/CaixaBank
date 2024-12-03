import { LightningElement, track, api, wire }  from 'lwc';
import { NavigationMixin }          from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';


import gestionarEvento from '@salesforce/label/c.CIBE_GestionarEvento';
import btnCerrarEvento from '@salesforce/label/c.CIBE_CerrarEventoEInformarOporunidad';
import cerrarEvento from '@salesforce/label/c.CIBE_CerrarEventoInformarOportunidad';

import getRecords           from '@salesforce/apex/CIBE_callReportController.getRecords';

export default class cibe_EventTabs extends NavigationMixin(LightningElement) {
    
    labels = {
        gestionarEvento, 
        btnCerrarEvento,
        cerrarEvento
    };

    @api recid;
    fecha;
    @track showDetail = true;
    @track status = false;

    @track _wiredData;
    @wire(getRecords, { recordId: '$recid' })
    getEvent(wiredData){
        this._wiredData = wiredData;
        const {data, error} = wiredData;
        if(data){
            this.status = data.ev.CSBD_Evento_Estado__c;
        }else if(error) {
            console.log(error);
        }
    };

    connectedCallback() {
		this.fecha = new Date().toISOString().substring(0,10);
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
                apiName: 'CIBE_CloseEvent'
            },state: {
				c__recId: this.recid
			}
        });
        this.refresh();
        
    }

    @wire(CurrentPageReference)
	getStateParameters(currentPageReference) {
		if (currentPageReference) {
			this.recid = currentPageReference.attributes.recordId;
		}	
	}

    get isDisabled () {
        return this.status !== 'Pendiente';
    }

    refresh() {
        return refreshApex(this._wiredData); 
    }
}