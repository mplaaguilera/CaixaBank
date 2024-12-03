@istest
public with sharing class SAC_SeleccionDireccionRespuesta_Test {
    @TestSetup
    static void makeData(){

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];

        //usuario
        User user = new User(
            Username = 'admin123@testcaixa1.com',
            Email = 'email@test.com',
            LastName = 'Usuario Test',
            ProfileId = profileId,
            Alias = 'alias',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'es_ES',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            isActive = true,
            userRole = uRole
        );
        Database.insert(user);

        List<Account> listaCuentas = new List<Account>();
        Account cuenta = new Account(Name = 'Cuenta', CC_Email__c = 'test@test.com', recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(), OwnerId = user.Id);
        listaCuentas.add(cuenta);

        Account cuenta2 = new Account(Name = 'Cuenta2', CC_Email__c = 'test@test.com', recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SAC_NoCliente').getRecordTypeId(), OwnerId = user.Id);
        listaCuentas.add(cuenta2);

        Database.insert(listaCuentas);

        List<Case> listaCasos = new List<Case>();

        Case casoReclamacion = new Case();
        casoReclamacion.Subject = 'TestRec';
        casoReclamacion.Origin = 'Otros';
        casoReclamacion.Status = 'SAC_001';
        casoReclamacion.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        casoReclamacion.AccountId= cuenta.id;   
        casoReclamacion.OwnerId = user.Id;  
        listaCasos.add(casoReclamacion);

        Case casoReclamacion2 = new Case();
        casoReclamacion2.Subject = 'Caso2';
        casoReclamacion2.Origin = 'Otros';
        casoReclamacion2.Status = 'SAC_001';
        casoReclamacion2.Origin = 'SAC_CartaPostal';
        casoReclamacion2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        casoReclamacion2.AccountId= cuenta.id;  
        casoReclamacion2.OwnerId = user.Id;     
        listaCasos.add(casoReclamacion2);

        Case casoReclamacion3 = new Case();
        casoReclamacion3.Subject = 'Caso3';
        casoReclamacion3.Origin = 'Otros';
        casoReclamacion3.Status = 'SAC_001';
        casoReclamacion3.Origin = 'SAC_CXBNow';
        casoReclamacion3.SuppliedEmail = 'una@test.com';
        casoReclamacion3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();    
        casoReclamacion3.OwnerId = user.Id;  
        listaCasos.add(casoReclamacion3);

        Case casoReclamacion4 = new Case();
        casoReclamacion4.Subject = 'Caso4';
        casoReclamacion4.Origin = 'Otros';
        casoReclamacion4.Status = 'SAC_001';
        casoReclamacion4.Origin = 'SAC_CartaPostal';
        casoReclamacion4.SuppliedEmail = 'una@test.com';
        casoReclamacion4.SAC_DireccionPostalNotificacion__c='Direccion test';
        casoReclamacion4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId(); 
        casoReclamacion4.AccountId= cuenta2.id;    
        casoReclamacion4.OwnerId = user.Id;  
        listaCasos.add(casoReclamacion4);

        Case casoReclamacion5 = new Case();
        casoReclamacion5.Subject = 'Caso5';
        casoReclamacion5.Origin = 'Otros';
        casoReclamacion5.Status = 'SAC_001';
        casoReclamacion5.Origin = 'Otros';
        casoReclamacion5.SuppliedEmail = 'una@test.com';
        casoReclamacion5.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();    
        casoReclamacion5.OwnerId = user.Id;  
        listaCasos.add(casoReclamacion5);

        Case casoReclamacion6 = new Case();
        casoReclamacion6.Subject = 'Caso6';
        casoReclamacion6.Origin = 'Otros';
        casoReclamacion6.Status = 'SAC_001';
        casoReclamacion6.Origin = 'Otros';
        casoReclamacion6.SuppliedEmail = 'una@test.com';
        casoReclamacion6.CC_Canal_Respuesta__c = 'SAC_CartaPostal';
        casoReclamacion6.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();    
        casoReclamacion6.OwnerId = user.Id;  
        listaCasos.add(casoReclamacion6);

        Case casoReclamacion7 = new Case();
        casoReclamacion7.Subject = 'Caso7';
        casoReclamacion7.Origin = 'SAC_FormularioOficina';
        casoReclamacion7.Status = 'SAC_001';
        casoReclamacion7.CC_Canal_Respuesta__c = 'SAC_CartaPostal';
        casoReclamacion7.SAC_DireccionPostalNotificacion__c='Direccion test carta postal';
        casoReclamacion7.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();    
        casoReclamacion7.OwnerId = user.Id;  
        listaCasos.add(casoReclamacion7);

        Database.insert(listaCasos);

    }
    @istest
    static void setCanalRespuestaTest() {
        User usuarioGeneral = [SELECT id From User Where Username = 'admin123@testcaixa1.com' AND isActive = true Limit 1];

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarioGeneral.id);       
        Database.insert(psa);

        Case caso = [SELECT id, OS_Email__c FROM Case WHERE Subject = 'TestRec'];
        caso.OS_Email__c = 'caso@caso.com';

        Case caso2 = new Case();
       
        System.runAs(usuarioGeneral) {
            Test.startTest();
            Database.update(caso);
            caso2 = [SELECT id, OS_Email__c FROM Case WHERE Subject = 'TestRec'];
            Test.stopTest();
        }
        
        System.assertNotEquals(caso2.OS_Email__c, null, 'No se ha cambiado el email');
    }
    @istest
    static void setCanalRespuestaTest2() {
        User usuarioGeneral = [SELECT id From User Where Username = 'admin123@testcaixa1.com' AND isActive = true Limit 1];

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarioGeneral.id);       
        Database.insert(psa);

        Case caso = [SELECT id, OS_Email__c FROM Case WHERE Subject = 'Caso2'];
        caso.SAC_DireccionPostal__c = 'direccion';

        System.runAs(usuarioGeneral) {
            Test.startTest();
            Database.update(caso);
            Test.stopTest();
        }     

        Case caso2 = [SELECT id, OS_Email__c, SAC_DireccionPostal__c FROM Case WHERE Subject = 'TestRec'];
        System.assertNotEquals(caso2.SAC_DireccionPostal__c, caso.SAC_DireccionPostal__c, 'No se ha cambiado el SAC_DireccionPostal__c');
    }
    @istest
    static void setCanalRespuestaTest3() {
        User usuarioGeneral = [SELECT id From User Where Username = 'admin123@testcaixa1.com' AND isActive = true Limit 1];

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarioGeneral.id);       
        Database.insert(psa);

        Account cuenta = [SELECT id, recordTypeId FROM Account WHERE Name = 'Cuenta2'];
        cuenta.CC_Email__c = 'email@test.com';
        Case caso = [SELECT id, Origin, Account.CC_Email__c, OS_Email__c FROM Case WHERE Subject = 'Caso3'];
        caso.AccountId=  cuenta.id;

        SAC_SeleccionDireccionRespuesta.objetoWrapper resultado;

        System.runAs(usuarioGeneral) {
            Test.startTest();
            Database.update(cuenta);
            resultado = SAC_SeleccionDireccionRespuesta.setParaEmail(caso, cuenta.recordTypeId);
            Test.stopTest();
        }     

       System.assertNotEquals(resultado, Null, 'No se ha recuperado el Objeto Wrapper');
    }

    @istest
    static void setCanalRespuestaTest4() {
        User usuarioGeneral = [SELECT id From User Where Username = 'admin123@testcaixa1.com' AND isActive = true Limit 1];

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarioGeneral.id);       
        Database.insert(psa);
        
        Account cuenta = [SELECT id, recordTypeId FROM Account WHERE Name = 'Cuenta2'];
        Case caso = [SELECT id, Origin, Account.CC_Email__c, OS_Email__c, SAC_DireccionPostalNotificacion__c FROM Case WHERE Subject = 'Caso4'];

        SAC_SeleccionDireccionRespuesta.objetoWrapper resultado;

        System.runAs(usuarioGeneral) {
            Test.startTest();
            Database.update(cuenta);
            resultado = SAC_SeleccionDireccionRespuesta.setParaEmail(caso, cuenta.recordTypeId);
            Test.stopTest();
        }     

        System.assertNotEquals(resultado, Null, 'No se ha recuperado el Objeto Wrapper');
    }

    @istest
    static void setCanalRespuestaTest5() {
        User usuarioGeneral = [SELECT id From User Where Username = 'admin123@testcaixa1.com' AND isActive = true Limit 1];

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarioGeneral.id);       
        Database.insert(psa);

        Account cuenta = [SELECT id, recordTypeId FROM Account WHERE Name = 'Cuenta2'];
        Case caso = [SELECT id, Origin, Account.CC_Email__c, OS_Email__c, SAC_DireccionPostalNotificacion__c,SuppliedEmail FROM Case WHERE Subject = 'Caso5'];

        SAC_SeleccionDireccionRespuesta.objetoWrapper resultado;

        System.runAs(usuarioGeneral) {
            Test.startTest();
            Database.update(cuenta);
            resultado = SAC_SeleccionDireccionRespuesta.setParaEmail(caso, cuenta.recordTypeId);
            Test.stopTest();
        }     

        System.assertNotEquals(resultado, Null, 'No se ha recuperado el Objeto Wrapper');
    }
    @istest
    static void setCanalRespuestaTest6() {
        User usuarioGeneral = [SELECT id From User Where Username = 'admin123@testcaixa1.com' AND isActive = true Limit 1];

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarioGeneral.id);       
        Database.insert(psa);

        SAC_SeleccionDireccionRespuesta.objetoWrapper resultado;

        System.runAs(usuarioGeneral) {
            Test.startTest();
            Account cuenta = [SELECT id, recordTypeId FROM Account WHERE Name = 'Cuenta'];
            cuenta.CC_Email__c = 't@t.t';
            Database.update(cuenta);
            Case caso = [SELECT id, Origin, Account.CC_Email__c, OS_Email__c, SAC_DireccionPostalNotificacion__c,SuppliedEmail FROM Case WHERE Subject = 'Caso3'];
            caso.AccountId = cuenta.Id;
            Database.update(caso);

            Database.update(cuenta);
            resultado = SAC_SeleccionDireccionRespuesta.setParaEmail(caso, cuenta.recordTypeId);
            Test.stopTest();
        }     

        System.assertNotEquals(resultado, Null, 'No se ha recuperado el Objeto Wrapper');
    }

    @istest
    static void setCanalRespuestaTest7() {
        User usuarioGeneral = [SELECT id From User Where Username = 'admin123@testcaixa1.com' AND isActive = true Limit 1];

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarioGeneral.id);       
        Database.insert(psa);

        Account cuenta = [SELECT id, recordTypeId FROM Account WHERE Name = 'Cuenta'];
        Case caso = [SELECT id, Origin, Account.CC_Email__c, OS_Email__c, SAC_DireccionPostalNotificacion__c,SuppliedEmail FROM Case WHERE Subject = 'Caso7'];

        SAC_SeleccionDireccionRespuesta.objetoWrapper resultado;

        System.runAs(usuarioGeneral) {
            Test.startTest();
            Database.update(cuenta);
            resultado = SAC_SeleccionDireccionRespuesta.setParaEmail(caso, cuenta.recordTypeId);
            Test.stopTest();
        }     

        System.assertNotEquals(resultado, Null, 'No se ha recuperado el Objeto Wrapper');
    }

    @isTest
    static void getParaEmailTest() {
        User usuarioGeneral = [SELECT id From User Where Username = 'admin123@testcaixa1.com' AND isActive = true Limit 1];

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarioGeneral.id);       
        Database.insert(psa);

        String resultado;

        System.runAs(usuarioGeneral) {
            Test.startTest();
            Account cuenta = [SELECT id, recordTypeId FROM Account WHERE Name = 'Cuenta'];
            cuenta.CC_Email__c = 't@t.t';
            Database.update(cuenta);
            Case caso = [SELECT id, CC_Canal_Respuesta__c, OS_Email__c, SAC_DireccionPostalNotificacion__c, SuppliedEmail  FROM Case WHERE Subject = 'Caso6'];
            caso.AccountId = cuenta.Id;
            Database.update(caso);

            Database.update(cuenta);
            resultado = SAC_SeleccionDireccionRespuesta.getParaEmail(caso, cuenta.recordTypeId);
            Test.stopTest();
        }     

        System.assertNotEquals(resultado, Null, 'No se ha recuperado el Objeto Wrapper');
    }
}