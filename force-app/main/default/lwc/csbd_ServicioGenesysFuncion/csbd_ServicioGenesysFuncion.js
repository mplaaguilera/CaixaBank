    import { LightningElement, api, wire } from 'lwc';
    import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
    import { toast } from 'c/csbd_lwcUtils';

    import getServicioGenesysFuncionOptionsApex from '@salesforce/apex/CSBD_ServicioGenesysFuncionApex.getServicioGenesysFuncionOptions';

    import SVC_GENESYS_FUNCION from '@salesforce/schema/CC_Servicio_Genesys__c.CSBD_Gestion_Rellamada__c';

    export default class csbdServicioGenesysFuncion extends LightningElement {
        @api recordId;

        svcGenesys;

        options = [];

        @wire(getRecord, {recordId: '$recordId', fields: SVC_GENESYS_FUNCION})
        wiredRecord({data, error}) {
            if (data) {
                this.svcGenesys = data;
                this.refs.inputFuncion.value = getFieldValue(data, SVC_GENESYS_FUNCION) ?? '';
            } else if (error) {
                console.error('Problema recuperando los datos del Servicio Genesys', error);
            }
        }

        @wire(getServicioGenesysFuncionOptionsApex, {})
        wiredOptions({data, error}) {
            if (data) {
                this.options = [
                    {label: 'Sin definir', value: ''},
                    ...data.map(option => ({label: option, value: option}))
                ];
            } else if (error) {
                console.error(error);
            }
        }

        async guardar() {
            const botonGuardar = this.refs.botonGuardar;
            botonGuardar.disabled = true;

            try {
                const fields = {};
                fields.Id = this.recordId;
                fields.CSBD_Gestion_Rellamada__c = this.refs.inputFuncion.value;
                await updateRecord({fields});

                this.refs.botonGuardar.classList.add('oculto');
                toast('success', 'Se actualizó Servicio Genesys', 'Se actualizó correctamente la función del Servicio Genesys');

            } catch (error) {
                console.error('Problema actualizando el Servicio Genesys', error);
                toast('error', 'Problema actualizando el Servicio Genesys', 'error');

            } finally {
                botonGuardar.disabled = false;
            }
        }

        inputFuncionOnchange({target: {value: nuevoValor}}) {
            const botonGuardar = this.refs.botonGuardar;
            botonGuardar.disabled = false;
            botonGuardar.classList.toggle('oculto', nuevoValor === getFieldValue(this.svcGenesys, SVC_GENESYS_FUNCION));
        }
    }
