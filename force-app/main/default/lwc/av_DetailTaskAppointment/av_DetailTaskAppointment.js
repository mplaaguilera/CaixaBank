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
    buttonClassNoLocalizado = "customNoLocalizadoDefault"; 
    noLocalizadoActive = false; 
    subjectToSend;
    originToSend;
    statusToSend;
    dateToSend;
    commentToSend;
    comentToSendNoLocalizado; 
    ownerToSend; 
    tipo;
    canal;
    vinculed = false;
    classMap = {
        'check':'customCheck',
        'close':'customClose'
        ,'nolocalizado': 'customNoLocalizado'  
    }
    classMapDefault = {
        'check':'customCheckDefault',
        'close':'customCloseDefault'
        , 'nolocalizado':'customNoLocalizadoDefault'  
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
        this.ownerToSend = this.task.Owner;  
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
        if(buttonToAvoid != 'check'  ){
            this.buttonClassCheck = this.classMapDefault['check'];
        }
        if(buttonToAvoid != 'close' ){
            this.buttonClassClose = this.classMapDefault['close'];
        }
        if(buttonToAvoid != 'nolocalizado'){
            this.buttonClassNoLocalizado = this.classMapDefault['nolocalizado'];
        }
    }

    clickIcon(event){
        const buttonId = event.target.dataset.id;
        this.template.querySelector("[data-id = '"+ buttonId +"']").blur();
        this.resetCustomButtons(event.target.name);
    
        if(buttonId == 'check'){
            this.noLocalizadoActive = false;  
            if(this.buttonClassCheck == this.classMapDefault[event.target.name]){
                this.vinculed = true;
                this.buttonClassCheck = this.classMap[event.target.name];
                this.statusToSend = 'Gestionada positiva';
            }else{
                this.vinculed = false;
                this.buttonClassCheck = this.classMapDefault[event.target.name];
                this.statusToSend = this.status;
            }
        }else if(buttonId == 'close'){
            this.noLocalizadoActive = false;  
            if(this.buttonClassClose == this.classMapDefault[event.target.name]){
                this.vinculed = true;
                this.buttonClassClose = this.classMap[event.target.name];
                this.statusToSend = 'Gestionada negativa';
            }else{
                this.vinculed = false;
                this.buttonClassClose = this.classMapDefault[event.target.name];
                this.statusToSend = this.status;
            }
        }
        
        else if(buttonId == 'nolocalizado'){
            this.noLocalizadoActive = true;
            if(this.buttonClassNoLocalizado == this.classMapDefault[event.target.name]){
                this.vinculed = true;
                this.buttonClassNoLocalizado = this.classMap[event.target.name];
                this.statusToSend = 'Pendiente no localizado';
                
                const fechaYHoraActual = new Date();
                const dia = fechaYHoraActual.getDate().toString().padStart(2, '0');
                const mes = (fechaYHoraActual.getMonth() + 1).toString().padStart(2, '0'); // Se suma 1 ya que los meses van de 0 a 11
                const año = fechaYHoraActual.getFullYear();
                const fechaFormateada = `${dia}/${mes}/${año}`;
                const horas = fechaYHoraActual.getHours().toString().padStart(2, '0');
                const minutos = fechaYHoraActual.getMinutes().toString().padStart(2, '0');
                const horaFormateada = horas + ':' + minutos;
                
                this.comentToSendNoLocalizado = 'No localizado - '+horaFormateada+' - '+ fechaFormateada;  
            }else{
                this.vinculed = false;
                this.buttonClassNoLocalizado = this.classMapDefault[event.target.name];
                this.statusToSend = this.status;
            }
        }
        

        this.showComentary = this.buttonClassCheck == 'customCheck' || this.buttonClassClose == 'customClose';
        this.sendDataToController();
    }

    sendDataToController(){
        
        let comentario;
        if(this.noLocalizadoActive){
            comentario = this.comentToSendNoLocalizado
        }else{
            comentario = this.commentToSend;
        }
    
        this.dispatchEvent(
            new CustomEvent('senddatafromtask',
            {
                detail:{
                    id:this.id,
                    status:this.statusToSend,
                    comment: comentario  
                    ,owner: this.ownerToSend,
                    vinculed: this.vinculed  
                }
            })
        )
    }

    handleChangeComment(event){
        this.commentToSend = event.target.value;
        this.sendDataToController();
    }
}