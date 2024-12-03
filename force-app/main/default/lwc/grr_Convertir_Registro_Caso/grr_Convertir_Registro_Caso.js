import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex'; //Sirve para actualizar los resultados en el @wire
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {loadStyle} from 'lightning/platformResourceLoader';

//CSS
import CUSTOM_CSS from '@salesforce/resourceUrl/GRR_Case_Gestion_Css';

//Métodos Apex
import getListadoRegistros from '@salesforce/apex/GRR_Convertir_Registro_Caso_Controller.getListadoRegistros';
import validarMultiplesRegistros from '@salesforce/apex/GRR_Convertir_Registro_Caso_Controller.validarMultiplesRegistros'; 
import getGruposUsuario from '@salesforce/apex/GRR_Convertir_Registro_Caso_Controller.getGruposUsuario'; 


//Campos Carga
import CARGA_ID from '@salesforce/schema/GRR_Carga__c.Id';
import CARGA_TIPO_FICHERO from '@salesforce/schema/GRR_Carga__c.GRR_TipoDeFichero__c';

//Campos Registro
import REGISTRO_ID from '@salesforce/schema/GRR_RegistroCarga__c.Id';
import REGISTRO_FICHERO from '@salesforce/schema/GRR_RegistroCarga__c.GRR_Fichero__c';
import REGISTRO_NAME from '@salesforce/schema/GRR_RegistroCarga__c.Name';
import REGISTRO_CASO from '@salesforce/schema/GRR_RegistroCarga__c.GRR_Caso__c';
import REGISTRO_GRR from '@salesforce/schema/GRR_RegistroCarga__c.GRR_GRR__c';
import REGISTRO_RECORDTYPENAME from '@salesforce/schema/GRR_RegistroCarga__c.RecordType.Name';
import REGISTRO_RECORDTYPEID from '@salesforce/schema/GRR_RegistroCarga__c.RecordTypeId';
import REGISTRO_UR from '@salesforce/schema/GRR_RegistroCarga__c.GRR_UR__c';
import REGISTRO_VULNERABILIDAD from '@salesforce/schema/GRR_RegistroCarga__c.GRR_Vulnerabilidad__c';
import REGISTRO_DEPARTAMENTO from '@salesforce/schema/GRR_RegistroCarga__c.GRR_Departamento__c';
import REGISTRO_MOTIVOS from '@salesforce/schema/GRR_RegistroCarga__c.GRR_Motivos__c';
import REGISTRO_PROVINCIA from '@salesforce/schema/GRR_RegistroCarga__c.GRR_Provincia__c';
import REGISTRO_DIRECCION from '@salesforce/schema/GRR_RegistroCarga__c.GRR_Direccion__c';
import REGISTRO_POBLACION from '@salesforce/schema/GRR_RegistroCarga__c.GRR_Poblacion__c';
import REGISTRO_COMUNIDAD from '@salesforce/schema/GRR_RegistroCarga__c.GRR_Comunidad__c';
import REGISTRO_CODOFICINA from '@salesforce/schema/GRR_RegistroCarga__c.GRR_CodigoOficina__c';
import REGISTRO_CODDAN from '@salesforce/schema/GRR_RegistroCarga__c.GRR_CodigoDAN__c';
import REGISTRO_CODDT from '@salesforce/schema/GRR_RegistroCarga__c.GRR_CodigoDT__c';
import REGISTRO_NIFS from '@salesforce/schema/GRR_RegistroCarga__c.GRR_NIF__c';
import REGISTRO_INTERVINIENTES from '@salesforce/schema/GRR_RegistroCarga__c.GRR_Intervinientes__c';
import REGISTRO_NIFSCONRR from '@salesforce/schema/GRR_RegistroCarga__c.GRR_NIFs_Con_RR__c';
import REGISTRO_INTERVINIENTESCONRR from '@salesforce/schema/GRR_RegistroCarga__c.GRR_Intervinientes_Con_RR__c';
import REGISTRO_INFORMACIONCLIENTE from '@salesforce/schema/GRR_RegistroCarga__c.GRR_Informacion_Cliente__c';
import REGISTRO_OBSERVACIONESCP from '@salesforce/schema/GRR_RegistroCarga__c.GRR_ObservacionesCP__c';
import REGISTRO_COMENTARIOSSANCIONBC from '@salesforce/schema/GRR_RegistroCarga__c.GRR_ComentariosSancionBC__c';


