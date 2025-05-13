@isTest
public with sharing class CC_MCC_AU_TRHan_Test {
    
    @isTest
    static void testAutoBajaMCC() {
        // Obtener los RecordTypes necesarios
        Id rtTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id rtProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id rtMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id rtCausa = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        
        User admin = CC_TestDataFactory.getUserAdmin();
        
        System.runAs(admin) {
            // Crear registros iniciales activos
            List<CC_MCC__c> mccList = new List<CC_MCC__c>();
            
            // Crear Temática
            CC_MCC__c tematica = new CC_MCC__c(
            RecordTypeId = rtTematica,
            Name = 'Temática Test',
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Fecha_Vigencia_Inicio__c = System.Now().addDays(-1),
            CC_Codigo_Externo__c = '2311011',
            CC_Canal_Operativo__c = 'App BrokerNow'
                );
            mccList.add(tematica);
            
            // Crear Producto
            CC_MCC__c producto = new CC_MCC__c(
            RecordTypeId = rtProducto,
            Name = 'Producto Test',
            CC_Tipo_Cliente__c = 'Empleado',
            CC_Codigo_Externo__c = '2311012',
            CC_Fecha_Vigencia_Inicio__c = System.Now().addDays(-1)
                );
            mccList.add(producto);
            
            // Crear Motivo
            CC_MCC__c motivo = new CC_MCC__c(
            RecordTypeId = rtMotivo,
            Name = 'Motivo Test',
            CC_Tipo_Cliente__c = 'Cliente/Empleado',
            CC_Codigo_Externo__c = '2311013',
            CC_Fecha_Vigencia_Inicio__c = System.Now().addDays(-1)
                );
            mccList.add(motivo);
            
            // Crear Causa
            CC_MCC__c causa = new CC_MCC__c(
            RecordTypeId = rtCausa,
            Name = 'Causa Test',
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = '2311014',
            CC_Fecha_Vigencia_Inicio__c = System.Now().addDays(-1)
                );
            mccList.add(causa);
            
            Test.startTest();
            insert mccList;
            
            // Actualizar los registros para desactivarlos
            for(CC_MCC__c mcc : mccList) {
                mcc.CC_Fecha_Vigencia_Fin__c = System.Now();
            }
            update mccList;
            
            List<CC_MCC__c> updatedMccList = [SELECT Id, Name, CC_Activo__c, RecordType.DeveloperName 
                                             FROM CC_MCC__c 
                                             WHERE Id IN :mccList];
            
            for(CC_MCC__c mcc : updatedMccList) {
                System.assert(!mcc.CC_Activo__c, 'El registro ' + mcc.Name + ' debería estar desactivado');
            }
            
            Test.stopTest();
            
        }
    }
 
}