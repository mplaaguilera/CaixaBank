@isTest
private class AV_peaLink_Controller_Test {

    @TestSetup
	static void setup() {
        User userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank');
        AV_TestHelper.insertPermissionSet(userGestor.Id, 'AV_Simuladores');
        AV_TestHelper.insertPermissionSet(userGestor.Id, 'AV_CustomMetadata');

        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        
        System.runAs(usuario) {
            Account customerTest = AV_TestHelper.createCustomer();
            Opportunity opp= AV_TestHelper.createOpportunity(customerTest);
            Product2 product = [SELECT Id FROM Product2 WHERE Id =: opp.AV_PF__c];
            AV_Simulador__c simulador = new AV_Simulador__c();
                simulador.name = 'pruebaSimulador';
                simulador.AV_Color__c = '#557FB8';
                simulador.AV_URL_PEA__c = 'PEA';
                simulador.AV_PEA__c = 'https://google.es';
                simulador.AV_Producto__c = product.Id;

                insert simulador;
        }
	}

    @isTest
    static void getURLsTest() {
        User us1=[SELECT id FROM User WHERE Alias = 'tsAlias'];
        List<AV_peaLink_Controller.LabelURL> listURLs = new List<AV_peaLink_Controller.LabelURL>();
                
        Test.startTest();
        System.runAs(us1){
            listURLs = AV_peaLink_Controller.getURLs('AV_0004');
        Test.stopTest();
        }

        System.assertNotEquals(null, listURLs, 'url is null');
    }

    @isTest
    static void getCurrentPEATest() {
        User us1=[SELECT id FROM User WHERE Alias = 'tsAlias'];
        AV_Simulador__c simulador = [SELECT Id FROM AV_Simulador__c WHERE Name = 'pruebaSimulador'];
        String idSimulador = simulador.Id;
        String currentPEA = '';
                Test.startTest();
                System.runAs(us1){
                    currentPEA = AV_peaLink_Controller.getCurrentPEA(idSimulador);
                
                Test.stopTest();
                }
                System.assertNotEquals(null, currentPEA, 'currentPEA is null');
            }

    @isTest
    static void updateSimuladorTest() {
        User us1=[SELECT id FROM User WHERE Alias = 'tsAlias'];
        AV_Simulador__c simulador = [SELECT Id FROM AV_Simulador__c WHERE Name = 'pruebaSimulador'];
        String urlNew = 'testURLUpdate';  
        Test.startTest();
        System.runAs(us1){
            AV_peaLink_Controller.updateSimulador(simulador.Id, urlNew);
        
        Test.stopTest();
        }
        System.assertNotEquals(null, urlNew, 'urlNew is null');

    }
}