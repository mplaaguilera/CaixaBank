import { LightningElement, api, track, wire } from 'lwc';
import getGestionesByCaseId from '@salesforce/apex/GRR_GestionController.getGestionesByCaseId';
import getGestionRecordTypeId from '@salesforce/apex/GRR_GestionController.getGestionRecordTypeId';
import { refreshApex } from '@salesforce/apex';
const MI_RECORDTYPE = 'GRR_Operacion';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Grr_operaciones_relacionadas extends NavigationMixin(LightningElement) {
    @api recordId; // Este es el ID del Case en cuya página estás
    @track showForm = false;
    gestiones = [];
    wiredGestionesResult; // para guardar el resultado y refrescar
    recordTypeId;
    //@api miRecordtype = 'GRR_Operacion';

     @wire(getGestionesByCaseId, { caseId: '$recordId', recordType:  MI_RECORDTYPE })
            wiredGestiones(result) {
                this.wiredGestionesResult = result; // ⬅️ Aquí guardamos el resultado para luego usar refreshApex
    
                const { data, error } = result;
    
                if (data) {
                    this.gestiones = data;
                } else if (error) {
                    console.error(error);
                }
             }
    
      handleShowForm() {
            this.showForm = true;
    
             getGestionRecordTypeId({recordType: MI_RECORDTYPE})
            .then(id => {
                this.recordTypeId = id;
            })
            .catch(error => {
                console.error('Error al obtener el Record Type:', error);
            });
    
        }

        handleSuccess(event) {
             // Mostrar toast
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Éxito',
                        message: 'La gestión se ha creado correctamente.',
                        variant: 'success'
                    }));

       
            this.showForm = false;

            // Opcional: emitir evento al padre o mostrar toast
            const evt = new CustomEvent('recordcreated', {
                detail: { id: event.detail.id }
            });
            this.dispatchEvent(evt);
            // Recargar los registros desde el servidor
            refreshApex(this.wiredGestionesResult);

            setTimeout(() => {
                    location.reload(); // recarga completa
                }, 1000); 
        }

         handleSubmit(event) {
            event.preventDefault(); // detener submit estándar

            const fields = event.detail.fields;
            fields.GRR_Case_Gestion__c = this.recordId; // asignar el valor oculto


            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }

          handleCancel() {
            this.dispatchEvent(new CustomEvent('close'));
            this.showForm = false;
        }

        get tituloGestiones() {
            return `Operaciones Relacionadas (${this.gestiones.length})`;
          }

          getGestionesConLinks() {
            return this.gestiones.map(g => ({
                ...g,
                link: `/lightning/r/${g.Id}/view`
            }));
        }

        get gestionesConLinks() {
            return this.gestiones
                ? this.getGestionesConLinks()
                : [];
        }

        




}