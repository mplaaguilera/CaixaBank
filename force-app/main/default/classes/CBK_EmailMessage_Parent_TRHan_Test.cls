@isTest
private class CBK_EmailMessage_Parent_TRHan_Test{

	@isTest
	private static void testEntrada() {

		CBK_ActivateParenHan_Test__c conf = new CBK_ActivateParenHan_Test__c(name = 'ActivarHandlerTest', Active__c = true);
		insert conf;

		List<EmailServicesAddress> headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'AM_%' LIMIT 1];
		String headerValueStr = 'test@p-18nbt53xompbolkephezu961v8dyxkay8s2tvjsaow1i4i5stv.0q-1vnyua2.cs109.apex.sandbox.salesforce.com';
        if (headerValue != null && headerValue.size() > 0){
			headerValueStr = headerValue[0].LocalPart +'@'+ headerValue[0].EmailDomainName;
		}

		List<EmailMessage> lst = new List<EmailMessage> ();
		Set<string> sIds = new Set<string> ();
		EmailMessage correo = new EmailMessage();
		correo.Incoming = true;
		correo.Subject = 'EMAILENTRADA';
		correo.TextBody = 'EMAILENTRADA';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.CC_Procedencia__c = 'Remitir Colaboradorfdasdfa';
		correo.ToAddress = 'test@p-18nbt53xompbolkephezu961v8dyxkay8s2tvjsaow1i4i5stv.0q-1vnyua2.cs109.apex.sandbox.salesforce.com';
		//correo.Headers = '[{"value": "test@p-18nbt53xompbolkephezu961v8dyxkay8s2tvjsaow1i4i5stv.0q-1vnyua2.cs109.apex.sandbox.salesforce.com","name": "X-SFDC-Original-RCPT"}]';
		correo.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
		lst.add(correo);
		sIds.add(correo.Id);

		correo = new EmailMessage();
		correo.Incoming = true;
		correo.Subject = 'EMAILENTRADA1';
		correo.TextBody = 'EMAILENTRADA1';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.CC_Procedencia__c = 'Remitir Colaboradorfdasdfa';
		correo.Headers = '[{"value": "test@p-18nbt53xompbolkephezu961v8dyxkay8s2tvjsaow1i4i5stv.0q-1vnyua2.cs109.apex.sandbox.salesforce.com","name": "X-SFDC-Original-RCPT"}]';
		correo.ToAddress = 'test@p-18nbt53xompbolkephezu961v8dyxkay8s2tvjsaow1i4i5stv.0q-1vnyua2.cs109.apex.sandbox.salesforce.com';
		lst.add(correo);
		sIds.add(correo.Id);

		correo = new EmailMessage();
		correo.Incoming = true;
		correo.Subject = 'EMAILENTRADA2';
		correo.TextBody = 'EMAILENTRADA2';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.CC_Procedencia__c = 'Remitir Colaboradorfdasdfa';
		correo.ToAddress = 'PruebaOtro@test.com';
		correo.Headers = '[{"value": "Prueba@IBM","name": "X-SFDC-Original-RCPT"}]';
		lst.add(correo);
		sIds.add(correo.Id);

		correo = new EmailMessage();
		correo.Incoming = true;
		correo.Subject = 'EMAILENTRADA2';
		correo.TextBody = 'EMAILENTRADA2';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.CC_Procedencia__c = 'Remitir Colaboradorfdasdfa';
		correo.ToAddress = 'PruebaOtro@test.com';
		correo.Headers = '[{"value": "Prueba@IBM22","name": "X-SFDC-Original-RCPT"}]';
		lst.add(correo);
		sIds.add(correo.Id);

		CC_TriggerParameters tp = new CC_TriggerParameters();
		tp.newList = lst;
		Test.startTest();
		CBK_EmailMessage_Parent_TRHan tt = new CBK_EmailMessage_Parent_TRHan();
		tt.executeParent(tp, CC_TriggerParameters.TriggerEvent.beforeInsert);

		insert lst;

		lst[1].Subject = 'EMAILENTRADA2';
		update lst;

		delete lst[1];
		Test.stopTest();

