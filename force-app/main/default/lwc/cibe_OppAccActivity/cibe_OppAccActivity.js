/**
 * test
 */
import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfos } from 'lightning/uiObjectInfoApi';
import events from '@salesforce/label/c.CIBE_Eventos';
import tasks from '@salesforce/label/c.CIBE_Tareas';
//import TASK_OBJECT from '@salesforce/schema/Task';
//import EVENT_OBJECT from '@salesforce/schema/Event';

import getActivities from '@salesforce/apex/CIBE_OppAccActivitiesController.getActivities';

export default class CIBE_OppAccActivities extends LightningElement {
    label = {
        events,
        tasks
    };
    /*@track columnsTask =[{ label: 'Asunto', fieldName: 'Name', type: 'url', typeAttributes: {label: { fieldName: 'Subject' }, target: '_self'}},
    { label: 'Estado', fieldName: 'Status', type:"text"},//label estado
    { label: 'Fecha Vto.', fieldName: 'ActivityDate', type:"date"},
    { label: 'Asignado A', fieldName: 'OwnerName', type:"text"}];*/
    columnsTask =[];
    columnsEvent =[];
    totalPagesTask=0;
    totalPagesEvent=0;
    pageNumberTask;
    pageNumberEvent;
    @track pageDataEvent = [];
    @track pageDataTask = [];
    /*@track columnsEvent =[{ label: 'Asunto', fieldName: 'Name', type: 'url', typeAttributes: {label: { fieldName: 'Subject' }, target: '_self'}},
    { label: 'Estado', fieldName: 'CSBDEventoEstado', type:"text"},//label estado
    { label: 'Fecha', fieldName: 'ActivityDate', type:"date"},
    { label: 'Asignado A', fieldName: 'OwnerName', type:"text"}];*/
    dataTask=[];
    taskSize=0;
    eventSize=0;
    dataEvent=[];
    @api recordId;
    @track dataTest;

  /*  @wire(getObjectInfos, {objectApiNames: [ TASK_OBJECT, EVENT_OBJECT]})
    wireObjInfos({error, dataList, pageNumber, dataPage}){
        if (dataList, pageNumber, dataPage ) {
            let objectInfo = dataList, pageNumber, dataPage.results.reduce((map, obj) => (map[obj.result.apiName] = obj, map), {});
            
            for (const field in objectInfo['Task'].result.fields) {
                console.log('field API Name = ' + field + ' ,label = ' , objectInfo['Task'].result.fields[field].label);
            }
            console.log(JSON.stringify(dataList, pageNumber, dataPage));

        }else if(error){
            //handleError
        }
    }*/

