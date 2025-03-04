@isTest
public class OS_EmailService_Test {

    @TestSetup
    static void cargaDeDatos(){
        User operador = OS_Usuarios.usuarioOperador();

        SEG_Settings__c csDelay = new SEG_Settings__c();
        csDelay.Name = 'SEG_DelaySEGCOPS';
        csDelay.SEG_Delay__c = 1;
        insert csDelay;

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

        CC_MCC__c tematica = new CC_MCC__c();
		tematica.Name = 'tematica cops test';
        tematica.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        tematica.CC_Fecha_Vigencia_Inicio__c = System.now();
        tematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.CC_Codigo_Externo__c = 'TEC-000001';
        tematica.OS_Departamento__c = 'UAC';
        tematica.OS_Horario__C= businessHoursId;
        insert tematica;

        CC_MCC__c producto = new CC_MCC__c();
        producto.Name = 'producto cops test';
        producto.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        producto.CC_Fecha_Vigencia_Inicio__c = System.now();
        producto.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        producto.CC_Tematica__c = tematica.Id;
        producto.CC_Codigo_Externo__c = 'PRC-000001'; 
        insert producto;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.Name = 'motivo cops test';
        motivo.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        motivo.CC_Fecha_Vigencia_Inicio__c = System.now();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tematica__c = tematica.Id;
        motivo.CC_Producto_Servicio__c = producto.Id;
        motivo.CC_Codigo_Externo__c = 'MOC-000001';
        insert motivo;

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        caso.Subject = 'Caso OS_EmailService_Test';
        caso.Origin = 'Email';
        caso.Status = 'Activo';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.CC_Idioma__c = 'es';
        caso.CC_Detalles_Consulta__c = 'Detalles consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles solución';
        caso.CC_MCC_Tematica__c = tematica.Id;
        caso.CC_MCC_ProdServ__c = producto.Id;
        caso.CC_MCC_Motivo__c = motivo.Id;
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso;

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

    @isTest
    public static void testCorreoEntrante() {
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        List<String> lstCcAdd = new List<String>();
        lstCcAdd.add('email1@test.com');
        lstCcAdd.add('pruebaCorreo@gmail.com');
        
        List<String> lstToAdd = new List<String>();
        lstToAdd.add('email1@test.com');
        lstToAdd.add('prueba.cci.holabank@salesforce.com');
        
        header.value = 'hello';
        header.name = 'Content-Id';
        envelope.fromAddress = 'correo@prueba.com';
        envelope.toAddress = [SELECT OS_Email__c FROM OS_Correo__mdt WHERE DeveloperName LIKE '%Holabank%' LIMIT 1].OS_Email__c;
        correo.subject = 'asunto';
        correo.fromAddress = 'correo@prueba.com';
        correo.toAddresses = lstToAdd;
        correo.ccAddresses = lstCcAdd;
        correo.plainTextBody = 'email test';
        correo.htmlBody = 'email test';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};
        
        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
        //Adjunto de texto
        Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

        System.runAs (OS_Usuarios.usuarioAdmin()) {
            Test.startTest();
            OS_EmailService emailServiceCOPS = new OS_EmailService();
            emailServiceCOPS.handleInboundEmail(correo, envelope);   
            Test.stopTest();

            List<Case> newCase = [SELECT Subject,Id FROM Case WHERE Subject =:correo.subject];

            System.assertEquals('asunto', correo.subject, 'Comprobamos el asunto.');                 
        }
    }

    @isTest
    public static void testCorreoEntranteError() {
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        List<String> lstCcAdd = new List<String>();
        lstCcAdd.add('email1@test.com');
        lstCcAdd.add('pruebaCorreo@gmail.com');
        
        List<String> lstToAdd = new List<String>();
        lstToAdd.add('email1@test.com');
        lstToAdd.add('prueba.cci.holabank@salesforce.com');
        
        header.value = 'hello';
        header.name = 'Content-Id';
        envelope.fromAddress = 'correo@prueba.com';
        envelope.toAddress = [SELECT OS_Email__c FROM OS_Correo__mdt WHERE DeveloperName LIKE '%Holabank%' LIMIT 1].OS_Email__c;
        correo.subject = 'TESTCATCHMETHOD';
        correo.fromAddress = 'correo@prueba.com';
        correo.toAddresses = lstToAdd;
        correo.ccAddresses = lstCcAdd;
        correo.plainTextBody = 'email test';
        correo.htmlBody = 'email test';
        
        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
        //Adjunto de texto
        Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

        System.runAs (OS_Usuarios.usuarioAdmin()) {
            Test.startTest();
            OS_EmailService emailServiceCOPS = new OS_EmailService();
            emailServiceCOPS.handleInboundEmail(correo, envelope);   
            Test.stopTest();

            List<Case> newCase = [SELECT Subject FROM Case WHERE Subject =:correo.subject];

            System.assertEquals('TESTCATCHMETHOD', correo.subject, 'Comprobamos el asunto.');
        }
    }
    
