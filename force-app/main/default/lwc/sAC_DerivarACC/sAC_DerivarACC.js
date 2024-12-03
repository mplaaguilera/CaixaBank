import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import crearCase from '@salesforce/apex/SAC_LCMP_CaseParaContactCenter.crearCase';
import mostrarBoton from '@salesforce/apex/SAC_LCMP_CaseParaContactCenter.mostrarBoton';
import { updateRecord } from 'lightning/uiRecordApi';
import userId from '@salesforce/user/Id';

export default class SAC_DerivarACC extends LightningElement {
    @api recordId;
    @track disableButton = true;

    renderedCallback(){
        mostrarBoton({ idUsuario: userId, idCasoDisparador: this.recordId }).then(result => {
            this.disableButton = result;            
        }).catch(error => {
            this.disableButton = true;
        },);   
    }

    handleClick(){
        
        crearCase({ idCasoDisparador: this.recordId }).then(result => {
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '',
                    message: 'Reclamación derivada al Contact Center',
                    variant: 'success'
                }),
                this.disableButton=true,
                updateRecord({ fields: { Id: this.recordId } })
                
            )
        })
            .catch(error => {
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No se ha podido derivar al Contact Center',
                    variant: 'error'
                }),);

            })
        
    }
}