		List<EmailMessage> lstEM = [SELECT Id FROM EmailMessage WHERE Subject in('EMAILENTRADA')];
		System.assertEquals(lstEM.size(), 1);
	}

	@isTest
	private static void testSalida() {
		CBK_ActivateParenHan_Test__c conf = new CBK_ActivateParenHan_Test__c(name = 'ActivarHandlerTest', Active__c = true);
		insert conf;
		List<Case> lstCase = createCaseData();
		
		SAC_Interaccion__c iteraccion = new SAC_Interaccion__c();
        iteraccion.SAC_Propuesta__c = 'propuesta test';
        iteraccion.recordTypeId = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Escalado').getRecordTypeId();
        iteraccion.SAC_Estado__c = 'SAC_PendienteRespuesta';
        iteraccion.SAC_Email1__c = 'testingcorreo@test.test';
        insert iteraccion;

		SAC_ParametrizacionEscalado__c parametrizacionEscalado = new SAC_ParametrizacionEscalado__c();
        parametrizacionEscalado.Name='Validacion Escalado AJ';
        parametrizacionEscalado.Aplica_escalado__c=true;
        parametrizacionEscalado.SAC_Importe__c=200;
        parametrizacionEscalado.SAC_Mensaje__c= 'Mensaje';
        parametrizacionEscalado.SAC_todosMCCs__c =true;
        parametrizacionEscalado.SAC_TodosDespachos__c = true;
        parametrizacionEscalado.SAC_validarImporte__c = false;
		insert parametrizacionEscalado;

		Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
		CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
		grupoColab.Name = 'Grupo Colaborador Temporal';
		grupoColab.RecordTypeId = recordTypeGrupoColaborador;
		grupoColab.CC_External__c = 'GC-00001';
		insert grupoColab;

		List<EmailMessage> lstEm = new List<EmailMessage> ();
		EmailMessage correo = new EmailMessage();
		correo.ParentId = lstCase[1].Id;
		correo.RelatedToId = lstCase[1].Id;
		correo.Incoming = false;
		correo.Subject = 'EMAILCASO';
		correo.TextBody = 'EMAILCASO';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.CC_Procedencia__c = 'Remitir Colaboradorfdasdfa';
		correo.CC_Grupo_Colab__c = grupoColab.Name;
		correo.ToAddress = 'prueba@ibm.com';
		lstEm.add(correo);

		correo = new EmailMessage();
		correo.ParentId = lstCase[2].Id;
		correo.RelatedToId = lstCase[2].Id;
		correo.Incoming = false;
		correo.Subject = 'EMAILCASO2';
		correo.TextBody = 'EMAILCASO2';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.CC_Procedencia__c = 'Remitir Colaboradorfdasdfa';
		correo.CC_Grupo_Colab__c = grupoColab.Name;
		correo.ToAddress = 'prueba@ibm.com';
		lstEm.add(correo);

		correo = new EmailMessage();
		correo.ParentId = lstCase[0].Id;
		correo.RelatedToId = lstCase[0].Id;
		correo.Incoming = false;
		correo.Subject = 'EMAILCASO3';
		correo.TextBody = 'EMAILCASO3';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.CC_Procedencia__c = 'Remitir Colaboradorfdasdfa';
		correo.CC_Grupo_Colab__c = grupoColab.Name;
		correo.ToAddress = 'prueba@ibm.com';
		lstEm.add(correo);

		string idRecordType = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
		List<Opportunity> lstoportunidad = new List<Opportunity> ();
		Opportunity oportunidad = new Opportunity();
		oportunidad.RecordTypeId = idRecordType;
		oportunidad.Name = 'temp';
		oportunidad.StageName = 'Solicitud';
		oportunidad.CloseDate = System.today().addDays(4);
		lstoportunidad.add(oportunidad);

		string idRecordType2 = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Hipoteca').getRecordTypeId();

		Opportunity oportunidad2 = new Opportunity();
		oportunidad2.RecordTypeId = idRecordType2;
		oportunidad2.Name = 'temp2';
		oportunidad2.StageName = 'Solicitud2';
		oportunidad2.CloseDate = System.today().addDays(4);
		lstoportunidad.add(oportunidad2);
		insert lstoportunidad;

		correo = new EmailMessage();
		correo.RelatedToId = lstoportunidad[0].Id;
		correo.Incoming = false;
		correo.Subject = 'OPORTUN';
		correo.TextBody = 'OPORTUN';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.CC_Procedencia__c = 'Remitir Colaboradorfdasdfa';
		correo.CC_Grupo_Colab__c = grupoColab.Name;
		correo.ToAddress = 'prueba2@ibm.com';
		lstEm.add(correo);

		correo = new EmailMessage();
		correo.RelatedToId = lstoportunidad[1].Id;
		correo.Incoming = false;
		correo.Subject = 'OPORTUN2';
		correo.TextBody = 'OPORTUN2';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.CC_Procedencia__c = 'Remitir Colaboradorfdasdfa';
		correo.CC_Grupo_Colab__c = grupoColab.Name;
		correo.ToAddress = 'prueba2@ibm.com';
		lstEm.add(correo);

		Account acc = new Account();
		acc.FirstName = 'Prueba';
		acc.LastName = 'Test';
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
		acc.CC_Numero_Documento__c = '45855598S';
		acc.CC_NumPerso__c = '533752';
		insert acc;

		correo = new EmailMessage();
		correo.RelatedToId = acc.Id;
		correo.Incoming = false;
		correo.Subject = 'EMAILACC';
		correo.TextBody = 'EMAILACC';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.CC_Procedencia__c = 'Remitir Colaboradorfdasdfa';
		correo.CC_Grupo_Colab__c = grupoColab.Name;
		correo.ToAddress = 'prueba2@ibm.com';
		lstEm.add(correo);

		correo = new EmailMessage();
		correo.RelatedToId = acc.Id;
		correo.Incoming = false;
		correo.Subject = 'EMAILACC2';
		correo.TextBody = 'EMAILACC2';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.CC_Procedencia__c = 'Remitir Colaboradorfdasdfa';
		correo.CC_Grupo_Colab__c = grupoColab.Name;
		correo.ToAddress = 'prueba2@ibm.com';
		lstEm.add(correo);

		correo = new EmailMessage();
		correo.RelatedToId = iteraccion.Id;
		correo.Incoming = false;
		correo.Subject = 'EMAIL Iter';
		correo.TextBody = 'EMAIL Iter';
		correo.HtmlBody = 'BODEY TEST';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.CC_Procedencia__c = 'Remitir Colaboradorfdasdfa';
		correo.CC_Grupo_Colab__c = grupoColab.Name;
		correo.ToAddress = 'prueba@ibm.com';
		lstEm.add(correo);

		correo = new EmailMessage();
		correo.RelatedToId = iteraccion.Id;
		correo.Incoming = false;
		correo.HtmlBody = 'BODEY TEST';
		correo.Subject = 'EMAIL Iter2';
		correo.TextBody = 'EMAIL Iter2';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.CC_Procedencia__c = 'Remitir Colaboradorfdasdfa';
		correo.CC_Grupo_Colab__c = grupoColab.Name;
		correo.ToAddress = 'prueba@ibm.com';
		lstEm.add(correo);

		CC_TriggerParameters tp = new CC_TriggerParameters();
		tp.newList = lstEm;

		Test.startTest();
		CBK_EmailMessage_Parent_TRHan tt = new CBK_EmailMessage_Parent_TRHan();
		tt.executeParent(tp, CC_TriggerParameters.TriggerEvent.beforeInsert);

		insert lstEm;
		Test.stopTest();
		List<EmailMessage> lstEM2 = [SELECT Id FROM EmailMessage WHERE Subject in('EMAILCASO')];

		System.assertEquals(lstEM2.size(), 1);
	}

	@isTest
	private static void testKO1() {
		EmailMessage correo = new EmailMessage();
		List<EmailMessage> lstEm = new List<EmailMessage> ();
		correo.Incoming = false;
		correo.Subject = 'KO TRDISP';
		correo.TextBody = 'KO TRDISP';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.CC_Procedencia__c = 'Remitir Colaboradorfdasdfa';
		correo.ToAddress = 'prueba2@ibm.com';
		lstEm.add(correo);
		CC_TriggerParameters tp = new CC_TriggerParameters();
		tp.newList = null;

		CC_EmailMessage_TRDisp dis = new CC_EmailMessage_TRDisp();
		try{
			dis.beforeInsert(tp);
		}catch(Exception e){
			System.assertEquals(tp.newList, null);
		}
		
	}
	@isTest
	private static void testKO2() {
		EmailMessage correo = new EmailMessage();
		List<EmailMessage> lstEm = new List<EmailMessage> ();
		correo.Incoming = false;
		correo.Subject = 'KO TRDISP1 ';
		correo.TextBody = 'KO TRDISP1';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.CC_Procedencia__c = 'Remitir Colaboradorfdasdfa';
		correo.ToAddress = 'prueba2@ibm.com';
		lstEm.add(correo);
		CC_TriggerParameters tp = new CC_TriggerParameters();
		tp.newList = null;

		CC_EmailMessage_TRDisp dis = new CC_EmailMessage_TRDisp();
		try{
			dis.afterInsert(tp);
		}catch(Exception e){
			System.assertEquals(tp.newList, null);
		}
		
	}
	
	private static List<Case> createCaseData() {
		string rtId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
		string rtId2 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		string rtId3 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

		List<Case> lstCase = new List<Case> ();
		Case caso = new Case();
		caso.Origin = 'phone';
		caso.Description = 'test1';
		caso.RecordTypeId = rtId;
		caso.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
		caso.CC_Tipo_Contacto__c = 'Asesoramiento';
		lstCase.add(caso);

		Case caso2 = new Case();
		caso2.Origin = 'Email';
		caso2.Description = 'test2';
		caso2.RecordTypeId = rtId2;
		caso2.CC_Canal_Procedencia__c = 'Formulario web';
		caso2.CC_Tipo_Contacto__c='Consulta';
		lstCase.add(caso2);

		Case caso3 = new Case();
		caso3.Origin = 'Chat';
		caso3.Description = 'test3';
		caso3.RecordTypeId = rtId3;
		caso3.CC_Canal_Procedencia__c = 'Web';
		caso3.CC_Tipo_Contacto__c = 'Consulta';
		lstCase.add(caso3);
		insert lstCase;
		return lstCase;	
	}

	@isTest
	private static void testemailHeader(){
		List<CBK_EmailMessage_Parent_TRHan.HeaderDTO> lstheader =  new List<CBK_EmailMessage_Parent_TRHan.HeaderDTO>();
		CBK_EmailMessage_Parent_TRHan.HeaderDTO header =  new CBK_EmailMessage_Parent_TRHan.HeaderDTO();
		header.name = 'X-SFDC-Original-RCPT';
		header.value = 'email@test.com';
		lstheader.add(header);
		String email = CBK_EmailMessage_Parent_TRHan.getToAddresHeader(JSON.serialize(lstheader));
		System.assertEquals(email, 'email@test.com');

		String header2 = 'X-SFDC-Original-RCPT: email@test.com\nTest: dfasdfasdfa\n';
		CBK_EmailMessage_Parent_TRHan.getToAddresHeader(header2, '', new List<String>());

		List<EmailServicesAddress> lstEmailCase = [SELECT Id,LocalPart,  EmailDomainName,Function.FunctionName,DeveloperName FROM EmailServicesAddress where Function.FunctionName = 'EmailToCase'];	
		List<String> lstemails =  new List<string>();
		for(EmailServicesAddress em : lstEmailCase){
			lstemails.add(em.LocalPart + '@' + em.EmailDomainName);
		}
		if(lstemails.isEmpty()){
			lstemails.add('email@test.com;email2@test.com');
		}
		CBK_EmailMessage_Parent_TRHan.getToAddresHeader('', lstemails[0], lstemails);
	}
	@isTest
	private static void testSalidaSACObjects(){
		Case caso = new Case();
		caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();  
		caso.SAC_Naturaleza__c = 'SAC_004';
		caso.Subject = 'Test';
		Insert caso ;

		SAC_Accion__c tarea = new SAC_Accion__c();
		tarea.SAC_Estado__c = 'SAC_PendienteEnviar';
		tarea.SAC_Reclamacion__c = caso.Id;
		tarea.recordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_MaestroDeTareas').getRecordTypeId();
		Insert tarea;

		SAC_Accion__c tarea2 = new SAC_Accion__c();
		tarea2.SAC_Estado__c = 'SAC_PendienteEnviar';
		tarea2.SAC_Reclamacion__c = caso.Id;
		tarea2.recordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_OtrasTareas').getRecordTypeId();
		Insert tarea2;

		SAC_Alerta__c alerta = new SAC_Alerta__c();
		alerta.SAC_Reclamacion__c = caso.Id;
		alerta.RecordTypeId = Schema.SObjectType.SAC_Alerta__c.getRecordTypeInfosByDeveloperName().get('SAC_Alerta').getRecordTypeId();
		insert alerta;


		SAC_Interaccion__c iteraccion = new SAC_Interaccion__c();
		iteraccion.SAC_Propuesta__c = 'propuesta test';
		iteraccion.recordTypeId = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Escalado').getRecordTypeId();
		iteraccion.SAC_Estado__c = 'SAC_PendienteRespuesta';
		iteraccion.SAC_Email1__c = 'testingcorreo@test.test';
		insert iteraccion;




		//Accion
		List<EmailMessage> lstMsg = new List<EmailMessage>();
		EmailMessage correo = new EmailMessage();
		correo.RelatedToId = tarea.Id;
		correo.Incoming = false;
		correo.Subject = 'EMAIL ACCION SAC_MaestroDeTareas';
		correo.TextBody = 'EMAIL ACCION SAC_MaestroDeTareas';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.ToAddress = 'prueba@ibm.com';
		lstMsg.add(correo);
		correo = new EmailMessage();
		correo.RelatedToId = tarea.Id;
		correo.Incoming = false;
		correo.Subject = 'EMAIL ACCION SAC_MaestroDeTareas 2';
		correo.TextBody = 'EMAIL ACCION SAC_MaestroDeTareas 2';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.ToAddress = 'prueba@ibm.com';
		lstMsg.add(correo);

		correo = new EmailMessage();
		correo.RelatedToId = tarea2.Id;
		correo.Incoming = false;
		correo.Subject = 'EMAIL OTROS SAC_OtrasTareas';
		correo.TextBody = 'EMAIL OTROS SAC_OtrasTareas';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.ToAddress = 'prueba@ibm.com';
		lstMsg.add(correo);

		correo = new EmailMessage();
		correo.RelatedToId = tarea2.Id;
		correo.Incoming = false;
		correo.Subject = 'EMAIL OTROS SAC_OtrasTareas 2';
		correo.TextBody = 'EMAIL OTROS SAC_OtrasTareas 2';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.ToAddress = 'prueba@ibm.com';
		lstMsg.add(correo);


		///Alert
		correo = new EmailMessage();
		correo.RelatedToId = alerta.Id;
		correo.Incoming = false;
		correo.Subject = 'EMAIL ALERTA SAC_Alerta';
		correo.TextBody = 'EMAIL ALERTA SAC_Alerta';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.ToAddress = 'prueba@ibm.com';
		lstMsg.add(correo);
		correo = new EmailMessage();
		correo.RelatedToId = alerta.Id;
		correo.Incoming = false;
		correo.Subject = 'EMAIL ALERTA SAC_Alerta 2';
		correo.TextBody = 'EMAIL ALERTA SAC_Alerta 2';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.ToAddress = 'prueba@ibm.com';
		lstMsg.add(correo);



		// Iteraccion 
		correo = new EmailMessage();
		correo.RelatedToId = iteraccion.Id;
		correo.Incoming = false;
		correo.Subject = 'EMAIL ITERACCION SAC_Escalado';
		correo.TextBody = 'EMAIL ITERACCION SAC_Escalado';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.ToAddress = 'prueba@ibm.com';
		lstMsg.add(correo);

		correo = new EmailMessage();
		correo.RelatedToId = iteraccion.Id;
		correo.Incoming = false;
		correo.Subject = 'EMAIL ITERACCION SAC_Escalado 2';
		correo.TextBody = 'EMAIL ITERACCION SAC_Escalado 2';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.ToAddress = 'prueba@ibm.com';
		lstMsg.add(correo);
		insert lstMsg;

	}

	@isTest
	private static void testGenerateOldlist(){
		List<EmailMessage> lstMsg = new List<EmailMessage>();
		EmailMessage correo = new EmailMessage();
		correo.Incoming = false;
		correo.Subject = 'EMAIL ACCION SAC_MaestroDeTareas';
		correo.TextBody = 'EMAIL ACCION SAC_MaestroDeTareas';
		correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
		correo.ToAddress = 'prueba@ibm.com';
		lstMsg.add(correo);

		//CBK_EmailMessage_Parent_TRHan.generateOldList(lstMsg, mapaCorreosOld);
	}
		
}