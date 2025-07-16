import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

// const fields = [IDFIELD, CASE_EXTENSION, IDRECLAMACION, RECLAMACION_EXTENSION, DECISION_PRETENSION_FIELD, ANALISISDESISTIMIENTO_FIELD, ANALISISALLANAMIENTO_FIELD, MOTIVODESISTIMIENTO_FIELD, MOTIVOALLANAMIENTO_FIELD, ENTIDADAFECTADA_FIELD];
const fields = ['Case.Id', 'Case.SAC_TipoDeRepresentante__c', 'Case.SAC_TipoDeDocumento__c', 'Case.SAC_NombreRepresentante__c', 'Case.SAC_EmailRepresentante__c',
    'Case.SAC_DespachoRepresentante__c', 'Case.SAC_NumeroDelDocumento__c', 'Case.CBK_Case_Extension_Id__c', 'Case.SAC_DireccionPostal__c', 'Case.SAC_TelefonoRepresentante__c',
    'Case.SAC_NombreContacto__c', 'Case.SAC_UsarDatos__c', 'Case.SAC_DireccionRepresentante__c', 'Case.SAC_CodigoPostalRepresentante__c', 'Case.SAC_PoblacionRepresentante__c',
    'Case.SAC_ProvinciaRepresentante__c', 'Case.SAC_PaisRepresentante__c', 'Case.SAC_PoderRepresentante__c'];

export default class Spv_RepresentanteValido extends LightningElement {
    @api recordId;
    @track caso;

    @track validarRepresentante = false;
    @track validarCampos = false;
    @track direccionPostalInformada = false;
    @track validarCheckALF = false;
    @track usarDatos = false;
    @track tipoDeDocumento = false;
    @track tipoRepresentante = false;
    @track nombreRepresentante = false;
    @track numeroDelDocumento = false;
    @track emailRepresentante = false;
    @track poderRepresentante = false;


    @wire(getRecord, { recordId: '$recordId', fields })
    wiredCase({error, data}){
        if(data){
            this.caso = data.fields;

            if(this.caso.SAC_UsarDatos__c.value === true) {
                this.usarDatos = true;
            }

            if(this.caso.SAC_TipoDeDocumento__c.value == null) {
                this.tipoDeDocumento = true;
            }

            if(this.caso.SAC_TipoDeRepresentante__c.value == null) {
                this.tipoRepresentante = true;
            }

            if(this.caso.SAC_NombreRepresentante__c.value == null) {
                this.nombreRepresentante = true;
            }

            if(this.caso.SAC_NumeroDelDocumento__c.value == null) {
                this.numeroDelDocumento = true;
            }

            if(this.caso.SAC_EmailRepresentante__c.value == null) {
                this.emailRepresentante = true;
            }

            if(this.caso.SAC_PoderRepresentante__c.value === false) {
                this.poderRepresentante = true;
            }

            let validaRep;
            //Si cualquiera de estos campos tiene información, hay que validar el representante
             if (this.caso.SAC_TipoDeRepresentante__c.value != null || this.caso.SAC_TipoDeDocumento__c.value != null || this.caso.SAC_NombreRepresentante__c.value != null ||
                this.caso.SAC_EmailRepresentante__c.value != null || this.caso.SAC_DespachoRepresentante__c.value != null || this.caso.SAC_NumeroDelDocumento__c.value != null ||
                this.caso.SAC_DireccionPostal__c.value != null || this.caso.SAC_DireccionRepresentante__c.value != null  || this.caso.SAC_CodigoPostalRepresentante__c.value != null || this.caso.SAC_PoblacionRepresentante__c.value != null ||
                this.caso.SAC_ProvinciaRepresentante__c.value != null || this.caso.SAC_PaisRepresentante__c.value != null || this.caso.SAC_TelefonoRepresentante__c.value != null || this.caso.SAC_PoderRepresentante__c.value) {
                this.validarRepresentante = true;
                validaRep = true;
            } else {
                this.validarRepresentante = false;
                validaRep = false;
            }

            //Si se tiene que validar al representante y alguno de estos campos está vacío, hay que mostrar las validaciones de los campos
            //Antes la condición después del email era &&
            if (validaRep == true && (this.caso.SAC_TipoDeRepresentante__c.value == null || this.caso.SAC_TipoDeDocumento__c.value == null || this.caso.SAC_NombreRepresentante__c.value == null || this.caso.SAC_PoderRepresentante__c.value == false ||
                this.caso.SAC_NumeroDelDocumento__c.value == null || 
                (this.caso.SAC_EmailRepresentante__c.value == null || 
                (this.caso.SAC_DireccionPostal__c.value == null || this.caso.SAC_DireccionRepresentante__c.value == null || this.caso.SAC_CodigoPostalRepresentante__c.value == null || this.caso.SAC_PoblacionRepresentante__c.value == null || this.caso.SAC_ProvinciaRepresentante__c.value == null || this.caso.SAC_PaisRepresentante__c.value == null || this.caso.SAC_PoderRepresentante__c.value == false) 
            ))) {
                this.validarCampos = true;
            } else {
                this.validarCampos = false;
            }

            //Validar nuevos campos direccion postal
            if((this.caso.SAC_DireccionRepresentante__c.value != null && this.caso.SAC_DireccionRepresentante__c.value !='' && this.caso.SAC_DireccionRepresentante__c.value != undefined) && 
                (this.caso.SAC_CodigoPostalRepresentante__c.value != null && this.caso.SAC_CodigoPostalRepresentante__c.value !='' && this.caso.SAC_CodigoPostalRepresentante__c.value != undefined) &&
                (this.caso.SAC_PoblacionRepresentante__c.value != null && this.caso.SAC_PoblacionRepresentante__c.value != '' && this.caso.SAC_PoblacionRepresentante__c.value != undefined) &&
                (this.caso.SAC_ProvinciaRepresentante__c.value != null && this.caso.SAC_ProvinciaRepresentante__c.value != '' && this.caso.SAC_ProvinciaRepresentante__c.value != undefined) && 
                (this.caso.SAC_PaisRepresentante__c.value != null && this.caso.SAC_PaisRepresentante__c.value != '' && this.caso.SAC_PaisRepresentante__c.value != undefined) ){
                this.direccionPostalInformada = true;
            }
            else{
                this.direccionPostalInformada = false;
            }

            //Si cualquiera de estos campos tiene información, y además, el check SAC_UsarDatos__c está activo, hay que mostrar el mensaje del check
            if ((this.caso.SAC_TipoDeRepresentante__c.value != null || this.caso.SAC_TipoDeDocumento__c.value != null || this.caso.SAC_NombreRepresentante__c.value != null ||
                this.caso.SAC_EmailRepresentante__c.value != null || this.caso.SAC_DespachoRepresentante__c.value != null || this.caso.SAC_NumeroDelDocumento__c.value != null ||
                this.caso.SAC_DireccionPostal__c.value != null || this.caso.SAC_TelefonoRepresentante__c.value != null || this.caso.SAC_PoderRepresentante__c.value) && this.caso.SAC_UsarDatos__c.value) {
                this.validarCheckALF = true;
            } else {
                this.validarCheckALF = false;
            }
        }
    }
}