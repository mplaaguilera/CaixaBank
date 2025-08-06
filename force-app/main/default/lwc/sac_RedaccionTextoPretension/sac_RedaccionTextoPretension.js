import { LightningElement, api, wire, track } from 'lwc';
import getTitulos from '@salesforce/apex/SAC_LCMP_RedaccionPretension.getTitulos';
import getBody from '@salesforce/apex/SAC_LCMP_RedaccionPretension.getBody';
import insertRedaccion from '@salesforce/apex/SAC_LCMP_RedaccionPretension.insertRedaccion';
import getRedaccion from '@salesforce/apex/SAC_LCMP_RedaccionPretension.getRedaccion';
import compruebaPropietario from '@salesforce/apex/SAC_LCMP_RedaccionPretension.compruebaPropietario';
import recuperarCheckRedaccionFinal from '@salesforce/apex/SAC_LCMP_RedaccionPretension.recuperarCheckRedaccionFinal';
import recuperarSentidoResolucion from '@salesforce/apex/SAC_LCMP_RedaccionPretension.recuperarSentidoResolucion';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import REDACCION from '@salesforce/schema/Case.SAC_Redaccion__c';
import LISTOREDACCION from '@salesforce/schema/Case.SAC_RedaccionFinal__c';
import IDIOMA from '@salesforce/schema/Case.CC_Idioma__c';
import ID from '@salesforce/schema/Case.Id';
import STATUS from '@salesforce/schema/Case.Status';
import SENTIDORESOLUCION_FIELD from '@salesforce/schema/Case.SAC_SentidoResolucion__c';
import MOTIVORESOLUCION_FIELD from '@salesforce/schema/Case.SAC_MotivoSentidoResolucion__c';
import MOTIVOINADMISION_FIELD from '@salesforce/schema/Case.SAC_MotivoInadmision__c';
import RECORDTYPEID_FIELD from '@salesforce/schema/Case.RecordTypeId';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { getPicklistValues  } from 'lightning/uiObjectInfoApi';
import CASO_OBJECT from '@salesforce/schema/Case'; 
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import devolverCaso from '@salesforce/apex/SAC_LCMP_RedaccionFinal.devolverCaso';
import { RefreshEvent } from 'lightning/refresh';

export default class Sac_RedaccionTextoPretension extends LightningElement {

    
    @api recordId;
    @api isLoading;
    @api readOnly;
    @api listoRedaccionFinal;

    @track recordTypeId;
    @track value;
    @track valueMotivoCaso;
    @track valueMotivoNuevo;
    @track valueSentidoCaso;
    @track valueSentidoNuevo;
    @track valueRedaccionNuevo;
    @track options = [];
    @track dataApex = [];
    @track prueba = 'prueba';
    @track record;
    @track estado;
    @track isChecked;
    // @track esInadmision = true;


    @api myVal;
    @api argRes;

    _wiredResult;

    escritura(event){
        this.myVal = event.target.value;
    }

    argumentoRes(event){
        this.argRes = event.target.value;
    }

