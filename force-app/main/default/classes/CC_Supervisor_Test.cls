@isTest
public with sharing class CC_Supervisor_Test {
    private static String idservicechannel = '';
    private static String idskill = '';
    private static String idskillagente = '';
    private static String idskillidioma = '';
    private static String idskillproveedor = '';
    
    @TestSetup
    static void makeData()
    {
        //crear usuarios CC
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank_Empleados'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        PermissionSet psAnalistaEmpleado = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Analista_CCO'];
        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = profileId;
        usuario1.FirstName = 'Usuario';
        usuario1.LastName = 'Analista CCO';
        usuario1.Email = 'tuser000@amamama.com';
        usuario1.EmployeeNumber = 'U0199999';
        usuario1.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';
        userList.add(usuario1);

		User usuario2 = new User();
        usuario2.ProfileId = profileId;
        usuario2.FirstName = 'Usuario Prueba 2';
        usuario2.LastName = 'last1';
        usuario2.Email = 'tuser000@amamamaaaa.com';
        usuario2.Username = 'tuser000@amamamaaaa.com' + System.currentTimeMillis();
        usuario2.CompanyName = 'MST';
        usuario2.Title = 'title';
        usuario2.Alias = 'alias';
        usuario2.TimeZoneSidKey = 'Europe/Paris';
        usuario2.EmailEncodingKey = 'UTF-8';
        usuario2.LanguageLocaleKey = 'es';
        usuario2.LocaleSidKey = 'es_ES';
        userList.add(usuario2);

        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        User usuarioAdmin = new User();
        
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = roleCC;
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema CCO';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';
        
        userList.add(usuarioAdmin);
		
        insert userList;

        System.runAs(usuarioAdmin){
            User operador = new User();        
            operador.profileId = profileId;
            operador.UserRoleId = roleCC;
            operador.FirstName = '';
            operador.LastName = 'Operador oficina';
            operador.Email = 'tuser000@amamama.com';
            operador.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
            operador.CompanyName = 'MST';
            operador.Title = 'title';
            operador.Alias = 'alias';
            operador.TimeZoneSidKey = 'Europe/Paris';
            operador.EmailEncodingKey = 'UTF-8';
            operador.LanguageLocaleKey = 'es';
            operador.LocaleSidKey = 'es_ES';        
            insert operador;
            insert new PermissionSetAssignment(AssigneeId = operador.Id, PermissionSetId = psAnalistaEmpleado.Id);
            
            List<Skill> skillstouselst = [SELECT Id, DeveloperName FROM Skill WHERE DeveloperName in ('Extranjero','ES','Agente','DXC')];
            for (Skill sk : skillstouselst) {
                if(sk.DeveloperName == 'Extranjero'){
                    idskill = sk.Id;
                }
                else if(sk.DeveloperName == 'ES'){
                    idskillidioma = sk.Id;
                }
                else if(sk.DeveloperName == 'Agente'){
                    idskillagente = sk.Id;
                }
                else if(sk.DeveloperName == 'DXC'){
                    idskillproveedor = sk.Id;
                }
            }
            
            List<ServiceChannel> servicechannellst = [SELECT Id FROM ServiceChannel where DeveloperName = 'sfdc_liveagent'];
            idservicechannel = servicechannellst[0].Id;
            
            LiveChatVisitor lcv = new LiveChatVisitor();
            insert lcv;
            
             LiveChatTranscript lct = new LiveChatTranscript();
            lct.CC_Bienvenida__c = false;
            lct.recordtypeId = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByDeveloperName().get('CC_Empleados').getRecordTypeId();
            lct.CC_Nickname__c = 'Cliente 1';
            lct.CC_Idioma__c = 'es';
            lct.LiveChatVisitorId = lcv.Id;
            lct.CC_CaseOrigin__c='Chat';
            lct.CC_Tipo__c = 'Agente';
            lct.CC_NumEmpleado__c = 'U0190165';
            lct.CC_Cognitive_chat__c='{"user": "U0137298", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Como_puedo_dar_de_alta_una_Servicuenta", "confidence": 0.8238105773925781 }, {"id": "Como_dar_de_alta_una_servicuenta_si_no_tengo_un_deposito_de_ahorro", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Operativa_de_Reintegros_Stop_go_", "confidence": 0.23751013278961183 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&iquest;C&oacute;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "Chat", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["es"], "errors": [], "perfil":"bueno", "idGlobalList":["123456789"], "pilotaje":["piloto"],"sourceConversationID":"34625791388_226572751","sourceAplicacionCorpus":"NoaWhatsapp" }';
            lct.CC_Id_Cognitive__c='test123456';
            lct.CC_Espacio__c = 'Extranjero';
            lct.CC_Categoria__c = 'Extranjero';
        
            insert lct;
            
            PendingServiceRouting psr = new PendingServiceRouting();
            psr.RoutingModel = 'MostAvailable';
            psr.RoutingType = 'SkillsBased';
            psr.WorkItemId = lct.Id;
            psr.IsPreferredUserRequired = false;
            psr.IsReadyForRouting = false;
            psr.CapacityWeight = 7;
            psr.RoutingPriority = 2;
            psr.ServiceChannelId = idservicechannel;
            insert psr;
            
            //SkillReqs
            List<SkillRequirement> lstskillreqs = new List<SkillRequirement>();
            SkillRequirement skillreqidioma = new SkillRequirement();
            skillreqidioma.SkillId = idskillidioma;
            skillreqidioma.RelatedRecordId = psr.Id;
            lstskillreqs.add(skillreqidioma);
            SkillRequirement skillreqagenteohidden = new SkillRequirement();
            skillreqagenteohidden.SkillId = idskillagente;
            skillreqagenteohidden.RelatedRecordId = psr.Id;
            lstskillreqs.add(skillreqagenteohidden);
            SkillRequirement skillreqstandard = new SkillRequirement();
            skillreqstandard.SkillId = idskill;
            skillreqstandard.RelatedRecordId = psr.Id;
            lstskillreqs.add(skillreqstandard);
            SkillRequirement skillreqproveedor= new SkillRequirement();
            skillreqproveedor.SkillId = idskillproveedor;
            skillreqproveedor.RelatedRecordId = psr.Id;
             lstskillreqs.add(skillreqproveedor);
            insert lstskillreqs;
            
            //Capacidades
            CC_Capacidad_Proveedores__c capacidadDXC = new CC_Capacidad_Proveedores__c();
            capacidadDXC.CC_Idioma__c = 'es';
            capacidadDXC.CC_Tipo_Chat_Transcript__c = 'Agente';
            capacidadDXC.CC_Queue_Name__c = 'Extranjero';
            capacidadDXC.CC_Canal_Entrada__c = 'Chat';
            capacidadDXC.CC_Proveedor__c = 'DXC';
            capacidadDXC.CC_Capacidad__c = 60;
            capacidadDXC.CC_Cliente_Empleado__c = 'Empleados';
            capacidadDXC.RecordTypeId = Schema.SObjectType.CC_Capacidad_Proveedores__c.getRecordTypeInfosByDeveloperName().get('CC_Chat').getRecordTypeId();
            insert capacidadDXC;
            
            CC_Capacidad_Proveedores__c capacidadMST = new CC_Capacidad_Proveedores__c();
            capacidadMST.CC_Idioma__c = 'es';
            capacidadMST.CC_Tipo_Chat_Transcript__c = 'Agente';
            capacidadMST.CC_Queue_Name__c = 'Extranjero';
            capacidadMST.CC_Canal_Entrada__c = 'Chat';
            capacidadMST.CC_Proveedor__c = 'MST';
            capacidadMST.CC_Capacidad__c = 40;
            capacidadMST.CC_Cliente_Empleado__c = 'Empleados';
            capacidadMST.RecordTypeId = Schema.SObjectType.CC_Capacidad_Proveedores__c.getRecordTypeInfosByDeveloperName().get('CC_Chat').getRecordTypeId();
            insert capacidadMST;
            
            CC_Tiempo_Refresco__c tiempoRefresco = new CC_Tiempo_Refresco__c();
            tiempoRefresco.Name = 'Supervisor';
            tiempoRefresco.CC_Tipo__c= 'Supervisor';
            tiempoRefresco.CC_Tiempo__c = 15;     
             insert tiempoRefresco;
        }   
        
        insert new PermissionSetAssignment(AssigneeId = usuarioAdmin.Id, PermissionSetId = psAnalistaEmpleado.Id); 
    }

    @isTest 
    public static void testDatosTotal() {
        
        User admin = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema'];
        System.runAs(admin) {
            
            // Llamar al método de la clase Apex que deseas probar
            List<CC_Supervisor.ChatsWrapper> result = CC_Supervisor.datosTotal();
            System.assertNotEquals(null, result, 'El resultado no debe ser nulo');
        }
    }
    @isTest 
    public static void testTiempoRefresco() {
        
        User admin = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema'];
        System.runAs(admin) {
            
            // Llamar al método de la clase Apex que deseas probar
            Integer result = CC_Supervisor.tiempoRefresco();
            System.assert(result >0);
        }
    }
    
    
}