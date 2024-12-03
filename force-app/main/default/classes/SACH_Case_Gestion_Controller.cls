public with sharing class SACH_Case_Gestion_Controller {

    @AuraEnabled(cacheable=true)
    public static List<OT_Picklist.Item> getValueMCC(String tipoCliente, String tipoRegistro, String mccRelacionado) {
        String methodName = 'getValueMCC';

        List<OT_Picklist.Item> opciones = new List<OT_Picklist.Item>();
        String rtId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', tipoRegistro);
        String sql = 'Select Name from CC_MCC__c WHERE RecordTypeId = \''+rtId+'\' AND CC_Tipo_Cliente__c = \''+tipoCliente+'\' AND CC_Activo__c = true';
        switch on tipoRegistro {
            when 'CC_Producto_Servicio' {
                sql = sql+' AND CC_Tematica__c = \'' + mccRelacionado+'\'';
            }
            when 'CC_Motivo' {
                sql = sql+' AND CC_Producto_Servicio__c = \''+mccRelacionado+'\'';
            }
            when 'CC_Causa' {
                sql = sql+' AND CC_Motivo__c = \''+mccRelacionado+'\'';
            }
            when 'CC_Solucion' {
                sql = sql+' AND CC_Causa__c = \''+mccRelacionado+'\'';
            }

        }
        sql = sql+' ORDER BY Name ASC';

        List<CC_MCC__c> lstMCC = Database.query(sql);
        for (CC_MCC__c mcc : lstMCC){
            OT_Picklist.Item wrap = new OT_Picklist.Item(mcc.Id, mcc.Name);
            opciones.add(wrap);
        }

        return opciones;
    }

    @AuraEnabled
    public static void crearActividad(Id recordId, String tipo, String motivo) {

        Map<String, Object> camposTarea = new Map<String, Object>();
        camposTarea.put('WhatId', recordId);
        camposTarea.put('Type', tipo);
        camposTarea.put('Subject', tipo);
        camposTarea.put('ActivityDate', System.today());
        camposTarea.put('Status', 'Completed');
        camposTarea.put('Description', motivo);
        insert SACH_Activity.crearTarea('SACH_Task', camposTarea);
    }

    @AuraEnabled
    public static void reabrirTareaTrasladoColaborador(Id idCaso) {
        SACH_Activity.reabrirTareaTrasladoColab(idCaso);
    }

    
    @AuraEnabled
    public static void validarOperativaPromor(Case caso) {
        String nombreSolucion = '';
        Id sachCaseTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SACH_Cliente');
        Id rtsolucionCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
        List<CC_MCC__c> mccSolucion = [SELECT Id,Name from CC_MCC__c WHERE RecordTypeId = :rtsolucionCaso AND CC_Tipo_Cliente__c = 'Cliente (SACH)' AND CC_Activo__c = true];

        for(CC_MCC__c mcc : mccSolucion) {
            if(mcc.Id == caso.CC_MCC_Solucion__c) {
                nombreSolucion = mcc.Name;
            }
        }

        

        SACH_Activity.reabrirTareaTrasladoColab(caso.Id);
    }

}