const FIELDS_CARGA = [CARGA_ID, CARGA_TIPO_FICHERO]; 
const FIELDS_REGISTRO = [REGISTRO_ID, REGISTRO_FICHERO, REGISTRO_NAME, REGISTRO_CASO, REGISTRO_GRR, REGISTRO_RECORDTYPENAME, REGISTRO_RECORDTYPEID, REGISTRO_UR, 
    REGISTRO_VULNERABILIDAD, REGISTRO_DEPARTAMENTO, REGISTRO_MOTIVOS, REGISTRO_PROVINCIA, REGISTRO_DIRECCION, REGISTRO_POBLACION, REGISTRO_COMUNIDAD, REGISTRO_CODOFICINA,
    REGISTRO_CODDAN, REGISTRO_CODDT, REGISTRO_NIFS, REGISTRO_INTERVINIENTES, REGISTRO_NIFSCONRR, REGISTRO_INTERVINIENTESCONRR, REGISTRO_INFORMACIONCLIENTE, 
    REGISTRO_OBSERVACIONESCP, REGISTRO_COMENTARIOSSANCIONBC]; 


export default class grr_Convertir_Registro_A_Caso extends LightningElement {
    @api recordId;

    carga;
    
    listadoRegistros;
    
    cargaCargada = false;
    
    registrosCargados = false;
    
    guardando = false;
    
    opcionesProcedencias = [];
    
    procedencia;
    
    showModal = false;

    
    get tipoFicheroRecobro() {
        return getFieldValue(this.carga, CARGA_TIPO_FICHERO) === 'Recobro';
	}

    get botonConfirmarGrupoDisabled() {
		return !this.procedencia;
	}

