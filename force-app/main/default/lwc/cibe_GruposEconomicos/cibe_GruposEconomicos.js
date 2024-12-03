import { LightningElement, api, wire, track } from 'lwc';

import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';

import LWC_DATATABLE_CSS from '@salesforce/resourceUrl/CIBE_GruposEconomicosIcon'
import { loadStyle } from 'lightning/platformResourceLoader';

import getData from '@salesforce/apex/CIBE_GruposEconomicos_Controller.getData';
import getParentsData from '@salesforce/apex/CIBE_GruposEconomicos_Controller.getParentsData';
import roleCib  from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.roleCIB2';


import dominio from '@salesforce/label/c.CIBE_Dominio';
import restringido from '@salesforce/label/c.CIBE_Restringido';
import ampliado from '@salesforce/label/c.CIBE_Ampliado';
import nombreCliente from '@salesforce/label/c.CIBE_NombreClienteT';

import rarGrupo from '@salesforce/label/c.CIBE_RARGrupo';
import facturacion from '@salesforce/label/c.CIBE_Facturacion';
import financiacion from '@salesforce/label/c.CIBE_Financiacion';
import lex from '@salesforce/label/c.CIBE_LEX';
import vencimientoLex from '@salesforce/label/c.CIBE_VencimientoLEX';
import ahorroInversion from '@salesforce/label/c.CIBE_AhorroInversion';
import eapManager from '@salesforce/label/c.CIBE_EAPGestor';
import fuente from '@salesforce/label/c.CIBE_Fuente';
import tipoGrEconomico from '@salesforce/label/c.CIBE_TipoGrupoEconomico';
import selectType from '@salesforce/label/c.CIBE_SelectType';
import segmentoRentabilidadEA from '@salesforce/label/c.CIBE_SegmentoRentabilidadEA';
import segmentoRentabilidadER from '@salesforce/label/c.CIBE_SegmentoRentabilidadER';
import segmentoRentabilidadGA from '@salesforce/label/c.CIBE_SegmentoRentabilidadGA';
import segmentoRentabilidadGR from '@salesforce/label/c.CIBE_SegmentoRentabilidadGR';



export default class Cibe_GruposEconomicos extends NavigationMixin(LightningElement) {
    labels = {
        dominio,
        restringido,
        ampliado,
        nombreCliente,
        rarGrupo,
        facturacion,
        financiacion,
        lex,
        vencimientoLex,
        ahorroInversion,
        eapManager,
        fuente,
        tipoGrEconomico,
        selectType,
        segmentoRentabilidadEA,
        segmentoRentabilidadER,
        segmentoRentabilidadGA,
        segmentoRentabilidadGR
    }
    
    
    
    @track options = [
        { label: this.labels.dominio,  value: '110' },
        { label: this.labels.restringido,  value: '120' },
        { label: this.labels.ampliado,  value: '130' }
    ];
    

    @api recordId;
    @track showLoadingHeader = false;
    @track showLoadingBody = false;
    @track record;
    @track recordCIB;

    @track hasParents = false;
    @track positionToExpand = 0;
    @track parentStructure = [];
    @track parentStructureBackup = [];
    @track parentStructureReversed = [];

    //@track options = options;
    @track tipoGrupo = '120';
    
    //cib
    @track cib = false;

