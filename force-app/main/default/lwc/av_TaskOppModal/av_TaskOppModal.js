import { LightningElement, api, track } from 'lwc';
 
export default class Av_TaskOppModal extends LightningElement {

    @api isModalOpen = false;
    @api actionType;
    @api selectedItems;

    @track title;
    @track question;
    @track showSpinner = false;

    connectedCallback() {
        if(this.actionType === 'main') {
            this.title = 'Convertir a Oportunidad Principal';
            this.question = '¿Se desea convertir esta oportunidad en la oportunidad principal?';
        } else if(this.actionType === 'unlink') {
            this.title = 'Desvincular Oportunidad';
            this.question = '¿Se desea desvincular esta oportunidad del contacto actual?';
        } else if(this.actionType === 'link') {
            this.title = 'Vincular Oportunidad';
            this.question = '¿Se desea vincular esta oportunidad al contacto actual?';
        }else if(this.actionType === 'reminder'){
            this.title = 'Cambio de Estado';
            this.question = '¿Estás seguro de reportar sin hacer ningún cambio en las oportunidades?';
        }else if(this.actionType === 'oppoAsignar'){
            this.title = 'Asignar';
            this.question = '¿Estás seguro de reasignar ' + this.selectedItems + ' oportunidades?';
        }else if(this.actionType === 'taskAsignar'){
            this.title = 'Asignar';
            this.question = '¿Estás seguro de reasignar ' + this.selectedItems + ' tareas?';
        }else if(this.actionType === 'taskAsignarOtraOficina'){
            this.title = 'Asignar';
            this.question = '¿Estás seguro de reasignar ' + this.selectedItems + ' tareas a un empleado/a de otra oficina?';
        }else if(this.actionType === 'oppoAsignarOtraOficina'){
            this.title = 'Asignar';
            this.question = '¿Estás seguro de reasignar ' + this.selectedItems + ' oportunidades a un empleado/a de otra oficina?';
        }else if(this.actionType === 'noEmpleado'){
            this.title = 'Asignar';
            this.question = 'Por favor se debe seleccionar un empleado.';
        }else if(this.actionType === 'noTareas'){
            this.title = 'Asignar';
            this.question = 'Por favor, se debe seleccionar al menos una tarea.';
        }else if(this.actionType === 'noOppos'){
            this.title = 'Asignar';
            this.question = 'Por favor, se debe seleccionar al menos una oportunidad.';
        }else if(this.actionType === 'noLeadOppos'){
            this.title = 'Asignar';
            this.question = 'Por favor, se debe seleccionar al menos una Lead oportunidad.';
        }else if(this.actionType === 'leadOppAsignar'){
            this.title = 'Asignar';
            this.question = '¿Estás seguro de reasignar ' + this.selectedItems + ' Lead Oportunidades?';
        }else if(this.actionType==='leadOppAsignarOtraOficina'){
            this.title = 'Asignar';
            this.question = '¿Estás seguro de reasignar ' + this.selectedItems + ' Lead oportunidades a un empleado/a de otra oficina?';
        }
    }

    handleSave() {
        const confirmEvent = new CustomEvent('confirm', {
            detail: {
                action: this.actionType
            }
        });
        this.dispatchEvent(confirmEvent);
        //this.showSpinner = true;
    }
    
    handleCloseModal() {
        this.isModalOpen = false;
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    showToast(title, message, variant){
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant
		});
		this.dispatchEvent(event);
    }
}