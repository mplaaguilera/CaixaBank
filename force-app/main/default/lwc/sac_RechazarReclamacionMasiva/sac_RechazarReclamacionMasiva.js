import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import functionRechazar from '@salesforce/apex/SAC_LCMP_RechazarReclamacionMasiva.rechazarCasos';
import CASO_OBJECT from '@salesforce/schema/Case';
import MOTIVODERECHAZO_FIELD from '@salesforce/schema/Case.SAC_MotivoRechazo__c';

export default class sac_RechazarReclamacionMasiva extends LightningElement {
    @track motivo;
    @api casos=[];
    @track otros = false;
    @api isLoading = false;
    showbutton;
    @track valueMotivoRechazo = '';
    @track isModalOpenRechazar = true;
    
    @wire (getObjectInfo, {objectApiName: CASO_OBJECT})
    caseInfo;

    @wire(getPicklistValues, { recordTypeId: '$caseInfo.data.defaultRecordTypeId', fieldApiName: MOTIVODERECHAZO_FIELD })
    getMotivoValues;

    handleChange(event) {
        this.valueMotivoRechazo = event.detail.value;
        if(this.valueMotivoRechazo == 'Otros'){
            this.otros = true;
        }else{
            this.otros = false;
        }
    }

    rechazarClick (event) {
        if(this.valueMotivoRechazo != ''){
            this.isLoading = true;
            // En caso de que el motivo de rechazo sea "otros" se debe completar el comentario
            if(this.otros) {
                var inp = this.template.querySelector("lightning-textarea[data-my-id=textoParaChatterRechazar]");
                var comentario = inp.value;  
                if(comentario != '') { 
                    var mensajeChatter = 'Se ha rechazado el caso por el motivo: ' + this.valueMotivoRechazo + '\nObservación: ' + comentario;
                }
            }
            functionRechazar({motivo: this.valueMotivoRechazo, recordId: this.recordId, mensaje: mensajeChatter})
                            .then((data) => {  
                                    this.isLoading = false;  
                                    getRecordNotifyChange([{recordId: this.recordId}]);
                                    if (data == 'OK'){
                                        const evt = new ShowToastEvent({
                                            title: 'Éxito',
                                            message: 'Las reclamaciones han sido rechazadas correctamente',
                                            variant: 'success'
                                        });
                                        this.dispatchEvent(evt); 
                                        window.history.back();
                                    } else if (data == 'KO'){
                                        const evt = new ShowToastEvent({
                                            title: 'Error',
                                            message: 'Error al rechazar, compruebe que pertenece al grupo de trabajo de las reclamaciones y que estén en el estado correcto',
                                            variant: 'error'
                                        });
                                        this.dispatchEvent(evt);
                                        window.history.back();  
                                    } else {
                                        const evt = new ShowToastEvent({
                                            title: 'Error',
                                            message: JSON.stringify(data),
                                            variant: 'error'
                                        });
                                        this.dispatchEvent(evt); 
                                        window.history.back();
                                    } 
                                })
                                .catch(error => {  
                                    this.isLoading = false;   
                                    const evt = new ShowToastEvent({
                                        title: 'Error',
                                        message: JSON.stringify(error),
                                        variant: 'error'
                                    });
                                    this.dispatchEvent(evt); 
                                    window.history.back();
                                }
                            );
        }
    }

    connectedCallback(){
        if (this.casos.length > 0){   
            this.recordId = this.casos;
        }
    }


    closeModal(event) {
        window.history.back();
    }

}