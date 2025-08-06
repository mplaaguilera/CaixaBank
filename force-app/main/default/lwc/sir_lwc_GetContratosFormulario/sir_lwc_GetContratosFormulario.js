import { LightningElement, track, api, wire} from 'lwc';
import GetcontratosDeuda from '@salesforce/apex/SIR_LCMP_GetContratosFormulario.getcontratosDeuda';
import GetcontratosSinDeuda from '@salesforce/apex/SIR_LCMP_GetContratosFormulario.getcontratosSinDeuda';

const columnsContratoDeuda = [
    { label: 'Número de Contrato', fieldName: 'SIREC__SIREC_fld_numeContrato__c', type: 'text',hideDefaultActions: true },
    { label: 'Producto', fieldName: 'SIREC__SIREC_fld_tipoContrato__c', type: 'text',hideDefaultActions: true },
    { label: 'Situación contable', fieldName: 'SIREC__SIREC_fld_sitContable__c', type: 'text',hideDefaultActions: true },
    { label: 'Situación Administrativa', fieldName: 'SIREC__SIREC_fld_sitMorosidade__c', type: 'text',hideDefaultActions: true },  
    { label: 'Cuota', fieldName: 'SIREC__SIREC_fld_importeImpagado__c', type: 'currency',hideDefaultActions: true},   
    { label: 'Deuda total', fieldName: 'SIREC__SIREC_fld_deudaTotalContrato__c', type: 'currency',hideDefaultActions: true },
    { label: 'Deuda Pendiente de vencer', fieldName: 'SIREC__SIREC_fld_deudaPendienteVencimiento__c', type: 'currency',hideDefaultActions: true },
    { label: 'Deuda Vencida', fieldName: 'SIREC__SIREC_fld_deudaVencidaImpagada__c', type: 'currency',hideDefaultActions: true },
    { label: 'Días Impagados', fieldName: 'SIREC__SIREC_fld_diasImpagados__c', type: 'number',hideDefaultActions: true },
    { label: 'Refinanciado', fieldName: 'SIREC__SIREC_fld_refinanciado__c', type: 'Boolean',hideDefaultActions: true },
    { label: 'Refinanciador', fieldName: 'SIREC__SIREC_fld_refinanciador__c', type: 'Boolean',hideDefaultActions: true },
    { label: 'Contratos arrastrado', fieldName: 'SIREC__SIREC_fld_numContratosArrastre__c', type: 'number',hideDefaultActions: true },
    { label: 'Volumen arrastrado', fieldName: 'SIREC__SIREC_fld_volArrastre__c', type: 'currency',hideDefaultActions: true },
    { label: 'Contratos cura', fieldName: 'SIREC__SIREC_fld_numContratosCura__c', type: 'number',hideDefaultActions: true },
    { label: 'Volumen cura', fieldName: 'SIREC__SIREC_fld_volCura__c', type: 'currency',hideDefaultActions: true }
];
const columnsContratoSinDeuda = [
    { label: 'Número de Contrato', fieldName: 'SIREC__SIREC_fld_numeContrato__c', type: 'text',hideDefaultActions: true },
    { label: 'Producto', fieldName: 'SIREC__SIREC_fld_tipoContrato__c', type: 'text' ,hideDefaultActions: true},
    { label: 'Situación contable', fieldName: 'SIREC__SIREC_fld_sitContable__c', type: 'text' ,hideDefaultActions: true},
    { label: 'Situación Administrativa', fieldName: 'SIREC__SIREC_fld_sitMorosidade__c', type: 'text',hideDefaultActions: true },   
    { label: 'Cuota', fieldName: 'SIREC__SIREC_fld_importeImpagado__c', type: 'currency',hideDefaultActions: true}, 
    { label: 'Deuda total', fieldName: 'SIREC__SIREC_fld_deudaTotalContrato__c', type: 'currency',hideDefaultActions: true},
    { label: 'Deuda Pendiente de vencer', fieldName: 'SIREC__SIREC_fld_deudaPendienteVencimiento__c', type: 'currency',hideDefaultActions: true },
    { label: 'Deuda Vencida', fieldName: 'SIREC__SIREC_fld_deudaVencidaImpagada__c', type: 'currency',hideDefaultActions: true },
    { label: 'Días Impagados', fieldName: 'SIREC__SIREC_fld_diasImpagados__c', type: 'number',hideDefaultActions: true },
    { label: 'Refinanciado', fieldName: 'SIREC__SIREC_fld_refinanciado__c', type: 'Boolean',hideDefaultActions: true },
    { label: 'Refinanciador', fieldName: 'SIREC__SIREC_fld_refinanciador__c', type: 'Boolean',hideDefaultActions: true },
    { label: 'Contratos arrastrado', fieldName: 'SIREC__SIREC_fld_numContratosArrastre__c', type: 'number',hideDefaultActions: true },
    { label: 'Volumen arrastrado', fieldName: 'SIREC__SIREC_fld_volArrastre__c', type: 'currency',hideDefaultActions: true },
    { label: 'Contratos cura', fieldName: 'SIREC__SIREC_fld_numContratosCura__c', type: 'number',hideDefaultActions: true },
    { label: 'Volumen cura', fieldName: 'SIREC__SIREC_fld_volCura__c', type: 'currency',hideDefaultActions: true }
];
export default class Sir_lwc_GetContratosFormulario extends LightningElement {
    contratosConDeuda       = [];
    contratosSinDeuda       = [];
    columnsContratoDeuda    = columnsContratoDeuda;
    columnsContratoSinDeuda = columnsContratoSinDeuda;
    @api recordId;
    @track sumContractDeuda;
    @track sumContractSinDeuda;      

    @wire(GetcontratosDeuda, { recordId: '$recordId'}) // 
    GetcontratosDeuda({ error, data }) {
        if (data) {
           this.sumContractDeuda = data.length;
           this.contratosConDeuda = data;
        }
    }
    @wire(GetcontratosSinDeuda, { recordId: '$recordId'}) // 
    GetcontratosSinDeuda({ error, data }) {
        if (data) {
           this.contratosSinDeuda = data;
           this.sumContractSinDeuda = data.length;
        }
    }
}