import { LightningElement, api, wire, track } from 'lwc';
import recuperarReclamantes from '@salesforce/apex/SPV_LCMP_Reclamantes.recuperarReclamantes';
import eliminarReclaSecu from '@salesforce/apex/SPV_LCMP_Reclamantes.eliminarReclaSecu';
import cambiarReclaPrincipal from '@salesforce/apex/SPV_LCMP_Reclamantes.cambiarReclaPrincipal';
import tieneReclamanteSecundario from '@salesforce/apex/SPV_LCMP_Reclamantes.tieneReclamanteSecundario';
import eliminar from '@salesforce/apex/SPV_LCMP_Reclamantes.eliminar';
import eliminarYCambiarPrincipal from '@salesforce/apex/SPV_LCMP_Reclamantes.eliminarYCambiarPrincipal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import OWNERID_FIELD from '@salesforce/schema/Case.OwnerId';
import PRETPRINCIPALOWNERID_FIELD from '@salesforce/schema/Case.SAC_PretensionPrincipal__r.OwnerId';
import RECTYPE_FIELD from '@salesforce/schema/Case.RecordType.DeveloperName';
import ACCOUNTID_FIELD from '@salesforce/schema/Case.AccountId';
import CONTACTID_FIELD from '@salesforce/schema/Case.ContactId';
import SAC_CASORELACIONADO_FIELD from '@salesforce/schema/Case.SAC_CasoRelacionado__c';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import CC_NUMERO_DOCUMENTO__C_FIELD from '@salesforce/schema/Account.CC_Numero_Documento__c';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';
import PERSONMOBILEPHONE_FIELD from '@salesforce/schema/Account.PersonMobilePhone';
import PERSONEMAIL_FIELD from '@salesforce/schema/Account.PersonEmail';
import BILLINGADDRESS_FIELD from '@salesforce/schema/Account.BillingAddress';
import OFICINA_GESTORA_FIELD from '@salesforce/schema/Account.CC_OficinaGestoraId__c';
import GESTOR_FIELD from '@salesforce/schema/Account.AV_EAPGestor__c';
import OFICINA_NOMBRE_FIELD from '@salesforce/schema/Contact.CC_Nombre_Oficina__c';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import CUSTOMCSS from '@salesforce/resourceUrl/SAC_ReclamanteCSS';
import NAMECARACT_FIELD from '@salesforce/schema/CC_Caracteristica__c.Name';
import DESCCARACT_FIELD from '@salesforce/schema/CC_Caracteristica__c.CC_Descripcion__c';



const fields = [OWNERID_FIELD, PRETPRINCIPALOWNERID_FIELD, ACCOUNTID_FIELD, CONTACTID_FIELD, RECTYPE_FIELD, SAC_CASORELACIONADO_FIELD];

export default class Sac_Reclamantes extends NavigationMixin(LightningElement) {

    //Campos Account
    nameField = NAME_FIELD;
    CC_Numero_Documento__cField = CC_NUMERO_DOCUMENTO__C_FIELD;
    PhoneField = PHONE_FIELD;
    PersonMobilePhoneField = PERSONMOBILEPHONE_FIELD;
    PersonEmailField = PERSONEMAIL_FIELD;
    BillingAddressField = BILLINGADDRESS_FIELD;
    CC_OficinaGestoraId__cField = OFICINA_GESTORA_FIELD;
    CC_OficinaNombre__cField = OFICINA_NOMBRE_FIELD;
    AV_EAPGestor__cField = GESTOR_FIELD;

    namecaract = NAMECARACT_FIELD;
    descCaract = DESCCARACT_FIELD;

