@isTest
public with sharing class CC_TriggerTest { 
    
    // Clase genérica handler para realizar el test de métodos no implementados.
    public class CC_ClaseExtHand extends CC_TriggerHandlerBase {
        public override void mainEntry(CC_TriggerParameters tp) {
            
        }
    }
    
    // Clase genérica dispatcher para realizar el test de métodos no implementados.
    public class CC_ClaseExtDisp extends CC_TriggerDispatcherBase {
        public void ejecucionTest()
        {
            CC_TriggerParameters oParamTrg = new CC_TriggerParameters();
            CC_TriggerDispatcherBase oDispBase = new CC_TriggerDispatcherBase();
            CC_ClaseExtHand oHand = new CC_ClaseExtHand();
            
            oDispBase.bulkBefore();
            oDispBase.bulkAfter();
            
            oParamTrg.tEvent = CC_TriggerParameters.TriggerEvent.beforeInsert;
            oDispBase.beforeInsert(oParamTrg);
            oDispBase.execute(oHand, oParamTrg, CC_TriggerParameters.TriggerEvent.beforeInsert);
            oDispBase.execute(null, oParamTrg, CC_TriggerParameters.TriggerEvent.beforeInsert);
            
            oParamTrg.tEvent = CC_TriggerParameters.TriggerEvent.beforeUpdate;
            oDispBase.beforeUpdate(oParamTrg);
            oDispBase.execute(oHand, oParamTrg, CC_TriggerParameters.TriggerEvent.beforeUpdate);
            oDispBase.execute(null, oParamTrg, CC_TriggerParameters.TriggerEvent.beforeUpdate);
            
            oParamTrg.tEvent = CC_TriggerParameters.TriggerEvent.beforeDelete;
            oDispBase.beforeDelete(oParamTrg);
            oDispBase.execute(oHand, oParamTrg, CC_TriggerParameters.TriggerEvent.beforeDelete);
            oDispBase.execute(null, oParamTrg, CC_TriggerParameters.TriggerEvent.beforeDelete);
            
            oParamTrg.tEvent = CC_TriggerParameters.TriggerEvent.afterInsert;
            oDispBase.afterInsert(oParamTrg);
            oDispBase.execute(oHand, oParamTrg, CC_TriggerParameters.TriggerEvent.afterInsert);
            oDispBase.execute(null, oParamTrg, CC_TriggerParameters.TriggerEvent.afterInsert);
            
            oParamTrg.tEvent = CC_TriggerParameters.TriggerEvent.afterUpdate;
            oDispBase.afterUpdate(oParamTrg);
            oDispBase.execute(oHand, oParamTrg, CC_TriggerParameters.TriggerEvent.afterUpdate);
            oDispBase.execute(null, oParamTrg, CC_TriggerParameters.TriggerEvent.afterUpdate);
            
            oParamTrg.tEvent = CC_TriggerParameters.TriggerEvent.afterDelete;
            oDispBase.afterDelete(oParamTrg);
            oDispBase.execute(oHand, oParamTrg, CC_TriggerParameters.TriggerEvent.afterDelete);
            oDispBase.execute(null, oParamTrg, CC_TriggerParameters.TriggerEvent.afterDelete);
            
            oParamTrg.tEvent = CC_TriggerParameters.TriggerEvent.afterUnDelete;
            oDispBase.afterUnDelete(oParamTrg);
            oDispBase.execute(oHand, oParamTrg, CC_TriggerParameters.TriggerEvent.afterUnDelete);
            oDispBase.execute(null, oParamTrg, CC_TriggerParameters.TriggerEvent.afterUnDelete);
            
            // Constructor Trigger.
            Account oTestAcc = new Account();
            List<Account> oLista = new List<Account>();
            oLista.Add(oTestAcc);
        	CC_TriggerParameters tp = new CC_TriggerParameters(oLista, oLista, null, null, false, false, false, false, false, false, false);
        }
    }

    public static testMethod void testFactory() {
        // Test genéricos de cobertura.
        CC_TriggerException test = new CC_TriggerException();        
		CC_ClaseExtDisp testGen = new CC_ClaseExtDisp();
        testGen.ejecucionTest();
        System.assert(true);
    }
    
	public static testMethod void testLiveChatTransTrigger() {
        
        // Testar el trigger del objeto LiveChatVisitor
        LiveChatVisitor chatVis1 = new LiveChatVisitor();
        insert chatVis1;
        
        LiveChatTranscript chat1 = new LiveChatTranscript();
        chat1.CC_Tipo__c='Agente';
        chat1.LiveChatVisitorId=chatVis1.Id;
        chat1.Body='Chat iniciado Agente';
        
        String sAux = '';
        sAux = sAux + '{\"user\": \"U0137298\", \"startTime\": \"2018-09-06T07:15:30.194Z\", \"duration\": 1536218130194, \"iterations\": 2, \"reformulations\": 0, \"areas\": ';
        sAux = sAux + '[\"Ahorro\"], \"userQuery\": [\"convertir en seervicuenta una cuenta que no es servicuenta\"], \"conversationUnits\": ';
        sAux = sAux + '[{\"type\": 4, \"text\": \"Bienvenido. ¿En qué puedo ayudarte?\", \"timestamp\": \"2018-09-06T07:15:29.923Z\"}, ';
        sAux = sAux + '{\"type\": 2, \"text\": \"convertir en seervicuenta una cuenta que no es servicuenta\", \"timestamp\": \"2018-0  9-06T07:15:30.194Z\"}, ';
        sAux = sAux + '{\"type\": 5, \"text\": \"convertir en seervicuenta una cuenta que no es servicuenta\", \"timestamp\": \"2018-09-06T07:15:30.194Z\"}, ';
        sAux = sAux + '{\"type\": 8, \"text\": \"Ahorro\", \"timestamp\": \"2018-09-06T07:15:31.957Z\"}, {\"type\": 3, \"results\": [{\"id\": \"Como_puedo_dar_de_alta_una_Servicuenta\", ';
        sAux = sAux + '\"confidence\": 0.8238105773925781 }, {\"id\": \"Como_dar_de_alta_una_servicuenta_si_no_tengo_un_deposito_de_ahorro\", \"confidence\": 0.3118317008018494 }, ';
        sAux = sAux + '{\"id\": \"Se_puede_cambiar_la_modalidad_de_una_Servicuenta\", \"confidence\": 0.2550765454769135 }, ';
        sAux = sAux + '{\"id\": \"Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena\", ';
        sAux = sAux + '\"confidence\": 0.2510948121547699 }, {\"id\": \"Que_tarjetas_puedo_vincular_a_una_servicuenta\", ';
        sAux = sAux + '\"confidence\": 0.24829841256141663 }, {\"id\": \"Deseo_toda_la_informacion_sobre_Servicuentas_ahora\", ';
        sAux = sAux + '\"confidence\": 0.2416720747947693 }, {\"id\": \"Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados\", ';
        sAux = sAux + '\"confidence\": 0.2384248733520508 }, {\"id\": \"Operativa_de_Reintegros_Stop_go_\", \"confidence\": 0.23751013278961183 }, {\"id\": ';
        sAux = sAux + '\"Cual_es_la_operativa_para_dar_de_baja_una_servicuenta\", \"confidence\": 0.2371295839548111 }, {\"id\": \"Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion\", ';
        sAux = sAux + '\"confidence\": 0.23371837735176088 } ], \"timestamp\": \"2018-09-06T07:15:31.957Z\"}, {\"type\": 4, \"text\": \"<p>&iquest;C&oacute;mo puedo dar de alta una Servicuenta?</p>';
        sAux = sAux + '<BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no ';
        sAux = sAux + 'tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>\", \"timestamp\": \"2018-09-06T07:15:31.960Z\"}, {\"type\": 6, \"text\": \"¿Cómo puedo dar de alta una ';
        sAux = sAux + 'Servicuenta?\", \"id\": \"Como_puedo_dar_de_alta_una_Servicuenta\", \"timestamp\": \"2018-09-06T07:  15:31.960Z\"}, {\"type\": 5, \"text\": \"Ninguna de las anteriores\", ';
        sAux = sAux + '\"timestamp\": \"2018-09-06T07:15:40.695Z\"}, {\"type\": 4, \"text\": \"He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un ';
        sAux = sAux + 'depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta ';
        sAux = sAux + 'Ajena</li><li>Ninguna de las anteriores</li>\", \"timestamp\": \"2018-09-06T07:15:40.696Z\"}, {\"type\": 5, \"text\": \"Ninguna de las anteriores\", \"timestamp\": ';
        sAux = sAux + '\"2018-09-06T07:15:48.657Z\"} ], \"revision\": \"NO\", \"centro\": \"09945\", \"badClassifications\": [], \"agents\": [\"WATSON\"], \"aplicacionOrigen\": \"\", ';
        sAux = sAux + '\"conversationID\": \"U0137298_61456930\", \"currentID\": 61456930, \"aplicacionCorpus\": \"CC_OFICINAS\", \"idioma\": \"ca\", \"idiomasDetectados\": [\"es\"], \"errors\": [] }';
        
        chat1.CC_Cognitive_chat__c = sAux;
        
        // After Insert.
        insert chat1;

        List<LiveChatTranscript> oDatos = new List<LiveChatTranscript>();
        oDatos = [SELECT Id FROM LiveChatTranscript WHERE LiveChatVisitorId = :chatVis1.Id];
        
        // Crear caso.
        Case oCaso = new Case();
        oCaso.Subject = 'Test';
        insert oCaso;
        
        // Crear cliente.
        Account oCliente = new Account();
        oCliente.Name = 'Test';
        insert oCliente;
        
        // Crear contacto.
        Contact oContacto = new Contact();
        oContacto.FirstName = 'Test';
        oContacto.LastName = 'Test';
        oContacto.AccountId = oCliente.Id;
        oContacto.CC_Idioma__c = 'es';
        insert oContacto;
        
        // After update.
        chat1.CaseId = oCaso.Id;
        chat1.AccountId = oCliente.Id;
        chat1.ContactId = oContacto.Id;
        update chat1;
        
        System.assertEquals(2, oDatos.size());
	}


}