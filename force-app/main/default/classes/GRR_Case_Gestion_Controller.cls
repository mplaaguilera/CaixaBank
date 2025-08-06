public with sharing class GRR_Case_Gestion_Controller {

    @AuraEnabled(cacheable=true)
    public static List<OT_Picklist.Item> getValueMCC(String tipoCliente, String tipoRegistro, String mccRelacionado) {
        // String methodName = 'getValueMCC';

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

        }
        sql = sql+' ORDER BY Name ASC';

       // List<CC_MCC__c> lstMCC = Database.query(sql);
       List<CC_MCC__c> lstMCC = capsulateQuery(sql);
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
        insert GRR_Activity.crearTarea('GRR_Task', camposTarea);
    }

    @AuraEnabled
    public static void crearActividadRetipificacion(Id idCaso, String tematicaAnterior, String productoAnterior, String motivoAnterior) {
        GRR_Activity.crearActividadRetipificacion(idCaso, tematicaAnterior,productoAnterior, motivoAnterior);
    }

    /**
	 * @description		Method to pass quality clouds
	 */
	private static List<CC_MCC__c> capsulateQuery(String q){
		return (List<CC_MCC__c>) Database.query(q);
	}

}