    //Variables componente
    @api recordId;
    @api spinnerLoading = false;
    @track options = [];
    @track idPopUp;
    @track idPopUpContact;
    @track reclamantes;
    @track reclamantePrincipal = [];
    @track reclamantesSecundarios = [];
    @track mostrarReclamantePrincipal = false;
    @track mostrarReclamanteSecundario = false;
    @track error;
    @track modalMultiplesCasos = false;
    @track idReclamantePulsado;
    @track idReclamantePrincipalEliminar;
    @track accountIdToNavigate;
    @track ventanaEliminarReclamante = false;
    @track comprobarDesdeEliminarPrinc = false;
    @track dataReceived = false;
    @track posicionCursor;
    @track caracteristicasClientes;
    @track testCaract = [];
    @track mostrarCaractPrincipal = false;
    @track mostrarCaractSecund = false;
    @track idPopUpCaract;
    @track mostrarInfo;
    @track esReclamacion = false;
    @track modalDatosNoAlf = false;
    @track telefonoNoAlf = '';
    @track emailNoAlf = '';
    @track direccionNoAlf = '';
    @track codigoPostalNoAlf = '';
    @track poblacionNoAlf = '';
    @track provinciaNoAlf = '';
    @track paisNoAlf = '';
    // @track guardarDeshabilitar = true;
    @track idReclamante = '';

    //Método con anotacion api parra recibir la comunicación del componente aura búsqueda cliente y asi refrescar
    @api receiveData(data) {
	    this.dataReceived = data;
        if (this.dataReceived) {
          window.setTimeout(() => {
            refreshApex(this._wiredResult);
            this.updateRecordView(this.recordId);
            }, 3000);
        }
	}

    _wiredResult; //Variable para recoger el resultado del metodo wired recuperarReclamantes

    @wire(getRecord, { recordId: '$recordId', fields })
    case;

    get ownerId() {
        return getFieldValue(this.case.data, OWNERID_FIELD);
    }

    get pretPrincipalOwnerId() {
        return getFieldValue(this.case.data, PRETPRINCIPALOWNERID_FIELD);
    }

    get accountId() {
        return getFieldValue(this.case.data, ACCOUNTID_FIELD);
    }

    get contactId() {
        return getFieldValue(this.case.data, CONTACTID_FIELD);
    }

    get recordType() {
        return getFieldValue(this.case.data, RECTYPE_FIELD);
    }

    get casoRelacionado() {
        return getFieldValue(this.case.data, SAC_CASORELACIONADO_FIELD);
    }

    updateRecordView(recordId) {
        updateRecord({fields: { Id: recordId }});
        
    }

    abrirSpinner() {
        this.spinnerLoading = true;
    }

    cerrarSpinner() {
        this.spinnerLoading = false;
    }

