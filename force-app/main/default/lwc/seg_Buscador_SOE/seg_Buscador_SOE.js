import {LightningElement, api, track, wire} from 'lwc';
import getResultadoListaSOE from '@salesforce/apex/SEG_Buscador_SOE.getResultadoListaSOE';
import getResultadoContactosSOE from '@salesforce/apex/SEG_Buscador_SOE.getResultadoContactosSOE';
import {updateRecord, getFieldValue, getRecord} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

//Campos Operación SOE
//import OBJETO_CASE from '@Salesforce/schema/Case';
import CASE_SOE_ID from '@salesforce/schema/Case.Id';
import currentUserId from '@salesforce/user/Id';
import CASE_OWNERID from '@salesforce/schema/Case.OwnerId';
import CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';

import CASE_SOE_NUMEROSOE from '@salesforce/schema/Case.SEG_Numero_SOE__c';    // Número de SOE - Se utiliza el campo en "seg_Casos_Por_Grupos.js"
import CASE_SOE_NOMBREACREDITADA from '@salesforce/schema/Case.SEG_NombreDenominaciontitularoperaci_n__c'; // Nombre acreditada - NUEVO
import CASE_SOE_TITULAR from '@salesforce/schema/Case.SEG_Segmento_del_titular__c';    // Segmento del titualr
import CASE_SOE_NIF from '@salesforce/schema/Case.SEG_Identificador_NIF_titular_operaci_n__c';   // NIF Titular
import CASE_SOE_ORIGINADOR from '@salesforce/schema/Case.SEG_Originador__c'; // Originador
import CASE_SOE_TIPOOPER from '@salesforce/schema/Case.SEG_Area_agrupacion__c';  // Tipo operación
import CASE_SOE_AREA from '@salesforce/schema/Case.SEG_Aliasdelaoperacion__c';    // Área - NUEVO
import CASE_SOE_ENTIDADAGENTE from '@salesforce/schema/Case.SEG_EntidadAgente__c';   // Entidad agente
import CASE_SOE_HITOS from '@salesforce/schema/Case.SEG_Estado_seguimiento_hitos__c';   // Originador - NUEVO
import CASE_SOE_REFERENCIAUNICA from '@salesforce/schema/Case.SEG_Tipo_de_seguimiento_de_hitos__c';   // Referencia única
import CASE_SOE_LISTA_CONTACTOS from '@salesforce/schema/Case.SEG_Contactos_SOE_JSON__c';   // Lista Contactos para Comunicaciones

export default class Seg_Buscador_SOE extends LightningElement {

    @api recordId;
	datatableColumnas = [
		{label: 'N.SOE', fieldName: 'contractId', initialWidth: 154},
		{label: 'Nombre acreditada', fieldName: 'Nombreacreditada'},
		{label: 'Alta operacion', fieldName: 'soeSituationCode'},
		{label: 'Estados SOE', fieldName: 'soeSituationName'},
        {label: 'Fecha alta', fieldName: 'soeDate'},
        {label: 'Originador', fieldName: 'originatorName'},
        {label: 'Area', fieldName: 'areaName'},
        {label: 'Sector', fieldName: 'sectorName'}
	];
	datosSelLista;
	datatableData;
    mostarSpinner = false;
    @track isNotOwner = true;
	@track botonEnviarCorreoGenerarBorradorDisabled = true;

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

	modalBuscarSOEAbrir() {
		this.template.querySelector('.modalBuscarSOE').classList.add('slds-fade-in-open');
		this.template.querySelector('.slds-backdrop').classList.add('slds-backdrop--open');
		this.template.querySelector('.botonSeleccionSOE').classList.add('slds-hide');
	}

	limpiarDatosSOE(){
        const fields = {};
        fields[CASE_SOE_ID.fieldApiName] = this.recordId;
        fields[CASE_SOE_NUMEROSOE.fieldApiName] = null;
        fields[CASE_SOE_NOMBREACREDITADA.fieldApiName] = null;
        fields[CASE_SOE_TITULAR.fieldApiName] = null;
        fields[CASE_SOE_NIF.fieldApiName] = null;
        fields[CASE_SOE_ORIGINADOR.fieldApiName] = null;
        fields[CASE_SOE_TIPOOPER.fieldApiName] = null;
        fields[CASE_SOE_AREA.fieldApiName] = null;
        fields[CASE_SOE_ENTIDADAGENTE.fieldApiName] = null;
        fields[CASE_SOE_HITOS.fieldApiName] = null;
        fields[CASE_SOE_REFERENCIAUNICA.fieldApiName] = null;
        const caso = {fields};
        updateRecord(caso)
        .then(() => {})
        .catch(error => {
			this.mostrarToast('error', 'Error al limpiar los datos', 'No se han podido limpiar los datos.');
        });   
    }

	modalBuscarSOECerrar() {
		this.botonEnviarCorreoGenerarBorradorDisabled = true;
		this.datatableData = null;
		this.template.querySelector('.modalBuscarSOE').classList.remove('slds-fade-in-open');
        this.template.querySelector('.botonSeleccionSOE').classList.add('slds-hide');
		this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop--open');
		this.template.querySelector('.mostrarResultadosSOE').classList.add('slds-hide');
	}

