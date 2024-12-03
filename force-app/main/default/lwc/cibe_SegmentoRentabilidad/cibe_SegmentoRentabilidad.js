import { LightningElement, api,track, wire } from 'lwc';
import LWC_DATATABLE_CSS from '@salesforce/resourceUrl/CIBE_MeetingAttendesIcon'
import { loadStyle } from 'lightning/platformResourceLoader';



//labels
import helpAbsoluta from '@salesforce/label/c.CIBE_Absoluta';
import helpRelativa from '@salesforce/label/c.CIBE_Relativa';
import empresa from '@salesforce/label/c.CIBE_Empresa';
import grupoCEconomico from '@salesforce/label/c.CIBE_Grupo';
import segmento from '@salesforce/label/c.CIBE_SegmentoRentabilidad';
import absoluta from '@salesforce/label/c.CIBE_AbsolutaS';
import relativa from '@salesforce/label/c.CIBE_RelativaS';


//apex
import getAccount from '@salesforce/apex/CIBE_SegmentoRentabilidadController.getAccount';
import getValues from '@salesforce/apex/CIBE_SegmentoRentabilidadController.getValues';


export default class Cibe_SegmentoRentabilidad extends LightningElement {

    @api recordId;
    @track absolutaEmpresa;
    @track absolutaGrupo;
    @track relativaGrupo;
    @track relativaEmpresa;
    @track values;

    @track empresaRelativa = false;
    @track empresaAbsoluta = false;
    @track grupoAbsoluta = false;
    @track grupoRelativa = false;
    
    //Nombres Class CSS
	empresaAbsolutaClass;
    empresaRelativaClass;
    grupoAbsolutaClass;
    grupoRelativaClass;
    

    mapIcon = {
        'A' : 'alta-icon',
        'MA' : 'mediaAlta-icon',
        'M' : 'media-icon',
        'MB' : 'mediaBaja-icon',
        'B' : 'baja-icon',
        'MOR' : 'morosos-icon',
        'IN' : 'inactivos-icon',
        'P' : 'financiacionProyecto-icon'
    };

    labels = {
        helpAbsoluta,
        helpRelativa,
        empresa,
        grupoCEconomico,
        segmento,
        absoluta,
        relativa
    }


    connectedCallback() {
        loadStyle(this, LWC_DATATABLE_CSS);
    }

    @wire(getValues)
    wiredValues({error, data}){
    if(data){
        this.values = data;
    }else if(error){Console.log(error);}}

    @wire(getAccount, {recordId : '$recordId'})
    wiredAccount({error, data}){
        if(data){

            data.forEach(element => {
                this.updateState('absolutaEmpresa', 'empresaAbsoluta', element, 'empresaAbsolutaClass');

                this.updateState('relativaEmpresa', 'empresaRelativa', element, 'empresaRelativaClass');

                this.updateState('absolutaGrupo', 'grupoAbsoluta', element, 'grupoAbsolutaClass');

                this.updateState('relativaGrupo', 'grupoRelativa', element, 'grupoRelativaClass');
            });

        }else if(error){Console.log(error);}
    }

    updateState(value, flag, element, states) {
        if (element[value] != null && this.values != null) {

            this.values.forEach(e => {
                if(e.value === element[value]){
                    this[value] = e.label;
                    this[flag] = true;
                    this[states] = this.mapIcon[element[value]];
                }
            });

        }
    }
}