    @isTest
    public static void semillaSolicitudInfo() {
        User usuarioAdmin =OS_Usuarios.usuarioAdmin();

        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso OS_EmailService_Test'];
        caso.OwnerId = usuarioAdmin.Id;
        caso.CC_Referencia_Correo_Saliente__c = '199409247102802500KN000001SQZpYAO';
        caso.Status = 'Pendiente Cliente';
        update caso;

        //Actividad de solicitud de información
        Task tareaSolicitudInfo = new Task();
        tareaSolicitudInfo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        tareaSolicitudInfo.WhatId = caso.Id;
        tareaSolicitudInfo.Type = 'Solicitud Información';
        tareaSolicitudInfo.Subject = 'Solicitud Información';
        tareaSolicitudInfo.Status = 'Completed';
        tareaSolicitudInfo.CC_Referencia_Correo_Saliente__c = '199409247102802500KN000001SQZpYAO';
        tareaSolicitudInfo.OwnerId = usuarioAdmin.Id;
        insert tareaSolicitudInfo;

        List<String> lstCcAdd = new List<String>();
        lstCcAdd.add('email1@test.com');
        lstCcAdd.add('pruebaCorreo@gmail.com');
        
        List<String> lstToAdd = new List<String>();
        lstToAdd.add('email1@test.com');
        lstToAdd.add('prueba.cci.holabank@salesforce.com');

        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';
        envelope.fromAddress = 'correo@prueba.com';
        envelope.toAddress = [SELECT OS_Email__c FROM OS_Correo__mdt WHERE DeveloperName LIKE '%Holabank%' LIMIT 1].OS_Email__c;
        correo.subject = 'asunto';
        correo.fromAddress = 'correo@prueba.com';
        correo.plainTextBody = 'hola\n#@refSolicitudInfo#\nadios\n' + '#@199409247102802500KN000001SQZpYAO#' + '\nFin';
        correo.htmlBody = 'hola\n#@refSolicitudInfo#\nadios\n' + '#@199409247102802500KN000001SQZpYAO#' + '\nFin';
        correo.toAddresses = lstToAdd;
        correo.ccAddresses = lstCcAdd;
        
        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
        //Adjunto de texto
        Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

        System.runAs (OS_Usuarios.usuarioAdmin()) {
            Test.startTest();
            OS_EmailService testInbound = new OS_EmailService();
            testInbound.handleInboundEmail(correo, envelope);
            Test.stopTest();

            System.assertEquals(
                1, [SELECT Count() FROM EmailMessage WHERE ParentId = :caso.Id],
                'El correo de respuesta a la solicitud de información debe quedar vinculado al caso'
            );
        }
    }
    
