import { LightningElement, track, api } from 'lwc';

//Labels Error Copado
import productRequiredLabel from '@salesforce/label/c.AV_ProductoObligatorio';
import dateNextGestLabel from '@salesforce/label/c.AV_FechaProximaGestion';
import validateOppCommReqLabel from '@salesforce/label/c.AV_ValidateOppCommentReq';
import oppStagPotenLabel from '@salesforce/label/c.AV_LabelFlowStage';
import oppNameLabel from '@salesforce/label/c.AV_ValidateOppName';
import controlDateRecLabel from '@salesforce/label/c.AV_controlFechaRecordatorio';

	
export default class Av_NewOpportunity extends LightningElement {

    @api defaultStage;
    @api pfId;
    @api accountId;

    @track isModalOpen = false;
    @track allStages = [];


    @track _producto;
    @track _oportunidad;

    @track _path;
    @track _fechagestion;
    @track _comentario;
    @track _entidad;
    @track _fechavencimiento;
    @track _importe;
    @track _interes;
    @track _incluir;
    @track _cuota;
    @track _matricula;
    @track _otraentidad;
    @track _otraentidadpick;
    @track _fechaActivacion;
    @track _potencial;
    @track _owner;
    @track _contact;
    @track _resolucion;
    @track _margin;
    @track _amount;
    @track _byProduct;
    @track _validationError;
    

    //para enviarlos al flow:
    @api
    get resolucion(){
        return this._resolucion;
    }
    @api 
    get contact(){
        return this._contact;
    }
    @api
    get owner(){
        return this._owner;
    }
    @api
    get potencial(){

        return this._potencial;
    }
    @api
    get producto(){
        if (this._producto=='') {
            return null;
        }   
        return this._producto;
    }

    @api
    get oportunidad(){
 
        return this._oportunidad;
    }
    @api
    get path(){
        return this._path;
    }
    @api
    get fechagestion(){
        
        return this._fechagestion;
    }
    @api
    get comentario(){

        return this._comentario;
    }
    @api
    get entidad(){
        return this._entidad;
    }
    @api
    get fechavencimiento(){
        return this._fechavencimiento;
    }
    @api
    get importe(){
       
        return this._importe;
    }
    @api
    get interes(){
        return this._interes;
    }
    @api
    get incluir(){
        return this._incluir;
    }
    @api
    get cuota(){
        return this._cuota;
    }
    @api
    get matricula(){
        return this._matricula;
    }
    @api
    get otraentidad(){
        return this._otraentidad;
    }
    @api
    get otraentidadpick(){
        return this._otraentidadpick;
    }
    @api 
    get fechaActivacion(){

        return this._fechaActivacion;
    }
    @api 
    get margin(){

        return this._margin;
    }
    @api 
    get amount(){

        return this._amount;
    }
    @api
    get byProduct(){
        if (this._byProduct=='') {
            return null;
        }   
        return this._byProduct;
    }
    @api
    get validationError(){
        return this._validationError;
    }
    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    submitDetails() {
        this.isModalOpen = false;
    }
    
	handleData(event) { //trae del hijo
        this._path = event.detail.path;
        this._fechagestion = event.detail.fechagestion;
        this._comentario = event.detail.comentario;
        this._entidad = event.detail.entidad;
        this._fechavencimiento = event.detail.fechavencimiento;
        this._importe = event.detail.importe;
        this._interes = event.detail.interes;
        this._incluir = event.detail.incluir;
        this._producto = event.detail.producto;
        this._oportunidad = event.detail.oportunidad;
        this._cuota = event.detail.cuota;
        this._matricula = event.detail.matricula;
        this._otraentidad = event.detail.otraentidad;
        this._otraentidadpick = event.detail.otraentidadpick;
        this._fechaActivacion= event.detail.fechaActivacion;
        this._potencial = event.detail.potencial;
        this._owner= event.detail.owner;
        this._contact = event.detail.contact;     
        this._resolucion = event.detail.resolucion;   
        this._margin = event.detail.margin;   
        this._amount = event.detail.amount; 
        this._byProduct = event.detail.byProduct; 
        this._validationError = event.detail.validationError;

	}

    handleProducto(event){
        this._producto=event.target.value;
    }
    handleOportunidad(event){
        this._oportunidad=event.target.value;
    }


    @api
    validate() {

        let errorValidations = false;
        let errorMessageV;
        let returnOk = {isValid: true };
        let returnKo;

        if(!this._producto){
            errorValidations = true;
            errorMessageV = productRequiredLabel;
        }

        if(!this._oportunidad){
            errorValidations = true;
            errorMessageV = oppNameLabel;
        }

        if(!this._fechagestion && (this._path == 'En gestión/insistir' || this._path == 'No apto')){
            errorValidations = true;
            errorMessageV = dateNextGestLabel;
        }

        if(this._path == 'Potencial'){
            errorValidations = true;
            errorMessageV = oppStagPotenLabel;
        }

        if(this._resolucion == 'O' && !this._comentario){
            errorValidations = true;
            errorMessageV = validateOppCommReqLabel;	
        }

        let currentDate = new Date().toJSON().slice(0, 10);
        if(this._incluir && this._fechagestion < currentDate){ 
            errorValidations = true;
            errorMessageV = controlDateRecLabel; 
        }
 
        if(errorMessageV) {
            returnKo = {
                isValid: false,
                errorMessage: errorMessageV
            };
        }

        if(!errorValidations) {
            return returnOk;
        }else {
            return returnKo;
        }    
    }
}