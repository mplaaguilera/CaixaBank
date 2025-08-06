/**********************************************************************************************************************
 Name:	  CIBE_CambioMonedaSchedulable_Test 
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test de CIBE_CambioMonedaSchedulable_Test
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				        DATE				Description
	1.0					            jose maria fernandez       09/12/2022			Init version
    1.1             FIX             Alexandre Pérez            20/03/2023           cambio inserts por updates
***********************************************************************************************************************/
@isTest
public class CIBE_CambioMonedaSchedulable_Test {
    
    private User userCIB; 
    @TestSetup
    static void setup(){
        
        List<CBK_IntegrationSetting__c> listEndpointConf = new list<CBK_IntegrationSetting__c>();
        CBK_IntegrationSetting__c endpointConf = new CBK_IntegrationSetting__c(Name='changeCurrency', NamedCredential__c = 'changeCurrency');
        listEndpointConf.add(endpointConf);
        insert listEndpointConf;

        CIBE_Divisas__c peseta = new CIBE_Divisas__c(
            CIBE_CodigoDivisa__c = 'ESP',
            CIBE_DivisaBase__c = '166.387',
            CIBE_FechaTipoCambio__c	= system.today()-1
        );
        insert peseta;
    } 

    @isTest
    public static void insertDivisas() {
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('DIVISAS','OK'));

        Test.startTest();
        //será ejecutado por un admin de sistema como el que ejecuta las test 
        system.runAs(new User(Id = UserInfo.getUserId())){
            CIBE_CambioMonedaSchedulable myBatchObject = new CIBE_CambioMonedaSchedulable();
            Id batchId = Database.executeBatch(myBatchObject);    
        }
        
        Test.stopTest();

        System.assertEquals(3, [SELECT id FROM CIBE_Divisas__c].size(), 'se esperaban 3 divisas cargadas correctamente');
    }

    @isTest
    public static void scheduleDivisas() {
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('DIVISAS','OK'));
        final string cron_exp = dateTime.now().addMinutes(1).format('ss mm HH dd MM ? yyyy');
        Test.startTest();
        //será programado por un admin de sistema como el que ejecuta las test 
        system.runAs(new User(Id = UserInfo.getUserId())){
            System.schedule('Test Divisas Scheduler', cron_exp, new CIBE_CambioMonedaSchedulable());
        }
        Test.stopTest();
        System.assertEquals(2, [SELECT Id FROM AsyncApexJob].size(), 'Los batches no han sido programados');
        
    }
    
}