@isTest
public class CC_WS_Recupera_LogConversacion_Test {
    
    /*@isTest
    public static void testSetup() {
        
        Account cuenta = new Account(Name = 'Prueba');
        insert cuenta;
        
        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicio1();
        String jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(s1.CC_Codigo__c, '', '', '12345678');
        Id idLlamada = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        CC_Llamada__c llamada = [SELECT Id, Name, CC_Asunto__c, CC_Id_Cognitivo__c, CC_Idioma__c, CC_Servicio_Genesys__c, CC_Tipo__c, CC_ConnId__c,
                                 CC_ANI__c, CC_Agente__c, CC_Canal_del_Empleado__c, CC_Case_Consulta__c, CC_Cognitivo__c, CC_ConnId_Cognitivo__c,
                                 CC_ConnId_Consulta__c, CC_Contacto__c, CC_Cuenta__c, CC_Datos_Genesys__c, CC_DNIS__c , CC_Extension__c , CC_IdentCliente__c,
                                 CC_Identificado_Manualmente__c, CC_No_Identificado__c
                                 FROM CC_Llamada__c WHERE Id = :idLlamada AND CC_Fecha_Fin__c = NULL];
        llamada.CC_Cuenta__c = cuenta.Id;
        update llamada;
        
        Boolean cuentaAsociada = CC_Llamada_Caso_Nuevo_Controller.cuentaAsociada(idLlamada);
        System.assert(cuentaAsociada);
        
        Boolean cerrada = CC_Llamada_Caso_Nuevo_Controller.getLlamada(idLlamada);
        System.assertEquals(false, cerrada);
        
        Case oCaso = new Case();
        oCaso = CC_WS_Recupera_LogConversacion.CC_WS_Recupera_Conversacion(llamada);
        
    }*/
    
