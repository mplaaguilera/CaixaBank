public with sharing class FRA_Caracteristicas_Controller {

    @AuraEnabled(cacheable=true)
    public static List<CC_Caracteristica_Detalle__c> conseguirCaracteristica(Id idCliente) {
        String sObjectName = idCliente.getSObjectType().getDescribe().getName();
        Id idRegistro;
        String recordTypeContact;

        if (sObjectName == 'Opportunity') {
            // Consulta optimizada con LIMIT 1
            List<Opportunity> oportunidad = [SELECT CSBD_Contact__c, CSBD_Contact__r.RecordType.DeveloperName 
                                             FROM Opportunity 
                                             WHERE Id = :idCliente
                                             LIMIT 1];

            if (!oportunidad.isEmpty()) {
                Opportunity mioportunidad = oportunidad[0];
                idRegistro = mioportunidad.CSBD_Contact__c;
                recordTypeContact = mioportunidad.CSBD_Contact__r.RecordType.DeveloperName;
            }

        } else if (sObjectName == 'Case') {
            // Consulta optimizada con LIMIT 1
            List<Case> casos = [SELECT ContactId, Contact.RecordType.DeveloperName
                                FROM Case 
                                WHERE Id = :idCliente
                                LIMIT 1];

            if (!casos.isEmpty()) {
                Case micaso = casos[0];
                idRegistro = micaso.ContactId;
                recordTypeContact = micaso.Contact.RecordType.DeveloperName;
            }

        } else if (sObjectName == 'Contact') {
            // Consulta optimizada con LIMIT 1
            List<Contact> contactos = [SELECT RecordType.DeveloperName
                                       FROM Contact 
                                       WHERE Id = :idCliente
                                       LIMIT 1];

            if (!contactos.isEmpty()) {
                Contact micontacto = contactos[0];
                idRegistro = idCliente;
                recordTypeContact = micontacto.RecordType.DeveloperName;
            }
        }

        if (idRegistro != null) {
            if (recordTypeContact == 'CC_Empleado') {
                return [SELECT CC_Caracteristica__r.CC_Avisar_agente__c, CC_Caracteristica__r.Id, Name, 
                               CC_Caracteristica__r.Name, CC_Caracteristica__r.CC_Descripcion__c, 
                               CC_Caracteristica__r.CC_URL__c
                        FROM CC_Caracteristica_Detalle__c 
                        WHERE CC_Empleado__c = :idRegistro 
                          AND CC_Caracteristica__r.CC_Activo__c = true 
                          AND CC_Caracteristica__r.OS_Negocio__c = 'FRA' 
                        ORDER BY CC_Caracteristica__r.CC_Prioridad__c];
            } else {
                return [SELECT CC_Caracteristica__r.CC_Avisar_agente__c, CC_Caracteristica__r.Id, Name, 
                               CC_Caracteristica__r.CC_Activo__c, CC_Caracteristica__r.Name, 
                               CC_Caracteristica__r.CC_Descripcion__c, CC_Caracteristica__r.CC_URL__c
                        FROM CC_Caracteristica_Detalle__c 
                        WHERE CC_Cliente__c = :idRegistro 
                          AND CC_Caracteristica__r.CC_Activo__c = true  
                          AND CC_Caracteristica__r.OS_Negocio__c = 'FRA' 
                        ORDER BY CC_Caracteristica__r.CC_Prioridad__c];
            }
        } else {
            return new List<CC_Caracteristica_Detalle__c>();
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_Caracteristica_Detalle__c> conseguirCaracteristicaCuenta(Id idCaso) {
        String recordTypeAccount;
        Id idRegistro;

        if (idCaso != null) {
            // Consulta optimizada con LIMIT 1
            List<Case> cases = [SELECT AccountId, Account.RecordType.DeveloperName 
                                FROM Case 
                                WHERE Id = :idCaso 
                                  AND ContactId != null 
                                LIMIT 1];

            if (!cases.isEmpty()) {
                Case micaso = cases[0];
                idRegistro = micaso.AccountId;
                recordTypeAccount = micaso.Account.RecordType.DeveloperName;
            }
        }

        if (idRegistro != null) {
            if (recordTypeAccount == 'CC_CentroCaixaBank') {
                return [SELECT CC_Caracteristica__r.CC_Avisar_agente__c, CC_Caracteristica__r.Id, Name, 
                               CC_Caracteristica__r.Name, CC_Caracteristica__r.CC_Descripcion__c, 
                               CC_Caracteristica__r.CC_URL__c
                        FROM CC_Caracteristica_Detalle__c 
                        WHERE CC_Centro_CaixaBank__c = :idRegistro 
                          AND CC_Caracteristica__r.CC_Activo__c = true 
                          AND CC_Caracteristica__r.OS_Negocio__c = 'FRA' 
                        ORDER BY CC_Caracteristica__r.CC_Prioridad__c];
            } else {
                return [SELECT CC_Caracteristica__r.CC_Avisar_agente__c, CC_Caracteristica__r.Id, Name, 
                               CC_Caracteristica__r.CC_Activo__c, CC_Caracteristica__r.Name, 
                               CC_Caracteristica__r.CC_Descripcion__c, CC_Caracteristica__r.CC_URL__c
                        FROM CC_Caracteristica_Detalle__c 
                        WHERE CC_Cuenta__c = :idRegistro 
                          AND CC_Caracteristica__r.CC_Activo__c = true 
                          AND CC_Caracteristica__r.OS_Negocio__c = 'FRA' 
                        ORDER BY CC_Caracteristica__r.CC_Prioridad__c];
            }
        } else {
            return new List<CC_Caracteristica_Detalle__c>();
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_Caracteristica_Detalle__c> conseguirCaracteristicaContactoCaso(Id idCaso) {
        String recordTypeAccount;
        Id idRegistro;

        if (idCaso != null) {
            // Consulta optimizada con LIMIT 1
            List<Case> cases = [SELECT ContactId, Contact.AccountId, Contact.RecordType.DeveloperName 
                                FROM Case 
                                WHERE Id = :idCaso 
                                  AND ContactId != null 
                                LIMIT 1];

            if (!cases.isEmpty()) {
                Case micaso = cases[0];
                idRegistro = micaso.ContactId;
                recordTypeAccount = micaso.Contact.RecordType.DeveloperName;
            }
        }

        if (idRegistro != null) {
            return [SELECT CC_Caracteristica__r.CC_Avisar_agente__c, CC_Caracteristica__r.Id, Name, 
                           CC_Caracteristica__r.CC_Activo__c, CC_Caracteristica__r.Name, 
                           CC_Caracteristica__r.CC_Descripcion__c, CC_Caracteristica__r.CC_URL__c
                    FROM CC_Caracteristica_Detalle__c 
                    WHERE CC_Cliente__c = :idRegistro 
                      AND CC_Caracteristica__r.CC_Activo__c = true 
                      AND CC_Caracteristica__r.OS_Negocio__c = 'FRA' 
                    ORDER BY CC_Caracteristica__r.CC_Prioridad__c];
        } else {
            return new List<CC_Caracteristica_Detalle__c>();
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_Caracteristica__c> conseguirCaracteristicasFRADeCuenta() {
        return [
            SELECT Id, Name,RecordType.Name   FROM CC_Caracteristica__c WHERE OS_Negocio__c= 'FRA' AND RecordType.DeveloperName ='CC_Cliente_Cuenta' AND CC_Activo__c =true ORDER BY Name

        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_Caracteristica__c> conseguirCaracteristicasFRADeContacto() {
        return [
            SELECT Id, Name,RecordType.Name   FROM CC_Caracteristica__c WHERE OS_Negocio__c= 'FRA' AND RecordType.DeveloperName ='CC_Cliente_Contacto' AND CC_Activo__c =true ORDER BY Name

        ];
    }

    @AuraEnabled
    public static void asociarCaracteristicaCuenta(Id idCaso, Id idCaracteristica) {
        Case caso = [SELECT AccountId FROM Case WHERE Id = :idCaso LIMIT 1];
        Id accountId = caso.AccountId;

        if (accountId != null && idCaracteristica != null) {
            CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c();
            
            detalle.CC_Cuenta__c = accountId; 
            detalle.CC_Caracteristica__c = idCaracteristica;  

            insert detalle;
        }
    }

    @AuraEnabled
    public static void asociarCaracteristicaContacto(Id idCaso, Id idCaracteristica) {
        Case caso = [SELECT contactId FROM Case WHERE Id = :idCaso LIMIT 1];
        Id contactId = caso.ContactId;

        if (contactId != null && idCaracteristica != null) {
            CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c();
            
            detalle.CC_Cliente__c = contactId; 
            detalle.CC_Caracteristica__c = idCaracteristica;  

            insert detalle;
        }
    }
       
    }