import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';
import USER_ID from '@salesforce/user/Id';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASO_OBJECT from '@salesforce/schema/Case'; 
import compruebaPermisoSPV from '@salesforce/apex/SPV_MCC_Buscador_Controller.compruebaPermisoSPV';



const FIELDS = [
    'Case.CaseNumber', 'Case.OwnerId', 'Case.Status', 'Case.CC_MCC_Tematica__r.Name', 'Case.CC_MCC_ProdServ__r.Name', 'Case.CC_MCC_Motivo__r.Name', 'Case.RecordTypeId', 'Case.RecordType.DeveloperName', 'Case.SEG_Detalle__r.Name'
];

export default class SPV_MCC_Buscador extends LightningElement {
    @api puedeGuardar = false;
    @api mostrarBuscador = false;
    @api recordId;
    
    @track userId;
    @track esPropietario;
    @track tipoNegocio;
    @track recordTypeCase;
    @track owner;
    @track status;
    @track tematicaData;
    @track productoData;
    @track motivoData;
    @track detalleData;
    @track recordType;
    @track  isSelected = false;
    @track hayTematica = false;
    @track readOnly = false;



    @wire (getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfo;


    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredGetRecord({error, data}) {
        if (data) {
            this.userId = USER_ID;
            this.owner =  data.fields.OwnerId.value;
            this.status = data.fields.Status.value;
            this.esPropietario = this.userId === this.owner;
            this.recordType = data.fields.RecordType.value.fields.DeveloperName.value;
            this.tematicaData = data.fields?.CC_MCC_Tematica__r?.value?.fields?.Name?.value;
            this.productoData = data.fields?.CC_MCC_ProdServ__r?.value?.fields?.Name?.value;
            this.motivoData = data.fields?.CC_MCC_Motivo__r?.value?.fields?.Name?.value;
            this.detalleData = data.fields?.SEG_Detalle__r?.value?.fields?.Name?.value;

            if(this.recordType == 'SPV_Reclamacion'){
                this.readOnly = true;
            }else{
                this.readOnly = false;
            }

            
            if(this.tematicaData != null && this.tematicaData != undefined){
                this.hayTematica = true;
            }else{
                this.hayTematica = false;
            }
            
            compruebaPermisoSPV({'caseId': this.recordId, 'idUsuario': this.userId}).then(result => {
                if(result){
                    this.esPropietario = result;
                    console.log('esProp' + this.esPropietario);
                    console.log('status ' + this.status);
                    if(!this.esPropietario || this.status == 'Cerrado'){
                        this.puedeGuardar = false;

                    }else{
                        this.puedeGuardar = true;
                    }    
                }else{
                    console.error("error" + JSON.stringify(result));
                }
            }).catch(error => {
                console.error("Error en la promesa: " + JSON.stringify(error));
            });
            
              


        }else if(error) {
            console.error('Error al obtener el registro del caso: ' + JSON.stringify(error));
        }
    }

    handleClick() {
        this.isSelected = !this.isSelected;
        if (this.isSelected == true){
            this.mostrarBuscador = true;
        }else{
            this.mostrarBuscador = false;
        }
    }

    recieveDataLWC(event){
        this.mostrarBuscador = event.data;
        this.isSelected = !this.isSelected;
        this.dispatchEvent(new RefreshEvent());

    }
}