@isTest
public with sharing class AV_CreateOpportunityCallMe_Test {
    @TestSetup
	static void setup(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
            List<User> Usersinsert = new List<User>();
            User userTest = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank', 'U0009003', null);
            //User withoutManagerUser = AV_TestHelper.createUserSinGestorSinInsert('test');
            Usersinsert.add(userTest);
            //Usersinsert.add(withoutManagerUser);
            insert Usersinsert;

            Account centerCaixaTest = AV_TestHelper.createCaixaCenterSinInsert();
            centerCaixaTest.CC_Numero_Oficina__c = '04563';
            insert centerCaixaTest;
            Contact employeeCaixaTest = AV_TestHelper.createEmployee(centerCaixaTest, userGcf);
            Account clientTest = createCustomerWithEAPGestorSinInsert(employeeCaixaTest);
	        clientTest.OwnerId = userTest.Id;
            insert clientTest;

            List<CC_Lista_Valores__c> listValues = new List<CC_Lista_Valores__c>();
            RecordType rtList = AV_AppUtilities.getRecordType('CC_Lista_Valores__c', 'CC_Lista_Valores');
            CC_Lista_Valores__c listV = new CC_Lista_Valores__c();
            listV.Name = 'CSBD: Relación de valores Now - Salesforce: Empresa, familia y producto';
            listV.RecordTypeId = rtList.Id;
        
            RecordType rt = AV_AppUtilities.getRecordType('CC_Lista_Valores__c', 'CC_Valor');
            CC_Lista_Valores__c listValue = new CC_Lista_Valores__c();
            listValue.CC_Lista__c = listV.Id;
            listValue.Name = 'MyBoxVida';
            listValue.RecordTypeId = rt.Id;

            listValues.add(listV);
            listValues.add(listValue);
            insert listValues;
        }
       
    }
    @isTest
    public static void oppCallMeImaginTest() {
        
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        
        Product2 prodPF = AV_TestHelper.createProduct(null,null);
        
        Test.startTest();
        List<AV_PilotCenters__c> listCentrosPiloto = new List<AV_PilotCenters__c>();
        AV_PilotCenters__c centrosPiloto = new AV_PilotCenters__c();
        centrosPiloto.Name = 'Centros_Piloto';
        centrosPiloto.AV_OfficeNumber__c = '00002, 00035, 00654';
        AV_PilotCenters__c centrosPiloto2 = new AV_PilotCenters__c();
        centrosPiloto2.Name = 'Centros_Piloto2';
        centrosPiloto2.AV_OfficeNumber__c = '00302, 02035, 00354';

        listCentrosPiloto.add(centrosPiloto);
        listCentrosPiloto.add(centrosPiloto2);

        insert listCentrosPiloto;
        
        String jsonOppCallme = '{"solicitudes": [{"agenteInTouch": "","apellidos": "FERNANDEZ","apellidos_2": "","boton": "CMN_Suri","canal": "portal","codProducto": "","colectivo": "","fraccionamiento": "","horaFin": "8","horaIni": "5","idProducto": "MyBoxVida","importeTotal": "","indInTouch": "S","margen": "","minFin": "0","minIni": "0","nif": "45935864B","nombre": "ORIOL ALEJANDRO DE ARMAS FERNANDEZ","nombre2": "ORIOL ALEJANDRO","nombreProducto": "","NUMPERSO": "7B","origen": "imagin","proceso": "CMB/1","referencia_usuario": "PST20230215031737974974","reserva1": "","reserva2": "","subproducto_1": "","telefono": "666666666","timestamp": "20230215031737","tipoCliente": "L","tipoContacto": "C","tipoLlamada": "1","tipoPago": "","tipoSolicitud": "cmb"}]}';
	    String jsonOppCallme2 = '{"solicitudes": [{"agenteInTouch": "","apellidos": "FERNANDEZ","apellidos_2": "","boton": "CMN_Suri","canal": "notportal","codProducto": "","colectivo": "","fraccionamiento": "","horaFin": "18","horaIni": "15","idProducto": "MyBoxVida","importeTotal": "","indInTouch": "N","margen": "","minFin": "00","minIni": "00","nif": "45935864B","nombre": "ORIOL ALEJANDRO DE ARMAS FERNANDEZ","nombre2": "ORIOL ALEJANDRO","nombreProducto": "","NUMPERSO": "7B","origen": "imagin","proceso": "CMB/1","referencia_usuario": "PST20230215031737974974","reserva1": "","reserva2": "","subproducto_1": "","telefono": "666666666","timestamp": "20230215031737","tipoCliente": "L","tipoContacto": "C","tipoLlamada": "1","tipoPago": "","tipoSolicitud": "cmb"}]}';
        String jsonOppCallme3 = '{"solicitudes": [{"agenteInTouch": "","apellidos": "FERNANDEZ","apellidos_2": "","boton": "CMN_Suri","canal": "notportal","codProducto": "","colectivo": "","fraccionamiento": "","horaFin": "18","horaIni": "15","idProducto": "MyBoxVida","importeTotal": "","indInTouch": "S","margen": "","minFin": "00","minIni": "00","nif": "45935864B","nombre": "ORIOL ALEJANDRO DE ARMAS FERNANDEZ","nombre2": "ORIOL ALEJANDRO","nombreProducto": "","NUMPERSO": "","origen": "imagin","proceso": "CMB/1","referencia_usuario": "PST20230215031737974974","reserva1": "","reserva2": "","subproducto_1": "","telefono": "666666666","timestamp": "20230215031737","tipoCliente": "L","tipoContacto": "C","tipoLlamada": "1","tipoPago": "","tipoSolicitud": "cmb"}]}';

        //Contact withoutManager = [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE AV_UsuarioAsociado__r.Profile.Name = 'API Only' AND AV_UsuarioAsociado__r.Alias = 'AV-TF9' LIMIT 1];
        
        
        system.runAs(userGcf){
                 AV_CreateOpportunityCallMe.createOpp(jsonOppCallme, '04563');
                 AV_CreateOpportunityCallMe.createOpp(jsonOppCallme2, '04563');
                 AV_CreateOpportunityCallMe.createOpp(jsonOppCallme3, '04263');
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
        List<CC_Lista_Valores__c> listValores = new List<CC_Lista_Valores__c>();
        RecordType rtList = AV_AppUtilities.getRecordType('CC_Lista_Valores__c', 'CC_Lista_Valores');
        CC_Lista_Valores__c listV = new CC_Lista_Valores__c();
        listV.Name = 'CSBD: Blacklist';
        listV.RecordTypeId = rtList.Id;
        listV.CC_Activa__c = true;
        
        
        RecordType rt = AV_AppUtilities.getRecordType('CC_Lista_Valores__c', 'CC_Valor');
        CC_Lista_Valores__c listValue = new CC_Lista_Valores__c();
        listValue.CC_Lista__c = listV.Id;
        listValue.CC_Activa__c = true;
        listValue.Name = '45935864B';
        listValue.RecordTypeId = rt.Id;
        listValue.CC_Valor__c = 'NIF';
        
        listValores.add(listV);
        listValores.add(listValue);

        insert listValores;
                
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

    public static Account createCustomerWithEAPGestorSinInsert(Contact gestor) {
        RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
        Account acc = new Account(
                FirstName = 'FirstName',
                LastName = 'LastName',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '123',
                AV_Negocio__c = 'BPA'
            );
        if (gestor != null) {
            acc.AV_EAPGestor__c = gestor.Id;
        }
        return acc;
    }
}