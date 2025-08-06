@isTest
public with sharing class SEG_WS_AORActualizarCaso_Test {
    @testSetup
    static void datosIniciales() {

        CC_Grupo_Colaborador__c grupoCol1 = new CC_Grupo_Colaborador__c(
            SEG_Zona__c = 'Corporativa',
            SEG_Organizacion__C = 'Banca Corporativa',
        	Name = 'GrupoSegOp1',
            RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId()
        );
		insert grupoCol1;

        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111171H';
        insert cuentaSEG1;
        
        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.Email = 'test@test.com';
        insert contactoSEG1;
        
        Case caso = new Case(
            AccountId = cuentaSEG1.id,
            SEG_Numero_de_centro__c = cuentaSEG1.id,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId(),
            SEG_Grupo__c = grupoCol1.id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web',
            Status = 'Activo',
            SEG_Subestado__c = 'En curso',
            SEG_Zona__c = 'Corporativa',
            SEG_Organizacion__C = 'Banca Corporativa',
            Subject = 'test 2',
            ContactId = contactoSEG1.Id
        );
        insert caso;
    }

    //Test para actualizar un caso desde ServiceNow añadiendo un comentario al chatter.
	@isTest
    public static void snActualizarCaso_actualizarCaso_Test() {
        
        Case caso = [SELECT Id, CaseNumber, Status, SEG_Subestado__c FROM Case LIMIT 1];

        SEG_WS_AORActualizarCaso.Input datosEntrada = new SEG_WS_AORActualizarCaso.Input();
        datosEntrada.tipoProceso = 'SN1';
        //datosEntrada.origen
        datosEntrada.caseId = String.valueOf(caso.Id);
        //datosEntrada.fechaEvento
        datosEntrada.textoEmail = 'Caso actualizado desde SN';
        datosEntrada.caseNumber = String.valueOf(caso.CaseNumber);
        //datosEntrada.ContenidoAdicional
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/snActualizarCaso/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            SEG_WS_AORActualizarCaso.Output output =  SEG_WS_AORActualizarCaso.snActualizarCaso();
            Test.stopTest();

            Case casoTest = [SELECT Status, SEG_Subestado__c FROM Case LIMIT 1];
            System.assertEquals('Activo', casoTest.Status, 'No se ha actualizado el Status');
            System.assertEquals('Recibida respuesta jurídica', casoTest.SEG_Subestado__c,  'No se ha actualizado el SEG_Subestado__c');
        }
    }

    //Test para actualizar un caso desde ServiceNow al cerrar la petición
	@isTest
    public static void snActualizarCaso_cerrarCaso_Test() {

        Case caso = [SELECT Id, CaseNumber, Status, SEG_Subestado__c FROM Case LIMIT 1];
        
        SEG_WS_AORActualizarCaso.Input datosEntrada = new SEG_WS_AORActualizarCaso.Input();
        datosEntrada.tipoProceso = 'SN2';
        //datosEntrada.origen
        datosEntrada.caseId = String.valueOf(caso.Id);
        //datosEntrada.fechaEvento
        datosEntrada.textoEmail = 'Caso cerrado desde SN';
        datosEntrada.caseNumber = String.valueOf(caso.CaseNumber);
        //datosEntrada.ContenidoAdicional
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/snActualizarCaso/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            SEG_WS_AORActualizarCaso.Output output =  SEG_WS_AORActualizarCaso.snActualizarCaso();
            Test.stopTest();

            Case casoTest = [SELECT Status, SEG_Identificador_AOR__c FROM Case LIMIT 1];
            System.assertEquals(null, casoTest.SEG_Identificador_AOR__c, 'No se ha actualizado el SEG_Identificador_AOR__c');
        }
    }

    //Test para comprobar el mensaje de KO de la integración
	@isTest
    public static void snActualizarCaso_KO_Test() {

        Case caso = [SELECT Id, CaseNumber, Status, SEG_Subestado__c FROM Case LIMIT 1];
        
        SEG_WS_AORActualizarCaso.Input datosEntrada = new SEG_WS_AORActualizarCaso.Input();
        datosEntrada.tipoProceso = 'SN2';
        //datosEntrada.origen
        datosEntrada.caseId = '5005r00000Cf25QAAR';
        //datosEntrada.fechaEvento
        datosEntrada.textoEmail = 'Caso cerrado desde SN';
        datosEntrada.caseNumber = String.valueOf(caso.CaseNumber);
        //datosEntrada.ContenidoAdicional
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/snActualizarCaso/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            SEG_WS_AORActualizarCaso.Output output =  SEG_WS_AORActualizarCaso.snActualizarCaso();
            Test.stopTest();

            Case casoTest = [SELECT Status, SEG_Subestado__c FROM Case LIMIT 1];
            System.assertEquals('KO', output.resultado, 'La prueba debería de haber dado KO');
            System.assertEquals('No se encuentra el Caso', output.mensaje, 'El mensaje de KO no es correcto');
        }
    }
}