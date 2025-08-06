import { LightningElement, track, wire,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAgrupadores from '@salesforce/apex/CC_Llamada_Caso_Nuevo_Controller.getAgrupadores';
import crearCasoLlamadamasiva from '@salesforce/apex/CC_Llamada_Caso_Nuevo_Controller.crearCasoLlamadaMasiva';
import devolverMensaje from '@salesforce/apex/CC_Llamada_Caso_Nuevo_Controller.devolverMensaje';

export default class Hdt_llamada_caso_a_masiva extends NavigationMixin(LightningElement) {
    @track agrupadoresOptions = [];
    selectedAgrupador = '';
    @track caseId = '';
    @track isLoading = false;
    @track spinner = false;
    @api recordId;
    @api llamada; // Recibe el objeto llamada desde el padre

    nombreMasiva = '';

        // Obtener los Agrupadores desde Apex
        @wire(getAgrupadores)
        wiredAgrupadores({ error, data }) {
            if (data) {
                this.agrupadoresOptions = data.map(agrupador => ({
                    label: agrupador.CC_Titulo__c,
                    value: agrupador.Id
                }));
            } else if (error) {
                this.showToast('Error', 'No se pudieron cargar los agrupadores', 'error');
            }
        }


        // Manejar cambio en el combobox
        handleAgrupadorChange(event) {
            this.selectedAgrupador = event.detail.value;
        }

         //Llamada para la creacion del caso   
         async handleAsociarMasiva() {
            if (!this.selectedAgrupador) {
                this.showToast('Error', 'Selecciona un agrupador antes de crear un caso', 'error');
                return;
            }
 
            if (!this.llamada?.CC_Cuenta__c && !this.llamada?.CC_No_Identificado__c) {
                this.showToast('info', 'Llamada no identificada', 'Debes identificar previamente al cliente o marcar la llamada como "No se identifica"');
                return;
            }
            
            if (this.llamada?.CC_Fecha_Fin__c && !this.llamada?.HDT_Desborde__c) {
                this.showToast('info', 'Llamada finalizada', 'No se permite crear un caso desde una llamada finalizada');
                return;
            }
    
            this.isLoading = true;
            this.spinner = true;

            try {
                const retorno = await devolverMensaje({ recordId: this.llamada.Id });
                if (retorno) {
                    this.showToast(
                        'info',
                        'Ya existe un caso para esta llamada',
                        `No es posible crear un caso nuevo, ya hay uno abierto para esta llamada (caso ${retorno.CaseNumber})`,
                        retorno.getMensaje            
                    );
                    const closeEvent = new CustomEvent('closemodal');
                    this.dispatchEvent(closeEvent);

                } else {
                    
                    if (!this.selectedAgrupador) {
                        this.showToast('Error', 'Selecciona un agrupador antes de crear un caso', 'error');
                        return;
                    }
                    const miagrupadorId = String(this.selectedAgrupador || '');
                    const caso = await  crearCasoLlamadamasiva({ recordId: this.llamada.Id ,agrupadorId: miagrupadorId });
    
                    this.dispatchEvent(new CustomEvent('casocreado', { detail: caso }));
                    this.showToast('Enorabuena', 'El caso se ha creado correctamente', `Se creó correctamente el caso ${caso.CaseNumber}`);

                     
                    if (caso && caso.Id) {
                        this.openSubtabCaso(caso.Id);
                    } else {
                        this.showToast('Error', 'No se pudo abrir el caso porque el ID no está definido', 'error');
                    }

                    // Disparar evento para cerrar el modal en Aura
                    const closeEvent = new CustomEvent('closemodal');
                    this.dispatchEvent(closeEvent);

                    //this.openSubtabCaso(caso.Id);

                }
            } catch (error) {
                this.showToast('error', 'Problema creando caso', error?.body?.message || 'Error desconocido');
            } finally {
                
                this.isLoading = false;
                this.spinner = false;
            }
            
        }

        // Mostrar notificaciones
        showToast(title, message, variant) {
            const event = new ShowToastEvent({
                title,
                message,
                variant
            });
            this.dispatchEvent(event);
        }

        handleClose() {
                this.dispatchEvent(new CustomEvent('close'));
        }

        openSubtabCaso(idCaso) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: idCaso,
                    objectApiName: 'Case',
                    actionName: 'view'
                }
            });
        }






}