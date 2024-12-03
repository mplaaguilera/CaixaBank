import { LightningElement, wire, api, track } from 'lwc';
import getConsultasTareas from '@salesforce/apex/SAC_LCMP_ConsultasTareas.getActionConsultaOffice';
import getURLHomeOficinas from '@salesforce/apex/SAC_LCMP_ConsultasTareas.getURLHomeOficinas';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const columns = [   
    {   
        label: 'Tipo', fieldName: 'SAC_Tipo', type: 'text', sortable: true,
        cellAttributes:{
            class:{fieldName:'colorRow'}
        }
    },
    {   
        label: 'Nombre reclamante principal', fieldName: 'SAC_Reclamante__c', type: 'text', sortable: true,
        cellAttributes:{
            class:{fieldName:'colorRow'}
        }
    },
    {   
        label: 'Documento identidad reclamante principal', fieldName: 'SAC_DNIReclamante__c', type: 'text', sortable: true,
        cellAttributes:{
            class:{fieldName:'colorRow'}
        }
    },
    {   
        label: 'Fecha vencimiento', fieldName: 'SAC_FechaVencimiento__c', type: 'text', sortable: true,
        cellAttributes:{
            class:{fieldName:'colorRow'}
        }
    },
    {   
        label: 'Número de oficina', fieldName: 'SAC_Oficina__c', type: 'text', sortable: true,
        cellAttributes:{
            class:{fieldName:'colorRow'}
        }
    }
]

   
   
export default class SAC_ConsultasTareas extends LightningElement {

    @api columns = columns;
    @track ConsultasList = [];
    @track tituloTabla;
    
    @track defaultSortDirection = 'asc';
    //@track sortDirectionConsultasTareas = 'asc';
    //sortedBy;

    @wire(getConsultasTareas, {})
    getConsultasTareas({ error, data }) { 

        if(data){
            let listaTareas = data.lstTareas;
            let listaConsultas = data.lstConsultas;
            let currentDataA = [];
            let currentDataB = [];

            //cargar los datos de la consulta
            currentDataA = listaConsultas.map(item=>{
                let tipo = 'Consulta';
                let SAC_Reclamante__c =  item.SAC_Reclamante__c;
                let SAC_DNIReclamante__c = item.SAC_Reclamacion__r.CC_SuppliedNIF__c;
                let SAC_FechaVencimiento__c = item.SAC_Fecha_Vencimiento__c;
                let SAC_Oficina__c = item.SAC_Oficina__r.AV_NumeroCentroCaixaBank__c; /* CC_Numero_Oficina__pc */

                return {...item, 
                    "SAC_Tipo":tipo,
                    "SAC_Reclamante__c":SAC_Reclamante__c, 
                    "SAC_DNIReclamante__c":SAC_DNIReclamante__c,
                    "SAC_FechaVencimiento__c":SAC_FechaVencimiento__c,
                    "SAC_Oficina__c":SAC_Oficina__c
                    };  
            });        

            currentDataB = listaTareas.map(item=>{
                let tipo = 'Tarea';
                let SAC_Reclamante__c =  item.SAC_Reclamacion__r.SAC_NombreContacto__c; //item.SAC_Reclamacion__r.AccountId.Name
                let SAC_DNIReclamante__c = item.SAC_Reclamacion__r.CC_SuppliedNIF__c;
                let SAC_FechaVencimiento__c = item.SAC_FechaVencimiento__c;
                let SAC_Oficina__c = item.SAC_Oficina__r.AV_NumeroCentroCaixaBank__c;

                return {...item, 
                    "SAC_Tipo":tipo,
                    "SAC_Reclamante__c":SAC_Reclamante__c, 
                    "SAC_DNIReclamante__c":SAC_DNIReclamante__c,
                    "SAC_FechaVencimiento__c":SAC_FechaVencimiento__c,
                    "SAC_Oficina__c":SAC_Oficina__c
                    };
            });
            //this.tituloTabla = 'Procesos pendientes (' +  (listaTareas.length + listaConsultas.length) + ')';
            this.tituloTabla = 'Reclamaciones pendientes (URGENTES 24 h.) (' +  (listaTareas.length + listaConsultas.length) + ')';
            this.ConsultasList = [...currentDataA, ...currentDataB];
        }else{
			this.mostrarToast('error', 'ERROR', JSON.stringify(error));
        }
    }

    mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({
			variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000
		}));
	}

    goToHomeOficinas(){
        getURLHomeOficinas({}).then(result => {            
          //  window.open(result, "_blank"); www.google.com/_vmcNewTab=true 
            window.open(result); 
        })
        .catch(error => {
			this.mostrarToast('error', 'ERROR', JSON.stringify(error));
        });
    }

    onHandleSortConsultasTareas(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.ConsultasList];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        // this.ConsultasList = cloneData;
        // this.sortDirectionConsultasTareas = sortDirection;
        //this.sortedBy = sortedBy;
        return sortedBy;
    }

    onHandleSortDirectionConsultasTareas(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.ConsultasList];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        return sortDirection;
    }

    onHandleSortConsultasList(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.ConsultasList];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        return cloneData;
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
}