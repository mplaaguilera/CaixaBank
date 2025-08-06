@isTest
private class SPV_HandlerWithoutSharingMethods_Test {


    @TestSetup
    static void makeData(){

        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        usuarioAdmin.Username = 'useraadmin@test.com.testdata';
        Database.insert(usuarioAdmin);

        User usuario;
        System.runAs(usuarioAdmin){
            usuario = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            usuario.Username = 'ustestesteo@test.com';
            Database.insert(usuario);

            PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
            PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
            permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
            permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
            Database.insert(permiSetAssiAdmin);
        }


        list<Account> cuentas;
        cuentas = SPV_TestDataFactory.crearCuentasNoClientePA(2);

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

        case reclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl);
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

       

        case reclamacion2 = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl2);
        reclamaciones.add(reclamacion2);

        insert reclamaciones;

    }

    @isTest
    static void testActualizarReclamanteNoCliente() {
        user usuario = [SELECT Id FROM User WHERE userName = 'ustestesteo@test.com'];
        account cuenta = [SELECT Id FROM Account WHERE firstName = 'Target 1'];
        case reclamacion = [SELECT Id from Case WHERE Subject = 'TestRec'];

        Test.startTest();
        System.runAs(usuario) {     
            SPV_HandlerWithoutSharingMethods.actualizarReclamanteNoClienteWithoutSharing(reclamacion.Id, cuenta.Id);
        }
        Test.stopTest();
        
        list<SAC_CaseReclamante__c> reclamante = [SELECT Id FROM SAC_CaseReclamante__c WHERE SAC_Case__c =: reclamacion.Id];
        List<SAC_CaseReclamante__c> listaReclamantes = [SELECT Id FROM SAC_CaseReclamante__c WHERE SAC_Case__c =: reclamacion.Id];
        Integer n = 0;
        for (SAC_CaseReclamante__c cr : listaReclamantes) {
            n++;
        }
        System.assertEquals(2, n, 'error');
    }

    /*
    @isTest
    static void testActualizarReclamanteNoCliente2() {

        user usuario = [SELECT Id FROM User WHERE userName = 'ustestesteo@test.com'];
        account cuenta = [SELECT Id FROM Account WHERE firstName = 'Target 1'];
        case reclamacion = [SELECT Id from Case WHERE Subject = 'TestRec2'];
       
        Test.startTest();
        System.runAs(usuario) {
            SPV_HandlerWithoutSharingMethods.actualizarReclamanteNoClienteWithoutSharing(reclamacion.id, cuenta.Id);
        }
        Test.stopTest();
        reclamacion = [SELECT Id, accountId from Case WHERE Subject = 'TestRec2'];
        
        System.assertEquals(cuenta.Id, reclamacion.accountId, 'error');
    }
    */

    @isTest
    static void insertarAccionShareTest() {
        case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec2'];
        user usuario = [SELECT Id FROM User WHERE userName = 'ustestesteo@test.com'];

        SAC_Accion__c tarea = new SAC_Accion__c();
        tarea.SAC_Observaciones__c = 'Llamar';
        tarea.RecordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SPV_MaestroDeTareas').getRecordTypeId();
        //tarea.SAC_EquipoResponsable__c = listaGrupos[0].Id;
        tarea.SAC_Reclamacion__c = reclamacion.Id;
        tarea.SAC_Estado__c = 'SAC_PendienteEnviar';
        Database.insert(tarea);

        Test.startTest();
        System.runAs(usuario) {
            SPV_HandlerWithoutSharingMethods.insertarAccionShare(tarea);
        }
        Test.stopTest();

        SAC_Accion__Share accionSH = [SELECT Id FROM SAC_Accion__Share WHERE ParentId = :tarea.Id AND UserOrGroupId = :usuario.Id AND AccessLevel = 'Edit' LIMIT 1];
        System.assertNotEquals(null, accionSH, 'no se ha insertado la accion share');
        
    }
}