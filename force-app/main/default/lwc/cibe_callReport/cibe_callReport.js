import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent }   from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';


import getRecords from '@salesforce/apex/CIBE_callReportController.getRecords';

//labels
import cancel from '@salesforce/label/c.CIBE_Cancelar';
import save from '@salesforce/label/c.CIBE_Guardar';

import FIELD_1 from '@salesforce/schema/CBK_Activity_Extension__c.CIBE_ClienteNuevo__c';
import FIELD_2 from '@salesforce/schema/CBK_Activity_Extension__c.CIBE_ClienteEspana__c';
import FIELD_3 from '@salesforce/schema/CBK_Activity_Extension__c.CIBE_InformacionComplementariaGestor__c';
import FIELD_4 from '@salesforce/schema/CBK_Activity_Extension__c.CIBE_ConclusionesGestor__c';
import FIELD_5 from '@salesforce/schema/CBK_Activity_Extension__c.CIBE_ConclusionesCliente__c';
import FIELD_6 from '@salesforce/schema/CBK_Activity_Extension__c.CIBE_ProximosPasosCliente__c';

export default class Cibe_callReport extends LightningElement  {
    
    fields1 = [ FIELD_1, FIELD_2 ];
    fields2 = [ FIELD_3, FIELD_4, FIELD_5, FIELD_6 ];

    labels = {
        save,
        cancel
    };
    
    @api recordId;

    @track activityExtensionId;
    @track status;
    
    @track editMode = false;
    @track showSpinner = false;

    @track _wiredData;
    @wire(getRecords, { recordId : '$recordId' })
	wiredgetRecords(wiredData) {
        const {data, error} = wiredData;
        this._wiredData = wiredData;
        if(data) {
            if(data.ev) {
                this.status = data.ev.CSBD_Evento_Estado__c;
            }
            if(data.activityExtension) {
                this.activityExtensionId = data.activityExtension.Id;
            }
        }else if(error){
            console.log(error);
        }
    }

    get isEditable() {
        return this.status && this.status === 'Pendiente';
    }
    
    handleEnableEdit() {
        this.editMode = true;
        refreshApex( this._wiredData);
    }

    handleSubmit() {
        this.showSpinner = true;

    }

    handleSuccess() {
        this.editMode = false;
        this.showSpinner = false;
    }

    handleError(event) {
        this.showSpinner = false;
    }
    
    handleCancel(){
        this.editMode = false;
    }

}