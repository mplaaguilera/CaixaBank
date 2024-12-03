import { LightningElement, api, wire, track } from 'lwc';

import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';

import getData from '@salesforce/apex/CIBE_GruposEconomicos_Controller.getData';
import getParentsData from '@salesforce/apex/CIBE_GruposEconomicos_Controller.getParentsData';

const options = [
    { label: 'Dominio',  value: '110' },
    { label: 'Restringido',  value: '120' },
    { label: 'Ampliado',  value: '130' }
];

export default class Cibe_GruposEconomicos extends NavigationMixin(LightningElement) {
    @api recordId;
    @track showLoadingHeader = false;
    @track showLoadingBody = false;
    @track record;

    @track hasParents = false;
    @track positionToExpand = 0;
    @track parentStructure = [];
    @track parentStructureBackup = [];
    @track parentStructureReversed = [];

    @track options = options;
    @track tipoGrupo = '120';

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
            label: 'Nombre Cliente'
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
            label: 'RAR Grupo',
            cellAttributes: {
                alignment: 'right'
            },
            initialWidth : 120
        },
        {
            type: 'text',
            fieldName: 'facturacion',
            label: 'Facturación (€)',
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'text',
            fieldName: 'activo',
            label: 'Financiación (€)',
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'text',
            fieldName: 'lexDisponible',
            label: 'Lex Disponible',
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'date',
            fieldName: 'lexFechaViegencia',
            label: 'Lex Fin de Vigencia',
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
            label: 'Ahorro e inversión (€)',
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
            label: 'EAP/Gestor'
        },
        {
            type: 'text',
            fieldName: 'source',
            label: 'Fuente',
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
            console.log(this.template.querySelector('lightning-tree-grid'));
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
    
}