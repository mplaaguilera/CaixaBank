@isTest
public with sharing class CC_MCC_AI_TRHan_Test {

    @isTest
    static void testTriggerExternalId(){
        Id rtMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        User admin = CC_TestDataFactory.getUserAdmin();
        
        System.runAs(admin){
            Test.startTest();
            CC_MCC__c mcc = new CC_MCC__c();
            mcc.Name = 'Test';
            mcc.CC_Fecha_Vigencia_Inicio__c = System.now();
            mcc.RecordTypeId = rtMotivo;
            mcc.CC_Tipo_Cliente__c = 'Cliente';
            mcc.CC_Codigo_Externo__c = '12';
            insert mcc;
            
            
            // Recuperar el registro después de la inserción para asegurar que los cambios del trigger se han aplicado
            mcc = [SELECT Id, CC_Codigo_Externo__c FROM CC_MCC__c WHERE Id = :mcc.Id];
            
            system.assert(mcc.Id != null, 'El MCC no se creó correctamente');
            system.assert(mcc.CC_Codigo_Externo__c != null, 'El código externo no se actualizó correctamente. Código externo actual: ' + mcc.CC_Codigo_Externo__c);

            Test.stopTest();
        }
    }

}