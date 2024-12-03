import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues  } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import CASO_OBJECT from '@salesforce/schema/Case'; 
import TIPODECODIGO_FIELD from '@salesforce/schema/Account.SAC_TipoDeCodigo__c';
import getRecTypeCliente from '@salesforce/apex/SPV_LCMP_BusquedaCliente.getRecTypeCliente';
import getIdentidad from '@salesforce/apex/SPV_LCMP_BusquedaCliente.getIdentidad';
import crearReclamanteSecundario from '@salesforce/apex/SPV_LCMP_BusquedaCliente.crearReclamanteSecundario';
import setClienteCaso from '@salesforce/apex/SPV_LCMP_BusquedaCliente.setClienteCaso';
import actualizarIdentificacion from '@salesforce/apex/SPV_LCMP_BusquedaCliente.actualizarIdentificacion';
import crearNoCli from '@salesforce/apex/SPV_LCMP_BusquedaCliente.crearNoCli';
import actualizarReclamanteNoCliente from '@salesforce/apex/SPV_LCMP_BusquedaCliente.actualizarReclamanteNoCliente';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import CC_NUMERO_DOCUMENTO__C_FIELD from '@salesforce/schema/Account.CC_Numero_Documento__c';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';
import PERSONMOBILEPHONE_FIELD from '@salesforce/schema/Account.PersonMobilePhone';
import PERSONEMAIL_FIELD from '@salesforce/schema/Account.PersonEmail';
import BILLINGADDRESS_FIELD from '@salesforce/schema/Account.BillingAddress';
import OFICINA_GESTORA_FIELD from '@salesforce/schema/Account.CC_OficinaGestoraId__c';
import GESTOR_FIELD from '@salesforce/schema/Account.AV_EAPGestor__c';
import OFICINA_NOMBRE_FIELD from '@salesforce/schema/Contact.CC_Nombre_Oficina__c';







const FIELDS = ['Case.CC_No_Identificado__c', 'Case.RecordType.DeveloperName', 'Case.AccountId', 'Case.SAC_CasoRelacionado__c', 'Case.OwnerId', 'Case.SAC_PretensionPrincipal__r.OwnerId']

export default class Spv_BusquedaCliente extends NavigationMixin(LightningElement) {

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



    @api recordId;


    @track sTipoBusquedaOptions = [
        { label: 'Búsqueda Global', value: 'SF' },
        { label: 'Documento de identidad', value: 'DOC' },
        { label: 'Teléfono', value: 'TEL' }
    ];
    @track oCuentas =[];
    
    @track userId;
    @track disableButton;
    @track sBusqueda;
    @track clienteNoIdentificado;
    @track sacTipoDeCaso;
    @track SAC_casoRelacionado;
    @track recordTypeNoCliente;
    @track sTipoBusqueda;
    @track sMensErr;
    @track caracteristicas;
    @track options = [];
    @track idPopUp;
    @track posicionCursor;
    @track accountIdToNavigate;


    @track esPropietario;
    @track bError;
    @track bRes;
    @track bEsperaALF;
    @track bEsperaSFDC;
    @track identificacionPrevia;
    @track bMostrarContactos;
    @track isLoading;
    @track modalCrearNoCliente;
    @track esperaInsertNoCliente;

    @track valueFname= '';
    @track valueLname='';
    @track valuePhone='';
    @track valueEmail= '';
    @track valueCodigo= '';
    @track valueNumDoc= '';
    @track valueStreet=  '';
    @track valuePostal= '';
    @track valueCity= '';
    @track valueState= '';
    @track valueCountry= '';

