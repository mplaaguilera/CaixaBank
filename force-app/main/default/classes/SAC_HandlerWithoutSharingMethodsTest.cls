/*****************************************************************
 * Name: SAC_HandlerWithOutSharingMethodsTest
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Clase de test de SAC_HandlerWithoutSharingMethods
 * 
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US866223         Alex perez     15/04/2024   Creación
*****************************************************************/
@isTest
private class SAC_HandlerWithoutSharingMethodsTest {

    @TestSetup
    static void makeData(){

        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];     
        Database.insert(usuarioAdmin);

        User usuario;
        System.runAs(usuarioAdmin) {
            //Usuario SAC General
            usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            usuario.Username = 'ustestesteo@test.com';      
            Database.insert(usuario);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuario.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }

        list<Account> cuentas;
        System.runAs(usuario) {
            cuentas = SAC_TestDataFactory.crearCuentasNoClientePA(2);
        }

        insert cuentas;

        list<case> reclamaciones = new list<case>();
  
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl.put('AccountId', cuentas[0].Id);
        camposRecl.put('SAC_TipoConsumidor__c', 'No');
        camposRecl.put('OwnerId', usuario.id);

        case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        reclamaciones.add(reclamacion);

        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Description', 'prueba');
        camposRecl2.put('Status', 'Activo');
        camposRecl2.put('Origin', 'Otros');
        camposRecl2.put('CC_Idioma__c', 'es');
        camposRecl2.put('CC_Tipo_Contacto__c', 'Consulta');
        camposRecl2.put('CC_Tipo_Cliente__c', 'Cliente');
        camposRecl2.put('CC_Canal_Procedencia__c', 'Junta Andalucia');
        //camposRecl2.put('OwnerId', usuario.id);

       

        case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl2);
        reclamaciones.add(reclamacion2);

        insert reclamaciones;

    }

    @isTest
    static void testRecuperarColasSAC_CacheVacio(){
        user usuario = [SELECT Id FROM User WHERE userName = 'ustestesteo@test.com'];

            List<Group> listaColas = new List<Group>();
            Test.startTest();
            System.runAs(usuario) {
                listaColas = SAC_HandlerWithoutSharingMethods.recuperarColasSAC();
            }
            Test.stopTest();
            System.assertEquals(3, listaColas.size(), 'El número de colas no es el esperado');
        
    }
@isTest
    static void testActualizarReclamanteNoCliente() {

        user usuario = [SELECT Id FROM User WHERE userName = 'ustestesteo@test.com'];
        account cuenta = [SELECT Id FROM Account WHERE firstName = 'Target 1'];
        case reclamacion = [SELECT Id from Case WHERE Subject = 'TestRec'];
       
        Test.startTest();
        System.runAs(usuario) {     
            SAC_HandlerWithoutSharingMethods.actualizarReclamanteNoClienteWithoutSharing(reclamacion.Id, cuenta.Id);
        }
        Test.stopTest();
        
        //list<SAC_CaseReclamante__c> reclamante = [SELECT Id FROM SAC_CaseReclamante__c WHERE SAC_Case__c =: reclamacion.Id];
        System.assertEquals(2, [SELECT Id FROM SAC_CaseReclamante__c WHERE SAC_Case__c =: reclamacion.Id].size());
    }

    @isTest
    static void testActualizarReclamanteNoCliente2() {

        user usuario = [SELECT Id FROM User WHERE userName = 'ustestesteo@test.com'];
        account cuenta = [SELECT Id FROM Account WHERE firstName = 'Target 1'];
        case reclamacion = [SELECT Id from Case WHERE Subject = 'TestRec2'];      
       
        Test.startTest();
        System.runAs(usuario) {
            Id idRecordType = SAC_LCMP_BusquedaCliente.getRecTypeCliente();
            string tipoPersona = SAC_HandlerWithoutSharingMethods.queryRepresentantesOrContactosCliente(cuenta.Id);
            SAC_HandlerWithoutSharingMethods.actualizarReclamanteNoClienteWithoutSharing(reclamacion.id, cuenta.Id);
        }
        Test.stopTest();
        reclamacion = [SELECT Id, accountId from Case WHERE Subject = 'TestRec2'];
        
        System.assertEquals(cuenta.Id, reclamacion.accountId);
    }
}