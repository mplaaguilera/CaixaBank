import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getRelatedTareas from '@salesforce/apex/SAC_LCMP_TareasReclamacion.getRelatedTareas'; 

const COLUMNS = [
    { label: 'Nombre', fieldName: 'tareaUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_blank'
        }
    },
    { label: 'Maestro de Acciones', fieldName: 'maestroName' },
    { label: 'Estado', fieldName: 'SAC_Estado__c' },
    { label: 'Propietario', fieldName: 'SAC_Propietario__c' }
];

const TAREA_FIELDS = ['SAC_Accion__c.SAC_Reclamacion__c'];

export default class Sac_TareasReclamacion extends LightningElement {
    @api recordId;
    reclamacionId;
    tareas;
    columns = COLUMNS;

    // Get Account Id
    @wire(getRecord, { recordId: '$recordId', fields: TAREA_FIELDS })
    wiredContact({ error, data }) {
        if (data) {
            this.reclamacionId = data.fields.SAC_Reclamacion__c.value; 
        }
    }

    // Get related Tareas
    @wire(getRelatedTareas, { reclamacionId: '$reclamacionId' })
    wiredTareas(result) {
        this.tareas = result;
        if (result.data) {
            this.tareas.data = result.data.map(tarea => {
                return{
                Id: tarea.Id,
                Name: tarea.Name,
                SAC_Estado__c: tarea.SAC_Estado__c,
                SAC_Propietario__c: tarea.SAC_Propietario__c,
                maestroName: tarea.SAC_MaestroAccionesReclamacion__c ? tarea.SAC_MaestroAccionesReclamacion__r.Name : '',
                tareaUrl: `/lightning/r/SAC_Accion__c/${tarea.Id}/view`
                };
            });
        }else if (result.error) {
            this.error = result.error;
        }
    }
}