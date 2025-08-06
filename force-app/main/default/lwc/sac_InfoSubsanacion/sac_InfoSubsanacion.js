import { LightningElement, track, wire, api } from 'lwc';

//Llamadas Apex
import getSubsanaciones from '@salesforce/apex/SAC_LCMP_InfoSubsanaciones.getSubsanaciones';

export default class Sac_InfoSubsanacion extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track listSubsanaciones = [];
    @track mostrarSubsanaciones = false;

    //Controlar desplegable seccion principal
    @track toggleSeccionPrincipal = "slds-section slds-is-open";
    @track expandirSeccionPrincipal = true;

    //Controlar Desplegable: Subsanación
    @track toggleSeccionSubsanaciones = "slds-section slds-is-open cuerpo-subseccion";

    @track expandedSubsanaciones = new Set();

    @wire (getSubsanaciones, {'casoId': '$recordId'})
    wiredSubsanaciones({data, error}){
        if(data){
            this.listSubsanaciones = data;
            this.mostrarSubsanaciones = true;
        }
    }

    getSubsanacionClass(id) {
        return this.expandedSubsanaciones.has(id)
            ? 'slds-section slds-is-open cuerpo-subseccion'
            : 'slds-section cuerpo-subseccion';
    }

    handleExpandirSubsanacion(event) {
        const buttonid = event.currentTarget.dataset.name;
        if (this.expandedSubsanaciones.has(buttonid)) {
            this.expandedSubsanaciones.delete(buttonid);
        } else {
            this.expandedSubsanaciones.add(buttonid);
        }
        // Forzar re-render
        this.expandedSubsanaciones = new Set(this.expandedSubsanaciones);
    }

    get listSubsanacionesWithClass() {
        return this.listSubsanaciones.map(subsanacion => {
            const isOpen = this.expandedSubsanaciones.has(subsanacion.Id);
            return {
                ...subsanacion,
            sectionClass: isOpen
                    ? 'slds-section slds-is-open cuerpo-subseccion'
                    : 'slds-section cuerpo-subseccion',
                isOpen // propiedad booleana
            };
        });
    }
    
    handleExpandirSeccionPrincipal(){
        if(this.expandirSeccionPrincipal){
            this.expandirSeccionPrincipal = false;
            this.toggleSeccionPrincipal = "slds-section"; 
        }else{
            this.expandirSeccionPrincipal = true;
            this.toggleSeccionPrincipal = "slds-section slds-is-open";
        }
    }


}