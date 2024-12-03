import { LightningElement, api, track, wire } from 'lwc';
import datosTotalApex from '@salesforce/apex/CC_Supervisor.datosTotal';
import tiempoRefrescoApex from '@salesforce/apex/CC_Supervisor.tiempoRefresco';

const mycolumnsCount = [
    { label: 'Servicio', fieldName: 'servicio', type: 'text' },
    { label: 'DXC', fieldName: 'contadorDXC', type: 'Integer' },
    { label: 'MST', fieldName: 'contadorMST', type: 'Integer' }
];

const skillReqListCount = [];

export default class cc_OmniSupervisor extends LightningElement {
    skillReqListCount = [];
    mycolumnsCount = mycolumnsCount;

    connectedCallback() {
        tiempoRefrescoApex({}).then(result =>{
            this.interval = window.setInterval(() => {
                this.datosTotal();
            }, result*1000); 
        });  
        
    }

    datosTotal(){
        datosTotalApex({}).then(result => {
            this.skillReqListCount = result;
            
        })
        .catch(error => { 
            console.log(JSON.stringify(error));
        });
    }
    
    disconnectedCallback(){
        window.clearInterval(this.interval);
    }
}