    @wire(recuperarReclamantes, { caseId: '$recordId' })
    caseReclamantes(result){
        this._wiredResult = result; 

        if(this.recordType === 'SPV_Reclamacion'){
            this.esReclamacion = true;
        }

        if (result.data) {
            this.reclamantes = result.data.listReclamantes;
            this.caracteristicasClientes = result.data.listCaracteristicas;
            //Inicializar variables de control
            this.options = [];
            this.idReclamantePulsado = null;
            this.idReclamantePrincipalEliminar = null;
            //Separamos el reclamante principal de los secundarios en dos arrays distintas y las iniciamos
            this.reclamantePrincipal = [];
            this.reclamantesSecundarios = [];
            for(let i=0; i<this.reclamantes.length; i++){
                if (this.reclamantes[i].SAC_ReclamantePrincipal__c) {
                    let listCaract = [];
                    let caractElement = [];
                    if(this.caracteristicasClientes != ''){
                        this.mostrarCaractPrincipal = true;
                        this.caracteristicasClientes.forEach(element => {
                            if(element.SAC_Cuenta__c === this.reclamantes[i].SAC_Account__c){
                                caractElement.push(element); 
                            }
                        });
                        if(this.reclamantes[i].SAC_Account__r.AV_EAPGestor__c != null) {
                            if(this.reclamantes[i].SAC_Account__r.CC_OficinaGestoraId__c != this.reclamantes[i].SAC_Account__r.AV_EAPGestor__r.AccountId && this.reclamantes[i].SAC_Account__r.CC_OficinaGestoraId__c != null && this.reclamantes[i].SAC_Account__r.AV_EAPGestor__r.AccountId != null) {
                                listCaract = Object.assign({caracteristicas : caractElement}, {OficinaDiferente : true}, this.reclamantes[i]);
                            } else {
                                listCaract = Object.assign({caracteristicas : caractElement}, {OficinaDiferente : false}, this.reclamantes[i]);
                            }
                        } else {
                            listCaract = Object.assign({caracteristicas : caractElement}, {OficinaDiferente : false}, this.reclamantes[i]);
                        }
                        this.reclamantePrincipal.push(listCaract);
                    }else{
                        let listaReclamantes = [];
                        if(this.reclamantes[i].SAC_Account__r.AV_EAPGestor__c != null) {
                            if(this.reclamantes[i].SAC_Account__r.CC_OficinaGestoraId__c != this.reclamantes[i].SAC_Account__r.AV_EAPGestor__r.AccountId && this.reclamantes[i].SAC_Account__r.CC_OficinaGestoraId__c != null && this.reclamantes[i].SAC_Account__r.AV_EAPGestor__r.AccountId != null) {
                                listaReclamantes = Object.assign({OficinaDiferente : true}, this.reclamantes[i]);
                            } else {
                                listaReclamantes = Object.assign({OficinaDiferente : false}, this.reclamantes[i]);
                            }
                        } else {
                            listaReclamantes = Object.assign({OficinaDiferente : false}, this.reclamantes[i]);
                        }  
                        this.reclamantePrincipal.push(listaReclamantes);
                    }
                } else {
                    let listCaract = [];
                    let caractElement = [];
                    if(this.caracteristicasClientes != ''){
                        this.mostrarCaractSecund = true;
                        this.caracteristicasClientes.forEach(element => {
                            if(element.SAC_Cuenta__c === this.reclamantes[i].SAC_Account__c){
                                caractElement.push(element); 
                            }
                        });
                        if(this.reclamantes[i].SAC_Account__r.AV_EAPGestor__c != null) {
                            if(this.reclamantes[i].SAC_Account__r.CC_OficinaGestoraId__c != this.reclamantes[i].SAC_Account__r.AV_EAPGestor__r.AccountId && this.reclamantes[i].SAC_Account__r.CC_OficinaGestoraId__c != null && this.reclamantes[i].SAC_Account__r.AV_EAPGestor__r.AccountId != null) {
                                listCaract = Object.assign({caracteristicas : caractElement}, {OficinaDiferente : true}, this.reclamantes[i]);
                            } else {
                                listCaract = Object.assign({caracteristicas : caractElement}, {OficinaDiferente : false}, this.reclamantes[i]);
                            }
                        } else {
                            listCaract = Object.assign({caracteristicas : caractElement}, {OficinaDiferente : false}, this.reclamantes[i]);
                        }
                        this.reclamantesSecundarios.push(listCaract);
                    }else{
                        let listaReclamantes = [];
                        if(this.reclamantes[i].SAC_Account__r.AV_EAPGestor__c != null) {
                            if(this.reclamantes[i].SAC_Account__r.CC_OficinaGestoraId__c != this.reclamantes[i].SAC_Account__r.AV_EAPGestor__r.AccountId && this.reclamantes[i].SAC_Account__r.CC_OficinaGestoraId__c != null && this.reclamantes[i].SAC_Account__r.AV_EAPGestor__r.AccountId != null) {
                                listaReclamantes = Object.assign({OficinaDiferente : true}, this.reclamantes[i]);
                            } else {
                                listaReclamantes = Object.assign({OficinaDiferente : false}, this.reclamantes[i]);
                            }
                        } else {
                            listaReclamantes = Object.assign({OficinaDiferente : false}, this.reclamantes[i]);
                        }  
                        this.reclamantesSecundarios.push(listaReclamantes);
                    }



                }
            }

            //Comprobación si debo mostrar el reclamante principal
            if(this.reclamantePrincipal.length >= 1){
                this.mostrarReclamantePrincipal = true;
            }else{
                this.mostrarReclamantePrincipal = false;
            }
            //Comprobación si debo mostrar los reclamantes secundarios
            if(this.reclamantesSecundarios.length >= 1){
                this.mostrarReclamanteSecundario = true;
                //Rellenar options combobox
                this.reclamantesSecundarios.forEach(ele =>{
                    this.options.push({label: ele.SAC_Account__r.Name , value: ele.Id});
                });
            }else{
                this.mostrarReclamanteSecundario = false;
            }

        } else if (result.error) {
            this.error = result.error.body.message;
        }
    }

