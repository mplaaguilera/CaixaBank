@IsTest
public class CIBE_OppCerradoNegativoSchedulable_Test {

    @TestSetup
    static void makeData(){
        ID rtOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.OPP_INICIATIVAEMP_RT).getRecordTypeId();
        
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,
            CIBE_AppConstants.CIBE_CUSTOMMETADATA,
            CIBE_AppConstants.CIBE_ANALYTICS,
            CIBE_AppConstants.CIBE_OPERATIVAEMP, 
            CIBE_AppConstants.USER_AV_AVOIDBULKAPI,
            CIBE_AppConstants.CIBE_INTEGRACION
        };

        CIBE_TestInitialSetup.setupInitialData(null, null, null, null, null, ps);
        User admin = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];

        Account acc = CIBE_TestHelper.createCustomer(admin);
        Product2 prodPF = CIBE_TestHelper.createProduct(null,null);

        Opportunity opp = new Opportunity();
                opp.ownerId = admin.Id;
                opp.RecordTypeId = rtOpp;
                opp.CloseDate = System.today();
                opp.AccountId = acc.Id;
                opp.Name = 'Alerta Comercial Test';
                opp.StageName = 'CIBE_Vencido';
                opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
                opp.AV_PF__c = prodPF.Id;
                opp.CIBE_LastUpdatedCerradoNegativo__c = Date.newInstance(2023, 10, 9);

            insert opp;  

            List<Opportunity> listaOpp = new List<Opportunity>();
            listaOpp.add(opp);
    }


    @isTest
    public static void validateBatch() {
        User admin = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];

        System.runAs(admin) {
			Test.startTest();
                CIBE_OppCerradoNegativoSchedulable batchPrueba = new CIBE_OppCerradoNegativoSchedulable('SELECT Id FROM Opportunity');
                CIBE_OppCerradoNegativoSchedulable batch = new CIBE_OppCerradoNegativoSchedulable();
                Id batchId = Database.executeBatch(batch);
            Test.stopTest();
		}
        List<Opportunity> listOpp = [SELECT id FROM Opportunity WHERE Name = 'Alerta Comercial Test' AND StageName = :CIBE_AppConstants.OPPORTUNITY_STATUS_CERRNEGA AND CIBE_CerradoNegativo__c = 'No gestionada' LIMIT 1];
        System.assertEquals(1, listOpp.size());
    }
    
}