import { LightningElement, api, wire } from 'lwc';
//import insertarPretension from '@salesforce/apex/SAC_LCMP_InsertarPretension.insertarPretension';
import tienePermisos from '@salesforce/apex/SAC_LCMP_InsertarPretension.tienePermisos';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASO_OBJECT from '@salesforce/schema/Case';

const fields = [
    'Case.Status',
    'Case.OwnerId'
];

export default class SAC_InsertarPretension extends NavigationMixin(LightningElement) {

    @api recordId;
    @api idRec;
    @api isLoading = false;
    @api tienePermisosEditar = false;
    @api mensaje = 'Se ha creado la pretensión en el sistema.';
    @api my_error = 'La creación de la pretensión ha fallado.';
    casetInfo;
    ownerId;

    _wiredResult;  
    @wire (getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfo;

    @wire(getRecord, {recordId: '$recordId', fields})
    actualCase({data, error}){
        if(data){
            this.casetInfo = data;
            this.ownerId = this.casetInfo.fields.OwnerId.value; 
        }            
    };

    @wire(tienePermisos, { idCaso: '$recordId'}) 
    mapaPermisos(result){ 
        if(result.data){
            this.tienePermisosEditar = result.data;           
        }else{
            this.ownerId == Id ? this.tienePermisosEditar = true :  this.tienePermisosEditar = false;
        }
    };

    insertRecord(){        
        this.isLoading = true;
        insertarPretension({idRec: this.recordId})
            .then(result => {       
            let nuevaId = result;
            const evt = new ShowToastEvent({
                title: 'Pretensión Creada',
                message: this.mensaje,
                variant: 'success'
            });
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: nuevaId,
                    objectApiName: 'Case',
                    actionName: 'view'
                }
            });
            this.dispatchEvent(evt);
            this.isLoading = false;
            eval("$A.get('e.force:refreshView').fire();");
        })
            .catch(error => {

                const evt = new ShowToastEvent({
                    title: 'Fallo al crear Pretensión',
                    message: error.body.message,
                    variant: 'error'
                });

                this.dispatchEvent(evt);
                this.isLoading = false;
            })

    }

}