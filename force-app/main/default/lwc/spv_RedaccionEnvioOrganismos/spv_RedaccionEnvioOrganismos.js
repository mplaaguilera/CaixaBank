import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import USER_ID from '@salesforce/user/Id';
import CASO_OBJECT from '@salesforce/schema/Case'; 
import ORGANISMO_FIELD from '@salesforce/schema/Case.SPV_Organismo__c';
import OWNERID_FIELD from '@salesforce/schema/Case.OwnerId';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import SUBSTATUS_FIELD from '@salesforce/schema/Case.SEG_Subestado__c';
import { RefreshEvent } from 'lightning/refresh';
import enviarDocOrganismos from '@salesforce/apex/SPV_LCMP_RedaccionEnvioOrganismos.enviarDocOrganismos';

const fields = [ORGANISMO_FIELD, OWNERID_FIELD, STATUS_FIELD, SUBSTATUS_FIELD];


export default class Spv_RedaccionEnvioOrganismos extends LightningElement {
    @api recordId;

    @track isLoading = false;
    @track isCheckedEnviarReclamante = false;
    @track isCheckedEnviarOrganismos = false;
    @track mostrarOrganismo = false;
    @track organismoCaso;
    @track desactivarBotonEnviar;
    @track status;
    @track subestado;

    @wire(getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfo;

    @wire(getRecord, {recordId: '$recordId', fields})
    casoActual({ data, error }) {
        if(data){
            this.userId = USER_ID;
            this.desactivarBotonEnviar = (data.fields?.OwnerId?.value == this.userId) ? false : true;
            this.organismoCaso = data.fields.SPV_Organismo__c.value;
            this.status = data.fields.Status.value;  
            this.subestado = data.fields.SEG_Subestado__c.value;
        }
    }
    
    handleEnviarReclamantes(event){
		this.isCheckedEnviarReclamante = event.target.checked;
	}

    handleEnviarOrganismos(event){
		this.isCheckedEnviarOrganismos = event.target.checked;
        if(this.isCheckedEnviarOrganismos == true) {
            this.mostrarOrganismo = true;
        } 
        if(this.isCheckedEnviarOrganismos == false) {
            this.mostrarOrganismo = false;
        }
	}

    enviarOrganismo(){
        if(this.isCheckedEnviarOrganismos == true && this.organismoCaso == null) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Seleccionar un valor',
                    message: 'Debe seleccionar un organismo.',
                    variant: 'warning'
                })
            );
        } else {
            this.isLoading = true;
            enviarDocOrganismos({'caseId': this.recordId, 'enviarReclamante': this.isCheckedEnviarReclamante, 'enviarOrganismos': this.isCheckedEnviarOrganismos, 'organismo': this.organismoCaso, 'estado': this.status, 'subestado': this.subestado}).then(()=>{
                this.isLoading = false;
                this.refreshView();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Envío realizado',
                        message:  "Se ha realizado el envío de la documentación a los organismos correspondientes.",
                        variant: 'success'
                    }),
                );
            }).catch(error=>{
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: JSON.stringify(error),
                        variant: 'error'
                    }),);
            });
        }
    }

    refreshView() {
        this.dispatchEvent(new RefreshEvent());
    }
}