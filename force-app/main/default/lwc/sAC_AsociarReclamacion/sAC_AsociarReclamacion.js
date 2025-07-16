import { LightningElement, wire, api, track } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSameOwnerCases from '@salesforce/apex/SAC_LCMP_GetOwnerCases.getSameOwnerCases';
import modifySameOwnerCases from '@salesforce/apex/SAC_LCMP_GetOwnerCases.modifySameOwnerCases';
import desvincular from '@salesforce/apex/SAC_LCMP_GetOwnerCases.desvincular';
import validarVincularDesvincularComplementaria from '@salesforce/apex/SAC_LCMP_GetOwnerCases.validarVincularDesvincularComplementaria';
import { NavigationMixin } from 'lightning/navigation'; 
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import esPropietario from '@salesforce/apex/SAC_LCMP_UpdateStatus.esPropietario';

const fields = [
    'Case.SAC_Naturaleza__c',
    'Case.OS_Fecha_Resolucion__c'
];

export default class SAC_AsociarReclamacion extends NavigationMixin(LightningElement) {


    @track listadoReclamaciones = [];
    @track idAVincular;
    @track record;
    @track recordType; 
    @track error;
    @track propietario; 
    @api recordId;    
    @api caseId;
    @api isLoading = false;
    
    existenDatos;
    naturaleza;
    fechaResolucion;
    @track complementariaResuelta = false;      //En caso de que sea una complementaria y ya haya sido resuelta, no se muestra activado el botón de desvincular


    /*@wire(getRecord, { recordId: '$recordId' })
    case;    */
    @wire(getRecord, {recordId: '$recordId', fields})
    actualCase({data, error}){
         if(data) {
            this.existenDatos = data;
            this.naturaleza = this.existenDatos.fields.SAC_Naturaleza__c.value;
            this.fechaResolucion = this.existenDatos.fields.OS_Fecha_Resolucion__c.value;
            if(this.naturaleza == 'SAC_007' && this.fechaResolucion != null){
                this.complementariaResuelta = true;
            }else{
                this.complementariaResuelta = false;
            }
        }     
    };



    _wiredResult;
     
    @wire(getSameOwnerCases, { idCasoDisparador: '$recordId' })
    recogerListaReclamaciones(result) {
        this._wiredResult = result;
        if (result.error) {
            if(result.error.body.message != null) {
                this.errorMsg = result.error.body.message;
            } else {
                this.errorMsg = result.error.body.pageErrors[0].message;
            }
            this.dispatchEvent(
            new ShowToastEvent({
                title: 'Fallo al obtener reclamaciones',
                message: this.errorMsg,
                variant: 'error'
            }));
        } else if (result.data) {
            let reclamaciones = result.data;

            for (var miReclamacion in reclamaciones) {                
                let reclamacion = reclamaciones[miReclamacion];
                this.listadoReclamaciones.push(reclamacion);
            } 

            this.listadoReclamaciones.sort(function(r1,r2){ 

                if (r1.reclamacionActual.CreatedDate > r2.reclamacionActual.CreatedDate){
                    return -1;
                }if(r1.reclamacionActual.CreatedDate < r2.reclamacionActual.CreatedDate){
                    return 1;
                }
                return 0;   
            });
        }
    }

    get esPropietario(){
        esPropietario({record: this.recordId})
            .then(result => {
                this.propietario = result;
            })
            .catch(error => {
                this.error = error;
            });
        return this.propietario;
    }

    updateRecordView(recordId) {
        updateRecord({fields: { Id: recordId }});
    }

