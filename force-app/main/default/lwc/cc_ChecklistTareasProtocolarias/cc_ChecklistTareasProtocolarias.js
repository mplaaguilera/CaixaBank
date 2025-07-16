import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import REC_STATUS from '@salesforce/schema/Case.Status';
import REC_OWNER from '@salesforce/schema/Case.OwnerId';
import REC_MOTIVO from '@salesforce/schema/Case.CC_Motivo__c';
import cargarDatosControlAltas from '@salesforce/apex/CC_TareasProtocolarias.cargarDatosControlAltas';
import guardarControlAlta from '@salesforce/apex/CC_TareasProtocolarias.guardarControlAlta';

const fields = [REC_STATUS, REC_OWNER, REC_MOTIVO];

export default class cc_ChecklistTareasProtocolarias extends NavigationMixin(LightningElement) {

    @api recordId;

    //Controlar desplegable Control Altas
    @track toggleSeccionControlAltas = "slds-section slds-is-open";
    @track expandirControlAltas = true;

    @track estadoCaso;
    @track motivoCaso;
    @track disabledEditar = false;
    @track mapaSecciones = [];
    @track hayControlesAlta = false;
    @track listaTemasCheck = [];
    @track activarGuardar = false;
    @track spinnerLoading = false;


    connectedCallback(){
        this.cargarDatosCamposControl();  
    }

    @wire(getRecord, { recordId: '$recordId', fields })
    wiredCase({error, data}){
        if(data){
            this.estadoCaso = data.fields.Status.value;
            this.motivoCaso = data.fields.CC_Motivo__c.value;

            if(this.estadoCaso === 'Activo'){
                this.disabledEditar = false;
            }else{
                this.disabledEditar = true;
            }

            this.cargarDatosCamposControl();
        }
    }

    get mostrarBotones() {
        if(this.activarGuardar && !this.disabledEditar){
            return true;
        }else{
            return false;
        }
    }

    handleExpandirControlAltas(){
        if(this.expandirControlAltas){
            this.expandirControlAltas = false;
            this.toggleSeccionControlAltas = "slds-section";
        }else{
            this.expandirControlAltas = true;
            this.toggleSeccionControlAltas = "slds-section slds-is-open";
        }
    }

    handleChange(e) {
        if(!this.activarGuardar){
            this.activarGuardar = true;
        }

        if(e.target.checked){
            this.listaTemasCheck.push(e.target.value);
        }else{
            var index = this.listaTemasCheck.indexOf(e.target.value); 
            this.listaTemasCheck.splice(index,1);
        }
    }

    handleClickCancelar(){
        this.spinnerLoading = true;
        this.activarGuardar = false;        
        this.cargarDatosCamposControl();
    }

    handleClickGuardar(){
        this.spinnerLoading = true;
        this.activarGuardar = false;
        let listaEstados = [];
        let listaControles = [];
        for(let acc of this.mapaSecciones){
            let listadoValores = acc.value;
            for(let valor of listadoValores){
                listaControles.push(valor.idControl);
                if(this.listaTemasCheck.includes(valor.idControl)){
                    listaEstados.push(true);
                }else{
                    listaEstados.push(false);
                }
            }
        }
        guardarControlAlta({idCaso: this.recordId, motivoCaso:this.motivoCaso, listaControles : listaControles, listaEstados : listaEstados}).then(result =>{ 
            setTimeout(() => {
                this.spinnerLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Exito',
                        message: 'Se ha guardado correctamente el estado de las tareas.',
                        variant: 'success'
                    }),
                );
                refreshApex(this.mapaSecciones);
            }, 1000);
            // location.reload();
        }).catch(error =>{
            this.spinnerLoading = false;
            this.mostrarToast('error', 'ERROR', JSON.stringify(error));
        })
    }   

    mostrarToast(tipo, titulo, mensaje) {
        this.dispatchEvent(new ShowToastEvent({
            variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000
        }));
    }

    cargarDatosCamposControl(){
        this.mapaSecciones = [];
        this.listaTemasCheck = [];
        
        if(this.recordId){
            cargarDatosControlAltas({idCaso: this.recordId}).then(result =>{ 
            
                if(result){
    
                    if(this.mapaSecciones.length != 0 || this.listaTemasCheck.length != 0){
                        this.mapaSecciones = [];
                        this.listaTemasCheck = [];
                    }
    
                    this.spinnerLoading = false;
                    var conts = result;
    
                    for(var key in conts){
                        this.mapaSecciones.push({value:conts[key],key:key});
                    }                     
        
                    for(let acc of this.mapaSecciones){
                        let listadoValores = acc.value;
                        for(let valor of listadoValores){
                            if(valor.selecionadoControl){ 
                                this.listaTemasCheck.push(valor.idControl);
                            }                    
                        }
                    }  
    
                    if(this.mapaSecciones !== undefined && this.mapaSecciones.length > 0){
                        this.hayControlesAlta = true;
                    }                
    
                    refreshApex(this.mapaSecciones);
                }
                
            }).catch(error =>{
                this.spinnerLoading = false;
                this.mostrarToast('error', 'ERROR', JSON.stringify(error));
            })
        }
    }
}