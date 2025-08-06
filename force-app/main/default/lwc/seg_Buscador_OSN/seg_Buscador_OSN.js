import {LightningElement, api, track, wire} from 'lwc';
import getResultadoListaOSN from '@salesforce/apex/SEG_Buscador_OSN.getResultadoListaOSN';
import getResultadoContactosOSN from '@salesforce/apex/SEG_Buscador_OSN.getResultadoContactosOSN';
import getNumperso from '@salesforce/apex/SEG_Buscador_OSN.getNumperso';
import {updateRecord, getFieldValue, getRecord} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
//import {getObjectInfo} from 'lightning/uiObjectInfoApi';

//Campos Operación OSN
//import OBJETO_CASE from '@Salesforce/schema/Case';
import CASE_OSN_ID from '@salesforce/schema/Case.Id';
import currentUserId from '@salesforce/user/Id';
import CASE_OWNERID from '@salesforce/schema/Case.OwnerId';
import CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';

import CASE_OSN_NUMEROOSN from '@salesforce/schema/Case.SEG_Numero_OSN__c';    // Número de OSN - Se utiliza el campo en "seg_Casos_Por_Grupos.js"
import CASE_OSN_NOMBREACREDITADA from '@salesforce/schema/Case.SEG_Nombre_OSN__c'; // Nombre acreditada - NUEVO
import CASE_OSN_ESTADO from '@salesforce/schema/Case.SEG_Estado_OSN__c';    // Estado OSN
import CASE_OSN_CONCEDIDO from '@salesforce/schema/Case.SEG_Concedido_expediente_sindicado__c';   // Concedido
import CASE_OSN_FECHACONSTITUCION from '@salesforce/schema/Case.SEG_Fecha_constitucion__c'; // Fecha constitución - NUEVO
import CASE_OSN_NUMEROSOE from '@salesforce/schema/Case.SEG_Numero_OSN_SOE__c';    // Número SOE - NUEVO
import CASE_OSN_TIPOOPER from '@salesforce/schema/Case.SEG_Tipodeoperacion__c';  // Tipo operación
import CASE_OSN_AREA from '@salesforce/schema/Case.SEG_Area_OSN__c';    // Área - NUEVO
import CASE_OSN_ENTIDADAGENTE from '@salesforce/schema/Case.SEG_EntidadAgente__c';   // Entidad agente
import CASE_OSN_ORIGINADOR from '@salesforce/schema/Case.SEG_Originador_OSN__c';   // Originador - NUEVO
import CASE_OSN_REFERENCIAUNICA from '@salesforce/schema/Case.SEG_ReferenciaUnica__c';   // Referencia única
import CASE_OSN_LISTA_CONTACTOS from '@salesforce/schema/Case.SEG_Contactos_OSN_JSON__c';   // Lista Contactos para Comunicaciones

export default class Seg_Buscador_SOE extends LightningElement {

    @api recordId;
	datatableColumnas = [
		{label: 'N.OSN', fieldName: 'syndicatedId'},
        {label: 'N.SOE', fieldName: 'contractSoeId'},
		{label: 'Nombre acreditada', fieldName: 'accreditedName'},
        {label: 'Fecha constitución', fieldName: 'dateFrom'},
        {label: 'Originador', fieldName: 'originatorName'},
		{label: 'Estado OSN', fieldName: 'status'},
		{label: 'Concedido', fieldName: 'amountGranted'},
        {label: 'Tipo operación', fieldName: 'operationType'},
        {label: 'Área', fieldName: 'contractSoeArea'}
	];
    datosSelLista;
	datatableData;
    lstExcepciones;
    mostrarSpinner = false;
    mostrarBotonesNavegacion = false;
    deshabilitarCampo = true;
    @track isNotOwner = true;
    @track botonEnviarCorreoGenerarBorradorDisabled = true;

    resultadosBusqueda = [];
    resultadoAcotado = [];
    cuentaName;
    numperso;

    tipoBusquedaSeleccionada = {
		iconName: 'standar:account'
	}

    get optionsOSN() {
        return [
            { label: '-', value: 'estadoVacio'},
            { label: 'Vigente', value: 'CURRENT'},
            { label: 'Cancelado', value: 'CANCELLED'},
            { label: 'Impagado', value: 'UNPAID'}
        ];
    }

