import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import getCaseExtensionIdApex from '@salesforce/apex/GRR_CaseTriggerHelper.getCaseExtensionId';
import cambiarMCCporTipo from '@salesforce/apex/GRR_CaseTriggerHelper.informarCambioTipo';


import FECHA_ENVIO_DR from '@salesforce/schema/CBK_Case_Extension__c.GRR_Fecha_EnvioDT__c';
import FECHA_RECEPCION_DR from '@salesforce/schema/CBK_Case_Extension__c.GRR_Fecha_RespuestaDT__c';
import TIPO_DR from '@salesforce/schema/CBK_Case_Extension__c.GRR_Tipo_Recobro__c';
import CLASIFICACION_DR from '@salesforce/schema/CBK_Case_Extension__c.GRR_Clasificacion__c';
import SERVICIO_DR from '@salesforce/schema/CBK_Case_Extension__c.GRR_Servicio__c';
import GARANTIA_DR from '@salesforce/schema/CBK_Case_Extension__c.GRR_Garantia__c';
import ORIGEN_DR from '@salesforce/schema/CBK_Case_Extension__c.GRR_Origen__c';
import AGENCIA_DR from '@salesforce/schema/CBK_Case_Extension__c.GRR_Agencia__c';
import INGRESOS_DR from '@salesforce/schema/CBK_Case_Extension__c.GRR_Ingresos__c';
import MOTIVO_DR from '@salesforce/schema/CBK_Case_Extension__c.GRR_Motivo_Bloqueo__c';
import RESUMEN_DR from '@salesforce/schema/CBK_Case_Extension__c.GRR_Resumen_Sondeo__c';
import NUMEROEXP_DR from '@salesforce/schema/CBK_Case_Extension__c.GRR_Numero_Expediente__c';
import INFORMACION_DR from '@salesforce/schema/CBK_Case_Extension__c.GRR_Informacion_Oficina__c';
import PROPUESTA_DR from '@salesforce/schema/CBK_Case_Extension__c.GRR_Propuesta_Servicio__c';
import IDENTIFICADOR_DR from '@salesforce/schema/CBK_Case_Extension__c.GRR_Identificador_Llamada__c';
import ENTIDAD_DR from '@salesforce/schema/CBK_Case_Extension__c.GRR_Entidad__c';





export default class Grr_case_detalles_recobro extends LightningElement {

            campos = [FECHA_ENVIO_DR, FECHA_RECEPCION_DR, TIPO_DR, CLASIFICACION_DR, SERVICIO_DR, GARANTIA_DR, ORIGEN_DR, AGENCIA_DR, ENTIDAD_DR, INGRESOS_DR, MOTIVO_DR, RESUMEN_DR, NUMEROEXP_DR, INFORMACION_DR, PROPUESTA_DR, IDENTIFICADOR_DR];
            @api recordId;
        
            caseExtensionId;
        
            @wire(getCaseExtensionIdApex, {recordId: '$recordId'})
            wiredCaseExtension({data, error}) {
                if (data) {
                    this.caseExtensionId = data;
                } else if (error) {
                    console.error(error);
                }
            }

            handleSuccess(event) {
                const extensionId = event.detail.id;

                cambiarMCCporTipo({ extensionId: extensionId })
                    .then((casoModificado) => {
                        return updateRecord({
                            fields: {
                                Id: casoModificado.Id,
                                CC_MCC_Tematica__c: casoModificado.CC_MCC_Tematica__c,
                                CC_MCC_ProdServ__c: casoModificado.CC_MCC_ProdServ__c
                            }
                        });
                    })
                    .then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Actualización completa',
                                message: 'Se actualizó el caso correctamente',
                                variant: 'success'
                            })
                        );
                    })
                    .catch(error => {
                        console.error('Error al actualizar caso:', error);
                    });

                this.handleCancel(); // tu lógica para cerrar o resetear el formulario

            }

            get hasEdits() {
                return this.campos.some(c => c.isEditing);
            }

             handleEditField(event) {
                const fieldName = event.currentTarget.dataset.field;
                this.campos = this.campos.map(c => ({
                    ...c,
                    isEditing: c.fieldApiName === fieldName ? true : c.isEditing
                }));
            }

            handleCancel() {
                this.campos = this.campos.map(c => ({ ...c, isEditing: false }));
            }

            handleSubmit() {}

            handleError(event) {
                console.error('⚠️ Error al guardar:', event.detail);
            }



}