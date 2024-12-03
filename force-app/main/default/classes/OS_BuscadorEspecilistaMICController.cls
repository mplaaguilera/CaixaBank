public with sharing class OS_BuscadorEspecilistaMICController {
    
    @AuraEnabled
    public static void asociar(List<Account> cuentasApex, String regActualApex){
        if (
            Schema.sObjectType.Account.isUpdateable() && 
            Schema.sObjectType.Account.fields.OS_Especialista_MIC__c.isUpdateable()
        ) {
            if(regActualApex != null && regActualApex != ''){
                Id rt = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
                List<Account> cuentasEliminar = [SELECT Id, Name, OS_Modificacion_Campos_COPS__c, OS_Especialista_MIC__c 
                            FROM Account
                            WHERE RecordTypeId =: rt AND OS_Especialista_MIC__c =: regActualApex];
                            
                List<Account> paraUpdate = new List<Account>();
                Map<Id, Account> mapNoDupli = new Map<Id ,Account>();
                //primer update para evitar que salte la validation rule (VR), segundo para dejar en el estado previo el campo que hace que pasa por alto la VR  
                if(!cuentasEliminar.isEmpty()){
                    for(Account accEliminar : cuentasEliminar){
                        accEliminar.OS_Modificacion_Campos_COPS__c = true;
                        accEliminar.OS_Especialista_MIC__c = null;
                        mapNoDupli.put(accEliminar.Id, accEliminar);
                    }
                }
                if(!cuentasApex.isEmpty()){
                    for (Account acc : cuentasApex) {
                        acc.OS_Especialista_MIC__c = regActualApex;
                        acc.OS_Modificacion_Campos_COPS__c = true;
                        if (mapNoDupli.containsKey(acc.Id)) {
                            Account accMap = mapNoDupli.get(acc.Id);
                            accMap.OS_Especialista_MIC__c = acc.OS_Especialista_MIC__c;
                            mapNoDupli.put(acc.Id, accMap);
                        }
                        else {
                            mapNoDupli.put(acc.Id, acc);
                        }
                    }
                }

                if(!mapNoDupli.isEmpty()){
                    paraUpdate = mapNoDupli.values();

                    update paraUpdate;

                    for (Account acc : paraUpdate) {
                        acc.OS_Modificacion_Campos_COPS__c = false;
                    }
                    update paraUpdate;
                }
            }
        }
        else {
            throw new AuraHandledException('Permisos insuficientes');
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccounts(String keyword){
        if(Schema.sObjectType.Account.isAccessible()){
            Id rt = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            List<List<SObject>> searchResults =  [FIND :keyword IN ALL FIELDS RETURNING Account(Id, Name, OS_Modificacion_Campos_COPS__c, OS_Especialista_MIC__c, CC_Numero_Oficina__c   WHERE RecordTypeId =: rt ORDER BY CC_Numero_Oficina__c ASC )];
            return (Account[])searchResults[0];
        }
        else {
            throw new AuraHandledException('Permisos insuficientes');
        }
    }

    @AuraEnabled
    public static List<Account> cargarDatos(String regActualApex){
        if(Schema.sObjectType.Account.isAccessible()){
            if(regActualApex != null && regActualApex != '' ){
                return [SELECT Id, Name FROM Account WHERE OS_Especialista_MIC__c =: regActualApex ORDER BY CC_Numero_Oficina__c ASC];
            }
            else {
                throw new AuraHandledException('No existe recordId');
            }
        }
        else {
            throw new AuraHandledException('Permisos insuficientes');
        }
    }
}