import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getReclamacionesMismoReclamante from '@salesforce/apex/SPV_LCMP_ReclamacionesVinculadas.getReclamacionesMismoReclamante';
import vincularReclamacion from '@salesforce/apex/SPV_LCMP_ReclamacionesVinculadas.vincularReclamacion';
import desvincularReclamacion from '@salesforce/apex/SPV_LCMP_ReclamacionesVinculadas.desvincularReclamacion';
import { NavigationMixin } from 'lightning/navigation'; 
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import comprobarPermisosVinculacion from '@salesforce/apex/SPV_LCMP_ReclamacionesVinculadas.comprobarPermisosVinculacion';

import ACCOUNTID from '@salesforce/schema/Case.AccountId';


const FIELDS = [
    ACCOUNTID
];

export default class Spv_AsociarReclamacion extends NavigationMixin(LightningElement) {
    @api recordId;    
    @api caseId;
    @api isLoading = false;
    @api tabNombre;
    @track existenReclamaciones = false;
    @track listadoReclamaciones = [];
    @track deshabilitarBotones = false;
    @track tituloInicial = 'Reclamaciones relacionadas';
    @track esRegistroSAC;

    
    _wiredResult;
    @wire(getRecord, {recordId: '$recordId', fields : FIELDS})
    getCaseRecord({ error, data }){
        if (data) {
            let hayReclamante = false;

            for (const campo in data.fields){
                if (campo == 'AccountId'){
                    if (data.fields[campo].value != null){
                        hayReclamante = true;
                    }else{
                        this.showToast('Error', 'No existe un cliente asociado a la reclamación.', 'error');
                    }
                }
            }

            if(hayReclamante){
                getReclamacionesMismoReclamante({ idCasoActual: this.recordId, regProyecto: this.tabNombre}).then(result => {
                    
                    if (result) {                        
                        this.listadoReclamaciones = [];
                        this._wiredResult = result;
                        this.existenReclamaciones = true;
                        let reclamaciones = result;

                        for (var miReclamacion in reclamaciones) {  
                            let reclamacion = reclamaciones[miReclamacion];
                            reclamacion.isExpanded = false;
                            reclamacion.toggleText = 'Ver más...';                            

                            if(reclamacion.casoVinculadoActual){
                                reclamacion.desactivarVincular = true;
                                reclamacion.desactivarDesvincular = false;
                            }else{
                                reclamacion.desactivarVincular = false;
                                reclamacion.desactivarDesvincular = true;
                            }

                            //Aqui vamos a intentar meter a cada pretension su N_Contrato                            
                            var listPretensiones = reclamacion.listaPretensionesActual;
                            var listacontratos = reclamacion.mapPretNumerosContratosActual;

                            listPretensiones.forEach(pretension => {
                                //Obtener los contratos relacionados al Id de la pretension desde listacontratos
                                const contratos = listacontratos[pretension.Id] || [];

                                // Agregar un nuevo campo 'Contratos' al objeto pretension
                                pretension.contratosPret = contratos;
                            });

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
                })
                .catch(error => {                    
                    this.showToast('Error', error.body.message, 'error');
                });
            }
        }
    }

    @wire(comprobarPermisosVinculacion, { idCaso: '$recordId'}) 
    mapaPermisos(result){ 
        if(result){
            if(result.data !== '' && result.data != undefined){
                this.deshabilitarBotones = result.data;
            }
        }else{
            this.deshabilitarBotones = false;
        }
    };

    connectedCallback(){           
        if(this.tabNombre){
            this.tituloInicial = 'Reclamaciones ' + this.tabNombre + ' relacionadas';

            if(this.tabNombre === 'SAC'){
                this.esRegistroSAC = true;
            }else if(this.tabNombre === 'Supervisores'){
                this.esRegistroSAC = false;
            }
        }
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

    handleClickVincular(event) {
        
        var variableAuxiliarCodigoboton = event.currentTarget.id;
        this.isLoading = true;

        for (var i = 0; i < variableAuxiliarCodigoboton.length - 1; i++) {
            if (variableAuxiliarCodigoboton.charAt(i) == '-') {
                this.caseId = variableAuxiliarCodigoboton.substring(0, i);
            }
        }

        vincularReclamacion({ idCasoVinculado: this.caseId, idCasoActual: this.recordId }).then(result => {
            this.showToast('Reclamacion vinculada', 'La reclamación ha sido vinculada correctamente.', 'success');
            this.isLoading = false; 
            this.listadoReclamaciones = [];
            refreshApex(this._wiredResult);
            this.updateRecordView(this.recordId);

        })
        .catch(error => {
            this.isLoading = false;

            this.showToast('Fallo al vincular', error.body.message, 'error');
        })
    }

    handleClickDesvincular(event){

        var variableAuxiliarCodigoboton = event.currentTarget.id;
        this.isLoading = true;

        for (var i = 0; i < variableAuxiliarCodigoboton.length - 1; i++) {
            if (variableAuxiliarCodigoboton.charAt(i) == '-') {
                this.caseId = variableAuxiliarCodigoboton.substring(0, i);
            }
        }

        desvincularReclamacion({ idCasoVinculado: this.caseId, idCasoActual: this.recordId }).then(result => {
            this.showToast('Reclamacion desvinculada', 'La reclamación ha sido desvinculada correctamente.', 'success');
            this.isLoading = false; 
            this.listadoReclamaciones = [];
            refreshApex(this._wiredResult);
            this.updateRecordView(this.recordId);

        })
        .catch(error => {
            this.isLoading = false;

            this.showToast('Fallo al desvincular', error.body.message, 'error');
        })
    }

    updateRecordView(recordId) {
        updateRecord({fields: { Id: recordId }});
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }


     // Método para alternar el estado expandido de una reclamación
    toggleText(event) {
        const caseId = event.target.dataset.id;

        this.listadoReclamaciones = this.listadoReclamaciones.map(reclamacion => {
            if (reclamacion.reclamacionActual.Id === caseId) {
                reclamacion.isExpanded = !reclamacion.isExpanded;
                reclamacion.toggleText = reclamacion.isExpanded ? ' ...Ver menos' : 'Ver más...'; // Actualizar el texto del botón
            }
            return reclamacion;
        });
    }
}