    @track _wiredData;
    @wire(getData, { recordId : '$recordId', tipoGrupo : '$tipoGrupo' })
    gridData(wireResult) {
        const { error, data } = wireResult;
        this._wiredData = wireResult;
        if (data) {
            let objs = JSON.parse(JSON.stringify(data));
            objs.map(e =>{
                if(e['children']) {
                    e._children = e['children'];
                }
            })
            this.record = objs;
            this.recordCIB = objs;


            this.recordCIB = data.map((item) => {
                const iconObj = {...item};

                //empresa absoluta
                if(item.empresaAbsoluta === 'Alta' || item.empresaAbsoluta === 'High'){
                    iconObj.priorityiconEA = "utility:record" ;
                    iconObj.classEstadoEA = 'classAlta'
                }else if(item.empresaAbsoluta === 'Media Alta' || item.empresaAbsoluta === 'Medium High'){
                    iconObj.priorityiconEA = "utility:record" ;
                    iconObj.classEstadoEA = 'classMediaAlta'
                }else if(item.empresaAbsoluta === 'Media' || item.empresaAbsoluta === 'Medium'){
                    iconObj.priorityiconEA = "utility:record" ;
                    iconObj.classEstadoEA = 'classMedia'
                }else if(item.empresaAbsoluta === 'Media Baja' || item.empresaAbsoluta === 'Medium Low'){
                    iconObj.priorityiconEA = "utility:record" ;
                    iconObj.classEstadoEA = 'classMediaBaja'
                }else if(item.empresaAbsoluta === 'Baja' || item.empresaAbsoluta === 'Low'){
                    iconObj.priorityiconEA = "utility:record" ;
                    iconObj.classEstadoEA = 'classBaja'
                }else if(item.empresaAbsoluta === 'Morosos' || item.empresaAbsoluta === 'Default'){
                    iconObj.priorityiconEA = "utility:record" ;
                    iconObj.classEstadoEA = 'classBaMorosos'
                }else if(item.empresaAbsoluta === 'Inactivos' || item.empresaAbsoluta === 'Inactive'){
                    iconObj.priorityiconEA = "utility:record" ;
                    iconObj.classEstadoEA = 'classInactivos'
                }else if(item.empresaAbsoluta === 'Project Finance'){
                    iconObj.priorityiconEA = "utility:record" ;
                    iconObj.classEstadoEA = 'classFinanciacionProyecto'
                }

                //empresa relativa

                if(item.empresaRelativa === 'Alta' || item.empresaRelativa === 'High'){
                    iconObj.priorityiconER = "utility:record" ;
                    iconObj.classEstadoER = 'classAlta'
                }else if(item.empresaRelativa === 'Media Alta' || item.empresaRelativa === 'Medium High'){
                    iconObj.priorityiconER = "utility:record" ;
                    iconObj.classEstadoER = 'classMediaAlta'
                }else if(item.empresaRelativa === 'Media' || item.empresaRelativa === 'Medium'){
                    iconObj.priorityiconER = "utility:record" ;
                    iconObj.classEstadoER = 'classMedia'
                }else if(item.empresaRelativa === 'Media Baja' || item.empresaRelativa === 'Medium Low'){
                    iconObj.priorityiconER = "utility:record" ;
                    iconObj.classEstadoER = 'classMediaBaja'
                }else if(item.empresaRelativa === 'Baja' || item.empresaRelativa === 'Low'){
                    iconObj.priorityiconER = "utility:record" ;
                    iconObj.classEstadoER = 'classBaja'
                }else if(item.empresaRelativa === 'Morosos' || item.empresaRelativa === 'Default'){
                    iconObj.priorityiconER = "utility:record" ;
                    iconObj.classEstadoER = 'classBaMorosos'
                }else if(item.empresaRelativa === 'Inactivos' || item.empresaRelativa === 'Inactive'){
                    iconObj.priorityiconER = "utility:record" ;
                    iconObj.classEstadoER = 'classInactivos'
                }else if(item.empresaRelativa === 'Project Finance'){
                    iconObj.priorityiconER = "utility:record" ;
                    iconObj.classEstadoER = 'classFinanciacionProyecto'
                }


                //grupo absoluta
                if(item.grupoAbsoluta === 'Alta' || item.grupoAbsoluta === 'High'){
                    iconObj.priorityiconGA = "utility:record" ;
                    iconObj.classEstadoGA = 'classAlta'
                }else if(item.grupoAbsoluta === 'Media Alta' || item.grupoAbsoluta === 'Medium High'){
                    iconObj.priorityiconGA = "utility:record" ;
                    iconObj.classEstadoGA = 'classMediaAlta'
                }else if(item.grupoAbsoluta === 'Media' || item.grupoAbsoluta === 'Medium'){
                    iconObj.priorityiconGA = "utility:record" ;
                    iconObj.classEstadoGA = 'classMedia'
                }else if(item.grupoAbsoluta === 'Media Baja' || item.grupoAbsoluta === 'Medium Low'){
                    iconObj.priorityiconGA = "utility:record" ;
                    iconObj.classEstadoGA = 'classMediaBaja'
                }else if(item.grupoAbsoluta === 'Baja' || item.grupoAbsoluta === 'Low'){
                    iconObj.priorityiconGA = "utility:record" ;
                    iconObj.classEstadoGA = 'classBaja'
                }else if(item.grupoAbsoluta === 'Morosos' || item.grupoAbsoluta === 'Default'){
                    iconObj.priorityiconGA = "utility:record" ;
                    iconObj.classEstadoGA = 'classBaMorosos'
                }else if(item.grupoAbsoluta === 'Inactivos' || item.grupoAbsoluta === 'Inactive'){
                    iconObj.priorityiconGA = "utility:record" ;
                    iconObj.classEstadoGA = 'classInactivos'
                }else if(item.grupoAbsoluta === 'Project Finance'){
                    iconObj.priorityiconGA = "utility:record" ;
                    iconObj.classEstadoGA = 'classFinanciacionProyecto'
                }

                //grupo relativa
                if(item.grupoRelativa === 'Alta' || item.grupoRelativa === 'High'){
                    iconObj.priorityiconGR = "utility:record" ;
                    iconObj.classEstadoGR = 'classAlta'
                }else if(item.grupoRelativa === 'Media Alta' || item.grupoRelativa === 'Medium High'){
                    iconObj.priorityiconGR = "utility:record" ;
                    iconObj.classEstadoGR = 'classMediaAlta'
                }else if(item.grupoRelativa === 'Media' || item.grupoRelativa === 'Medium'){
                    iconObj.priorityiconGR = "utility:record" ;
                    iconObj.classEstadoGR = 'classMedia'
                }else if(item.grupoRelativa === 'Media Baja' || item.grupoRelativa === 'Medium Low'){
                    iconObj.priorityiconGR = "utility:record" ;
                    iconObj.classEstadoGR = 'classMediaBaja'
                }else if(item.grupoRelativa === 'Baja' || item.grupoRelativa === 'Low'){
                    iconObj.priorityiconGR = "utility:record" ;
                    iconObj.classEstadoGR = 'classBaja'
                }else if(item.grupoRelativa === 'Morosos' || item.grupoRelativa === 'Default'){
                    iconObj.priorityiconGR = "utility:record" ;
                    iconObj.classEstadoGR = 'classBaMorosos'
                }else if(item.grupoRelativa === 'Inactivos' || item.grupoRelativa === 'Inactive'){
                    iconObj.priorityiconGR = "utility:record" ;
                    iconObj.classEstadoGR = 'classInactivos'
                }else if(item.grupoRelativa === 'Project Finance'){
                    iconObj.priorityiconGR = "utility:record" ;
                    iconObj.classEstadoGR = 'classFinanciacionProyecto'
                }

                
                return iconObj;
                
            });

        } else if (error) {
            console.log(error);
        }
    }