    @wire(getRecord, {recordId: '$recordId', fields: [CASE_OWNERID, CASE_NUMBER]})
	wiredRecord({error,data}) {
		if (data) {
			this.caso = data;
            if(getFieldValue(this.caso, CASE_OWNERID) == currentUserId){
                this.isNotOwner = false;
            } else {
                this.isNotOwner = true;
            }
		}else if (error){
            this.errorDatos(error);
        }
	}

    handleChange(event) {
        this.value = event.detail.value;
    }

	modalBuscarOSNAbrir() {
        this.deshabilitarCampo = true;
		this.template.querySelector('.modalBuscarOSN').classList.add('slds-fade-in-open');
        this.template.querySelector('.slds-backdrop').classList.add('slds-backdrop--open');
        this.template.querySelector('.botonSeleccionOSN').classList.add('slds-hide');
        this.template.querySelector('.resultadosBuscador').classList.remove('slds-hide');
        this.template.querySelector('.mostrarErrorBuscar').classList.add('slds-hide');
	}

    habilitarCampo(){
        let nombreNifAcreditada = this.template.querySelector('[data-id="numperso"]').value;
        if(nombreNifAcreditada.length >= 1){
            this.deshabilitarCampo = false;
        }else{
            this.deshabilitarCampo = true;
            this.numperso = '';
        }
    }

    limpiarDatosOSN(){
        const fields = {};
        fields[CASE_OSN_ID.fieldApiName] = this.recordId;
        fields[CASE_OSN_NUMEROOSN.fieldApiName] = null;
        fields[CASE_OSN_NOMBREACREDITADA.fieldApiName] = null;
        fields[CASE_OSN_ESTADO.fieldApiName] = null;
        fields[CASE_OSN_CONCEDIDO.fieldApiName] = null;
        fields[CASE_OSN_FECHACONSTITUCION.fieldApiName] = null;
        fields[CASE_OSN_NUMEROSOE.fieldApiName] = null;
        fields[CASE_OSN_TIPOOPER.fieldApiName] = null;
        fields[CASE_OSN_AREA.fieldApiName] = null;
        fields[CASE_OSN_ENTIDADAGENTE.fieldApiName] = null;
        fields[CASE_OSN_ORIGINADOR.fieldApiName] = null;
        fields[CASE_OSN_REFERENCIAUNICA.fieldApiName] = null;
        fields[CASE_OSN_LISTA_CONTACTOS.fieldApiName] = null;
        const caso = {fields};

        updateRecord(caso)
        .then(() => {})
        .catch(error => {
            this.errorDatos(error);
        });        
    }

	modalBuscarOSNCerrar() {
        this.botonEnviarCorreoGenerarBorradorDisabled = true;
        this.datatableData = null;
        this.resultadosBusqueda = [];
        this.resultadoAcotado = [];
        this.template.querySelector('.mostrarErrorBuscar').classList.add('slds-hide');
        this.template.querySelector('.mostrarErrorCampos').classList.add('slds-hide');
        this.template.querySelector('.mostrarErrorResultados').classList.add('slds-hide');
        this.template.querySelector('.mostrarResultadosOSN').classList.add('slds-hide');
        this.template.querySelector('.modalBuscarOSN').classList.remove('slds-fade-in-open');
        this.template.querySelector('.botonSeleccionOSN').classList.add('slds-hide');
        this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop--open');
        this.template.querySelector('[data-id="numperso"]').value = '',
        this.template.querySelector('[data-id="estadosOSN"]').value = '',
        this.template.querySelector('[data-id="numOSN"]').value = '',
        this.template.querySelector('[data-id="numSOE"]').value = ''
        this.template.querySelector('.resultadosBuscador').classList.add('slds-hide');
	}

