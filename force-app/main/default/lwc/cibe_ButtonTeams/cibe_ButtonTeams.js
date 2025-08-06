import { LightningElement, api, track } from 'lwc';
import getUrlTeams from '@salesforce/apex/CIBE_ButtonTeamsController.getUrlTeams';
import Iconos from '@salesforce/resourceUrl/CIBE_IconoTeams';
import cibe_LabelTeams 	from '@salesforce/label/c.CIBE_LabelTeams';

export default class Cibe_ButtonTeams extends LightningElement {
    
    @api recordId;
    @track url;
    @track tieneUrl=false;
	@track icono=Iconos+'/teams_icon_white.png';
	@track labelTeams=cibe_LabelTeams;

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