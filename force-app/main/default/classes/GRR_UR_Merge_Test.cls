@isTest
public with sharing class GRR_UR_Merge_Test {

    private static GRR_UR__c crearUROrigen() {
        GRR_UR__c ur = new GRR_UR__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_UR__c', 'GRR_UR'),
            GRR_Id_UR__c = 'UR Origen'
        );
        insert ur;

        GRR_Lanzamiento__c lanzamiento = new GRR_Lanzamiento__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_Lanzamiento__c', 'GRR_Lanzamiento'),
            GRR_UR__c = ur.Id,
            GRR_Codigo_UR__c = ur.GRR_Id_UR__c,
            GRR_Fecha_Prevista_Posesion__c = Datetime.now()
        );
        insert lanzamiento;
        lanzamiento.GRR_Codigo_Lanzamiento__c = ur.GRR_Id_UR__c + '-' + lanzamiento.GRR_Fecha_Prevista_Posesion__c.format('yyyyMMdd');
        update lanzamiento;

        Case caso = new Case(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'),
            Origin = 'SAC_Manual',
            GRR_UR_Relacionada__c = ur.Id
        );
        insert caso;

        GRR_Carga__c carga = new GRR_Carga__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_Carga__c', 'GRR_Carga'),
            GRR_NombreDelFichero__c = 'Carga prueba',
            GRR_TipoDeFichero__c = 'Acta de comité'
        );
        insert carga;

        GRR_RegistroCarga__c registroCarga = new GRR_RegistroCarga__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Recobro'),
            GRR_Fichero__c = carga.Id,
            GRR_UR__c = ur.Id,
            GRR_CodigoUR__c = ur.GRR_Id_UR__c
        );
        insert registroCarga;

        Task tarea = new Task(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task'),
            Type = 'Tarea prueba',
            Subject = 'Tarea prueba',
            Status = 'Completed',
            WhatId = ur.Id
        );
        insert tarea;

        return ur;
    }

    private static GRR_UR__c crearURDestino() {
        GRR_UR__c ur = new GRR_UR__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_UR__c', 'GRR_UR'),
            GRR_Id_UR__c = 'UR Destino'
        );
        insert ur;
        return ur;
    }     
    
    @isTest
    public static void testFusionarUR() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();

            GRR_UR__c urOrigen = crearUROrigen();
            GRR_UR__c urDestino = crearURDestino();
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S';
            contentVersion.PathOnClient = 'Test';
            contentVersion.Origin = 'H';
            contentVersion.Title = 'Test';
            contentVersion.VersionData = Blob.valueOf('Test Content');
            insert contentVersion;
            ContentVersion cVers = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
            ContentDocumentLink cdl1 = new ContentDocumentLink(
                LinkedEntityId = urOrigen.Id,
                ContentDocumentId = cVers.ContentDocumentId,
                ShareType = 'V'
            );
            insert cdl1;
    
            String resultado = GRR_UR_Merge.fusionarUR(urOrigen.Id, urDestino.Id);
            System.assertEquals(2, [SELECT COUNT() FROM Task WHERE WhatId = :urDestino.Id]);

            Test.stopTest();
        }
    }

}