import { LightningElement,track,wire } from 'lwc';
import {NavigationMixin} from 'lightning/navigation'
import Id from '@salesforce/user/Id';

import getReportsUniqueName from '@salesforce/apex/CIBE_Tab_Custom_Oportunidades.getReportsUniqueName';
	
import tabLabel from '@salesforce/label/c.CIBE_Tab';	
import reportLabel from '@salesforce/label/c.CIBE_Report';

export default class Cibe_TabOportunidad extends NavigationMixin(LightningElement) {
    
    label = {
        tabLabel,
        reportLabel
    };

    // Mapa que contiene los valores de los filtros, el id del reporte y el nombre del reporte.
    @track reportsForCurrentView = [];
    @track tabsForCurrentView = [];


    @track tabs = [];
    @track reports = [];

    @track ifTabs = false;
    @track ifReports = false;

    //Indicamos si el listado está cargado o no.
    @track isExpanded = false;
    @track isLoaded = false;

    //Indicamos el filtro actual.
    opportunities = 'Oportunidades';

    //Obtenemos los reportes de un Custom Metadata a traves de un Apex Controller y populamos el mapa reportsForCurrentView.
    @wire(getReportsUniqueName , { userId: Id })
    getReportsUniqueName({data, error}) {
        if(data) {
            if(data.wrapperReports){

                if(data.wrapperReports.length > 0){this.ifReports = true;}
                this.reports = data.wrapperReports;
            
                this.reports .forEach(report=> {
                    if(report.header == true){
                        this.reportsForCurrentView.unshift({value: report.name, id:report.id});
                    }else{
                        this.reportsForCurrentView.push({value: report.name, id:report.id});
                    }
                });
            }
        
        if(data.wrapperTabs) {
            if(data.wrapperTabs.length > 0){this.ifTabs = true;}

            this.tabs = data.wrapperTabs;
            this.tabs.forEach(tab=> {

                if(tab.developerName == true){
                    this.tabsForCurrentView.unshift({value: tab.developerName, label:tab.label});
                }else{
                    this.tabsForCurrentView.push({value: tab.developerName, label:tab.label});
                }
            });
        }
    }
        else if(error) {
            window.console.log(error);
        }
        
    }
    

    //Controlador de la clase CSS que se aplica al botón de filtrado.
    get dropdownTriggerClass() {
        if (this.isExpanded) {
            return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view slds-is-open'
        } else {
            return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view'
        }
    }

    //Controlador de la clase CSS que se aplica al icono de filtrado.
    get dropdownIconTriggerClass() {
        if (this.isExpanded) {
            return 'slds-truncate slds-button overlow-text  slds-button_icon slds-button_icon-border slds-button_icon-x-small'
        } else {
            return 'slds-truncate slds-button overlow-text  slds-button_icon  slds-button_icon-x-small'
        }
    }

    //Controlador de la clase CSS que se aplica al icono de filtrado.
    get iconNameTriggerClass() {
        if (this.isExpanded) {
            return 'utility:up'
        } else {
            return 'utility:down'
        }
    }
 
    // Controlador del evento que se lanza al seleccionar un filtro.
    handleFilterChangeButton(event) {
        console.log('handleFilterChangeButton: ' +event );

        this.isLoaded = false;
        let filter = event.target.dataset.filter;
        this.isExpanded = !this.isExpanded;
        this.sendToReportPage(filter), 0
    
        this.isLoaded = true;
        
    }

      // Controlador del evento que se lanza al seleccionar un filtro.
      handleFilterChangeButtonTabs(event) {
        
        this.isLoaded = false;
        let filter = event.target.dataset.filter;
        this.isExpanded = !this.isExpanded;
        this.sendToTabPage(filter), 0
        this.isLoaded = true;
    }

    // Controlador del evento que se lanza al seleccionar un filtro.
    sendToReportPage(filter) {
        let reportId = this.reportsForCurrentView.find(item => item.value === filter).id;
        let objectApiName = this.reportsForCurrentView.find(item => item.value === filter).objectApiName; 
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: reportId,
                objectApiName: objectApiName, 
                actionName: 'view'
            }
        });  }

        // Controlador del evento que se lanza al seleccionar un filtro.
    sendToTabPage(filter) {
        let tabValue = this.tabsForCurrentView.find(item => item.label === filter).value;

        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: tabValue
            }
});
}
    
    
    // Controlador del evento que se lanza al pulsar el botón de filtrado.
    handleClickExtend() {
        this.isExpanded = !this.isExpanded;
    }

}