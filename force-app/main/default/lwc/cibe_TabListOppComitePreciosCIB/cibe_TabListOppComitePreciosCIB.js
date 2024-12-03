import { LightningElement, wire, track, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getOpportunity from '@salesforce/apex/CIBE_TabListOppComitePreciosCIBContr.getOpportunity';
import exportOpportunities from '@salesforce/apex/CIBE_TabListOppComitePreciosCIBContr.exportOpportunities';
import getPicklistValuesHier from '@salesforce/apex/CIBE_MassReassignOwner_Controller.picklistValues';
import getPicklistValuesDepen from '@salesforce/apex/CIBE_MassReassignOwner_Controller.picklistValuesDependency';
import getTipoAprobacion from '@salesforce/apex/CIBE_TabListOppComitePreciosCIBContr.getTipoAprobacion';
import getSector from '@salesforce/apex/CIBE_TabListOppComitePreciosCIBContr.getSector';
import getCartera from '@salesforce/apex/CIBE_TabListOppComitePreciosCIBContr.getCartera';
import getOptionsHierarchy from '@salesforce/apex/CIBE_TabListOppComitePreciosCIBContr.getOptionsHierarchy';
import updateCreditoPortfolio from '@salesforce/apex/CIBE_OpportunityComite.updateCreditoPortfolio';
import updateEquipoSindicaciones from '@salesforce/apex/CIBE_OpportunityComite.updateEquipoSindicaciones';
import updateALM from '@salesforce/apex/CIBE_OpportunityComite.updateALM';
import getDocumentOpp from '@salesforce/apex/CIBE_TabListOppComitePreciosCIBContr.getDocumentOpp';


import LWC_DATATABLE_CSS from '@salesforce/resourceUrl/CIBE_ComitePreciosIcon'
import { loadStyle } from 'lightning/platformResourceLoader';


//Fields
import opportunity_Object from '@salesforce/schema/Opportunity';
import vigenciOferta_FIELD from '@salesforce/schema/Opportunity.CIBE_VigenciaOferta__c';


//Labels
import cliente from '@salesforce/label/c.CIBE_Cliente';
import numeroDocumento from '@salesforce/label/c.CIBE_NumeroDocumento';
import grupoComercial from '@salesforce/label/c.CIBE_GrupoComercial';
import gruposEconomico from '@salesforce/label/c.CIBE_GrupoEconomico';
import name from '@salesforce/label/c.CIBE_Name';
import producto from '@salesforce/label/c.CIBE_Producto';
import importe from '@salesforce/label/c.CIBE_Importe';
import divisa from '@salesforce/label/c.CIBE_Divisa';
import impactoBalance from '@salesforce/label/c.CIBE_ImpactoBalance';
import impactoComisiones from '@salesforce/label/c.CIBE_ImpactoComisiones';
import tipoOperacion from '@salesforce/label/c.CIBE_TipoOperacion';
import fechaCierre from '@salesforce/label/c.CIBE_FechaCierre';
import owner from '@salesforce/label/c.CIBE_Owner';
import ecas from '@salesforce/label/c.CIBE_ECAs';
import algunaOperacionRAR from '@salesforce/label/c.CIBE_AlgunaOper';
import dictamenALM from '@salesforce/label/c.CIBE_DictamenALM';
import analystReview from '@salesforce/label/c.CIBE_RevisionCPAnalysis';
import nivel from '@salesforce/label/c.CIBE_Nivel';
import sindicaciones from '@salesforce/label/c.CIBE_Sindicaciones';
import sindicacionesTeam from '@salesforce/label/c.CIBE_SindicacionesEquipo';
import observaciones from '@salesforce/label/c.CIBE_Observaciones';
import vigenciaOferta from '@salesforce/label/c.CIBE_VigenciaOferta';
import fechaComitePrecios from '@salesforce/label/c.CIBE_FechaComitePrecios';
import comitePrecio from '@salesforce/label/c.CIBE_ComitePrecio';
import reiniciar from '@salesforce/label/c.CIBE_Reiniciar';
import exportar from '@salesforce/label/c.CIBE_Exportar';
import fechaAprobacionPrecio from '@salesforce/label/c.CIBE_FechaAprobacionPrecio';
import fechaAprobacionPrecioDesde from '@salesforce/label/c.CIBE_FechaAprobacionPrecioDesde';
import fechaAprobacionPrecioHasta from '@salesforce/label/c.CIBE_FechaAprobacionPrecioHasta';
import anterior from '@salesforce/label/c.CIBE_Anterior';
import posterior from '@salesforce/label/c.CIBE_Posterior';
import oportunidades from '@salesforce/label/c.CIBE_Oportunidades';
import select from '@salesforce/label/c.CIBE_SeleccionaOpcion';
import confidencial from '@salesforce/label/c.CIBE_Confidencial';
import linea from '@salesforce/label/c.CIBE_Linea';
import pais from '@salesforce/label/c.CIBE_Pais';
import rating from '@salesforce/label/c.CIBE_Rating';
import RARSeveridad from '@salesforce/label/c.CIBE_RARSeveridad';
import RARPlazoVidaMediaAños from '@salesforce/label/c.CIBE_RARPlazoYears';
import RARIndiceReferencia from '@salesforce/label/c.CIBE_RARIndiceReferencia';
import RARInteresDiferencial from '@salesforce/label/c.CIBE_RARInteresDiferencial';
import RARPlazoVidaMediaFecha from '@salesforce/label/c.CIBE_RARPlazoVidaMediaFecha';
import RARPost from '@salesforce/label/c.CIBE_RARPost';
import comisionSaldoMedio from '@salesforce/label/c.CIBE_comisionSaldoMedio';
import RARComisionApertura from '@salesforce/label/c.CIBE_RARComisionApertura';
import RARGarantias from '@salesforce/label/c.CIBE_RARGarantias';
import impactoDivisaComisionesCierreAnio from '@salesforce/label/c.CIBE_impactoDivisaComisionesCierreAnio';
import impactoComisionesCierreAnio from '@salesforce/label/c.CIBE_impactoComisionesCierreAnio';
import RARConjunto from '@salesforce/label/c.CIBE_RAROperaciones';
import RAROperacionRar from '@salesforce/label/c.CIBE_RAR';
import VAOperacion from '@salesforce/label/c.CIBE_VAOperacion';
import RARMargenDiario from '@salesforce/label/c.CIBE_RARMargenDiario';
import RARComision12meses from '@salesforce/label/c.CIBE_RARComision12ultMeses';
import selecciona from '@salesforce/label/c.CIBE_SeleccionaOpcion';
import negociosLab from '@salesforce/label/c.CIBE_Negocio';
import redesLab from '@salesforce/label/c.CIBE_RedeSeg';
import sectoresLab from '@salesforce/label/c.CIBE_SectorPais';
import centroLab from '@salesforce/label/c.CIBE_CentroCartera';
import importeHasta from '@salesforce/label/c.CIBE_ImporteHasta';
import importeDesde from '@salesforce/label/c.CIBE_ImporteDesde';
import importeEuros from '@salesforce/label/c.CIBE_ImporteEuros';
import segmentoRentabilidadEA from '@salesforce/label/c.CIBE_SegmentoRentabilidadEA';
import segmentoRentabilidadER from '@salesforce/label/c.CIBE_SegmentoRentabilidadER';
import segmentoRentabilidadGA from '@salesforce/label/c.CIBE_SegmentoRentabilidadGA';
import segmentoRentabilidadGR from '@salesforce/label/c.CIBE_SegmentoRentabilidadGR';
import observacionesPrecio from '@salesforce/label/c.CIBE_ObservacionesPrecio';
import gestor from '@salesforce/label/c.CIBE_Gestor';
import equipoAnalistas from '@salesforce/label/c.CIBE_EquipoAnalistas';
import equipoRelacionados from '@salesforce/label/c.CIBE_EquiposRelacionados';
import comite from '@salesforce/label/c.CIBE_Comite';
import cancelar from '@salesforce/label/c.CIBE_Cancelar';
import calculadora from '@salesforce/label/c.CIBE_CalculadoraPrecios';
import sector from '@salesforce/label/c.CIBE_Sector';
import cartera from '@salesforce/label/c.CIBE_Cartera';
import tipoAprobacion from '@salesforce/label/c.CIBE_TipoAprobacion';
import importeRenovacion from '@salesforce/label/c.CIBE_ImporteRenovacion';
import importeVariacion from '@salesforce/label/c.CIBE_ImporteVariacion';
import updateOppKo from '@salesforce/label/c.CIBE_ErrorActualizandoOpp';
import creditoPortfolioError from '@salesforce/label/c.CIBE_CreditPortfolioError';
import syndicationTeamError from '@salesforce/label/c.CIBE_SyndicationTeamError';
import almTeam from '@salesforce/label/c.CIBE_ALMTeam';
import nameSimple from '@salesforce/label/c.CIBE_NombreSimple';
import createdDate from '@salesforce/label/c.CIBE_DocuFechaCreacion';
import documentos from '@salesforce/label/c.CIBE_Documentos';



export default class cibe_TabListOppComitePreciosCIB extends LightningElement {

    label = {
        comitePrecio,
        reiniciar,
        exportar,
        fechaAprobacionPrecio,
        fechaAprobacionPrecioDesde,
        fechaAprobacionPrecioHasta,
        anterior,
        posterior,
        oportunidades,
        select,
        confidencial,
        linea,
        fechaComitePrecios,
        owner,
        pais,
        gruposEconomico,
        grupoComercial,
        name,
        rating,
        RARSeveridad,
        RARPlazoVidaMediaAños,
        tipoOperacion,
        producto,
        RARIndiceReferencia,
        RARInteresDiferencial,
        RARPlazoVidaMediaFecha,
        RARConjunto,
        RAROperacionRar,
        RARPost,
        comisionSaldoMedio,
        RARComisionApertura,
        RARGarantias,
        VAOperacion,
        RARMargenDiario,
        RARComision12meses,
        fechaCierre,
        impactoBalance,
        impactoDivisaComisionesCierreAnio,
        impactoComisiones,
        impactoComisionesCierreAnio,
        ecas,
        algunaOperacionRAR,
        vigenciaOferta,
        dictamenALM,
        nivel,
        analystReview,
        sindicaciones,
        sindicacionesTeam,
        observaciones,
        selecciona,
        centroLab,
        sectoresLab,
        redesLab,
        negociosLab,
        importeHasta,
        importeDesde,
        importeEuros,
        segmentoRentabilidadEA,
        segmentoRentabilidadER,
        segmentoRentabilidadGA,
        segmentoRentabilidadGR,
        observacionesPrecio,
        gestor,
        equipoAnalistas,
        equipoRelacionados,
        comite,
        cancelar,
        calculadora,
        sector,
        cartera,
        tipoAprobacion,
        importeRenovacion,
        importeVariacion,
        updateOppKo,
        creditoPortfolioError,
        syndicationTeamError,
        almTeam,
        nameSimple,
        createdDate,
        documentos
    }

    @api recordId;
    @track oppVigencia = [];
    @track oppHierarchy = [];
    @track pickListOptions;
    @track picklistHierarchy;
    ecas;
    @track isLoading = true;
    errors;
    @track values = [];

    @track data;
    @track items = [];
    @track totalPage = 0;
    @track totalRecountCount = 0;
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize = 10;
    @track page = 1;
    @track rowOffset = 0;
    @track altura;
    @track plazoAnios;


    sortedBy;
    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';

    @track offSet = 0;
    @track offSetUpdate = 0;

    @track fecha = null;
    @track fechaDesde = null;
    @track fechaHasta = null;
    @track exportDisabled = false;
    @track importeDesde = null;
    @track importeHasta = null;

    //Jerarquia
    @track picklistValues = null;
    @track picklistValues2 = null;
    @track picklistValues3 = null;
    @track picklistValues4 = null;
    @track negocios = '';
    @track redesSegmentos = '';
    @track sectoresPaises = '';
    @track centrosCarteras = '';
    @api inputObj = 'Contact';

    //Precarga valores campos
    @track placeHol = select;

    @track isShowModal = false;

    //campos comite
    @track idOpp;
    @track isLoadingComite = false;


    @track optionsTipoAprobacion = [];
    @track valueTipoAprobacion = null;

    @track optionsSector = [];
    @track valueSector = null;


    @track optionsCartera = [];
    @track valueCartera = null;

    @track picklist = 'Redes-Segmentos';
    @track name = 'Corporate Banking España';
    @track picklistCartera = 'Sectores-Paises';


    @track creditNeg = 'CIB Solutions';
    @track creditRed = 'Credit Portfolio Analysis';

    @track sindNeg = 'Structured Finance';
    @track sindRed = 'Loan Syndicate & Sales';
    @track almRed = 'ALM';

    @track isShowModalFile = false;
    @track documents;
    @track hasDocuments = false;


    columnHeader = [gestor, cliente, segmentoRentabilidadEA, segmentoRentabilidadER, segmentoRentabilidadGA, segmentoRentabilidadGR, confidencial, gruposEconomico, rating, name, producto, importeEuros, RARPlazoVidaMediaAños, RARGarantias, tipoOperacion,
        RARMargenDiario, RARInteresDiferencial, RARComisionApertura, comisionSaldoMedio, RARConjunto, RAROperacionRar, observaciones, observacionesPrecio, RARPost, nivel,
        analystReview, dictamenALM, sindicaciones, sindicacionesTeam, ecas, algunaOperacionRAR, vigenciaOferta, pais, RARIndiceReferencia, fechaCierre, impactoBalance,
        impactoDivisaComisionesCierreAnio, impactoComisiones, impactoComisionesCierreAnio, grupoComercial, numeroDocumento,
        fechaComitePrecios, VAOperacion, RARComision12meses, linea, RARSeveridad, importe, divisa, importeRenovacion, importeVariacion, owner];

    @track minDate = new Date();
    @track todayDate = new Date();

    @wire(getObjectInfo, { objectApiName: opportunity_Object })
    opportunityObjectMetadata;

    //fetch picklist options
    @wire(getPicklistValues, { recordTypeId: "$opportunityObjectMetadata.data.defaultRecordTypeId", fieldApiName: vigenciOferta_FIELD })
    wirePickList({ error, data }) {
        if (data) {
            this.oppVigencia = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValuesHier, { inputField: 'Negocios', inputObj: 'Contact' })
    wiredPicklist({ data, error }) {
        if (data) {
            this.picklistValues1 = data;
        } else if (error) {
            this.picklistValues1 = undefined;
            console.log(error);
        }
    }

    @wire(getTipoAprobacion)
    wiredValues({ error, data }) {
        if (data) {
            this.optionsTipoAprobacion = data;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getOptionsHierarchy)
    wiredPicklisHierarchy({ error, data }) {
        if (data) {
            this.oppHierarchy = data;
        } else if (error) {
            console.log(error);
        }
    }


    @wire(getSector, { picklist: '$picklist', name: '$name' })
    wiredSector({ error, data }) {
        if (data) {
            this.optionsSector = data;
        } else if (error) {
            console.log(error);
        }
    }

    @track _wiredData;
    @wire(getOpportunity, { offSet: '$offSet', fecha: '$fecha', desde: '$fechaDesde', hasta: '$fechaHasta', negocios: '$negocios', redesSegmentos: '$redesSegmentos', sectoresPaises: '$sectoresPaises', centrosCarteras: '$centrosCarteras', importeDesde: '$importeDesde', importeHasta: '$importeHasta', tipoAprobacion: '$valueTipoAprobacion', sector: '$valueSector', cartera: '$valueCartera' })
    wiredOpportunity(wiredData) {
        this._wiredData = wiredData;
        const { data, error } = wiredData;
        this.totalPage = 1;
        if (data) {
            var options = [];
            var options2 = [];
            for (var key in this.oppVigencia) {
                options.push({ label: this.oppVigencia[key].label, value: this.oppVigencia[key].value })
            }

            if(this.oppHierarchy != null){
                for (var key in this.oppHierarchy) {
                    options2.push({ label: this.oppHierarchy[key].label, value: this.oppHierarchy[key].value })
                }
            }

            this.data = data.map((item) => {
                const iconObj = { ...item };
                iconObj.pickListOptions = options;
                iconObj.picklistHierarchy = options2;
                //empresa absoluta    
                if (item.empresaAbsoluta === 'Alta' || item.empresaAbsoluta === 'High') {
                    iconObj.priorityiconEA = "utility:record";
                    iconObj.valorSemaforoEA = item.empresaAbsoluta;
                    iconObj.classEstadoEA = 'classAlta'
                } else if (item.empresaAbsoluta === 'Media Alta' || item.empresaAbsoluta === 'Medium High') {
                    iconObj.priorityiconEA = "utility:record";
                    iconObj.classEstadoEA = 'classMediaAlta';
                    iconObj.valorSemaforoEA = item.empresaAbsoluta;
                } else if (item.empresaAbsoluta === 'Media' || item.empresaAbsoluta === 'Medium') {
                    iconObj.priorityiconEA = "utility:record";
                    iconObj.classEstadoEA = 'classMedia';
                    iconObj.valorSemaforoEA = item.empresaAbsoluta;
                } else if (item.empresaAbsoluta === 'Media Baja' || item.empresaAbsoluta === 'Medium Low') {
                    iconObj.priorityiconEA = "utility:record";
                    iconObj.classEstadoEA = 'classMediaBaja';
                    iconObj.valorSemaforoEA = item.empresaAbsoluta;
                } else if (item.empresaAbsoluta === 'Baja' || item.empresaAbsoluta === 'Low') {
                    iconObj.priorityiconEA = "utility:record";
                    iconObj.classEstadoEA = 'classBaja';
                    iconObj.valorSemaforoEA = item.empresaAbsoluta;
                } else if (item.empresaAbsoluta === 'Morosos' || item.empresaAbsoluta === 'Default') {
                    iconObj.priorityiconEA = "utility:record";
                    iconObj.classEstadoEA = 'classMorosos';
                    iconObj.valorSemaforoEA = item.empresaAbsoluta;
                } else if (item.empresaAbsoluta === 'Inactivos' || item.empresaAbsoluta === 'Inactive') {
                    iconObj.priorityiconEA = "utility:record";
                    iconObj.classEstadoEA = 'classInactivos';
                    iconObj.valorSemaforoEA = item.empresaAbsoluta;
                }else if (item.empresaAbsoluta === 'Project Finance') {
                    iconObj.priorityiconEA = "utility:record";
                    iconObj.classEstadoEA = 'classProjectFinance';
                    iconObj.valorSemaforoEA = item.empresaAbsoluta;
                }

                //empresa relativa

                if (item.empresaRelativa === 'Alta' || item.empresaRelativa === 'High') {
                    iconObj.priorityiconER = "utility:record";
                    iconObj.classEstadoER = 'classAlta';
                    iconObj.valorSemaforoER = item.empresaRelativa;
                } else if (item.empresaRelativa === 'Media Alta' || item.empresaRelativa === 'Medium High') {
                    iconObj.priorityiconER = "utility:record";
                    iconObj.classEstadoER = 'classMediaAlta';
                    iconObj.valorSemaforoER = item.empresaRelativa;
                } else if (item.empresaRelativa === 'Media' || item.empresaRelativa === 'Medium') {
                    iconObj.priorityiconER = "utility:record";
                    iconObj.classEstadoER = 'classMedia';
                    iconObj.valorSemaforoER = item.empresaRelativa;
                } else if (item.empresaRelativa === 'Media Baja' || item.empresaRelativa === 'Medium Low') {
                    iconObj.priorityiconER = "utility:record";
                    iconObj.classEstadoER = 'classMediaBaja';
                    iconObj.valorSemaforoER = item.empresaRelativa;
                } else if (item.empresaRelativa === 'Baja' || item.empresaRelativa === 'Low') {
                    iconObj.priorityiconER = "utility:record";
                    iconObj.classEstadoER = 'classBaja';
                    iconObj.valorSemaforoER = item.empresaRelativa;
                } else if (item.empresaRelativa === 'Morosos' || item.empresaRelativa === 'Default') {
                    iconObj.priorityiconER = "utility:record";
                    iconObj.classEstadoER = 'classMorosos';
                    iconObj.valorSemaforoER = item.empresaRelativa;
                } else if (item.empresaRelativa === 'Inactivos' || item.empresaRelativa === 'Inactive') {
                    iconObj.priorityiconER = "utility:record";
                    iconObj.classEstadoER = 'classInactivos';
                    iconObj.valorSemaforoER = item.empresaRelativa;
                }else if (item.empresaRelativa === 'Project Finance') {
                    iconObj.priorityiconER = "utility:record";
                    iconObj.classEstadoER = 'classProjectFinance';
                    iconObj.valorSemaforoER = item.empresaRelativa;
                }

                //grupo absoluta
                if (item.grupoAbsoluta === 'Alta' || item.grupoAbsoluta === 'High') {
                    iconObj.priorityiconGA = "utility:record";
                    iconObj.classEstadoGA = 'classAlta';
                    iconObj.valorSemaforoGA = item.grupoAbsoluta;
                } else if (item.grupoAbsoluta === 'Media Alta' || item.grupoAbsoluta === 'Medium High') {
                    iconObj.priorityiconGA = "utility:record";
                    iconObj.classEstadoGA = 'classMediaAlta';
                    iconObj.valorSemaforoGA = item.grupoAbsoluta;
                } else if (item.grupoAbsoluta === 'Media' || item.grupoAbsoluta === 'Medium') {
                    iconObj.priorityiconGA = "utility:record";
                    iconObj.classEstadoGA = 'classMedia';
                    iconObj.valorSemaforoGA = item.grupoAbsoluta;
                } else if (item.grupoAbsoluta === 'Media Baja' || item.grupoAbsoluta === 'Medium Low') {
                    iconObj.priorityiconGA = "utility:record";
                    iconObj.classEstadoGA = 'classMediaBaja';
                    iconObj.valorSemaforoGA = item.grupoAbsoluta;
                } else if (item.grupoAbsoluta === 'Baja' || item.grupoAbsoluta === 'Low') {
                    iconObj.priorityiconGA = "utility:record";
                    iconObj.classEstadoGA = 'classBaja';
                    iconObj.valorSemaforoGA = item.grupoAbsoluta;
                } else if (item.grupoAbsoluta === 'Morosos' || item.grupoAbsoluta === 'Default') {
                    iconObj.priorityiconGA = "utility:record";
                    iconObj.classEstadoGA = 'classMorosos';
                    iconObj.valorSemaforoGA = item.grupoAbsoluta;
                } else if (item.grupoAbsoluta === 'Inactivos' || item.grupoAbsoluta === 'Inactive') {
                    iconObj.priorityiconGA = "utility:record";
                    iconObj.classEstadoGA = 'classInactivos';
                    iconObj.valorSemaforoGA = item.grupoAbsoluta;
                }else if (item.grupoAbsoluta === 'Project Finance') {
                    iconObj.priorityiconGA = "utility:record";
                    iconObj.classEstadoGA = 'classProjectFinance';
                    iconObj.valorSemaforoGA = item.grupoAbsoluta;
                }

                //grupo relativa
                if (item.grupoRelativa === 'Alta' || item.grupoRelativa === 'High') {
                    iconObj.priorityiconGR = "utility:record";
                    iconObj.classEstadoGR = 'classAlta';
                    iconObj.valorSemaforoGR = item.grupoRelativa;
                } else if (item.grupoRelativa === 'Media Alta' || item.grupoRelativa === 'Medium High') {
                    iconObj.priorityiconGR = "utility:record";
                    iconObj.classEstadoGR = 'classMediaAlta';
                    iconObj.valorSemaforoGR = item.grupoRelativa;
                } else if (item.grupoRelativa === 'Media' || item.grupoRelativa === 'Medium') {
                    iconObj.priorityiconGR = "utility:record";
                    iconObj.classEstadoGR = 'classMedia';
                    iconObj.valorSemaforoGR = item.grupoRelativa;
                } else if (item.grupoRelativa === 'Media Baja' || item.grupoRelativa === 'Medium Low') {
                    iconObj.priorityiconGR = "utility:record";
                    iconObj.classEstadoGR = 'classMediaBaja';
                    iconObj.valorSemaforoGR = item.grupoRelativa;
                } else if (item.grupoRelativa === 'Baja' || item.grupoRelativa === 'Low') {
                    iconObj.priorityiconGR = "utility:record";
                    iconObj.classEstadoGR = 'classBaja';
                    iconObj.valorSemaforoGR = item.grupoRelativa;
                } else if (item.grupoRelativa === 'Morosos' || item.grupoRelativa === 'Default') {
                    iconObj.priorityiconGR = "utility:record";
                    iconObj.classEstadoGR = 'classMorosos';
                    iconObj.valorSemaforoGR = item.grupoRelativa;
                } else if (item.grupoRelativa === 'Inactivos' || item.grupoRelativa === 'Inactive') {
                    iconObj.priorityiconGR = "utility:record";
                    iconObj.classEstadoGR = 'classInactivos';
                    iconObj.valorSemaforoGR = item.grupoRelativa;
                }else if (item.grupoRelativa === 'Project Finance') {
                    iconObj.priorityiconGR = "utility:record";
                    iconObj.classEstadoGR = 'classProjectFinance';
                    iconObj.valorSemaforoGR = item.grupoRelativa;
                }

                return iconObj;

            });
            if (this.data[0] != undefined && this.data[0].nOpps != null) {
                this.totalPage = Math.ceil(this.data[0].nOpps / 10);
            }
            if (this.offSet === this.offSetUpdate) {
                this.page = 1;
                this.rowOffset = 0;
            }

            this.isLoading = false;
        } else if (error) {
            this.isLoading = false;
            console.log(error);
        } else {
            this.isLoading = false;
            this.totalPage = 1;
        }

    }

    connectedCallback() {
        loadStyle(this, LWC_DATATABLE_CSS);
        const selectedEvent = new CustomEvent("renametab");
        this.dispatchEvent(selectedEvent);
    }

    get height() {
        if (this.altura != undefined && this.altura != null && this.altura != '') {
            return this.data !== null && this.data !== undefined && this.data.length >= 10 ? this.altura : '';
        } else {
            if (this.data != null && this.data.length != null) {
                this.altura = this.data.length * 42;
            }
            return this.data !== null && this.data !== undefined && this.data.length >= 10 ? 'height: ' + this.altura + 'px' : '';
        }
    }

    get disabledDate() {
        return this.fecha !== null;
    }

    get disabledDates() {
        return this.fechaDesde !== null || this.fechaHasta !== null;
    }

    get validateDate() {
        return (this.minDate.getFullYear() - 2) + '-' + (this.minDate.getMonth()) + '-' + this.minDate.getDate();
    }

    get getHasPrevius() {
        return this.offSet <= 0;
    }

    get getHasNext() {
        return (this.offSet >= 1000 || (this.data !== null && this.data !== undefined && this.data.length < 10));
    }

    handleChangeDate(event) {
        this.isLoading = true;
        this.offSet = 0;
        this.fecha = event.target.value;
    }

    handleChangeDateDesde(event) {
        this.isLoading = true;
        this.offSet = 0;
        this.fechaDesde = event.target.value;
    }

    handleChangeDateHasta(event) {
        this.isLoading = true;
        this.offSet = 0;
        this.fechaHasta = event.target.value;
    }

    handleChangeImporteDesde(event) {
        this.isLoading = true;
        this.offSet = 0;
        this.importeDesde = event.target.value;
    }

    handleChangeImporteHasta(event) {
        this.isLoading = true;
        this.offSet = 0;
        this.importeHasta = event.target.value;
    }

    handleChangeTipoAprobacion(event) {
        this.isLoading = true;
        this.offSet = 0;
        this.valueTipoAprobacion = event.target.value;
    }

    handleChangeSector(event) {
        this.data = null;
        this.valueSector = event.detail.value;
        this.getCarteras();
    }

    handleChangeCartera(event) {
        this.data = null;
        this.valueCartera = event.detail.value;
    }

    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.values];
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
        if (draftValueChanged) {
            this.values = [...copyDraftValues];
        } else {
            this.values = [...copyDraftValues, updateItem];
        }
    }

    exportData() {
        this.exportDisabled = true;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Exportacion',
                message: 'Su excel se está preparando para ser descargado.',
                variant: 'info',
                mode: 'sticky'
            }));

        exportOpportunities({ fecha: this.fecha, desde: this.fechaDesde, hasta: this.fechaHasta, negocios: this.negocios, redesSegmentos: this.redesSegmentos, sectoresPaises: this.sectoresPaises, centrosCarteras: this.centrosCarteras, importeDesde: this.importeDesde, importeHasta: this.importeHasta, tipoAprobacion: this.valueTipoAprobacion, sector: this.valueSector, cartera: this.valueCartera })
            .then(data => {
                let doc = '';
                this.columnHeader.forEach(element => {
                    doc += element + ';';
                });
                doc += '\n';
                doc += data.join('');
                let downloadElement = document.createElement('a');
                downloadElement.href = 'data:application/csv;charset=utf-8,%EF%BB%BF' + encodeURIComponent(doc);
                downloadElement.target = '_self';
                downloadElement.download = this.label.comitePrecio + ' ' + (this.todayDate.getDate() + '-' + (this.todayDate.getMonth() + 1) + '-' + this.todayDate.getFullYear()) + '.csv';
                document.body.appendChild(downloadElement);
                downloadElement.click();
            })
            .catch(error => {
                console.log(error);
            })
            .finally(() => {
                this.exportDisabled = false;
            });
    }

    handleSave(event) {
        let editPortfolioAnalysis = false;
        let valuePortfolioAnalysis;
        let idsPortfolioAnalysis = [];
        let idsComiteSindicaciones = [];
        let idsALM = [];
        let editComiteSindicaciones = false;
        let valueComiteSindicaciones;
        let editALM = false;
        let valueALM;
        this.values = event.detail.draftValues;
        this.altura = 'height: 410px';
        const returnValues = {
            Id: {},
            CIBE_Observaciones__c: {},
            CIBE_Sindicaciones__c: {},
            CIBE_DictamenALM__c: {},
            CIBE_AlgunaOperRAR__c: {},
            CIBE_ECAs__c: {},
            CIBE_Nivel__c: {},
            CIBE_VigenciaOferta__c: {},
            AV_ClienteConfidencial__c: {},
            CIBE_Linea__c: {},
            CIBE_CreditPortAnalystReview__c: {},
            CIBE_DicALM__c: {}, 
            CIBE_SyndicationTeamOpinion__c: {}
        };

        const recordInputs = this.values.map(row => {
            var num = row.Id.replace('row-', '');
            returnValues.Id = this.data[num].iden.substring(1);
            returnValues.CIBE_Observaciones__c = row.observaciones !== undefined ? row.observaciones : this.data[num].observaciones !== undefined ? this.data[num].observaciones : '',
            returnValues.AV_ClienteConfidencial__c = row.confidencial !== undefined ? row.confidencial : this.data[num].confidencial,
            returnValues.CIBE_Linea__c = row.linea !== undefined ? row.linea : this.data[num].linea,
            returnValues.CIBE_Sindicaciones__c = row.sindicaciones !== undefined ? row.sindicaciones : this.data[num].sindicaciones,
            returnValues.CIBE_ECAs__c = row.ecas !== undefined ? row.ecas : this.data[num].ecas,
            returnValues.CIBE_AlgunaOperRAR__c = row.algunaOperacionRAR !== undefined ? row.algunaOperacionRAR : this.data[num].algunaOperacionRAR,
            returnValues.CIBE_Nivel__c = row.nivel !== undefined ? row.nivel : this.data[num].nivel,
            returnValues.CIBE_VigenciaOferta__c = row.vigenciaOferta !== undefined ? row.vigenciaOferta : this.data[num].vigenciaOferta
            if(row.analystReview !== undefined){
                editPortfolioAnalysis = true;
                valuePortfolioAnalysis = row.analystReview;
                idsPortfolioAnalysis.push(returnValues.Id);
            }

            if(row.sindicacionesTeam !== undefined){
                editComiteSindicaciones = true;
                valueComiteSindicaciones = row.sindicacionesTeam;
                idsComiteSindicaciones.push(returnValues.Id);
            }

            if(row.dictamenALM !== undefined){
                editALM = true;
                valueALM = row.dictamenALM;
                idsALM.push(returnValues.Id);
            }
            const fields = Object.assign({}, returnValues);
            return { fields }
        });


        this.isLoading = true;
        this.errors = { rows: {} };
        const promises = recordInputs.map(iden => updateRecord(iden));
        Promise.allSettled(promises).then(results => {
            results.forEach((res, i) => {
                if (res.status === 'rejected') {
                    if (res.reason.body.output.errors[0].message) {
                        const key = event.detail.draftValues[i].Id;
                        this.errors.rows[key] = {
                            title: ' ',
                            messages: [res.reason.body.output.errors[0].message],
                            fieldNames: [...Object.keys(event.detail.draftValues[i]), 'AccountLink']
                        }
                    }
                }
            });
            
            if(editPortfolioAnalysis){
                updateCreditoPortfolio({ recordId: idsPortfolioAnalysis, creditoPortfolio: valuePortfolioAnalysis, negocioV: this.creditNeg, redesV: this.creditRed })
                .then((data) => { 
                    if (data === 'NOK') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                        title: this.label.updateOppKo,
                        message: this.label.creditoPortfolioError,
                        variant: 'error'
                        })
                    );
                    } 
                }).catch(error => {
                    Console.log(error);
                }).finally(() => {
                    refreshApex(this._wiredData).then(() => {
                        this.isLoading = false;
                    });
                });
            }

            if(editComiteSindicaciones){
                updateEquipoSindicaciones({ recordId: idsComiteSindicaciones, equipoSindicaciones: valueComiteSindicaciones, negocioV: this.sindNeg, redesV: this.sindRed, listado: true })
                .then((data) => {
                if (data === 'NOK') {
                    this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.updateOppKo,
                        message: this.label.syndicationTeamError,
                        variant: 'error'
                    })
                    );
                }
                }).catch(error => {
                    console.log(error);
                }).finally(() => {
                    refreshApex(this._wiredData).then(() => {
                        this.isLoading = false;
                    });
                });
            }


            if(editALM){
                updateALM({ recordId: idsALM, valueALM: valueALM, commentALM: null, negocioV: this.creditNeg, redesV: this.almRed, listado: true })
                .then((data) => { 
                    console.log(data);
                  if (data === 'NOK') {
                    this.dispatchEvent(
                      new ShowToastEvent({
                        title: this.label.updateOppKo,
                        message: this.label.almTeam,
                        variant: 'error'
                      })
                    );
                  }
                }).catch(error => {
                  console.log(error);
                }).finally(() => {
                    refreshApex(this._wiredData).then(() => {
                        this.isLoading = false;
                    });
                });
            }
            
        }).finally(() => {
            this.values = [];
            refreshApex(this._wiredData).then(() => {
                this.isLoading = false;
            });
        });
    }

    handleCancel() {
        this.values = [];
    }

    resetFilters() {
        this.isLoading = true;
        this.offSet = 0;
        this.fecha = null;
        this.fechaDesde = null;
        this.fechaHasta = null;
        this.page = 1;
        this.rowOffset = 0;
        this.totalPage = 1;
        this.importeDesde = null;
        this.importeHasta = null;
        this.picklistValues2 = null;
        this.picklistValues3 = null;
        this.picklistValues4 = null;
        this.negocios = null;
        this.redesSegmentos = null;
        this.centrosCarteras = null;
        this.sectoresPaises = null;
        this.valueTipoAprobacion = null;
        this.valueSector = null;
        this.valueCartera = null;
    }

    previousHandler() {
        this.isLoading = true;
        this.page = this.page - 1;
        this.offSet = this.offSet >= 10 ? (this.offSet - 10) : this.offSet;
        this.rowOffset = this.rowOffset - 10;
    }

    nextHandler() {
        this.isLoading = true;
        this.offSet = (this.offSet <= 1990) ? (this.offSet + 10) : this.offSet;
        this.page = this.page + 1;
        this.rowOffset = this.rowOffset + 10;
    }

    // Selección de valores
    handleValueChange(event) {
        this.data = null;
        this.negocios = event.detail.value;
        this.redesSegmentos = null;
        this.centrosCarteras = null;
        this.sectoresPaises = null;
        this.picklistValues2 = null;
        this.picklistValues3 = null;
        this.picklistValues4 = null;
        this.getDependencyPicklist('Negocios', this.negocios, this.inputObj);
    }

    handleValueChange2(event) {
        this.data = null;
        this.redesSegmentos = event.detail.value;
        this.centrosCarteras = null;
        this.sectoresPaises = null;
        this.picklistValues3 = null;
        this.picklistValues4 = null;
        this.getDependencyPicklist('Redes-Segmentos', this.redesSegmentos, this.inputObj);
    }

    handleValueChange3(event) {
        this.data = null;
        this.sectoresPaises = event.detail.value;
        this.centrosCarteras = null;
        this.picklistValues4 = null;
        this.getDependencyPicklist('Sectores-Paises', this.sectoresPaises, this.inputObj);
    }

    handleValueChange4(event) {
        this.centrosCarteras = event.detail.value;
        this.offSet = 0;
        this.data = null;
    }

    getDependencyPicklist(inputFld, inputVal, inputObjt) {
        getPicklistValuesDepen({ inputField: inputFld, inputValue: inputVal, inputObj: inputObjt })
            .then((data) => {
                switch (inputVal) {
                    case this.negocios:
                        this.picklistValues2 = JSON.parse(JSON.stringify(data));
                        if (data === null || data.length === 0) {
                            this.picklistValues2 = JSON.parse(JSON.stringify(data));
                        }
                        break;
                    case this.redesSegmentos:
                        this.picklistValues3 = JSON.parse(JSON.stringify(data));
                        if (data === null || data.length === 0) {
                            this.picklistValues3 = JSON.parse(JSON.stringify(data));
                        }
                        break;
                    case this.sectoresPaises:
                        this.picklistValues4 = JSON.parse(JSON.stringify(data));
                        break;
                }
            })
            .catch(error => {
                console.log(error);
            }
            );
    }


    handleRowAction(event) {
        let row = event.detail.row.iden;
        this.idOpp = row.substring(1);
        if (event.detail.action.name === 'comite') {
            this.isShowModal = true;
            this.isLoadingComite = true;
            this.plazoAnios = null;
            this.data.forEach(item => {
                if (item.iden === row) {
                    this.plazoAnios = item.rarPlazoVidaMediaMeses;
                }
            })

            if (this.idOpp != null) {
                this.isShowModal = true;
                this.isLoadingComite = false;
            }
        }else if(event.detail.action.name === 'documento'){
            getDocumentOpp({ recordId: this.idOpp })
            .then(data => {
                this.isShowModalFile = true;
                this.documents = data;
                if(data.length > 0 ){
                    this.hasDocuments = true;
                }else{
                    this.hasDocuments = false;
                }
                
            })
            .catch(error => {
                console.log(error);
            })
        }
    }

    hideModalBox() {
        this.isShowModal = false;
        this.isShowModalFile = false;
    }

    getCarteras() {
        getCartera({ sector: this.valueSector, picklist: this.picklistCartera })
            .then(data => {
                this.optionsCartera = data;
            })
            .catch(error => {
                console.log(error);
            })
    }

    staticColumns2 = [
        { label: ' ', fieldName: 'destacada', type: 'button-icon', typeAttributes: { iconName: { fieldName: 'destacadaIcon' }, variant: 'bare-inverse', iconClass: { fieldName: 'iconClass' }, initialWidth: 2, name: 'comite' }, hideDefaultActions: true, initialWidth: 20 },
        { label: this.label.gestor, fieldName: 'gestorId', type: 'url', typeAttributes: { label: { fieldName: 'gestorName' } }, initialWidth: 140, hideDefaultActions: true },
        { label: cliente, fieldName: 'accountId', type: 'url', typeAttributes: { label: { fieldName: 'accountName' } }, initialWidth: 140, hideDefaultActions: true },
        { label: this.label.segmentoRentabilidadEA, type: 'button-icon', initialWidth: 50, typeAttributes: { iconName: { fieldName: 'priorityiconEA' }, alternativeText: { fieldName: 'valorSemaforoEA' }, variant: 'bare-inverse', class: { fieldName: 'classEstadoEA' } }, hideDefaultActions: true, initialWidth: 64 },
        { label: this.label.segmentoRentabilidadER, type: 'button-icon', initialWidth: 50, typeAttributes: { iconName: { fieldName: 'priorityiconER' }, alternativeText: { fieldName: 'valorSemaforoER' }, variant: 'bare-inverse', class: { fieldName: 'classEstadoER' } }, hideDefaultActions: true, initialWidth: 60 },
        { label: this.label.segmentoRentabilidadGA, type: 'button-icon', initialWidth: 50, typeAttributes: { iconName: { fieldName: 'priorityiconGA' }, alternativeText: { fieldName: 'valorSemaforoGA' }, variant: 'bare-inverse', class: { fieldName: 'classEstadoGA' } }, hideDefaultActions: true, initialWidth: 62 },
        { label: this.label.segmentoRentabilidadGR, type: 'button-icon', initialWidth: 50, typeAttributes: { iconName: { fieldName: 'priorityiconGR' }, alternativeText: { fieldName: 'valorSemaforoGR' }, variant: 'bare-inverse', class: { fieldName: 'classEstadoGR' } }, hideDefaultActions: true, initialWidth: 60 },
        { label: this.label.confidencial, fieldName: 'confidencial', initialWidth: 100, cellAttributes: { alignment: 'center' }, type: 'boolean' },
        { label: this.label.gruposEconomico, fieldName: 'grupoEconomico', initialWidth: 125, hideDefaultActions: true },
        { label: this.label.rating, fieldName: 'rating', initialWidth: 65, hideDefaultActions: true }
    ];

    columns2 = [
        { fieldName: 'file', type: 'button-icon', typeAttributes: { iconName: { fieldName: 'fileIcon' }, variant: 'bare-inverse', iconClass: { fieldName: 'iconClass' }, initialWidth: 2, name: 'documento' }, hideDefaultActions: true },
        { label: this.label.name, fieldName: 'iden', type: 'url', typeAttributes: { label: { fieldName: 'name' } }, initialWidth: 190, hideDefaultActions: true },
        { label: this.label.producto, fieldName: 'pFId', type: 'url', typeAttributes: { label: { fieldName: 'pFName' } }, initialWidth: 150, hideDefaultActions: true },
        { label: importeEuros, fieldName: 'amountEuros', cellAttributes: { alignment: 'right' }, initialWidth: 110, hideDefaultActions: true },
        { label: this.label.RARPlazoVidaMediaAños, fieldName: 'rarPlazoVidaMediaMeses', initialWidth: 80, cellAttributes: { alignment: 'right' }, hideDefaultActions: true },
        { label: this.label.RARGarantias, fieldName: 'rarGarantias', initialWidth: 115, hideDefaultActions: true },
        { label: this.label.tipoOperacion, fieldName: 'tipoOperaciones', initialWidth: 135, hideDefaultActions: true },
        { label: this.label.RARMargenDiario, fieldName: 'rarMargenDiario', initialWidth: 110, cellAttributes: { alignment: 'right' }, hideDefaultActions: true },
        { label: this.label.RARInteresDiferencial, fieldName: 'rarInteresDiferencial', initialWidth: 110, cellAttributes: { alignment: 'right' }, hideDefaultActions: true },
        { label: this.label.RARComisionApertura, fieldName: 'rarComisionApertura', initialWidth: 110, cellAttributes: { alignment: 'right' }, hideDefaultActions: true },
        { label: this.label.comisionSaldoMedio, fieldName: 'comisionSaldoMedio', initialWidth: 110, cellAttributes: { alignment: 'right' }, hideDefaultActions: true },
        { label: this.label.RARConjunto, fieldName: 'rarConjunto', initialWidth: 100, cellAttributes: { alignment: 'right' }, hideDefaultActions: true },
        { label: this.label.RAROperacionRar, fieldName: 'rarOperacionRar', initialWidth: 100, cellAttributes: { alignment: 'right' }, hideDefaultActions: true },
        { label: this.label.observaciones, fieldName: 'observaciones', editable: true, initialWidth: 175 },
        { label: this.label.observacionesPrecio, fieldName: 'observacionesPrecio', initialWidth: 175 },
        { label: this.label.RARPost, fieldName: 'rarPost', initialWidth: 110, cellAttributes: { alignment: 'right' }, hideDefaultActions: true },
        { label: this.label.nivel, fieldName: 'nivel', editable: true, initialWidth: 145, hideDefaultActions: true },
        { label: this.label.analystReview, fieldName: 'analystReview', initialWidth: 90, hideDefaultActions: true, editable: true, type: 'picklistColumn', typeAttributes: { options: { fieldName: 'picklistHierarchy' }, value: { fieldName: 'analystReview' }, placeholder: this.label.select } },
        { label: this.label.dictamenALM, fieldName: 'dictamenALM', editable: true, type: 'picklistColumn', initialWidth: 90, hideDefaultActions: true, typeAttributes: { options: { fieldName: 'picklistHierarchy' }, value: { fieldName: 'dictamenALM' }, placeholder: this.label.select }  },
        { label: this.label.sindicaciones, fieldName: 'sindicaciones', editable: true, type: 'boolean', initialWidth: 85, cellAttributes: { alignment: 'center' }, hideDefaultActions: true },
        { label: this.label.sindicacionesTeam, fieldName: 'sindicacionesTeam', initialWidth: 125, hideDefaultActions: true, editable: true, type: 'picklistColumn', typeAttributes: { options: { fieldName: 'picklistHierarchy' }, value: { fieldName: 'sindicacionesTeam' }, placeholder: this.label.select } },
        { label: this.label.ecas, fieldName: 'ecas', editable: true, type: 'boolean', initialWidth: 85, cellAttributes: { alignment: 'center' }, hideDefaultActions: true },
        { label: this.label.algunaOperacionRAR, fieldName: 'algunaOperacionRAR', editable: true, type: 'boolean', initialWidth: 85, cellAttributes: { alignment: 'center' }, hideDefaultActions: true },
        { label: this.label.vigenciaOferta, fieldName: 'vigenciaOferta', editable: true, type: 'picklistColumn', wrapText: true, typeAttributes: { options: { fieldName: 'pickListOptions' }, value: { fieldName: 'vigenciaOferta' }, placeholder: this.label.select }, initialWidth: 135, hideDefaultActions: true },
        { label: this.label.pais, fieldName: 'pais', cellAttributes: { alignment: 'right' }, initialWidth: 95, hideDefaultActions: true },
        { label: this.label.RARIndiceReferencia, fieldName: 'rarIndiceReferencia', initialWidth: 110, cellAttributes: { alignment: 'right' }, hideDefaultActions: true },
        { label: this.label.fechaCierre, fieldName: 'closeDate', type: 'date', typeAttributes: { day: '2-digit', month: '2-digit', year: 'numeric' }, initialWidth: 115, cellAttributes: { alignment: 'right' }, hideDefaultActions: true },
        { label: this.label.impactoBalance, fieldName: 'balanceDivisa', cellAttributes: { alignment: 'right' }, initialWidth: 110, hideDefaultActions: true },
        { label: this.label.impactoDivisaComisionesCierreAnio, fieldName: 'impactoDivisaComisionesCierreAnio', initialWidth: 110, cellAttributes: { alignment: 'right' }, hideDefaultActions: true },
        { label: this.label.impactoComisiones, fieldName: 'comisionesDivisa', cellAttributes: { alignment: 'right' }, initialWidth: 110, hideDefaultActions: true },
        { label: this.label.impactoComisionesCierreAnio, fieldName: 'impactoComisionesCierreAnio', initialWidth: 110, cellAttributes: { alignment: 'right' }, hideDefaultActions: true },
        { label: this.label.grupoComercial, fieldName: 'grupoComercialId', type: 'url', typeAttributes: { label: { fieldName: 'grupoComercialName' } }, initialWidth: 170, hideDefaultActions: true },
        { label: numeroDocumento, fieldName: 'accountCif', initialWidth: 135, hideDefaultActions: true },
        { label: this.label.fechaComitePrecios, fieldName: 'fechaAprobacionPrecio', type: 'date', typeAttributes: { day: '2-digit', month: '2-digit', year: 'numeric' }, initialWidth: 140, cellAttributes: { alignment: 'right' }, hideDefaultActions: true },
        { label: this.label.VAOperacion, fieldName: 'vaOperacion', initialWidth: 110, cellAttributes: { alignment: 'right' }, hideDefaultActions: true },
        { label: this.label.RARComision12meses, fieldName: 'rarComision12meses', initialWidth: 110, cellAttributes: { alignment: 'right' }, hideDefaultActions: true },
        { label: this.label.linea, fieldName: 'linea', cellAttributes: { alignment: 'center' }, type: 'boolean', initialWidth: 85, hideDefaultActions: true },
        { label: this.label.RARSeveridad, fieldName: 'rarSeveridad', initialWidth: 75, cellAttributes: { alignment: 'right' }, hideDefaultActions: true },
        { label: importe, fieldName: 'amountDivisa', cellAttributes: { alignment: 'right' }, initialWidth: 90, hideDefaultActions: true },
        { label: divisa, fieldName: 'divisa', initialWidth: 70, hideDefaultActions: true },
        { label: this.label.importeRenovacion, fieldName: 'importeRenovacion', initialWidth: 110, hideDefaultActions: true },
        { label: this.label.importeVariacion, fieldName: 'importeVariacion', initialWidth: 110, hideDefaultActions: true },
        { label: this.label.owner, fieldName: 'ownerId', type: 'url', typeAttributes: { label: { fieldName: 'ownerName' } }, initialWidth: 140, hideDefaultActions: true }
    ];


    columnsDocuments = [
        { label: this.label.nameSimple, fieldName: 'id', type: 'url', typeAttributes: { label: { fieldName: 'name' } }, hideDefaultActions: true },
        { label: this.label.createdDate, fieldName: 'createdDate', type: 'date', typeAttributes: { day: '2-digit', month: '2-digit', year: 'numeric' }, cellAttributes: { alignment: 'right' }, hideDefaultActions: true }
    ];

}