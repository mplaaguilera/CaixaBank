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
    @track listaTemasNoAplica = [];
    @track activarGuardar = false;
    @track activarGuardarNoAplica = false;
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
        if((this.activarGuardar || this.activarGuardarNoAplica) && !this.disabledEditar){
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

    handleChangeCompletada(e) {
        // Actualizar el valor de selecionadoControl
        for(let acc of this.mapaSecciones){
            let listadoValores = acc.value;
            for(let valor of listadoValores){
                if(valor.idControl === e.target.value){
                    valor.selecionadoControl = e.target.checked;
                    valor.noAplicaControl = false; // Desmarcar el otro checkbox
                    valor.disabledRazonNoAplica = true; // Deshabilitar el campo de texto
                    this.activarGuardar = true;
                    break;
                }
            }
        }

        if(e.target.checked){
            this.listaTemasCheck.push(e.target.value);
        }else{
            var index = this.listaTemasCheck.indexOf(e.target.value); 
            this.listaTemasCheck.splice(index,1);
        }

        // Actualizar listaTemasNoAplica
        var indexNoAplica = this.listaTemasNoAplica.indexOf(e.target.value); 
        if(indexNoAplica !== -1){
            this.listaTemasNoAplica.splice(indexNoAplica,1);
        }
    }

    handleChangeNoAplica(e) {
        // Actualizar el valor de noAplicaControl
        for(let acc of this.mapaSecciones){
            let listadoValores = acc.value;
            for(let valor of listadoValores){
                if(valor.idControl === e.target.value){
                    valor.noAplicaControl = e.target.checked;
                    valor.disabledRazonNoAplica = !e.target.checked || valor.desactivarControl;
                    valor.selecionadoControl = false; // Desmarcar el otro checkbox
                    this.activarGuardarNoAplica = true;
                    break;
                }
            }
        }

        if(e.target.checked){
            this.listaTemasNoAplica.push(e.target.value);
        }else{
            var index = this.listaTemasNoAplica.indexOf(e.target.value); 
            this.listaTemasNoAplica.splice(index,1);
        }

        // Actualizar listaTemasCheck
        var indexCheck = this.listaTemasCheck.indexOf(e.target.value); 
        if(indexCheck !== -1){
            this.listaTemasCheck.splice(indexCheck,1);
        }
    }

    handleClickCancelar(){
        this.spinnerLoading = true;
        this.activarGuardar = false;
        this.activarGuardarNoAplica = false;       
        this.cargarDatosCamposControl();
    }

    handleClickGuardar(){
        this.spinnerLoading = true;
        this.activarGuardar = false;
        this.activarGuardarNoAplica = false;
        let listaEstados = [];
        let listaNoAplica = [];
        let listaControles = [];
        let listaRazonNoAplica = [];
        for(let acc of this.mapaSecciones){
            let listadoValores = acc.value;
            for(let valor of listadoValores){
                listaControles.push(valor.idControl);
                listaRazonNoAplica.push(valor.razonNoAplica);
                if(this.listaTemasCheck.includes(valor.idControl)){
                    listaEstados.push(true);
                }else{
                    listaEstados.push(false);
                }
                if(this.listaTemasNoAplica.includes(valor.idControl)){
                    listaNoAplica.push(true);
                }else{
                    listaNoAplica.push(false);
                }
            }
        }
        guardarControlAlta({idCaso: this.recordId, motivoCaso:this.motivoCaso, listaControles : listaControles, listaEstados : listaEstados, listaNoAplica : listaNoAplica, listaRazonNoAplica : listaRazonNoAplica}).then(result =>{ 
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
        this.listaTemasNoAplica = []; // Agregar esta línea
        
        if(this.recordId){
            cargarDatosControlAltas({idCaso: this.recordId}).then(result =>{ 
                
                if(result){
        
                    if(this.mapaSecciones.length != 0 || this.listaTemasCheck.length != 0 || this.listaTemasNoAplica.length != 0){
                        this.mapaSecciones = [];
                        this.listaTemasCheck = [];
                        this.listaTemasNoAplica = []; // Agregar esta línea
                    }
        
                    this.spinnerLoading = false;
                    var conts = result;
        
                    for(var key in conts){
                        this.mapaSecciones.push({value:conts[key],key:key});
                    }                     
            
                    for(let acc of this.mapaSecciones){
                        let listadoValores = acc.value;
                        for(let valor of listadoValores){
                            valor.disabledRazonNoAplica = true;
                            if(valor.selecionadoControl){ 
                                this.listaTemasCheck.push(valor.idControl);
                            }
                            if(valor.noAplicaControl){ 
                                this.listaTemasNoAplica.push(valor.idControl);
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

    handleChangeRazonNoAplica(e) {
        // Actualizar el valor de razonNoAplica
        for(let acc of this.mapaSecciones){
            let listadoValores = acc.value;
            for(let valor of listadoValores){
                if(valor.idControl === e.target.dataset.id){
                    valor.razonNoAplica = e.target.value;
                    this.activarGuardar = true;
                    break;
                }
            }
        }
    }
}