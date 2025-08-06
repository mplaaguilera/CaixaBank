import { LightningElement, track, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
//Campos reclamación
import OWNERID_FIELD from '@salesforce/schema/Case.OwnerId';
import IDFIELD from '@salesforce/schema/Case.Id';
import TIPO_REPRESENTANTE_FIELD from '@salesforce/schema/Case.SAC_TipoDeRepresentante__c';
import NUMERO_DOCUMENTO_FIELD from '@salesforce/schema/Case.SAC_NumeroDelDocumento__c';


//Campos Case Extension
import DESPACHO_REPRESENTANTE_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SAC_DespachoRepresentante__c';
import EXTENSION_CASE from '@salesforce/schema/Case.CBK_Case_Extension_Id__c';

//Llamadas Apex
import obtenerValoresDespachoRepresentante from '@salesforce/apex/SAC_LCMP_DespachoRepresentante.obtenerValoresDespachoRepresentante';
import guardarDespachoRepresentante from '@salesforce/apex/SAC_LCMP_DespachoRepresentante.guardarDespachoRepresentante';
import verSiGestorLetrado from '@salesforce/apex/SAC_LCMP_DespachoRepresentante.verSiGestorLetrado';
import comprobarCaractRepresentante from '@salesforce/apex/SAC_LCMP_DespachoRepresentante.comprobarCaractRepresentante';

const fields = [IDFIELD, OWNERID_FIELD, DESPACHO_REPRESENTANTE_FIELD, EXTENSION_CASE, TIPO_REPRESENTANTE_FIELD,NUMERO_DOCUMENTO_FIELD];

export default class Sac_DespachoRepresentante extends LightningElement {

    @api recordId;
    @track caso;
    @track idCaso;
    @track owner;
    @track editarDespacho = true;
    @track editandoCampo = false;
    @track datosCargados = false;
    @track picklistDespachoValues;
    @track despachoSeleccionado = '';   //Aquí se almacena la cadena que indica el nombre del despacho seleccionado
    @track spinnerLoading = false;

    @track sePuedeEditarDespacho = false;   //Solo se podrá editar el despacho si el tipo de representante es Abogado y se es el Gestor
    @track sePuedeVerDespacho = true;   //Ahora el despacho se mostrará siempre
    @track despachoVacio = false;
    @track despachoActual = null;

    @track esGestorLetrado = false;
    @track esGestor = false;
    @track esLetrado = false;
    @track esCOPSAJ = false;

    @track listaCaracteristicas;
    @track mostrarCaracteristicas = false;

    @wire(getRecord, {recordId: '$recordId', fields: fields})
    wiredCase({error, data}){
        if(data){
            this.caso = data;
            this.idCaso = data.fields.Id.value;
            this.owner = data.fields.OwnerId.value;
            this.datosCargados = true;
            this.editandoCampo = false;     //Cuando se carga, se pone en modo de lectura, no de edición


            verSiGestorLetrado({'idCaso': this.recordId, 'ownerCaso': this.owner}).then(resultado=>{
                if(resultado){
                    this.esGestor = resultado.esUsuarioGestor;
                    this.esLetrado = resultado.esUsuarioLetrado;
                    this.esCOPSAJ = resultado.esUsuarioCOPSAJ;
                }
                //Actualmente, se muestra el campo aunque no sea abogado, pero si no es abogado, no permitirá editar
                if(this.caso.fields.SAC_TipoDeRepresentante__c.value === 'SAC_Abogado'){
                    //this.sePuedeVerDespacho = true;
                    //Comprobar si se podrá editar el despacho
                    if(this.esGestor == true || this.esLetrado == true || this.esCOPSAJ == true){
                        this.sePuedeEditarDespacho = true;
                    }else{
                        this.sePuedeEditarDespacho = false;
                    }
                }else{
                    //this.sePuedeVerDespacho = false;
                    this.sePuedeEditarDespacho = false;
                    this.mostrarCaracteristicas = false;
                    this.listaCaracteristicas = null;
                }

                //Comprobar si se podrá editar el despacho
                /*if(this.caso.fields.SAC_TipoDeRepresentante__c.value === 'SAC_Abogado' && this.esGestor == true){
                   this.sePuedeEditarDespacho = true;
                }else{
                    this.sePuedeEditarDespacho = false;
                }*/

                //En caso de que el despacho representante esté vacío, controlar que no se muestre el espacio en blanco
                if(this.caso.fields.CBK_Case_Extension_Id__r.value.fields.SAC_DespachoRepresentante__c.value == null || this.caso.fields.CBK_Case_Extension_Id__r.value.fields.SAC_DespachoRepresentante__c.value == undefined){
                    this.despachoVacio = true;
                    this.despachoActual = null;
                }else{
                   this.despachoActual = this.caso.fields.CBK_Case_Extension_Id__r.value.fields.SAC_DespachoRepresentante__c.value;
                   this.despachoVacio = false;
                }


                if(this.caso.fields.CBK_Case_Extension_Id__r.value.fields.SAC_DespachoRepresentante__c.value != null || this.caso.fields.SAC_NumeroDelDocumento__c.value != null ){
                    comprobarCaractRepresentante({'documento': this.caso.fields.SAC_NumeroDelDocumento__c.value, 'despacho': this.caso.fields.CBK_Case_Extension_Id__r.value.fields.SAC_DespachoRepresentante__c.value}).then(resultado=>{
                        if(resultado != null){
                            this.listaCaracteristicas = resultado;
                            this.mostrarCaracteristicas = true;
                        }else{
                            this.listaCaracteristicas = null;
                            this.mostrarCaracteristicas = false;
                        }

                    }).catch(error =>{
                        this.isLoading = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: JSON.stringify(error),
                                variant: 'error'
                            }),);
                    });
                }else{
                    this.listaCaracteristicas = null;
                    this.mostrarCaracteristicas = false;
                }




            }).catch(error =>{
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

    @wire(obtenerValoresDespachoRepresentante)
    wiredDespachosRepresentantes(result){
        if(result.data){
            this.picklistDespachoValues = result.data.map(item => ({
                label: item,
                value: item
            }));

            //Solo se añade el valor --None-- en caso de que haya algún valor para seleccionar en la picklist
            if(this.picklistDespachoValues.length !== 0){
                const valorNone = {
                    label: '--None--',
                    value: '--None--'
                }

                this.picklistDespachoValues.unshift(valorNone); //Añade el valor de None al principio del array
            }

        }
    }



    //Controlar cuando se pulsa en editar el despacho para que se muestren los valores de despachos a elegir
    handleEditarCampos(event){
        if(this.editandoCampo == false){
            this.editandoCampo = true;
        }else{
            this.editandoCampo = false;
        }
    }


    //Cada vez que se seleccione un valor de la "picklist", se actualiza el valor de despachoSeleccionado
    handleChangeDespacho(event){
        const selectedValue = event.detail.value;
        const selectedOption = this.picklistDespachoValues.find(option => option.value === selectedValue);
        this.despachoSeleccionado = selectedOption.label;
    }


    //Cuando se pusle guardar, se actualiza el campo de despacho representante
    handleGuardarDespacho(event){
        this.spinnerLoading = true;
        guardarDespachoRepresentante({'despachoSeleccionado': this.despachoSeleccionado, 'idCaso': this.idCaso}).then(()  => {
            this.lanzarToast('Éxito', 'Se han aplicado los cambios.', 'success');
            this.dispatchEvent(new RefreshEvent());         //Refresca para que se muestre el valor seleccionado
            this.editandoCampo = false;
            this.spinnerLoading = false;
            this.dispatchEvent(new CustomEvent('force:refreshView'));
        })
        .catch(error => {
            this.lanzarToast('Error', 'Error al actualizar el despacho representante.', 'error');
        });
    }

    
    lanzarToast(titulo, mensaje, variante) {
        const toastEvent = new ShowToastEvent({
            title: titulo,
            message: mensaje,
            variant: variante
        });
        this.dispatchEvent(toastEvent);
    }


}