    @wire(getActivities, {oppId: '$recordId'})
    getData({error, data}){
        if(data){
            let intTask = [];
            let intEvent = [];
            console.log(JSON.stringify(data.taskLabels));
            console.log(JSON.stringify(data.eventLabels));
            //console.log(dataList, pageNumber, dataPage.taskLabels.find(label => label.name == 'subject'));
            let colIntTask = [{ label: data.taskLabels[0].value, fieldName: 'Name', type: 'url', typeAttributes: {label: { fieldName: 'Subject' }, target: '_self'}},
            { label: data.taskLabels[1].value, fieldName: 'Status', type:"text"},//label estado
            { label: data.taskLabels[2].value, fieldName: 'ActivityDate', type:"date"},
            { label: data.taskLabels[3].value, fieldName: 'OwnerName', type:"text"}];
            let colIntEvent = [{ label: data.eventLabels[0].value, fieldName: 'Name', type: 'url', typeAttributes: {label: { fieldName: 'Subject' }, target: '_self'}},
            { label: data.eventLabels[1].value, fieldName: 'CSBDEventoEstado', type:"text"},//label estado
            { label: data.eventLabels[2].value, fieldName: 'ActivityDate', type:"date"},
            { label: data.eventLabels[3].value, fieldName: 'OwnerName', type:"text"}];
            //colIntTask = this.columnsTask;
            //colIntTask[0].label = dataList, pageNumber, dataPage.taskLabels[0].value;
            this.columnsEvent = colIntEvent;
            this.columnsTask = colIntTask;
            console.log(data.taskLabels[0].name);
            this.taskSize = data.taskList.length;
            data.taskList.forEach(function(task){
                let otask = {};
                otask.OwnerName = task.Owner.Name;
                otask.ActivityDate = task.ActivityDate;
                otask.Name = '/' + task.Id;
                otask.Subject = task.Subject; 
                otask.Status = task.Status;
                intTask.push(otask);
            });
            //console.log(this.totalPagesTask);

            this.eventSize = data.eventList.length;
            data.eventList.forEach(function(event){
                let oevent = {};
                oevent.OwnerName = event.Owner.Name;
                oevent.ActivityDate = event.ActivityDate;
                oevent.Name = '/' + event.Id;
                oevent.Subject =  event.Subject;
                oevent.CSBDEventoEstado = event.status;
                intEvent.push(oevent);
            });
            this.totalPagesTask = intTask.length > 0 ? (Math.ceil(intTask.length/10)-1) : 0;
            this.pageNumberTask = 0;
            this.totalPagesEvent = intEvent.length > 0 ? (Math.ceil(intEvent.length/10)-1) : 0;
            this.pageNumberEvent = 0;
            this.pageDataTask = intTask.slice(0, 10);
            this.pageDataEvent = intEvent.slice(0, 10);
            this.dataTask = intTask;
            this.dataEvent = intEvent;
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error al obtener la actividad',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }

    previous(event) {
        if(event.target.dataset.type === "Task"){
            this.pageNumberTask = Math.max(0, this.pageNumberTask - 1);
            this.pageDataTask = this.dataTask.slice(this.pageNumberTask*10, this.pageNumberTask*10+10);
        } else {
            this.pageNumberEvent = Math.max(0, this.pageNumberEvent - 1);
            this.pageDataEvent = this.dataEvent.slice(this.pageNumberEvent*10, this.pageNumberEvent*10+10);
        }
    }
    
    first(event) {
        if(event.target.dataset.type === "Task"){
            this.pageDataTask = this.dataTask.slice(0, 10);
            this.pageNumberTask = 0;
        } else {
            this.pageDataEvent = this.dataEvent.slice(0, 10);
            this.pageNumberEvent = 0;
        }
    }
    
    next(event) {
        console.log(JSON.stringify(event.target.dataset.type));
        if(event.target.dataset.type === "Task"){
            if((this.pageNumberTask+1)<=this.totalPagesTask) {
                this.pageNumberTask = this.pageNumberTask + 1;
                this.pageDataTask = this.dataTask.slice(this.pageNumberTask*10, this.pageNumberTask*10+10);
            }
        } else {
            if((this.pageNumberEvent+1)<=this.totalPagesEvent) {
                this.pageNumberEvent = this.pageNumberEvent + 1;
                this.pageDataEvent = this.dataEvent.slice(this.pageNumberEvent*10, this.pageNumberEvent*10+10);
            }
        }
    }
    
    last(event) {
        if(event.target.dataset.type === "Task"){
            this.pageNumberTask = this.pageNumberTask = this.totalPagesTask;
            this.pageDataTask = this.dataTask.slice(this.pageNumberTask*10, this.pageNumberTask*10+10);
        } else {
            this.pageNumberEvent = this.pageNumberEvent = this.totalPagesEvent;
            this.pageDataEvent = this.dataEvent.slice(this.pageNumberEvent*10, this.pageNumberEvent*10+10);
        }
    }

    get getPageNumberTask() {
        return (this.pageNumberTask+1);
    }

    get getTotalPageNumberTask() {
        return (this.totalPagesTask+1);
    }

    get getPageNumberEvent() {
        return (this.pageNumberEvent+1);
    }

    get getTotalPageNumberEvent() {
        return (this.totalPagesEvent+1);
    }
}