    modalBuscarResultadosOSN() {
        // Validar que los campos obligatorios estén informados.
        this.template.querySelector('.mostrarErrorResultados').classList.add('slds-hide');
        let nOSN = this.template.querySelector('[data-id="numOSN"]').value;
        let nSOE = this.template.querySelector('[data-id="numSOE"]').value;
        var regex = /\D+/; //dígitos no numéricos
		if ((this.numperso == '' || this.numperso == undefined) && nOSN == '' && nSOE == ''){
            this.template.querySelector('.mostrarErrorCampos').classList.remove('slds-hide');
            this.template.querySelector('.mostrarResultadosOSN').classList.add('slds-hide');
            this.template.querySelector('.mostrarErrorBuscar').classList.add('slds-hide');
            this.template.querySelector('.mostrarErrorLetras').classList.add('slds-hide');
			return;
        } else if((nOSN != '' && regex.test(nOSN)) || (nSOE != '' && regex.test(nSOE))){
            this.template.querySelector('.mostrarErrorLetras').classList.remove('slds-hide');
            this.template.querySelector('.mostrarResultadosOSN').classList.add('slds-hide');
            this.template.querySelector('.mostrarErrorBuscar').classList.add('slds-hide');
            this.template.querySelector('.mostrarResultadosOSN').classList.add('slds-hide');
			return;
        }else{
            this.datatableData = [];
            this.template.querySelector('.mostrarErrorCampos').classList.add('slds-hide');
            this.template.querySelector('.mostrarErrorBuscar').classList.add('slds-hide');
            this.template.querySelector('.mostrarErrorLetras').classList.add('slds-hide');
            this.mostrarSpinner = true;
            getResultadoListaOSN({
                numperso: this.numperso,
                estadoOSN: this.template.querySelector('[data-id="estadosOSN"]').value,
                numOSN: this.template.querySelector('[data-id="numOSN"]').value,
                numSOE: this.template.querySelector('[data-id="numSOE"]').value,
                caseNumber: this.caso.casenumber
            })
            .then(resultOSN => {
                if(resultOSN.responseOSN == null || resultOSN.responseOSN == undefined){
                    this.template.querySelector('.mostrarResultadosOSN').classList.add('slds-hide');
                    this.template.querySelector('.mostrarErrorResultados').classList.remove('slds-hide');
                    this.template.querySelector('.botonSeleccionOSN').classList.add('slds-hide');
                }else {
                    this.template.querySelector('.mostrarErrorResultados').classList.add('slds-hide');
                    this.template.querySelector('.mostrarResultadosOSN').classList.remove('slds-hide');
                    this.template.querySelector('.botonSeleccionOSN').classList.remove('slds-hide');
                    this.datatableData = resultOSN.responseOSN.syndicatedList;
                }
            })
            .catch(error => {
                this.errorDatos(error);
                this.template.querySelector('.mostrarResultadosOSN').classList.add('slds-hide');
            })
            .finally(() => this.mostrarSpinner = false);

            //Contesta el apex
            this.mostrarSpinner = false;
        }
    }

    modalResultadosOSN(){
        getResultadoContactosOSN({
            numOSN: this.datosSelLista[0].syndicatedId,
            caseNumber: this.caso.casenumber
        })
        .then(resultContactosOSN => {
            this.mostrarSpinner = true;
            if (resultContactosOSN.responseContactoOSN == null || resultContactosOSN.responseContactoOSN == undefined) {
                this.mostrarSpinner = false;
            } else {
                const fields = {};
                fields[CASE_OSN_ID.fieldApiName] = this.recordId;
                fields[CASE_OSN_NUMEROOSN.fieldApiName] = String(resultContactosOSN.responseContactoOSN.syndicatedId);
                fields[CASE_OSN_NOMBREACREDITADA.fieldApiName] = String(resultContactosOSN.responseContactoOSN.accreditedName);
                fields[CASE_OSN_ESTADO.fieldApiName] = String(resultContactosOSN.responseContactoOSN.status);
                fields[CASE_OSN_CONCEDIDO.fieldApiName] = String(resultContactosOSN.responseContactoOSN.amountGranted); 
                fields[CASE_OSN_FECHACONSTITUCION.fieldApiName] = String(resultContactosOSN.responseContactoOSN.dateFrom);
                fields[CASE_OSN_NUMEROSOE.fieldApiName] = String(resultContactosOSN.responseContactoOSN.contractSoeId);
                fields[CASE_OSN_TIPOOPER.fieldApiName] = String(resultContactosOSN.responseContactoOSN.operationType);
                fields[CASE_OSN_AREA.fieldApiName] = String(resultContactosOSN.responseContactoOSN.contractSoeArea);
                fields[CASE_OSN_ENTIDADAGENTE.fieldApiName] = String(resultContactosOSN.responseContactoOSN.agentEntity);
                fields[CASE_OSN_ORIGINADOR.fieldApiName] = String(resultContactosOSN.responseContactoOSN.originatorName);
                fields[CASE_OSN_REFERENCIAUNICA.fieldApiName] = String(resultContactosOSN.responseContactoOSN.syndicatedReference);
                fields[CASE_OSN_LISTA_CONTACTOS.fieldApiName] = JSON.stringify(resultContactosOSN.responseContactoOSN.contactList);
                const caso = {fields};
    
                updateRecord(caso)
                .then(() => {
                    this.mostrarSpinner = true;
                })
                .catch(error => {
                    this.mostrarSpinner = false;
                    this.errorDatos(error);
                });
            }
        })
        .catch(error => {
            this.errorDatos(error);
            this.mostrarSpinner = false;
        })
        .finally(() => {
            this.mostrarSpinner = false;
            this.botonEnviarCorreoGenerarBorradorDisabled = true;
            this.datatableData = null;
            this.template.querySelector('.modalBuscarOSN').classList.remove('slds-fade-in-open');
            this.template.querySelector('.botonSeleccionOSN').classList.add('slds-hide');
            this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop--open');
            this.template.querySelector('.mostrarResultadosOSN').classList.add('slds-hide');
            this.template.querySelector('.mostrarErrorCampos').classList.add('slds-hide');
            this.template.querySelector('.mostrarErrorResultados').classList.add('slds-hide');
            this.template.querySelector('[data-id="numperso"]').value = '',
            this.template.querySelector('[data-id="estadosOSN"]').value = '',
            this.template.querySelector('[data-id="numOSN"]').value = '',
            this.template.querySelector('[data-id="numSOE"]').value = ''

        });

    }

