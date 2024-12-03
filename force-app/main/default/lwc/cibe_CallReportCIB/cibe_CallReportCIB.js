import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';


import FIELD_1 from '@salesforce/schema/CBK_Activity_Extension__c.CIBE_ClienteNuevo__c';
import FIELD_2 from '@salesforce/schema/CBK_Activity_Extension__c.CIBE_ClienteEspana__c';
import FIELD_3 from '@salesforce/schema/CBK_Activity_Extension__c.CIBE_CategoriaAenor__c';
import FIELD_4 from '@salesforce/schema/CBK_Activity_Extension__c.CIBE_RelacionCliente__c';
import FIELD_5 from '@salesforce/schema/CBK_Activity_Extension__c.CIBE_ConclusionesGestor__c';
import FIELD_6 from '@salesforce/schema/CBK_Activity_Extension__c.CIBE_ConclusionesCliente__c';

import cancel from '@salesforce/label/c.CIBE_Cancelar';
import save from '@salesforce/label/c.CIBE_Guardar';

import getRecords from '@salesforce/apex/CIBE_callReportController.getRecords';

export default class Cibe_CallReportCIB extends LightningElement {

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
        this._wiredData = wiredData;
        const {data, error} = wiredData;
        if(data) {
            console.log(data);
            console.log(data.ev);
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