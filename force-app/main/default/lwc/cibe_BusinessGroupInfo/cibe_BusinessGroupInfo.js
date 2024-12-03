import { LightningElement, track, api, wire } from 'lwc';
import getInfoGroup from '@salesforce/apex/CIBE_BusinessGroupInfo_Controller.getParentAccountOfCommercialGroup';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import NAME from '@salesforce/schema/Account.Name';
import opp from '@salesforce/label/c.CIBE_Oportunidades';
import task from '@salesforce/label/c.CIBE_Tareas';
import events from '@salesforce/label/c.CIBE_Eventos';
import interlocutor from '@salesforce/label/c.CIBE_Interlocutor';
import members from '@salesforce/label/c.Cibe_Members';

export default class Cibe_BusinessGroupInfo extends NavigationMixin(LightningElement) {


    @api recordId;
    businessGroupName;
    businessGroupId;
    interlocutorId;
    interlocutorName;
    membersNumber;
    membersList = [];
    totalOpp;
    totalEvents;
    totalTask;
    readyToRender = false;
    opp = opp;
    task = task;
    events = events;
    interlocutor = interlocutor;
    members = members;
    showSpinner = true;

    /**
     * Retrieve the id of the current record
     * @param {*} param0 
     */
    @wire(getRecord, { recordId: '$recordId', fields: [NAME] })
    wiredAccount({ error, data }) {
        if (data) {
            this.recordName = data.fields.Name.value;
            this.getParentAccont(data.id);
        } else if (error) {
            this.showSpinner = false;
        }
    }

    /**
     * Retrieves information related to the account being visited.
     * @param {*} childId 
     */
    getParentAccont(childId) {
        getInfoGroup({ childAccountId: childId })
            .then(data => {
                if (data) {
                    this.businessGroupName = data.businessGroupName;
                    this.businessGroupId = data.businessGroupId;
                    this.interlocutorId = data.interlocutorId;
                    this.interlocutorName = data.interlocutor;
                    this.membersNumber = data.members.length;
                    this.membersList = data.members.slice(0, 2);
                    this.totalOpp = data.countOpp;
                    this.totalEvents = data.countEvents;
                    this.totalTask = data.countTask;
                    this.readyToRender = true;
                }
            })
            .catch(error => {
                console.log('Error ', error);
                this.showSpinner = false;
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    /**
     * Navigate to the client window by clicking on the name.
     * @param {*} event 
     */
    viewAccount(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'Account',
                recordId: event.target.name,
                actionName: 'view'
            }
        });
    }




}