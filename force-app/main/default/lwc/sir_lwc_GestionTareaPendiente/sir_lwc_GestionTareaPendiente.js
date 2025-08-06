import { LightningElement, wire, api, track } from 'lwc';
import {refreshApex} from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import uId from '@salesforce/user/Id';
import getTipoTarea from '@salesforce/apex/SIR_LCMP_GestionTareaPendiente.getTipoTarea';
import puedeGestionar from '@salesforce/apex/SIR_LCMP_GestionTareaPendiente.puedeGestionar';

export default class Sir_lwc_GestionTareaPendiente extends LightningElement {
    @api recordId;

    @track proceso;
    @track idTarea;
    @track tipoTarea;
    @track codTarea;
    @track tituloTarea;
    @track tipoSEL_DAT = false;
    @track tipoACT = false;
    @track tipoCTL = false;
    @track tipoOPC = false;
    @track tipoOPCListaContratos = false;
    @track tipoDAT_EE = false;

    primeraVez = true;
    primeraVezAccion = true;
    primeraVezCTLoCTLAccion = true; // Variable que indica si es la primera vez que pasa por una CTL normal o por una CTL Accion
    recordtypeProceso = ''; // Variable donde guardaremos el recordtype.Name de Proceso
    userId = uId;

    tareaReapertura = false;

    gestiona;
    sincronizado;
    
    @track wiredResult = [];

