@isTest
public with sharing class CC_MCC_BU_BI_TRHan_Test {

    @isTest
    static void testTriggerRefWeb(){
        Id rtConversionWeb = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_ConvMCCWeb');
        User admin = CC_TestDataFactory.insertUserAdmin();
        
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
            
            mcc = [SELECT Id, Name, CC_Equivalencia_Formulario__c FROM CC_MCC__c WHERE Id = :mcc.Id];
            
            system.assert(mcc.Id != null, 'El MCC no se creó correctamente');
            system.assert(mcc.Name == 'Ori-Mot-Pro-Amb', 'El nombre del MCC no se actualizó correctamente. Nombre actual: ' + mcc.Name);
            system.assert(mcc.CC_Equivalencia_Formulario__c == 'Ori-Mot-Pro-Amb', 'La equivalencia del formulario no se actualizó correctamente. Equivalencia actual: ' + mcc.CC_Equivalencia_Formulario__c);

            mcc.CC_MCCWeb_Origen__c = 'Or2';
            mcc.CC_MCCWeb_Motivo__c = 'Mo2';
            mcc.CC_MCCWeb_Producto__c = 'Pr2';
            mcc.CC_MCCWeb_Ambito__c = 'Am2';
            update mcc;
            
            // Recuperar el registro después de la inserción para asegurar que los cambios del trigger se han aplicado
            mcc = [SELECT Id, Name, CC_Equivalencia_Formulario__c FROM CC_MCC__c WHERE Id = :mcc.Id];
            
            system.assert(mcc.Id != null, 'El MCC no se creó correctamente');
            system.assert(mcc.Name == 'Or2-Mo2-Pr2-Am2', 'El nombre del MCC no se actualizó correctamente. Nombre actual: ' + mcc.Name);
            system.assert(mcc.CC_Equivalencia_Formulario__c == 'Or2-Mo2-Pr2-Am2', 'La equivalencia del formulario no se actualizó correctamente. Equivalencia actual: ' + mcc.CC_Equivalencia_Formulario__c);

            Test.stopTest();
        }
    }
}