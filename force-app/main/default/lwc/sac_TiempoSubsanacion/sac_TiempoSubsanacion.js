import { LightningElement, api, wire, track } from 'lwc';
import recuperarSLAActivos from '@salesforce/apex/SAC_LCMP_UpdateStatus.recuperarSLAActivos';

export default class Sac_TiempoSubsanacion extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track mapaMilestone;

    @wire(recuperarSLAActivos, {recordId: '$recordId'})
    fechaTiemposMilestone(result) {
        if(result.data){
            this.mapaMilestone = [];
            for (var key in result.data) {
                this.mapaMilestone.push({ key: key, value: result.data[key] });
            } 
        }
    }
}