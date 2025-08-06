import { LightningElement, api, wire, track } from 'lwc';
import perteneceCOPSAJ from '@salesforce/apex/SAC_LCMP_ForzarResolucion.perteneceCOPSAJ';
import recuperarEscalados from '@salesforce/apex/SAC_LCMP_ForzarResolucion.recuperarEscalados';
import recuperarConsultas from '@salesforce/apex/SAC_LCMP_ForzarResolucion.recuperarConsultas';
import recuperarTareas from '@salesforce/apex/SAC_LCMP_ForzarResolucion.recuperarTareas';
import finalizarProcesoForzado from '@salesforce/apex/SAC_LCMP_ForzarResolucion.finalizarProcesoForzado';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASO_OBJECT from '@salesforce/schema/Case';
import { RefreshEvent } from 'lightning/refresh';

const fields = [
    'Case.Status',
    'Case.OwnerId'
];

export default class SAC_ForzarResolucion extends LightningElement {

    @api esCOPSAJ = false;
    @api recordId;
    @track tieneAsociados = false;
    @track escaladosAsociados = false;
    @track consultasAsociadas = false;
    @track tareaAsociadas = false;
    @track modalForzarResolucion = false;
	@track modalTieneAsociados = false;
    @api escalados = [];
    @api consultas = [];
    @api tareas = [];
    @track motivoCierre = '';
    @api spinnerLoading = false;
    @api requerido = false;


    _wiredResult;  
    @wire (getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfo;

    @wire(getRecord, {recordId: '$recordId', fields})
    actualCase({data, error}){
        if(data){
            this.casetInfo = data;
            this.ownerId = this.casetInfo.fields.OwnerId.value;  
        }            
    };


    @wire(perteneceCOPSAJ, {idCaso: '$recordId'}) 
    mapaPermisos(result){ 
        if(result.data){ 
            this.esCOPSAJ = result.data;          
        }
    };

    comprobarEstadoCaso(){
        this.modalForzarResolucion = true;

        recuperarEscalados({caseId: this.recordId}).then(result => {
            if(result){
                this.escalados = result;

                if(this.escalados.length === 0){
                    this.escaladosAsociados = false;
                }else{
                    this.escaladosAsociados = true;
                    this.tieneAsociados = true;
                }
            }
            })
            .catch(error => {
            const evt = new ShowToastEvent({
                title: 'Fallo al recuperar los escalados',
                message: 'error el recuperar los campos',
                variant: 'error'
            }); 
            this.dispatchEvent(evt);
        })

        recuperarConsultas({caseId: this.recordId}).then(result => {
            if(result){
                this.consultas = result;

                if(this.consultas.length === 0){
                    this.consultasAsociadas = false;
                }else{
                    this.consultasAsociadas = true;
                    this.tieneAsociados = true;
                }
            }
            })
            .catch(error => {
            const evt = new ShowToastEvent({
                title: 'Fallo al recuperar las consultas',
                message: 'error el recuperar los campos',
                variant: 'error'
            }); 
            this.dispatchEvent(evt);
        })

        recuperarTareas({caseId: this.recordId}).then(result => {
            if(result){
                this.tareas = result;

                if(this.tareas.length === 0){
                    this.tareaAsociadas = false;
                }else{
                    this.tareaAsociadas = true;
                    this.tieneAsociados = true;
                }
            }
            })
            .catch(error => {
            const evt = new ShowToastEvent({
                title: 'Fallo al recuperar las tareas',
                message: 'error el recuperar los campos',
                variant: 'error'
            }); 
            this.dispatchEvent(evt);
        })
    }

    recuperarAsociados(){
        return true;
    }

    cerrarModalForzarCierre(){
        this.modalForzarResolucion = false;
        this.motivoCierre = '';
        this.requerido = false;
    }

    handleChange( event ) {
        this.motivoCierre = event.detail.value;
    }

    confirmarForzarCierre(){
        if(this.motivoCierre === '' || this.motivoCierre === null){
            this.requerido = true;
        }else{
            this.requerido = false;
            this.modalForzarResolucion = false;
            this.spinnerLoading = true;
            
    
            finalizarProcesoForzado({caseId: this.recordId, listaEscalados: this.escalados, listaConsultas: this.consultas, listaTareas: this.tareas, motivo: this.motivoCierre}).then(result => { 
                
                //this.modalForzarResolucion = false;
                const evt = new ShowToastEvent({
                    title: 'Éxito',
                    message: 'El proceso ha terminado con éxito',
                    variant: 'success'
                });
    
                this.dispatchEvent(evt);
                this.spinnerLoading = false;
                this.motivoCierre = '';
                this.esCOPSAJ = false;
                this.dispatchEvent(new RefreshEvent());
                
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error al forzar el cierre',
                    message: error.body.pageErrors[0].message,
                    variant: 'error'
                }); 
                this.dispatchEvent(evt);
                this.spinnerLoading = false;
            })
        }
    }
}