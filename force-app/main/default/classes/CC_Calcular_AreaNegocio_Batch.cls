/**
 * @description       : 
 * @author            : Adrian Mariscal
 * @group             : 
 * @last modified on  : 11-14-2022
 * @last modified by  : Adrian Mariscal
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   06-15-2022   Adrian Mariscal   Initial Version
**/
@isTest
global class CC_Calcular_AreaNegocio_Batch{// implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
   /** private String fechaCierre;

    global CC_Calcular_AreaNegocio_Batch() {}

    global CC_Calcular_AreaNegocio_Batch(String fechaCierre) {
        this.fechaCierre = fechaCierre;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        Datetime fechaCreacion = Datetime.newInstance(2022, 05, 01);
        String query;
        if(fechaCierre == null){
            query = 'SELECT Id FROM Case WHERE CreatedDate >= :fechaCreacion AND RecordType.DeveloperName LIKE \'CC_%\' AND Status = \'Cerrado\' AND CC_Facturado__c  = FALSE' ;
        }else{
            query = 'SELECT Id FROM Case WHERE ClosedDate = ' + fechaCierre + ' AND CreatedDate >= :fechaCreacion AND RecordType.DeveloperName LIKE \'CC_%\' AND Status = \'Cerrado\' AND CC_Facturado__c  = FALSE';
        }
        return Database.getQueryLocator(query); 
    }

    global void execute(Database.BatchableContext bc, List<Case> scope) {
        Set<Id> idSet = new Set<Id>();
        
        for(Case c:scope){
            idSet.add(c.Id);
        }
        
        CC_Lista_Valores__c listaValores = [SELECT Id FROM 	CC_Lista_Valores__c WHERE Name = 'CC_Asignacion_Area_Negocio_Clientes'];
        List<CC_Lista_Valores__c> valores = [SELECT Id,CC_Valor__c,CC_Valor_Amplio__c FROM CC_Lista_Valores__c WHERE CC_Lista__c = :listaValores.Id];
                
        List<Case> casos = new List<Case>();
        List<Case> casosActualizar = new List<Case>();
        try{
            for(CC_Lista_Valores__c valor:valores){
                if(!idSet.isEmpty()){
                    String ids = '(';
                    for(Id caseId:idSet){
                        ids += '\'' + caseId + '\',';
                    }
                    ids = ids.removeEnd(',');
                    ids += ')';
                    String query = valor.CC_Valor_Amplio__c;
                    query = query.replace('{ids}', ids);
                    casos = Database.query(query);
                    for(Case caso:casos){
                        idSet.remove(caso.Id);
                        caso.CC_Area_Negocio__c = valor.CC_Valor__c;
                        casosActualizar.add(caso);
                    }
                }                            
            }
        }catch(Exception e){
            System.debug(e);
        }

        if (!casosActualizar.isEmpty() && Schema.sObjectType.Case.fields.CC_Area_Negocio__c.isUpdateable()) {
            List<Database.SaveResult> results = Database.update(casosActualizar,false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        CBK_log.debug('CC_Calcular_AreaNegocio_Batch: Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage(), LoggingLevel.ERROR);
                    }
                }     
            }             
        } else {
            CBK_log.debug('CC_Calcular_AreaNegocio_Batch: Error returned: No se han encontrado casos o no hay permiso sobre el campo CC_Area_Negocio__c');
        }
    }

    global void finish(Database.BatchableContext bc) {
        
    }

    */
}