    get cargasCompletadas(){
        return this.cargaCargada && this.registrosCargados;
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS_CARGA })
    wiredCarga({ error, data }) {
        if (data) {
            this.carga = data; 
            this.cargaCargada = true;
        } else if (error) {
            this.mostrarToast('Error', 'Problema al cargar los datos', 'El fichero o los registros no han terminado de cargar.', 'sticky');
        }
    }

    @wire(getListadoRegistros, { cargaId: '$recordId', fields: FIELDS_REGISTRO })
    wiredRegistros({ error, data }) {
        if (data) {
            this.listadoRegistros = data;
            this.registrosCargados = true;
        } else if (error) {
            this.mostrarToast('Error', 'Problema al recuperar los datos de los registros', 'El fichero o los registros no han terminado de cargar.', 'sticky');
        }
    }

    renderedCallback() {
		//Hoja de estilos para habilitar toasts con varias líneas de texto
		if (!this.cssCargado) {
			loadStyle(this, CUSTOM_CSS).then(() => this.cssCargado = true);
		}

		if (this.funcionAbrirModal) {
			this.funcionAbrirModal.call(this);
			this.funcionAbrirModal = null;
		}
	}

    modalRecobrosAbrir(){
        if (this.showModal) {
            this.modalRecobrosInicializar();
        } else {
            this.funcionAbrirModal = this.modalRecobrosInicializar;
            this.showModal = true;
        }
    }

    modalRecobrosInicializar(){
        if (this.opcionesProcedencias.length === 0) {
            getGruposUsuario()
            .then(result => {
                this.opcionesProcedencias = result; 
                if (this.opcionesProcedencias.length === 1){
                    this.procedencia = this.opcionesProcedencias[0].value;
                    this.template.querySelector('[data-id="comboboxProcedenciaSeleccionar"]').value = this.procedencia;
                } 
            }).catch(error => {
                this.mostrarToast('Error', 'Error al obtener los grupos del usuario', error.body.message, 'sticky');
            });
        } else if (this.opcionesProcedencias.length === 1){
            this.procedencia = this.opcionesProcedencias[0].value;
            this.template.querySelector('[data-id="comboboxProcedenciaSeleccionar"]').value = this.procedencia;
        } else {
            this.procedencia = null;
        }

        this.template.querySelector('.modalProcedencia').classList.add('slds-fade-in-open');
        this.template.querySelector('.backdropModales').classList.add('slds-backdrop_open');
        this.template.querySelector('.modalProcedenciaCancelar').focus();
    }

    handleGrupoSeleccionado(event){
        let comboboxProcedencia;
        if (event.currentTarget.dataset.operativa === 'SeleccionarProcedencia') {
            comboboxProcedencia = this.template.querySelector('[data-id="comboboxProcedenciaSeleccionar"]');
		}
        this.procedencia = comboboxProcedencia.value;
    }

    generarCasosRecobros() {
		this.template.querySelector('.modalProcedenciaConfirmar').disabled = true;

        if (this.carga && this.listadoRegistros && this.procedencia) {
            this.guardando = true;

            // Datos del objeto Carga
            const cargaData = {
                Id: this.carga.fields.Id.value,
                GRR_TipoDeFichero__c: this.carga.fields.GRR_TipoDeFichero__c.value
            };

            // Datos del objeto Registro
            const registros = this.listadoRegistros.map(listadoRegistro => ({
                Id: listadoRegistro.Id,
                GRR_Fichero__c: listadoRegistro.GRR_Fichero__c,
                Name: listadoRegistro.Name,
                GRR_Caso__c: listadoRegistro.GRR_Caso__c,
                GRR_GRR__c: listadoRegistro.GRR_GRR__c,
                RecordTypeName: listadoRegistro.RecordType.Name,
                RecordTypeId: listadoRegistro.RecordType.Id,
                GRR_UR__c: listadoRegistro.GRR_UR__c,
                GRR_Vulnerabilidad__c: listadoRegistro.GRR_Vulnerabilidad__c,
                GRR_Departamento__c: listadoRegistro.GRR_Departamento__c,
                GRR_Motivos__c: listadoRegistro.GRR_Motivos__c,
                GRR_Provincia__c: listadoRegistro.GRR_Provincia__c,
                GRR_Direccion__c: listadoRegistro.GRR_Direccion__c,
                GRR_Poblacion__c: listadoRegistro.GRR_Poblacion__c,
                GRR_Comunidad__c: listadoRegistro.GRR_Comunidad__c,
                GRR_CodigoOficina__c: listadoRegistro.GRR_CodigoOficina__c,
                GRR_CodigoDAN__c: listadoRegistro.GRR_CodigoDAN__c,
                GRR_CodigoDT__c: listadoRegistro.GRR_CodigoDT__c,
                GRR_NIF__c: listadoRegistro.GRR_NIF__c,
                GRR_Intervinientes__c: listadoRegistro.GRR_Intervinientes__c,
                GRR_NIFs_Con_RR__c: listadoRegistro.GRR_NIFs_Con_RR__c,
                GRR_Intervinientes_Con_RR__c: listadoRegistro.GRR_Intervinientes_Con_RR__c,
                GRR_Informacion_Cliente__c: listadoRegistro.GRR_Informacion_Cliente__c, 
                GRR_ObservacionesCP__c: listadoRegistro.GRR_ObservacionesCP__c, 
                GRR_ComentariosSancionBC__c : listadoRegistro.GRR_ComentariosSancionBC__c
            }));

            validarMultiplesRegistros({ carga: cargaData, registros, procedenciaSeleccionada: this.procedencia})
            .then(result => {
                this.closeModals();
                if(result.startsWith("Error")){
                    this.mostrarToast('Error', 'Error parcial al generar', result, 'sticky'); //Se deja el toast fijo
                }else {
                    this.mostrarToastRecargar('Success', 'Éxito', result);
                }
                
                return refreshApex(this.wiredRegistros); // Actualiza aquellos registros del wiredRegistros
            }).catch(error => {
                this.closeModals();
                if(error.body.message.startsWith("Aviso")){
                    this.mostrarToast('Warning', 'Aviso', error.body.message, 'dismissible'); //Modo default: el toast desaparece
                } else {
                    this.mostrarToast('Error', 'Error al generar', error.body.message, 'sticky');
                }
            });

        } else {
            this.mostrarToast('Error', 'Error inicial', 'El fichero o los registros tienen valor null o undefined.', 'sticky');
        } 
	}

    handleGenerarCasosGlobal() {
        if (this.carga && this.listadoRegistros) {
            this.guardando = true;
            
            // Datos del objeto Carga
            const cargaData = {
                Id: this.carga.fields.Id.value,
                GRR_TipoDeFichero__c: this.carga.fields.GRR_TipoDeFichero__c.value
            };

            // Datos del objeto Registro
            const registros = this.listadoRegistros.map(listadoRegistro => ({
                Id: listadoRegistro.Id,
                GRR_Fichero__c: listadoRegistro.GRR_Fichero__c,
                Name: listadoRegistro.Name,
                GRR_Caso__c: listadoRegistro.GRR_Caso__c,
                GRR_GRR__c: listadoRegistro.GRR_GRR__c,
                RecordTypeName: listadoRegistro.RecordType.Name,
                RecordTypeId: listadoRegistro.RecordType.Id,
                GRR_UR__c: listadoRegistro.GRR_UR__c,
                GRR_Vulnerabilidad__c: listadoRegistro.GRR_Vulnerabilidad__c,
                GRR_Departamento__c: listadoRegistro.GRR_Departamento__c,
                GRR_Motivos__c: listadoRegistro.GRR_Motivos__c,
                GRR_Provincia__c: listadoRegistro.GRR_Provincia__c,
                GRR_Direccion__c: listadoRegistro.GRR_Direccion__c,
                GRR_Poblacion__c: listadoRegistro.GRR_Poblacion__c,
                GRR_Comunidad__c: listadoRegistro.GRR_Comunidad__c,
                GRR_CodigoOficina__c: listadoRegistro.GRR_CodigoOficina__c,
                GRR_CodigoDAN__c: listadoRegistro.GRR_CodigoDAN__c,
                GRR_CodigoDT__c: listadoRegistro.GRR_CodigoDT__c,
                GRR_NIF__c: listadoRegistro.GRR_NIF__c,
                GRR_Intervinientes__c: listadoRegistro.GRR_Intervinientes__c,
                GRR_NIFs_Con_RR__c: listadoRegistro.GRR_NIFs_Con_RR__c,
                GRR_Intervinientes_Con_RR__c: listadoRegistro.GRR_Intervinientes_Con_RR__c,
                GRR_Informacion_Cliente__c: listadoRegistro.GRR_Informacion_Cliente__c, 
                GRR_ObservacionesCP__c: listadoRegistro.GRR_ObservacionesCP__c, 
                GRR_ComentariosSancionBC__c : listadoRegistro.GRR_ComentariosSancionBC__c
            }));
            
            validarMultiplesRegistros({ carga: cargaData, registros, procedenciaSeleccionada: null })
            .then(result => {
                if(result.startsWith("Error")){
                    this.mostrarToast('Error', 'Error parcial al generar', result, 'sticky'); //Se deja el toast fijo
                }else {
                    this.mostrarToastRecargar('Success', 'Éxito', result);
                }
                
                return refreshApex(this.wiredRegistros); // Actualiza aquellos registros del wiredRegistros
            }).catch(error => {
                if(error.body.message.startsWith("Aviso")){
                    this.mostrarToast('Warning', 'Aviso', error.body.message, 'dismissible'); //Modo default: el toast desaparece
                } else {
                    this.mostrarToast('Error', 'Error al generar', error.body.message, 'sticky');
                }
            });

        }  else {
            this.mostrarToast('Error', 'Error inicial', 'El fichero o los registros tienen valor null o undefined.', 'sticky');
        } 
    }

    modalTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.closeModals();
		}
	}

    closeModals() {
        this.guardando = false; 
        this.procedencia = null;

        this.template.querySelector('[data-id="comboboxProcedenciaSeleccionar"]').value = null;
		this.template.querySelectorAll('.slds-modal').forEach(modal => modal.classList.remove('slds-fade-in-open'));
		this.template.querySelector('.backdropModales').classList.remove('slds-backdrop_open');
	}

    mostrarToast(tipo, titulo, mensaje, modo) {
        const eventoToast = new ShowToastEvent({
            title: titulo,
            message: mensaje,
            variant: tipo,
            mode: modo
        });
        this.dispatchEvent(eventoToast);
        this.guardando = false;
    }

    mostrarToastRecargar(tipo, titulo, mensaje) {
        const eventoToast = new ShowToastEvent({
            title: titulo,
            message: mensaje,
            variant: tipo
        });
        this.dispatchEvent(eventoToast);

        setTimeout(() => {
            location.reload();
        }, 2500);
    }
}