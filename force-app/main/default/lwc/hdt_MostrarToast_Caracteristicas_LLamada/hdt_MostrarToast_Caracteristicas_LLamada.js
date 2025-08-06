import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import conseguirCaracteristicaContacto from '@salesforce/apex/HDT_Caracteristicas_Controller.conseguirCaracteristicaContactoLlamada';
import conseguirCaracteristicaContactoCaso from '@salesforce/apex/HDT_Caracteristicas_Controller.conseguirCaracteristicaContactoCaso';
import conseguirCaracteristicaCuentaLlamada from '@salesforce/apex/HDT_Caracteristicas_Controller.conseguirCaracteristicaCuentaLlamada';
import conseguirCaracteristicaCuentaCaso from '@salesforce/apex/HDT_Caracteristicas_Controller.conseguirCaracteristicaCuenta';


import caseId from '@salesforce/schema/Case.Id';
import cuenta from '@salesforce/schema/CC_Llamada__c.CC_Cuenta__c';
import llamadaId from '@salesforce/schema/CC_Llamada__c.Id';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

export default class Hdt_MostrarToast_Caracteristicas_LLamada extends LightningElement {

    @api recordId; 
	contactCaracteristicas = [];
    accountCaracteristicas = [];
    @api objectApiName;
    idObjeto = null;
    tipoObjeto = null;
    idCuenta = null;

    @wire(getRecord, { recordId: '$recordId', fields: '$cargarCampos' })
    wiredRecord({ error, data }) {
        if (error) {
        } else if (data) {
            if (this.objectApiName === 'Case') {
                this.idObjeto = getFieldValue(data, caseId);
                this.tipoObjeto = 'Case';
            } else {
                this.idCuenta = getFieldValue(data, cuenta);
                this.idObjeto = getFieldValue(data, llamadaId);
                this.tipoObjeto = 'Llamada';
            }

            if (this.tipoObjeto === 'Llamada') {
                this.loadContactCaracteristicasLlamada(this.idObjeto);
            }else{
                this.loadContactCaracteristicasCaso(this.idObjeto);
            }
        }
    }

    //Buscamos las Características del Contacto Asociado a esta llamada o Caso
    loadContactCaracteristicasLlamada(idLlamada) {
        conseguirCaracteristicaContacto({ idLlamada: idLlamada })
            .then(result => {
                 // Verificar si la lista tiene elementos
                if (result && result.length > 0) {
                    let caracteristicas = [];  // Lista para acumular las características
                    // Recorrer cada elemento de 'result'
                    result.forEach(item => {
                        let avisarAgente = item.CC_Caracteristica__r.CC_Avisar_agente__c;  // Cambia por el nombre del campo correcto
                
                        if (avisarAgente) {
                            caracteristicas.push(this.formatCaracteristicas([item]));
                        }
                    });
                    // Si se encontraron características que mostrar, crear el toast
                if (caracteristicas.length > 0) {
                    this.showToast('Las Características que tiene este Contacto asignadas a esta llamada son : ',  caracteristicas.join('\n'), 'warning');
                }

                    //let caracteristicas = this.formatCaracteristicas(result);
                    //this.showToast('Las Características que tiene este Contacto asignadas a esta llamada son : ', caracteristicas, 'warning');
                }
            })
            .catch(error => {
            });

        conseguirCaracteristicaCuentaLlamada({ idLlamada: idLlamada })
            .then(result => {
                 // Verificar si la lista tiene elementos
            if (result && result.length > 0) {
                let caracteristicas = [];  // Lista para acumular las características
                // Recorrer cada elemento de 'result'
                result.forEach(item => {
                    let avisarAgente = item.CC_Caracteristica__r.CC_Avisar_agente__c;  // Cambia por el nombre del campo correcto
               
                    if (avisarAgente) {
                        caracteristicas.push(this.formatCaracteristicas([item]));
                    }
                });
                // Si se encontraron características que mostrar, crear el toast
            if (caracteristicas.length > 0) {
                this.showToast('Las Características que tiene este Cuenta asignadas a este llamada son : ',  caracteristicas.join('\n'), 'warning');
            }

                    //let caracteristicas = this.formatCaracteristicas(result);
                    //this.showToast('Las Características que tiene este Cuenta asignadas a este llamada son : ', caracteristicas, 'warning');
                }
            })
            .catch(error => {
            });
    }

    //Buscamos las Características del Contacto Asociado a esta llamada o Caso
    loadContactCaracteristicasCaso(idCaso) {
        conseguirCaracteristicaContactoCaso({ idCaso: idCaso })
            .then(result => {
                 // Verificar si la lista tiene elementos
            if (result && result.length > 0) {
                let caracteristicas = [];  // Lista para acumular las características
                // Recorrer cada elemento de 'result'
                result.forEach(item => {
                    let avisarAgente = item.CC_Caracteristica__r.CC_Avisar_agente__c;  // Cambia por el nombre del campo correcto
               
                    if (avisarAgente) {
                        caracteristicas.push(this.formatCaracteristicas([item]));
                    }
                });
                // Si se encontraron características que mostrar, crear el toast
            if (caracteristicas.length > 0) {
                this.showToast('Las Características asignadas a este Contacto en el CASO son:',  caracteristicas.join('\n'), 'warning');
            }
                }
            })
            .catch(error => {
                
            });

        conseguirCaracteristicaCuentaCaso({ idCaso: idCaso })
            .then(result => {
                 // Verificar si la lista tiene elementos
            if (result && result.length > 0) {
                let caracteristicas = [];  // Lista para acumular las características
                // Recorrer cada elemento de 'result'
                result.forEach(item => {
                    let avisarAgente = item.CC_Caracteristica__r.CC_Avisar_agente__c;  // Cambia por el nombre del campo correcto
               
                    if (avisarAgente) {
                        caracteristicas.push(this.formatCaracteristicas([item]));
                    }
                });
                // Si se encontraron características que mostrar, crear el toast
            if (caracteristicas.length > 0) {
                this.showToast('Las Características que tiene este Cuenta asignadas a este CASO son : ',  caracteristicas.join('\n'), 'warning');
            }

                    //let caracteristicas = this.formatCaracteristicas(result);
                    //this.showToast('Las Características que tiene este Cuenta asignadas a este CASO son : ', caracteristicas, 'warning');
                }
            })
            .catch(error => {
                
            });
        
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            duration: 12000,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    formatCaracteristicas(caracteristicas) {
        return caracteristicas.map(caracteristica => {
            //return `Nombre: ${caracteristica.CC_Caracteristica__r.Name}, Descripción: ${caracteristica.CC_Caracteristica__r.CC_Descripcion__c}`;
            return `${caracteristica.CC_Caracteristica__r.CC_Descripcion__c}`;
        }).join('\n'); // Unir cada característica en una nueva línea
    }

    get cargarCampos() {
        console.log("cargarCampos: ", this.objectApiName);
        if (this.objectApiName === 'CC_Llamada__c') {
            return [llamadaId, cuenta];
        } else {
            return [caseId];
        }

    };
}