    eliminarReclamanteSecundario(evt) {
        this.abrirSpinner();
        var idReclamante = evt.currentTarget.name;
        eliminarReclaSecu({ idCaso: this.recordId, ownerId: this.ownerId, pretPrincipalownerId: this.pretPrincipalOwnerId, reclamanteId: idReclamante })
            .then(result => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Reclamante secundario eliminado',
                    message: 'Reclamante eliminado con éxito',
                    variant: 'success'
                }),);
                this.cerrarSpinner();
                refreshApex(this._wiredResult);
                this.updateRecordView(this.recordId);
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'No se ha podido eliminar el reclamante',
                    message: error.body.message,
                    variant: 'error'
                }),);
                this.cerrarSpinner();
            });
    }

    comprobarOpcionCombobox(evt) {
        let desdeEliminar = true;
        if(this.idReclamantePulsado == null || this.idReclamantePulsado == '') {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Por favor, elija una opción',
                message: 'Debe elegir una opción para poder continuar',
                variant: 'warning'
            }),);
        } else if (this.idReclamantePulsado != null || this.idReclamantePulsado != '') {
            this.comprobarCasosAbiertosCliente(evt, desdeEliminar);
        }
    }

    comprobarCasosAbiertosCliente(evt, desdeEliminar) {        
        this.abrirSpinner();
        if(desdeEliminar != true) {
            this.idReclamantePulsado = evt.currentTarget.name;
        }
        //Si NO vengo de la ventana de eliminar, el reclamante pulsado tiene que ser el current target (se ha presionado el botón de cambiar a principal de un secundario)

        //Si vengo de consulta o de una reclamacion copiada, no quiero comprobar si hay casos abiertos
        if(this.recordType == 'SPV_Reclamacion'){
            if(!this.comprobarDesdeEliminarPrinc) {
                //Si el modal no se ha abierto y NO vengo de la ventana de eliminar, es porque voy a updatear el reclamante principal
                this.cambiarReclamantePrincipal();
            } else {
                //Si el modal no se ha abierto y SI que vengo de la ventana de eliminar, elimino el reclamante principal poniendo un secundario como nuevo principal
                this.eliminarCambiandoPrincipal();
            }
        }                    
    }

    cambiarReclamantePrincipal(){
        this.abrirSpinner();
        this.cerrarModalMultiplesCasos();
        cambiarReclaPrincipal({ reclamanteId : this.idReclamantePulsado })
            .then(result => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Reclamante principal cambiado',
                    message: 'Reclamante principal cambiado con éxito',
                    variant: 'success'
                }),);
                this.cerrarSpinner();
                refreshApex(this._wiredResult);
                this.updateRecordView(this.recordId);
                getRecordNotifyChange([{recordId: this.recordId}]);
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'No se ha podido cambiar el reclamante principal',
                    message: error.body.message,
                    variant: 'error'
                }),);
                this.cerrarSpinner();
            });
    }

    comprobarEliminarOElegir(evt) {
        this.abrirSpinner();
        this.idReclamantePrincipalEliminar = evt.currentTarget.name;
        tieneReclamanteSecundario({ caseId : this.recordId, ownerId: this.ownerId, pretPrincipalownerId: this.pretPrincipalOwnerId })
            .then(result => {
                if (result == true) {
                    this.abrirVentanaEliminar();
                } else {
                    this.eliminarSinCambiarPrincipal();
                }
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'No se ha podido cambiar el reclamante principal',
                    message: error.body.message,
                    variant: 'error'
                }),);
                this.cerrarSpinner();
            });
    }

    eliminarCambiandoPrincipal(evt) {
        this.abrirSpinner();
        this.cerrarModalMultiplesCasos();
        this.comprobarDesdeEliminarPrinc = false;
        eliminarYCambiarPrincipal({ caseId : this.recordId, accountId : this.accountId, idReclamanteCambiarAPrincipal : this.idReclamantePulsado })
            .then(result => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Reclamante principal eliminado',
                    message: 'Reclamante principal eliminado con éxito',
                    variant: 'success'
                }),);
                this.cerrarSpinner();
                refreshApex(this._wiredResult);
                this.updateRecordView(this.recordId);
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'No se ha podido cambiar el reclamante principal',
                    message: error.body.message,
                    variant: 'error'
                }),);
                this.cerrarSpinner();
            });
        let mantenerSpinner = true;
        this.cerrarVentanaEliminar(mantenerSpinner);
    }

    eliminarSinCambiarPrincipal() {
        eliminar({ caseId : this.recordId, accountId : this.accountId })
            .then(result => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Reclamante principal eliminado',
                    message: 'Reclamante principal eliminado con éxito',
                    variant: 'success'
                }),);
                this.cerrarSpinner();
                refreshApex(this._wiredResult);
                this.updateRecordView(this.recordId);
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'No se ha podido cambiar el reclamante principal',
                    message: error.body.message,
                    variant: 'error'
                }),);
                this.cerrarSpinner();
            });
    }

    navigateToAccount(evt) {
        this.accountIdToNavigate = evt.currentTarget.name;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": this.accountIdToNavigate,
                "objectApiName": "Account",
                "actionName": "view"
            }
        });
    }

    abrirModalMultiplesCasos() {
        this.modalMultiplesCasos = true;
    }

    cerrarModalMultiplesCasos() {
        this.modalMultiplesCasos = false;
    }

    abrirVentanaEliminar() {
        this.ventanaEliminarReclamante = true;
        this.comprobarDesdeEliminarPrinc = true;
    }

    cerrarVentanaEliminar(mantenerSpinner) {
        this.ventanaEliminarReclamante = false;
        this.comprobarDesdeEliminarPrinc = false;
        this.idReclamantePulsado = null;
        this.idReclamantePrincipalEliminar = null;
        if (mantenerSpinner != true) {
            this.cerrarSpinner();
        } 
    }
    
    renderedCallback(){
        if(this.isCssLoaded) return
        this.isCssLoaded = true;
        loadStyle(this,CUSTOMCSS).then(()=>{
        })
        .catch(error=>{
        });
    }

    handleChangeComboBox(event) {
        this.idReclamantePulsado = event.detail.value;
    }

    handleMouseover(event) {
        if(this.idPopUp != event.target.dataset.targetId) {
            this.idPopUp = event.target.dataset.targetId;

            for(let i=0; i<this.reclamantes.length; i++){
                if (this.reclamantes[i].SAC_Account__c == this.idPopUp) {
                    this.idPopUpContact = this.reclamantes[i].SAC_Account__r.AV_EAPGestor__c;
                }
            }
        }
        //Las siguiente variables recogen la posición actual del cursor
        var pY = event.clientY -135;
        var pX = event.clientX - 420;
        //Guardo en una string el estilo que quiero dar al popover para darlo
        this.posicionCursor = "top: "+pY+"px; left:"+pX+"px; position: fixed; height:350px; width:400px;";
    }
    
    handleMouseLeave(event) {
        this.idPopUp = null;
    }

    mostrarTooltip(event) {
        // this.mostrarInfo = true;
        this.mostrarInfo = event.target.dataset.targetId;
        //Las siguiente variables recogen la posición actual del cursor
        var pY = event.clientY -100;
        var pX = event.clientX - 310;
        //Guardo en una string el estilo que quiero dar al popover para darlo
        this.posicionCursor = "top: "+pY+"px; left:"+pX+"px; position: fixed; height:200px; width:300px;";
    }

    ocultarTooltip() {
        this.mostrarInfo = null;
    }

}