    @wire (getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: SENTIDORESOLUCION_FIELD })
    opcionesSentido;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: MOTIVOINADMISION_FIELD })
    opcionesMotivo;

    @wire(getRecord, { recordId: '$recordId', fields: [REDACCION, IDIOMA, ID, STATUS, LISTOREDACCION, SENTIDORESOLUCION_FIELD, MOTIVORESOLUCION_FIELD, MOTIVOINADMISION_FIELD, RECORDTYPEID_FIELD]})
    casoCampo({data, error}){
        if(data){ 
            this.listoRedaccionFinal = data.fields.SAC_RedaccionFinal__c.value;
            this.valueSentidoCaso = data.fields.SAC_SentidoResolucion__c.value;
            this.valueMotivoCaso = data.fields.SAC_MotivoInadmision__c.value;
            this.recordTypeId = data.fields.RecordTypeId.value;
            this.myVal = this.nameMethod();
            this.argRes = data.fields.SAC_MotivoSentidoResolucion__c.value;          
            this.habilitadorGetTitulos();
            if(this.valueSentidoCaso == 'SAC_004'){
                this.esInadmision = true;
            }else{
                this.esInadmision = false;
            }
        }
    }

    @wire(getTitulos, {idCaso: '$recordId', sentido: null})
    listaTitulos(result) {
        this._wiredResult = result;
        if (result.error) {
            
            this.myVal = this.plantilla(this.recordId);

            compruebaPropietario({id: this.recordId}).then(result => {
                if(result === true){
                    this.readOnly = true;
                }
                else{
                    this.readOnly = false;
                }
            })
            .catch(error => {
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al comprobar privilegios',
                    message: error.body.message,
                    variant: 'warning'
                }));
    
                })

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al obtener plantillas',
                    message: result.error.body.message,
                    variant: 'warning'
                })
            );
            
            
        } else if (result.data) {
            let titulos = result.data;
            if (titulos.length === 0) {
                this.mostrarToastSinPlantillas();
            }
            if(this.myVal == null){
                             
                if(titulos.length === 1){
                    
                    getBody({idTitulo: titulos[0].idPlantilla, idCase: this.recordId}).then(result => {
                        let body = result;
                        this.myVal = body;
                        this.value = titulos[0].idPlantilla; 
                    })
                        .catch(error => {
                            this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Fallo al obtener el contenido de la plantilla',
                                message: error.body.message,
                                variant: 'warning'
                            }));
            
                        })
                }
                

            }
            for (var miTitulo in titulos) {
                let titulo = titulos[miTitulo];
                this.options.push({ label: titulo.nombrePlantilla, value: titulo.idPlantilla });
            }            
            this.options = JSON.parse(JSON.stringify(this.options));

            compruebaPropietario({id: this.recordId}).then(result => {
                if(result === true){
                    this.readOnly = true;
                }
                else{
                    this.readOnly = false;
                }
            })
            .catch(error => {
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al comprobar privilegios',
                    message: error.body.message,
                    variant: 'warning'
                }));
    
                })

        }
    }

    @api
    get isChecked(){
        return this.listoRedaccionFinal;
    }

    @api
    get valueSentido(){
        return this.valueSentidoCaso;
    }

    @api
    get valueMotivo(){
        return this.valueMotivoCaso;
    }

    get read(){
        compruebaPropietario({id: this.recordId}).then(result => {
            if(result === true){
                this.readOnly = true;
            }
            else{
                this.readOnly = false;
            }
        })
        .catch(error => {
            this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error'
            }));

            })
    }

    habilitadorGetTitulos(){
        refreshApex(this._wiredResult);
        this.options = [];
        this.myVal = this.nameMethod();

        getTitulos({idCaso: this.recordId, sentido: this.valueSentidoNuevo}).then(result => {
            this._wiredResult = result;
            this.myVal = this.nameMethod();
            let titulos = result;
            if(this.myVal == null){
                             
                if(titulos.length === 1){
                    
                    getBody({idTitulo: titulos[0].idPlantilla, idCase: this.recordId}).then(result => {
                        let body = result;
                        this.myVal = body;
                        this.value = titulos[0].idPlantilla; 
                    })
                        .catch(error => {
                            this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Fallo al obtener plantillas',
                                message: error.body.message,
                                variant: 'error'
                            }));
            
                        })
                }
                for (var miTitulo in titulos) {
                    let titulo = titulos[miTitulo];
                    //this.options.push({ label: titulo.nombrePlantilla, value: titulo.idPlantilla });
                }            

            }
            else{
                for (var miTitulo in titulos) {
                    let titulo = titulos[miTitulo];
                    this.options.push({ label: titulo.nombrePlantilla, value: titulo.idPlantilla });
                }            
            }
            
            this.options = JSON.parse(JSON.stringify(this.options));

            compruebaPropietario({id: this.recordId}).then(result => {
                if(result === true){
                    this.readOnly = true;
                }
                else{
                    this.readOnly = false;
                }
            })
            .catch(error => {
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al comprobar privilegios',
                    message: error.body.message,
                    variant: 'error'
                }));
    
                })

            
        })
        .catch(error => {
        /*    this.dispatchEvent(
            new ShowToastEvent({
                title: 'Fallo al obtener el cuerpo de la plantilla',
                message: error.body.message,
                variant: 'warning',
            }));
*/
            });
    }


    plantilla(param){
        this.myVal = getRedaccion({id: param}).then(result => {
            this.myVal = result;
        });
        return this.myVal;
    }


    nameMethod() {
        return getFieldValue(this.casoCampo.data, REDACCION);
    }

    recuperarEstado() {
        return getFieldValue(this.casoCampo.data, STATUS);
    }

    handleChangeSentido(event){
        this.valueSentidoNuevo = event.detail.value;
        this.options = [];
        this.myVal = this.nameMethod();
        if(this.valueSentidoNuevo == 'SAC_004'){
            this.esInadmision = true;
        }else{
            this.esInadmision = false;
        }

        getTitulos({idCaso: this.recordId, sentido: this.valueSentidoNuevo}).then(result => {
            this._wiredResult = result;
            this.myVal = this.nameMethod();
            let titulos = result;
            if(this.myVal == null){
                             
                if(titulos.length === 1){
                    
                    getBody({idTitulo: titulos[0].idPlantilla, idCase: this.recordId}).then(result => {
                        let body = result;
                        this.myVal = body;
                        this.value = titulos[0].idPlantilla; 
                    })
                        .catch(error => {
                            this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Fallo al obtener plantillas',
                                message: error.body.message,
                                variant: 'error'
                            }));
            
                        })
                }
                for (var miTitulo in titulos) {
                    let titulo = titulos[miTitulo];
                    this.options.push({ label: titulo.nombrePlantilla, value: titulo.idPlantilla });
                }            

            }
            else{
                for (var miTitulo in titulos) {
                    let titulo = titulos[miTitulo];
                    this.options.push({ label: titulo.nombrePlantilla, value: titulo.idPlantilla });
                }            
            }
            
            this.options = JSON.parse(JSON.stringify(this.options));

            compruebaPropietario({id: this.recordId}).then(result => {
                if(result === true){
                    this.readOnly = true;
                }
                else{
                    this.readOnly = false;
                }
            })
            .catch(error => {
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al comprobar privilegios',
                    message: error.body.message,
                    variant: 'error'
                }));
    
                })

            
        })
        .catch(error => {
        /*    this.dispatchEvent(
            new ShowToastEvent({
                title: 'Fallo al obtener el cuerpo de la plantilla',
                message: error.body.message,
                variant: 'warning',
            }));
*/
            });
    }

    handleChangeMotivo(event){
        this.valueMotivoNuevo = event.target.value;
    }

    handleChangeRedaccionFinal(event){
        
        this.valueRedaccionNuevo = event.target.checked;

    }

    handleChange(event) {
        
        getBody({idTitulo: event.detail.value, idCase: this.recordId}).then(result => {
            let body = result;
            this.myVal = body;
        })
            .catch(error => {
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al obtener el cuerpo de la plantilla',
                    message: error.body.message,
                    variant: 'error'
                }));

            })
    }

    handleClick(){

        if(this.valueSentidoCaso == null && this.valueSentidoNuevo != null){
            this.valueSentidoCaso = this.valueSentidoNuevo;
        }

        if((this.valueSentidoCaso == 'SAC_004' && this.valueMotivoNuevo != null )|| (this.valueSentidoCaso != 'SAC_004' && this.valueSentidoNuevo =='SAC_004' && this.valueMotivoNuevo != null )){
            this.valueMotivoCaso = this.valueMotivoNuevo;
        }else if(this.valueSentidoCaso != 'SAC_004' && this.valueMotivoNuevo != null && this.valueSentidoNuevo != 'SAC_004'){
            this.valueMotivoCaso = null;
        }
 
        if((this.valueSentidoNuevo == 'SAC_004' && this.valueMotivoCaso == null) ||(this.valueSentidoNuevo == null && this.valueSentidoCaso =='SAC_004' && this.valueMotivoCaso == null)){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Motivo Inadmisión',
                    message: 'El campo motivo inadmisión está vacío.',
                    variant: 'warning',
                }));
        }
        else if(this.valueSentidoCaso == null || this.valueSentidoCaso  == undefined){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Sentido resolución',
                    message: 'El campo sentido de resolución está vacío.',
                    variant: 'warning'
                }));
            

        // if(this.valueSentidoCaso == null && this.valueSentidoNuevo != null){
        //     this.valueSentidoCaso = this.valueSentidoNuevo;
        //     if(this.valueSentidoCaso == 'SAC_004' && this.valueMotivoNuevo != null){
        //         this.valueMotivoCaso = this.valueMotivoNuevo;
        //     }else{
        //         this.valueMotivoCaso = null;
        //     }

        // }

        // if(this.valueSentidoCaso == null || this.valueSentidoCaso  == undefined){
            
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: 'Sentido resolución',
        //             message: 'El campo sentido de resolución está vacío.',
        //             variant: 'warning',
        //         }));

        }else{
            this.isLoading = true;

            if(this.valueRedaccionNuevo == undefined){
                this.valueRedaccionNuevo = this.listoRedaccionFinal;
            }
    
            if(this.valueSentidoNuevo == undefined){
                this.valueSentidoNuevo = this.valueSentidoCaso; 
            }
    
            insertRedaccion({campo: this.myVal, argumentoRes: this.argRes, id: this.recordId, valorSentido: this.valueSentidoNuevo, valorMotivo: this.valueMotivoCaso, listoRedaccion: this.valueRedaccionNuevo}).then(result => {
                this.isLoading = false;
                
                const evt = new ShowToastEvent({
                    title: 'Redacción guardada',
                    message: 'La redacción ha quedado almacenada en el registro actual.',
                    variant: 'success'
                });                
                
                this.dispatchEvent(evt);
                this.updateRecordView();   
               
            })
                .catch(error => {
                    this.isLoading = false;
                    let mensageError = 'Error al actualizar';
                    if(error.body.message) {
                        mensageError = error.body.message;
                    } else if(error.body.pageErrors[0].message) {
                        mensageError = error.body.pageErrors[0].message;
                    }
                    this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Fallo al guardar la redacción',
                        message: mensageError,
                        variant: 'error'
                    }));

                    this.listoRedaccionFinal = false;
    
                }) 
                
                
        }
        
    }

    updateRecordView() {
        setTimeout(() => {
             this.dispatchEvent(new RefreshEvent());
        }, 1000); 
    }

    mostrarToastSinPlantillas() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Fallo al obtener plantillas',
                message: 'No hay plantillas definidas para la pretensión',
                variant: 'warning'
            }));
    }
    /*
    async handleSave(event){
        const updatedFields = event.detail.draftValues;
        // Prepare the record IDs for getRecordNotifyChange()
        const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.Id } });
        console.log(notifyChangeIds,' : notifyChangeIds');
    
        const recordInputs = event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return {fields};
        });
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'SUCCESS_TITLE', 
                    message: 'SUCCESS_MSG', 
                    variant: 'success'
                })
            );
            console.log(notifyChangeIds,' : notifyChangeIds');
            getRecordNotifyChange(notifyChangeIds);
            // Display fresh data in the datatable
            refreshApex(this.casoCampo)
            // Clear all draft values in the datatable also hides the save and cancel button
            this.draftValues = [];
            
        })
        .catch(error =>{
            console.log('error: ',error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR_TITLE', 
                    message: error.body.message, 
                    variant: 'error'
                })
            );
        });
    }*/

}