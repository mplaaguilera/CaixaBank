import { LightningElement, api } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';

export default class Av_PendingTask extends NavigationMixin(LightningElement)  {
    @api task;
    @api cambioEstado=false;
    //picklist estado
	valueEstado = null;
	get optionsEstado() {
		return [
            { label: 'Actualizar estado', value: null},
			{ label: 'Gestionada negativa', value: 'Gestionada negativa' },
			{ label: 'Gestionada positiva', value: 'Gestionada positiva' },
		];
	}
	handleChangeEstado(event) {
		this.valueEstado = event.detail.value;
        if (this.valueEstado != null) {
            this.cambioEstado=true;
        }else {
            this.cambioEstado=false;
        }
        this.sendData();
	}
    //comentario
	comentario=null;
	handleChangeComentario(event) {
		this.comentario = event.detail.value;
        this.sendData();
	}
    sendData() {
        const sendDataOpp = new CustomEvent('data', {
            detail: {
                id: this.task.idRecord,
                comentario: this.comentario,
                estado: this.valueEstado
            }
        });
        this.dispatchEvent(sendDataOpp);
    }
    
    viewRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": this.task.idRecord,
                "objectApiName": "Task",
                "actionName": "view"
            },
        });
    }
}