    // Test con caso existente para que lo devuelva con status='Activo'
    @isTest
    public static void testCasoCerrado() {        
        // Crear cliente.
        Account cuenta = new Account();
        cuenta.Name = 'Prueba';
        cuenta.CC_Numero_Oficina_Empresa__c = '11111-001';
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        insert cuenta;
        
        // Crear contacto.
        Contact b = new Contact();
     	Id RecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
		b.RecordTypeId = RecordType;
        b.AccountId = cuenta.Id;
        b.LastName = 'empleado prueba 1';
        b.FirstName = 'empleado prueba 1';
        b.CC_Idioma__c = 'es';
        b.Email = 'test@contact.com';
        b.CC_Matricula__c = '9265';
        insert b;
        /*
        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicio1();
        String jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(s1.CC_Codigo__c, '', '', '12345678');
        Id idLlamada = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        CC_Llamada__c llamada = [SELECT Id, Name, CC_Asunto__c, CC_Id_Cognitivo__c, CC_Idioma__c, CC_Servicio_Genesys__c, CC_Tipo__c, CC_ConnId__c,
                                 CC_ANI__c, CC_Agente__c, CC_Canal_del_Empleado__c, CC_Case_Consulta__c, CC_Cognitivo__c, CC_ConnId_Cognitivo__c,
                                 CC_ConnId_Consulta__c, CC_Contacto__c, CC_Cuenta__c, CC_Datos_Genesys__c, CC_DNIS__c , CC_Extension__c , CC_IdentCliente__c,
                                 CC_Identificado_Manualmente__c, CC_No_Identificado__c
                                 FROM CC_Llamada__c WHERE Id = :idLlamada AND CC_Fecha_Fin__c = NULL];
        llamada.CC_Cuenta__c = cuenta.Id;
        llamada.CC_ConnId_Cognitivo__c = 'FCL-000001';
        update llamada;
        
        Boolean cuentaAsociada = CC_Llamada_Caso_Nuevo_Controller.cuentaAsociada(idLlamada);
        System.assert(cuentaAsociada);
        
        Boolean cerrada = CC_Llamada_Caso_Nuevo_Controller.getLlamada(idLlamada);
        System.assertEquals(false, cerrada);
        */
                
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordCau = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id recordSol = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Empleado';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Empleado';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;        
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
		//'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Empleado';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2; 
        CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
        CC_MCC__c mcc3 = new CC_MCC__c();
        mcc3.RecordTypeId = recordCau;
        mcc3.Name = 'Causa';
        mcc3.CC_Tipo_Cliente__c = 'Empleado';
        mcc3.CC_Codigo_Externo__c = 'CA-000001';
        insert mcc3;  
		CC_MCC__c causa = [SELECT Id FROM CC_MCC__c WHERE Name='Causa' LIMIT 1];
        CC_MCC__c mcc4 = new CC_MCC__c();
        mcc4.RecordTypeId = recordSol;
        mcc4.Name = 'Solucion';
        mcc4.CC_Tipo_Cliente__c = 'Empleado';
        mcc4.CC_Codigo_Externo__c = 'SO-000001';
        insert mcc4;
		CC_MCC__c sol = [SELECT Id FROM CC_MCC__c WHERE Name='Solucion' LIMIT 1];
        
        Case oCaseCerrado = new Case();
        oCaseCerrado.Subject = 'Prueba';
        oCaseCerrado.CC_Idioma__c = 'es';
        oCaseCerrado.CC_NumPerso__c = '123456';
        oCaseCerrado.CC_Tipo_Cliente__c = 'Cliente';
        oCaseCerrado.Status = 'Activo';
        oCaseCerrado.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        oCaseCerrado.Origin = 'Chat';
		oCaseCerrado.CC_Tipo_Contacto__c = 'Consulta';
        oCaseCerrado.CC_Canal_Procedencia__c = 'Activo';
        oCaseCerrado.CC_Tipo_ChatTranscript__c = 'Hidden';
        oCaseCerrado.CC_Detalles_Consulta__c = 'Prueba';
        oCaseCerrado.CC_Detalles_Solucion__c = 'Prueba';
        oCaseCerrado.CC_Id_Cognitivo__c = '87654321_9999999';
        oCaseCerrado.CC_MCC_Motivo__c = motiv.Id;
		oCaseCerrado.CC_MCC_ProdServ__c = prod.Id;
        oCaseCerrado.CC_MCC_Tematica__c = tem.Id;
        oCaseCerrado.CC_MCC_Causa__c = causa.Id;
        oCaseCerrado.CC_MCC_Solucion__c = sol.Id;
        oCaseCerrado.AccountId = cuenta.Id;
        oCaseCerrado.ContactId = b.Id;
        insert oCaseCerrado;
        
        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicioEmpleado();
        String jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(s1.CC_Codigo__c, '', oCaseCerrado.Id, '');
        Id idLlamada = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        CC_Llamada__c llamada = [SELECT Id, Name, CC_Asunto__c, CC_Id_Cognitivo__c, CC_Idioma__c, CC_Servicio_Genesys__c, CC_Tipo__c, CC_ConnId__c,
                                 CC_ANI__c, CC_Agente__c, CC_Canal_del_Empleado__c, CC_Case_Consulta__c, CC_Cognitivo__c, CC_ConnId_Cognitivo__c,
                                 CC_ConnId_Consulta__c, CC_Contacto__c, CC_Cuenta__c, CC_Datos_Genesys__c, CC_DNIS__c , CC_Extension__c , CC_IdentCliente__c,
                                 CC_Identificado_Manualmente__c, CC_No_Identificado__c
                                 FROM CC_Llamada__c WHERE Id = :idLlamada AND CC_Fecha_Fin__c = NULL];
        llamada.CC_Cuenta__c = cuenta.Id;
        llamada.CC_ConnId_Cognitivo__c = '87654321_9999999';
        llamada.CC_Id_Cognitivo__c = '87654321_9999999';
        update llamada;
        
        oCaseCerrado.Status = 'Cerrado';
        update oCaseCerrado;
        
        Case oCaso = new Case();
        oCaso = CC_WS_Recupera_LogConversacion.CC_WS_Recupera_Conversacion(llamada);
    }
    
