public with sharing class HDT_Caracteristica {
    
    @AuraEnabled(cacheable=true)
    public static List<CC_Caracteristica_Detalle__c> conseguirCaracteristica(Id idCliente) {

        String sObjectName = idCliente.getSObjectType().getDescribe().getName();
        Id idRegistro;
        String recordTypeContact;

        if (sObjectName == 'Opportunity') {
            Opportunity oportunidad = [SELECT CSBD_Contact__c, CSBD_Contact__r.RecordType.DeveloperName FROM Opportunity WHERE Id = :idCliente];
            idRegistro = oportunidad.CSBD_Contact__c;
            recordTypeContact = oportunidad.CSBD_Contact__r.RecordType.DeveloperName;
        
        } else if (sObjectName == 'Case') {
            Case caso = [SELECT ContactId, Contact.RecordType.DeveloperName FROM Case WHERE Id = :idCliente];
            idRegistro = caso.ContactId;
            recordTypeContact = caso.Contact.RecordType.DeveloperName;
        } else if (sObjectName == 'Contact') {
            Contact contacto = [SELECT RecordType.DeveloperName FROM Contact WHERE Id = :idCliente];
            idRegistro = idCliente;
            recordTypeContact = contacto.RecordType.DeveloperName;
        }

        if (idRegistro != null) {
            if (recordTypeContact == 'CC_Empleado') {
                return [SELECT CC_Caracteristica__r.Id, Name, CC_Caracteristica__r.Name, CC_Caracteristica__r.CC_Descripcion__c, CC_Caracteristica__r.CC_URL__c
                        FROM CC_Caracteristica_Detalle__c WHERE CC_Empleado__c = :idRegistro AND CC_Caracteristica__r.CC_Activo__c = true ORDER BY CC_Caracteristica__r.CC_Prioridad__c];
            } else {
                List<CC_Caracteristica_Detalle__c> retorno = [SELECT CC_Caracteristica__r.Id, Name, CC_Caracteristica__r.CC_Activo__c, CC_Caracteristica__r.Name, CC_Caracteristica__r.CC_Descripcion__c, CC_Caracteristica__r.CC_URL__c
                                                                FROM CC_Caracteristica_Detalle__c WHERE CC_Cliente__c = :idRegistro AND CC_Caracteristica__r.CC_Activo__c = true ORDER BY CC_Caracteristica__r.CC_Prioridad__c];
                
                return retorno;
            }
        } else {
            //Si no se ha encontrado el registro se retorna una lista vacía de características
            return new List<CC_Caracteristica_Detalle__c>();
        }
    }
    
    @testvisible
    @AuraEnabled(cacheable=true)
    public static List<CC_Caracteristica_Detalle__c> conseguirCaracteristicaCuenta(Id idCaso) {

        String recordTypeAccount;
        Id idRegistro;
        if (idCaso != null) {
            Case caso = [SELECT AccountId, Account.RecordType.DeveloperName FROM Case WHERE Id = :idCaso];
            idRegistro = caso.AccountId;
            recordTypeAccount = caso.Account.RecordType.DeveloperName;            
        }
        
        if (idRegistro != null) {
            if (recordTypeAccount == 'CC_CentroCaixaBank') {
                return [SELECT CC_Caracteristica__r.Id, Name, CC_Caracteristica__r.Name, CC_Caracteristica__r.CC_Descripcion__c, CC_Caracteristica__r.CC_URL__c
                        FROM CC_Caracteristica_Detalle__c WHERE CC_Centro_CaixaBank__c = :idRegistro AND CC_Caracteristica__r.CC_Activo__c = true ORDER BY CC_Caracteristica__r.CC_Prioridad__c];
            } else {
                return [SELECT CC_Caracteristica__r.Id, Name, CC_Caracteristica__r.CC_Activo__c, CC_Caracteristica__r.Name, CC_Caracteristica__r.CC_Descripcion__c, CC_Caracteristica__r.CC_URL__c
                                                                FROM CC_Caracteristica_Detalle__c WHERE CC_Cuenta__c  = :idRegistro AND CC_Caracteristica__r.CC_Activo__c = true ORDER BY CC_Caracteristica__r.CC_Prioridad__c];

            }
        } else {
            //Si no se ha encontrado el registro se retorna una lista vacía de características
            return new List<CC_Caracteristica_Detalle__c>();
        }
        
    }

    @AuraEnabled
    public static List<String> getAvisosCaracteristicas(String sID) {
        List<String> avisos = new List<String>();
        List<LiveChatTranscript> oChat = [SELECT CC_NumPerso__c FROM LiveChatTranscript WHERE Id = :sID AND CC_NumPerso__c != null];

        if (!oChat.isEmpty()) {
            List<Contact> oContact = [SELECT Id FROM Contact WHERE CC_NumPerso__c = :oChat[0].CC_NumPerso__c];
            if (!oContact.isEmpty()) {
                List<CC_Caracteristica_Detalle__c> listDetalle = [SELECT CC_Caracteristica__r.Id, Name, CC_Caracteristica__r.Name, CC_Caracteristica__r.CC_Descripcion__c, CC_Caracteristica__r.CC_URL__c
                                                                    FROM CC_Caracteristica_Detalle__c
                                                                    WHERE CC_Cliente__c =: oContact[0].Id AND CC_Caracteristica__r.CC_Activo__c = true AND CC_Caracteristica__r.CC_Avisar_agente__c = true
                                                                    ORDER BY CC_Caracteristica__r.CC_Prioridad__c];
                String aviso;
                if (listDetalle.size() > 0) {
                    // Generamos la lista de los avisos de características a mostrar (máximo 3 avisos)
                    for (Integer i = 0; i < 3 && i < listDetalle.size(); i++) {
                        CC_Caracteristica_Detalle__c caracteristicaDetalle = listDetalle[i];
                        aviso = addLineBreaks(caracteristicaDetalle.CC_Caracteristica__r.CC_Descripcion__c);
                        avisos.add(aviso);
                    }
                    // En caso de existir más de 3 características, en el tercer aviso inidicamos que el resto puede consultarse desde la pestaña
                    if (listDetalle.size() > 3) {
                        avisos[avisos.size() - 1] = 'Puede ver el resto de las características accediendo\na la pestaña correspondiente.';
                    }
                }
            }
        }
        return avisos;
    }
    
    @testvisible
    public static String addLineBreaks(String originalString) {
        String modifiedString = '';
        String line = '';
        for (Integer i = 0; i < originalString.length(); i++) {
            line += originalString.substring(i, i + 1);
            if (line.length() > 50 && originalString.substring(i, i + 1) == ' ') {
                modifiedString += line + '\n';
                line = '';
            }

            if (i == originalString.length() - 1) {
                modifiedString += line;
            }
        }
        return modifiedString;
    }
    
    @AuraEnabled
    public static List<CC_Caracteristica_Detalle__c> getCaracteristicasConAviso(String sID) {
        List<CC_Caracteristica_Detalle__c> caracteristicasConAviso = new List<CC_Caracteristica_Detalle__c>();
        List<LiveChatTranscript> oChat = [SELECT CC_NumPerso__c FROM LiveChatTranscript WHERE Id = :sID];
        if (!oChat.isEmpty()) {
            List<Contact> oContact = [SELECT Id FROM Contact WHERE CC_NumPerso__c = :oChat[0].CC_NumPerso__c];
            if (!oContact.isEmpty()) {
                caracteristicasConAviso = [SELECT CC_Caracteristica__r.Id, Name, CC_Caracteristica__r.Name, CC_Caracteristica__r.CC_Descripcion__c, CC_Caracteristica__r.CC_Prioridad__c
                                            FROM CC_Caracteristica_Detalle__c 
                                            WHERE CC_Cliente__c = :oContact[0].Id
                                            AND CC_Caracteristica__r.CC_Avisar_agente__c = true AND CC_Caracteristica__r.CC_Activo__c = true
                                            ORDER BY CC_Caracteristica__r.CC_Prioridad__c];
            }
        }
        return caracteristicasConAviso;
    }
    
    @InvocableMethod
    public static void RelacionarCaso(List<Id> recordId) {
        List<Case> casos = [SELECT Id, ContactId, Contact.AccountId FROM Case WHERE Id IN :recordId AND ContactId != null];
        
        List<CC_Caracteristica_Case__c> caracteristicasToCreate = new List<CC_Caracteristica_Case__c>();
        
        Map<Id, Set<Id>> idsWithCases = new Map<Id, Set<Id>>();        
        for (Case caso : casos) {
            Set<Id> casosLoop = idsWithCases.get(caso.ContactId);
            if (casosLoop == null) {
                Set<Id> casosMap = new Set<Id>{caso.Id};
                idsWithCases.put(caso.ContactId, casosMap);
            } else {
                casosLoop.add(caso.Id);
            }
            
            if (caso.Contact.AccountId != null) {
                Set<Id> casosLoopAcc = idsWithCases.get(caso.Contact.AccountId);
                if (casosLoopAcc == null) {
                    Set<Id> casosMapAcc = new Set<Id>{caso.Id};
                        idsWithCases.put(caso.Contact.AccountId, casosMapAcc);
                } else {
                    casosLoopAcc.add(caso.Id);
                }
            }
        }

        if (idsWithCases.size() == 0) {
            return;
        }
        List<CC_Caracteristica_Detalle__c> detallesList = [SELECT CC_Caracteristica__c, CC_Cliente__c, CC_Empleado__c, CC_Cuenta__c, CC_Centro_CaixaBank__c
                                                            FROM CC_Caracteristica_Detalle__c 
                                                            WHERE (CC_Cliente__c IN :idsWithCases.keySet() 
                                                            OR CC_Empleado__c IN :idsWithCases.keySet()
                                                            OR CC_Cuenta__c IN :idsWithCases.keySet()
                                                            OR CC_Centro_CaixaBank__c IN :idsWithCases.keySet())
                                                            AND CC_Caracteristica__r.CC_Activo__c = true
                                                            AND CC_Caracteristica__r.OS_Negocio__c = 'HDT'];
        
        
        if (!detallesList.isEmpty()) {
            for (CC_Caracteristica_Detalle__c detalle : detallesList) {
                Id carContactId;
                if (detalle.CC_Cliente__c != null) {
                    carContactId = detalle.CC_Cliente__c;
                } else if (detalle.CC_Empleado__c != null) {
                    carContactId = detalle.CC_Empleado__c;
                } else if (detalle.CC_Cuenta__c != null) {
                    carContactId = detalle.CC_Cuenta__c;
                } else if (detalle.CC_Centro_CaixaBank__c != null) {
                    carContactId = detalle.CC_Centro_CaixaBank__c;
                }

                if (carContactId != null) {
                    for (Id casoIdToCreate : idsWithCases.get(carContactId)) {
                        CC_Caracteristica_Case__c caracteristicaCaso = new CC_Caracteristica_Case__c();        
                        caracteristicaCaso.CC_Case__c = casoIdToCreate;
                        caracteristicaCaso.CC_Caracteristica__c = detalle.CC_Caracteristica__c;
                        //caracteristicaCaso.cc = 'bla blaa';
                        caracteristicasToCreate.add(caracteristicaCaso);
                    }
                }
            }
        }       
        
        if (!caracteristicasToCreate.isEmpty()) {
            insert caracteristicasToCreate;
        }
        
    }
}