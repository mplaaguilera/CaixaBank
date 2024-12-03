import { LightningElement, api, wire, track } from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import STOPPED_SINCE from '@salesforce/schema/Case.StopStartDate';
import DETENIDO_DESDE from '@salesforce/schema/Case.SAC_DetenidoDesde__c';
import STATUS from '@salesforce/schema/Case.Status';
import RECLAMACION from '@salesforce/schema/Case.SAC_Reclamacion__c';
import comprobarEstadoPausaPadre from '@salesforce/apex/SAC_LCMP_infoSla.comprobarEstadoPausaPadre';
import { NavigationMixin } from 'lightning/navigation';

export default class Sac_infoSla extends NavigationMixin(LightningElement){
    
    @api recordId;
    @track estadoActual;
    @track fechaHora;
    @track fechaDetenidoDesde;
    @track estadoPadre;
    @track reclamacionPadreId;
    @track estadoResultado;
    @track subsanacionActiva = false;

    @wire(getRecord, {recordId: '$recordId', fields: [STOPPED_SINCE,STATUS,RECLAMACION,DETENIDO_DESDE] })
    case;

    get stoppedSince(){
        this.fechaHora = getFieldValue(this.case.data, STOPPED_SINCE);
        return this.fechaHora;
    }  
    get detenidoDesde(){
        this.fechaDetenidoDesde = getFieldValue(this.case.data, DETENIDO_DESDE);
        return this.fechaDetenidoDesde;
    } 
    get status(){ 
        this.estadoActual = getFieldValue(this.case.data, STATUS);
        var estadoLabel;
        if (this.estadoActual == 'SAC_006'){
            estadoLabel = 'Subsanación';
            this.subsanacionActiva = true;
        }
        else if (this.estadoActual == 'SAC_007'){
            estadoLabel = 'Negociación';

        }else if(this.estadoActual != null){
            this.reclamacionPadreId = getFieldValue(this.case.data, RECLAMACION);
            if(this.reclamacionPadreId != null) {
                comprobarEstadoPausaPadre({ caseId: this.reclamacionPadreId })
                .then(result => {
                    this.estadoResultado = result;
                })
    
                estadoLabel = this.estadoResultado;
            }  
        }
        
        return estadoLabel;
    }    
}