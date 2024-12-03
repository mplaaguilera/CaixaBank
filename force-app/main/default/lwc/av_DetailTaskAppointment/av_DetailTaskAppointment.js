import { LightningElement,api, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
const FIELDS = ['Task.Id', 'Task.Subject', 'Task.Origen', 'Task.Status', 'Task.Fecha'];
export default class Av_DetailTaskAppointment extends NavigationMixin(LightningElement) {
    @api task;
    id;
    subject;
    origen;
    status;
    date;
    showComentary = false;
    buttonClassCheck = "customCheckDefault";
    buttonClassClose = "customCloseDefault";
    subjectToSend;
    originToSend;
    statusToSend;
    dateToSend;
    commentToSend;
    tipo;
    canal;
    classMap = {
        'check':'customCheck',
        'close':'customClose'
    }
    classMapDefault = {
        'check':'customCheckDefault',
        'close':'customCloseDefault'
    }

    connectedCallback(){
        this.fillVars();
    }

    fillVars(){
        this.id = this.task.Id;
        this.subject = this.task.Subject;
        this.origen = this.task.Origen;
        this.status = this.task.Status;
        this.date = this.task.Fecha;
        this.commentToSend = this.task.Comment;
        this.tipo = this.task.Tipo;
        this.canal = this.task.Canal;
    }

    navigateToRecord(event){
        let recordToGo = event.target.name;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'Task',
                recordId: recordToGo,
                actionName:'view'
            }
        })
    }

    resetCustomButtons(buttonToAvoid){

        if(buttonToAvoid != 'check' ){
            this.buttonClassCheck = this.classMapDefault['check'];
        }else if(buttonToAvoid != 'close'){
            this.buttonClassClose = this.classMapDefault['close'];
        }
    }

    clickIcon(event){
        const buttonId = event.target.dataset.id;
        this.template.querySelector("[data-id = '"+ buttonId +"']").blur();
        this.resetCustomButtons(event.target.name);
    
        if(buttonId == 'check'){
            if(this.buttonClassCheck == this.classMapDefault[event.target.name]){
                this.buttonClassCheck = this.classMap[event.target.name];
                this.statusToSend = 'Gestionada positiva';
            }else{
                this.buttonClassCheck = this.classMapDefault[event.target.name];
                this.statusToSend = this.status;
            }
        }else if(buttonId == 'close'){
            if(this.buttonClassClose == this.classMapDefault[event.target.name]){
                this.buttonClassClose = this.classMap[event.target.name];
                this.statusToSend = 'Gestionada negativa';
            }else{
                this.buttonClassClose = this.classMapDefault[event.target.name];
                this.statusToSend = this.status;
            }
        }

        this.showComentary = this.buttonClassCheck == 'customCheck' || this.buttonClassClose == 'customClose';
        this.sendDataToController();
    }

    sendDataToController(){
        this.dispatchEvent(
            new CustomEvent('senddatafromtask',
            {
                detail:{
                    id:this.id,
                    status:this.statusToSend,
                    comment:this.commentToSend
                }
            })
        )
    }

    handleChangeComment(event){
        this.commentToSend = event.target.value;
        this.sendDataToController();
    }
}