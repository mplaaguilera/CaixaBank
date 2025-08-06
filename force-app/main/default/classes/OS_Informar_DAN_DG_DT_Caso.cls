public with sharing class OS_Informar_DAN_DG_DT_Caso {
    //Este metodo es para evitar llama a una atualizacion de datos tras la llamada a un trigger
    public static void informarCamposBeforeTrigger(List<Case> lstCasos) {
        //DAN(GC) -> Delegacion general(DG) -> Direccion territorial DT -> TT -> TE  
        Set<Id> idsCuentas = new Set<Id>();
        
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();

        for(Case caso : lstCasos){
            idsCuentas.add(caso?.AccountId);
            idsCuentas.add(caso?.Account?.Parent?.Parent?.ParentId);
            idsCuentas.add(caso?.Account?.CC_OficinaGestoraId__r?.Parent?.Parent?.ParentId);
        }

        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id,
        CC_Tipo_Centro__c,
        ParentId, Parent.CC_Tipo_Centro__c,
        Parent.ParentId, Parent.Parent.CC_Tipo_Centro__c,
        Parent.Parent.ParentId, Parent.Parent.Parent.CC_Tipo_Centro__c,
        Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.CC_Tipo_Centro__c,
        CC_OficinaGestoraId__c, CC_OficinaGestoraId__r.CC_Tipo_Centro__c,
        CC_OficinaGestoraId__r.ParentId, CC_OficinaGestoraId__r.Parent.CC_Tipo_Centro__c,
        CC_OficinaGestoraId__r.Parent.ParentId, CC_OficinaGestoraId__r.Parent.Parent.CC_Tipo_Centro__c,
        CC_OficinaGestoraId__r.Parent.Parent.ParentId, CC_OficinaGestoraId__r.Parent.Parent.Parent.CC_Tipo_Centro__c
        FROM Account WHERE Id IN :idsCuentas]);

        if (!lstCasos.isEmpty()) {  
            Set<Id> setCuentas = new Set<Id>();
            Map<Id, Account> mapAccountsTercerPadre = new Map<Id, Account>();
            Map<Id, Account> mapAccountsOficinaGestoraPadre = new Map<Id, Account>();

            for (Case caso : lstCasos) {
                if(mapAccounts.containsKey(mapAccounts.get(caso?.AccountId)?.Parent?.Parent?.ParentId)){
                    mapAccountsTercerPadre.put(caso.Id,mapAccounts.get(mapAccounts.get(caso.AccountId).Parent.Parent.ParentId));
                }
                if(mapAccounts.containsKey(mapAccounts.get(caso?.AccountId)?.CC_OficinaGestoraId__r?.Parent?.Parent?.ParentId)){
                    mapAccountsOficinaGestoraPadre.put(caso.Id,mapAccounts.get(mapAccounts.get(caso.AccountId).CC_OficinaGestoraId__r.Parent.Parent.ParentId));
                }
            }

            for (Case caso : lstCasos) {
                Account cuenta;
                if (caso.AccountId != null){
                    if(caso.RecordTypeId == rtEmpleado){
                        if(mapAccountsTercerPadre.containsKey(caso.Id)){
                            cuenta = mapAccountsTercerPadre.get(caso.Id);
                        } else if(mapAccounts.containsKey(caso.AccountId)){
                            cuenta = mapAccounts.get(caso.AccountId);
                        }
                    } else if (caso.RecordTypeId == rtCliente){
                        if(mapAccountsOficinaGestoraPadre.containsKey(caso.Id)){
                            cuenta = mapAccountsOficinaGestoraPadre.get(caso.Id);
                        } else if(mapAccounts.containsKey(caso.AccountId)){
                            cuenta = mapAccounts.get(caso.AccountId).CC_OficinaGestoraId__r;
                        }
                    }

                    if(cuenta != null){
                        if (cuenta.CC_Tipo_Centro__c == 'DT'){
                            caso.CC_Direccion_Territorial__c = cuenta.Id;
                        } else if (cuenta.Parent.CC_Tipo_Centro__c == 'DT'){
                            caso.CC_Direccion_Territorial__c = cuenta.ParentId;
                            if (cuenta.CC_Tipo_Centro__c == 'DG'){
                                caso.CC_DG__c = cuenta.Id;
                            }
                        } else if (cuenta.Parent.Parent.CC_Tipo_Centro__c == 'DT'){
                            caso.CC_Direccion_Territorial__c = cuenta.Parent.ParentId;
                            if (cuenta.Parent.CC_Tipo_Centro__c == 'DG'){
                                caso.CC_DG__c = cuenta.ParentId;
                            }
                            if (cuenta.CC_Tipo_Centro__c == 'GC'){
                                caso.CC_DAN__c = cuenta.Id;
                            }
                        } else if (cuenta.Parent.Parent.Parent.CC_Tipo_Centro__c == 'DT'){
                            caso.CC_Direccion_Territorial__c = cuenta.Parent.Parent.ParentId;
                            if (cuenta.Parent.Parent.CC_Tipo_Centro__c == 'DG'){
                                caso.CC_DG__c = cuenta.Parent.ParentId;
                            }
                            if (cuenta.Parent.CC_Tipo_Centro__c == 'GC'){
                                caso.CC_DAN__c = cuenta.ParentId;
                            }
                        } else if (cuenta.Parent.Parent.Parent.Parent.CC_Tipo_Centro__c == 'DT'){
                            caso.CC_Direccion_Territorial__c = cuenta.Parent.Parent.Parent.ParentId;
                            if (cuenta.Parent.Parent.Parent.CC_Tipo_Centro__c == 'DG'){
                                caso.CC_DG__c = cuenta.Parent.Parent.ParentId;
                            }
                            if (cuenta.Parent.Parent.CC_Tipo_Centro__c == 'GC'){
                                caso.CC_DAN__c = cuenta.Parent.ParentId;
                            }
                        } 
                    }
                }
            }
        }   
    }

    public static void desinformarCampos(List<Case> casosActualizarList){
        for(Case caso: casosActualizarList){
            caso.CC_DAN__c = null;
            caso.CC_DG__c = null;
            caso.CC_Direccion_Territorial__c = null;
        }
    }
}