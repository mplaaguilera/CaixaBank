import { LightningElement, api, track } from 'lwc';
import getUrlTeams from '@salesforce/apex/AV_ButtonTeamsController.getUrlTeams';
import Iconos from '@salesforce/resourceUrl/AV_IconoTeams';
import AV_LabelTeams 	from '@salesforce/label/c.AV_LabelTeams';

export default class Av_ButtonTeams extends LightningElement {
    
    @api recordId; //para llamar al método.
    @track url;
    @track tieneUrl=false;
	icono=Iconos+'/teams_icon_white.png';
	labelTeams=AV_LabelTeams;

    connectedCallback() {
        this.getUrls();
    }

    getUrls(){
        getUrlTeams({recordId: this.recordId})
        .then(result => {
            this.url = result;
            if (this.url != null) {
                this.tieneUrl=true;
            }
        })
        .catch(error => {
            console.log(error);
        });
    }
}