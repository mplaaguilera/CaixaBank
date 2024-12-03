@isTest
public with sharing class AV_CreateOpportunityCallMe_Test {

    @isTest
    public static void oppCallMeImaginTest() {
        
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];

        User userTest = AV_TestHelper.createUser('AV_Usuario_CaixaBank');
        User withoutManagerUser = AV_TestHelper.createUserSinGestorSinInsert('test');
        insert withoutManagerUser;
        Account centerCaixaTest = AV_TestHelper.createCaixaCenterSinInsert();
        centerCaixaTest.CC_Numero_Oficina__c = '04563';
        upsert centerCaixaTest;
        Contact employeeCaixaTest = AV_TestHelper.createEmployee(centerCaixaTest, withoutManagerUser);
        Account clientTest = AV_TestHelper.createCustomerWithEAPGestor(employeeCaixaTest);
	    clientTest.OwnerId = userTest.Id;
        update clientTest;
        Product2 prodPF = AV_TestHelper.createProduct(null,null);

        RecordType rtList = AV_AppUtilities.getRecordType('CC_Lista_Valores__c', 'CC_Lista_Valores');
        CC_Lista_Valores__c listV = new CC_Lista_Valores__c();
        listV.Name = 'CSBD: Relación de valores Now - Salesforce: Empresa, familia y producto';
        listV.RecordTypeId = rtList.Id;
        insert listV;
        
        RecordType rt = AV_AppUtilities.getRecordType('CC_Lista_Valores__c', 'CC_Valor');
        CC_Lista_Valores__c listValue = new CC_Lista_Valores__c();
        listValue.CC_Lista__c = listV.Id;
        listValue.Name = 'MyBoxVida';
        listValue.RecordTypeId = rt.Id;
        insert listValue;
        
        String jsonOppCallme = '{"solicitudes": [{"agenteInTouch": "","apellidos": "FERNANDEZ","apellidos_2": "","boton": "CMN_Suri","canal": "portal","codProducto": "","colectivo": "","fraccionamiento": "","horaFin": "18","horaIni": "15","idProducto": "MyBoxVida","importeTotal": "","indInTouch": "N","margen": "","minFin": "00","minIni": "00","nif": "45935864B","nombre": "ORIOL ALEJANDRO DE ARMAS FERNANDEZ","nombre2": "ORIOL ALEJANDRO","nombreProducto": "","NUMPERSO": "7B","origen": "imagin","proceso": "CMB/1","referencia_usuario": "PST20230215031737974974","reserva1": "","reserva2": "","subproducto_1": "","telefono": "666666666","timestamp": "20230215031737","tipoCliente": "L","tipoContacto": "C","tipoLlamada": "1","tipoPago": "","tipoSolicitud": "cmb"}]}';
	    String jsonOppCallme2 = '{"solicitudes": [{"agenteInTouch": "","apellidos": "FERNANDEZ","apellidos_2": "","boton": "CMN_Suri","canal": "notportal","codProducto": "","colectivo": "","fraccionamiento": "","horaFin": "18","horaIni": "15","idProducto": "MyBoxVida","importeTotal": "","indInTouch": "N","margen": "","minFin": "00","minIni": "00","nif": "45935864B","nombre": "ORIOL ALEJANDRO DE ARMAS FERNANDEZ","nombre2": "ORIOL ALEJANDRO","nombreProducto": "","NUMPERSO": "7B","origen": "imagin","proceso": "CMB/1","referencia_usuario": "PST20230215031737974974","reserva1": "","reserva2": "","subproducto_1": "","telefono": "666666666","timestamp": "20230215031737","tipoCliente": "L","tipoContacto": "C","tipoLlamada": "1","tipoPago": "","tipoSolicitud": "cmb"}]}';

        Contact withoutManager = [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE AV_UsuarioAsociado__r.Profile.Name = 'API Only' AND AV_UsuarioAsociado__r.Alias = 'AV-TF9' LIMIT 1];
        
        Test.startTest();
        system.runAs(usuCli){
                 AV_CreateOpportunityCallMe.createOpp(jsonOppCallme, '04563');
                 AV_CreateOpportunityCallMe.createOpp(jsonOppCallme2, '04563');
        }
        Test.stopTest();
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'AV_CallMe'];
        system.assertEquals(2, opp.size());

    }
    
    @isTest
    public static void oppCallMeNoClient() {
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];

        String jsonOppCallme = '{"solicitudes": [{"agenteInTouch": "","apellidos": "FERNANDEZ","apellidos_2": "","boton": "CMN_Suri","canal": "notportal","codProducto": "","colectivo": "","fraccionamiento": "","horaFin": "18","horaIni": "15","idProducto": "MyBoxVida","importeTotal": "","indInTouch": "N","margen": "","minFin": "00","minIni": "00","nif": "45935864B","nombre": "ORIOL ALEJANDRO DE ARMAS FERNANDEZ","nombre2": "ORIOL ALEJANDRO","nombreProducto": "","NUMPERSO": "323","origen": "imagin","proceso": "CMB/1","referencia_usuario": "PST20230215031737974974","reserva1": "","reserva2": "","subproducto_1": "","telefono": "666666666","timestamp": "20230215031737","tipoCliente": "L","tipoContacto": "C","tipoLlamada": "1","tipoPago": "","tipoSolicitud": "cmb"}]}';
	    Test.startTest();
        system.runAs(usuCli){

              AV_CreateOpportunityCallMe.createOpp(jsonOppCallme,'04563');
        }
        Test.stopTest();
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'AV_CallMe'];
        system.assertEquals(0, opp.size());
    }
    
    @isTest
    public static void oppCallMeCheckBlackList() {
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];

		CSBD_Campos_blacklist__mdt[] camposComprobarMetadato = [SELECT MasterLabel, CSBD_Campo_API_Name__c FROM CSBD_Campos_blacklist__mdt];
    
        RecordType rtList = AV_AppUtilities.getRecordType('CC_Lista_Valores__c', 'CC_Lista_Valores');
        CC_Lista_Valores__c listV = new CC_Lista_Valores__c();
        listV.Name = 'CSBD: Blacklist';
        listV.RecordTypeId = rtList.Id;
        insert listV;
        
        RecordType rt = AV_AppUtilities.getRecordType('CC_Lista_Valores__c', 'CC_Valor');
        CC_Lista_Valores__c listValue = new CC_Lista_Valores__c();
        listValue.CC_Lista__c = listV.Id;
        listValue.CC_Activa__c = TRUE;
        listValue.Name = '45935864B';
        listValue.RecordTypeId = rt.Id;
        listValue.CC_Valor__c = 'NIF';
        insert listValue;
                
        String jsonOppCallme = '{"solicitudes": [{"agenteInTouch": "","apellidos": "FERNANDEZ","apellidos_2": "","boton": "CMN_Suri","canal": "notportal","codProducto": "","colectivo": "","fraccionamiento": "","horaFin": "18","horaIni": "15","idProducto": "MyBoxVida","importeTotal": "","indInTouch": "N","margen": "","minFin": "00","minIni": "00","nif": "45935864B","nombre": "ORIOL ALEJANDRO DE ARMAS FERNANDEZ","nombre2": "ORIOL ALEJANDRO","nombreProducto": "","NUMPERSO": "323","origen": "imagin","proceso": "CMB/1","referencia_usuario": "PST20230215031737974974","reserva1": "","reserva2": "","subproducto_1": "","telefono": "666666666","timestamp": "20230215031737","tipoCliente": "L","tipoContacto": "C","tipoLlamada": "1","tipoPago": "","tipoSolicitud": "cmb"}]}';
        
        Map<String, Object> jsonOppMap = new Map<String, Object>();
        Map<String,Object> jsonOppMapTest = (Map<String,Object>) JSON.deserializeUntyped(jsonOppCallme);

        for(Object  jsonElement : (List<Object>)jsonOppMapTest.get('solicitudes')){
            jsonOppMap = (Map<String, Object>) jsonElement ;
        }
        
        Map<String, Object> fields = new Map<String, Object>();
        Test.startTest();
        system.runAs(usuCli){
                AV_CreateOpportunityCallMe.checkBlakList(jsonOppMap, fields);
        }
        Test.stopTest();
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'AV_CallMe'];
        system.assertEquals(0, opp.size());
    }
}