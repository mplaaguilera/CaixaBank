global class CC_FacturarCasosCerrados_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global CC_FacturarCasosCerrados_Batch() {}

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        if(Test.isRunningTest()){
            query  = 'SELECT Id, CC_Catalogo_Facturacion__c,CC_Precio_Facturacion__c,CC_Precio_Facturar__c,CC_Facturado__c FROM Case ' + 
            'WHERE RecordType.DeveloperName IN (\'CC_Cliente\', \'CC_Empleado\') AND Status = \'Cerrado\' AND CC_Catalogo_Facturacion__c !=null LIMIT 10';
        }else{
            query  = 'SELECT Id, CC_Catalogo_Facturacion__c,CC_Precio_Facturacion__c,CC_Precio_Facturar__c,CC_Facturado__c FROM Case ' + 
            'WHERE ClosedDate = LAST_MONTH AND RecordType.DeveloperName IN (\'CC_Cliente\', \'CC_Empleado\') AND Status IN(\'Cerrado\',\'Rechazado\') AND CC_Catalogo_Facturacion__c !=null AND CC_Precio_Facturacion__c !=null AND CC_Precio_Facturar__c !=null';
        }
            return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Case> scope) {
        List<Case> casosActualizar = new List<Case>();
        for(Case caso:scope){
            caso.CC_Facturado__c = true;
            casosActualizar.add(caso);
            
        }

        if(!casosActualizar.isEmpty()){
            Database.update(casosActualizar, false);
        }
    }

    global void finish(Database.BatchableContext bc) {
        
    }
}