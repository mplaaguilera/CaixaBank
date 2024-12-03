@isTest
public class CC_Envio_Encuestas_3N_Test {
    @isTest
    static void enviarEncuesta() {
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
        
        List<CC_Envio_Encuesta__c> listaEncuesta = new List<CC_Envio_Encuesta__c>();
        CC_Envio_Encuesta__c encuesta3 = new CC_Envio_Encuesta__c();
		encuesta3.Name = 'CC_URL_Encuesta';
		encuesta3.CC_Id_Encuesta__c = '687532';
        encuesta3.CC_Tipo_Encuesta__c = 'URL base';
		encuesta3.CC_Link_LimeSurvey__c = 'https://opina.caixabank.com/index.php?r=survey/index&';
        listaEncuesta.add(encuesta3);
        CC_Envio_Encuesta__c encuesta4 = new CC_Envio_Encuesta__c();
		encuesta4.Name = 'CC_TercerNivel';
		encuesta4.CC_Id_Encuesta__c = '687532';
        encuesta4.CC_Tipo_Encuesta__c = 'Chat';
		encuesta4.CC_Link_LimeSurvey__c = 'https://opina.caixabank.com/index.php?r=survey/index&';
        listaEncuesta.add(encuesta4);
        insert listaEncuesta;
        
        Account cuentaGestora = new Account();
        cuentaGestora.Name = 'Cuenta Test Gestora';
        cuentaGestora.CC_Email__c = 'cuentasolinfoemp@test.com';
        cuentaGestora.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuentaGestora.CC_Tipo_Centro__c='OF';
        cuentaGestora.CC_Email__c='test@gmail.com';
        insert cuentaGestora;
              
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Cliente';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.CC_OficinaGestoraId__c=cuentaGestora.Id;
        insert cuenta;
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        oContacto.RecordTypeId =CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        oContacto.AccountId = cuenta.Id;
        oContacto.CC_Matricula__c = 'U01A4123';
        insert oContacto;

        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Alfabético';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        mccTematica.CC_Codigo_Externo__c = 'TE-100001';
        insert mccTematica;
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Personas';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-100001';
        insert mccProducto; 

       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Personas confidenciales';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-100001';
        insert mccMotivo;        
            
        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        caso.CC_Idioma__c = 'es';
        caso.CC_NumPerso__c = '123456';
        caso.CC_Tipo_Cliente__c = 'Empleado';
        caso.Status = 'Activo';
        caso.CC_No_Identificado__c = true;
        caso.Origin = 'Chat';
        caso.CC_Canal_Procedencia__c = 'Web';
        caso.CC_Canal_Resolucion__c = 'Web';
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
        task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        insert task; 
        
        List<Id> idcases= new List<Id>();
        idcases.add(caso.Id);
               
        Test.startTest();
            CC_Envio_Encuestas_3N.enviarEncuesta(idcases);
            Case caseInfo = [SELECT Id, CC_URL_Encuesta_3N__c FROM Case WHERE Id = : caso.Id LIMIT 1];
            System.assertNotEquals(Null, caseInfo.CC_URL_Encuesta_3N__c, 'En caso que falle hay que activar el valor de web en la lista de valores');
        Test.stopTest();
    }
}