    iniciarBusqueda(event){
        getNumperso({
            valorBusqueda: this.template.querySelector('[data-id="numperso"]').value
        })
        .then(resultContactosOSN => {
            if(resultContactosOSN == null || resultContactosOSN == ''){
                this.template.querySelector('.mostrarErrorBuscar').classList.remove('slds-hide');
                this.template.querySelector('.resultadosBuscador').classList.add('slds-hide');
                return;
            }

            this.resultadosBusqueda = resultContactosOSN;
            if(resultContactosOSN != null && resultContactosOSN != undefined){
                // Comprobamos que la longitud es mayor que 5
                if (this.resultadosBusqueda.length < 6) {
                    this.resultadoAcotado = this.resultadosBusqueda;
                    this.mostrarBotonesNavegacion = false;
                } else {
                    // Recorremos los 5 primeros
                    for (let index = 0; index < 5; index++) {
                        this.resultadoAcotado.push(this.resultadosBusqueda[index]);                 
                    }
                    this.mostrarBotonesNavegacion = true;
                }
            }
            this.template.querySelector('.resultadosBuscador').classList.remove('slds-hide');
            this.template.querySelector('.mostrarErrorBuscar').classList.add('slds-hide');
        })
        .catch(error => {
           // this.mostrarToast('error', 'Problema durante a ejecución', error);
            console.log('Error ->' + error);
            this.template.querySelector('.mostrarResultadosOSN').classList.add('slds-hide');
        })
        .finally(() => this.mostrarSpinner = false);
    }

    siguienteBusqueda(){

    }

    anteriorBusqueda(){
        
    }

    habilitarSel(event){
        this.datosSelLista = event.detail.selectedRows;
        this.botonEnviarCorreoGenerarBorradorDisabled = false;
    }

    mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000}));
	}

    eventStopPropagation(event) {
		event.stopPropagation();
	}

    seleccionarResultado(event) {
        this.numperso = event.currentTarget.dataset.numperso;
        this.cuentaName = event.currentTarget.dataset.nombre;
        this.template.querySelector('[data-id="numperso"]').value = this.cuentaName;
        this.template.querySelector('.mostrarErrorCampos').classList.add('slds-hide');
        this.template.querySelector('.mostrarErrorBuscar').classList.add('slds-hide');
        this.template.querySelector('.resultadosBuscador').classList.add('slds-hide'); 
	}

    errorDatos(error){
        let mensajeError;
        if (Array.isArray(error?.body)) {
            mensajeError = error.body.map(e => e.message).join(', ');
        } else if (typeof error?.body?.message === 'string') {
            mensajeError = error.body.message;
        } else {
            mensajeError = error;
        }
        this.mostrarToast('error', 'Problema durante a ejecución', mensajeError);
    }
}