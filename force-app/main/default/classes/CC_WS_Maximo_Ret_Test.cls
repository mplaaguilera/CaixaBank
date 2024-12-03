@isTest
public with sharing class CC_WS_Maximo_Ret_Test {
    @testSetup
    static void data(){
         //Usuario SAC General
		User usuarioGeneral = SACH_TestDataFactory.crearUsuarioaSACH(1)[0];      
        Database.insert(usuarioGeneral);

        CC_Clasificacion_Maximo__c clasificacion = new CC_Clasificacion_Maximo__c();
        clasificacion.CC_Path__c = 'ARQUITECTURA \\ TEST';
        clasificacion.CC_Nivel_1__c = 'ARQUITECTURA';
        clasificacion.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        clasificacion.CC_Activa__c = true;
        clasificacion.CC_Propietario__c = 'TEST';
        insert clasificacion;


        String recordTypeGrupo = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();
        grupo.RecordTypeId = recordTypeGrupo;
        grupo.Name = 'Grupo1';
        grupo.CC_External__c = 'GM-0000101';
        insert grupo;

        String recordTypeAgrupador = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();

        CC_Agrupador__c agrupador = new CC_Agrupador__c();
        agrupador.RecordTypeId = recordTypeAgrupador;
        agrupador.CC_Titulo__c = 'Test';
        agrupador.CC_Descripcion__c = 'Test';
        agrupador.CC_GrupoMaximo__c = grupo.Id;
        agrupador.CC_Opcion_Call_Center__c = 'Opcion CalIl Center';
        agrupador.CC_Clasificacion_Maximo__c = clasificacion.Id;
        agrupador.CC_Id_Maximo__c = 'IN526445';
        insert agrupador;


        Contact contacto = new Contact();
        contacto.LastName = 'Test contacto';
        contacto.Email = 'test@test.es';
        insert contacto;

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'Alfabético';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Canal_Operativo__c = 'Sin canal';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Tipo_Cliente__c = 'HDT Empleado';
        insert mccTematica;

        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Personas';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        mccProducto.CC_Tipo_Cliente__c = 'HDT Empleado';
        insert mccProducto;

        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Personas confidenciales';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        mccMotivo.CC_Tipo_Cliente__c = 'HDT Empleado';
        mccMotivo.HDT_Notif_Pdte_Rev_Sol_Maximo__c = true;
        insert mccMotivo;

        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso2.Subject = 'Test Incidencia HDT';
        caso2.Origin = 'Email';
        caso2.ContactId = contacto.Id;
        caso2.CC_NotIncidencia__c = '1';
        caso2.CC_MailTelfNotif__c = 'test@test.es';
        caso2.CC_CanalNotifCli__c = 'Email';
        caso2.CC_Agrupador_Id__c = agrupador.Id;
        caso2.CC_Idioma__c = 'es';
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        insert caso2;


        List <String> owaEmails = new List<String>{('Atención Empleados Contact Center IT Grupo CaixaBank')};

        List <OrgWideEmailAddress> owa = new List <OrgWideEmailAddress>([SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName IN : owaEmails]);

        HDT_Parametros__c params = new HDT_Parametros__c();
        params.Name = 'HDT_Email_Respuesta_Empleados_New';
        params.HDT_Configuracion_1__c = owa[0].Address;
        params.HDT_Configuracion_2__c = owa[0].Address;
        insert params;


        Case caso1 = new Case();
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        caso1.Subject = 'Test Incidencia CC1';
        caso1.Origin = 'Email';
        caso1.ContactId = contacto.Id;
        caso1.CC_NotIncidencia__c = '1';
        caso1.CC_MailTelfNotif__c = 'test@test.es';
        caso1.CC_CanalNotifCli__c = 'Email';
        caso1.CC_Agrupador_Id__c = agrupador.Id;
        caso1.CC_Idioma__c = 'es';

        /*
        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso2.Subject = 'Test Incidencia HDT1';
        caso2.Origin = 'Email';
        caso2.ContactId = contacto.Id;
        caso2.CC_NotIncidencia__c = '1';
        caso2.CC_MailTelfNotif__c = 'test@test.es';
        caso2.CC_CanalNotifCli__c = 'Email';
        caso2.CC_Agrupador_Id__c = agrupador.Id;
        caso2.CC_Idioma__c = 'es';
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;*/


    }

    @isTest
    static void validarDatosEntrada()
    {
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){


        List<CC_WS_Maximo_Ret.CC_WS_Maximo_Input> inputs = new List<CC_WS_Maximo_Ret.CC_WS_Maximo_Input>();
        CC_WS_Maximo_Ret.CC_WS_Maximo_Input datos = new CC_WS_Maximo_Ret.CC_WS_Maximo_Input();

        datos.TICKETID = 'IN526445';
        datos.SIEBELID = 'X';
        datos.ESTADO = 'RESOLV_REV_SOL';
        datos.REQUIEREATENCION = 'N';
        datos.AFFECTEDDATE = '2019-06-03T10:01:42+02:00';
        datos.ITNAFFECTEDFINDATE = '';
        datos.TARGETSTART = '';
        datos.TARGETFINISH = '900606060';
        datos.ACTUALSTART = '23663942R';
       // datos.ACTUALFINISH = 2019-08-27T10:45:37+02:00;
        datos.CREATIONDATE = '2019-08-27T10:45:37+02:00';
        datos.FECHAOBJECTORESOLUCION = '';
        datos.FR2CODE_LONGDESCRIPTION = 'Se ha solucionado correctamente';
        inputs.add(datos);

        //Maximo no encontrado
        List<CC_WS_Maximo_Ret.CC_WS_Maximo_Output> updatear0 = CC_WS_Maximo_Ret.updMaximo(inputs);
        //system.assertEquals('Maximo no localizado.', updatear0[0].sDetalleError);
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo1'];

        CC_Grupo_Colaborador_Contact__c colaborador = new CC_Grupo_Colaborador_Contact__c();
        colaborador.CC_Usuario__c = usuario.Id;
        colaborador.CC_Grupo_Colaborador__c = grupo.Id;
        insert colaborador;
            
        CC_Clasificacion_Maximo__c clasificacion = [SELECT CC_Path__c,CC_Nivel_1__c,CC_Clave_Primaria_Externa__c,CC_Activa__c,CC_Propietario__c  FROM CC_Clasificacion_Maximo__c WHERE CC_Nivel_1__c = 'ARQUITECTURA' LIMIT 1];
        CC_Agrupador__c agrupador = [SELECT Id FROM CC_Agrupador__c WHERE CC_Titulo__c = 'Test' LIMIT 1];

        String recordTypeAgrupador = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
       
        Contact contacto = new Contact();
        contacto.LastName = 'Test contacto';
        contacto.Email = 'test@test.es';
        insert contacto;
        
        /*
        CC_MCC__c mccTematica = [SELECT Id FROM CC_MCC__c WHERE Name = 'Alfabético' LIMIT 1];
        CC_MCC__c mccMotivo = [SELECT Id FROM CC_MCC__c WHERE Name = 'Personas confidenciales' LIMIT 1];
        CC_MCC__c mccProducto = [SELECT Id FROM CC_MCC__c WHERE Name = 'Personas' LIMIT 1];
        

        Case caso1 = new Case();
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        caso1.Subject = 'Test Incidencia CC1';
        caso1.Origin = 'Email';
        caso1.ContactId = contacto.Id;
        caso1.CC_NotIncidencia__c = '1';
        caso1.CC_MailTelfNotif__c = 'test@test.es';
        caso1.CC_CanalNotifCli__c = 'Email';
        caso1.CC_Agrupador_Id__c = agrupador.Id;
        caso1.CC_Idioma__c = 'es';

        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso2.Subject = 'Test Incidencia HDT1';
        caso2.Origin = 'Email';
        caso2.ContactId = contacto.Id;
        caso2.CC_NotIncidencia__c = '1';
        caso2.CC_MailTelfNotif__c = 'test@test.es';
        caso2.CC_CanalNotifCli__c = 'Email';
        caso2.CC_Agrupador_Id__c = agrupador.Id;
        caso2.CC_Idioma__c = 'es';
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;*/
        

        //insert new List<Case>{caso1, caso2};

        List<CC_WS_Maximo_Ret.CC_WS_Maximo_Output> updatear = CC_WS_Maximo_Ret.updMaximo(inputs);
        //system.assertEquals('Maximo actualizado.', updatear[0].sDetalleError);

        //Campos obligatorios pendientes de informar
        List<CC_WS_Maximo_Ret.CC_WS_Maximo_Input> inputsErroneos = new List<CC_WS_Maximo_Ret.CC_WS_Maximo_Input>();
        CC_WS_Maximo_Ret.CC_WS_Maximo_Input datos1 = new CC_WS_Maximo_Ret.CC_WS_Maximo_Input();

        datos1.SIEBELID = 'X';
        datos1.ESTADO = 'RESOLV_REV_SOL';
        datos1.REQUIEREATENCION = 'N';
        datos1.AFFECTEDDATE = '2019-06-03T10:01:42+02:00';
        datos1.ITNAFFECTEDFINDATE = '';
        datos1.TARGETSTART = '';
        datos1.TARGETFINISH = '900606060';
        datos1.ACTUALSTART = '23663942R';
        datos1.CREATIONDATE = '2019-08-27T10:45:37+02:00';
        datos1.FECHAOBJECTORESOLUCION = '';
        datos1.FR2CODE_LONGDESCRIPTION = 'Se ha solucionado correctamente';
        inputsErroneos.add(datos1);

        CC_Agrupador__c agrupadorErroneo = new CC_Agrupador__c();
        agrupadorErroneo.RecordTypeId = recordTypeAgrupador;
        agrupadorErroneo.CC_Titulo__c = 'Test';
        agrupadorErroneo.CC_Descripcion__c = 'Test';
        agrupadorErroneo.CC_GrupoMaximo__c = grupo.Id;
        agrupadorErroneo.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        agrupadorErroneo.CC_Clasificacion_Maximo__c = clasificacion.Id;
        insert agrupadorErroneo;

        List<CC_WS_Maximo_Ret.CC_WS_Maximo_Output> updatearError = CC_WS_Maximo_Ret.updMaximo(inputsErroneos);
        system.assertEquals('Datos obligatorios no informados.', updatearError[0].sDetalleError);

        //Maximo ACCEPTED
        List<CC_WS_Maximo_Ret.CC_WS_Maximo_Input> inputsAccepted = new List<CC_WS_Maximo_Ret.CC_WS_Maximo_Input>();
        CC_WS_Maximo_Ret.CC_WS_Maximo_Input datosAccepted = new CC_WS_Maximo_Ret.CC_WS_Maximo_Input();

        datosAccepted.TICKETID = 'IN526446';
        datosAccepted.SIEBELID = 'X';
        datosAccepted.ESTADO = 'ACCEPTED';
        datosAccepted.REQUIEREATENCION = 'N';
        datosAccepted.AFFECTEDDATE = '2019-06-03T10:01:42+02:00';
        datosAccepted.ITNAFFECTEDFINDATE = '';
        datosAccepted.TARGETSTART = '';
        datosAccepted.TARGETFINISH = '900606060';
        datosAccepted.ACTUALSTART = '23663942R';
        datosAccepted.CREATIONDATE = '2019-08-27T10:45:37+02:00';
        datosAccepted.FECHAOBJECTORESOLUCION = '';
        datosAccepted.FR2CODE_LONGDESCRIPTION = 'Se ha solucionado correctamente';
        inputsAccepted.add(datosAccepted);

        CC_Agrupador__c agrupadorAceptado = new CC_Agrupador__c();
        agrupadorAceptado.RecordTypeId = recordTypeAgrupador;
        agrupadorAceptado.CC_Titulo__c = 'Test';
        agrupadorAceptado.CC_Descripcion__c = 'Test';
        agrupadorAceptado.CC_GrupoMaximo__c = grupo.Id;
        agrupadorAceptado.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        agrupadorAceptado.CC_Clasificacion_Maximo__c = clasificacion.Id;
        agrupadorAceptado.CC_Id_Maximo__c = 'IN526446';
        insert agrupadorAceptado;

        List<CC_WS_Maximo_Ret.CC_WS_Maximo_Output> updatearAccepted = CC_WS_Maximo_Ret.updMaximo(inputsAccepted);
            System.assertEquals('Maximo actualizado.', updatearAccepted[0].sDetalleError);

        }
        
    }

    @isTest
    static void testEnviarNotificacionesCasosPendRevSolucion() {
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){

       
        Case caso3 = [SELECT ContactId, Contact.Email, CC_Idioma__c FROM Case WHERE Subject = 'Test Incidencia HDT'LIMIT 1];
        
        // Ejecuta el método futuro
        Test.startTest();
        List<Id> idCasos = new List<Id>{caso3.Id};
            CC_WS_Maximo_Ret.enviarNotificacionesCasosPendRevSolucion(idCasos);
        Test.stopTest();

        // Verifica que se hayan enviado los correos electrónicos
        List<EmailMessage> correosEnviados = [SELECT Id FROM EmailMessage];
        System.assertEquals(1, correosEnviados.size(), 'Se esperaba enviar un correo electrónico por cada caso');
        }
    }
}