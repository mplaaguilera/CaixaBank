import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import functionRechazar from '@salesforce/apex/SAC_LCMP_RechazarReclamacionMasiva.rechazarCasos';
import functionDescartar from '@salesforce/apex/SAC_LCMP_RechazarReclamacionMasiva.descartarCasos';
import CASO_OBJECT from '@salesforce/schema/Case';
import MOTIVODERECHAZO_FIELD from '@salesforce/schema/Case.SAC_MotivoRechazo__c';
import MOTIVODEDESCARTE_FIELD from '@salesforce/schema/Case.SAC_MotivoDescarte__c';

export default class sac_RechazarReclamacionMasiva extends LightningElement {
    @track motivo;
    @api casos=[];
    @track otros = false;
    @api isLoading = false;
    showbutton;
    @track valueMotivo = '';
    @track isModalOpenRechazar = true;
    @api tipoCaso;
    esReclamacion = false;
    esConsulta = false;
    
    @wire (getObjectInfo, {objectApiName: CASO_OBJECT})
    caseInfo;

    @wire(getPicklistValues, { recordTypeId: '$caseInfo.data.defaultRecordTypeId', fieldApiName: MOTIVODERECHAZO_FIELD })
    getMotivoValues;

    @wire(getPicklistValues, { recordTypeId: '$caseInfo.data.defaultRecordTypeId', fieldApiName: MOTIVODEDESCARTE_FIELD })
    getDescarteValues;

    handleChange(event) {
        this.valueMotivo = event.detail.value;
        if(this.valueMotivo == 'Otros' || this.valueMotivo == 'SAC_Otros'){
            this.otros = true;
        }else{
            this.otros = false;
        }
    }
    rechazarClick (event) {
        if(this.valueMotivo != ''){
            this.isLoading = true;
            // En caso de que el motivo de rechazo sea "otros" se debe completar el comentario
            if(this.otros) {
                var inp = this.template.querySelector("lightning-textarea[data-my-id=textoParaChatterRechazar]");
                var comentario = inp.value;  
                if(comentario != '') { 
                    var mensajeChatter = 'Se ha rechazado el caso por el motivo: ' + this.valueMotivo + '\nObservación: ' + comentario;
                }
            }
            functionRechazar({motivo: this.valueMotivo, recordId: this.recordId, mensaje: mensajeChatter})
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
                                        message: JSON.stringify(error.body.pageErrors[0].message),
                                        variant: 'error'
                                    });
                                    this.dispatchEvent(evt); 
                                    window.history.back();
                                }
                            );
        }
    }

    descartarClick (event) {
        if(this.valueMotivo != ''){
            this.isLoading = true;
            // En caso de que el motivo de descarte sea "otros" se debe completar el comentario
            if(this.otros) {
                var inp = this.template.querySelector("lightning-textarea[data-my-id=textoParaChatterRechazar]");
                var comentario = inp.value;  
                if(comentario != '') { 
                    var mensajeChatter = 'Se ha descartado el caso por el motivo: ' + this.valueMotivo + '\nObservación: ' + comentario;
                }
            }
            functionDescartar({motivo: this.valueMotivo, recordId: this.recordId, mensaje: mensajeChatter})
                            .then((data) => {  
                                    this.isLoading = false;  
                                    getRecordNotifyChange([{recordId: this.recordId}]);
                                    if (data == 'OK'){
                                        const evt = new ShowToastEvent({
                                            title: 'Éxito',
                                            message: 'Las consultas han sido descartadas correctamente',
                                            variant: 'success'
                                        });
                                        this.dispatchEvent(evt); 
                                        window.history.back();
                                    } else if (data == 'KO'){
                                        const evt = new ShowToastEvent({
                                            title: 'Error',
                                            message: 'Error al descartar, compruebe que pertenece al grupo de trabajo de las consultas y que estén en el estado correcto',
                                            variant: 'error'
                                        });
                                        this.dispatchEvent(evt);
                                        window.history.back();  
                                    }  else if (data == 'KO ORIGEN'){
                                        const evt = new ShowToastEvent({
                                            title: 'Error',
                                            message: 'Error al descartar, para gestionar la consulta primero debe de indicar el origen de la misma.',
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
            if(this.tipoCaso == 'SAC_Reclamacion'){
                this.esReclamacion = true;
            }else if(this.tipoCaso == 'SAC_Consulta'){
                this.esConsulta = true;
            }
        }
    }


    closeModal(event) {
        window.history.back();
    }

}