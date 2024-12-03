import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } 	    from 'lightning/platformShowToastEvent';

//Labels
import AV_CMP_ErrorMessage 		from '@salesforce/label/c.AV_CMP_ErrorMessage';

//Methods
import getLinks 		        from '@salesforce/apex/AV_LinkOperativoController.getLinks';
import getIdFilterObject       	from '@salesforce/apex/AV_SObjectRelatedInfoCController.getIdFilterObject';


export default class AV_LinkOperativos extends LightningElement {
    
    @api title; 
    @api icon;
    @api setting;
    @api description;
    @api objectApiName;
    @api recordId;
    @api filterField;
    @api filterObject;
    @track hasLinks = false;
    @track listData;
    
    @wire(getIdFilterObject,  {recordId: '$recordId', objectApiName: '$objectApiName', objectFilter: '$filterObject', filterField: '$filterField'})
    getObject({ error, data }){
        console.log('getObject');
        if(data){
            var result = JSON.parse(JSON.stringify(data));
            getLinks({seccion: this.objectApiName, filterObject: this.filterObject, customerId: result, parentId: this.recordId, setting: this.setting}).then(result => {
                this.hasLinks = true;
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
            console.log('Error loading: ', result);
        }
    };

    
    
}