    @track _wireParentsResult;
    @wire(getParentsData, { recordId : '$recordId', tipoGrupo : '$tipoGrupo', positionToExpand : '$positionToExpand',  parentStructure : '$parentStructureBackup' })
    parentsData(wireResult){
        const { error, data } = wireResult;
        this._wireParentsResult = wireResult;
        if (data) {
            this.parentStructure = JSON.parse(JSON.stringify(data));
            if(this.parentStructure.length > 0) {
                this.parentStructureReversed = [];
                this.parentStructure.forEach((e, i) => {
                    const reversed = [...e];
                    this.parentStructureReversed.push(reversed.reverse());
                });
                this.hasParents = true;
            }
        } else if (error) {
            console.log(error);
        }
    }

    gridColumns = [
        {
            type: 'url',
            typeAttributes : {
                label : {
                    fieldName : "accountName"
                },
                target: '_self'
            },
            fieldName: 'showRecord',
            label: this.labels.nombreCliente
        },
        {
            type: 'text',
            fieldName: 'rar',
            label: 'RAR',
            cellAttributes: {
                alignment: 'right'
            },
            initialWidth : 80
        },
        {
            type: 'text',
            fieldName: 'rarGrupo',
            label: this.labels.rarGrupo,
            cellAttributes: {
                alignment: 'right'
            },
            initialWidth : 120
        },
        {
            type: 'text',
            fieldName: 'facturacion',
            label: this.labels.facturacion,
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'text',
            fieldName: 'activo',
            label: this.labels.financiacion,
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'text',
            fieldName: 'lexDisponible',
            label: this.labels.lex,
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'date',
            fieldName: 'lexFechaViegencia',
            label: this.labels.vencimientoLex,
            cellAttributes: {
                alignment: 'right'
            },
            typeAttributes: {
                day: "numeric",
                month: "2-digit",
                year: "numeric"
            }
        },
        {
            type: 'text',
            fieldName: 'pasivo',
            label: this.labels.ahorroInversion,
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'url',
            typeAttributes : {
                label : {
                    fieldName : "gestorName"
                },
                target: '_self'
            },
            fieldName: 'gestorNameLink',
            label: this.labels.eapManager
        },
        {
            type: 'text',
            fieldName: 'source',
            label: this.labels.fuente,
            cellAttributes: {
                alignment: 'center'
            },
            wrapText: true
        }
    ];

