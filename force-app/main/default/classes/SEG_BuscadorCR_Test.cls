@isTest
public with sharing class SEG_BuscadorCR_Test {
    
    @testSetup
    static void datosIniciales ()
    {        
        // Creación cuentas a tratar.
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111111H';
        insert cuentaSEG1; 

        SEG_ClasificacionRapida__c regla3 = new SEG_ClasificacionRapida__c();
        regla3.Name = 'CR3';
        regla3.SEG_CRContratos__c  = false;
        regla3.CBK_Negocio__c = 'Segmentos';
        insert regla3;

        Case caso1 = new Case();
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso1.AccountId = cuentaSEG1.Id;
        caso1.SEG_Idioma__c = 'es';
        caso1.CC_AcuseRecibo__c ='0';
        caso1.Subject = 'test 1';
        caso1.Status = 'Activo';
        caso1.SEG_Zona__c = 'Corporativa';
        caso1.SEG_Organizacion__C = 'Banca Corporativa';
        caso1.SEG_N_operaciones_del_caso__c = 3.0;
        insert caso1;
    }
    
    @isTest
    public static void buscadorCR_OK()
    {
        Test.startTest();
        
        	List<Object> resultados = SEG_BuscadorCR.querySalesforceRecord('SELECT Id FROM Account LIMIT 1','test1');
        
        Test.stopTest();

		System.assert(resultados.size() == 1);
    }
    
    @isTest
    public static void buscadorCR_SinQuery()
    {
        Test.startTest();
        
        	List<Object> resultados = SEG_BuscadorCR.querySalesforceRecord('','');
        
        Test.stopTest();

		System.assert(resultados.size() == 0);
    }

    @isTest
    public static void actualizarCasoOK()
    {
        Case caso1 = [SELECT Id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        SEG_ClasificacionRapida__c cr1 = [SELECT Id FROM SEG_ClasificacionRapida__c WHERE Name = 'CR3' LIMIT 1];

        Test.startTest();
        
        	SEG_BuscadorCR.updateCaseCR(caso1.Id, cr1.Id);
        
        Test.stopTest();

        caso1 = [SELECT Id, SEG_ClasificacionRapida__c FROM Case WHERE Subject = 'test 1' LIMIT 1];

		System.assert(caso1.SEG_ClasificacionRapida__c == cr1.Id);
    }

    @isTest
    public static void actualizarCasoKO()
    {
        Boolean bOK = true;

        Test.startTest();
        
            try{
                SEG_BuscadorCR.updateCaseCR(null,null);
            }catch(Exception e){
                bOK = false;
            }        	
        
        Test.stopTest();

		System.assert(bOk == false);
    }
}