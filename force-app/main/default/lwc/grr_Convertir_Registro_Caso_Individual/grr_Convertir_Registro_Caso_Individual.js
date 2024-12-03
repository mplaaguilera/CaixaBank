import { LightningElement, api, wire } from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Métodos Apex
import validarRegistroIndividual from '@salesforce/apex/GRR_Convertir_Registro_Caso_Controller.validarRegistroIndividual'; 

//Campos Registro
import REGISTRO_ID from '@salesforce/schema/GRR_RegistroCarga__c.Id';
import REGISTRO_FICHERO from '@salesforce/schema/GRR_RegistroCarga__c.GRR_Fichero__c';
import REGISTRO_NAME from '@salesforce/schema/GRR_RegistroCarga__c.Name';
import REGISTRO_CASO from '@salesforce/schema/GRR_RegistroCarga__c.GRR_Caso__c';
import REGISTRO_GRR from '@salesforce/schema/GRR_RegistroCarga__c.GRR_GRR__c';
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




const FIELDS_REGISTRO = [REGISTRO_ID, REGISTRO_FICHERO, REGISTRO_NAME, REGISTRO_CASO, REGISTRO_GRR, REGISTRO_RECORDTYPEID, REGISTRO_UR, 
    REGISTRO_VULNERABILIDAD, REGISTRO_DEPARTAMENTO,  REGISTRO_MOTIVOS, REGISTRO_PROVINCIA, REGISTRO_DIRECCION, REGISTRO_POBLACION, REGISTRO_COMUNIDAD, REGISTRO_CODOFICINA,
    REGISTRO_CODDAN, REGISTRO_CODDT, REGISTRO_NIFS, REGISTRO_INTERVINIENTES, REGISTRO_NIFSCONRR, REGISTRO_INTERVINIENTESCONRR, REGISTRO_INFORMACIONCLIENTE, 
    REGISTRO_OBSERVACIONESCP, REGISTRO_COMENTARIOSSANCIONBC]; 

export default class grr_Convertir_Registro_A_Caso_Individual extends LightningElement {
    @api recordId;
    listadoRegistros
    tipoRegistro;
    guardando=false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS_REGISTRO })
    wiredRegistro({ error, data }) {
        if (data) {
            this.listadoRegistros = data; 
            this.tipoRegistro = getFieldValue(this.listadoRegistros, REGISTRO_RECORDTYPEID);
        } else if (error) {
            this.mostrarToast('Error', 'Problema al cargar los datos', 'Los datos del registro no se han cargado correctamente.', 'sticky');
        }
    }

    handleGenerarCasoIndividual() {
        if (this.listadoRegistros) {
            this.guardando = true;
            //Datos del objeto Registro
            const registros = [{
                Id: this.listadoRegistros.fields.Id.value,
                GRR_Fichero__c: this.listadoRegistros.fields.GRR_Fichero__c.value,
                Name: this.listadoRegistros.fields.Name.value,
                GRR_Caso__c: this.listadoRegistros.fields.GRR_Caso__c.value,
                GRR_GRR__c: this.listadoRegistros.fields.GRR_GRR__c.value,
                RecordTypeId: this.listadoRegistros.fields.RecordTypeId.value,
                GRR_UR__c: this.listadoRegistros.fields.GRR_UR__c.value,
                GRR_Vulnerabilidad__c: this.listadoRegistros.fields.GRR_Vulnerabilidad__c.value,
                GRR_Departamento__c: this.listadoRegistros.fields.GRR_Departamento__c.value,
                GRR_Motivos__c: this.listadoRegistros.fields.GRR_Motivos__c.value,
                GRR_Provincia__c: this.listadoRegistros.fields.GRR_Provincia__c.value,
                GRR_Direccion__c: this.listadoRegistros.fields.GRR_Direccion__c.value,
                GRR_Poblacion__c: this.listadoRegistros.fields.GRR_Poblacion__c.value,
                GRR_Comunidad__c: this.listadoRegistros.fields.GRR_Comunidad__c.value,
                GRR_CodigoOficina__c: this.listadoRegistros.fields.GRR_CodigoOficina__c.value,
                GRR_CodigoDAN__c: this.listadoRegistros.fields.GRR_CodigoDAN__c.value,
                GRR_CodigoDT__c: this.listadoRegistros.fields.GRR_CodigoDT__c.value,
                GRR_NIF__c: this.listadoRegistros.fields.GRR_NIF__c.value,
                GRR_Intervinientes__c: this.listadoRegistros.fields.GRR_Intervinientes__c.value,
                GRR_NIFs_Con_RR__c: this.listadoRegistros.fields.GRR_NIFs_Con_RR__c.value,
                GRR_Intervinientes_Con_RR__c: this.listadoRegistros.fields.GRR_Intervinientes_Con_RR__c.value,
                GRR_Informacion_Cliente__c: this.listadoRegistros.fields.GRR_Informacion_Cliente__c.value, 
                GRR_ObservacionesCP__c: this.listadoRegistros.fields.GRR_ObservacionesCP__c.value,
                GRR_ComentariosSancionBC__c: this.listadoRegistros.fields.GRR_ComentariosSancionBC__c.value
            }];

            validarRegistroIndividual({ registros: registros})
            .then(result => {
                if(result.startsWith("Error")){
                    this.mostrarToast('Error', 'Error parcial al generar', result, 'sticky'); //Se deja el toast fijo
                }else {
                    this.mostrarToastRecargar('Success', 'Éxito', result);
                }

                return refreshApex(this.wiredRegistro); // Actualiza el registro para el LWC
            })
            .catch(error => {
                if(error.body.message.startsWith("Aviso")){
                    this.mostrarToast('Warning', 'Aviso', error.body.message, 'dismissible'); //Modo default: el toast desaparece
                } else {
                    this.mostrarToast('Error', 'Error al generar', error.body.message, 'sticky');
                }
            });

        }  else {
            this.mostrarToast('Error', 'Error inicial', 'El registro tiene valor null o undefined.');
        } 
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