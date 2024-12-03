@isTest
public with sharing class CC_Formulario_Consultas_Operativas_Test {
   
    @TestSetup static void customSetting(){
        CC_Parametrizaciones_Consultas_Operativa__c setting = new CC_Parametrizaciones_Consultas_Operativa__c();
		setting.Name = 'Test Setting';
		setting.CC_Canal_resolucion__c = 'Tarjetas y Comercios';
        setting.CC_Cola__c = 'CC_ConsForm_Tarjetas_Comercios';
        setting.CC_Tematica__c = 'Tarjetas';
        setting.CC_Tematica_CAT__c ='Targetes';
		insert setting;

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        insert cuenta; 	
                
        Contact contacto = new Contact();
        contacto.Email = 'jorge.andres.argente.guillen@ibm.com';
        contacto.CC_Inactivo__c = false;
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        contacto.LastName = 'Plata';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Matricula__c = 'U0152396';
        insert contacto;
        
        
        
        List<String> developerNamesPlantillas = new List<String>{'CC_ConsultasOperativasCanalFormulario_Entrada_CAS','CC_ConsultasOperativasCanalFormulario_Entrada_CAT'};
		List<EmailTemplate> plantillas = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName IN :developerNamesPlantillas];
        List<EmailTemplate> plantillasAInsertar = new List<EmailTemplate>();
        if (plantillas.isEmpty()) {
            
            EmailTemplate plantilla1CAS= new EmailTemplate();
            plantilla1CAS.Developername = 'CC_ConsultasOperativasCanalFormulario_Entrada_CAS';
            plantilla1CAS.HTMLValue= 'hola prueba 2';
            plantilla1CAS.Subject = 'plantilla1CAS';
            plantilla1CAS.FolderId = UserInfo.getUserId();
            plantilla1CAS.TemplateType = 'Text';        
            plantilla1CAS.name = 'CC_ConsultasOperativasCanalFormulario_Entrada_CAS';
            plantilla1CAS.IsActive = true;
            plantillasAInsertar.Add(plantilla1CAS);

            
            EmailTemplate plantilla1CAT= new EmailTemplate();
            plantilla1CAT.Developername = 'CC_ConsultasOperativasCanalFormulario_Entrada_CAT';
            plantilla1CAT.HTMLValue= 'hola prueba 2';
            plantilla1CAT.Subject = 'plantilla1CAT';
            plantilla1CAT.FolderId = UserInfo.getUserId();
            plantilla1CAT.TemplateType = 'Text';        
            plantilla1CAT.name = 'CC_ConsultasOperativasCanalFormulario_Entrada_CAT';
            plantilla1CAT.IsActive = true;
            plantillasAInsertar.Add(plantilla1CAT);
            
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            	insert plantillasAInsertar;
        	}
        }
    }
     
    @isTest
    public static void testCreacionCasoCastellano() {        
        
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        List<String> lstCcAdd = new List<String>();
        String buzonFormularioConsultasOperativas = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Formulario_Consultas_operativas_ESP' LIMIT 1].CC_Direccion_Correo__c;
		List<String> lstToAdd = new List<String>();
        lstToAdd.add('email1@test.com');
        lstToAdd.add(buzonFormularioConsultasOperativas);
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_Formulario_Consultas') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';

		/*header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';*/
        envelope.fromAddress = 'correo@prueba.com';
        envelope.toAddress = buzonFormularioConsultasOperativas;
        correo.subject = 'Asunto';
        correo.fromAddress = 'correo@prueba.com';
        correo.toAddresses = lstToAdd;
        correo.ccAddresses = lstCcAdd;
        correo.htmlBody = 'Lunes 27/12/2021 09:30:00<br><br>nU01: U0152396<br><br>Nombre empleado: MIGUEL BRAVO GUTIERREZ<br><br>Email empleado: jorge.andres.argente.guillen@ibm.com<br><br>Selecciona la temática: Tarjetas<br><br>Detalla tu consulta: Extracto fiscal 2022 PRUEBA<br><br>>Cognitive id: 123456789<br>';
		correo.headers = new List<Messaging.InboundEmail.Header>{header};

        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        correo.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
		// add an Text atatchment
		Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

       
        Test.startTest();
        CC_Formulario_Consultas_Operativas emailServiceConsultasoperativas = new CC_Formulario_Consultas_Operativas();
       	emailServiceConsultasoperativas.handleInboundEmail(correo, envelope);

        Case caso = [SELECT Id FROM Case WHERE Subject = 'Asunto'];    
        Test.stopTest();
        
        System.assertEquals(2, [SELECT Count() FROM EmailMessage WHERE ParentId = :caso.Id]);
    }
    
     @isTest
    public static void testCrearCasoCatalan() {

        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        List<String> lstCcAdd = new List<String>();
        String buzonFormularioConsultasOperativas = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Formulario_Consultas_operativas_ESP' LIMIT 1].CC_Direccion_Correo__c;
		List<String> lstToAdd = new List<String>();
        lstToAdd.add('email1@test.com');
        lstToAdd.add(buzonFormularioConsultasOperativas);
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_Formulario_Consultas') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';

		/*header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';*/
        envelope.fromAddress = 'correo@prueba.com';
        envelope.toAddress = buzonFormularioConsultasOperativas;
        correo.subject = 'Asumpte';
        correo.fromAddress = 'correo@prueba.com';
        correo.toAddresses = lstToAdd;
        correo.ccAddresses = lstCcAdd;
        correo.htmlBody = 'Lunes 27/12/2021 09:30:00<br><br>nU01: U0152396<br><br>Nom empleat: MIGUEL BRAVO GUTIERREZ<br><br>Email empleat: jorge.andres.argente.guillen@ibm.com<br><br>Selecciona la temàtica: Targetes<br><br>Detalla la teva consulta: Extracto fiscal 2022 PRUEBA<br><br>Cognitive id: 123456789<br>';
		correo.headers = new List<Messaging.InboundEmail.Header>{header};

        Test.startTest();
        CC_Formulario_Consultas_Operativas emailServiceConsultasoperativas = new CC_Formulario_Consultas_Operativas();
       	emailServiceConsultasoperativas.handleInboundEmail(correo, envelope);     
        Test.stopTest();
                
        Case caso = [SELECT Id FROM Case WHERE Subject =  'Asumpte'];

        System.assertEquals(2, [SELECT Count() FROM EmailMessage WHERE ParentId = :caso.Id]);
    }
    
    
    
}