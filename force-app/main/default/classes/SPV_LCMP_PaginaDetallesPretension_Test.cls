@isTest
public with sharing class SPV_LCMP_PaginaDetallesPretension_Test {
    
    @TestSetup
    static void makeData(){

        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SPV_DatabaseDML.insertDML(usuarioAdmin, false);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            SPV_DatabaseDML.insertDML(usuarioGeneral, false);

            PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
            PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
            permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
            permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
            SPV_DatabaseDML.insertDML(permiSetAssiAdmin, false);
        }

        Id recType = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoGestor').getRecordTypeId();

        Account cuenta = new Account();
        cuenta.Name = 'cuentaTest';
        cuenta.CC_Tipo_Centro__c = 'DT';
        SPV_DatabaseDML.insertDML(cuenta, true);

        List<CC_Grupo_Colaborador__c> grupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
        grupoColaborador.name = 'grupoColaboradorTest';
        grupoColaborador.RecordTypeId = recType;
        grupoColaborador.SAC_PorcentajeAsignacion__c = 100;
        grupoColaborador.SAC_MaximoCasosDiarios__c = 30;
        grupoColaborador.SAC_PermiteTareas__c = true;
        grupoColaborador.SAC_DeveloperName__c = 'SPV_TestGrupoTest';
        grupos.add(grupoColaborador);

        SPV_DatabaseDML.insertListDML(grupos, false);

        List<Case> listaReclamaciones = new List<Case>();
        Case caso = new Case();
        caso.Subject = 'ReclamacionTest';
        caso.Status = 'SPV_AnalisisDecision';
        caso.SPV_Complementaria_Entidad__c = false;
        caso.SAC_StatusAuxiliar__c = caso.Status;
        caso.SEG_Grupo__c = grupoColaborador.id;
        caso.AccountId = cuenta.Id;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();
        caso.OwnerId = usuarioAdmin.Id;
        caso.SAC_EntidadProductora__c = 'Bankia';
        caso.SAC_ValidacionOficinaAfectada__c = true;
        listaReclamaciones.add(caso);

        SPV_DatabaseDML.insertListDML(listaReclamaciones, false);

        List<Case> listPretensiones = new List<Case>();
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'pruebaPretension');
        camposPret.put('SPV_Organismo__c', 'SPV_Consumo');
        camposPret.put('OwnerId', usuarioAdmin.Id);
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_Reclamacion__c', caso.Id);
        Case pretension = SPV_TestDataFactory.crearCaso('Pretension',camposPret);
        listPretensiones.add(pretension);

        SPV_DatabaseDML.insertListDML(listPretensiones, false);


        Test.stopTest();
    }


    @isTest
    static void updateRecordsFormTest(){

        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case pretension = [SELECT Id, Status, SPV_Organismo__c FROM Case WHERE SuppliedCompany = 'pruebaPretension' limit 1];

        Test.startTest();

        System.runAs(usuario){
            pretension.SPV_Organismo__c = 'SPV_CNMV';
            List<Case> listaPretensiones = new List<Case>();
            listaPretensiones.add(pretension);
            SPV_LCMP_PaginaDetallesPretension.updateRecordsForm(listaPretensiones);
        }

        Case pretension2 = [SELECT Id, Status, SPV_Organismo__c FROM Case WHERE SuppliedCompany = 'pruebaPretension' limit 1];
        Assert.areEqual('SPV_CNMV', pretension2.SPV_Organismo__c, 'No se han actualizado los campos de la pretension.');
        Test.stopTest();
    }

    @isTest
    static void obtenerValoresPicklistTest(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario1){
            Test.startTest();
            SPV_LCMP_PaginaDetallesPretension.PicklistWrapper valoresPicklist = SPV_LCMP_PaginaDetallesPretension.obtenerValoresPicklist();

            Assert.areNotEqual(null, valoresPicklist, 'No se han recuperado los valores para la picklist');
            Test.stopTest();
        }
    }

    @isTest
    static void updatearCaseExtensionTest(){

        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case pretension = [SELECT Id, Status, CBK_Case_Extension_Id__c FROM Case WHERE SuppliedCompany = 'pruebaPretension' limit 1];
        Test.startTest();

        System.runAs(usuario){
            SPV_LCMP_PaginaDetallesPretension.updatearCaseExtension(pretension.CBK_Case_Extension_Id__c, 'Test', 'Test', 'Test', 'Test');
        }

        CBK_Case_Extension__c pretensionesResult = [SELECT Id, SPV_AnalisisDesistimiento__c FROM CBK_Case_Extension__c WHERE id =: pretension.CBK_Case_Extension_Id__c limit 1];
        Assert.areEqual(pretensionesResult.SPV_AnalisisDesistimiento__c, 'Test', 'No actualizado el case extension correctamente.');
    }
}