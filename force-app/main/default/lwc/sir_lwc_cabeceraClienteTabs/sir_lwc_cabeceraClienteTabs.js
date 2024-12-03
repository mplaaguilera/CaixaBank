import { LightningElement, wire, track, api } from 'lwc';
import wrapperCabeceraTabs from '@salesforce/apex/SIR_LCMP_GetProfileClient.wrapperCabeceraTabs';
import procesosPendientes from '@salesforce/apex/SIR_LCMP_GetProfileClient.procesosPendientes';

export default class Sir_lwc_cabeceraClienteTabs extends LightningElement {

@api recordId;   
@track wrapperIMPA;
@track wrapperPRESOL;
@track tabIMPA = 'Impagados 1-90';
@track tabPRESOL = 'PRESOL-Preventivo';
//@track vacio = false;
@track vacioIMPA = true;
@track vacioPRESOL = true;
@track mensaje;

@track resultado;

@wire(procesosPendientes, { recordId: '$recordId'}) 
    procesosPendientes({ error, data }) {
        if (data) {
            if(data === 'IMPA'){
                this.template.querySelector('lightning-tabset').activeTabValue = 'IMPA';
            }else if(data === 'PRESOL'){
                this.template.querySelector('lightning-tabset').activeTabValue = 'PRESOL';
            }
            
        }
    }

@wire(wrapperCabeceraTabs, { recordId: '$recordId'})
    wrapperCabeceraTabs({ error, data }) {
        if (data) {            
            this.resultado = JSON.stringify(data);
            if(this.resultado === '{}'){
                this.mensaje = 'No existen registros asociados.';
                this.vacioIMPA = true;
                this.vacioPRESOL = true;
            } else {
                for(var key in data){
                    if(key === 'NoProcesoActivo'){
                        this.mensaje = 'Cliente sin procesos activos, para consultar información actualizada dirigirse al Terminal Financiero.\n';
                        this.mensaje += '\n En esta Ficha de cliente encontraréis información de Procesos Históricos.';
                        this.vacioIMPA = true;
                        this.vacioPRESOL = true;
                    } else if(key === 'IMPA'){
                        this.wrapperIMPA = data[key];
                        this.vacioIMPA = false;
                    } else if(key === 'PRESOL'){                        
                        this.wrapperPRESOL = data[key];
                        this.vacioPRESOL = false;
                    }else{
                        this.vacioIMPA = true;
                        this.vacioPRESOL = true;
                        this.mensaje = 'No existen registros asociados.';
                    }
                }
                if((this.vacioIMPA === true || this.vacioPRESOL === true) && this.mensaje === undefined){
                    this.mensaje = 'No existen registros asociados.';
                }
            }
        }
    }
}