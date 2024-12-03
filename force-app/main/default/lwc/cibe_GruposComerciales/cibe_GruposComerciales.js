import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getClients from '@salesforce/apex/CIBE_GruposComerciales_Controller.getClients';
import getEconomicGroupList from '@salesforce/apex/CIBE_GruposComerciales_Controller.getEconomicGroupList';
import getShadow from '@salesforce/apex/CIBE_GruposComerciales_Controller.getShadow';

import getEconomicInfo from '@salesforce/apex/CIBE_GruposComerciales_Controller.getEconomicInfo';
import getApplicationN from '@salesforce/apex/CIBE_AppUtilities.getAppDefinition';

//labels
import nombreCliente from '@salesforce/label/c.CIBE_NombreClienteT';
import rarGrupo from '@salesforce/label/c.CIBE_RARGrupo';
import rentabilidad from '@salesforce/label/c.CIBE_Rentabilidad';
import facturacion from '@salesforce/label/c.CIBE_Facturacion';
import financiacion from '@salesforce/label/c.CIBE_Financiacion';
import LEX from '@salesforce/label/c.CIBE_LEX';
import vencimientoLEX from '@salesforce/label/c.CIBE_VencimientoLEX';
import fuente from '@salesforce/label/c.CIBE_Fuente';
import rar from '@salesforce/label/c.CIBE_RAR';
import grupoEconomico from '@salesforce/label/c.CIBE_GrupoEconomico';
import verGrupos from '@salesforce/label/c.CIBE_VerGrupos';
import dominio from '@salesforce/label/c.CIBE_Dominio';
import restringido from '@salesforce/label/c.CIBE_Restringido';
import ampliado from '@salesforce/label/c.CIBE_Ampliado';
import tipoGE from '@salesforce/label/c.CIBE_TipoGrupoEconomico';
import seleccionaTipoGE from '@salesforce/label/c.CIBE_TipoGE';
import seleccionaGE from '@salesforce/label/c.CIBE_SelectGE';
import repreJerarquica from '@salesforce/label/c.CIBE_RepresentacionJerarquica';
import otrosClientes from '@salesforce/label/c.CIBE_OtrosClientes';
import gruposEconomicos from '@salesforce/label/c.CIBE_GruposEconomicos';
import cerrar from '@salesforce/label/c.CIBE_Cerrar';
import interlocutor from '@salesforce/label/c.CIBE_Interlocutor';




export default class Cibe_GruposComerciales extends LightningElement {

    labels = {
        nombreCliente,
        rarGrupo,
        rentabilidad,
        facturacion,
        financiacion,
        LEX,
        vencimientoLEX,
        fuente,
        rar,
        grupoEconomico,
        verGrupos,
        dominio,
        restringido,
        ampliado,
        tipoGE,
        seleccionaTipoGE,
        seleccionaGE,
        repreJerarquica,
        otrosClientes,
        gruposEconomicos,
        cerrar,
        interlocutor

    }

    economicGroupTypeOptions = [
        { label: this.labels.dominio, value: '110' },
        { label: this.labels.restringido, value: '120' },
        { label: this.labels.ampliado, value: '130' }
    ];

    @api recordId;
    @api isLoaded = false;

    @track matrix;
    @track clientIds;
    @track clients;

    @track groupType = '120';
    //@track economicGroupTypeOptions = economicGroupTypeOptions;

    @track group;
    @track economicGroupOptions;

    @track shadow;
    @track expanded;
    @track notShadowedClients;
    @track gridLoadingState = true;

    @track selected1 = [];
    @track selected2 = [];

    @track groups;
    @track isShowViewGroups = false;

    @track columns = [];
    @track application;

    @wire(getApplicationN, {})
    getApp({ error, data }) {
        if (data) {
            this.application = data;
            if (data == 'CIBE_MisClientesCIB') {
                this.columns = this.gridColumnsCIB;
            } else if (data == 'CIBE_MisClientesEMP' || data == 'SIR_misClientesSolutions' || data == 'SIRE_MisClientesSolucionesEMP') {
                this.columns = this.gridColumnsEMP;
            }
        } else if (error) {
            console.error('error', JSON.stringify(error));
        }
    }

