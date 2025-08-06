import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } 	    from 'lightning/platformShowToastEvent';

//Labels
import SIR_CMP_Message from '@salesforce/label/c.SIR_CMP_Message';
import SIR_CMP_NoDataFound 		from '@salesforce/label/c.SIR_CMP_NoDataFound';
import SIR_CMP_ErrorMessage 		from '@salesforce/label/c.SIR_CMP_ErrorMessage';
import SIR_LinksOperations		from '@salesforce/label/c.SIR_LinksOperations';
//Methods
import getLinks 		        from '@salesforce/apex/SIR_LCMP_LinksOperativoController.getLinks';
//import getIdFilterObject       	from '@salesforce/apex/SIR_LCMP_LinksOperativoController.getIdFilterObject';


export default class Sir_lwc_LinksOperativos extends LightningElement {
    @api title; 
    @api icon;
    @api objectApiName;
    @api recordId;
    //@api filterField;
    @api filterObject;
    @track newTitle = SIR_LinksOperations;
    @track listLinks;
    @track hasLinks = false;
    @track currenObjectName;
    @track ObjectId;
    a_Record_URL;
    
    message = SIR_CMP_Message;
    noDataFound = SIR_CMP_NoDataFound;
    
    connectedCallback() {
        this.a_Record_URL = window.location.origin;
        this.currenObjectName = this.objectApiName;
        this.getData();
    } 

    refreshCmp(){
        this.hasConsents = !this.hasConsents;
        this.getData();
    }

    
    getData(){
        this.getRecId(this.recordId,this.currenObjectName,this.filterObject);
    }

    getLink(){
        getLinks({seccion: this.currenObjectName, customerId: this.ObjectId, url: this.a_Record_URL})
			.then(result => {
                this.listLinks = result;
                this.hasLinks = true;
                
			})
			.catch(error => {
				console.log('Display ShowToastEvent error (catch): ',error);
				const evt = new ShowToastEvent({
					title: SIR_CMP_ErrorMessage,
					message: JSON.stringify(error),
					variant: 'error'
                });
                this.dispatchEvent(evt);
		});

    }

    getRecId(recordId,objectApiName,filterObject/*,filterField*/){
        if(objectApiName == filterObject){
            this.ObjectId = recordId;
            this.getLink();
        }/*else{
            getIdFilterObject({ recordId: this.recordId, objectApiName: this.objectApiName, objectFilter: this.filterObject, filterField: this.filterField  })
                .then(resultIdObject => {
                    this.ObjectId = resultIdObject;
                    if(this.ObjectId != null && this.ObjectId != undefined)  this.getLink();
                })
                .catch(error => {
                    console.log(error);
                    const evt = new ShowToastEvent({
                        title: SIR_CMP_ErrorMessage,
                        message: JSON.stringify(error),
                        variant: 'error'
                    });
                    this.dispatchEvent(evt);
                });
        }*/
    }
}