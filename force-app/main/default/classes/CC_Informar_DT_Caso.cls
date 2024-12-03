public with sharing class CC_Informar_DT_Caso {
    @InvocableMethod(label='CC_Informa_DireccionTerritorial' description='Informa la Dirección Territorial')
    public static void informaDireccionTerritorial(List<Id> caseID) {
        List<Case> listCase = new List<Case>();
        List<Case> listCaseQuery = new List<Case>();
        Set<Id> setIdsCuentas = new Set<Id>();

        List<Case > listaCase = [SELECT Id, AccountId, CC_Oficina_Afectada_Lookup__c, CC_Oficina_Afectada_Lookup__r.CC_Tipo_Centro__c,
                                 CC_Oficina_Afectada_Lookup__r.ParentId, CC_Oficina_Afectada_Lookup__r.Parent.CC_Tipo_Centro__c,
                                 CC_Oficina_Afectada_Lookup__r.Parent.ParentId, CC_Oficina_Afectada_Lookup__r.Parent.Parent.CC_Tipo_Centro__c,
                                 CC_Oficina_Afectada_Lookup__r.Parent.Parent.ParentId, CC_Oficina_Afectada_Lookup__r.Parent.Parent.Parent.CC_Tipo_Centro__c
                                 FROM Case WHERE Id IN : caseID WITH SECURITY_ENFORCED];
        
        if(!listaCase.isEmpty()){
            for (Case listado : listaCase){
                if (listado.CC_Oficina_Afectada_Lookup__c != null){
                    if (Listado.CC_Oficina_Afectada_Lookup__r.CC_Tipo_Centro__c == 'DT'){
                        Case casoUpd = new Case();
                        casoUpd.Id = Listado.Id;
                        casoUpd.CC_Direccion_Territorial__c = listado.CC_Oficina_Afectada_Lookup__c;
                        listCase.add(casoUpd);
                    } else if (Listado.CC_Oficina_Afectada_Lookup__r.Parent.CC_Tipo_Centro__c == 'DT'){
                        Case casoUpd = new Case();
                        casoUpd.Id = Listado.Id;
                        casoUpd.CC_Direccion_Territorial__c = listado.CC_Oficina_Afectada_Lookup__r.ParentId;
                        listCase.add(casoUpd);
                    } else if (Listado.CC_Oficina_Afectada_Lookup__r.Parent.Parent.CC_Tipo_Centro__c == 'DT'){
                        Case casoUpd = new Case();
                        casoUpd.Id = Listado.Id;
                        casoUpd.CC_Direccion_Territorial__c = listado.CC_Oficina_Afectada_Lookup__r.Parent.ParentId;
                        listCase.add(casoUpd);
                    } else if (Listado.CC_Oficina_Afectada_Lookup__r.Parent.Parent.Parent.CC_Tipo_Centro__c == 'DT'){
                        Case casoUpd = new Case();
                        casoUpd.Id = Listado.Id;
                        casoUpd.CC_Direccion_Territorial__c = listado.CC_Oficina_Afectada_Lookup__r.Parent.Parent.ParentId;
                        listCase.add(casoUpd);
                    } else {
                        listCaseQuery.add(listado);
                        setIdsCuentas.add(listado.CC_Oficina_Afectada_Lookup__r.Parent.Parent.ParentId);
                    }
                }
            }

            if(!listCaseQuery.isEmpty()){
                Map<Id, Account> mapIdAccount = new Map<Id, Account>();
                List<Account> listaOficinas = [SELECT Id, CC_Tipo_Centro__c, 
                ParentId, Parent.CC_Tipo_Centro__c,
                Parent.ParentId, Parent.Parent.CC_Tipo_Centro__c, 
                Parent.Parent.ParentId, Parent.Parent.Parent.CC_Tipo_Centro__c
                FROM Account WHERE Id IN : setIdsCuentas WITH SECURITY_ENFORCED];

                for (Account listadoOF : listaOficinas){
                    mapIdAccount.put(listadoOF.Id, listadoOF);
                }

                if(!listaOficinas.isEmpty()){
                    for (Case listado : listCaseQuery) {
                        if (mapIdAccount.containsKey(listado.CC_Oficina_Afectada_Lookup__r.Parent.Parent.ParentId)) {
                            if (mapIdAccount.get(listado.CC_Oficina_Afectada_Lookup__r.Parent.Parent.ParentId).CC_Tipo_Centro__c == 'DT'){
                                Case casoUpd = new Case();
                                casoUpd.Id = Listado.Id;
                                casoUpd.CC_Direccion_Territorial__c = mapIdAccount.get(listado.CC_Oficina_Afectada_Lookup__r.Parent.Parent.ParentId).Id;
                                listCase.add(casoUpd);
                            } else if(mapIdAccount.get(listado.CC_Oficina_Afectada_Lookup__r.Parent.Parent.ParentId).Parent.CC_Tipo_Centro__c == 'DT'){
                                Case casoUpd = new Case();
                                casoUpd.Id = Listado.Id;
                                casoUpd.CC_Direccion_Territorial__c = mapIdAccount.get(listado.CC_Oficina_Afectada_Lookup__r.Parent.Parent.ParentId).ParentId;
                                listCase.add(casoUpd);
                            } else if(mapIdAccount.get(listado.CC_Oficina_Afectada_Lookup__r.Parent.Parent.ParentId).Parent.Parent.CC_Tipo_Centro__c == 'DT'){
                                Case casoUpd = new Case();
                                casoUpd.Id = Listado.Id;
                                casoUpd.CC_Direccion_Territorial__c = mapIdAccount.get(listado.CC_Oficina_Afectada_Lookup__r.Parent.Parent.ParentId).Parent.ParentId;
                                listCase.add(casoUpd);
                            } else if(mapIdAccount.get(listado.CC_Oficina_Afectada_Lookup__r.Parent.Parent.ParentId).Parent.Parent.Parent.CC_Tipo_Centro__c == 'DT'){
                                Case casoUpd = new Case();
                                casoUpd.Id = Listado.Id;
                                casoUpd.CC_Direccion_Territorial__c = mapIdAccount.get(listado.CC_Oficina_Afectada_Lookup__r.Parent.Parent.ParentId).Parent.Parent.ParentId;
                                listCase.add(casoUpd);
                            }
                        } 
                    }
                }
            }
        }
        // Update
        if (listCase.size() > 0){
            Database.SaveResult[] oResCom = Database.update(listCase, false);
        }
    }
}