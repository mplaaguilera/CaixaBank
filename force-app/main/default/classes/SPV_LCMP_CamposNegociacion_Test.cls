@isTest
public with sharing class SPV_LCMP_CamposNegociacion_Test {
    @TestSetup
    static void makeData(){
        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);

        User usuario;
        System.runAs(usuarioAdmin){
            usuario = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            Database.insert(usuario);

            PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
            PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
            permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
            permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
            Database.insert(permiSetAssiAdmin);
        }
        Test.stopTest();

        //Añadir las reclamaciones
        List<Case> listaReclamaciones = new List<Case>();
        Map<String, Object> camposReclamacion = new Map<String, Object>();  //Siendo Object tipo genérico
        camposReclamacion.put('Subject', 'TestRec');
        camposReclamacion.put('Origin', 'Backoffice');
        camposReclamacion.put('Status', 'SAC_001');
        camposReclamacion.put('SAC_StatusAuxiliar__c', 'SAC_001');

        //Se llama al método que devolverá el caso creado con los campos pasados
        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);
        listaReclamaciones.add(casoReclamacion);

        Map<String, Object> camposReclamacion2 = new Map<String, Object>();  //Siendo Object tipo genérico
        camposReclamacion2.put('Subject', 'TestRec2');
        camposReclamacion2.put('Origin', 'Backoffice');
        camposReclamacion2.put('Status', 'SAC_002');
        camposReclamacion2.put('SAC_StatusAuxiliar__c', 'SAC_002');
        camposReclamacion2.put('OwnerId', usuario.Id);

        Case casoReclamacion2 = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion2);
        listaReclamaciones.add(casoReclamacion2);

        //Y, una vez obtenidos los casos en una lista, se insertan
        Database.insert(listaReclamaciones);

        //Se añaden las pretensiones
        List<Case> listaPretensiones = new List<Case>();

        //Pretensión 1
        Map<String, Object> camposPretension = new Map<String, Object>();
        camposPretension.put('OwnerId', usuario.Id);
        camposPretension.put('SuppliedCompany', 'pret1');

        Case pretension1 = SPV_TestDataFactory.crearCaso('Pretension', camposPretension);
        listaPretensiones.add(pretension1);


        //Pretensión 2
        Map<String, Object> camposPretension2 = new Map<String, Object>();
        camposPretension2.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPretension2.put('Status', casoReclamacion.Status);
        camposPretension2.put('SAC_StatusAuxiliar__c', casoReclamacion.Status);
        camposPretension2.put('Origin', casoReclamacion.Origin);
        camposPretension2.put('SAC_TiempoSLARegulatorio__c', 30);
        camposPretension2.put('SAC_TiempoSLALetradoAlta__c', 30);
        camposPretension2.put('CC_No_Identificado__c', true);
        camposPretension2.put('SAC_CasoNegociado__c', true);
        camposPretension2.put('CC_IdentCliente__c', '0');
        camposPretension2.put('OwnerId', usuario.id);

        Case pretension2 = SPV_TestDataFactory.crearCaso('Pretension', camposPretension2);
        listaPretensiones.add(pretension2);

        Database.insert(listaPretensiones);
    }

    @isTest
    static void getPretensionesTest(){
        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT id, Ownerid FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        List<Case> listResultado = new List<Case>();

        System.runAs(usuario1){
            Test.startTest();
            listResultado = SPV_LCMP_CamposNegociacion.getPretensiones(reclamacion.Id);
            Test.stopTest();
        }

        Assert.areNotEqual(null, listResultado, 'No se han recuperado las pretensiones de la reclamacion');
    }

    @isTest
    static void addPretensionesNegociacionReclamacionTest(){
        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT id, Ownerid FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        List<Case> listResultado = new List<Case>();

        System.runAs(usuario1){
            Test.startTest();
            listResultado = SPV_LCMP_CamposNegociacion.addPretensionesNegociacionReclamacion(reclamacion.Id);
            Test.stopTest();
        }

        Assert.areNotEqual(null, listResultado, 'No se han recuperado las pretensiones de la reclamacion que no se encuentran en negociación');
    }


    @isTest
    static void activarNegociacionPretensionTest(){
        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT id, Ownerid FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Case pretensionNegociada;
        List<Case> listResultado = new List<Case>();

        System.runAs(usuario1){
            Test.startTest();
            List<Case> pretensionesCaso = SPV_LCMP_CamposNegociacion.addPretensionesNegociacionReclamacion(reclamacion.Id);
            SPV_LCMP_CamposNegociacion.activarNegociacionPretension(reclamacion.Id, pretensionesCaso);
            pretensionNegociada = [SELECT id, CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c FROM Case WHERE Id =: pretensionesCaso[0].Id LIMIT 1];
            Test.stopTest();
        }

        Assert.areEqual(true, pretensionNegociada.CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c, 'No se iniciado la negociación en la pretensión');
    }


    @isTest
    static void eliminarPretensionNegociacionTest(){
        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT id, Ownerid FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Case pretensionEliminada;
        List<Case> listResultado = new List<Case>();

        System.runAs(usuario1){
            Test.startTest();
            List<Case> pretensionesCaso = SPV_LCMP_CamposNegociacion.addPretensionesNegociacionReclamacion(reclamacion.Id);
            System.debug('pretensionesCaso ' +pretensionesCaso);
            SPV_LCMP_CamposNegociacion.eliminarPretensionNegociacion(pretensionesCaso[0].Id);
            pretensionEliminada = [SELECT id, CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c FROM Case WHERE Id =: pretensionesCaso[0].Id LIMIT 1];
            Test.stopTest();
        }

        Assert.areEqual(false, pretensionEliminada.CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c, 'No se eliminado la pretensión de la negociación');
    }
}