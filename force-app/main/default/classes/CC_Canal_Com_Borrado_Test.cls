@IsTest
public with sharing class CC_Canal_Com_Borrado_Test {
    public static testMethod void test(){
        Account cuenta = new Account(
            Name = 'Cuenta test confidencial'
        );
        insert cuenta;
        
        Contact contacto = new Contact(
            LastName = 'Contacto test confidencial',
            AccountId = cuenta.Id
        );
        insert contacto;

        CC_Canal_Com__c canal = new CC_Canal_Com__c(
            CC_CuentaId__c = cuenta.Id
        );
        insert canal;
        
        List<CC_Canal_Com__c> canales = [SELECT Id FROM CC_Canal_Com__c Where CC_CuentaId__c = :cuenta.Id];
        System.assertEquals(1, canales.size());

        contacto.CC_Confidencial__c = TRUE;
        update contacto;


        List<Id> cuentasId = new List<Id>();
        cuentasId.add(cuenta.Id);
        CC_Canal_Com_Borrado.borradoConfidenciales(cuentasId);
        List<CC_Canal_Com__c> canalesBorrados = [SELECT Id FROM CC_Canal_Com__c Where CC_CuentaId__c = :cuenta.Id];
        System.assertEquals(0, canalesBorrados.size());
    }
}