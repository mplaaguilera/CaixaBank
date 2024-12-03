import { LightningElement, api, wire,track } from 'lwc';
import { ShowToastEvent }   from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { updateRecord } from 'lightning/uiRecordApi';


// Methods
import resetLeadOpp  from '@salesforce/apex/AV_ResendCommercialOfferController.resetLeadOpp';

       
export default class av_ResendCommercialOffer extends LightningElement {

    @api recordId;
    @track retrievedRecordId = false;

    renderedCallback() {
        if (!this.retrievedRecordId && this.recordId) {
            
            this.retrievedRecordId = true;
            this.updateLeadOpp();
        }
    }
    
    updateLeadOpp(){
        resetLeadOpp({ recordId: this.recordId })
        .then(result =>{
            if (result) {
                var evt = new ShowToastEvent({
                    title: 'Lead Oportunidad preparado para enviar la oferta comercial',
                    message: 'Se ha reseteado el estado envío oferta comercial',
                    variant: 'success'
                });
        
                this.dispatchEvent(evt);
                this.dispatchEvent(new CloseActionScreenEvent());
                // Refresh LeadOpp Detail Page
                updateRecord({ fields: { Id: this.recordId }})
           }
        }).catch(error => {
            console.log(error);
        })
    }
    
   
}