import {LightningElement, api, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';


import RT_CASE from '@salesforce/schema/Case.RecordType.Name';
import VALORACION_AI from '@salesforce/schema/Case.CC_Valoracion_AI__c';
import MOTIVO_VALORACION from '@salesforce/schema/Case.CC_Motivo_Valoracion__c';
import RESPUESTA_ASISTENTE from '@salesforce/schema/Case.CC_Respuesta_Asistente__c';
import RESUMEN_AI from '@salesforce/schema/Case.CC_Resumen_AI__c';

//eslint-disable-next-line camelcase
export default class CC_Conversacion_IA extends LightningElement {

	@api recordId;

	campos;

	recordTypeCaso;

	// @wire(getRecord, {recordId: '$recordId', fields: [RT_CASE, VALORACION_AI]})
	// wiredValoracionCase({data, error}) {
	// 	if (data) {
	// 		this.recordTypeCaso = getFieldValue(data, RT_CASE);
	// 		this.campos = this.recordTypeCaso === 'Cliente' ? [RESPUESTA_ASISTENTE, RESUMEN_AI] : [RESUMEN_AI];
	// 		this.template.querySelector('.botonLike').classList.toggle('buttonIconVerde', getFieldValue(data, VALORACION_AI) === 'OK');
	// 		this.template.querySelector('.botonDislike').classList.toggle('buttonIconRojo', getFieldValue(data, VALORACION_AI) === 'KO');
	// 	} else if (error) {
	// 		console.error(error);
	// 	}
	// }


    @wire(getRecord, { recordId: '$recordId', fields: [RT_CASE, VALORACION_AI, RESPUESTA_ASISTENTE, RESUMEN_AI] })
    wiredValoracionCase({ data, error }) {
        if (data) {
            this.recordTypeCaso = getFieldValue(data, RT_CASE);
            const respuestaAsistenteValue = getFieldValue(data, RESPUESTA_ASISTENTE);
            const resumenAIValue = getFieldValue(data, RESUMEN_AI);

            this.campos = [
                {
                    fieldApiName: RESPUESTA_ASISTENTE.fieldApiName,
                    value: respuestaAsistenteValue,
                    label: 'Respuesta Asistente',
                    isRespuestaAsistente: false
                },
                {
                    fieldApiName: RESUMEN_AI.fieldApiName,
                    label: 'Resumen',
					value: resumenAIValue,
                    isRespuestaAsistente: true
                }
            ];
			// console.log('DPK campos', JSON.stringify(this.campos));
            this.template.querySelector('.botonLike').classList.toggle('buttonIconVerde', getFieldValue(data, VALORACION_AI) === 'OK');
            this.template.querySelector('.botonDislike').classList.toggle('buttonIconRojo', getFieldValue(data, VALORACION_AI) === 'KO');
        } else if (error) {
            console.error(error);
        }
    }

	like(event) {
		const botonLike = event.currentTarget;
		botonLike.blur();
		//if (botonLike.classList.contains('buttonIconVerde')) {
		//botonLike.classList.remove('buttonIconVerde');
		//this.actualizarValoracion('Nada');
		//} else {
		botonLike.classList.add('buttonIconVerde');
		this.template.querySelector('.botonDislike').classList.remove('buttonIconRojo');
		this.actualizarValoracion('OK');
		//}
	}

	dislike(event) {
		const botonDislike = event.currentTarget;
		botonDislike.blur();
		//if (botonDislike.classList.contains('buttonIconRojo')) {
		//botonDislike.classList.remove('buttonIconRojo');
		//this.actualizarValoracion('Nada');
		//} else
		if (this.recordTypeCaso === 'Cliente') {
			//this.template.querySelector('.botonLike').classList.remove('buttonIconVerde');
			this.template.querySelector('.modalMotivoValoracion').classList.add('slds-fade-in-open');
			this.template.querySelector('.slds-backdrop').classList.add('slds-backdrop_open');
			this.template.querySelector('lightning-input-field[data-name="motivo"]').focus();
		} else {
			this.cerrarModalesSinMotivoValoracion();
		}
	}

	actualizarValoracion(valoracion) {
		const fields = {};
		fields.Id = this.recordId;
		fields[VALORACION_AI.fieldApiName] = valoracion;
		updateRecord({fields})
			//.then(() => this.toast('success', 'Valoración actualizada', 'La valoración de la respuesta ha cambiado a "' + fields[VALORACION_AI.fieldApiName] + '"'))
			.then(() => this.toast('success', 'Valoración actualizada'))
			.catch(error => console.error(error));
	}

	valorar() {
		const inputMotivo = this.template.querySelector('lightning-input-field[data-name="motivo"]');
		if (inputMotivo.reportValidity()) {
			this.template.querySelector('.botonLike').classList.remove('buttonIconVerde');
			const fields = {};
			fields.Id = this.recordId;
			fields[MOTIVO_VALORACION.fieldApiName] = inputMotivo.value;
			fields[VALORACION_AI.fieldApiName] = 'KO';
			updateRecord({fields})
				.then(() => this.toast('success', 'Valoración actualizada'))
				.catch(error => console.error(error));
			this.template.querySelector('.botonDislike').classList.add('buttonIconRojo');
			this.cerrarModales();
		}
	}


	cerrarModalesSinMotivoValoracion() {
		this.template.querySelector('.botonLike').classList.remove('buttonIconVerde');
		this.template.querySelector('.botonDislike').classList.add('buttonIconRojo');
		this.actualizarValoracion('KO');
		this.cerrarModales();
	}

	cerrarModales() {
		this.template.querySelector('.modalMotivoValoracion').classList.remove('slds-fade-in-open');
		this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop_open');
	}

	modalTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.cerrarModales();
		}
	}

	toast(variant, title, message) {
		this.dispatchEvent(new ShowToastEvent({variant, title, message}));
	}

	recordEditFormOnload() {
		this.template.querySelector('.slds-card').classList.remove('slds-hide');
	}


}