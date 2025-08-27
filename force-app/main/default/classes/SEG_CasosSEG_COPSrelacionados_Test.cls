@isTest
public with sharing class SEG_CasosSEG_COPSrelacionados_Test {

    @TestSetup
    static void cargaDeDatos(){
        User operador = OS_Usuarios.usuarioOperador();

        Id businessHoursId;
        BusinessHours[] stdBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = 'Default' AND IsActive = true];
        businessHoursId = stdBusinessHours[0].Id;
        if(stdBusinessHours.isEmpty()){
            businessHoursId = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1].Id;
        }

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        insert cuenta;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto01';
        contacto.LastName = 'Contacto01'; 
        contacto.CC_NumPerso__c = '25345561';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'correo@prueba.com';
        insert contacto;

        Contact contacto2 = new Contact();
        contacto2.FirstName = 'Contacto02';
        contacto2.LastName = 'Contacto02';
        contacto2.CC_NumPerso__c = '25345562';
        contacto2.AccountId = cuenta.Id;
        contacto2.CC_Idioma__c = 'Es';
        contacto2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto2.Email = 'correo2@prueba.com';
        insert contacto2;

        CC_MCC__c tematica = new CC_MCC__c();
		tematica.Name = 'tematica cops test';
        tematica.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        tematica.CC_Fecha_Vigencia_Inicio__c = System.now();
        tematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c','CC_Tematica');
        tematica.CC_Codigo_Externo__c = 'TEC-000001';
        tematica.OS_Departamento__c = 'UAC';
        tematica.OS_Horario__C= businessHoursId;
        insert tematica;

        CC_MCC__c producto = new CC_MCC__c();
        producto.Name = 'producto cops test';
        producto.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        producto.CC_Fecha_Vigencia_Inicio__c = System.now();
        producto.RecordTypeId =  CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c','CC_Producto_Servicio');
        producto.CC_Tematica__c = tematica.Id;
        producto.CC_Codigo_Externo__c = 'PRC-000001'; 
        insert producto;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.Name = 'motivo cops test';
        motivo.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        motivo.CC_Fecha_Vigencia_Inicio__c = System.now();
        motivo.RecordTypeId =  CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c','CC_Motivo');
        motivo.CC_Tematica__c = tematica.Id;
        motivo.CC_Producto_Servicio__c = producto.Id;
        motivo.CC_Codigo_Externo__c = 'MOC-000001';
        insert motivo;

        SEG_ClasificacionRapida__c clasRapida = new SEG_ClasificacionRapida__c();
        //clasRapida.SEG_Tematica__c = tematica.Id;
        //clasRapida.SEG_Producto__c = producto.Id;
        //clasRapida.SEG_Motivo__c = motivo.Id; //
        clasRapida.OS_EstadoCaso__c = 'Activo';
        clasRapida.CBK_Negocio__c = 'Cops';
        clasRapida.SEG_Prioridad__c = 'Low';
        clasRapida.SEG_Inactiva__c = false;
        insert clasRapida;

        List<SEG_Regladeclasificacion__c> listaClasificaciones = new List <SEG_Regladeclasificacion__c>();
        SEG_Regladeclasificacion__c regClas = new SEG_Regladeclasificacion__c();
        regClas.CBK_Negocio__c = 'Cops';
        regClas.OS_AgrupacionBuzon__c = 'Buzón CCI Holabank';
        regClas.SEG_Inactiva__c = false;
        regClas.SEG_ClasificacionRapida__c = clasRapida.id;
        regClas.OS_Logica_Multivalor__c = 'OR'; 
        listaClasificaciones.add(regClas);

        SEG_Regladeclasificacion__c regClas2 = new SEG_Regladeclasificacion__c();
        regClas2.CBK_Negocio__c = 'Cops';
        regClas2.OS_AgrupacionBuzon__c = 'Buzón CCI Holabank';
        regClas2.SEG_Inactiva__c = false;
        regClas2.SEG_ClasificacionRapida__c = clasRapida.id;
        regClas2.OS_Logica_Multivalor__c = 'AND'; 
        listaClasificaciones.add(regClas2);
        insert listaClasificaciones;       

        List<SEG_Multivalor__c> listaMultivalores = new List <SEG_Multivalor__c>();
        SEG_Multivalor__c multivalor1 = new SEG_Multivalor__c();
        multivalor1.SEG_Reglas_Clasificacion__c = regClas.id;
        multivalor1.SEG_TipodeValor__c = 'Cuerpo';
        multivalor1.SEG_Valor__c = 'test';
        multivalor1.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor1);

        SEG_Multivalor__c multivalor12 = new SEG_Multivalor__c();
        multivalor12.SEG_Reglas_Clasificacion__c = regClas.id;
        multivalor12.SEG_TipodeValor__c = 'Cuerpo';
        multivalor12.SEG_Valor__c = 'test2';
        multivalor12.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor12);
        
        SEG_Multivalor__c multivalor2 = new SEG_Multivalor__c();
        multivalor2.SEG_Reglas_Clasificacion__c = regClas.id;
        multivalor2.SEG_TipodeValor__c = 'Remitente';
        multivalor2.SEG_Valor__c = 'correo@prueba.com';
        multivalor2.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor2);

        SEG_Multivalor__c multivalor22 = new SEG_Multivalor__c();
        multivalor22.SEG_Reglas_Clasificacion__c = regClas.id;
        multivalor22.SEG_TipodeValor__c = 'Remitente';
        multivalor22.SEG_Valor__c = 'correo2@prueba.com';
        multivalor22.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor22);
        
        SEG_Multivalor__c multivalor3 = new SEG_Multivalor__c();
        multivalor3.SEG_Reglas_Clasificacion__c = regClas.id;
        multivalor3.SEG_TipodeValor__c = 'Asunto';
        multivalor3.SEG_Valor__c = 'asunto';
        multivalor3.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor3);

        SEG_Multivalor__c multivalor32 = new SEG_Multivalor__c();
        multivalor32.SEG_Reglas_Clasificacion__c = regClas.id;
        multivalor32.SEG_TipodeValor__c = 'Asunto';
        multivalor32.SEG_Valor__c = 'asunto2';
        multivalor32.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor32);
        
        SEG_Multivalor__c multivalor4 = new SEG_Multivalor__c();
        multivalor4.SEG_Reglas_Clasificacion__c = regClas.id;
        multivalor4.SEG_TipodeValor__c = 'Destinatario';
        multivalor4.SEG_Valor__c = 'prueba.cci.holabank@salesforce.com';
        multivalor4.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor4);

        SEG_Multivalor__c multivalor42 = new SEG_Multivalor__c();
        multivalor42.SEG_Reglas_Clasificacion__c = regClas.id;
        multivalor42.SEG_TipodeValor__c = 'Destinatario';
        multivalor42.SEG_Valor__c = 'prueba2.cci.holabank@salesforce.com';
        multivalor42.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor42);
        
        SEG_Multivalor__c multivalor5 = new SEG_Multivalor__c();
        multivalor5.SEG_Reglas_Clasificacion__c = regClas.id;
        multivalor5.SEG_TipodeValor__c = 'Destinatario CC';
        multivalor5.SEG_Valor__c = 'prueba.cci.holabank@salesforce.com';
        multivalor5.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor5);

        SEG_Multivalor__c multivalor52 = new SEG_Multivalor__c();
        multivalor52.SEG_Reglas_Clasificacion__c = regClas.id;
        multivalor52.SEG_TipodeValor__c = 'Destinatario CC';
        multivalor52.SEG_Valor__c = 'prueba2.cci.holabank@salesforce.com';
        multivalor52.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor52);

        SEG_Multivalor__c multivalor6 = new SEG_Multivalor__c();
        multivalor6.SEG_Reglas_Clasificacion__c = regClas.id;
        multivalor6.SEG_TipodeValor__c = 'Asunto a excluir';
        multivalor6.SEG_Valor__c = 'asunt0';
        multivalor6.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor6);

        SEG_Multivalor__c multivalor62 = new SEG_Multivalor__c();
        multivalor62.SEG_Reglas_Clasificacion__c = regClas.id;
        multivalor62.SEG_TipodeValor__c = 'Asunto a excluir';
        multivalor62.SEG_Valor__c = 'asunt2';
        multivalor62.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor62);

        SEG_Multivalor__c multivalor7 = new SEG_Multivalor__c();
        multivalor7.SEG_Reglas_Clasificacion__c = regClas.id;
        multivalor7.SEG_TipodeValor__c = 'Destinatario CCO';
        multivalor7.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor7);

        SEG_Multivalor__c multivalor72 = new SEG_Multivalor__c();
        multivalor72.SEG_Reglas_Clasificacion__c = regClas.id;
        multivalor72.SEG_TipodeValor__c = 'Destinatario CCO';
        multivalor72.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor72);

        SEG_Multivalor__c multivalor1prueba = new SEG_Multivalor__c();
        multivalor1prueba.SEG_Reglas_Clasificacion__c = regClas2.id;
        multivalor1prueba.SEG_TipodeValor__c = 'Cuerpo';
        multivalor1prueba.SEG_Valor__c = 'testprueba';
        multivalor1prueba.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor1prueba);

        SEG_Multivalor__c multivalor12prueba = new SEG_Multivalor__c();
        multivalor12prueba.SEG_Reglas_Clasificacion__c = regClas2.id;
        multivalor12prueba.SEG_TipodeValor__c = 'Cuerpo';
        multivalor12prueba.SEG_Valor__c = 'test2prueba';
        multivalor12prueba.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor12prueba);
        
        SEG_Multivalor__c multivalor2prueba = new SEG_Multivalor__c();
        multivalor2prueba.SEG_Reglas_Clasificacion__c = regClas2.id;
        multivalor2prueba.SEG_TipodeValor__c = 'Remitente';
        multivalor2prueba.SEG_Valor__c = 'correo@pruebaprueba.com';
        multivalor2prueba.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor2prueba);

        SEG_Multivalor__c multivalor22prueba = new SEG_Multivalor__c();
        multivalor22prueba.SEG_Reglas_Clasificacion__c = regClas2.id;
        multivalor22prueba.SEG_TipodeValor__c = 'Remitente';
        multivalor22prueba.SEG_Valor__c = 'correo2@prueba.com';
        multivalor22prueba.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor22prueba);
        
        SEG_Multivalor__c multivalor3prueba = new SEG_Multivalor__c();
        multivalor3prueba.SEG_Reglas_Clasificacion__c = regClas2.id;
        multivalor3prueba.SEG_TipodeValor__c = 'Asunto';
        multivalor3prueba.SEG_Valor__c = 'asunto';
        multivalor3prueba.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor3prueba);

        SEG_Multivalor__c multivalor32prueba = new SEG_Multivalor__c();
        multivalor32prueba.SEG_Reglas_Clasificacion__c = regClas2.id;
        multivalor32prueba.SEG_TipodeValor__c = 'Asunto';
        multivalor32prueba.SEG_Valor__c = 'asunto2';
        multivalor32prueba.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor32prueba);
        
        SEG_Multivalor__c multivalor4prueba = new SEG_Multivalor__c();
        multivalor4prueba.SEG_Reglas_Clasificacion__c = regClas2.id;
        multivalor4prueba.SEG_TipodeValor__c = 'Destinatario';
        multivalor4prueba.SEG_Valor__c = 'prueba.cci.holabank@salesforce.com';
        multivalor4prueba.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor4prueba);

        SEG_Multivalor__c multivalor42prueba = new SEG_Multivalor__c();
        multivalor42prueba.SEG_Reglas_Clasificacion__c = regClas2.id;
        multivalor42prueba.SEG_TipodeValor__c = 'Destinatario';
        multivalor42prueba.SEG_Valor__c = 'prueba2.cci.holabank@salesforce.com';
        multivalor42prueba.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor42prueba);
        
        SEG_Multivalor__c multivalor5prueba = new SEG_Multivalor__c();
        multivalor5prueba.SEG_Reglas_Clasificacion__c = regClas2.id;
        multivalor5prueba.SEG_TipodeValor__c = 'Destinatario CC';
        multivalor5prueba.SEG_Valor__c = 'pruebaCorreo@gmail.com';
        multivalor5prueba.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor5prueba);

        SEG_Multivalor__c multivalor52prueba = new SEG_Multivalor__c();
        multivalor52prueba.SEG_Reglas_Clasificacion__c = regClas2.id;
        multivalor52prueba.SEG_TipodeValor__c = 'Destinatario CC';
        multivalor52prueba.SEG_Valor__c = 'prueba2Correo@gmail.com';
        multivalor52prueba.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor52prueba);

        SEG_Multivalor__c multivalor6prueba = new SEG_Multivalor__c();
        multivalor6prueba.SEG_Reglas_Clasificacion__c = regClas2.id;
        multivalor6prueba.SEG_TipodeValor__c = 'Asunto a excluir';
        multivalor6prueba.SEG_Valor__c = 'asunt0';
        multivalor6prueba.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor6prueba);

        SEG_Multivalor__c multivalor62prueba = new SEG_Multivalor__c();
        multivalor62prueba.SEG_Reglas_Clasificacion__c = regClas2.id;
        multivalor62prueba.SEG_TipodeValor__c = 'Asunto a excluir';
        multivalor62prueba.SEG_Valor__c = 'asunt2';
        multivalor62prueba.CBK_Negocio__c = 'Cops';
        listaMultivalores.add(multivalor62prueba);
        insert listaMultivalores;

        List<CC_Lista_Valores__c> listaValores = new List<CC_Lista_Valores__c>();
        CC_Lista_Valores__c lstValores = new CC_Lista_Valores__c();
        lstValores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lstValores.Name = 'COPS: Acuse de recibo por Buzones';
        lstValores.CC_Activa__c = true;
        listaValores.add(lstValores);

        CC_Lista_Valores__c lstValor = new CC_Lista_Valores__c();
        lstValor.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        lstValor.Name = 'Buzón CCI Holabank';
        lstValor.CC_Lista__c  = lstValores.id;
        lstValor.CC_Valor__c = 'Buzón CCI Holabank';
        lstValor.CC_Activa__c = true;
        listaValores.add(lstValor);
        insert listaValores;
	}
	@IsTest
    public static void nuevoHtml(){
		EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE LocalPart LIKE 'SEG_%' LIMIT 1];
        

        User usuarioAdmin =OS_Usuarios.usuarioAdmin();

		List<String> lstCcAdd = new List<String>();
        lstCcAdd.add([SELECT OS_Email__c, OS_Cola_Procedencia__c, OS_Canal_Procedencia__c, OS_Correo__c, OS_Recordtype_Caso_Defecto__c
		FROM OS_Correo__mdt LIMIT 1].OS_Email__c);
        lstCcAdd.add('pruebaCorreo@gmail.com');
		
        List<String> lstToAdd = new List<String>();
        lstToAdd.add([SELECT SEG_Correo_de_procedencia__c
		FROM SEG_Buzon__mdt LIMIT 1].SEG_Correo_de_procedencia__c);

        //Crear un InboundEnvelope e InboundEmail de entrada
		EmailMessage correo = new EmailMessage();
        correo.Subject = 'prueba';
        correo.Incoming = true;
        correo.TextBody = 'cuerpo';
        correo.FromAddress = 'test@mail.com';
        correo.CC_Procedencia__c = 'Traslado Colaborador';
		correo.ToAddress = lstToAdd[0];
		correo.ccAddress = lstCcAdd[0];
		insert correo;
       
		System.debug('::: id mensaje  - '+correo.Id);

		Contact contacto = [SELECT Id, AccountId FROM Contact WHERE Email = 'correo@prueba.com'];
        Contact contacto2 = [SELECT Id, AccountId FROM Contact WHERE Email = 'correo2@prueba.com'];
		CC_MCC__c mccs =[SELECT Id, CC_Producto_Servicio__c, CC_Tematica__c FROM CC_MCC__c  WHERE CC_Codigo_Externo__c = 'MOC-000001'];
        Id recordTypeSeg = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		Id recordTypeOs = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

		list<case> lstCase = new list<Case>();
        
        Case caso1 = new Case(
		RecordTypeId = recordTypeOs,
        Subject = 'Caso OS_EmailService_Test',
        Origin = 'Email',
        Status = 'Activo',
        AccountId = contacto.AccountId,
        ContactId = contacto.Id,
        CC_Idioma__c = 'es',
        CC_Detalles_Consulta__c = 'Detalles consulta',
        CC_Detalles_Solucion__c = 'Detalles solución',
        CC_MCC_Tematica__c = mccs.CC_Tematica__c,
        CC_MCC_ProdServ__c = mccs.CC_Producto_Servicio__c,
        CC_MCC_Motivo__c = mccs.Id,
        CC_Canal_Procedencia__c = 'Buzón CCI Holabank',
        CC_Tipo_Contacto__c = 'Asesoramiento',
		SEG_Id_Related_Mail__c = correo.Id
			);
        lstCase.add(caso1);

        Case caso2 = new Case(
          		Description = 'Descripción caso 1',
            	Subject = 'Subject caso 2',
                RecordTypeId = recordTypeSeg,
                SEG_Id_Related_Mail__c = correo.Id
			);
        lstCase.add(caso2);

        Case caso3 = new Case(
		RecordTypeId = recordTypeOs,
        Subject = 'Caso OS_EmailService_Test3',
        Origin = 'Email',
        Status = 'Activo',
        AccountId = contacto2.AccountId,
        ContactId = contacto2.Id,
        CC_Idioma__c = 'es',
        CC_Detalles_Consulta__c = 'Detalles consulta',
        CC_Detalles_Solucion__c = 'Detalles solución',
        CC_MCC_Tematica__c = mccs.CC_Tematica__c,
        CC_MCC_ProdServ__c = mccs.CC_Producto_Servicio__c,
        CC_MCC_Motivo__c = mccs.Id,
        CC_Canal_Procedencia__c = 'Buzón CCI Holabank',
        CC_Tipo_Contacto__c = 'Asesoramiento',
		SEG_Id_Related_Mail__c = correo.Id
			);
        lstCase.add(caso3);
		insert lstCase;
        
        SEG_CasosSEG_COPSrelacionados job = new SEG_CasosSEG_COPSrelacionados(correo.Id, correo.htmlBody, correo.subject, 'idNoExistente');
        System.runAs (usuarioAdmin) {

            AsyncOptions options = new AsyncOptions();
            options.DuplicateSignature = QueueableDuplicateSignature.Builder()
            .addId(usuarioAdmin.Id)
            
            .addString('testRelatedCase')
            
            .build(); 
            Id id;
            Test.startTest();
                try {
                    id= System.enqueueJob(job, options);
                } catch (DuplicateMessageException ex) {
                    //Exception is thrown if there is already an enqueued job with the same signature
                    CBK_Log.error(ex);
                }
            
            Test.stopTest();
			String queryString = 
			'SELECT COUNT() FROM Case WHERE CC_CasoRelacionado__c in :lstCase'; 
			Integer countCases = 
			Database.countQuery(QueryString);	
			
            System.assertEquals( 3, countCases, 'Los casos actuales son 3');
        }   
    }

    @IsTest
    public static void emailCOPSaSEG() {
        User usuarioAdmin = OS_Usuarios.usuarioAdmin();

        // Crear EmailMessage
        EmailMessage correo = new EmailMessage();
        correo.Subject = 'pruebaCOPS';
        correo.Incoming = true;
        correo.TextBody = 'cuerpoCOPS';
        correo.FromAddress = 'testcops@mail.com';
        insert correo;

        // Datos base
        Contact contacto = [SELECT Id, AccountId FROM Contact WHERE Email = 'correo@prueba.com' LIMIT 1];
        CC_MCC__c mccs = [SELECT Id, CC_Producto_Servicio__c, CC_Tematica__c FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'MOC-000001' LIMIT 1];
        Id recordTypeOs = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        // Crear caso COPS
        Case casoCOPS = new Case(
            RecordTypeId = recordTypeOs,
            Subject = 'Caso COPS',
            Origin = 'Email',
            Status = 'Activo',
            AccountId = contacto.AccountId,
            ContactId = contacto.Id,
            CC_Idioma__c = 'es',
            CC_Detalles_Consulta__c = 'Detalles consulta',
            CC_Detalles_Solucion__c = 'Detalles solución',
            CC_MCC_Tematica__c = mccs.CC_Tematica__c,
            CC_MCC_ProdServ__c = mccs.CC_Producto_Servicio__c,
            CC_MCC_Motivo__c = mccs.Id,
            CC_Canal_Procedencia__c = 'Buzón CCI Holabank',
            CC_Tipo_Contacto__c = 'Asesoramiento'

            //Este campo se rellenaría llamando al método de relación
            //SEG_Id_Related_Mail__c = correo.Id
        );
        insert casoCOPS;

        // Crear caso SEG
        Id recordTypeSeg = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        Case casoSEG = new Case(
            RecordTypeId = recordTypeSeg,
            Subject = 'Caso SEG',
            Origin = 'Email',
            Status = 'Activo',
            AccountId = contacto.AccountId,
            ContactId = contacto.Id,

            SEG_Id_Related_Mail__c = correo.Id
        );
        insert casoSEG;

        // Vinculación: COPS → SEG
        SEG_CasosSEG_COPSrelacionados job = new SEG_CasosSEG_COPSrelacionados(correo.Id, correo.TextBody, correo.Subject, casoCOPS.Id);
        System.runAs(usuarioAdmin) {

            AsyncOptions options = new AsyncOptions();
            options.DuplicateSignature = QueueableDuplicateSignature.Builder()
            .addId(usuarioAdmin.Id)
            .addString('testRelatedCase')
            .build();

            Id id;
            Test.startTest();
                try {
                    id= System.enqueueJob(job, options);
                } catch (DuplicateMessageException ex) {
                    //Exception is thrown if there is already an enqueued job with the same signature
                    CBK_Log.error(ex);
                }
            Test.stopTest();

            // Verificar que el caso SEG está vinculado al caso COPS
            Case casoSegReload = [SELECT CC_CasoRelacionado__c FROM Case WHERE Id = :casoSEG.Id];
            System.assertEquals(casoCOPS.Id, casoSegReload.CC_CasoRelacionado__c, 'El caso SEG debe estar vinculado al caso COPS');
        }
    }

    @IsTest
    public static void emailSEGaCOPS() {
        User usuarioAdmin = OS_Usuarios.usuarioAdmin();

        // Crear EmailMessage
        EmailMessage correo = new EmailMessage();
        correo.Subject = 'pruebaSEG';
        correo.Incoming = true;
        correo.TextBody = 'cuerpoSEG';
        correo.FromAddress = 'testseg@mail.com';
        insert correo;

        // Datos base
        Contact contacto = [SELECT Id, AccountId FROM Contact WHERE Email = 'correo@prueba.com' LIMIT 1];
        CC_MCC__c mccs = [SELECT Id, CC_Producto_Servicio__c, CC_Tematica__c FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'MOC-000001' LIMIT 1];
        Id recordTypeSeg = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();

        // Crear caso SEG
        Case casoSEG = new Case(
            RecordTypeId = recordTypeSeg,
            Subject = 'Caso SEG',
            Origin = 'Email',
            Status = 'Activo',
            AccountId = contacto.AccountId,
            ContactId = contacto.Id

            //Este campo se rellenaría llamando al método de relación
            //SEG_Id_Related_Mail__c = correo.Id
        );
        insert casoSEG;

        // Crear caso COPS
        Id recordTypeOs = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Case casoCOPS = new Case(
            RecordTypeId = recordTypeOs,
            Subject = 'Caso COPS',
            Origin = 'Email',
            Status = 'Activo',
            AccountId = contacto.AccountId,
            ContactId = contacto.Id,
            CC_Idioma__c = 'es',
            CC_Detalles_Consulta__c = 'Detalles consulta',
            CC_Detalles_Solucion__c = 'Detalles solución',
            CC_MCC_Tematica__c = mccs.CC_Tematica__c,
            CC_MCC_ProdServ__c = mccs.CC_Producto_Servicio__c,
            CC_MCC_Motivo__c = mccs.Id,
            CC_Canal_Procedencia__c = 'Buzón CCI Holabank',
            CC_Tipo_Contacto__c = 'Asesoramiento',
            SEG_Id_Related_Mail__c = correo.Id
        );
        insert casoCOPS;

        // Vinculación: SEG → COPS
        SEG_CasosSEG_COPSrelacionados job = new SEG_CasosSEG_COPSrelacionados(correo.Id, correo.TextBody, correo.Subject, casoSEG.Id);
        System.runAs(usuarioAdmin) {

            AsyncOptions options = new AsyncOptions();
            options.DuplicateSignature = QueueableDuplicateSignature.Builder()
            .addId(usuarioAdmin.Id)
            .addString('testRelatedCase')
            .build();

            Id id;
            Test.startTest();
                try {
                    id= System.enqueueJob(job, options);
                } catch (DuplicateMessageException ex) {
                    //Exception is thrown if there is already an enqueued job with the same signature
                    CBK_Log.error(ex);
                }
            Test.stopTest();

            // Verificar que el caso COPS está vinculado al caso SEG
            Case casoCopsReload = [SELECT CC_CasoRelacionado__c FROM Case WHERE Id = :casoCOPS.Id];
            System.assertEquals(casoSEG.Id, casoCopsReload.CC_CasoRelacionado__c, 'El caso COPS debe estar vinculado al caso SEG');
        }
    }

}