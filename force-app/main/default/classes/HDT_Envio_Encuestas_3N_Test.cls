@isTest
public class HDT_Envio_Encuestas_3N_Test {
    @isTest
    static void enviarEncuesta() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
          // Inicialización de datos.        
          Id recorTypeLista = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId(); 
          CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
          lista.Name = 'HDT - Envío de Encuesta 3N - Canales de resolución';
          lista.CC_Activa__c = true;
          lista.RecordTypeId = recorTypeLista;
          insert lista;

          Id listaPadre = [SELECT id FROM CC_Lista_Valores__c WHERE Name = 'HDT - Envío de Encuesta 3N - Canales de resolución' limit 1].Id;
          // Crear un registro de CC_Lista_Valores__c para simular un resultado válido
          CC_Lista_Valores__c listaValor = new CC_Lista_Valores__c(
              Name = 'Servicios Centrales',
              CC_Activa__c = true,
              CC_Valor__c = 'No EDG',
              CC_Lista__c = listaPadre
  
          );
          insert listaValor;
  
          CC_Lista_Valores__c listaValor2 = new CC_Lista_Valores__c(
              Name = 'EDG-CREDIFIMO',
              CC_Activa__c = true,
              CC_Valor__c = 'EDG',
              CC_Lista__c = listaPadre
  
          );
          insert listaValor2;



        List <String> owaEmails = new List<String>{('Atención Empleados Contact Center IT Grupo CaixaBank')};

        List <OrgWideEmailAddress> owa = new List <OrgWideEmailAddress>([SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName IN : owaEmails]);

        HDT_Parametros__c params = new HDT_Parametros__c();
        params.Name = 'HDT_Email_Respuesta_Empleados_New';
        params.HDT_Configuracion_1__c = owa[0].Address;
        params.HDT_Configuracion_2__c = owa[0].Address;
        insert params;

        HDT_Parametros__c params2 = new HDT_Parametros__c();
        params2.Name = 'HDT_Envio_Encuesta_3N_EDG';
        params2.HDT_Configuracion_1__c = owa[0].Address;
        params2.HDT_Configuracion_2__c = owa[0].Address;
        insert params2;


        CC_Lista_Valores__c lovEncuestas = new CC_Lista_Valores__c();
        lovEncuestas.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovEncuestas.CC_Activa__c = true;
        lovEncuestas.Name = 'Envío de Encuesta 3N - Canales de resolución';
        insert lovEncuestas;
        
        CC_Lista_Valores__c valorEncuesta = new CC_Lista_Valores__c();
        valorEncuesta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorEncuesta.CC_Activa__c = true;
        valorEncuesta.CC_Lista__c = lovEncuestas.Id;
        valorEncuesta.Name = 'Web';
        valorEncuesta.CC_Valor__c = 'Web';
        insert valorEncuesta;
        
        CC_Envio_Encuesta__c encuesta = new CC_Envio_Encuesta__c();
		encuesta.Name = 'CC_URL_Encuesta';
		encuesta.CC_Id_Encuesta__c = '687532';
		encuesta.CC_Link_LimeSurvey__c = 'https://opina.caixabank.com/index.php?r=survey/index&';
        insert encuesta;
        
      	Id recordTypeOficinaGestora = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Account cuentaGestora = new Account();
        cuentaGestora.Name = 'Cuenta Test Gestora';
        cuentaGestora.CC_Email__c = 'cuentasolinfoemp@test.com';
        cuentaGestora.RecordTypeId = recordTypeOficinaGestora;
        cuentaGestora.CC_Tipo_Centro__c='OF';
        cuentaGestora.CC_Email__c='test@gmail.com';
        insert cuentaGestora;
               
        Id recordTypeCuenta = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Cliente';
        cuenta.RecordTypeId = recordTypeCuenta;
        cuenta.CC_OficinaGestoraId__c=cuentaGestora.Id;
        insert cuenta;
        
        //Id recordTypeCliente = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        oContacto.RecordTypeId = recordTypeCliente;
        oContacto.AccountId = cuenta.Id;
        insert oContacto;
                
        //Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();

        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Alfabético';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-100001';
        insert mccTematica;
        
        //Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Personas';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-100001';
        insert mccProducto; 
        