    @wire(getClients, { recordId: '$recordId', application: '$application' })
    getClients({ error, data }) {
        if (data) {
            this.matrix = data.matrix;
            this.clientIds = data.clientIds;
            this.clients = data.clients;
        } else if (error) {
            this.gridLoadingState = false;
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                }));
        }
    }

    @wire(getEconomicGroupList, { recordId: '$matrix', groupType: '$groupType' })
    getEconomicGroupList({ error, data }) {
        if (data) {
            this.economicGroupOptions = data;
            if (this.economicGroupOptions.length > 0) {
                this.group = data[0].value;
            }
        } else if (error) {
            this.gridLoadingState = false;
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                }));
        }
    }

    @wire(getShadow, { recordId: '$group', groupType: '$groupType', clientIds: '$clientIds', application: '$application', clients: '$clients' })
    getShadow({ error, data }) {
        if (data) {
            this.expanded = data.clientIds;
            let tree = JSON.parse(JSON.stringify(data.clients));
            this.tree(tree);
            this.shadow = tree;
            const notShadowedClients = [...this.clients];
            this.unShadow(this.shadow, notShadowedClients);
            this.notShadowedClients = notShadowedClients;

            if (this.gridLoadingState) {
                this.throwRefreshEvent(this.clientIds);
                this.gridLoadingState = false;
            }
        } else if (error) {
            console.log(error);

            if (this.gridLoadingState) {
                this.throwRefreshEvent(this.clientIds);
                this.gridLoadingState = false;
            }
        }
    }

    tree(objs) {
        objs.map(e => {
            if (e['children']) {
                e._children = e['children'];
                this.tree(e._children);
            }
        });
    }

    unShadow(shadow, notShadowedClients) {
        shadow.forEach(e => {
            if (!e.isGrupo) {
                var index = -1;
                notShadowedClients.forEach((e2, i) => {
                    if (e2.id === e.id) {
                        index = i;
                    }
                });

                if (index != -1) {
                    notShadowedClients.splice(index, 1);
                }
            } else if (e.isGrupo) {
                this.unShadow(e._children, notShadowedClients);
            }
        });
    }

    handleGroupType(event) {
        this.groupType = event.detail.value;
    }

    handleGroup(event) {
        this.group = event.detail.value;
    }

    get hasData() {
        return this.shadow != null && this.shadow.length > 0;
    }

    get hasShadows() {
        return this.notShadowedClients != null && this.notShadowedClients.length > 0;
    }

    refreshRelated1(event) {
        this.selected1 = [];
        event.detail.selectedRows.forEach(e => {
            if (!e.isGrupo) {
                if (!this.selected1.includes(e.id) && !this.selected2.includes(e.id)) {
                    this.selected1.push(e.id);
                }
            }
        });

        const selected = this.selected1.concat(this.selected2);
        if (!(selected.length > 0)) {
            this.throwRefreshEvent(this.clientIds);
        }

        if (selected.length > 0) {
            this.throwRefreshEvent(selected);
        }
    }

    refreshRelated2(event) {
        this.selected2 = [];
        event.detail.selectedRows.forEach(e => {
            if (!e.isGrupo) {
                if (!this.selected1.includes(e.id) && !this.selected2.includes(e.id)) {
                    this.selected2.push(e.id);
                }
            }
        });

        const selected = this.selected1.concat(this.selected2);
        if (!(selected.length > 0)) {
            this.throwRefreshEvent(this.clientIds);
        }

        if (selected.length > 0) {
            this.throwRefreshEvent(selected);
        }
    }

    throwRefreshEvent(accountIds) {
        this.dispatchEvent(
            new CustomEvent('refreshrelated', {
                detail: accountIds
            }));
    }

    showViewGroups(event) {
        getEconomicInfo({ recordId: event.detail.row.id })
            .then(result => {
                if (result != null) {
                    this.groups = result;
                }
            }).finally(() => {
                this.isShowViewGroups = true;
            });

    }

    hideViewGroups(event) {
        this.isShowViewGroups = false;
    }

    gridColumnsEMP = [
        {
            type: 'url',
            typeAttributes: {
                label: {
                    fieldName: "accountName"
                },
                target: '_self'
            },
            fieldName: 'showRecord',
            actions: false,
            label: this.labels.nombreCliente,
            initialWidth: 300
        },
        {
            type: 'text',
            hideDefaultActions: true,
            typeAttributes: {
                label: {
                    fieldName: "interlocutor"
                },
                target: '_self'
            },
            fieldName: 'rol',
            label: this.labels.interlocutor
        },
        {
            type: 'text',
            hideDefaultActions: true,
            fieldName: 'rar',
            label: this.labels.rar,
            cellAttributes: {
                alignment: 'right'
            },
            initialWidth: 80
        },
        {
            type: 'text',
            hideDefaultActions: true,
            fieldName: 'rarGrupo',
            label: this.labels.rarGrupo,
            cellAttributes: {
                alignment: 'right'
            },
            initialWidth: 120
        },
        {
            type: 'text',
            hideDefaultActions: true,
            fieldName: 'rentabilidad',
            label: this.labels.rentabilidad,
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'text',
            hideDefaultActions: true,
            fieldName: 'facturacion',
            label: this.labels.facturacion,
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'text',
            hideDefaultActions: true,
            fieldName: 'activo',
            label: this.labels.financiacion,
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'text',
            hideDefaultActions: true,
            fieldName: 'lexDisponible',
            label: this.labels.LEX,
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'date',
            hideDefaultActions: true,
            fieldName: 'lexFechaVigencia',
            label: this.labels.vencimientoLEX,
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
            hideDefaultActions: true,
            fieldName: 'source',
            label: this.labels.fuente,
            cellAttributes: {
                alignment: 'center'
            },
            wrapText: true
        },
        {
            label: this.labels.grupoEconomico,
            type: "button",
            hideDefaultActions: true,
            typeAttributes: {
                label: this.labels.verGrupos,
                name: 'gruposEconomico',
                title: 'Grupos Economico'
            },
            cellAttributes: {
                alignment: 'left'
            },
            initialWidth: 140
        }
    ];

    gridColumnsCIB = [
        {
            type: 'url',
            hideDefaultActions: true,
            typeAttributes: {
                label: {
                    fieldName: "accountName"
                },
                target: '_self'
            },
            fieldName: 'showRecord',
            label: this.labels.nombreCliente,
            cellAttributes: {
                iconName: {
                    fieldName: 'bookIcon'
                }
            },
            initialWidth: 300
        },
        {
            type: 'text',
            hideDefaultActions: true,
            fieldName: 'rar',
            label: this.labels.rar,
            cellAttributes: {
                alignment: 'right'
            },
            initialWidth: 80
        },
        {
            type: 'text',
            hideDefaultActions: true,
            fieldName: 'rarGrupo',
            label: this.labels.rarGrupo,
            cellAttributes: {
                alignment: 'right'
            },
            initialWidth: 120
        },
        {
            type: 'text',
            hideDefaultActions: true,
            fieldName: 'rentabilidad',
            label: this.labels.rentabilidad,
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'text',
            hideDefaultActions: true,
            fieldName: 'facturacion',
            label: this.labels.facturacion,
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'text',
            hideDefaultActions: true,
            fieldName: 'activo',
            label: this.labels.financiacion,
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'text',
            hideDefaultActions: true,
            fieldName: 'lexDisponible',
            label: this.labels.LEX,
            cellAttributes: {
                alignment: 'right'
            }
        },
        {
            type: 'date',
            hideDefaultActions: true,
            fieldName: 'lexFechaVigencia',
            label: this.labels.vencimientoLEX,
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
            hideDefaultActions: true,
            fieldName: 'source',
            label: this.labels.fuente,
            cellAttributes: {
                alignment: 'center'
            },
            wrapText: true
        },
        {
            label: this.labels.grupoEconomico,
            type: "button",
            hideDefaultActions: true,
            typeAttributes: {
                label: this.labels.verGrupos,
                name: 'gruposEconomico',
                title: 'Grupos Economico'
            },
            cellAttributes: {
                alignment: 'left'
            },
            initialWidth: 140
        }
    ];

    @track height1 = '';
    @track height2 = '';

    renderedCallback() {
        this.height1 = this.getHeight1();
        this.height2 = this.getHeight2();
    }

    getHeight1() {
        let count = 0;
        if (this.shadow !== undefined && this.shadow !== null) {
            const grid = this.template.querySelector('[data-gc="GC1"');
            if (grid !== undefined && grid !== null) {
                const expandeds = grid.getCurrentExpandedRows();
                this.shadow.forEach(client => {
                    count++;
                    expandeds.forEach(expanded => {
                        if (client.id === expanded) {
                            if (client._children !== undefined && client._children !== null) {
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

    getHeight2() {
        let count = 0;
        if (this.notShadowedClients !== undefined && this.notShadowedClients !== null) {
            const grid = this.template.querySelector('[data-gc="GC2"');
            if (grid !== undefined && grid !== null) {
                const expandeds = grid.getCurrentExpandedRows();
                this.notShadowedClients.forEach(client => {
                    count++;
                    expandeds.forEach(expanded => {
                        if (client.id === expanded) {
                            if (client._children !== undefined && client._children !== null) {
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