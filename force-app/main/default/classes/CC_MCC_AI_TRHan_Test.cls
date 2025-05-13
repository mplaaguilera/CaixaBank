@isTest
public with sharing class CC_MCC_AI_TRHan_Test {

    @isTest
    static void testTriggerRefWeb(){
        Id rtConversionWeb = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_ConvMCCWeb').getRecordTypeId();
        User admin = CC_TestDataFactory.getUserAdmin();
        
        System.runAs(admin){
            Test.startTest();
            CC_MCC__c mcc = new CC_MCC__c();
            mcc.RecordTypeId = rtConversionWeb;
            mcc.CC_Tipo_Cliente__c = 'Cliente';
            mcc.CC_MCCWeb_Origen__c = 'Ori';
            mcc.CC_MCCWeb_Motivo__c = 'Mot';
            mcc.CC_MCCWeb_Producto__c = 'Pro';
            mcc.CC_MCCWeb_Ambito__c = 'Amb';
            insert mcc;
            
            
            // Recuperar el registro después de la inserción para asegurar que los cambios del trigger se han aplicado
            mcc = [SELECT Id, Name, CC_Equivalencia_Formulario__c FROM CC_MCC__c WHERE Id = :mcc.Id];
            
            system.assert(mcc.Id != null, 'El MCC no se creó correctamente');
            system.assert(mcc.Name == 'Ori-Mot-Pro-Amb', 'El nombre del MCC no se actualizó correctamente. Nombre actual: ' + mcc.Name);
            system.assert(mcc.CC_Equivalencia_Formulario__c == 'Ori-Mot-Pro-Amb', 'La equivalencia del formulario no se actualizó correctamente. Equivalencia actual: ' + mcc.CC_Equivalencia_Formulario__c);

            Test.stopTest();
        }
    }

    @isTest
    static void testTriggerExternalId(){
        Id rtMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        User admin = CC_TestDataFactory.getUserAdmin();
        
        System.runAs(admin){
            Test.startTest();
            CC_MCC__c mcc = new CC_MCC__c();
            mcc.RecordTypeId = rtMotivo;
            mcc.CC_Tipo_Cliente__c = 'Cliente';
            insert mcc;
            
            
            // Recuperar el registro después de la inserción para asegurar que los cambios del trigger se han aplicado
            mcc = [SELECT Id, CC_Codigo_Externo__c FROM CC_MCC__c WHERE Id = :mcc.Id];
            
            system.assert(mcc.Id != null, 'El MCC no se creó correctamente');
            system.assert(mcc.CC_Codigo_Externo__c != null, 'El código externo no se actualizó correctamente. Código externo actual: ' + mcc.CC_Codigo_Externo__c);

            Test.stopTest();
        }
    }

}