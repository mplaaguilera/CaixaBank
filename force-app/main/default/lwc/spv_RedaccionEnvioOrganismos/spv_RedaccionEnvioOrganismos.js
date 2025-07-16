import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import USER_ID from '@salesforce/user/Id';
import CASO_OBJECT from '@salesforce/schema/Case'; 
import ORGANISMO_FIELD from '@salesforce/schema/Case.SPV_Organismo__c';
import OWNERID_FIELD from '@salesforce/schema/Case.OwnerId';
import { RefreshEvent } from 'lightning/refresh';
import enviarDocOrganismos from '@salesforce/apex/SPV_LCMP_RedaccionEnvioOrganismos.enviarDocOrganismos';
import getDocumentosValidados from '@salesforce/apex/SPV_LCMP_RedaccionEnvioOrganismos.getDocumentosValidados';
import comprobarPermisosUsuario from '@salesforce/apex/SPV_LCMP_RedaccionEnvioOrganismos.comprobarPermisosUsuario';

const fields = [ORGANISMO_FIELD, OWNERID_FIELD];


export default class Spv_RedaccionEnvioOrganismos extends LightningElement {
    @api recordId;

    @track isLoading = false;
    @track isCheckedEnviarReclamante = false;
    @track isCheckedEnviarOrganismos = false;
    @track mostrarOrganismo = false;
    @track organismoCaso;
    @track desactivarBotonEnviar;

    @track documentosSeleccionados = [];
    @track documentos;
    @track hayDocs = false;
    @track wiredDocumentos;
    // @track wiredPermisosUser;

    @wire(getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfo;

    @wire(getRecord, {recordId: '$recordId', fields})
    wiredCasoActual(result) {
        if(result.data){
            this.userId = USER_ID;
            this.organismoCaso = result.data.fields.SPV_Organismo__c.value;          
        }
    }

    @wire(getDocumentosValidados, {caseId: '$recordId'})
    wiredDocumentos(result){
        this.wiredDocumentos = result;
        
        if(result.data){

            this.documentos = result.data;
            if(this.documentos != null){
                this.hayDocs = true;
            }
        }
    }

    @wire(comprobarPermisosUsuario, {caseId: '$recordId', usuarioActualId: USER_ID})
    wiredPermisosUser(result){        
        if(result){
            this.desactivarBotonEnviar = !result.data;           
        }
    }
    
    handleEnviarReclamantes(event){
		this.isCheckedEnviarReclamante = event.target.checked;
	}

    handleEnviarOrganismos(event){
		this.isCheckedEnviarOrganismos = event.target.checked;

        if(this.isCheckedEnviarOrganismos) {
            this.mostrarOrganismo = true;
        }else{
            this.mostrarOrganismo = false;
        }
	}

    enviarOrganismo(){
        
        if(this.documentosSeleccionados == null || this.documentosSeleccionados == undefined || this.documentosSeleccionados == '' ){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Seleccionar documentos',
                    message: 'Debe seleccionar al menos un documento para enviar.',
                    variant: 'warning'
                })
            );
        }else if(this.isCheckedEnviarOrganismos == true && this.organismoCaso == null) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Seleccionar un valor',
                    message: 'Debe seleccionar un organismo.',
                    variant: 'warning'
                })
            );
        }
        else {
            this.isLoading = true;
            enviarDocOrganismos({'caseId': this.recordId, 'enviarReclamante': this.isCheckedEnviarReclamante, 'enviarOrganismos': this.isCheckedEnviarOrganismos, 'organismo': this.organismoCaso, 'listaSeleccionados': this.documentosSeleccionados}).then(()=>{
                this.isLoading = false;
                this.refreshView();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Envío realizado',
                        message:  "Se ha realizado el envío de la documentación a los organismos correspondientes.",
                        variant: 'success'
                    }),
                );
            }).catch(error=>{
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: JSON.stringify(error),
                        variant: 'error'
                    }),);
            });
        }
    }

    get documentosPorColumnas() {        
        if(this.documentos != '' && this.documentos != undefined){
            let sortedData = [...this.documentos];
            const sortDirection = this.sortedDirection;

       
            return sortedData.map(doc => {
                const options = { day: 'numeric', month: 'numeric', year: 'numeric', hour: 'numeric', minute: 'numeric' };
                const formattedDate = new Intl.DateTimeFormat('es-ES', options).format(new Date(doc.CreatedDate));
                return {
                    idDoc: doc.Id,
                    titulo: doc.Title,
                    formattedCreateDate: formattedDate,
                    tipoDoc: doc.SAC_TipoAdjunto__r ? doc.SAC_TipoAdjunto__r.Name : 'N/A'
                };
            });
        } 
        return [];
    }

    handleCheckboxChange(event) {

        const docId = event.target.dataset.id;
        if (event.target.checked) {
          this.documentosSeleccionados.push(docId);
          
        } else {
            this.documentosSeleccionados = this.documentosSeleccionados.filter(id => id !== docId); // Filtrar para eliminar
        }
      }

      handleRefreshClick() {
        return refreshApex(this.wiredDocumentos);
    }

    refreshView() {
        this.dispatchEvent(new RefreshEvent());
    }
}