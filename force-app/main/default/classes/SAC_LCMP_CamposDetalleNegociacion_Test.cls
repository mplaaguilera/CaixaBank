@isTest 
public with sharing class SAC_LCMP_CamposDetalleNegociacion_Test {
    @TestSetup
    static void makeData() {
        User usuario;

        Test.startTest();
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);

        System.runAs(usuarioAdmin) {
            List<User> usuariosGenerales = SAC_TestDataFactory.crearUsuarioSACGeneral(1);
            usuariosGenerales[0].Username = 'Name12345@test.com';            
            usuario = usuariosGenerales[0];
            SAC_DatabaseDML.insertListDML(usuariosGenerales, false);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuario.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);
        }
        //Cuentas
        Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];       
        Account ofi = SAC_TestDataFactory.crearCuentasOficina(1)[0];
        
        List<Account> listaCuentas = new List<Account>();
        listaCuentas.add(cuenta);
        listaCuentas.add(ofi);
        SAC_DatabaseDML.insertListDML(listaCuentas, false);
        Test.stopTest();

        //RECLAMACION
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Otros');
        camposRecl.put('Status', 'SAC_007');
        camposRecl.put('OwnerId', usuario.Id);
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_007');
        camposRecl.put('AccountId', cuenta.Id);
        camposRecl.put('SAC_ProrrogaCounter__c', 0);
        camposRecl.put('SuppliedEmail', 't.t@t.t');
        camposRecl.put('SAC_TipoConsumidor__c', 'Si');
        camposRecl.put('SAC_CasoNegociado__c', true);
        camposRecl.put('CC_Oficina_Afectada_Lookup__c', ofi.Id);
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);

        List<Case> casosReclamacion = new List<Case>();
        casosReclamacion.add(casoReclamacion);
        SAC_DatabaseDML.insertListDML(casosReclamacion, false);

        //Creacion MCC
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.Name = 'MCC Test';
        mcc.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        SAC_DatabaseDML.insertDML(mcc, false);

        // PRETENSION
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('Subject', 'TestPret');
        camposPret.put('SuppliedCompany', 'TestPret');
        camposPret.put('Origin', 'Otros');
        camposPret.put('Status', 'SAC_007');
        camposPret.put('SAC_StatusAuxiliar__c', 'SAC_007');
        camposPret.put('SAC_SentidoResolucion__c', 'SAC_002');
        camposPret.put('SAC_RedaccionFinal__c', true);
        camposPret.put('SAC_NegociacionFinalizada__c', true);
        camposPret.put('CC_Importe_Reclamado__c', 50);
        camposPret.put('SAC_Importe_Resuelto__c', 50);
        camposPret.put('CC_Importe_Abonado__c', 50);
        camposPret.put('SAC_Importe_ResultadoNegociacion__c', 50);
        camposPret.put('SAC_ResultadoNegociacion__c', 'Con acuerdo');
        camposPret.put('SAC_DetalleResultadoNegociacion__c', 'Factoría');
        camposPret.put('OwnerId', usuario.Id);
        camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret.put('AccountId', cuenta.Id);
        camposPret.put('SEG_Detalle__c', mcc.Id);
        
        Case pretension = SAC_TestDataFactory.crearCaso('Pretension', camposPret);
        
        List<Case> casosPretension = new List<Case>();
        casosPretension.add(pretension);
        SAC_DatabaseDML.insertListDML(casosPretension, false);
    }


    @isTest
    static void getNegociacionesPretensionTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];

        List<Case> resultado;

        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){
            resultado = SAC_LCMP_CamposDetalleNegociacion.getNegociacionesPretension(reclamacion.Id);
        }
        Test.stopTest();

        Assert.areEqual(false, resultado.isEmpty(), 'No se han recuperado las pretensiones negociadas de la reclamación');
    }
}