    connectedCallback() {
        this.sTipoBusqueda = this.sTipoBusquedaOptions[0].value;
    }
    @wire(getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: TIPODECODIGO_FIELD })
    getTipoDeCodigo({data, error}){
        if (data) {
            this.options = data.values;
            this.error = undefined;
          } else if (error) {
            this.error = error;
          }
        }
    

    @wire(getRecord, { recordId: '$recordId',  fields: FIELDS})
    wireGetRecord({data, error}){
        if(data){
            this.userId = USER_ID;
            this.identificacionPrevia = data.fields?.AccountId?.value;
            this.clienteNoIdentificado = data.fields?.CC_No_Identificado__c?.value;
            if(this.identificacionPrevia != null || this.clienteNoIdentificado == true){
                this.disableButton = true;
            }else{
                this.disableButton = false;
            }
            this.sacTipoDeCaso = data.fields.RecordType.value.fields.DeveloperName.value;
            this.SAC_casoRelacionado = data.fields?.SAC_casoRelacionado?.value;
            this.esPropietario = (data.fields?.OwnerId?.value == this.userId || data.fields?.SAC_PretensionPrincipal__r?.value?.fields?.OwnerId?.value == this.userId) ? true : false;
            getRecTypeCliente().then(result=>{
                this.recordTypeNoCliente = result;
            })
        }
    }

    handleActualizarIdentificacion() {
        this.bEsperaSFDC = true;
        actualizarIdentificacion({'recordId': this.recordId, 'noIdentificado': true, 'tipoRegistro': this.objectInfo.data.apiName}).then(()=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Éxito',
                    message: 'Cliente no se ha identificado',
                    variant: 'info'
                }),);
                this.refreshView();
                this.bEsperaSFDC = false;
        })

    }

    insertNoCliente(){

        if(this.valueFname == '' || this.valueLname == '' || this.valueCodigo == '' || this.valueNumDoc == '' ){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Faltan campos obligatorios por rellenar.',
                    variant: 'error'
                }),);
        }else{
            this.isLoading = true;
            this.modalCrearNoCliente = false;
            crearNoCli({'firstName': this.valueFname,
                'lastName': this.valueLname,
                'personEmail': this.valueEmail,
                'phone': this.valuePhone,
                'sacTipoDeCodigo': this.valueCodigo,
                'ccNumeroDocumento': this.valueNumDoc,
                'billingStreet': this.valueStreet,
                'billingPostalCode': this.valuePostal,
                'billingCity': this.valueCity,
                'billingState': this.valueState,
                'billingCountry': this.valueCountry
                }).then(result=>{
                    if(result){
                        this.esperaInsertNoCliente = true;
                        this.isLoading = false;
                        actualizarReclamanteNoCliente({'caseId': this.recordId, 'accountId': result }).then(()=>{
                            this.identificacionPrevia = true;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Éxito',
                                    message: 'Se ha insertado el registro correctamente.',
                                    variant: 'success'
                                }),);
                            this.esperaInsertNoCliente = false;
                            this.refreshView();
                            this.passDataToSPV_Reclamantes();
                        }).catch(error=>{
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Ha ocurrido un error.',
                                    variant: 'error'
                                }),);
                            this.esperaInsertNoCliente = false;

                        })
 
                    }
                }).catch(error=>{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: JSON.stringify(error),
                            variant: 'error'
                        }),);
                    this.modalCrearNoCliente = false;
                    this.isLoading = false;
                })
        }
    }


    crearNoCliente() {
        this.modalCrearNoCliente = true;
    }

    ocultarModal() {
        this.modalCrearNoCliente = false;
    }

    get isBusquedaEmpty() {
        if(this.sBusqueda == '' || this.sBusqueda == undefined){
            return true;
        }else{
            return false;
        }
    }

    handleTipoBusquedaChange(event) {
        this.sTipoBusqueda = event.detail.value;
        // Implementar lógica adicional aquí
    }

    handleValorBusquedaChange(event) {
        this.sBusqueda = event.detail.value;
        // Implementar lógica adicional aquí
    }

    handleChange(event){
        const inputId = event.target.name;
        const inputValue = event.target.value;
    
        switch (inputId) {
          case 'valueFname':
            this.valueFname = inputValue;
            break;
          case 'valueLname':
            this.valueLname = inputValue;
            break;
          case 'valuePhone':
            this.valuePhone = inputValue;
            break;
          case 'valueEmail':
            this.valueEmail = inputValue;
            break;
          case 'valueCodigo':
            this.valueCodigo = inputValue;
            break;
          case 'valueNumDoc':
            this.valueNumDoc = inputValue;
            break;
          case 'valueStreet':
            this.valueStreet = inputValue;
            break;
          case 'valuePostal':
            this.valuePostal = inputValue;
            break;
          case 'valueCity':
            this.valueCity = inputValue;
            break;
          case 'valueState':
            this.valueState = inputValue;
            break;
          case 'valueCountry':
            this.valueCountry = inputValue;
            break;
        
        }
    }

    buscarAlfabetico() {
        this.bRes = false;
        this.bMostrarContactos = false;
        // this.bMostrarRepresentantesPersonaFisica = false;
        // this.bMostrarRepresentantesPersonaJuridica = false;
        this.bError = false;
        this.bInfo = false;

        if(this.esPropietario){
            this.bEsperaALF = true;
            getIdentidad({'tipoBusqueda': this.sTipoBusqueda, 'valorBusqueda':this.sBusqueda }).then(result=>{
                if(result){
                    this.bEsperaALF = false;
                    let oMap = result;
                    if(oMap != null){
                        if(oMap.CUENTAS.length > 0){
                            this.bRes = true;
                            this.oCuentas = oMap.CUENTAS;
                        }else{
                            this.bError = true;
                            this.sMensErr = 'No se ha identificado ningun cliente';
                        }
                    }else{
                        this.bError = true;
                        this.sMensErr = 'No se ha identificado ningun cliente';
                    }
                }else{
                    this.bError = true;
                    this.sMensErr = 'Se ha producido un error al realizar la consulta.';
                }
            }).catch(error=>{
                this.bEsperaALF = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: JSON.stringify(error),
                        variant: 'error '
                    }),);
            });
            refreshView();
        }else{
            this.bError = true;
            this.sMensErr ='Debe ser propietario del registro para poder iniciar la identificación.';
        }
    }

    asociarCliente(event){
        let idAccount = event.target.name;
        // let rt = this.sacTipoDeCaso;
        if(this.bRes == true && this.identificacionPrevia != undefined){
            this.asociarSoloAccSecundario(idAccount);
        }
        if(this.bRes == true && this.identificacionPrevia == undefined){
            this.asociarSoloAcc(idAccount);
        }
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

    handleMouseover(event) {
        if(this.idPopUp != event.target.name) {
            this.idPopUp = event.target.name;

            for(let i=0; i<this.oCuentas.length; i++){
                if (this.oCuentas[i].SAC_Account__c == this.idPopUp) {
                    this.idPopUpContact = this.oCuentas[i].SAC_Account__r.AV_EAPGestor__c;
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
    
    asociarSoloAcc(event){ //REVISAR SI HAY QUE AÑADIR MAS COSAS DE SAC
        this.bEsperaSFDC = true;
        this.bRes = false;
        this.bError = false;
        this.bInfo = false;
        this.bMostrarContactos = false;
        let sCuenta = event;
        // getRepresentantesOrContactosCliente = component.get('c.getRepresentantesOrContactosCliente');
        setClienteCaso({'sID':sCuenta, 'sTipo': 'Cuenta', 'sCasoId': this.recordId }).then(()=>{
            this.bEsperaSFDC = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Éxito',
                    message: 'Se asoció correctamente la cuenta al caso.',
                    variant: 'success'
                }),);
                this.passDataToSPV_Reclamantes();
                actualizarIdentificacion({'recordId': this.recordId, 'noIdentificado': false, 'tipoRegistro': 'Case'}).then(()=>{
                this.identificacionPrevia = true;
                this.sBusqueda = ''
                this.passDataToSPV_Reclamantes();
            });
         });

        this.refreshView();

    }

    asociarSoloAccSecundario(event){
        let sCuenta = event;
        this.bEsperaSFDC = true;
        this.bRes = false;
        this.bError = false;
        this.bInfo = false;

        let sCaso = this.recordId;
        crearReclamanteSecundario({'sID': sCuenta, 'sTipo': 'Cuenta', 'sCasoId': sCaso}).then(()=>{
            this.bEsperaSFDC = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Éxito',
                    message: 'Se asoció correctamente el reclamante secundario al registro.',
                    variant: 'success'
                }),);
        }).catch(error=>{
            this.bEsperaSFDC = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: JSON.stringify(error),
                    variant: 'error'
                }),);
        });
        this.refreshView();
        this.passDataToSPV_Reclamantes();

    }


    refreshView() {
        this.dispatchEvent(new RefreshEvent());
    }

    passDataToSPV_Reclamantes() {
        const childComponent = this.template.querySelector('c-spv_-reclamantes');
        if (childComponent) {
            childComponent.receiveData(true);
        }
    }
}