    @isTest
    public static void testCasoChat() {        
        // Crear oficina.
        Account cuenta = new Account();
        cuenta.Name = 'Prueba';
        cuenta.CC_Numero_Oficina_Empresa__c = '11111-001';
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        insert cuenta;
        
        // Crear empleado.
        Contact b = new Contact();
     	Id RecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
		b.RecordTypeId = RecordType;
        b.AccountId = cuenta.Id;
        b.LastName = 'empleado prueba 1';
        b.FirstName = 'empleado prueba 1';
        b.CC_Idioma__c = 'es';
        b.Email = 'test@contact.com';
        b.CC_Matricula__c = '9265';
        insert b;
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordCau = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id recordSol = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Empleado';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Empleado';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;        
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
		//'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Empleado';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2; 
        CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
        CC_MCC__c mcc3 = new CC_MCC__c();
        mcc3.RecordTypeId = recordCau;
        mcc3.Name = 'Causa';
        mcc3.CC_Tipo_Cliente__c = 'Empleado';
        mcc3.CC_Codigo_Externo__c = 'CA-000001';
        insert mcc3;  
		CC_MCC__c causa = [SELECT Id FROM CC_MCC__c WHERE Name='Causa' LIMIT 1];
        CC_MCC__c mcc4 = new CC_MCC__c();
        mcc4.RecordTypeId = recordSol;
        mcc4.Name = 'Solucion';
        mcc4.CC_Tipo_Cliente__c = 'Empleado';
        mcc4.CC_Codigo_Externo__c = 'SO-000001';
        insert mcc4;
		CC_MCC__c sol = [SELECT Id FROM CC_MCC__c WHERE Name='Solucion' LIMIT 1];
        
        Case oCaseCerrado = new Case();
        oCaseCerrado.Subject = 'Prueba';
        oCaseCerrado.CC_Idioma__c = 'es';
        oCaseCerrado.CC_NumPerso__c = '123456';
        oCaseCerrado.CC_Tipo_Cliente__c = 'Empleado';
        oCaseCerrado.Status = 'Cerrado';
        oCaseCerrado.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        oCaseCerrado.Origin = 'Chat';
		oCaseCerrado.CC_Tipo_Contacto__c = 'Consulta';
        oCaseCerrado.CC_Canal_Procedencia__c = 'Activo';
        oCaseCerrado.CC_MCC_Motivo__c = motiv.Id;
		oCaseCerrado.CC_MCC_ProdServ__c = prod.Id;
        oCaseCerrado.CC_MCC_Tematica__c = tem.Id;
        oCaseCerrado.CC_Tipo_ChatTranscript__c = 'Hidden';
        oCaseCerrado.CC_Detalles_Consulta__c = 'Prueba';
        oCaseCerrado.CC_Detalles_Solucion__c = 'Prueba';
        oCaseCerrado.CC_Id_Cognitivo__c = '87654321_9999999';
        oCaseCerrado.CC_MCC_Causa__c = causa.Id;
        oCaseCerrado.CC_MCC_Solucion__c = sol.Id;
        oCaseCerrado.AccountId = cuenta.Id;
        oCaseCerrado.ContactId = b.Id;
        insert oCaseCerrado;
        
        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicioEmpleado();
        String jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(s1.CC_Codigo__c, '', oCaseCerrado.Id, '');
        Id idLlamada = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        CC_Llamada__c llamada = [SELECT Id, Name, CC_Asunto__c, CC_Id_Cognitivo__c, CC_Idioma__c, CC_Servicio_Genesys__c, CC_Tipo__c, CC_ConnId__c,
                                 CC_ANI__c, CC_Agente__c, CC_Canal_del_Empleado__c, CC_Case_Consulta__c, CC_Cognitivo__c, CC_ConnId_Cognitivo__c,
                                 CC_ConnId_Consulta__c, CC_Contacto__c, CC_Cuenta__c, CC_Datos_Genesys__c, CC_DNIS__c , CC_Extension__c , CC_IdentCliente__c,
                                 CC_Identificado_Manualmente__c, CC_No_Identificado__c
                                 FROM CC_Llamada__c WHERE Id = :idLlamada AND CC_Fecha_Fin__c = NULL];
        llamada.CC_Cuenta__c = cuenta.Id;
        llamada.CC_ConnId_Cognitivo__c = '87654321_9999999';
        llamada.CC_Id_Cognitivo__c = '87654321_9999998';
        update llamada;
        
        Boolean cuentaAsociada = CC_Llamada_Caso_Nuevo_Controller.cuentaAsociada(idLlamada);
        System.assert(cuentaAsociada);
        
        Boolean cerrada = CC_Llamada_Caso_Nuevo_Controller.getLlamada(idLlamada);
        System.assertEquals(false, cerrada);        
        
        Case oCaso = new Case();
        oCaso = CC_WS_Recupera_LogConversacion.CC_WS_Recupera_Conversacion(llamada);
    }
}