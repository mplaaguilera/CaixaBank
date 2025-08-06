@isTest
public class CC_Servicio_Genesys_BD_TRHan_Test {
    @isTest
    public static void main() {
        List<CC_Servicio_Genesys__c> servicios = new List<CC_Servicio_Genesys__c>();
        servicios.add(new CC_Servicio_Genesys__c(CC_Codigo__c = '1', CC_VDN__c = '2'));
        servicios.add(new CC_Servicio_Genesys__c(CC_Codigo__c = '3', CC_VDN__c = '4'));
        insert servicios;
        CC_Servicio_Genesys_Detalle__c detalle = new CC_Servicio_Genesys_Detalle__c();
        detalle.CC_Servicio_Genesys__c = servicios[0].Id;
        detalle.CC_Servicio_Genesys_Relacionado__c = servicios[1].Id;
        insert detalle;

        Test.startTest();
        delete servicios;
        Test.stopTest();

        List<CC_Servicio_Genesys_Detalle__c> result = [SELECT Id FROM CC_Servicio_Genesys_Detalle__c];
        System.assertEquals(0, result.size());        
    }
}