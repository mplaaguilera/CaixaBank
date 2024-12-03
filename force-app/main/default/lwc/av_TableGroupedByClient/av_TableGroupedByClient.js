import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getTaskData from "@salesforce/apex/AV_TableGroupedByClient_Controller.getData";
import BPRPS from '@salesforce/customPermission/AV_PrivateBanking';

import { CurrentPageReference } from 'lightning/navigation';

export default class Av_TableGroupedByClient extends NavigationMixin(LightningElement) {
    taskNumber;
    dataClient;
    renderComponent = false;
    buttonDisabled = true;
    subjectFilter = null;
    preconcedidoFilter = null;
    myBoxFilter = null;
    targetAutoFilter = null;
    showSpinner = false;
    colorFondo = 'green';
    mainClickFilter;

    @track isBpr = (BPRPS != undefined);
    //@track isBpr = false;
    
    // @track isBpr = true;


    filterResults = {
        subjectFilterValue: null,
        preconcedidoFilterValue: null,
        myBoxFilterValue: null,
        targetAutoFilterValue: null
    };

    get optionsPreconcedido() {
        return [
            { label: "Sí", value: "true" },
            { label: "No", value: "false" },
            { label: "", value: null }
        ];
    }

    get optionsYesOrNo() {
        return [
            { label: "Sí", value: "S" },
            { label: "No", value: "N" },
            { label: "", value: null }
        ];
    }

    get optionsSubject() {
        return this.optionsSubject;
    }

    get productArray() {

        let groupedDataMap = new Map();
        let previousAccount;
        let bgColor = 'bgColor';

        this.dataClient.forEach((product) => {
            if (groupedDataMap.has(product.name)) {
                //entra aquí si YA ESTABA ESE CLIENTE
                groupedDataMap.get(product.name).products.push(product);
                let newProduct = {};
                newProduct.name = product.name;
                newProduct.showIcon = product.showIcon;
                newProduct.taskNumber = groupedDataMap.get(
                    product.name
                ).products.length;
                newProduct.products = groupedDataMap.get(product.name).products;
                if (previousAccount == null) {
                    previousAccount = product.accountId;
                } else if (previousAccount != null && previousAccount != product.accountId) {
                    if (bgColor === 'bgColor') {
                        bgColor = 'bgcWhite';
                    } else {
                        bgColor = 'bgColor';
                    }
                }

                newProduct.colour = bgColor;
                groupedDataMap.set(product.name, newProduct);
                previousAccount = product.accountId;

            } else {
                //ENTRA AQUÍ SI NO ESTABA ESE CLIENTE
                let newProduct = {};
                newProduct.name = product.name;
                newProduct.showIcon = product.showIcon;
                newProduct.taskNumber = 1;
                newProduct.products = [product];
                if (previousAccount == null) {
                    previousAccount = product.accountId;
                } else if (previousAccount !== null && previousAccount !== product.accountId) {
                    if (bgColor === 'bgColor') {
                        bgColor = 'bgcWhite';
                    } else {
                        bgColor = 'bgColor';
                    }
                }

                newProduct.colour = bgColor;
                previousAccount = product.accountId;
                groupedDataMap.set(product.name, newProduct);

            }
        });





        let itr = groupedDataMap.values();
        let productArray = [];
        let result = itr.next();
        while (!result.done) {
            result.value.rowspan = result.value.products.length + 1;
            productArray.push(result.value);
            result = itr.next();
        }
        return productArray;
    }


    /**
     * The key-value pairs of the PageReference state property are serialized to URL query parameters
     * @param {*} pageRef 
     */
    @wire(CurrentPageReference)
    setCurrentPageRef(pageRef) {
        if (pageRef) {
            let rtLabelApiNameMap = new Map([
                ['Priorizador', 'AV_Priorizador'],
                ['Alertas Comerciales', 'AV_AlertaComercial'],
                ['Experiencia Cliente', 'AV_ExperienciaCliente'],
                ['Iniciativa Gestor/a', 'AV_Otros'],
                ['Onboarding', 'AV_Onboarding'],
                ['Onboarding Intouch', 'AV_Onboarding']
            ]);

            this.mainClickFilter = rtLabelApiNameMap.get(pageRef.state.c__fv9.replaceAll("'", ''));
        }
    }

    connectedCallback() { 

        this.isBpr = BPRPS;
        this.callApexToGetDataFiltered();

    }


    redirectToClient(event) {
        let id = this.getId(event.target.name);

        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                objectApiName: "Account",
                recordId: id,
                actionName: "view"
            }
        });
    }

    redirectToTask(event) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                objectApiName: "Task",
                recordId: event.target.name,
                actionName: "view"
            }
        });
    }

    getId(name) {
        let id;
        this.dataClient.forEach((d) => {
            if (d.name.toUpperCase() === name.toUpperCase()) {
                id = d.accountId;
            }
        });
        return id;
    }

    handleChangeSubject(event) {
        this.subjectFilter = event.target.value;
        this.filterResults.subjectFilterValue = this.subjectFilter;
        this.checkButtonStatus();
    }

    handleChangePreconcedido(event) {
        this.preconcedidoFilter = event.target.value;
        this.filterResults.preconcedidoFilterValue = this.preconcedidoFilter;
        this.checkButtonStatus();
    }

    handleChangeMyBox(event) {
        this.myBoxFilter = event.target.value;
        this.filterResults.myBoxFilterValue = this.myBoxFilter;
        this.checkButtonStatus();
    }

    handleChangeTargetAuto(event) {
        this.targetAutoFilter = event.target.value;
        this.filterResults.targetAutoFilterValue = this.targetAutoFilter;
        this.checkButtonStatus();
    }

    resetFilters() {
        this.template.querySelectorAll("lightning-input").forEach((each) => {
            each.value = "";
        });
        this.targetAutoFilter = null;
        this.myBoxFilter = null;
        this.preconcedidoFilter = null;
        this.filterResults = {
            subjectFilterValue: null,
            preconcedidoFilterValue: null,
            myBoxFilterValue: null,
            targetAutoFilterValue: null
        };
        this.buttonDisabled = true;
        this.showSpinner = true;
        this.callApexToGetDataFiltered();
    }

    handleSearchData() {
        this.showSpinner = true;
        this.callApexToGetDataFiltered();
    }

    callApexToGetDataFiltered() {
        getTaskData({ filterResults: this.filterResults, mainClickFilter: this.mainClickFilter })
            .then((result) => {
                this.dataClient = result;
                this.showSpinner = false;
                this.renderComponent = true; //TEST
            })
            .catch((error) => {
                console.log("error ", error);
            });
    }

    checkButtonStatus() {
        if (
            (this.filterResults.preconcedidoFilterValue === null ||
                this.filterResults.preconcedidoFilterValue === "") &&
            (this.filterResults.myBoxFilterValue === null ||
                this.filterResults.myBoxFilterValue === "") &&
            (this.filterResults.targetAutoFilterValue === null ||
                this.filterResults.targetAutoFilterValue === "") &&
            (this.filterResults.subjectFilterValue === null ||
                this.filterResults.subjectFilterValue === "")
        ) {
            this.buttonDisabled = true;
        } else {
            this.buttonDisabled = false;
        }
    }
}