    connectedCallback(){
        setTimeout(() => {             
            puedeGestionar({idProceso: this.recordId}).then(result => { 
                this.gestiona = result;
                if(!this.gestiona){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'No tiene permisos para gestionar este Proceso.',
                            variant: 'error'
                        })
                    );
                    // Ponemos un timeout para que haya tiempo para leer el mensaje
                    setTimeout(() => {
                        this.dispatchEvent(new CloseActionScreenEvent());
                        window.location.reload();
                    }, 1500);
                } else {
                    this.sincronizado = true;  
                }        
            })
            .catch(error => {
                console.log('Error puedeGestionar');
                console.log(error);
            });      
        }, 100);              
    }


    @wire(getTipoTarea, {
        idProceso: '$recordId', sincronizado: '$sincronizado'
    })wiredProceso(result) {
        this.wiredResult = result;
        if(result.data){            
            this.proceso = result.data;            
            this.idTarea = this.proceso[0].SIREC__SIREC_fld_tarea__c;            
            if(this.idTarea == null || this.idTarea === undefined || this.idTarea === ''){
                //En caso de que el WF no traiga siguiente tarea cerraremos el pop-up y haremos refresh para actualizar la pantalla
                this.closeQuickAction();
            } else{ 
                // Si no existe SIREC__SIREC_fld_tareaOPCPendiente__c entonces utilizamos SIREC__SIREC_fld_tarea__c 
                if(this.proceso[0].SIREC__SIREC_fld_tareaOPCPendiente__c == null || this.proceso[0].SIREC__SIREC_fld_tareaOPCPendiente__c === undefined || this.proceso[0].SIREC__SIREC_fld_tareaOPCPendiente__c === ''){
                    this.tipoTarea = this.proceso[0].SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tipo_tarea__c;                    
                    this.codTarea = this.proceso[0].SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_codigo_tarea__c;
                    this.tituloTarea = this.proceso[0].SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tituloInfo__c;
                } else {
                    // En caso de que exista SIREC__SIREC_fld_tareaOPCPendiente__c entonces utilizamos SIREC__SIREC_fld_tareaOPCPendiente__c
                    this.tipoTarea = this.proceso[0].SIREC__SIREC_fld_tareaOPCPendiente__r.SIREC__SIREC_fld_tipo_tarea__c;                    
                    this.codTarea = this.proceso[0].SIREC__SIREC_fld_tareaOPCPendiente__r.SIREC__SIREC_fld_codigo_tarea__c;
                    this.tituloTarea = this.proceso[0].SIREC__SIREC_fld_tareaOPCPendiente__r.SIREC__SIREC_fld_tituloInfo__c;
                }               
                this.recordtypeProceso = this.proceso[0].RecordType.Name;
                if(this.tipoTarea === 'DAT' || this.tipoTarea === 'SEL'){
                    // Si es tarea DAT y el codigoTarea contiene 'DAT-EE' se llamará al LWC de Documentos EE
                    if(this.tipoTarea === 'DAT' && this.codTarea.includes('DAT-EE')){
                        // Ponemos la variable primeraVezCTLoCTLAccion a false para cuando se inicie el flujo desde una DAT-EE no aparezca despues la pregunta del reabrir
                        this.primeraVezCTLoCTLAccion = false;
                        this.tipoDAT_EE = true;
                        this.tipoSEL_DAT = false;
                        this.tipoACT = false;
                        this.tipoCTL = false;
                        this.tipoOPC = false;  
                        this.tipoOPCListaContratos = false;           
                    } else {
                        // Si el titulo de la tarea es '¿Desea reabrir gestión?' y no es proceso pressol ponemos variable a True
                        if(this.recordtypeProceso !== 'PRESOL' && this.tituloTarea === '¿Desea reabrir gestión?'){                            
                            this.tareaReapertura = true; 
                        } else {
                            this.tareaReapertura = false; 
                        }
                        // Si no es presol se considera cualquier SEL/DAT como ctl para que no anide, ya que si hay sel pendiente sincro anidaria y no queremos
                        if(this.recordtypeProceso !== 'PRESOL'){
                            this.primeraVezAccion = false;
                            this.primeraVezCTLoCTLAccion = false;
                        }
                        this.tipoSEL_DAT = true;
                        this.tipoACT = false;
                        this.tipoCTL = false;
                        this.tipoOPC = false;
                        this.tipoOPCListaContratos = false;
                        // Solo se llama a esa funcion cuando se anidan dos sel seguidas (para lanzar el wire de nuevo)
                        if(this.primeraVez === false){
                            this.handleRefrescarDatos();
                        } 
                    }
                    
                } else if(this.tipoTarea === 'CTL' && this.codTarea.includes('CTL-SFACC') || this.tipoTarea === 'CTL' && this.codTarea.includes('CTL-FEPEC')){
                    // Si detecta que la CTL es de tipo Accion
                    // PRESOL - Si es la primera vez que detecta una ctl de tipo accion, mostramos la accion
                    // NO PRESOL - Si es la primera vez que detecta una ctl (normal o accion) mostramos accion, pero si se detecta que ya ha mostrado una ctl normal se cierra modal
                    // NO PRESOL Y tareaReapertura == true - se anida
                    if((this.recordtypeProceso === 'PRESOL' && this.primeraVezAccion === true) || (this.recordtypeProceso !== 'PRESOL' && this.primeraVezCTLoCTLAccion === true) 
                        || (this.recordtypeProceso !== 'PRESOL' && this.tareaReapertura === true) ){                        
                        this.primeraVezAccion = false;
                        this.primeraVezCTLoCTLAccion = false;                        
                        this.tipoSEL_DAT = false;
                        this.tipoACT = true;
                        this.tipoCTL = false;
                        this.tipoOPC = false;  
                        this.tipoOPCListaContratos = false;   
                        if(this.recordtypeProceso !== 'PRESOL' && this.tareaReapertura === true){
                            this.tareaReapertura = false;
                        }                   
                    } else {
                        // Si es la segunda vez que detecta una ctl de tipo accion, paramos de anidar
                        this.closeQuickAction();
                    }                      
                } else if(this.tipoTarea === 'CTL'||this.tipoTarea === 'BAT'){ 
                    if(this.tituloTarea !== '' && this.tituloTarea !== undefined){
                        // Si el titulo de la tarea es 'reapertura' y no es proceso pressol ponemos variable a True
                        if(this.recordtypeProceso !== 'PRESOL' && this.tituloTarea.includes('reapertura')){                            
                           this.tareaReapertura = true; 
                        } else {
                            this.tareaReapertura = false; 
                        }
                        // Si detecta que la ctl es de Reabrir gestion y no es la primera vez, cierra la anidacion
                        // Si detecta que es la segunda CTL (ya sea de normal o accion) y no es PRESOL, cierra la anidacion
                        if( (this.recordtypeProceso !== 'PRESOL' && this.primeraVezCTLoCTLAccion === false) ||
                          (this.recordtypeProceso === 'PRESOL' && this.primeraVez === false && (this.tituloTarea.includes('reapertura') || this.tituloTarea.includes('Proceso finalizado') ) )  ){
                            this.closeQuickAction();
                        } else {
                            // Si es una CTL normal se anida
                            this.primeraVezCTLoCTLAccion = false;
                            this.tipoSEL_DAT = false;
                            this.tipoACT = false;
                            this.tipoCTL = true;
                            this.tipoOPC = false;
                            this.tipoOPCListaContratos = false;
                        }
                    }                        
                } else if(this.tipoTarea === 'OPC' && (!this.codTarea.includes('OPC-FEACP') && !this.codTarea.includes('OPC-FEPLP')) ){
                    // Ponemos la variable primeraVezCTLoCTLAccion a false para cuando se inicie el flujo desde una OPC no aparezca despues la pregunta del reabrir
                    this.primeraVezCTLoCTLAccion = false;
                    this.tipoSEL_DAT = false;
                    this.tipoACT = false;
                    this.tipoCTL = false;
                    this.tipoOPC = true;
                    this.tipoOPCListaContratos = false;

                    // OPC Seleccion Contratos para AcuerdoPago o PlanPago --> 'OPC-FEACPA' 'OPC-FEPLPA' 'OPC-FEACP2' 'OPC-FEPLP2'
                } else if(this.tipoTarea === 'OPC' && (this.codTarea.includes('OPC-FEACP') || this.codTarea.includes('OPC-FEPLP')) ){
                    // Ponemos la variable primeraVezCTLoCTLAccion a false para cuando se inicie el flujo desde una OPC no aparezca despues la pregunta del reabrir
                    this.primeraVezCTLoCTLAccion = false;
                    this.tipoSEL_DAT = false;
                    this.tipoACT = false;
                    this.tipoCTL = false;
                    this.tipoOPC = false;
                    this.tipoOPCListaContratos = true;
                }
            }          
        }        
    }

    handleRefrescarDatos(){
        // Llamamos a una funcion del hijo c-sir_lwc_-Form-S-E-L-D-A-T para que realice el wire
        setTimeout(() => { 
            this.template.querySelector('c-sir_lwc_-Form-S-E-L-D-A-T').refrescarDatos();
          }, 100);  
        //this.template.querySelector('c-sir_lwc_-Tarea-C-T-L').refrescarDatos();
    }

    calcularTarea(){
        this.primeraVez = false;
        refreshApex(this.wiredResult); 
    }

    closeQuickAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
        window.location.reload();
    }
}