import { LightningElement, track, api, wire} from 'lwc';
import getProcesos from '@salesforce/apex/SIR_LCMP_GetOtrosProcesos.getProcesos';

const columns = [
    { label: 'Nombre Proceso', fieldName: 'descripcion', type: 'text',hideDefaultActions: true },
    { label: 'Situación', fieldName: 'descSituacion', type: 'text',hideDefaultActions: true },
    { label: 'Fecha situación', fieldName: 'fechaSituac', type: 'text',hideDefaultActions: true },
    { label: 'Gestor', fieldName: 'empleado', type: 'text',hideDefaultActions: true },    
    { label: 'Fecha Inicio', fieldName: 'fechaInicio', type: 'text',hideDefaultActions: true },
];
export default class Sir_lwc_ProcesosAgencia extends LightningElement {
    columns = columns;
    @api recordId;
    @track sumProcesos = 0;
    otrosProcesos = [];
    @track isEmpty = true;
    @track todoOK;
    @track todoKO;
    @track mensajeError;
    @track codigoError;

    @wire(getProcesos, { idCuenta: '$recordId'}) 
    getProcesos({ error, data }) {
        if(data){
            if(data.length >= 0){
                if(data[0] == 'OK'){                    
                    var procesos = JSON.parse(data[1]);
                    procesos.listaProcesoOtrasUnidGestDto.forEach((row) => {
                        this.otrosProcesos.push(row);
                    });                
                    this.todoOK = true; 
                    this.todoKO = false; 
                    this.isEmpty = false; 
                    this.sumProcesos = this.otrosProcesos.length;
                    if(this.sumProcesos == 0){
                        this.isEmpty = true;
                    }                
                } if(data[0] == 'KO'){
                    this.mensajeError = data[1];
                    this.codigoError = data[2]; 
                    this.todoOK = false; 
                    this.todoKO = true;                   
                }
            }
        } else {
            this.mensajeError = error;
            this.todoOK = false; 
            this.todoKO = false;
        } 
    }

}