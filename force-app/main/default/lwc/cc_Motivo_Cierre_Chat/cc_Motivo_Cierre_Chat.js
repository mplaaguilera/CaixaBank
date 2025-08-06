import {LightningElement, api, wire, track} from 'lwc';
import cerradoPorTimeOut from '@salesforce/apex/CC_LiveAgentTranscript_TimeOut.cerradoPorTimeOut'

export default class CC_Motivo_Cierre_Chat extends LightningElement {
    @api recordId;
    @track chatCerrado = false;
    @wire(cerradoPorTimeOut, {idChat: '$recordId'})
    chatCerrado;

}