    @isTest
    public static void semillaTrasladoColaborador() {
        
        User usuarioAdmin =OS_Usuarios.usuarioAdmin();

        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso OS_EmailService_Test'];
        caso.OwnerId = usuarioAdmin.Id;
        caso.CC_Referencia_Correo_Saliente__c = '199409247102802500KN000001SQZpYAO';
        caso.Status = 'Pendiente Colaborador';
        update caso;

        Id recordTypeTask=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        
        //Actividad de solicitud de información
        Task tareaTrasladoColab = new Task();
        tareaTrasladoColab.RecordTypeId = recordTypeTask;
        tareaTrasladoColab.WhatId = caso.Id;
        tareaTrasladoColab.Type = 'Traslado Colaborador';
        tareaTrasladoColab.Subject = 'Traslado Colaborador';
        tareaTrasladoColab.Status = 'Completed';
        tareaTrasladoColab.CC_Referencia_Correo_Saliente__c = '199409247102802500KN000001SQZpYAO';
        tareaTrasladoColab.OwnerId = usuarioAdmin.Id;
        insert tareaTrasladoColab;
        
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';
        envelope.fromAddress = 'correo@prueba.com';
        envelope.toAddress = [SELECT OS_Email__c FROM OS_Correo__mdt WHERE DeveloperName LIKE '%Holabank%' LIMIT 1].OS_Email__c;
        correo.subject = 'asunto';
        correo.fromAddress = 'correo@prueba.com';
        correo.plainTextBody = 'hola\n#@refTrasladoColab#\nadios\n' + '#@199409247102802500KN000001SQZpYAO#' + '\nFin';
        correo.htmlBody = 'hola\n#@refTrasladoColab#\nadios\n' + '#@199409247102802500KN000001SQZpYAO#' + '\nFin';
        
        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
        //Adjunto de texto
        Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

        System.runAs (usuarioAdmin) {
            Test.startTest();
            OS_EmailService testInbound = new OS_EmailService();
            testInbound.handleInboundEmail(correo, envelope); 
            Test.stopTest();

            System.assertEquals(
              1, [SELECT Count() FROM EmailMessage WHERE ParentId = :caso.Id],
                'El correo de respuesta al traslado a colaborador debe quedar vinculado al caso'
            );
        }
    }
    
