/**
 * @description       :
 * @author            : Adrian Mariscal
 * @group             :
 * @last modified on  : 09-01-2022
 * @last modified by  : Adrian Mariscal
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   05-09-2022   Adrian Mariscal   Initial Version
**/
@istest
public class CC_Servicio_Genesys_Test {

	@isTest
	public static void testGetServicioGenesys() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();
        System.runAs (usuarioGestor) {
            CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicio1();

            String jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(s1.CC_Codigo__c, '', '', '12345678');
            Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
            CC_Llamada__c llamada = CC_Llamada_Test.obtenerLlamada(llamadaId);
            Case caso = CC_Llamada.crearVincularCaso(llamada);

            Test.startTest();

            CC_Servicio_Genesys__c servicio = CC_OpenCTI.obtenerServicioGenesys('S1');
            System.assert(servicio != null);

            servicio = CC_OpenCTI.obtenerServicioGenesysDesdeCaso(caso.Id);
            System.assert(servicio != null);

            String prefijo = CC_OpenCTI.obtenerPrefijo('666666666', 'Cliente nacional', caso.Id);
            System.assert(prefijo != null);
            prefijo = CC_OpenCTI.obtenerPrefijo('666666666', 'Cliente internacional', caso.Id);
            System.assert(prefijo != null);
            prefijo = CC_OpenCTI.obtenerPrefijo('666666666', 'Empleado nacional', caso.Id);
            System.assert(prefijo != null);
            prefijo = CC_OpenCTI.obtenerPrefijo('666666666', 'Empleado internacional', caso.Id);
            System.assert(prefijo != null);
            prefijo = CC_OpenCTI.obtenerPrefijo('66666', 'Empleado nacional', caso.Id);
            System.assert(prefijo != null);
        }
    }

    @isTest
	public static void testGetServicioGenesysCSIBankia() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();
        System.runAs (usuarioGestor) {
            CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicioEmpleadoCSI();
            Case caso = CC_Llamada_Test.crearCasoEmpleadoCSI();

            //Realizar la llamada saliente
            String jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(null, null, caso.Id, null);
            Id llamadaId = CC_OpenCTI.registrarLlamadaSaliente(jsonLlamada);
            CC_Llamada__c llamada = CC_Llamada_Test.obtenerLlamada(llamadaId);

            CC_Servicio_Genesys__c servicio = CC_OpenCTI.obtenerServicioGenesys('S5');
            System.assertEquals('CSI Bankia', servicio.CC_Tipo_Cliente__c);

            servicio = CC_OpenCTI.obtenerServicioGenesysDesdeCaso(caso.Id);
            System.assertEquals('CSI Bankia', servicio.CC_Tipo_Cliente__c);

            String prefijo = CC_OpenCTI.obtenerPrefijo('666666666', 'Empleado nacional', caso.Id);
            System.assertEquals('55415', prefijo);
            prefijo = CC_OpenCTI.obtenerPrefijo('666666666', 'Empleado internacional', caso.Id);
            System.assertEquals('554150', prefijo);
            prefijo = CC_OpenCTI.obtenerPrefijo('66666', 'Empleado nacional', caso.Id);
            System.assertEquals('55415', prefijo);
        }
    }

    @isTest
	public static void testObtenerServicioEncuestaDesdeCaso() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();
        System.runAs (usuarioGestor) {
            CC_Servicio_Genesys__c servicioEncuesta = CC_Llamada_Test.crearServicioEncuesta();
            CC_Servicio_Genesys__c servicio = CC_Llamada_Test.crearServicio1();
            servicio.CC_Encuesta__c = servicioEncuesta.Id;
            update servicio;

            Case caso = CC_Llamada_Test.crearCaso();
            String jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(null, null, caso.Id, null);
            Id llamadaId = CC_OpenCTI.registrarLlamadaSaliente(jsonLlamada);

            Test.startTest();
            CC_Servicio_Genesys__c servicioEncuestaSaliente = CC_OpenCTI.obtenerServicioEncuestaDesdeCaso(caso.Id);
            Test.stopTest();

            System.assertNotEquals(null, servicioEncuestaSaliente);
            System.assertEquals(servicioEncuesta.Id, servicioEncuestaSaliente.CC_Encuesta__c);
        }
    }

    @isTest
	public static void testObtenerServicioEncuestaDesdeCasoServicioSinEncuesta() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();
        System.runAs (usuarioGestor) {
            //Creamos servicio sin encuesta
            CC_Servicio_Genesys__c servicio = CC_Llamada_Test.crearServicio1();

            Case caso = CC_Llamada_Test.crearCaso();
            String jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(null, null, caso.Id, null);
            Id llamadaId = CC_OpenCTI.registrarLlamadaSaliente(jsonLlamada);

            Test.startTest();
            CC_Servicio_Genesys__c servicioEncuestaSaliente = CC_OpenCTI.obtenerServicioEncuestaDesdeCaso(caso.Id);
            Test.stopTest();

            System.assertEquals(null, servicioEncuestaSaliente);
        }
    }

    @isTest
	public static void testobtenerServicioSaliente() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();
        System.runAs (usuarioGestor) {
            Case caso = new Case();
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario web';
            insert caso;

            String recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Servicio_Genesys__c','CC_Servicios_Salientes');
            CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c();
            servicio.RecordTypeId = recordTypeId;
            servicio.CC_Codigo__c = 'SALIENTE';
            servicio.CC_VDN__c = '4444444';
            servicio.CC_Canal_Procedencia__c = 'Formulario web';
            insert servicio;

            Test.startTest();
            CC_Servicio_Genesys__c serviciosaliente = CC_Servicio_Genesys.obtenerServicioSaliente(caso.Id);
            Test.stopTest();

            System.assertEquals(servicio.Id, serviciosaliente.Id);
        }
    }

    @isTest
    public static void obtenerQueueId() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();
        System.runAs (usuarioGestor) {
            Id idRecordTypeSvcGenesys = Schema.SObjectType.CC_Servicio_Genesys__c.getRecordTypeInfosByDeveloperName().get('CC_Servicio').getRecordTypeId();
            CC_Servicio_Genesys__c svcCcDefault = new CC_Servicio_Genesys__c();
            svcCcDefault.RecordTypeId = idRecordTypeSvcGenesys;
            svcCcDefault.Name = 'CC Genesys Cloud Outbound Default';
            svcCcDefault.CC_Codigo__c = 'CC_GenesysCloudOutboundDefault';
            svcCcDefault.CSBD_Now_Codigo_Producto__c = 'B';
            svcCcDefault.KIN_Cola_Id_GC__c = 'queueId_CC_GenesysCloudOutboundDefault';
            svcCcDefault.CC_VDN__c = '4444444';
            CC_Servicio_Genesys__c svcCcFormularioWeb = new CC_Servicio_Genesys__c();
            svcCcFormularioWeb.RecordTypeId = idRecordTypeSvcGenesys;
            svcCcFormularioWeb.Name = 'CC Saliente Formulario Web';
            svcCcFormularioWeb.CC_Codigo__c = 'CC_SalienteFormularioWeb';
            svcCcFormularioWeb.CC_Canal_Procedencia__c = 'Formulario web';
            svcCcFormularioWeb.KIN_Cola_Id_GC__c = 'queueId_CC_SalienteFormularioWeb';
            svcCcFormularioWeb.CC_VDN__c = '4444444';
            CC_Servicio_Genesys__c svcCsbdDefault = new CC_Servicio_Genesys__c();
            svcCsbdDefault.RecordTypeId = idRecordTypeSvcGenesys;
            svcCsbdDefault.Name = 'CSBD Genesys Cloud Outbound Default';
            svcCsbdDefault.CC_Codigo__c = 'NIS_GenesysCloudOutboundDefault';
            svcCsbdDefault.KIN_Cola_Id_GC__c = 'queueId_CSBD_GenesysCloudOutboundDefault';
            svcCsbdDefault.CC_VDN__c = '4444444';
            CC_Servicio_Genesys__c svcCsbdPrestamoPlus = new CC_Servicio_Genesys__c();
            svcCsbdPrestamoPlus.RecordTypeId = idRecordTypeSvcGenesys;
            svcCsbdPrestamoPlus.Name = 'CSBD Saliente Préstamo Plus';
            svcCsbdPrestamoPlus.CC_Codigo__c = 'CSBD_SalientePrestamoPlus';
            svcCsbdPrestamoPlus.CSBD_Now_Codigo_Producto__c = 'NowPrestamoPlus';
            svcCsbdPrestamoPlus.KIN_Cola_Id_GC__c = 'queueId_CSBD_SalientePrestamoPlus';
            svcCsbdPrestamoPlus.CC_VDN__c = '4444444';
            CC_Servicio_Genesys__c svcCsbdSinGrabacion = new CC_Servicio_Genesys__c();
            svcCsbdSinGrabacion.RecordTypeId = idRecordTypeSvcGenesys;
            svcCsbdSinGrabacion.Name = 'CSBD Saliente sin grabación';
            svcCsbdSinGrabacion.CC_Codigo__c = 'CSBD_SalienteSinGrabacion';
            svcCsbdSinGrabacion.KIN_Cola_Id_GC__c = 'queueId_CSBD_SalienteSinGrabacion';
            svcCsbdSinGrabacion.CC_VDN__c = '4444444';
            CC_Servicio_Genesys__c svcCsbdConGrabacion = new CC_Servicio_Genesys__c();
            svcCsbdConGrabacion.RecordTypeId = idRecordTypeSvcGenesys;
            svcCsbdConGrabacion.Name = 'CSBD Saliente con grabación';
            svcCsbdConGrabacion.CC_Codigo__c = 'CSBD_SalienteConGrabacion';
            svcCsbdConGrabacion.KIN_Cola_Id_GC__c = 'queueId_CSBD_SalienteConGrabacion';
            svcCsbdConGrabacion.CC_VDN__c = '4444444';
            CC_Servicio_Genesys__c svcCsbdCSCCsinGrabacion = new CC_Servicio_Genesys__c();
            svcCsbdCSCCsinGrabacion.RecordTypeId = idRecordTypeSvcGenesys;
            svcCsbdCSCCsinGrabacion.Name = 'CSBD Saliente CSCC sin grabación';
            svcCsbdCSCCsinGrabacion.CC_Codigo__c = 'CSBD_SalienteCSCCsinGrabacion';
            svcCsbdCSCCsinGrabacion.KIN_Cola_Id_GC__c = 'queueId_CSBD_SalienteCSCCsinGrabacion';
            svcCsbdCSCCsinGrabacion.CC_VDN__c = '4444444';
            CC_Servicio_Genesys__c svcCsbdCSCCconGrabacion = new CC_Servicio_Genesys__c();
            svcCsbdCSCCconGrabacion.RecordTypeId = idRecordTypeSvcGenesys;
            svcCsbdCSCCconGrabacion.Name = 'CSBD Saliente CSCC con grabación';
            svcCsbdCSCCconGrabacion.CC_Codigo__c = 'CSBD_SalienteCSCCconGrabacion';
            svcCsbdCSCCconGrabacion.KIN_Cola_Id_GC__c = 'queueId_CSBD_SalienteCSCCconGrabacion';
            svcCsbdCSCCconGrabacion.CC_VDN__c = '4444444';
            insert new List<CC_Servicio_Genesys__c>{svcCcDefault, svcCcFormularioWeb, svcCsbdDefault, svcCsbdPrestamoPlus, svcCsbdSinGrabacion, svcCsbdConGrabacion, svcCsbdCSCCsinGrabacion, svcCsbdCSCCconGrabacion};

            Id idRecordTypeListaValores = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
            CC_Lista_Valores__c serviciosDefaultCsbd = new CC_Lista_Valores__c();
            serviciosDefaultCsbd.RecordTypeId = idRecordTypeListaValores;
            serviciosDefaultCsbd.Name = 'CSBD: Servicios Genesys por defecto';
            CC_Lista_Valores__c listaProductosGrabacion = new CC_Lista_Valores__c();
            listaProductosGrabacion.RecordTypeId = idRecordTypeListaValores;
            listaProductosGrabacion.Name = 'CSBD: Productos con grabación de llamadas salientes';
            insert new List<CC_Lista_Valores__c>{serviciosDefaultCsbd, listaProductosGrabacion};

            Id idRecordTypeValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            CC_Lista_Valores__c servicioDefaultCsbd = new CC_Lista_Valores__c();
            servicioDefaultCsbd.RecordTypeId = idRecordTypeValor;
            servicioDefaultCsbd.CC_Lista__c = serviciosDefaultCsbd.Id;
            servicioDefaultCsbd.Name = 'Saliente sin grabación';
            servicioDefaultCsbd.CC_Valor__c = 'CSBD_SalienteSinGrabacion';
            CC_Lista_Valores__c servicioDefaultCsbdGrabacion = new CC_Lista_Valores__c();
            servicioDefaultCsbdGrabacion.RecordTypeId = idRecordTypeValor;
            servicioDefaultCsbdGrabacion.CC_Lista__c = serviciosDefaultCsbd.Id;
            servicioDefaultCsbdGrabacion.Name = 'Saliente con grabación';
            servicioDefaultCsbdGrabacion.CC_Valor__c = 'CSBD_SalienteConGrabacion';
            CC_Lista_Valores__c servicioDefaultCsbdCSCCsinGrabacion = new CC_Lista_Valores__c();
            servicioDefaultCsbdCSCCsinGrabacion.RecordTypeId = idRecordTypeValor;
            servicioDefaultCsbdCSCCsinGrabacion.CC_Lista__c = serviciosDefaultCsbd.Id;
            servicioDefaultCsbdCSCCsinGrabacion.Name = 'Saliente sin grabación CSCC';
            servicioDefaultCsbdCSCCsinGrabacion.CC_Valor__c = 'CSBD_SalienteCSCCsinGrabacion';
            CC_Lista_Valores__c servicioDefaultCsbdCSCCconGrabacion = new CC_Lista_Valores__c();
            servicioDefaultCsbdCSCCconGrabacion.RecordTypeId = idRecordTypeValor;
            servicioDefaultCsbdCSCCconGrabacion.CC_Lista__c = serviciosDefaultCsbd.Id;
            servicioDefaultCsbdCSCCconGrabacion.Name = 'Saliente con grabación CSCC';
            servicioDefaultCsbdCSCCconGrabacion.CC_Valor__c = 'CSBD_SalienteCSCCconGrabacion';
            CC_Lista_Valores__c valorProductoGrabacion = new CC_Lista_Valores__c();
            valorProductoGrabacion.RecordTypeId = idRecordTypeValor;
            valorProductoGrabacion.CC_Lista__c = listaProductosGrabacion.Id;
            valorProductoGrabacion.Name = 'Hipoteca Premium';
            valorProductoGrabacion.CSBD_Tipo_de_oportunidad__c = 'Hipoteca;CSCC';
            insert new List<CC_Lista_Valores__c>{servicioDefaultCsbd, servicioDefaultCsbdGrabacion, servicioDefaultCsbdCSCCsinGrabacion, servicioDefaultCsbdCSCCconGrabacion, valorProductoGrabacion};

            Id idRecordCasoCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Case casoFormularioWeb = new Case();
            casoFormularioWeb.RecordTypeId = idRecordCasoCliente;
            casoFormularioWeb.Subject = 'caso1';
            casoFormularioWeb.Origin = 'Email';
            casoFormularioWeb.CC_Canal_Procedencia__c = 'Formulario web';
            Case casoAccionista = new Case();
            casoAccionista.RecordTypeId = idRecordCasoCliente;
            casoAccionista.Subject = 'casoAccionista';
            casoAccionista.Origin = 'Email';
            casoAccionista.CC_Canal_Procedencia__c = 'Accionista';
            insert new List<Case>{casoFormularioWeb, casoAccionista};

            Map<String, Object> camposHipotecaPremium = new Map<String, Object>{'CSBD_Producto__c' => 'Hipoteca Premium'};
            Opportunity hipotecaPremium = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', camposHipotecaPremium);
            Map<String, Object> camposHipotecaExpress = new Map<String, Object>{'CSBD_Producto__c' => 'Hipoteca Express'};
            Opportunity hipotecaExpress = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', camposHipotecaExpress);
            Map<String, Object> camposHipotecaSinProducto = new Map<String, Object>{'CSBD_Producto__c' => null};
            Opportunity llamadaPorDefecto = CSBD_Opportunity.crearOportunidad('CSBD_Llamada_Servicio', camposHipotecaSinProducto);
            Map<String, Object> camposLlamadaServicioPrestamoPlus = new Map<String, Object>{'CSBD_Now_Codigo_Producto__c' => 'NowPrestamoPlus'};
            Opportunity llamadaServicioPrestamoPlus = CSBD_Opportunity.crearOportunidad('CSBD_Llamada_Servicio', camposLlamadaServicioPrestamoPlus);
            Map<String, Object> camposCSCCconGrabacion = new Map<String, Object>{'CSBD_Producto__c' => 'Hipoteca Premium'};
            Opportunity llamadaCSCCconGrabacion = CSBD_Opportunity.crearOportunidad('CSBD_MAC', camposCSCCconGrabacion);
            Map<String, Object> camposCSCCsinGrabacion = new Map<String, Object>{'CSBD_Producto__c' => 'Renting'};
            Opportunity llamadaCSCCsinGrabacion = CSBD_Opportunity.crearOportunidad('CSBD_MAC', camposCSCCsinGrabacion);

            Test.startTest();
            String queueIdCasoFormularioWeb = CC_Servicio_Genesys.obtenerQueueId(casoFormularioWeb.Id, 'Case');
            String queueIdCasoAccionista = CC_Servicio_Genesys.obtenerQueueId(casoAccionista.Id, 'Case');
            String queueIdHipotecaPremium = CC_Servicio_Genesys.obtenerQueueId(hipotecaPremium.Id, 'Opportunity');
            String queueIdHipotecaExpress = CC_Servicio_Genesys.obtenerQueueId(hipotecaExpress.Id, 'Opportunity');
            String queueIdLlamadaPorDefecto = CC_Servicio_Genesys.obtenerQueueId(llamadaPorDefecto.Id, 'Opportunity');
            String queueIdLlamadaServicioPrestamoPlus = CC_Servicio_Genesys.obtenerQueueId(llamadaServicioPrestamoPlus.Id, 'Opportunity');
            String queueIdLlamadaServicioCSCCconGrabacion = CC_Servicio_Genesys.obtenerQueueId(llamadaCSCCconGrabacion.Id, 'Opportunity');
            String queueIdLlamadaServicioCSCCsinGrabacion = CC_Servicio_Genesys.obtenerQueueId(llamadaCSCCsinGrabacion.Id, 'Opportunity');
            Test.stopTest();

            System.assertEquals('queueId_CC_SalienteFormularioWeb', queueIdCasoFormularioWeb, 'Id de cola incorrecto: ' + queueIdCasoFormularioWeb);
            System.assertEquals('queueId_CC_GenesysCloudOutboundDefault', queueIdCasoAccionista, 'Id de cola incorrecto: ' + queueIdCasoAccionista);
            System.assertEquals('queueId_CSBD_SalienteConGrabacion', queueIdHipotecaPremium, 'Id de cola incorrecto: ' + queueIdHipotecaPremium);
            System.assertEquals('queueId_CSBD_SalienteSinGrabacion', queueIdHipotecaExpress, 'Id de cola incorrecto: ' + queueIdHipotecaExpress);
            System.assertEquals('queueId_CSBD_GenesysCloudOutboundDefault', queueIdLlamadaPorDefecto, 'Id de cola incorrecto: ' + queueIdLlamadaPorDefecto);
            System.assertEquals('queueId_CSBD_SalientePrestamoPlus', queueIdLlamadaServicioPrestamoPlus, 'Id de cola incorrecto: ' + queueIdLlamadaServicioPrestamoPlus);
            System.assertEquals('queueId_CSBD_SalienteCSCCconGrabacion', queueIdLlamadaServicioCSCCconGrabacion, 'Id de cola incorrecto: ' + queueIdLlamadaServicioCSCCconGrabacion);
            System.assertEquals('queueId_CSBD_SalienteCSCCsinGrabacion', queueIdLlamadaServicioCSCCsinGrabacion, 'Id de cola incorrecto: ' + queueIdLlamadaServicioCSCCsinGrabacion);
        }
    }
}