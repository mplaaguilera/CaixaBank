@isTest
public class CC_activityTimeline_Controller_test {
    @isTest
    public static void testAllCase() {
        //Creación nueva cuenta
        Account cuenta = new Account(Name='Cuenta');
        insert cuenta;
        
        //Creación nuevo contacto asociado a la cuenta anterior
        Contact contacto = new Contact(LastName='Contacto', AccountId=cuenta.Id);
        insert contacto;
        
        //Creación nuevo caso asociado al contacto anterior
        Case caso = new Case(AccountId=cuenta.Id, ContactId=contacto.Id, Status = 'Activo');
        
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c='Accionista';
        insert caso;
        
        //Creación nueva tarea ABIERTA asociada al caso anterior
        Task tarea = new Task(WhatId=caso.Id, Status='Pendiente');
        insert tarea;

        //Creación nueva tarea ABIERTA asociada al caso anterior
        Task tarea2 = new Task(WhatId=caso.Id, Status='Complete');
        insert tarea2;        
        
        List<SocialPost> sp = new List<SocialPost>{new SocialPost(name='SP1', ParentId=caso.Id)};
        insert sp;
    
        // Queries to get the inserted accounts 
        SocialPost masterSP = [SELECT Id, Name FROM SocialPost WHERE Name = 'SP1' LIMIT 1];
        DateTime fecha = Datetime.now();
        List<SocialPost> sp2 = new List<SocialPost>{
            new SocialPost(name='SP2', IsOutbound=true, Posted=fecha, ReplyToId=masterSP.Id, ParentId=caso.Id)
            };                                        
        insert sp2;
                
        SocialPost childSP = [SELECT Id, Name FROM SocialPost WHERE Name = 'SP2' LIMIT 1];
        List<ID> ListSP = new List<ID>();
        ListSP.add(childSP.Id);
        
        Task actividad_email = new Task();
        actividad_email.WhatId = caso.Id;
        insert actividad_email; 
        
		EmailMessage correo = new EmailMessage();
        correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correo.ParentId = caso.Id;
        correo.RelatedToId = caso.Id;
        correo.ActivityId = actividad_email.Id;
        correo.Subject = 'prueba';
        correo.Incoming = false;
        correo.TextBody = 'cuerpo';
        insert correo;
        
        actividad_email = new Task();
        actividad_email.WhatId = caso.Id;
        actividad_email.status='Completed';
        insert actividad_email; 
        
        

        correo = new EmailMessage();
        correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correo.ParentId = caso.Id;
        correo.RelatedToId = caso.Id;
        correo.ActivityId = actividad_email.Id;
        correo.Subject = 'prueba';
        correo.Incoming = false;
        correo.HTMLBody = 'cuerpo';
        insert correo;
        
        
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        
        LiveChatTranscript chat = new LiveChatTranscript(
            CC_Bienvenida__c = false,
            LiveChatVisitorId = liveChatVisitor.Id,
            CC_Cognitive_chat__c='{"user": "U0137298", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Como_puedo_dar_de_alta_una_Servicuenta", "confidence": 0.8238105773925781 }, {"id": "Como_dar_de_alta_una_servicuenta_si_no_tengo_un_deposito_de_ahorro", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Operativa_de_Reintegros_Stop_go_", "confidence": 0.23751013278961183 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&iquest;C&oacute;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["es"], "errors": [] }',            CC_Id_Cognitive__c='test01',
            CC_Tipo__c = 'Agente'
        );
        insert chat;
        
        chat.AccountId = cuenta.Id;
        chat.ContactId = contacto.Id;
        chat.CaseId = caso.Id;
        update chat;
            
        List<CC_activityTimeline_Model> lst = CC_activityTimeline_Controller.getActivityTimeline(caso.Id,'All','Case');
        List<CC_activityTimeline_Model> lst2 = CC_activityTimeline_Controller.getActivityTimeline(contacto.Id,'All','Contact');
        List<CC_activityTimeline_Model> lst3 = CC_activityTimeline_Controller.getActivityTimeline(caso.Id,'Social','Contact');
        List<CC_activityTimeline_Model> lst4 = CC_activityTimeline_Controller.getActivityTimeline(caso.Id,'Task','Case');

        
        System.assertEquals(lst.size(), 4);
        System.assertEquals(lst2.size(), 7);
        System.assertEquals(lst3.size(), 0);
        System.assertEquals(lst4.size(), 6);

        
    }
}