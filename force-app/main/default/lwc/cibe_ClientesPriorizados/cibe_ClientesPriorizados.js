import { LightningElement, wire, track, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';


//labels
import titulo from '@salesforce/label/c.CIBE_ClientesPriorizados';
import subtitulo from '@salesforce/label/c.CIBE_ClientesPriorizadosReport';
import reiniciar from '@salesforce/label/c.CIBE_Reiniciar';
import aplicar from '@salesforce/label/c.CIBE_Aplicar';
import filtrar from '@salesforce/label/c.CIBE_FiltrarClientes';
import origen from '@salesforce/label/c.CIBE_Origen';
import grupoComercial from '@salesforce/label/c.CIBE_GrupoComercial';
import cliente from '@salesforce/label/c.CIBE_Cliente';
import asunto from '@salesforce/label/c.CIBE_Asunto';
import vencimiento from '@salesforce/label/c.CIBE_Vencimiento';
import lex from '@salesforce/label/c.CIBE_LexDisponible';
import contacto from '@salesforce/label/c.CIBE_UltContacto';
import modelo from '@salesforce/label/c.CIBE_ModeloDeAtencion';
import buscarAsunto from '@salesforce/label/c.CIBE_BuscarAsunto';
import buscarGC from '@salesforce/label/c.CIBE_BuscarGrupoComercial';
import tareasPendientesEMP from '@salesforce/label/c.CIBE_TareaspendientesEMP';
import cargando from '@salesforce/label/c.CIBE_Cargando';

//Controller
import getData from '@salesforce/apex/CIBE_ClientesPriorizadosController.getData';
import searchGrupoComercial from '@salesforce/apex/CIBE_ClientesPriorizadosController.searchGrupoComercial';

export default class Cibe_ClientesPriorizados extends LightningElement {

    labels = {
        titulo,
        subtitulo,
        reiniciar,
        aplicar, 
        filtrar,
        origen,
        grupoComercial,
        cliente,
        asunto,
        vencimiento,
        lex,
        contacto,
        modelo,
        buscarAsunto,
        buscarGC,
        tareasPendientesEMP,
        cargando
    }

    columns = [

        { label: this.labels.origen, fieldName: 'origen',sortable: true,type: 'text'}, 
        { label: this.labels.grupoComercial, fieldName: 'grupoComercialId', sortable: true, type: 'url',  typeAttributes: {label: {fieldName: 'grupoComercial'}}},
        { label: this.labels.cliente, fieldName: 'clienteId', sortable: true, type: 'url',  typeAttributes: {label: {fieldName: 'cliente'}}},
        { label: this.labels.asunto, fieldName: 'asuntoId', sortable: true, type: 'url',  typeAttributes: {label: {fieldName: 'asunto'}}},
        { label: this.labels.vencimiento, fieldName: 'fechaVencimiento',sortable: true,type: 'date', typeAttributes: {day: "2-digit", month: "2-digit", year: "numeric"}}, 
        { label: this.labels.lex, fieldName: 'lexDisponible',sortable: true,type: 'text', cellAttributes: { alignment: 'right' }}, 
        { label: this.labels.contacto, fieldName: 'contacto',sortable: true,type: 'date',  typeAttributes: {day: "2-digit", month: "2-digit", year: "numeric"}}, 
        { label: this.labels.modelo, fieldName: 'modelo',sortable: true,type: 'text'}, 

    ];

    @track data;
    @track buscar ='';
    @track errors = [];
    @track initialSelection = [];
    @track subjectFilter = null;
    @track showSpinner = false;
    @track selection = [];
    @track showPill = false;
    @track selectedIds = [];
    @track buttonDisabled = true;
    multiSelectionDouble = 0;
    originalLookUpOptions = [];
    @api clickFilter = null;
    @track auxData;
    @track auxClickFilter;

    //pills
    @track asunto = false;


    @track sortByFieldName;
    @track sortByLabel;
    @track sortDirection;
    @track defaultSort = 'asc';
    @api subjectPick;

    filterResults = {
        subjectFilterValue: null
    };
    
    @wire(getData, { filterResults : null, selectedIds : null, clickFilter : '$clickFilter'})
    wiredData({data, error}) {
        if(data){
            this.data = data;
            this.auxData = data;
            this.auxClickFilter = this.clickFilter;
        }else if(error){
            console.log(error);
        }
    }

    handleChangeSubject(event) {
        this.subjectFilter = event.target.value;
        this.filterResults.subjectFilterValue = this.subjectFilter;
        this.buttonDisabled = false;
    }

    handleSearchGrupoComercial(event) {
		const lookupElement = event.target;
		searchGrupoComercial ({searchTerm: event.detail.searchTerm})
        .then((results) => {
            this.template.querySelector('[data-id="clookup4"]').setSearchResults(results);
            this.template.querySelector('[data-id="clookup4"]').scrollIntoView();
            this.originalLookUpOptions = results;
            })
			.catch((error) => {
				console.error(error);
				this.errors = [error];
			});
	}

    handleSearchData(){
        this.showSpinner = true;
        this.call();
    }

    resetFilters() {
        this.template.querySelectorAll("lightning-input", "c-av_-lookup").forEach((each) => {
            each.value = "";
        });
        this.template.querySelectorAll('[data-id="clookup4"]').forEach((each) => {
            each.value = null;
        });
        this.filterResults = {
            subjectFilterValue: null
        };
        this.selection = [];
        this.showPill = false;
        this.showSpinner = false;
        this.data = this.auxData;
    }

    handleSelectionChange(event){
        this.multiSelectionDouble++;
        this.initialSelection = [];
        this.buttonDisabled = false;
        this.selectedIds = event.detail;

        this.errors = [];
		var targetId = event.target.dataset.id;
		if (targetId == 'clookup4') {
            const selection = this.template.querySelector('c-av_-lookup').getSelection();
            if(selection != undefined){
                for (let i = 0; i < this.originalLookUpOptions.length; i++) {
                    if (this.originalLookUpOptions[i].id == this.selectedIds) {
                        this.subjectPick = {
                            'icon':'standard:account',
                            id:this.originalLookUpOptions[i].id,
                            'sObjectType':'Account',
                            'subtitle':'Matricula •',
                            'title':this.originalLookUpOptions[i].title,
                            'bucleId':this.multiSelectionDouble
                        };
                        break;
                    }
                }
                let insert = true;
                if (this.selection.length > 0) {
                    for (let i = 0; i < this.selection.length; i++) {
                        if (this.selection[i].id == this.subjectPick.id) {
                            insert = false;
                            break;
                        }
                    }
                }
                if (insert) {
                    this.selection.push(this.subjectPick);
                }       
            }
        }
        this.showPill = true;
    }
    
    handleRemoveSelectedItem(event){
        const recordId = event.currentTarget.name;
        this.selection = this.selection.filter((item) => item.id !== recordId);
    }

    call() {
        this.auxClickFilter = this.clickFilter != null ? this.clickFilter : '' ;

        getData({ filterResults: this.filterResults, selectedIds : this.selectedIds, clickFilter : this.auxClickFilter })
            .then((result) => {
                this.data = result;
                refreshApex(this.data);
            })
            .catch((error) => {
                console.log("error ", error);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    handleSortData(event) {
        this.sortByFieldName = event.detail.fieldName;
        let sortField = event.detail.fieldName;
        for (let col of this.columns) {
            if (col.fieldName == this.sortByFieldName && col.type == 'url'){
                sortField = col.typeAttributes.label.fieldName;
            }
        }
        this.sortDirection = event.detail.sortDirection;
        this.sortData(sortField, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        let keyValue = (a) => {
            return a[fieldname];
        };

        let isReverse = direction === 'asc' ? 1: -1;
        this.data = parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.data.forEach(e => {
            console.log(e);
        })
    }  

    sortBy(field, reverse, primer) {
        const key = primer ? function(x) {
            return primer(x[field]);
        } : function(x) {
                return x[field];
            };
        
        return function(a, b) {
            a = key(a);
            b = key(b);
         return reverse * ((a > b) - (b > a));
        };
    }
}