    navigateToCase(evt) {

        evt.preventDefault();
        var variableAuxiliarCodigoboton = evt.currentTarget.id;
        for (var i = 0; i < variableAuxiliarCodigoboton.length - 1; i++) {
            if (variableAuxiliarCodigoboton.charAt(i) == '-') {
                this.caseId = variableAuxiliarCodigoboton.substring(0, i);
            }
        }
        evt.stopPropagation();

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": this.caseId,
                "objectApiName": "Case",
                "actionName": "view"
            }
        });

    }


    handleClick(event) {
        
        var variableAuxiliarCodigoboton = event.currentTarget.id;
        this.isLoading = true;

        for (var i = 0; i < variableAuxiliarCodigoboton.length - 1; i++) {
            if (variableAuxiliarCodigoboton.charAt(i) == '-') {
                this.idAVincular = variableAuxiliarCodigoboton.substring(0, i);
            }
        }

        validarVincularDesvincularComplementaria({idCaso: this.recordId}).then(result =>{
            if(result == true){
                //Permite vincular si no es una complementaria que ya ha sido resuelta
                modifySameOwnerCases({ idCasoVinculado: this.idAVincular, idCasoActual: this.recordId }).then(result => {
                    let mensaje;
                    let title;
                    let nombreRecord;
                    let numeroReclamacion;
        
                    for (var i = 0; i < result.length - 1; i++) {
                        if (result.charAt(i) == ';') {
                            nombreRecord = result.substring(0, i);
                            numeroReclamacion = result.substring(i+1,result.length - 1);
                        }
                    }
        
                    if(nombreRecord == 'SAC_Reclamacion'){
                        mensaje = 'Se ha actualizado el estado de la reclamación vinculada.';
                        title =  'Reclamacion vinculada';
        
                    }else if(nombreRecord == 'SAC_Consulta'){
                        mensaje = 'Se ha realizado la vinculación de la consulta a la reclamación ('+numeroReclamacion+') con éxito.';
                        title =  'Consulta vinculada';
                    }
        
                   this.dispatchEvent(
        
                        new ShowToastEvent({
                            title: title,
                            message: mensaje,
                            variant: 'success'
                        }),
                    );
                    this.isLoading = false; 
                    this.listadoReclamaciones = [];
                    refreshApex(this._wiredResult);
                    this.updateRecordView(this.recordId);
        
                })
                    .catch(error => {
                        this.isLoading = false;
                        this.errorMsg = error;
                        
                        this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Fallo al vincular',
                            message: error.body.message,
                            variant: 'error'
                        }),);
        
                    })

            }else{
               this.isLoading = false;
               this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error al vincular',
                        message: 'No se puede realizar la vinculación después de resolver.',
                        variant: 'error'
                    })
                );
                this.dispatchEvent(new RefreshEvent());
            }

        })
        .catch(error => {
            this.isLoading = false;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error al vincular',
                    variant: 'error'
                })
            );
        })
    }

    handleClickDesvincular(event) {
        var variableAuxiliarCodigoboton = event.currentTarget.id;
        this.isLoading = true;

        for (var i = 0; i < variableAuxiliarCodigoboton.length - 1; i++) {
            if (variableAuxiliarCodigoboton.charAt(i) == '-') {
                this.idAVincular = variableAuxiliarCodigoboton.substring(0, i);
            }
        }


        validarVincularDesvincularComplementaria({idCaso: this.recordId}).then(result =>{
                    if(result == true){
                        //Permite desvincular si no es una complementaria que ya ha sido resuelta
                        desvincular({ idCasoVinculado: this.idAVincular, idCasoActual: this.recordId }).then(result => {
                            let mensaje;
                            let title;
                            let nombreRecord;
                            let numeroReclamacion;
                
                            for (var i = 0; i < result.length - 1; i++) {
                                if (result.charAt(i) == ';') {
                                    nombreRecord = result.substring(0, i);
                                    numeroReclamacion = result.substring(i+1,result.length - 1);
                                }
                            }
                
                            if(nombreRecord == 'SAC_Reclamacion'){
                                mensaje = 'Se ha actualizado el estado de la reclamación.';
                                title =  'Reclamacion desvinculada';
                
                            }else if(nombreRecord == 'SAC_Consulta'){
                                mensaje = 'Se ha desvinculado la consulta.';
                                title =  'Consulta desvinculada';
                            }
                
                           this.dispatchEvent(
                
                                new ShowToastEvent({
                                    title: title,
                                    message: mensaje,
                                    variant: 'success'
                                }),
                            );
                            this.isLoading = false; 
                            this.listadoReclamaciones = [];
                            refreshApex(this._wiredResult);
                            this.updateRecordView(this.recordId);
                
                        })
                            .catch(error => {
                                this.isLoading = false;
                                this.errorMsg = error;
                
                
                                this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Fallo al vincular',
                                    message: error.body.pageErrors[0].message,
                                    variant: 'error'
                                }),);
                
                            })


                    }else{
                       this.isLoading = false;
                       this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error al desvincular',
                                message: 'No se puede realizar la vinculación/desvinculación después de resolver.',
                                variant: 'error'
                            })
                        );
                        this.dispatchEvent(new RefreshEvent());
                    }

            })
            .catch(error => {
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error al vincular/desvincular',
                        variant: 'error'
                    })
                );
            })
    }
}