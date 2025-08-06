@isTest
public class CSBD_WS_Opportunity_Test {

    @testSetup
    static void setup() {
        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valorPrestamo = new CC_Lista_Valores__c();
        valorPrestamo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorPrestamo.CC_Lista__c = listaValores.Id;
        valorPrestamo.Name = 'Préstamo';
        valorPrestamo.CC_Valor__c = '1';
        CC_Lista_Valores__c valorTpv = new CC_Lista_Valores__c();
        valorTpv.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorTpv.CC_Lista__c = listaValores.Id;
        valorTpv.Name = 'TPV';
        valorTpv.CC_Valor__c = '5';
        insert new List<CC_Lista_Valores__c>{valorPrestamo, valorTpv};

        Pricebook2 listaPrecios = new Pricebook2();
        listaPrecios.Name = 'Standard Price Book';
        Pricebook2 pb = new Pricebook2(Name = 'CSBD Price Book', Description = 'CSBD Price Book', IsActive = true );
        insert new List<Pricebook2>{listaPrecios, pb};

        Account account = (Account)CSBD_TestDataFactory.crearCuentaContacto('12345678Z').get('cuenta');

        Map<String, Object> campos = new Map<String, Object>{
            'Name' => 'oportunidad de prueba',
            'CSBD_Estado__c' => 'Nueva',
            'StageName' => 'Solicitud',
            'AccountId' => account.Id,
            'CSBD_Contact__c' => [SELECT Id FROM Contact WHERE AccountId = :account.Id].Id,
            'CSBD_Telefono_Solicitud__c' => '632999999',
            'CSBD_Now_NIF__c' => account.CC_Numero_Documento__c
        };
        CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
    }

    @isTest
    public static void getOpportunityTest() {
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            RestRequest request = new RestRequest();
            request.requestURI = '/services/apexrest/CSBD_Opportunity/' + opportunity.Id;
            request.httpMethod = 'GET';
            RestContext.request = request;
            RestContext.response = new RestResponse();

            Test.startTest();
            Opportunity result = CSBD_WS_Opportunity.getOpportunity();
            Test.stopTest();
            System.assert(result != null);
        }
    }

}