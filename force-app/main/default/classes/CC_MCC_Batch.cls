public class CC_MCC_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
 List<Id> idsMcc;
    //public CC_Agrupador_Batch (List<Id> idAgrupadores) { this.idAgrupadores = idAgrupadores; }

    public CC_MCC_Batch () 
    { 
        CBK_log.debug('Comienzo batch');
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT id, RecordTypeId, CC_Activo__c, CC_Tipo_Cliente__c, CC_Fecha_Vigencia_Fin__c FROM CC_MCC__c WHERE CC_Fecha_Vigencia_Fin__c = TODAY 
                                         AND CC_Activo__c = false AND CC_Tipo_Cliente__c IN ('Cliente','Empleado','Cliente/Empleado')]); 
    }

    public void execute(Database.BatchableContext bc, List<CC_MCC__c> records) {

         
		Id rtTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
		Id rtProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
		Id rtMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		Id rtCausa = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();

        List<CC_MCC__c> lstMCC = new List<CC_MCC__c>(); 
        
        for (CC_MCC__c mcc : records){            
            
            if(mcc.RecordTypeId == rtTematica || mcc.RecordTypeId == rtProducto || 
            mcc.RecordTypeId == rtMotivo || mcc.RecordTypeId == rtCausa){
                lstMCC.add(mcc);
            }
        }

        if(!lstMCC.isEmpty()){
            //Prueba de funcionamiento estandar
            autoBajaMCC(lstMCC, rtTematica, rtProducto, rtMotivo, rtCausa);
        }
    }


    public void finish(Database.BatchableContext bc) 
    {
        CBK_log.debug('Fin batch Agrupador CC');        
    }

    private void autoBajaMCC(List<CC_MCC__c> lstMCC, String rtTematica, String rtProducto, String rtMotivo, String rtCausa){

        String day = string.valueOf(system.now().day());
        String month = string.valueOf(system.now().month());
        String hour = string.valueOf(system.now().hour());
        String minute = string.valueOf(system.now().minute() + 1);
        String second = string.valueOf(system.now().second());
        String year = string.valueOf(system.now().year());
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        
		List<CC_MCC__c> lstMccUpd = new list<CC_MCC__c>(); 
        for (CC_MCC__c mcc : lstMCC){    
            if (!mcc.CC_Activo__c &&
                (mcc.CC_Tipo_Cliente__c == 'Cliente' || mcc.CC_Tipo_Cliente__c == 'Empleado' || mcc.CC_Tipo_Cliente__c == 'Cliente/Empleado')){
                lstMccUpd.add(mcc);
            }
        }
        if (!lstMccUpd.isEmpty()) {
            for(CC_MCC__c mcc :lstMccUpd){
                if(mcc.RecordTypeId == rtTematica){
                    CC_MCC_Automatize_Date.bajaProductos(lstMccUpd);
                }
                if(mcc.RecordTypeId == rtProducto){
                    CC_MCC_Automatize_Date.bajaMotivos(lstMccUpd);
                }
                if(mcc.RecordTypeId == rtMotivo){
                    CC_MCC_Automatize_Date.bajaCausa(lstMccUpd);
                }
                if(mcc.RecordTypeId == rtCausa){
                    CC_MCC_Automatize_Date.bajaSolucion(lstMccUpd);
                }
            }
            
        }
    }
    }