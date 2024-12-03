import { LightningElement, api, track } from 'lwc';

export default class Cibe_GruposComercialesParent extends LightningElement {

    @api recordId;

    @track isLoaded = false;

    @track shareToComponents = [];
    @track shareToCXBTeam = [];

    @track recordIdsOpportunity = [];
    @track recordIdsEvent = [];
    @track recordIdsTasks = [];

    firstTime = true;
    @track recordIdsEquipoCB = [];

    refreshRelatedLists(event) {
        this.shareToComponents = JSON.parse(JSON.stringify(event.detail));
        this.isLoaded = false;

        if(this.firstTime) {
            this.firstTime = false;
            this.shareToCXBTeam = this.shareToComponents;
        }
    }

    handleActive(event) {
        const tab = event.target.value;
        const shareToComponents = JSON.parse(JSON.stringify(this.shareToComponents));
        const shareToCXBTeam = JSON.parse(JSON.stringify(this.shareToCXBTeam));
        switch(tab) {
            case "1":
                break;
            case "2":
                if(!this.arrayEquals(this.recordIdsOpportunity, shareToComponents)) {
                    this.isLoaded = false;
                    this.recordIdsOpportunity = shareToComponents;
                }
                break;
            case "3":
                if(!this.arrayEquals(this.recordIdsEvent, shareToComponents)) {
                    this.isLoaded = false;
                    this.recordIdsEvent = shareToComponents;
                }
                break;
            case "4":
                if(!this.arrayEquals(this.recordIdsTasks, shareToComponents)) {
                    this.isLoaded = false;
                    this.recordIdsTasks = shareToComponents;
                }
                break;
            case "5":
                if(!this.arrayEquals(this.recordIdsEquipoCB, shareToCXBTeam)) {
                    this.recordIdsEquipoCB = shareToCXBTeam;
                }
                break;
            
            default:
                console.error('Not recognised tab!');
        }
    }

    arrayEquals(a, b) {
        return Array.isArray(a) &&
            Array.isArray(b) &&
            a.length === b.length &&
            a.every((val, index) => val === b[index]);
    }

    handleLoaded(event) {
        this.isLoaded = true;
    }

}