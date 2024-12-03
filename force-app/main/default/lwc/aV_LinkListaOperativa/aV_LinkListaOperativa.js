import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } 	    from 'lightning/platformShowToastEvent';

//Labels
import AV_CMP_ErrorMessage 		from '@salesforce/label/c.AV_CMP_ErrorMessage';

//Methods
import getLinks 		        from '@salesforce/apex/AV_LinkListaOperativa_Controller.getLinks';
import getIdFilterObject       	from '@salesforce/apex/AV_SObjectRelatedInfoCController.getIdFilterObject';


export default class AV_LinkListaOperativa extends LightningElement {
    
    @api title; 
    @api icon;
    @api setting;
    @api description;
    @api objectApiName;
    @api recordId;
    @api filterField;
    @api filterObject;
    @track hasLinks = false;
    @track isLoading = true;
    @track listData;


    @wire(getIdFilterObject,  {recordId: '$recordId', objectApiName: '$objectApiName', objectFilter: '$filterObject', filterField: '$filterField'})
       
    getObject({ error, data }){
        if(data){
            var result = JSON.parse(JSON.stringify(data));
            getLinks({filterObject: this.filterObject, customerId: result, parentId: this.recordId}).then(result => {
                this.hasLinks = true;
                this.isLoading = false;
                this.listData = result;
			}).catch(error => {
				const evt = new ShowToastEvent({
					title: AV_CMP_ErrorMessage,
					message: JSON.stringify(error),
					variant: 'error'
                    
                });
                this.dispatchEvent(evt);
		    });

        }else if(error) {
            var result = JSON.parse(JSON.stringify(error));
        }
    };
}