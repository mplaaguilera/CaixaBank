import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendPurse from '@salesforce/apex/AV_ReasignarCartera.sendPurseFromTaskToAPI';
import getContactPurse from '@salesforce/apex/AV_ReasignarCartera.getPurseFromContact';
import controlVisibilityTask from '@salesforce/apex/AV_ReasignarCartera.controlVisibilityTask';

//Labels
import AV_ASSIGNCONTACT from '@salesforce/label/c.AV_assignContact';
import AV_SELECTPURSE from '@salesforce/label/c.AV_selectPurse';
import AV_CANCEL from '@salesforce/label/c.AV_CMP_Cancel';
import AV_SAVE from '@salesforce/label/c.AV_CMP_Save';

export default class Av_assignPurse extends LightningElement {
    @api recordId;

    @track noConnectedAPI = false;

    @track initModal = true;
    @track lastModal = false;

    @track notPurse;
    @track purseChange = false;

    @track fieldIdToApi = [];
    @track getPurseValue = [];

    @track valPurse;

    label = {
        AV_ASSIGNCONTACT,
        AV_SELECTPURSE,
        AV_CANCEL,
        AV_SAVE
    };

    connectedCallback(){
        controlVisibilityTask({ taskId : this.recordId })
        .then((result) => {
            if(result){
                this.noConnectedAPI = true;
            }
        })
        .catch((error) => {
            console.log(error);
        })
   }

    closeModalContact() {
        this.initModal = false;
    }
    closeModalPurse() {
        this.lastModal = false;
    }

    handleChangeContact(event) {
        this.getPurseValue = [];
        var gestor = event.target.value;
        getContactPurse({ contactId : gestor })
        .then((result) => {
            var resultArray = [];
            resultArray = Reflect.ownKeys(result).length;
            if(resultArray>0){
                for(let key in result){
                    this.getPurseValue.push({value:result[key], key:key});
                }
                this.notPurse = true;
            }else{
                this.notPurse = false;
            }
        })
        .catch((error) => {
            console.log(error);
        })
    }

    handleChangePurse(event){
        this.valPurse = event.target.value;
        this.purseChange = true;

    }

    handleOnClick(event) {
        var sendData = false;
        var buttonName = event.target.dataset.name;
        if(!sendData){
            switch(buttonName){
                case 'getContact':
                    if(this.notPurse){
                        this.initModal = false;
                        this.lastModal = true;
                    }else{
                        const evt = new ShowToastEvent({
                            title: 'Operación incorrecta',
                            message: 'El gestor no tiene Cartera/Cesta activas.',
                            variant: 'error',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                    }
                    
                break;
    
                case 'getPurse':
                    var purse;
                    if(this.purseChange){
                        purse = this.valPurse;
                    }else{
                        purse = this.template.querySelector('.purse').value;
                    }
                    var tempArrayPurse = '';
                    var tempArrayIdTask = '';
                    tempArrayPurse = purse;
                    tempArrayIdTask = this.recordId;
                    if(!this.fieldIdToApi.includes(tempArrayPurse)){
                        this.fieldIdToApi.push(tempArrayPurse);
                    }
                    if(!this.fieldIdToApi.includes(tempArrayIdTask)){
                        this.fieldIdToApi.push(tempArrayIdTask);
                    }
                    
                    sendData = true;
                    this.lastModal = false;
                break;
            }
        }

        if(sendData){
            sendPurse({ lstIds : this.fieldIdToApi })
            .then((result) => {
                console.log(result[0]);
                console.log(result[1]);
                if(result[0] === '200'){
                    const evt = new ShowToastEvent({
                        title: 'Operación correcta',
                        message: result[1],
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }else{
                    const evt = new ShowToastEvent({
                        title: 'Operación incorrecta',
                        message: result[1],
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
            })
            .catch((error) => {
                const evt = new ShowToastEvent({
                    title: 'Operación incorrecta',
                    message: error,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            })
            .finally(() => {
                console.log('Finally');
            })
        }
    }
}