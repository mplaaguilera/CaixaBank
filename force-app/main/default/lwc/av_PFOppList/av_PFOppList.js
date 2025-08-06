import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } 	    from 'lightning/platformShowToastEvent';

//Methods
import getPFInfo from '@salesforce/apex/AV_PFOppList_Controller.getPFInfo';
import getListData from '@salesforce/apex/AV_PFOppList_Controller.getListData';
import getStatusValues from '@salesforce/apex/AV_ListOpportunities_Controller.getStatusValues';

//Labels
import currentOppsLabel from '@salesforce/label/c.AV_OpportunitiesVigentes';
import historicalOppsLabel from '@salesforce/label/c.AV_HistoricoOpportunities';
import noDataFoundLabel from '@salesforce/label/c.AV_CMP_NoDataFound';
 
export default class Av_PFOppList extends LightningElement {

    @api recordId;

    @track listVigentes;
    @track listHistorico;
    @track stagesValuesOpp;

    icon = 'standard:opportunity';
    listFormat = true;

    label = {
        currentOppsLabel,
        historicalOppsLabel,
        noDataFoundLabel
    };
    
    connectedCallback() {
        this.getInitialInfo();
    }
    
    getInitialInfo() {
        getPFInfo({recordId: this.recordId})
			.then(result => {
                if(result != null) {
                    this.getData(JSON.stringify(result), 'Vigentes');
                    this.getData(JSON.stringify(result), 'Historico');
                } else {
                    this.disableSpinner();
                }
			})
			.catch(error => {
                this.showToast('Error', error.body.message, 'error');
                console.log(error.body);
                this.disableSpinner();
		});
    }

    getData(dataPF, viewType) {
        var listAux;
        getListData({dpfJson: dataPF, viewType: viewType})
			.then(result => {
                listAux = result;
                if(listAux.length > 0) {
                    if(viewType === 'Vigentes') {
                        this.listVigentes = listAux;
                    } else if(viewType === 'Historico') {
                        this.listHistorico = listAux;
                    }
                    this.getStatus('Opportunity', 'StageName', viewType);
                }
			})
			.catch(error => {
                this.showToast('Error', error.body, 'error');
                console.log(error.body);
        });
    }

    getStatus(objName, fldName, type){
        getStatusValues({objectName: objName, fieldName: fldName})
			.then(result => {
                
                this.stagesValuesOpp = result;
                if(type == 'Vigentes') {
                    for(var item of this.template.querySelectorAll('[data-id="vig"] > c-av_-detail-opp')) {
                        item.pathValues(this.stagesValuesOpp);
                    }
                } else if(type === 'Historico') {
                    for(var item of this.template.querySelectorAll('[data-id="his"] > c-av_-detail-opp')) {
                        item.pathValues(this.stagesValuesOpp);
                    }
                }
                this.disableSpinner();
			})
			.catch(error => {
                this.showToast('Error', error.body, 'error');
                this.disableSpinner();
		});
    }

    disableSpinner() {
        this.showSpinner = false;
    }

    enableSpinner() {
        this.showSpinner = true;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
			message: message,
			variant: variant
        });
        this.dispatchEvent(event);
    }
}