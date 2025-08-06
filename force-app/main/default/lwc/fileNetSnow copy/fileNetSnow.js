import { LightningElement, api, wire } from 'lwc';
import SNOW from "@salesforce/schema/Case.SNOW_Number__c";
import TicketId from "@salesforce/schema/Case.Id";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import consultaInicial from '@salesforce/apex/COL_ConsultaDocumentosFilenet_ctrl.consultaInicial';
import verDocumento from '@salesforce/apex/COL_ConsultaDocumentosFilenet_ctrl.verDocumento';
import modifyBodyViewDocument from '@salesforce/apex/COL_ConsultaDocumentosFilenet_ctrl.modifyBodyViewDocument';
import calloutFilenet from '@salesforce/apex/COL_ConsultaDocumentosFilenet_ctrl.calloutFilenet';
import calloutFilenetCont from '@salesforce/apexContinuation/COL_ConsultaDocumentosFilenet_ctrl.calloutFilenetCont';
import convertModifyResponse from '@salesforce/apex/COL_ConsultaDocumentosFilenet_ctrl.convertModifyResponse';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const FIELDS = [SNOW, TicketId];

const columns = [
    { label: 'Documento', fieldName: 'Nombre_Documento', type: 'String', sortable: true },
    { label: 'Tipo de documento', fieldName: 'Serie_Documental', type: 'String', sortable: true },
    // { label: 'Añadido el', fieldName: 'Fecha_Alta_Documento', type: 'String', sortable: true },
    { label: 'Fecha envío SGAIM', fieldName: 'Fecha_Envio_SGAIM', type: 'String', sortable: true },
    {
        label: 'Envío',
        id: 'Envio',
        type: 'button',
        typeAttributes: {
            label: 'Envío',
            name: 'Envio',
            title: 'Envio SGAIM',
            variant: 'brand-outline',
            disabled: { fieldName: 'isEnvioDisabled' }

        }
    },
    {
        label: 'Descargar',
        id: 'Descargar',
        type: 'button',
        typeAttributes: {
            label: 'Descargar',
            name: 'Descargar',
            title: 'DescargarFileNet',
            variant: 'brand-outline',

        }
    }
];


export default class fileNetSnow extends LightningElement {
    @api recordId;
    columns = columns;
    documentos = [];
    wdata = [];
    isLoading = true;
    viewDetails = false;
    recordToSee;
    displayMessage = false;
    SNOW_Number__c = SNOW;
    Id = TicketId;
    codigoValue = '';
    messageResponse = '';
    formattedDate;

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    case(value) {
        if (value.data) {
            consultaInicial({ ticketId: value.data.fields.Id.value, SNOWNUMBER: value.data.fields.SNOW_Number__c.value })
                .then(result => {
                    console.log('result', result);
                    let data = JSON.parse(result);
                    console.log('data', data);


                    if (result !== '') {
                        this.isLoading = false;  // Termina la carga
                        // Mapeamos el array result para estructurar los datos
                        this.documentos = data.map(docs => {
                            return {
                                "Tipo_Documento": docs.Tipo_Documento ? docs.Tipo_Documento : '',
                                "Serie_Documental": docs.Serie_Documental ? docs.Serie_Documental : '',
                                "Nombre_Documento": docs.Nombre_Documento ? docs.Nombre_Documento : '',
                                //    "Fecha_Alta_Documento": docs.Fecha_Alta_Documento ? docs.Fecha_Alta_Documento : '',
                                "Fecha_Envio_SGAIM": docs.Fecha_Envio_SGAIM ? docs.Fecha_Envio_SGAIM : '',
                                "Id_FileNet": docs.Id_FileNet ? docs.Id_FileNet : '',
                                "isEnvioDisabled": docs.Fecha_Envio_SGAIM !== ''

                            };
                        });
                    }

                    else {
                        this.displayMessage = true;
                        this.messageResponse = result.messageResponse;
                    }
                })
                .catch(error => {
                    console.error('Error fetching records:', error);
                });
        }
    }

    // async downloadFile(idFilenet, serie_Documental) {
    //     console.log(idFilenet, serie_Documental);
    //     let response = '';
    //     let body = await createBodyViewDocument({ matricula: 'U1691512', fileNetId: idFilenet, serieDocumental: serie_Documental });
    //     console.log(body);
    //     calloutFilenet({ body }).then(result => {
    //         response = result;
    //         console.log(result + 'result');

    //     });
    //     console.log(response);
    // }




    async handleRowAction(event) {
        const actionName = event.detail.action.name;
        var idFileNet = '';
        idFileNet = event.detail.row.Id_FileNet;
        var EnviadoASgaim = false;
        switch (actionName) {
            case 'Envio':

                if (event.detail.row.Fecha_Envio_SGAIM != '') {
                    //console.log('ya esta enviado');
                    break;
                } else {
                    //console.log('envio');
                    await modifyBodyViewDocument({ fileNetId: event.detail.row.Id_FileNet })
                        // convertModifyResponse(calloutFilenet(modifyBodyViewDocument(idFileNet)))
                        .then(result => {
                            let data = JSON.parse(result);
                            // Verificamos que result no sea undefined, null o vacío
                            if (result !== '') {
                                this.isLoading = false;  // Termina la carga
                                if (data.code == '000') {
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: data.description,
                                            variant: 'success'
                                        })
                                    );
                                }
                                else if (data.code !== '000') {
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: data.description,
                                            message: 'Código de Error: ' + data.code,
                                            variant: 'error'
                                        })
                                    );
                                }
                            } else {
                                this.displayMessage = true;
                                this.messageResponse = result.messageResponse;
                            }

                        })
                        .catch(error => {
                            console.error('Error fetching records:', error);
                        });
                }
                break;
            case 'Descargar':
                /*
                verDocumento({ filenetId: event.detail.row.Id_FileNet, serieDocumental: event.detail.row.Serie_Documental })
                     .then(result => {
                         var doc = JSON.parse(result);
                         var link = document.createElement('a');
                         link.download = doc.Nombre + doc.Extension;
                         link.href = 'data:' + doc.MimeType + ';base64,' + doc.Content;
                         link.click()
                     });
               break;
               */
              
            await calloutFilenetCont({ filenetId: event.detail.row.Id_FileNet, serieDocumental: event.detail.row.Serie_Documental })
                        .then(result => {
                            console.log('tst ' +JSON.stringify(result));
                            var doc = JSON.parse(result);
                            var link = document.createElement('a');
                            link.download = doc.Nombre + doc.Extension;
                            link.href = 'data:' + doc.MimeType + ';base64,' + doc.Content;
                            link.click()
                        });
                break;
            // Otras acciones
        }
    }
}