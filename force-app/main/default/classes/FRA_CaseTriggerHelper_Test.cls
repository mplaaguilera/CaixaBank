@isTest
public with sharing class FRA_CaseTriggerHelper_Test {

    @isTest
    public static void testInformarCanalResolucion() {
        // User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()){
            Test.startTest();
            Case caso1 = new Case(
                RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente'),
                Subject = 'Test FRAUDE 1',
                Origin = 'Phone',
                CC_Idioma__c = 'es',
                CC_Canal_Procedencia__c = 'Teléfono FRAUDE CaixaBankNow',
                CC_Canal_Resolucion__c = 'Teléfono FRAUDE Canal Oficina'
            );
            insert caso1;
            Case caso2 = new Case(
                RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente'),
                Subject = 'Test FRAUDE 2',
                Origin = 'Phone',
                CC_Idioma__c = 'es',
                CC_Canal_Procedencia__c = 'Teléfono FRAUDE CaixaBankNow'
            );
            insert caso2;

            System.assertEquals('Teléfono FRAUDE Canal Oficina', [SELECT CC_Canal_Resolucion__c FROM Case WHERE Subject = 'Test FRAUDE 1'].CC_Canal_Resolucion__c);
            System.assertEquals('Teléfono FRAUDE CaixaBankNow', [SELECT CC_Canal_Resolucion__c FROM Case WHERE Subject = 'Test FRAUDE 2'].CC_Canal_Resolucion__c);
            Test.stopTest();
        }
    }

    

    @isTest
    public static void testCambiarBuzones2() {
        User uSup = FRA_TestDataFactory.usuarioAFRA();
        System.runAs(uSup){

        // Crear usuario de prueba
        User testUser = [SELECT Id,Profile.Name FROM User WHERE Profile.Name = 'FRA_Usuario_Caixabank' LIMIT 1];
        // Obtener IDs de colas
        Id colaFraudeNow = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'FRA_BuzonFraudeNow' LIMIT 1].Id;
        Id colaFraudeTarjetas = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'FRA_BuzonFraudeTarjetas' LIMIT 1].Id;
        List<Case> lista = new List<Case>();
        Case caso1 = new Case(
            RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente'),
            Subject = 'Test FRAUDE 1',
            Origin = 'Phone',
            CC_Idioma__c = 'es',
            CC_Canal_Procedencia__c = 'Teléfono FRAUDE CaixaBankNow',
            CC_Canal_Resolucion__c = 'Teléfono FRAUDE Canal Oficina'
        );
        lista.add(caso1);
        Case caso2 = new Case(
            RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente'),
            Subject = 'Test FRAUDE 2',
            Origin = 'Phone',
            CC_Idioma__c = 'es',
            CC_Canal_Procedencia__c = 'Teléfono FRAUDE CaixaBankNow',
            CC_Canal_Resolucion__c = 'Teléfono FRAUDE Canal Oficina'
        );
        lista.add(caso2);
        insert lista;

         // Crear un Map simulando el estado previo
         Map<Id, Case> mapOldObj = new Map<Id, Case>{
            caso1.Id => new Case(Id = caso1.Id, OwnerId = testUser.Id, CC_CasoRelacionado__c = caso2.Id ) // Estado antes del cambio
        };

        Test.startTest();
        // Simular el cambio de propietario a la colaFraudeNow
        caso1.OwnerId = colaFraudeNow;
        update caso1;

         // Ejecutar el método a probar
         List<Case> casos = [SELECT Id, OwnerId, CC_Canal_Procedencia__c, CC_Canal_Resolucion__c FROM Case WHERE Id = :caso1.Id];
         FRA_CaseTriggerHelper.cambiarbuzonescolas(casos, mapOldObj);

         System.assertEquals('Buzón FRAUDE Now', [SELECT CC_Canal_Resolucion__c FROM Case WHERE Id = :caso1.Id]?.CC_Canal_Resolucion__c);
 
        Test.stopTest();
    }

    }

    @isTest
    public static void testCambiarBuzones3() {
       
        System.runAs(FRA_TestDataFactory.usuarioAFRA()){
       
        // Crear usuario de prueba
        User testUser = [SELECT Id,Profile.NAME FROM User WHERE Profile.Name = 'FRA_Usuario_Caixabank' LIMIT 1];
        // Obtener IDs de colas
        Id colaFraudeNow = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'FRA_BuzonFraudeNow' LIMIT 1].Id;
        Id colaFraudeTarjetas = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'FRA_BuzonFraudeTarjetas' LIMIT 1].Id;
        List<Case> lista = new List<Case>();
        Case caso1 = new Case(
            RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente'),
            Subject = 'Test FRAUDE 1',
            Origin = 'Phone',
            CC_Idioma__c = 'es',
            CC_Canal_Procedencia__c = 'Teléfono FRAUDE CaixaBankNow',
            CC_Canal_Resolucion__c = 'Teléfono FRAUDE Canal Oficina'
        );
        lista.add(caso1);

        Case caso2 = new Case(
            RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente'),
            Subject = 'Test FRAUDE 1',
            Origin = 'Phone',
            CC_Idioma__c = 'es',
            CC_Canal_Procedencia__c = 'Teléfono FRAUDE CaixaBankNow',
            CC_Canal_Resolucion__c = 'Teléfono FRAUDE Canal Oficina'
        );
        lista.add(caso2);
            insert lista;
        // Crear un Map simulando el estado previo
        Map<Id, Case> mapOldObj = new Map<Id, Case>{
            caso1.Id => new Case(Id = caso1.Id, OwnerId = testUser.Id, CC_CasoRelacionado__c = caso2.Id) // Estado antes del cambio
        };
        
        Test.startTest();
        // Simular el cambio de propietario a la colaFraudeNow
        caso1.OwnerId = colaFraudeTarjetas;
        update caso1;

         // Ejecutar el método a probar
         List<Case> casos = [SELECT Id, OwnerId, CC_Canal_Procedencia__c, CC_Canal_Resolucion__c FROM Case WHERE Id = :caso1.Id];
         FRA_CaseTriggerHelper.cambiarbuzonescolas(casos, mapOldObj);
         

            System.assertEquals('Buzón FRAUDE Tarjetas', [SELECT CC_Canal_Resolucion__c FROM Case WHERE Id = :caso1.Id]?.CC_Canal_Resolucion__c);
            
        
        Test.stopTest();
    
        }
    }

    





}