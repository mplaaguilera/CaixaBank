/**
 * @description       : 
 * @author            : Adrian Mariscal
 * @group             : 
 * @last modified on  : 11-02-2022
 * @last modified by  : Adrian Mariscal
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   06-08-2022   Adrian Mariscal   Initial Version
**/

public with sharing class CC_Margen_Facturacion_BI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CBK_Margen_Facturacion__c>)tp.newList, (Map<Id, CBK_Margen_Facturacion__c>)tp.newMap, (List<CBK_Margen_Facturacion__c>)tp.oldList, (Map<Id, CBK_Margen_Facturacion__c>)tp.oldMap);
    }

    private void process(List<CBK_Margen_Facturacion__c> listNewObj, Map<Id, CBK_Margen_Facturacion__c> mapNewObj, List<CBK_Margen_Facturacion__c> listOldObj, Map<Id, CBK_Margen_Facturacion__c> mapOldObj) {
               
        validarRegistros(listNewObj);
    }

    public static void validarRegistros(List<CBK_Margen_Facturacion__c> newList){
        Date fechaInicio;
        Date fechaFin;

        for(CBK_Margen_Facturacion__c mf:newList){
            fechaInicio = (fechaInicio == null ? mf.CC_Fecha_Inicio__c : (fechaInicio < mf.CC_Fecha_Inicio__c ? fechaInicio : mf.CC_Fecha_Inicio__c));
            fechaFin = (fechaFin == null ? mf.CC_Fecha_Fin__c : (fechaFin > mf.CC_Fecha_Fin__c ? fechaFin : mf.CC_Fecha_Fin__c));
        }

        List<CBK_Margen_Facturacion__c> mfList;
        if(fechaFin == null){
            mfList = [SELECT CC_Area_de_Negocio__c, CC_Fecha_Inicio__c,CC_Fecha_Fin__c FROM CBK_Margen_Facturacion__c 
                                                    WHERE (CC_Fecha_Inicio__c >= :fechaInicio OR CC_Fecha_Fin__c = null)];
        }else{
            mfList = [SELECT CC_Area_de_Negocio__c, CC_Fecha_Inicio__c,CC_Fecha_Fin__c FROM CBK_Margen_Facturacion__c 
            WHERE (CC_Fecha_Inicio__c >= :fechaInicio OR CC_Fecha_Fin__c = null)
            AND (CC_Fecha_Fin__c <= :fechaFin OR CC_Fecha_Fin__c = null)];
        }

        Boolean error;
        for(CBK_Margen_Facturacion__c mf:newList){
            error = false;
            for(CBK_Margen_Facturacion__c mfAux:mfList){
                if(mf.CC_Area_de_Negocio__c == mfAux.CC_Area_de_Negocio__c){
                    if(mf.CC_Fecha_Inicio__c >= mfAux.CC_Fecha_Inicio__c && (mf.CC_Fecha_Inicio__c <= mfAux.CC_Fecha_Fin__c || mfAux.CC_Fecha_Fin__c == null)){
                        mf.addError('La fechas se solapan con otro registro');
                        error = true;
                    }
                    if(mf.CC_Fecha_Fin__c >= mfAux.CC_Fecha_Inicio__c && (mf.CC_Fecha_Fin__c <= mfAux.CC_Fecha_Fin__c || mfAux.CC_Fecha_Fin__c == null)){
                        mf.addError('La fechas se solapan con otro registro');
                        error = true;
                    }
                    if(mf.CC_Fecha_Fin__c == null && mf.CC_Fecha_Inicio__c <= mfAux.CC_Fecha_Inicio__c){
                        mf.addError('La fechas se solapan con otro registro');
                        error = true;
                    }
                    if(mfAux.CC_Fecha_Fin__c == null && mf.CC_Fecha_Inicio__c >= mfAux.CC_Fecha_Inicio__c){
                        mf.addError('La fechas se solapan con otro registro');
                        error = true;
                    }
                }                
            } 
        }
        
    }
}