        //Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeIdMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Personas confidenciales';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-100001';
        insert mccMotivo;        
            
        //Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.CC_NumPerso__c = '123456';
        caso.CC_Tipo_Cliente__c = 'Empleado';
        caso.Status = 'Activo';
        caso.CC_No_Identificado__c = true;
        caso.Origin = 'Phone';
        caso.CC_Canal_Procedencia__c = 'EDG-CREDIFIMO';
        caso.CC_Canal_Resolucion__c = 'EDG-CREDIFIMO';
        caso.CC_Numero_Documento__c = '60236005V';
        caso.CC_Id_Cognitivo__c = 'HDD_666555666';
        caso.CC_Oficina_afectada__c = '08548';
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
		caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.ContactId = oContacto.Id;
        caso.AccountId = cuenta.Id;
        insert caso;     
        
        //Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
        
        Task task = new Task();
		task.Type = 'Traslado Tercer Nivel';
        task.status = 'Open';
        task.Subject = 'Email'; 
        task.WhatId = caso.Id;
        task.RecordTypeId = taskRecordTypeId;
        insert task; 
        
        List<Id> idcases= new List<Id>();
        idcases.add(caso.Id);
               
        Test.startTest();
            HDT_Envio_Encuestas_3N.enviarEncuesta(idcases);
            Case caseInfo = [SELECT Id, CC_URL_Encuesta_3N__c FROM Case WHERE Id = : caso.Id LIMIT 1];
            System.assertNotEquals(Null, caseInfo.CC_URL_Encuesta_3N__c, 'En caso que falle hay que activar el valor de web en la lista de valores');
        Test.stopTest();

        }
    }

    @isTest
    static void enviarEncuestaNoEDG() {

        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

            // Inicialización de datos.        
          Id recorTypeLista = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId(); 
          CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
          lista.Name = 'HDT - Envío de Encuesta 3N - Canales de resolución';
          lista.CC_Activa__c = true;
          lista.RecordTypeId = recorTypeLista;
          insert lista;

            Id listaPadre = [SELECT id FROM CC_Lista_Valores__c WHERE Name = 'HDT - Envío de Encuesta 3N - Canales de resolución' limit 1].Id;
            // Crear un registro de CC_Lista_Valores__c para simular un resultado válido
            CC_Lista_Valores__c listaValor = new CC_Lista_Valores__c(
                Name = 'Incidencias Técnicas',
                CC_Activa__c = true,
                CC_Valor__c = 'No EDG',
                CC_Lista__c = listaPadre
    
            );
            insert listaValor;
    
            CC_Lista_Valores__c listaValor2 = new CC_Lista_Valores__c(
                Name = 'EDG-MICROBANK',
                CC_Activa__c = true,
                CC_Valor__c = 'EDG',
                CC_Lista__c = listaPadre
    
            );
            insert listaValor2;

        List <String> owaEmails = new List<String>{('Atención Empleados Contact Center IT Grupo CaixaBank')};
        
        List <OrgWideEmailAddress> owa = new List <OrgWideEmailAddress>([SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName IN : owaEmails]);

        HDT_Parametros__c params = new HDT_Parametros__c();
        params.Name = 'HDT_Email_Respuesta_Empleados_New';
        params.HDT_Configuracion_1__c = owa[0].Address;
        params.HDT_Configuracion_2__c = owa[0].Address;
        insert params;

        HDT_Parametros__c params2 = new HDT_Parametros__c();
        params2.Name = 'HDT_Envio_Encuesta_3N';
        params2.HDT_Configuracion_1__c = owa[0].Address;
        params2.HDT_Configuracion_2__c = owa[0].Address;
        insert params2;



        CC_Lista_Valores__c lovEncuestas = new CC_Lista_Valores__c();
        lovEncuestas.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovEncuestas.CC_Activa__c = true;
        lovEncuestas.Name = 'Envío de Encuesta 3N - Canales de resolución';
        insert lovEncuestas;
        
        CC_Lista_Valores__c valorEncuesta = new CC_Lista_Valores__c();
        valorEncuesta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorEncuesta.CC_Activa__c = true;
        valorEncuesta.CC_Lista__c = lovEncuestas.Id;
        valorEncuesta.Name = 'Web';
        valorEncuesta.CC_Valor__c = 'Web';
        insert valorEncuesta;
        
        CC_Envio_Encuesta__c encuesta = new CC_Envio_Encuesta__c();
		encuesta.Name = 'CC_URL_Encuesta';
		encuesta.CC_Id_Encuesta__c = '687532';
		encuesta.CC_Link_LimeSurvey__c = 'https://opina.caixabank.com/index.php?r=survey/index&';
        insert encuesta;
        
        Id recordTypeOficinaGestora = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuentaGestora = new Account();
        cuentaGestora.Name = 'Cuenta Test Gestora';
        cuentaGestora.CC_Email__c = 'cuentasolinfoemp@test.com';
        cuentaGestora.RecordTypeId = recordTypeOficinaGestora;
        cuentaGestora.CC_Tipo_Centro__c='OF';
        cuentaGestora.CC_Email__c='test@gmail.com';
        insert cuentaGestora;
        
        //Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();        
        Id recordTypeCuenta = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Cliente';
        cuenta.RecordTypeId = recordTypeCuenta;
        cuenta.CC_OficinaGestoraId__c=cuentaGestora.Id;
        insert cuenta;
        
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        oContacto.RecordTypeId = recordTypeCliente;
        oContacto.AccountId = cuenta.Id;
        insert oContacto;
                
         //Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
         Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();

         CC_MCC__c mccTematica = new CC_MCC__c();
         mccTematica.Name = 'Alfabético';
         mccTematica.CC_Tipo_Cliente__c = 'Empleado';
         mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
         mccTematica.RecordTypeId = recordTypeIdTematica;
         mccTematica.CC_Codigo_Externo__c = 'TE-100001';
         insert mccTematica;
         
         //Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
         Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
         CC_MCC__c mccProducto = new CC_MCC__c();
         mccProducto.Name = 'Personas';
         mccProducto.CC_Tipo_Cliente__c = 'Empleado';
         mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
         mccProducto.RecordTypeId = recordTypeIdProducto;
         mccProducto.CC_Tematica__c = mccTematica.Id;
         mccProducto.CC_Codigo_Externo__c = 'PR-100001';
         insert mccProducto; 
         
         //Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
         Id recordTypeIdMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
            CC_MCC__c mccMotivo = new CC_MCC__c();
         mccMotivo.Name = 'Personas confidenciales';
         mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
         mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
         mccMotivo.RecordTypeId = recordTypeIdMotivo;
         mccMotivo.CC_Tematica__c = mccTematica.Id;
         mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
         mccMotivo.CC_Codigo_Externo__c = 'MO-100001';
         insert mccMotivo;              
            
         Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
         Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();

        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.CC_NumPerso__c = '123456';
        caso.CC_Tipo_Cliente__c = 'Empleado';
        caso.Status = 'Activo';
        caso.CC_No_Identificado__c = true;
        caso.Origin = 'Phone';
        caso.CC_Canal_Procedencia__c = 'Incidencias Técnicas';
        caso.CC_Canal_Resolucion__c = 'Incidencias Técnicas';
        caso.CC_Numero_Documento__c = '60236005V';
        caso.CC_Id_Cognitivo__c = 'HDD_666555666';
        caso.CC_Oficina_afectada__c = '08548';
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
		caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.ContactId = oContacto.Id;
        caso.AccountId = cuenta.Id;
        insert caso;     
                             
        Task task = new Task();
		task.Type = 'Traslado Tercer Nivel';
        task.status = 'Open';
        task.Subject = 'Email'; 
        task.WhatId = caso.Id;
        task.RecordTypeId = taskRecordTypeId;
        insert task; 
        
        List<Id> idcases= new List<Id>();
        idcases.add(caso.Id);
               
        Test.startTest();
            HDT_Envio_Encuestas_3N.enviarEncuesta(idcases);
            Case caseInfo = [SELECT Id, CC_URL_Encuesta_3N__c FROM Case WHERE Id = : caso.Id LIMIT 1];
            System.assertNotEquals(Null, caseInfo.CC_URL_Encuesta_3N__c, 'En caso que falle hay que activar el valor de web en la lista de valores');
        Test.stopTest();
        }
    }
}