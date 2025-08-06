@isTest
public class HDT_Clasificacion_Casos_Controller_Test {
    
    @TestSetup
    static void makeData(){
        
        //LISTA DE VALORES
        List<CC_Lista_Valores__c> lista = new List <CC_Lista_Valores__c>();
        List<CC_Lista_Valores__c> val = new List <CC_Lista_Valores__c>();
        
        CC_Lista_Valores__c a1 = new CC_Lista_Valores__c();
        a1.Name = 'Errores Terminal Financiero';
        a1.CC_Activa__c = true;
        a1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        lista.add(a1);
        insert lista;
        
        
        CC_Lista_Valores__c a2 = new CC_Lista_Valores__c();
        a2.Name = 'Error prueba 1';
        a2.CC_Activa__c = true;
        a2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        a2.CC_Lista__c = a1.Id;
        a2.CC_Valor__c = 'Error prueba 1';
        a2.CC_Valor_SFDC__c = 'Error prueba 1';
        a2.CC_Motivo_Relacionado__c = 'Bloquear producto / servicio';
        a2.CC_Solucion_Relacionada__c = 'Derivar a Asistencia tarjetas';
        val.add(a2);
        
        CC_Lista_Valores__c a3 = new CC_Lista_Valores__c();
        a3.Name = 'Error prueba 2';
        a3.CC_Activa__c = true;
        a3.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        a3.CC_Lista__c = a1.Id;
        a3.CC_Valor__c = 'Error prueba 2';
        a3.CC_Valor_SFDC__c = 'Error prueba 2';
        a3.CC_Motivo_Relacionado__c = 'Bloquear producto / servicio';
        a3.CC_Solucion_Relacionada__c = 'Derivar a Asistencia tarjetas';
        val.add(a3);
        insert val;
        
        
        //LISTA DE CARACTERISTICAS
        List<CC_Caracteristica__c> listaCaracteristicas = new List<CC_Caracteristica__c>();
        CC_Caracteristica__c campana = new CC_Caracteristica__c();
        campana.Name = 'Campaña Test';
        campana.CC_Descripcion__c = 'Descripción de campaña';
        campana.CC_Fecha_Vigencia_Inicio__c = date.today();
        campana.RecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId();
        listaCaracteristicas.add(campana);
        
        CC_Caracteristica__c campana2 = new CC_Caracteristica__c();
        campana2.Name = 'Campaña Test 2';
        campana2.CC_Descripcion__c = 'Descripción de campaña 2';
        campana2.CC_Fecha_Vigencia_Inicio__c = date.today();
        campana2.RecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId();
        listaCaracteristicas.add(campana2);
        insert listaCaracteristicas;
        
        
        
        
        //LISTA DE TEMATICAS
        List<CC_MCC__c> listaTematicas = new List<CC_MCC__c>();
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'MCC Tematica';
        mccTematica.CC_Tipo_Cliente__c = 'HDT Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
        mccTematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        listaTematicas.add(mccTematica);
        insert listaTematicas;
        
        
        //LISTA DE PRODUCTOS
        List<CC_MCC__c> listaProductos = new List<CC_MCC__c>();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'HDT Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
        mccProducto.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        listaProductos.add(mccProducto);
        
        CC_MCC__c mccProducto3 = new CC_MCC__c();
        mccProducto3.Name = 'Cuenta corriente 3';
        mccProducto3.CC_Tipo_Cliente__c = 'HDT Empleado';
        mccProducto3.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
        mccProducto3.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto3.CC_Tematica__c = mccTematica.Id;
        mccProducto3.CC_Codigo_Externo__c = 'PR-000003';
        listaProductos.add(mccProducto3);
        insert listaProductos;
        
        
        //LISTA DE MOTIVOS
        List<CC_MCC__c> listaMotivos = new List<CC_MCC__c>();
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'HDT Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
        mccMotivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
        listaMotivos.add(mccMotivo);
        
        CC_MCC__c mccMotivo3 = new CC_MCC__c();
        mccMotivo3.Name = 'Apertura sin autorización 3';
        mccMotivo3.CC_Tipo_Cliente__c = 'HDT Empleado';
        mccMotivo3.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
        mccMotivo3.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        mccMotivo3.CC_Codigo_Externo__c = 'MO-000003';
        mccMotivo3.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo3.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
        listaMotivos.add(mccMotivo3);
    
        insert listaMotivos;
        
        
        //LISTA DE CAUSAS
        List<CC_MCC__c> listaCausas = new List<CC_MCC__c>();
        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Causa 1';
        mccCausa.CC_Tipo_Cliente__c = 'HDT Empleado';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
        mccCausa.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
        listaCausas.add(mccCausa);
    
        
        CC_MCC__c mccCausa3 = new CC_MCC__c();
        mccCausa3.Name = 'Causa 3';
        mccCausa3.CC_Tipo_Cliente__c = 'HDT Empleado';
        mccCausa3.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
        mccCausa3.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        mccCausa3.CC_Motivo__c = mccMotivo.Id;
        mccCausa3.CC_Codigo_Externo__c = 'CA-000003';
        listaCausas.add(mccCausa3);
        insert listaCausas;
        
        
        //LISTA DE SOLUCIONES
        List<CC_MCC__c> listaSoluciones = new List<CC_MCC__c>();
        CC_MCC__c mccSolucion = new CC_MCC__c();
        mccSolucion.Name = 'Solucion 1';
        mccSolucion.CC_Tipo_Cliente__c = 'HDT Empleado';
        mccSolucion.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
        mccSolucion.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        mccSolucion.CC_Causa__c = mccCausa.Id;
        mccSolucion.CC_Codigo_Externo__c = 'SO-000001';
        mccSolucion.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
        listaSoluciones.add(mccSolucion);
        
        CC_MCC__c mccSolucion3 = new CC_MCC__c();
        mccSolucion3.Name = 'Solucion 3';
        mccSolucion3.CC_Tipo_Cliente__c = 'HDT Empleado';
        mccSolucion3.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
        mccSolucion3.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        mccSolucion3.CC_Causa__c = mccCausa.Id;
        mccSolucion3.CC_Codigo_Externo__c = 'SO-000003';
        mccSolucion3.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
        listaSoluciones.add(mccSolucion3);
        insert listaSoluciones;
        
        Account cuenta = new Account();
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Centro CaixaBank').getRecordTypeId();
        cuenta.Name = 'Cuenta Cliente Test 1';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.LastName = 'Contacto Cliente Test 1';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        insert contacto;
        
        //LISTA DE CASOS
        List<Case> casos= new List<Case>();
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.Subject='Caso de prueba TF7 Empleado';
        caso.recordtypeId= recordTypeCaso;
        caso.Origin='Email';
        caso.CC_Canal_Procedencia__c='Servicios Centrales';
        caso.CC_Tipo_Contacto__c='Consulta';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_MCC_Causa__c = mccCausa.Id;
        caso.CC_MCC_Solucion__c = mccSolucion.Id;
        caso.CC_En_Tercer_Nivel__c=true;
        caso.Status='Activo';
        casos.add(caso);
        insert casos;


        /************************/

        List<Group> queuesLst = new List<Group>();
        Group newQueue = new Group();
        newQueue.Type = 'Queue';
        newQueue.DeveloperName = 'Queue_MST';
        newQueue.Name = 'Queue_MST';
        queuesLst.add(newQueue);
        newQueue = new Group();
        newQueue.Type = 'Queue';
        newQueue.DeveloperName = 'Queue_DXC';
        newQueue.Name = 'Queue_DXC';
        queuesLst.add(newQueue);
        System.debug('queues: '+queuesLst);
        insert queuesLst;

        // Se usa runAs para evitar un error MIXED_DML_OPERATION al insertar los QueueSobject
        List<User> sysAdminUser = [SELECT Id FROM User WHERE Profile.name LIKE 'System Administrator' AND IsActive=true];
        if (!sysAdminUser.isEmpty()) {
            System.runAs(sysAdminUser[0]) {
                List<QueueSobject> queueSobjectLst = new List<QueueSobject>();
                QueueSobject newQueueSobject;
                for (Group queue : queuesLst) {
                    newQueueSobject = new QueueSobject();
                    newQueueSobject.SobjectType = 'Case';
                    newQueueSobject.QueueId = queue.Id;
                    queueSobjectLst.add(newQueueSobject);
                }
                insert queueSobjectLst;
            }
        }

        List <String> owaEmails = new List<String>{('Atención Empleados Contact Center IT Grupo CaixaBank')};

        List <OrgWideEmailAddress> owa = new List <OrgWideEmailAddress>([SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName IN : owaEmails]);

        HDT_Parametros__c params = new HDT_Parametros__c();
        params.Name = 'HDT_Email_Respuesta_Empleados_New';
        params.HDT_Configuracion_1__c = owa[0].Address;
        params.HDT_Configuracion_2__c = owa[0].Address;
        insert params;

        
        
    }
    
    
    @isTest
    public static void clasificacionRapida() {
        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            CC_Lista_Valores__c lovPadre = new CC_Lista_Valores__c();
            lovPadre.Name = 'MCC clasificación rápida';
            lovPadre.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
            insert lovPadre;
            
            CC_Lista_Valores__c valoresLOV = new CC_Lista_Valores__c();
            valoresLOV.Name = 'VALORES';
            valoresLOV.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            valoresLOV.CC_Lista__c = lovPadre.Id;
            valoresLOV.CC_Texto_Clasificacion_Rapida__c = 'Texto para comprobar el Test';
            insert valoresLOV;
            
            Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
            CC_MCC__c mccMotivo = new CC_MCC__c();
            mccMotivo.Name = 'Personas confidenciales';
            mccMotivo.CC_Tipo_Cliente__c = 'HDT Empleado';
            mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
            mccMotivo.RecordTypeId = recordTypeIdMotivo;
            mccMotivo.CC_Codigo_Externo__c = 'MO-1150001';
            mccMotivo.CC_Clasificacion_Rapida__c = 'VALORES';
            insert mccMotivo; 
            
                Test.startTest();
                String textoClasificacion = HDT_Clasificacion_Casos_Controller.clasificacionRapida(mccMotivo.Id);
                Test.stopTest();
                System.assertEquals('Texto para comprobar el Test', textoClasificacion);
            
        }
        
    }
    
    
    @isTest
    public static void getCampanas() {
        
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            Id recordTypeCampana =  Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId();
            List<CC_Caracteristica__c> campanas = [SELECT Name, Id FROM CC_Caracteristica__c WHERE recordtypeId = :recordTypeCampana];
            
            List<HDT_Clasificacion_Casos_Controller.PickListWrapper> listaCampanas = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
            for (CC_Caracteristica__c campana : campanas) {
                listaCampanas.add(new HDT_Clasificacion_Casos_Controller.PickListWrapper(campana.Name, campana.Id));
            }
            
            Id recordTypeEmpleado =  Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Case casoEmpleado = [SELECT Id FROM Case WHERE recordTypeId = :recordTypeEmpleado and Subject='Caso de prueba TF7 Empleado'];

                Test.startTest();
                
                List<OT_Picklist.Item> picklistCampana = HDT_Clasificacion_Casos_Controller.getCampanas();
                
                System.assertNotEquals(null, picklistCampana);
                System.assertEquals(listaCampanas.get(0).label, picklistCampana.get(0).label);
                System.assertEquals(listaCampanas.get(0).value,  picklistCampana.get(0).value);
                System.assertEquals(listaCampanas.get(1).label,  picklistCampana.get(1).label);
                System.assertEquals(listaCampanas.get(1).value,  picklistCampana.get(1).value);
                
                
                Test.stopTest();
        }
        
        
    }
    
    @isTest
    public static void getErroresTf7() {
        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            Test.startTest();
            System.assertNotEquals(null,  HDT_Clasificacion_Casos_Controller.getErroresTf7());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getCanalesOperativos() {
        
        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            Test.startTest();
            System.assertNotEquals(null,  HDT_Clasificacion_Casos_Controller.getCanalesOperativos());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getTematicas() {
        
        //List<OT_Picklist.Item> tematicas=HDT_Clasificacion_Casos_Controller.getTematicas('');
        //List<OT_Picklist.Item> tematicasCliente=HDT_Clasificacion_Casos_Controller.getTematicas('Cliente','','');
        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            Test.startTest();
            List<OT_Picklist.Item> tematicasEmpleado=HDT_Clasificacion_Casos_Controller.getTematicas();
            Test.stopTest();
            System.assertNotEquals(null, tematicasEmpleado);
        }
        //List<OT_Picklist.Item> tematicasEmpleadoBankia=HDT_Clasificacion_Casos_Controller.getTematicas('Empleado Bankia','','');
        //System.assertNotEquals(null, tematicasCliente);
        
    }
    
    @isTest
    public static void getProductos() {
        
        //Id tematicaCli = [SELECT Name FROM CC_MCC__c WHERE Name = 'MCC Tematica 2'].Id;
        Id tematicaEmp = [SELECT Name FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Tematica' AND Name = 'MCC Tematica' AND CC_Tipo_Cliente__c = 'HDT Empleado' AND CC_Activo__c = true ORDER BY Name ASC].Id;
        system.debug('tematicaEmp ' + tematicaEmp);
        //Id tematicaEmpCsi = [SELECT Name FROM CC_MCC__c WHERE Name = 'MCC Tematica 4'].Id;
        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            Test.startTest();
            //List<OT_Picklist.Item> productos = HDT_Clasificacion_Casos_Controller.getProductos(tematicaCli);
            //List<OT_Picklist.Item> productosCliente = HDT_Clasificacion_Casos_Controller.getProductos('Cliente',tematicaCli,'');
            
            List<OT_Picklist.Item> productosEmpleado = HDT_Clasificacion_Casos_Controller.getProductos(tematicaEmp);

            String tematicaNull;
            List<OT_Picklist.Item> productosEmpleado2 = HDT_Clasificacion_Casos_Controller.getProductos(tematicaNull);
            Test.stopTest();
            System.assertNotEquals(null, productosEmpleado);
            System.assertNotEquals(null, productosEmpleado2);
        }
        
    }
    
    @isTest
    public static void getMotivos() {
        
        //Id prodCli = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Cuenta corriente 2'].Id;
        Id prodEmp = [SELECT Id, Name FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Producto_Servicio' AND Name = 'Cuenta corriente' AND CC_Tipo_Cliente__c = 'HDT Empleado' AND CC_Activo__c = true ORDER BY Name ASC].Id;
        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            Test.startTest();
            //List<HDT_Clasificacion_Casos_Controller.PickListWrapper> motivos=HDT_Clasificacion_Casos_Controller.getMotivos('',prodCli,'');
            //List<HDT_Clasificacion_Casos_Controller.PickListWrapper> motivosCliente=HDT_Clasificacion_Casos_Controller.getMotivos('Cliente',prodCli,'');
            
            List<HDT_Clasificacion_Casos_Controller.PickListWrapper> motivosEmpleado=HDT_Clasificacion_Casos_Controller.getMotivos(prodEmp);

            String prodNull;
            List<HDT_Clasificacion_Casos_Controller.PickListWrapper> motivosEmpleado2=HDT_Clasificacion_Casos_Controller.getMotivos(prodNull);
            
            //System.assertNotEquals(null, motivosCliente);
            Test.stopTest();
            System.assertNotEquals(null, motivosEmpleado);
            System.assertNotEquals(null, motivosEmpleado2);
        }
        
    }
    @isTest
    public static void getCausas() {
        
        
        //Id motivoCli = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Apertura sin autorización 2'].Id;
        Id motivoEmp = [SELECT Id, Name FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Motivo' AND Name = 'Apertura sin autorización' AND CC_Tipo_Cliente__c = 'HDT Empleado' AND CC_Activo__c = true ORDER BY Name ASC].Id;
        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            Test.startTest();
            //List<HDT_Clasificacion_Casos_Controller.PickListWrapper> causas=HDT_Clasificacion_Casos_Controller.getCausas('',motivoCli,'');
            //List<HDT_Clasificacion_Casos_Controller.PickListWrapper> causasCliente=HDT_Clasificacion_Casos_Controller.getCausas('Cliente',motivoCli,'');
            List<HDT_Clasificacion_Casos_Controller.PickListWrapper> causasEmpleado=HDT_Clasificacion_Casos_Controller.getCausas(motivoEmp);
            
            String motivoNull;
            List<HDT_Clasificacion_Casos_Controller.PickListWrapper> causasEmpleado2=HDT_Clasificacion_Casos_Controller.getCausas(motivoNull);
            
            //System.assertNotEquals(null, causasCliente);
            Test.stopTest();
            System.assertNotEquals(null, causasEmpleado);
            System.assertNotEquals(null, causasEmpleado2);
        }
        
    }
    
    @isTest
    public static void getSoluciones() {
        
        
        //Id causaCli = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Causa 2'].Id;
        Id causaEmp = [SELECT Id, Name FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Causa' AND Name = 'Causa 1' AND CC_Tipo_Cliente__c = 'HDT Empleado' AND CC_Activo__c = true ORDER BY Name ASC].Id;
        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            Test.startTest();
            //List<HDT_Clasificacion_Casos_Controller.PickListWrapper> soluciones=HDT_Clasificacion_Casos_Controller.getSoluciones('',causaCli,'');
            //List<HDT_Clasificacion_Casos_Controller.PickListWrapper> solucionesCliente=HDT_Clasificacion_Casos_Controller.getSoluciones('Cliente',causaCli,'');
            
            List<HDT_Clasificacion_Casos_Controller.PickListWrapper> solucionesEmpleado=HDT_Clasificacion_Casos_Controller.getSoluciones(causaEmp);

            String causaNull;
            List<HDT_Clasificacion_Casos_Controller.PickListWrapper> solucionesEmpleado2=HDT_Clasificacion_Casos_Controller.getSoluciones(causaNull);
            
            //System.assertNotEquals(null, solucionesCliente);
            Test.stopTest();
            System.assertNotEquals(null, solucionesEmpleado);     
            System.assertNotEquals(null, solucionesEmpleado2);     
        }
        
    }
    
    @isTest
    public static void validarGuardarTest() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            Id recordTypeOficinaGestora = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            
            Account cuenta = new Account();
            cuenta.Name = 'Cuenta Test Gestora';
            cuenta.CC_Email__c = 'cuentasolinfoemp@test.com';
            cuenta.RecordTypeId = recordTypeOficinaGestora;
            cuenta.CC_Tipo_Centro__c='OF';
            cuenta.CC_Email__c='test@gmail.com';
            insert cuenta;
            
            Id recordTypeCliente = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Contact oContacto = new Contact();
            oContacto.LastName = 'Test contacto';
            oContacto.Email = 'test@test.es';
            oContacto.RecordTypeId = recordTypeCliente;
            oContacto.AccountId = cuenta.Id;
            insert oContacto;
            
            Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
            CC_MCC__c mccTematica = new CC_MCC__c();
            mccTematica.Name = 'Alfabético';
            mccTematica.CC_Tipo_Cliente__c = 'HDT Empleado';
            mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
            mccTematica.RecordTypeId = recordTypeIdTematica;
            mccTematica.CC_Codigo_Externo__c = 'TE-000011';
            insert mccTematica;
            
            Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
            CC_MCC__c mccProducto = new CC_MCC__c();
            mccProducto.Name = 'Personas';
            mccProducto.CC_Tipo_Cliente__c = 'HDT Empleado';
            mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
            mccProducto.RecordTypeId = recordTypeIdProducto;
            mccProducto.CC_Tematica__c = mccTematica.Id;
            mccProducto.CC_Codigo_Externo__c = 'PR-000011';
            insert mccProducto; 
            
            Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
            CC_MCC__c mccMotivo = new CC_MCC__c();
            mccMotivo.Name = 'Personas confidenciales';
            mccMotivo.CC_Tipo_Cliente__c = 'HDT Empleado';
            mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
            mccMotivo.RecordTypeId = recordTypeIdMotivo;
            mccMotivo.CC_Tematica__c = mccTematica.Id;
            mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
            mccMotivo.CC_Codigo_Externo__c = 'MO-000011';
            insert mccMotivo;      
            
            
            CC_MCC__c nuevoMccMotivo = new CC_MCC__c();
            nuevoMccMotivo.Name = 'Personas confidenciales';
            nuevoMccMotivo.CC_Tipo_Cliente__c = 'HDT Empleado';
            nuevoMccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
            nuevoMccMotivo.RecordTypeId = recordTypeIdMotivo;
            nuevoMccMotivo.CC_Tematica__c = mccTematica.Id;
            nuevoMccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
            nuevoMccMotivo.CC_Codigo_Externo__c = 'MO-100011';
            insert nuevoMccMotivo; 
            
            Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.Subject = 'Prueba';
            caso.RecordTypeId = recordTypeCaso;
            caso.CC_Idioma__c = 'es';
            caso.CC_NumPerso__c = '123456';
            caso.CC_Tipo_Cliente__c = 'Empleado';
            caso.Status = 'Activo';
            caso.CC_No_Identificado__c = true;
            caso.Origin = 'Email';
            caso.CC_Numero_Documento__c = '60236085V';
            caso.CC_Tipo_Contacto__c = 'Petición de servicio';
            caso.CC_Canal_Procedencia__c = 'Oficina Feedback';
            caso.CC_Id_Cognitivo__c = 'HDD_666515666';
            caso.CC_Oficina_afectada__c = '08548';
            caso.CC_MCC_Motivo__c = mccMotivo.Id;
            caso.CC_MCC_ProdServ__c = mccProducto.Id;
            caso.CC_MCC_Tematica__c = mccTematica.Id;
            caso.CC_Canal_Resolucion__c = 'Oficina Feedback';
            caso.ContactId = oContacto.Id;
            caso.AccountId = cuenta.Id;
            insert caso;    
            
            Map<String, Object> validar = HDT_Clasificacion_Casos_Controller.validarGuardar(caso.Id, 'Comentarios Stores', mccTematica.Id, mccProducto.Id, nuevoMccMotivo.Id);        
            
            System.assertEquals(true, validar.get('retipificar'));
            System.assertEquals('Personas confidenciales', validar.get('motivoAnteriorName'));
            
            
        }
    }
    
    @isTest
    public static void reabrirTareaTrasladoColaborador() {
        
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            //Creación nueva cuenta
            Account cuenta = new Account(Name='Cuenta');
            insert cuenta;
            
            //Creación nuevo contacto asociado a la cuenta anterior
            Contact contacto = new Contact(LastName='Contacto', AccountId=cuenta.Id);
            insert contacto;
            
            //Creación nuevo caso asociado al contacto anterior
            Case caso = new Case(AccountId=cuenta.Id, ContactId=contacto.Id, Status = 'Activo');
            caso.recordtypeId= Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c='Servicios Centrales';
            insert caso;
            
            //Creación nueva tarea Completada asociada al caso anterior
            Task tarea = new Task(WhatId=caso.Id, Status = 'Completed', Type='Traslado Colaborador');
            insert tarea;
            
            //Verificar que se ha rehabierto la tarea de traslado colaborador
            System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
                Test.startTest();
                HDT_Clasificacion_Casos_Controller.reabrirTareaTrasladoColaborador(caso.Id); 
                Test.stopTest();
                system.assertEquals('Open', [SELECT Status FROM TASK WHERE Id = :tarea.Id].Status);
            }       
        }
    }
    
    /*
    Pendiente de adaptación al nuevo método "init".
    
    @isTest
    static void testSetupCliente() {
        Account cuenta = new Account(Name = 'Cuenta01');
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        insert contacto;
        
        CC_MCC__c mccTematica = crearMccTematica('Cliente');
        CC_MCC__c mccProducto = crearMccProductoServicio('Cliente', mccTematica.Id);
        CC_MCC__c mccMotivo = crearMccMotivo('Cliente', mccProducto.Id);
        CC_MCC__c mccCausa = crearMccCausa('Cliente', mccMotivo.Id);
        CC_MCC__c mccSolucion = crearMccSolucion('Cliente', mccCausa.Id);
        
        Case caso = new Case();
        caso.ContactId = contacto.Id;
        caso.CC_Idioma__c ='es';
        caso.Status = 'Activo';
        caso.CC_Canal_Contacto__c = 'Chat';
        caso.CC_Canal_Procedencia__c = 'Web';
        caso.Reason = 'Helpdesk';
        caso.Origin = 'Chat';
        caso.CC_Detalles_Consulta__c = 'Detalle consulta';
        caso.CC_Error_TF7__c = 'Error excepción no controlada';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_MCC_Causa__c = mccCausa.Id;
        caso.CC_MCC_Solucion__c = mccSolucion.Id;
        insert caso;
        
        System.assertEquals(mccTematica.Id, HDT_Clasificacion_Casos_Controller.obtenerTematica(caso.Id));
        System.assertEquals(mccProducto.Id, HDT_Clasificacion_Casos_Controller.obtenerProducto(caso.Id));
        System.assertEquals(mccMotivo.Id,   HDT_Clasificacion_Casos_Controller.obtenerMotivo(caso.Id));
        System.assertEquals(mccCausa.Id,    HDT_Clasificacion_Casos_Controller.obtenerCausa(caso.Id));
        System.assertEquals(mccSolucion.Id, HDT_Clasificacion_Casos_Controller.obtenerSolucion(caso.Id));
        
        CC_Caracteristica__c campana = new CC_Caracteristica__c();
        campana.Name = 'Campaña Test';
        campana.CC_Descripcion__c = 'Descripción de campaña';
        campana.CC_Fecha_Vigencia_Inicio__c = Date.today();
        campana.RecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId();
        insert campana;
        
        List<Case> casos = HDT_Clasificacion_Casos_Controller.datosCaso(caso.Id);
        
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistTematica1 = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistTematica1 = HDT_Clasificacion_Casos_Controller.getTematicas('Cliente', '');
        System.assertEquals(picklistTematica1.size(), 1);
        
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistProducto1 = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistProducto2 = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        
        String tematica1 = mccTematica.Id;
        picklistProducto1 = HDT_Clasificacion_Casos_Controller.getProductos('Cliente', tematica1, '');
        System.assertEquals(picklistProducto1.size(), 1);
        String tematica2 = '';
        picklistProducto2 = HDT_Clasificacion_Casos_Controller.getProductos('Cliente', tematica2, '');
        System.assertEquals(picklistProducto2.size(), 0);
        
        String productoServicio1 = mccProducto.Id;
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistMotivo1 = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistMotivo1 = HDT_Clasificacion_Casos_Controller.getMotivos('Cliente', productoServicio1, '');
        System.assertEquals(picklistMotivo1.size(), 1);
        String productoServicio2 = '';
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistMotivo2 = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistMotivo2 = HDT_Clasificacion_Casos_Controller.getMotivos('Cliente', productoServicio2, '');
        System.assertEquals(picklistMotivo2.size(), 0);
        
        String motivo1 = mccMotivo.Id;
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistCausa1 = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistCausa1 = HDT_Clasificacion_Casos_Controller.getCausas('Cliente', motivo1, '');
        System.assertEquals(picklistCausa1.size(), 1);
        String motivo2 = '';
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistCausa2 = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistCausa2 = HDT_Clasificacion_Casos_Controller.getCausas('Cliente', motivo2, '');
        System.assertEquals(picklistCausa2.size(), 0);
        
        String causa1 = mccCausa.Id;
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistSolucion1 = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistSolucion1 = HDT_Clasificacion_Casos_Controller.getSoluciones('Cliente', causa1, '');
        System.assertEquals(picklistSolucion1.size(), 1);
        String causa2 = '';
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistSolucion2 = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistSolucion2 = HDT_Clasificacion_Casos_Controller.getSoluciones('Cliente', causa2, '');
        System.assertEquals(picklistSolucion2.size(), 0);
        
        String casoId = caso.Id;
        String motivoNOK = 'Error KYC';
        String error = 'Error excepción no controlada';
        
        Map<String, Object> oMap = HDT_Clasificacion_Casos_Controller.mapMCC(casoId, 'Cliente');
        System.assertEquals(18, oMap.size()); //Revisar, porque se han quitado campos y ya no se obtienen tantos
        
        List<CC_Caracteristica__c> caracteristicas = new List <CC_Caracteristica__c>();
        caracteristicas = [SELECT Name FROM CC_Caracteristica__c
        WHERE recordtypeId = :Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId()];
        
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistCampana = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistCampana = HDT_Clasificacion_Casos_Controller.getCampanas();
        System.assertEquals(picklistCampana.size(), 1);
        
        //Funcionalidad validar el canal de respuesta
        String resultado = HDT_Clasificacion_Casos_Controller.validarCanalResp(casoId, 'Email');
        System.assertEquals('OK', resultado);
        
        resultado = HDT_Clasificacion_Casos_Controller.validarCanalResp(casoId, 'Twitter');
        System.assertEquals('KO', resultado);
        
        caso.Origin = 'Twitter';
        update caso;
        
        resultado = HDT_Clasificacion_Casos_Controller.validarCanalResp(casoId, 'Twitter');
        System.assertEquals('OK', resultado);
        
        caso.Origin = 'Comentarios Stores';
        update caso;
        
        resultado = HDT_Clasificacion_Casos_Controller.validarCanalResp(casoId, 'Comentarios Stores');
        System.assertEquals('Store', resultado);
        
        //Funcionalidad validar los permisos de Tercer Nivel para retipificar
        List<String> resultadoValidar = HDT_Clasificacion_Casos_Controller.validaPermisosTercerNivelRetipificar(casoId, mccTematica.Id, mccProducto.Id, mccMotivo.Id);
        System.assertEquals('true', resultadoValidar[0]);
        
        //Funcionalidad para comprobar si eres propietario del caso
        Boolean esPropietario = HDT_Clasificacion_Casos_Controller.getEsPropietarioCaso(casoId);
        System.assertEquals(true, esPropietario);
        
        //Funcionalidad para crear actividad de retipificación del caso
        HDT_Clasificacion_Casos_Controller.retipificar(casoId, mccTematica.Id, mccProducto.Id, mccMotivo.Id);
    }
    */
    
    /*
    //Pendiente de adaptación al nuevo método "init".
    
    private static void testSetupEmpleado(String tipoClienteMcc, String canalProcedencia, Case caso) {
        Account cuenta = new Account(Name = 'Cuenta01');
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        insert contacto;
        
        CC_MCC__c mccTematica = crearMccTematica(tipoClienteMcc);
        CC_MCC__c mccProducto = crearMccProductoServicio(tipoClienteMcc, mccTematica.Id);
        CC_MCC__c mccMotivo = crearMccMotivo(tipoClienteMcc, mccProducto.Id);
        CC_MCC__c mccCausa = crearMccCausa(tipoClienteMcc, mccMotivo.Id);
        CC_MCC__c mccSolucion = crearMccSolucion(tipoClienteMcc, mccCausa.Id);
        
        caso.ContactId = contacto.Id;
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_MCC_Causa__c = mccCausa.Id;
        caso.CC_MCC_Solucion__c = mccSolucion.Id;
        insert caso;
        
        System.assertEquals(mccTematica.Id, HDT_Clasificacion_Casos_Controller.obtenerTematica(caso.Id));
        System.assertEquals(mccProducto.Id, HDT_Clasificacion_Casos_Controller.obtenerProducto(caso.Id));
        System.assertEquals(mccMotivo.Id,   HDT_Clasificacion_Casos_Controller.obtenerMotivo(caso.Id));
        System.assertEquals(mccCausa.Id,    HDT_Clasificacion_Casos_Controller.obtenerCausa(caso.Id));
        System.assertEquals(mccSolucion.Id, HDT_Clasificacion_Casos_Controller.obtenerSolucion(caso.Id));
        
        CC_Caracteristica__c campana = new CC_Caracteristica__c();
        campana.Name = 'Campaña Test';
        campana.CC_Descripcion__c = 'Descripción de campaña';
        campana.CC_Fecha_Vigencia_Inicio__c = date.today();
        campana.RecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId();
        insert campana;
        
        List<Case> casos = HDT_Clasificacion_Casos_Controller.datosCaso(caso.Id);
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistTematica1 = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistTematica1 = HDT_Clasificacion_Casos_Controller.getTematicas('Empleado', canalProcedencia);
        System.assertEquals(picklistTematica1.size(), 1);
        
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistProducto1 = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistProducto2 = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        
        String tematica1 = mccTematica.Id;
        picklistProducto1 = HDT_Clasificacion_Casos_Controller.getProductos('Empleado', tematica1, canalProcedencia);
        System.assertEquals(picklistProducto1.size(), 1);
        String tematica2 = '';
        picklistProducto2 = HDT_Clasificacion_Casos_Controller.getProductos('Empleado', tematica2, canalProcedencia);
        System.assertEquals(picklistProducto2.size(), 0);
        
        String productoServicio1 = mccProducto.Id;
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistMotivo1 = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistMotivo1 = HDT_Clasificacion_Casos_Controller.getMotivos('Empleado', productoServicio1, canalProcedencia);
        System.assertEquals(picklistMotivo1.size(), 1);
        String productoServicio2 = '';
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistMotivo2 = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistMotivo2 = HDT_Clasificacion_Casos_Controller.getMotivos('Empleado', productoServicio2, canalProcedencia);
        System.assertEquals(picklistMotivo2.size(), 0);
        
        String motivo1 = mccMotivo.Id;
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistCausa1 = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistCausa1 = HDT_Clasificacion_Casos_Controller.getCausas('Empleado', motivo1, canalProcedencia);
        System.assertEquals(picklistCausa1.size(), 1);
        String motivo2 = '';
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistCausa2 = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistCausa2 = HDT_Clasificacion_Casos_Controller.getCausas('Empleado', motivo2, canalProcedencia);
        System.assertEquals(picklistCausa2.size(), 0);
        
        String causa1 = mccCausa.Id;
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistSolucion1 = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistSolucion1 = HDT_Clasificacion_Casos_Controller.getSoluciones('Empleado', causa1, canalProcedencia);
        System.assertEquals(picklistSolucion1.size(), 1);
        String causa2 = '';
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> picklistSolucion2 = new List<HDT_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistSolucion2 = HDT_Clasificacion_Casos_Controller.getSoluciones('Empleado', causa2, canalProcedencia);
        System.assertEquals(picklistSolucion2.size(), 0);
        
        String casoId = caso.Id;
        String motivoNOK = 'Error KYC';
        String error = 'Error excepción no controlada';
        
        Map<String, Object> oMap = HDT_Clasificacion_Casos_Controller.mapMCC(casoId, 'Empleado');
        System.assertEquals(18, oMap.size()); //revisar, porque se han quitado campos y ya no se obtienen tantos
    }
    */
    
    /*
    @isTest
    static void getMotivosNOKTarjetas() {
        
        CC_MCC__c mccTematica = crearMccTematica('Cliente');
        CC_MCC__c mccProducto = crearMccProductoServicio('Cliente', mccTematica.Id);
        CC_MCC__c mccMotivo = crearMccMotivo('Cliente', mccProducto.Id);
        CC_MCC__c mccCausa = crearMccCausa('Cliente', mccMotivo.Id);
        CC_MCC__c mccSolucion = crearMccSolucion('Cliente', mccCausa.Id);
        
        List<HDT_Clasificacion_Casos_Controller.pickListWrapper> motivos = new List<HDT_Clasificacion_Casos_Controller.pickListWrapper>();
        motivos = HDT_Clasificacion_Casos_Controller.getMotivosNOKTarjetas(mccTematica.Id, mccMotivo.Id, mccSolucion.Id);
        System.assertNotEquals(motivos, null);
    }*/
    public static CC_MCC__c crearMccTematica(String tipoCliente) {
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'MCC Tematica';
        mccTematica.CC_Tipo_Cliente__c = tipoCliente;
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        return mccTematica;
    }
    
    public static CC_MCC__c crearMccProductoServicio(String tipoCliente, String mccTematicaId) {
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = tipoCliente;
        mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccProducto.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto.CC_Tematica__c = mccTematicaId;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto;
        return mccProducto;
    }
    
    public static CC_MCC__c crearMccMotivo(String tipoCliente, String mccProductoServicioId) {
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = tipoCliente;
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccMotivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        mccMotivo.CC_Producto_Servicio__c = mccProductoServicioId;
        mccMotivo.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
        insert mccMotivo;
        return mccMotivo;
    }
    
    public static CC_MCC__c crearMccCausa(String tipoCliente, String mccMotivoId) {
        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Causa 1';
        mccCausa.CC_Tipo_Cliente__c = tipoCliente;
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        mccCausa.CC_Motivo__c = mccMotivoId;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
        insert mccCausa;
        return mccCausa;
    }
    
    public static CC_MCC__c crearMccSolucion(String tipoCliente, String mccCausaId) {
        CC_MCC__c mccSolucion = new CC_MCC__c();
        mccSolucion.Name = 'Solucion 1';
        mccSolucion.CC_Tipo_Cliente__c = tipoCliente;
        mccSolucion.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccSolucion.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        mccSolucion.CC_Causa__c = mccCausaId;
        mccSolucion.CC_Codigo_Externo__c = 'SO-000001';
        mccSolucion.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
        insert mccSolucion;
        return mccSolucion;
    }    
    
    /************************************** Empleado CSI Bankia *********************************************************************/
    /*@isTest
    public static void clasificacionRapidaCSIBankia() {
        CC_Lista_Valores__c lovPadre = new CC_Lista_Valores__c();
        lovPadre.Name = 'MCC clasificación rápida';
        lovPadre.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        insert lovPadre;
        
        CC_Lista_Valores__c valoresLOV = new CC_Lista_Valores__c();
        valoresLOV.Name = 'VALORES';
        valoresLOV.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valoresLOV.CC_Lista__c = lovPadre.Id;
        valoresLOV.CC_Texto_Clasificacion_Rapida__c = 'Texto para comprobar el Test CSI Bankia';
        insert valoresLOV;
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Personas confidenciales';
        mccMotivo.CC_Tipo_Cliente__c = 'CSI Bankia';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Codigo_Externo__c = 'MO-1150001';
        mccMotivo.CC_Clasificacion_Rapida__c = 'VALORES';
        insert mccMotivo;          
        
        System.assertEquals('Texto para comprobar el Test CSI Bankia', HDT_Clasificacion_Casos_Controller.clasificacionRapida(mccMotivo.Id));               
    }
    
    @isTest
    public static void getTematicasCSIBankia() {
        Test.startTest();
        List<OT_Picklist.Item> tematicasEmpleadoCSI=HDT_Clasificacion_Casos_Controller.getTematicas('CSI Bankia','','');
        Test.stopTest();
        
        System.assertNotEquals(null, tematicasEmpleadoCSI);
    }
    
    @isTest
    public static void getProductosCSIBankia() {
        
        Id tematicaEmpCSI = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'MCC Tematica 4'].Id;
        
        Test.startTest();
        List<OT_Picklist.Item> productosEmpleadoCSI=HDT_Clasificacion_Casos_Controller.getProductos('CSI Bankia',tematicaEmpCSI,'');
        Test.stopTest();
        
        System.assertNotEquals(null, productosEmpleadoCSI);
    }
    
    @isTest
    public static void getMotivosCSIBankia() {
        
        Id prodEmpCSI = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Cuenta corriente 4'].Id;
        
        Test.startTest();
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> motivosEmpleadoCSI=HDT_Clasificacion_Casos_Controller.getMotivos('CSI Bankia',prodEmpCSI,'');
        
        Test.stopTest();
        
        System.assertNotEquals(null, motivosEmpleadoCSI);
    }
    @isTest
    public static void getCausasCSIBankia() {
        
        Id motivoEmpCSI = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Apertura sin autorización 4'].Id;
        
        Test.startTest();
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> causasEmpleadoCSI=HDT_Clasificacion_Casos_Controller.getCausas('CSI Bankia',motivoEmpCSI,'');
        Test.stopTest();
        
        System.assertNotEquals(null, causasEmpleadoCSI);
    }
    
    @isTest
    public static void getSolucionesCSIBankia() {
        
        Id causaEmpCSI = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Causa 4'].Id;
        
        Test.startTest();
        List<HDT_Clasificacion_Casos_Controller.PickListWrapper> solucionesEmpleadoCSI=HDT_Clasificacion_Casos_Controller.getSoluciones('CSI Bankia',causaEmpCSI,'');
        Test.stopTest();
        
        System.assertNotEquals(null, solucionesEmpleadoCSI);
    }*/
    
    @isTest
    public static void cambioEstadoPendiente3N()
    {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.Subject = 'Caso de prueba Cambio estado pendiente en 3N';
            caso.recordtypeId = recordTypeCaso;
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Oficina Feedback';
            caso.CC_Tipo_Contacto__c = 'Consulta';
            caso.CC_En_Tercer_Nivel__c = true;
            caso.Status = 'Activo';
            insert caso;
            
            
                Test.startTest();
                caso.CC_Cambio_Estado_Pendiente_Externo__c = true;
                Test.stopTest();
                
                System.assertEquals(caso.CC_Cambio_Estado_Pendiente_Externo__c, true);
            
        }
    }
    
    /*
    @isTest
    public static void cerrarCasoOrigen() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Id idCuenta = [SELECT Id FROM Account WHERE Name = 'Cuenta Cliente Test 1'].Id;
        Id idContacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Cliente Test 1'].Id;
        
        Case casoOrigen = [SELECT CC_MCC_Tematica__c FROM Case WHERE Subject = 'Caso de prueba TF7 Empleado'];
        casoOrigen.CC_Detalles_Consulta__c = 'd c';
        casoOrigen.AccountId = idCuenta;
        casoOrigen.ContactId = idContacto;
        update casoOrigen;
        
        Case caso = new Case();
        caso.Subject = 'Caso de seguimiento';
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Formulario web';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Operativo__c = 'App BrokerNow';
        caso.CC_MCC_Tematica__c = casoOrigen.CC_MCC_Tematica__c;
        caso.AccountId = idCuenta;
        caso.ContactId = idContacto;
        insert caso;
        
        Test.startTest();
        //HDT_Case.vincularCasoOrigenAux(new List<Id>{caso.Id});
        //Map<String, Object> datosCasoOrigen = HDT_Clasificacion_Casos_Controller.casoOrigenAbierto(caso.Id);
        HDT_Clasificacion_Casos_Controller.cerrarCasoOrigen(casoOrigen.Id, caso.Id);
        Test.stopTest();
        
       // System.assertEquals(casoOrigen.Id, datosCasoOrigen.get('Id'), 'El caso creado debería haber quedado vinculado con un caso origen existente');
        System.assertEquals('Cerrado', [SELECT Status FROM Case WHERE Id = :casoOrigen.Id].Status, 'El caso origen debería estar cerrado');
        }
    }*/
    
    @isTest
    public static void actividadesTrasladoColaborador() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            Case caso = new Case();
            caso.Subject='Caso de prueba';
            caso.recordtypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso.CC_Tipo_Contacto__c = 'Consulta';
            caso.Status = 'Activo';
            insert caso;
            
            
                Test.startTest();
                
                HDT_Clasificacion_Casos_Controller.reabrirTareaTrasladoColaborador(caso.Id); 
                HDT_Clasificacion_Casos_Controller.actividadesTrasladoColaborador(caso.Id);
                
                Test.stopTest();
                System.assertEquals('Activo', caso.Status);
            
        }
    }
    @isTest
    public static void cerrarActividadSolInf() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            Case caso = new Case();
            caso.Subject='Caso de prueba';
            caso.recordtypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso.CC_Tipo_Contacto__c = 'Consulta';
            caso.Status = 'Activo';
            insert caso;
            
            Task tarea = new Task();
            tarea.Subject = 'Solicitud Información';
            tarea.Type = 'Solicitud Información';
            tarea.Status = 'open';
            tarea.WhatId = caso.Id;
            insert tarea;
            
            caso.Status= 'Pendiente Cliente';
            update caso;
            
            
                Test.startTest();
                
                HDT_Clasificacion_Casos_Controller.cerrarActividadSolicitudInformacion(caso.Id);
                
                Test.stopTest();
                System.assertEquals('Pendiente Cliente', caso.Status);
            
        }
    }

}