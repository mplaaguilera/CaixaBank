/*****************************************************************
 * Name: SAC_Case_BU_TRHan_Test
 * Copyright © 2019  CaixaBank
 *
 * Proposito: Testear la clase SAC_Case_BU_TRHan
 *
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US200213         Carlos Solis         23/04/21     Creación
 * 1.1			  US507573		   Jose Carlos Blanco	29/12/22	 Modificación (agregada assertion)
 * 1.2            DE70472          Jose Carlos Blanco   09/01/23     Modificación
*****************************************************************/
@isTest
public with sharing class SAC_Case_BU_TRHan_Test {
    @TestSetup
    static void makeData() {
        Id recTypeTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recTypeProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recTypeMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recTypeDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        Id recTypeConsulta = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();

        Account cuenta = new Account();
        cuenta.name = 'cuentaTest';
        insert cuenta;

        SlaProcess slaPro = [select id, name from SlaProcess where name = 'SAC_Process' limit 1];

        Entitlement entitle = new Entitlement();
        entitle.name = 'EntitleTest';
        entitle.AccountId = cuenta.Id;
        entitle.SlaProcessId = slaPro.id;
        insert entitle;

        //MCC
        CC_MCC__c mccTematica1 = new CC_MCC__c(
        RecordTypeId = recTypeTematica,
        Name = 'Avales',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-0101');
        insert mccTematica1;

        CC_MCC__c mccProdServ1 = new CC_MCC__c(
        RecordTypeId = recTypeProdServ,
        Name = 'Avales Fianzas y Otras Garantías',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101',
        CC_Tematica__c = mccTematica1.id);
        insert mccProdServ1;

        CC_MCC__c mccMotivo1 = new CC_MCC__c(
        RecordTypeId = recTypeMotivo,
        Name = 'Discrepancia con importe deuda reclamada',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Producto_Servicio__c = mccProdServ1.id,
        CC_Codigo_Externo__c = 'TEST-0102');
        insert mccMotivo1;

        CC_MCC__c mccDetalle1 = new CC_MCC__c(
        RecordTypeId = recTypeDetalle,
        Name = 'Discrepancia con importe deuda reclamada',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-01010101',
        CC_Motivo__c = mccMotivo1.id);
        insert mccDetalle1;
        
        List<Case> listaReclamaciones = New List<Case>();
        Case casoReclamacion = new Case();
        casoReclamacion.Subject = 'TestRec';
        casoReclamacion.Origin = 'Backoffice';
        casoReclamacion.SlaStartDate = system.today();
        casoReclamacion.SAC_FechaRecepcion__c = system.today();
        casoReclamacion.RecordTypeId = recTypeReclamacion;
        listaReclamaciones.add(casoReclamacion);

        Case reclamacion3 = New Case(Subject = 'cambio naturaleza baja' , RecordTypeId = recTypeReclamacion);
        listaReclamaciones.add(reclamacion3);

        Case reclamacionAnalisis = new Case();
        reclamacionAnalisis.Subject = 'RecAnalisis';
        reclamacionAnalisis.RecordTypeId = recTypeReclamacion;
        reclamacionAnalisis.Status = 'SAC_010';
        reclamacionAnalisis.AccountId = cuenta.Id;
        //listaReclamaciones.add(reclamacionAnalisis);

        insert listaReclamaciones;

        Test.startTest();
        List<Case> listaCasos = new List<Case>();
        Case reclamacion2 = New Case(Subject = 'cambio naturaleza' , RecordTypeId = recTypeReclamacion);

        listaCasos.add(reclamacion2);
        Case casoPretension = new Case();
        casoPretension.SuppliedCompany = 'TestPret';
        casoPretension.RecordTypeId =  recTypePretension;
        casoPretension.SAC_Reclamacion__c = casoReclamacion.Id;
        casoPretension.CC_MCC_Tematica__c = mccTematica1.Id;
        casoPretension.CC_MCC_ProdServ__c = mccProdServ1.Id;
        casoPretension.CC_MCC_Motivo__c = mccMotivo1.Id;
        casoPretension.SEG_Detalle__c = mccDetalle1.Id;

        Case pretensionBaja = New Case();
        pretensionBaja.RecordTypeId = recTypePretension;
        pretensionBaja.SAC_Reclamacion__c = reclamacion3.Id;
        pretensionBaja.Status = 'SAC_009';
        pretensionBaja.SAC_StatusAuxiliar__c = 'SAC_009';

        Case recBalanceo = New Case();
        recBalanceo.RecordTypeId = recTypeConsulta;
        recBalanceo.SAC_Naturaleza__c = 'SAC_005';
        recBalanceo.Subject = 'recBalanceo';

        //Case cambioOwner = New Case();
        //cambioOwner.OwnerId = 

        listaCasos.add(casoPretension);
        listaCasos.add(pretensionBaja);
        listaCasos.add(reclamacionAnalisis);
        listaCasos.add(recBalanceo);

        insert listaCasos;
        Test.stopTest();
    }

    @isTest
    static void actualizarFechaRecepcionTest() {
        List<Case> listaCasosRec = [SELECT id, RecordTypeId, SlaStartDate, SAC_FechaRecepcion__c FROM Case WHERE RecordType.DeveloperName = 'SAC_Reclamacion' AND subject = 'TestRec'];
        Map<ID, Case> mapaCasos = new Map<ID, Case>([SELECT id, RecordTypeId, SlaStartDate, SAC_FechaRecepcion__c FROM Case WHERE subject = 'TestRec']);

        for (ID idKey : mapaCasos.keyset()) {
            Case caso = mapaCasos.get(idKey);
            System.debug(caso);
            caso.SAC_FechaRecepcion__c = system.today().addDays(-5);
        }
        Test.startTest();
        update mapaCasos.values();
        Test.stopTest();

        system.assertEquals(listaCasosRec[0].SAC_FechaRecepcion__c, listaCasosRec[0].SlaStartDate, 'No se ha actualizado el campo SlaStartDate');
    }

    @isTest
    static void actualizarMCCPretPrincipalTest() {
        List<Case> listaCasosRec = [SELECT id, SAC_PretensionPrincipal__c FROM Case WHERE RecordType.DeveloperName = 'SAC_Reclamacion' AND subject = 'TestRec'];
        List<Case> listaCasosPret = [SELECT id FROM Case WHERE RecordType.DeveloperName = 'SAC_Pretension' AND SuppliedCompany = 'TestPret'];
        listaCasosRec[0].SAC_PretensionPrincipal__c = listaCasosPret[0].Id;
        Test.startTest();
        update listaCasosRec;
        Test.stopTest();

        List<Case> listaCasosRecResult = [SELECT id, SAC_PretensionPrincipal__c FROM Case WHERE RecordType.DeveloperName = 'SAC_Reclamacion' AND subject = 'TestRec'];
        List<Case> listaCasosPretResult = [SELECT id FROM Case WHERE RecordType.DeveloperName = 'SAC_Pretension' AND SuppliedCompany = 'TestPret'];
        system.assertEquals(listaCasosPretResult[0].Id, listaCasosRecResult[0].SAC_PretensionPrincipal__c, 'No se ha actualizado la pretensión principal de la reclamación');
    }

    @istest 
    static void cambioDeNaturalezaTest1() {

        Boolean hayError = false;
        Case reclamacion = [SELECT Id, SAC_Naturaleza__c FROM Case WHERE  Subject = 'TestRec'];
        Case reclamacionOld = [SELECT Id, SAC_Naturaleza__c FROM Case WHERE  Subject = 'TestRec']; 
        reclamacion.SAC_Naturaleza__c = 'SAC_005';

        Test.startTest();
        try {
            update reclamacion;
        } catch (Exception e) {
            hayError = true; 
        } 
        Test.stopTest();
        System.assertNotEquals(reclamacion, reclamacionOld, 'No se realizó el cambio de naturaleza');     
    }

    @istest 
    static void cambioDeNaturalezaTest2() {
        Case reclamacion2 = [SELECT Id, SAC_Naturaleza__c FROM Case WHERE Subject = 'cambio naturaleza'];
        Case reclamacion2Old = [SELECT Id, SAC_Naturaleza__c FROM Case WHERE Subject = 'cambio naturaleza'];
        reclamacion2.SAC_Naturaleza__c = 'SAC_005';
        Test.startTest();
        update reclamacion2;
        Test.stopTest();
        System.assertNotEquals(reclamacion2, reclamacion2Old, 'No se realizó el cambio de naturaleza');         
    }

    @istest 
    static void cambioDeNaturalezaTest3() {
        Case reclamacion3 = [SELECT Id, SAC_Naturaleza__c, Status FROM Case WHERE Subject = 'cambio naturaleza baja'];
        Case reclamacion3Old = [SELECT Id, SAC_Naturaleza__c, Status FROM Case WHERE Subject = 'cambio naturaleza baja'];
        reclamacion3.SAC_Naturaleza__c = 'SAC_005';

        Test.startTest();
        update reclamacion3;
        Test.stopTest();
        System.assertNotEquals(reclamacion3, reclamacion3Old, 'No se realizó el cambio de naturaleza');         
    }
    @istest
    static void reclamacionAnalisis(){
        Case reclamacionAnalisis = [SELECT Id, SAC_Naturaleza__c, Status, AccountId FROM Case WHERE Subject = 'RecAnalisis'];
        Case reclamacionAnalisisOld = [SELECT Id, SAC_Naturaleza__c, Status, AccountId FROM Case WHERE Subject = 'RecAnalisis'];
        Boolean hayError = false;
        reclamacionAnalisis.Status = 'SAC_002';
        Test.startTest();
        try {
            update reclamacionAnalisis;
        } catch (Exception e) {
            hayError = true; 
        } 
        Test.stopTest();
        System.assertNotEquals(reclamacionAnalisis, reclamacionAnalisisOld, 'No se realizó el cambio de estado.');         
    }
    @istest
    static void reclamacionRechazada(){
        Case reclamacionRechazada = [SELECT Id, SAC_Naturaleza__c, Status, 
        AccountId FROM Case WHERE Subject = 'RecAnalisis'];
        Case reclamacionRechazadaOld = [SELECT Id, SAC_Naturaleza__c, Status, 
        AccountId FROM Case WHERE Subject = 'RecAnalisis'];

        Boolean hayError = false;
        reclamacionRechazada.Status = 'Rechazado';
        Test.startTest();
        try {
            update reclamacionRechazada;
        } catch (Exception e) {
            hayError = true; 
        } 
        Test.stopTest();
        System.assertNotEquals(reclamacionRechazada, reclamacionRechazadaOld, 'No se realizó el cambio de estado.');         
    }
    @istest
    static void ReclamacionesBalanceo(){
        Case reclamacionBalanceo = [SELECT Id, SAC_Naturaleza__c, 
        Status, SAC_StatusAuxiliar__c, AccountId FROM Case WHERE Subject = 'recBalanceo'];
        Case reclamacionBalanceoOld = [SELECT Id, SAC_Naturaleza__c, 
        Status, SAC_StatusAuxiliar__c, AccountId FROM Case WHERE Subject = 'recBalanceo'];
        Boolean hayError = false;
        reclamacionBalanceo.SAC_Naturaleza__c = 'SAC_004';
    
        Test.startTest();
        try {
            update reclamacionBalanceo;
        } catch (Exception e) {
            hayError = true; 
        } 
        Test.stopTest();
        System.assertNotEquals(reclamacionBalanceo, reclamacionBalanceoOld, 'No se realizó el cambio de estado.');         
    }
}