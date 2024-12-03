import { LightningElement ,api,wire,track} from 'lwc';
import obtenerMotivos from '@salesforce/apex/HDT_MCC_Notificar_Vigentes.obtenerMotivos';
 
export default class mccDatatable extends LightningElement {
    @track rowOffset = 0;
    @track columns = [{
            label: 'Temática',
            fieldName: 'CC_Tematica_Formula__c',
            type: 'text'
        },
       
        {
            label: 'Producto/Servicio',
            fieldName: 'CC_Producto_Servicio_Formula__c',
            type: 'text'
        },
        {
            label: 'Motivo',
            fieldName: 'Name',
            type: 'text'
        },
        {
            label: 'Detalle de motivo',
            fieldName: 'CC_Detalle__c',
            type: 'text'
        },
        {
            label: 'Fecha de inicio de vigencia',
            fieldName: 'CC_Fecha_Inicio_Vigencia_Max__c',
            type: 'date'
        }
 
    ];
    @track error;
    @track data ;
    @wire(obtenerMotivos)
    wiredMCC({
        error,
        data
    }) {
        if (data) {
            this.data = data;
            console.log(data);
            console.log(JSON.stringify(data, null, '\t'));
        } else if (error) {
            this.error = error;
        }
    }
}