    @isTest
    public static void semillaRemitirColaborador() {
        
        User usuarioAdmin =OS_Usuarios.usuarioAdmin();


        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso OS_EmailService_Test'];
        caso.OwnerId = usuarioAdmin.Id;
        caso.CC_Referencia_Correo_Saliente__c = '199409247102802500KN000001SQZpYAO';
        update caso;

        Id recordTypeTask=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');

        List<Task> tasks = new List<Task>();

        //Actividad de solicitud de información
        Task tareaRemitirColab = new Task();
        tareaRemitirColab.RecordTypeId =recordTypeTask;
        tareaRemitirColab.WhatId = caso.Id;
        tareaRemitirColab.Type = 'Remitir Colaborador';
        tareaRemitirColab.Subject = 'Remitir Colaborador';
        tareaRemitirColab.Status = 'Completed';
        tareaRemitirColab.CC_Referencia_Correo_Saliente__c = '199409247102802500KN000001SQZpYAO';
        tareaRemitirColab.OwnerId = usuarioAdmin.Id;
        tasks.add(tareaRemitirColab);
        

        Task tareaRemitirColab2 = new Task();
        tareaRemitirColab2.RecordTypeId = recordTypeTask;
        tareaRemitirColab2.WhatId = caso.Id;
        tareaRemitirColab2.Type = 'Responder a cliente';
        tareaRemitirColab2.Subject = 'Responder a cliente';
        tareaRemitirColab2.Status = 'Completed';
        tareaRemitirColab2.CC_Referencia_Correo_Saliente__c = '199409247102802500KN000001SQZpYAO';
        tareaRemitirColab2.OwnerId = usuarioAdmin.Id;
        tasks.add(tareaRemitirColab2);

        Task tareaRemitirColab3 = new Task();
        tareaRemitirColab3.RecordTypeId = recordTypeTask;
        tareaRemitirColab3.WhatId = caso.Id;
        tareaRemitirColab3.Type = 'Acuse de recibo';
        tareaRemitirColab3.Subject = 'Acuse de recibo';
        tareaRemitirColab3.Status = 'Completed';
        tareaRemitirColab3.CC_Referencia_Correo_Saliente__c = '199409247102802500KN000001SQZpYAO';
        tareaRemitirColab3.OwnerId = usuarioAdmin.Id;
        tasks.add(tareaRemitirColab3);

        Task tareaRemitirColab4 = new Task();
        tareaRemitirColab4.RecordTypeId = recordTypeTask;
        tareaRemitirColab4.WhatId = caso.Id;
        tareaRemitirColab4.Type = 'Prueba';
        tareaRemitirColab4.Subject = 'Prueba';
        tareaRemitirColab4.Status = 'Completed';
        tareaRemitirColab4.CC_Referencia_Correo_Saliente__c = '199409247102802500KN000001SQZpYAO';
        tareaRemitirColab4.OwnerId = usuarioAdmin.Id;
        tasks.add(tareaRemitirColab4);

        insert tasks;
        
        ///Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';
        envelope.fromAddress = 'correo@prueba.com';
        envelope.toAddress = [SELECT OS_Email__c FROM OS_Correo__mdt WHERE DeveloperName LIKE '%Holabank%' LIMIT 1].OS_Email__c;
        correo.subject = 'asunto';
        correo.fromAddress = 'correo@prueba.com';
        correo.plainTextBody = 'hola\n#@199409247102802500KN000001SQZpYAO#\nadios';
        correo.htmlBody = 'email test prueba 3';
        
        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
        //Adjunto de texto
        Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};
        System.runAs (usuarioAdmin) {
            Test.startTest();
            OS_EmailService testInbound = new OS_EmailService();
            testInbound.handleInboundEmail(correo, envelope);
            Test.stopTest();
            
            System.assertEquals(
                1, [SELECT Count() FROM EmailMessage WHERE ParentId = :caso.Id],
                'El correo de respuesta al remitir a colaborador debe quedar vinculado al caso'
            );
        }
    }

    //previamente comentado
    @isTest
    public static void testCorreoEntranteSinReglaUtilizada() {

        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        List<String> lstCcAdd = new List<String>();
        lstCcAdd.add('email1@test.com');
        lstCcAdd.add('pruebaCorreo@gmail.com');
        
        List<String> lstToAdd = new List<String>();
        lstToAdd.add('email1@test.com');
        lstToAdd.add('prueba.cci.holabank@salesforce.com');
        
        header.value = 'hello';
        header.name = 'Content-Id';
        envelope.fromAddress = 'correo@prueba.com';
        envelope.toAddress = [SELECT OS_Email__c FROM OS_Correo__mdt WHERE DeveloperName LIKE '%Holabank%' LIMIT 1].OS_Email__c;
        correo.subject = 'asunto';
        correo.fromAddress = 'correo@prueba.com';
        correo.toAddresses = lstToAdd;
        correo.ccAddresses = lstCcAdd;
        correo.plainTextBody = 'email test';
        correo.htmlBody = 'email test prueba 4';

        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
        //Adjunto de texto
        Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

        List<SEG_Regladeclasificacion__c> regClas = [SELECT Id FROM SEG_Regladeclasificacion__c WHERE OS_AgrupacionBuzon__c = 'Buzón CCI Holabank'];
        // regClas.SEG_ClasificacionRapida__c = null;
        delete regClas;

        System.runAs (OS_Usuarios.usuarioAdmin()) {
            Test.startTest();
            OS_EmailService emailServiceCOPS = new OS_EmailService();
            emailServiceCOPS.handleInboundEmail(correo, envelope);    
            Test.stopTest();

            List<Case> newCase = [SELECT Subject FROM Case WHERE Subject =:correo.subject];

            System.assertEquals('asunto', correo.subject,'asunto');
        }
    }

    @isTest
    public static void saltarCatch(){
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        ///Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        Boolean catchPasado = false;
        Messaging.InboundEmailResult resultado = new Messaging.InboundEmailResult();
        
        header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';
        envelope.fromAddress = 'correo@prueba.com';
        envelope.toAddress = [SELECT OS_Email__c FROM OS_Correo__mdt WHERE DeveloperName LIKE '%Holabank%' LIMIT 1].OS_Email__c;
        
        correo.subject = 'asunto';
        Test.startTest();
        
            System.runAs(usuarioOperador){
                OS_EmailService emailServiceCOPS = new OS_EmailService();
                resultado = emailServiceCOPS.handleInboundEmail(correo, envelope);
            }
            System.assertEquals(resultado, null);
        Test.stopTest();
    }
    
    @IsTest
    public static void testparseoDatetime() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
        String dateString = 'Tue, 8 Aug 2023 06:57:56 +0000';

        System.runAs (usuarioOperador){
            Test.startTest();
                Datetime result = OS_EmailService.parseoDatetime(dateString);   
            Test.stopTest();
            System.assertNotEquals(result ,null,'No he se calculado la fecha correctamente');   
        }           
   }
}