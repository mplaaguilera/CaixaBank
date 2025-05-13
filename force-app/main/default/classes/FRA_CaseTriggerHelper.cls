public with sharing class FRA_CaseTriggerHelper {

    public static List<Case> filtrarCasosFRA(List<Case> lstCasos) {
        List<Case> casosFRA = new List<Case>();
        Id fraCasoRTId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');
        for (Case caso : lstCasos) {
            if (caso.recordTypeId == fraCasoRTId) {
                casosFRA.add(caso);
            }
        } 
        return casosFRA;
    }

    public static void informarCanalResolucion(List<Case> lstCasos) {
        for (Case caso : lstCasos) {
            if(!String.isBlank(caso.CC_Canal_Procedencia__c) && String.isBlank(caso.CC_Canal_Resolucion__c)){
                caso.CC_Canal_Resolucion__c = caso.CC_Canal_Procedencia__c;
            }
        }
    }

    public static void cambiarbuzonescolas(List<Case> lstCasos, Map<Id, Case> mapOldObj) {

       // Validaciones de seguridad
        if (lstCasos == null || lstCasos.isEmpty()) {
            return;
        }

        if (mapOldObj == null || mapOldObj.isEmpty()) {
            return;
        }

        // Lista de casos a actualizar
        List<Case> casosParaActualizar = new List<Case>();

        Id rtCasoFraude = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');

        List<Case> listaCasos = [SELECT CC_Canal_Procedencia__c,CC_Canal_Resolucion__c,Id, OwnerId, ContactId, Subject, Description, CC_Idioma__c, CC_Tipo_Contacto__c, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c, AccountId, Comments, CC_ContactoRelacionado__c, CC_Oficina__c, CC_MCC_Tematica__r.Name, CC_MCC_Motivo__c
        FROM Case WHERE RecordTypeId = :rtCasoFraude AND Id IN :lstCasos  ];

        Id colaFraudeNow = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'FRA_BuzonFraudeNow' WITH SECURITY_ENFORCED].Id;
        Id colaFraudeTarjetas = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'FRA_BuzonFraudeTarjetas' WITH SECURITY_ENFORCED].Id;
                    
        for (Case caso : listaCasos) {
            Case casoAntiguo = mapOldObj.get(caso.Id);
    
            if (casoAntiguo != null && casoAntiguo.CC_CasoRelacionado__c != null) {
                // Verificar si el OwnerId pasó de la cola UNO a la cola DOS
                if (casoAntiguo.OwnerId != colaFraudeNow  && caso.OwnerId == colaFraudeNow) {
                  
                    // Modificar los valores requeridos
                    caso.CC_Canal_Procedencia__c = 'Teléfono FRAUDE CaixaBankNow';
                    caso.CC_Canal_Resolucion__c = 'Buzón Fraude Now';
    
                    // Agregar el caso a la lista de actualización
                    casosParaActualizar.add(caso);
                }

                // Verificar si el OwnerId pasó de la cola UNO a la cola DOS
                if (casoAntiguo.OwnerId != colaFraudeTarjetas  && caso.OwnerId == colaFraudeTarjetas ) {
                   
                    // Modificar los valores requeridos
                    caso.CC_Canal_Procedencia__c = 'Teléfono FRAUDE Tarjetas Payments';
                    caso.CC_Canal_Resolucion__c = 'Buzón Fraude Tarjetas';
    
                    // Agregar el caso a la lista de actualización
                    casosParaActualizar.add(caso);
                }

            }else{
                return;
            }

        }

        // Realizar la actualización solo si hay cambios
        if (!casosParaActualizar.isEmpty()) {
                update casosParaActualizar;
                
        }
    }
}