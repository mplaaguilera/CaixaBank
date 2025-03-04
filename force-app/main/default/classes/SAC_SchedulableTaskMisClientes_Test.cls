@isTest
public with sharing class SAC_SchedulableTaskMisClientes_Test {
   
    @TestSetup
    static void makeData(){

        Id recTypeTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recTypeProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recTypeMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recTypeDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();

        //Users
        List<User> listaUsers = SAC_TestDataFactory.crearUsuarioSACGeneral(1);
        listaUsers[0].Username = 'sac5reclamacion@test.test';
        SAC_DatabaseDML.insertListDML(listaUsers, false);  
        //Database.insert(listaUsers);

        //MCC
        List<CC_MCC__c> listamccsDetalle = new List<CC_MCC__c>();

        CC_MCC__c mccTematica1 = new CC_MCC__c(
        RecordTypeId = recTypeTematica,
        Name = 'Avales',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-0101');
        SAC_DatabaseDML.insertDML(mccTematica1, false);  
        //Database.insert(mccTematica1);

        CC_MCC__c mccProdServ1 = new CC_MCC__c(
        RecordTypeId = recTypeProdServ,
        Name = 'Avales Fianzas y Otras Garantías',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101',
        CC_Tematica__c = mccTematica1.id);
        SAC_DatabaseDML.insertDML(mccProdServ1, false);  
        //Database.insert(mccProdServ1);

        CC_MCC__c mccMotivo1 = new CC_MCC__c(
        RecordTypeId = recTypeMotivo,
        Name = 'Discrepancia con importe deuda reclamada',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Producto_Servicio__c = mccProdServ1.id,
        CC_Codigo_Externo__c = 'TEST-0102');
        SAC_DatabaseDML.insertDML(mccMotivo1, false);  
        //Database.insert(mccMotivo1);

        CC_MCC__c mccDetalle2 = new CC_MCC__c(
        RecordTypeId = recTypeDetalle,
        Name = 'Discrepancia con importe deuda reclamada',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101012',
        CC_Motivo__c = mccMotivo1.id,
        SAC_GenerarTaskMisClientes__c = true);
        listamccsDetalle.add(mccDetalle2);
        SAC_DatabaseDML.insertListDML(listamccsDetalle, false); 
        //Database.insert(listamccsDetalle);

        //Reclamacion
        List<Case> reclamaciones = new List<Case>();
        Map<String, Object> mapaCamposCaso = new Map<String, Object>();
        mapaCamposCaso.put('Subject', 'TestRec3');
        mapaCamposCaso.put('Origin', 'Backoffice');
        mapaCamposCaso.put('Status', 'SAC_001');
        mapaCamposCaso.put('SEG_Detalle__c', mccDetalle2.id);
        mapaCamposCaso.put('CC_MCC_Tematica__c', mccTematica1.id);
        mapaCamposCaso.put('CC_MCC_Motivo__c', mccMotivo1.id);
        mapaCamposCaso.put('CC_MCC_ProdServ__c', mccProdServ1.id);
        mapaCamposCaso.put('SAC_TipoConsumidor__c', 'Si');
        // mapaCamposCaso.put('AccountId', listaCuentas[0].id);
        mapaCamposCaso.put('OwnerId', listaUsers[0].id);
        Case casoReclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion', mapaCamposCaso);
        reclamaciones.add(casoReclamacion3);
        SAC_DatabaseDML.insertListDML(reclamaciones, false); 
        //Database.insert(reclamaciones);

        //Pretension
        List<Case> pretensiones = new List<Case>();
        Map<String, Object> mapaCamposPret = new Map<String, Object>();
        mapaCamposPret.put('SuppliedCompany', 'Pret3');
        mapaCamposPret.put('Origin', 'Backoffice');
        mapaCamposPret.put('Status', 'SAC_001');
        mapaCamposPret.put('SAC_Reclamacion__c', casoReclamacion3.Id);
        mapaCamposPret.put('SEG_Detalle__c', mccDetalle2.id);
        mapaCamposPret.put('CC_MCC_Tematica__c', mccTematica1.id);
        mapaCamposPret.put('CC_MCC_Motivo__c', mccMotivo1.id);
        mapaCamposPret.put('CC_MCC_ProdServ__c', mccProdServ1.id);
        mapaCamposPret.put('OwnerId', listaUsers[0].Id);
        Case casoPretension3 = SAC_TestDataFactory.crearCaso('Pretension', mapaCamposPret);
        pretensiones.add(casoPretension3);

    }

    @isTest
    static void scheduleTaskMTest() {
        User usuario = [SELECT id FROM user WHERE Username = 'sac5reclamacion@test.test' LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec3' LIMIT 1];

        //PendingProcess
        List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();
        CBK_SCH_PendingProcess__c pendingProcessReclamacion = new CBK_SCH_PendingProcess__c();
        pendingProcessReclamacion.recordId__c = reclamacion.Id;
        pendingProcessReclamacion.Schedule_Time__c = system.now().addMinutes(2);
        pendingProcessReclamacion.className__c = 'SAC_SchedulableTaskMisClientes';

        listaPendingProcess.add(pendingProcessReclamacion);

        SAC_SchedulableTaskMisClientes sca = new SAC_SchedulableTaskMisClientes();

        Test.startTest();
        System.runAs(usuario) {
            sca.work(listaPendingProcess);
        }
        Test.stopTest();

        System.assertNotEquals(null, sca, 'No se ha podido crear la task de mis clientes');
    }
}