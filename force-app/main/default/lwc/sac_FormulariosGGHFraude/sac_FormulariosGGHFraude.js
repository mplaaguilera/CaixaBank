import { LightningElement, api, wire, track } from 'lwc';
import getFicherosByCaseId from '@salesforce/apex/SAC_FormulariosGGHFraude.getFormulariosByCaseId';

export default class formularioList extends LightningElement {
    @api recordId;
    formulariosRT
    @track hasFormularios = false;

    // Get related Formularios
    @wire(getFicherosByCaseId, { recId: '$recordId' })
    wiredformularios({ error, data }) {
        if (data) {
            this.formulariosRT = Object.keys(data).map(recordTypeDevName => {
                this.hasFormularios = true;
                let tableTitle;
                if (recordTypeDevName === 'SAC_Formulario_GGH') {
                    tableTitle = 'Gastos Hipotecarios';
                } else if (recordTypeDevName === 'SAC_Formulario_Fraude') {
                    tableTitle = 'Fraude';
                }
                return {
                    tableTitle,
                    gghRT: recordTypeDevName === 'SAC_Formulario_GGH',
                    fraudeRT: recordTypeDevName === 'SAC_Formulario_Fraude',
                    formularios: data[recordTypeDevName].map(formulario => {
                        return {
                            ...formulario,
                        };
                    })
                };
            });
        } else if (error) {
            this.formulariosRT = undefined;
            this.hasFormularios = false;
        }
    }
}