	modalBuscarResultadosSOE() {
       // Validar que los campos obligatorios estén informados.
       this.template.querySelector('.mostrarErrorResultados').classList.add('slds-hide');
		let nombreAcreditada = this.template.querySelector('[data-id="nombreAcreditada"]').value;
        let numeroSOE = this.template.querySelector('[data-id="numeroSOE"]').value;
        let nif = this.template.querySelector('[data-id="nif"]').value;
        var regex = /\D+/; //dígitos no numéricos

		if (nombreAcreditada == '' && numeroSOE == '' && nif == ''){
            this.template.querySelector('.mostrarErrorCampos').classList.remove('slds-hide');
            this.template.querySelector('.mostrarResultadosSOE').classList.add('slds-hide');
            this.template.querySelector('.mostrarErrorLetras').classList.add('slds-hide');
			return;
        }
        else if((numeroSOE != '' && regex.test(numeroSOE))){
            this.template.querySelector('.mostrarErrorLetras').classList.remove('slds-hide');
            this.template.querySelector('.mostrarResultadosSOE').classList.add('slds-hide');
			return;
        }else{
            this.datatableData = [];
            this.template.querySelector('.mostrarErrorCampos').classList.add('slds-hide');
            this.template.querySelector('.mostrarErrorLetras').classList.add('slds-hide');
            this.mostrarSpinner = true;
            getResultadoListaSOE({
                nombreAcreditada: this.template.querySelector('[data-id="nombreAcreditada"]').value,
                nif: this.template.querySelector('[data-id="nif"]').value,
                numeroSOE: this.template.querySelector('[data-id="numeroSOE"]').value
				
            })
            .then(resultSOE => {
                // sacar log ver porque no entra
                if(resultSOE == null || resultSOE.responseSOE == null || resultSOE.responseSOE.datos == null || resultSOE.responseSOE.datos == ''){
                    this.template.querySelector('.mostrarResultadosSOE').classList.add('slds-hide');
                    this.template.querySelector('.mostrarErrorResultados').classList.remove('slds-hide');
                    this.template.querySelector('.botonSeleccionSOE').classList.add('slds-hide');
                }else{
                    this.template.querySelector('.mostrarErrorResultados').classList.add('slds-hide');
                    this.template.querySelector('.mostrarResultadosSOE').classList.remove('slds-hide');
                    this.template.querySelector('.botonSeleccionSOE').classList.remove('slds-hide');
                    this.datatableData = resultSOE.responseSOE.datos;
                }
            })
            .catch(error => {
                this.template.querySelector('.mostrarResultadosSOE').classList.add('slds-hide');
                this.template.querySelector('.mostrarErrorResultados').classList.remove('slds-hide');
                this.template.querySelector('.botonSeleccionSOE').classList.add('slds-hide');
            })
            .finally(() => this.mostarSpinner = false);
                
            //Contesta el apex
            this.mostarSpinner = false;
        }
	}

    modalResultadosSOE(){
        
        getResultadoContactosSOE({
            numSOE: this.datosSelLista[0].contractId,
            caseNumber: this.caso.casenumber
        })
        .then(resultContactosSOE => {
            this.mostrarSpinner = true;
            if (resultContactosSOE == null || resultContactosSOE.responseContactoSOE == null) {
                this.mostrarSpinner = false;
                this.template.querySelector('.mostrarResultadosSOE').classList.add('slds-hide');
                this.template.querySelector('.mostrarErrorResultados').classList.remove('slds-hide');
                this.template.querySelector('.botonSeleccionSOE').classList.add('slds-hide');
            } else {
                const fields = {};
                fields[CASE_SOE_ID.fieldApiName] = this.recordId;
                fields[CASE_SOE_NUMEROSOE.fieldApiName] = String(resultContactosSOE.responseContactoSOE.contractId);
                fields[CASE_SOE_NOMBREACREDITADA.fieldApiName] = String(resultContactosSOE.responseContactoSOE.originatorName);
                fields[CASE_SOE_TITULAR.fieldApiName] = String(resultContactosSOE.responseContactoSOE.borrowerName);
                fields[CASE_SOE_NIF.fieldApiName] = String(resultContactosSOE.responseContactoSOE.borrowerId);
                fields[CASE_SOE_ORIGINADOR.fieldApiName] = String(resultContactosSOE.responseContactoSOE.originatorName);
                fields[CASE_SOE_TIPOOPER.fieldApiName] = String(resultContactosSOE.responseContactoSOE.operationCodeName);
                fields[CASE_SOE_AREA.fieldApiName] = String(resultContactosSOE.responseContactoSOE.areaName);
                fields[CASE_SOE_ENTIDADAGENTE.fieldApiName] = String(resultContactosSOE.responseContactoSOE.areaCode);
                fields[CASE_SOE_HITOS.fieldApiName] = String(resultContactosSOE.responseContactoSOE.milestonesMonitoringSituationName);
                fields[CASE_SOE_REFERENCIAUNICA.fieldApiName] = String(resultContactosSOE.responseContactoSOE.soeSituationCode);
                fields[CASE_SOE_LISTA_CONTACTOS.fieldApiName] = JSON.stringify(resultContactosSOE.responseContactoSOE.contactList);
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
            this.template.querySelector('.modalBuscarSOE').classList.remove('slds-fade-in-open');
            this.template.querySelector('.botonSeleccionSOE').classList.add('slds-hide');
            this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop--open');
            this.template.querySelector('.mostrarResultadosSOE').classList.add('slds-hide');
            this.template.querySelector('.mostrarErrorCampos').classList.add('slds-hide');
            this.template.querySelector('.mostrarErrorResultados').classList.add('slds-hide');
            this.template.querySelector('[data-id="nombreAcreditada"]').value = '',
            this.template.querySelector('[data-id="numeroSOE"]').value = '',
            this.template.querySelector('[data-id="nif"]').value = ''
        });
    }

	habilitarSel(event){
        this.datosSelLista = event.detail.selectedRows;
        this.botonEnviarCorreoGenerarBorradorDisabled = false;
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

    mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000}));
	}

    eventStopPropagation(event) {
		event.stopPropagation();
	}
}