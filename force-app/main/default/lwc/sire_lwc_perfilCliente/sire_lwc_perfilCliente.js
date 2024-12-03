import { LightningElement, wire, track, api } from 'lwc';
import wrapperCabecera from '@salesforce/apex/SIRE_LCMP_PerfilCliente.wrapperCabecera';

export default class Sire_lwc_perfilCliente extends LightningElement {

@api recordId;   
@track wrapper;
@track vacio = false;
@track mensaje;

@track mostrarTabs;

@wire(wrapperCabecera, { recordId: '$recordId' }) 
    wrapperCabecera({ error, data }) {
        if(this.recordId !== undefined && this.recordId.startsWith('001')){
            this.mostrarTabs = true;
        } else {
            this.mostrarTabs = false;
        }
        this.resultado = JSON.stringify(data);
        if(this.resultado === '{}'){
            this.mensaje = 'No existen registros asociados.';
            this.vacio = true;
        } else {                
            for(let key in data){                  
                if(key === 'NoProcesoActivo'){
                    this.mensaje = 'Cliente sin procesos activos, para consultar información actualizada dirigirse a pestaña Posiciones Cliente o bien al Terminal Financiero.\n';
                    this.mensaje += '\n En esta pestaña de Ficha de cliente encontraréis información de Procesos Históricos';
                    this.vacio = true;
                } else if(key === 'EMP'){
                    this.wrapper = data[key];                 
                } else {
                    this.vacio = true;
                    this.mensaje = 'No existen registros asociados.';
                }
            }                
        }
    }

}