    gridColumnsCIB = [
        {
            type: 'url',
            typeAttributes : {
                label : {
                    fieldName : "accountName"
                },
                target: '_self'
            },
            fieldName: 'showRecord',
            label: this.labels.nombreCliente
        },
        {
            type: 'text',
            fieldName: 'rar',
            label: 'RAR',
            cellAttributes: {
                alignment: 'right'
            },
            initialWidth : 80
        },
        { label: this.labels.segmentoRentabilidadEA, fieldName : 'empresaAbsoluta',  type: 'text', cellAttributes: { iconName: { fieldName: 'priorityiconEA' }, class: {fieldName: 'classEstadoEA'}}  },
        { label: this.labels.segmentoRentabilidadER, fieldName : 'empresaRelativa',  type: 'text', cellAttributes: { iconName: { fieldName: 'priorityiconER' }, class: {fieldName: 'classEstadoER'}}},

        {
            type: 'text',
            fieldName: 'rarGrupo',
            label: this.labels.rarGrupo,
            cellAttributes: {
                alignment: 'right'
            },
            initialWidth : 120
        },
        { label: this.labels.segmentoRentabilidadGA, fieldName : 'grupoAbsoluta',  type: 'text', cellAttributes: { iconName: { fieldName: 'priorityiconGA' }, class: {fieldName: 'classEstadoGA'}}},
        { label: this.labels.segmentoRentabilidadGR, fieldName : 'grupoRelativa',  type: 'text', cellAttributes: { iconName: { fieldName: 'priorityiconGR' }, class: {fieldName: 'classEstadoGR'}}},

        {
            type: 'text',
            fieldName: 'facturacion',
            label: this.labels.facturacion,
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'text',
            fieldName: 'activo',
            label: this.labels.financiacion,
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'text',
            fieldName: 'lexDisponible',
            label: this.labels.lex,
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'date',
            fieldName: 'lexFechaViegencia',
            label: this.labels.vencimientoLex,
            cellAttributes: {
                alignment: 'right'
            },
            typeAttributes: {
                day: "numeric",
                month: "2-digit",
                year: "numeric"
            }
        },
        {
            type: 'text',
            fieldName: 'pasivo',
            label: this.labels.ahorroInversion,
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'url',
            typeAttributes : {
                label : {
                    fieldName : "gestorName"
                },
                target: '_self'
            },
            fieldName: 'gestorNameLink',
            label: this.labels.eapManager
        },
        {
            type: 'text',
            fieldName: 'source',
            label: this.labels.fuente,
            cellAttributes: {
                alignment: 'center'
            },
            wrapText: true
        }
    ];


    handleRowToggle(event) {
        function getNewDataWithChildren (rowName, data, children) {
            return data.map(function(row) {
                let hasChildrenContent = false;
                if (row.hasOwnProperty('_children') && Array.isArray(row._children) && row._children.length > 0) {
                    hasChildrenContent = true;
                }
                if (row.id === rowName) {
                    row._children = children;
                } else if (hasChildrenContent) {
                    getNewDataWithChildren(rowName, row._children, children);
                }
                return row;
            });
        }

        const rowName = event.detail.row.id;
        const hasChildrenContent = event.detail.hasChildrenContent;
        if (!hasChildrenContent) {
            this.showLoadingBody = true;
            getData({recordId: event.detail.row.id, tipoGrupo: this.tipoGrupo}).then(result => {
                let objs = JSON.parse(JSON.stringify(result));
                objs.map(e =>{
                    if(e['children']) {
                        e._children = e['children'];
                    }
                });                
                this.record = getNewDataWithChildren(rowName, this.record, objs);
            }).catch(error => {
                console.log(error);
            }).finally(e => {
                this.showLoadingBody = false;
            });
        }
    }

    handleTipoGrupoChange(event) {
        this.tipoGrupo = event.detail.value;
        this.showLoadingHeader = true
        this.showLoadingBody = true;
        refreshApex(this._wiredData).then(() => this.showLoadingBody = false);
        refreshApex(this._wireParentsResult).then(() => this.showLoadingHeader = false);
    }

    handleLoadParents(event) {
        const label = event.target.label;
        const name = event.target.name;
        event.preventDefault();
        if(label === '. . .') {
            this.parentStructure.forEach((e, i) => {
                e.forEach(e2 => {
                    if(e2.label === '. . .' && e2.id === name) {
                        this.positionToExpand = i;
                        this.parentStructureBackup = this.parentStructure;
                    }
                });
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: name,
                    objectApiName: 'Account',
                    actionName: 'view'
                }
            });
        }
    }

    get height() {
        let count = 0;
        if(this.record !== undefined && this.record !== null) {
            const grid = this.template.querySelector('lightning-tree-grid');
            if(grid !== undefined && grid !== null) {
                const expandeds = grid.getCurrentExpandedRows();
                this.record.forEach(client => {
                    count++;
                    expandeds.forEach(expanded => {
                        if(client.id === expanded) {
                            if(client._children !== undefined && client._children !== null) {
                                client._children.forEach(activity => {
                                    count++;
                                });
                            }
                        }
                    });
                });
            }
        }
        return (count <= 10) ? '' : 'height: 362px';
    }


    @wire(roleCib)
	getRoleCib({data, error}) {
        if(data) {
            this.cib = data;
		} else if(error) {
			console.log(error);
		}
    }

    connectedCallback() {
        loadStyle(this, LWC_DATATABLE_CSS);
    }
    
}