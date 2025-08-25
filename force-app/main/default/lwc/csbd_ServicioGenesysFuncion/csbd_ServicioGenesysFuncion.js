    import { LightningElement, api, wire } from 'lwc';
    import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
    import { toast } from 'c/csbd_lwcUtils';

    import getServicioGenesysFuncionOptionsApex from '@salesforce/apex/CSBD_ServicioGenesysFuncionApex.getServicioGenesysFuncionOptions';

    import SVC_GENESYS_FUNCION from '@salesforce/schema/CC_Servicio_Genesys__c.CSBD_Gestion_Rellamada__c';

    export default class csbdServicioGenesysFuncion extends LightningElement {
        @api recordId;

        svcGenesys;

        options = [];

        @wire(getRecord, { recordId: '$recordId', fields: SVC_GENESYS_FUNCION })
        wiredRecord({ data, error }) {
            if (data) {
                this.svcGenesys = data;
                this.refs.inputFuncion.value = getFieldValue(data, SVC_GENESYS_FUNCION);

            } else if (error) {
                console.error('Error loading record:', result.error);
            }
        }

        @wire(getServicioGenesysFuncionOptionsApex, {})
        wiredOptions({ data, error }) {
            if (data) {
                this.options = data.map(option => ({label: option, value: option}));

            } else if (error) {
                console.error('Error loading options:', error);
            }
        }

        async guardar() {
            try {
                const botonGuardar = this.refs.botonGuardar;
                botonGuardar.disabled = true;

                const fields = {};
                fields.Id = this.recordId;
                fields.CSBD_Gestion_Rellamada__c = this.refs.inputFuncion.value;

                await updateRecord({ fields });
                this.refs.botonGuardar.classList.add('oculto');
                toast('success', 'Se actualizó oportunidad', 'Se actualizó correctamente la oportunidad');

            } catch (error) {
                console.error('Error actualizando registro', error);
                toast('error', 'Error actualizando el campo', 'error');
            }

            finally {
                botonGuardar.disabled = false;
            }
        }

        inputFuncionOnchange() {
            const botonGuardar = this.refs.botonGuardar;
            botonGuardar.disabled = false;
            botonGuardar.classList.remove('oculto');
        }
    }
