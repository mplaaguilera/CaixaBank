@isTest
public class FRA_Case_Gestion_Controller_Test {
    
    @TestSetup
    static void testSetup(){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User usuario = new User();
            usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'FRA_Usuario_Caixabank'].Id;
            usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'FRA'].Id;
            usuario.FirstName = 'Fraude';
            usuario.LastName = 'Prueba';
            usuario.Alias = uniqueName.substring(18, 23);
            usuario.Email = uniqueName + '@test' + orgId + '.org';
            usuario.Username = uniqueName + '@test' + orgId + '.org';
            usuario.EmailEncodingKey = 'UTF-8';
            usuario.LanguageLocaleKey = 'es';
            usuario.LocaleSidKey = 'es_ES';
            usuario.TimezonesIdKey = 'Europe/Madrid';
            insert usuario;
    
            List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
            for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('FRA_PS_Operador')]) {
                PermissionSetAssignment psAssignment = new PermissionSetAssignment();
                psAssignment.AssigneeId = usuario.Id;
                psAssignment.PermissionSetId = ps.Id;
                psAssignments.add(psAssignment);
            }
            insert psAssignments;

            Account a = new Account();
            a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
            a.Name = 'account temp';
            insert a;
            
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
            campana.OS_Negocio__c = 'COPS';
            campana.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Caracteristica__c', 'CC_Campana');
            listaCaracteristicas.add(campana);
            
            CC_Caracteristica__c campana2 = new CC_Caracteristica__c();
            campana2.Name = 'Campaña Test 2';
            campana2.CC_Descripcion__c = 'Descripción de campaña 2';
            campana2.OS_Negocio__c = 'COPS';
            campana2.CC_Fecha_Vigencia_Inicio__c = date.today();
            campana2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Caracteristica__c', 'CC_Campana');
            listaCaracteristicas.add(campana2);
            insert listaCaracteristicas;
            
            //LISTA DE TEMATICAS
            List<CC_MCC__c> listaTematicas = new List<CC_MCC__c>();
            CC_MCC__c mccTematica = new CC_MCC__c();
            mccTematica.Name = 'MCC Tematica';
            mccTematica.CC_Tipo_Cliente__c = 'Empleado';
            mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccTematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            mccTematica.CC_Codigo_Externo__c = 'TE-000001';
            listaTematicas.add(mccTematica);
            
            CC_MCC__c mccTematica2 = new CC_MCC__c();
            mccTematica2.Name = 'MCC Tematica 2';
            mccTematica2.CC_Tipo_Cliente__c = 'Cliente';
            mccTematica2.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccTematica2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            mccTematica2.CC_Codigo_Externo__c = 'TE-000002';
            mccTematica2.CC_Canal_Operativo__c = 'Sin canal';
            listaTematicas.add(mccTematica2);
            
            CC_MCC__c mccTematica3 = new CC_MCC__c();
            mccTematica3.Name = 'MCC Tematica 3';
            mccTematica3.CC_Tipo_Cliente__c = 'Empleado';
            mccTematica3.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccTematica3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            mccTematica3.CC_Codigo_Externo__c = 'TE-000003';
            listaTematicas.add(mccTematica3);
            insert listaTematicas;
            
            //LISTA DE PRODUCTOS
            List<CC_MCC__c> listaProductos = new List<CC_MCC__c>();
            CC_MCC__c mccProducto = new CC_MCC__c();
            mccProducto.Name = 'Cuenta corriente';
            mccProducto.CC_Tipo_Cliente__c = 'Empleado';
            mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccProducto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            mccProducto.CC_Tematica__c = mccTematica.Id;
            mccProducto.CC_Codigo_Externo__c = 'PR-000001';
            listaProductos.add(mccProducto);
            
            CC_MCC__c mccProducto2 = new CC_MCC__c();
            mccProducto2.Name = 'Cuenta corriente 2';
            mccProducto2.CC_Tipo_Cliente__c = 'Cliente';
            mccProducto2.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccProducto2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            mccProducto2.CC_Tematica__c = mccTematica2.Id;
            mccProducto2.CC_Codigo_Externo__c = 'PR-000002';
            listaProductos.add(mccProducto2);
            
            CC_MCC__c mccProducto3 = new CC_MCC__c();
            mccProducto3.Name = 'Cuenta corriente 3';
            mccProducto3.CC_Tipo_Cliente__c = 'Empleado';
            mccProducto3.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccProducto3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            mccProducto3.CC_Tematica__c = mccTematica.Id;
            mccProducto3.CC_Codigo_Externo__c = 'PR-000003';
            listaProductos.add(mccProducto3);
            insert listaProductos;
            
            //LISTA DE MOTIVOS
            List<CC_MCC__c> listaMotivos = new List<CC_MCC__c>();
            CC_MCC__c mccMotivo = new CC_MCC__c();
            mccMotivo.Name = 'Apertura sin autorización';
            mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
            mccMotivo.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccMotivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
            mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
            mccMotivo.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
            listaMotivos.add(mccMotivo);
            
            CC_MCC__c mccMotivo2 = new CC_MCC__c();
            mccMotivo2.Name = 'Apertura sin autorización 2';
            mccMotivo2.CC_Tipo_Cliente__c = 'Cliente';
            mccMotivo2.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccMotivo2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            mccMotivo2.CC_Codigo_Externo__c = 'MO-000002';
            mccMotivo2.CC_Producto_Servicio__c = mccProducto2.Id;
            mccMotivo2.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
            mccMotivo2.OS_Requiere_Ref_Operacion__c = true;
            listaMotivos.add(mccMotivo2);
            
            CC_MCC__c mccMotivo3 = new CC_MCC__c();
            mccMotivo3.Name = 'Apertura sin autorización 3';
            mccMotivo3.CC_Tipo_Cliente__c = 'Empleado';
            mccMotivo3.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccMotivo3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            mccMotivo3.CC_Codigo_Externo__c = 'MO-000003';
            mccMotivo3.CC_Producto_Servicio__c = mccProducto.Id;
            mccMotivo3.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
            mccMotivo3.OS_Requiere_Ref_Operacion__c = true;
            listaMotivos.add(mccMotivo3);
            insert listaMotivos;
            
            //LISTA DE CAUSAS
            List<CC_MCC__c> listaCausas = new List<CC_MCC__c>();
            CC_MCC__c mccCausa = new CC_MCC__c();
            mccCausa.Name = 'Causa 1';
            mccCausa.CC_Tipo_Cliente__c = 'Empleado';
            mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccCausa.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
            mccCausa.CC_Motivo__c = mccMotivo.Id;
            mccCausa.CC_Codigo_Externo__c = 'CA-000001';
            listaCausas.add(mccCausa);
            
            CC_MCC__c mccCausa2 = new CC_MCC__c();
            mccCausa2.Name = 'Causa 2';
            mccCausa2.CC_Tipo_Cliente__c = 'Cliente';
            mccCausa2.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccCausa2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
            mccCausa2.CC_Motivo__c = mccMotivo2.Id;
            mccCausa2.CC_Codigo_Externo__c = 'CA-000002';
            listaCausas.add(mccCausa2);
            
            CC_MCC__c mccCausa3 = new CC_MCC__c();
            mccCausa3.Name = 'Causa 3';
            mccCausa3.CC_Tipo_Cliente__c = 'Empleado';
            mccCausa3.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccCausa3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
            mccCausa3.CC_Motivo__c = mccMotivo.Id;
            mccCausa3.CC_Codigo_Externo__c = 'CA-000003';
            listaCausas.add(mccCausa3);
            insert listaCausas;
            
            //LISTA DE SOLUCIONES
            List<CC_MCC__c> listaSoluciones = new List<CC_MCC__c>();
            CC_MCC__c mccSolucion = new CC_MCC__c();
            mccSolucion.Name = 'Solucion 1';
            mccSolucion.CC_Tipo_Cliente__c = 'Empleado';
            mccSolucion.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccSolucion.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
            mccSolucion.CC_Causa__c = mccCausa.Id;
            mccSolucion.CC_Codigo_Externo__c = 'SO-000001';
            mccSolucion.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
            listaSoluciones.add(mccSolucion);
            
            CC_MCC__c mccSolucion2 = new CC_MCC__c();
            mccSolucion2.Name = 'Solucion 2';
            mccSolucion2.CC_Tipo_Cliente__c = 'Cliente';
            mccSolucion2.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccSolucion2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
            mccSolucion2.CC_Causa__c = mccCausa2.Id;
            mccSolucion2.CC_Codigo_Externo__c = 'SO-000002';
            mccSolucion2.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
            listaSoluciones.add(mccSolucion2);
            
            CC_MCC__c mccSolucion3 = new CC_MCC__c();
            mccSolucion3.Name = 'Solucion 3';
            mccSolucion3.CC_Tipo_Cliente__c = 'Empleado';
            mccSolucion3.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccSolucion3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
            mccSolucion3.CC_Causa__c = mccCausa.Id;
            mccSolucion3.CC_Codigo_Externo__c = 'SO-000003';
            mccSolucion3.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
            listaSoluciones.add(mccSolucion3);
            insert listaSoluciones;
            
            //LISTA DE CASOS
            List<Case> casos= new List<Case>();
            Case caso = new Case();
            caso.Subject='Caso de prueba TF7';
            caso.recordtypeId= CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');
            caso.Origin='Phone';
            caso.CC_Canal_Procedencia__c = 'Teléfono FRAUDE Banca Internacional';
            caso.CC_MCC_Tematica__c = mccTematica.Id;
            caso.CC_MCC_ProdServ__c = mccProducto.Id;
            caso.CC_MCC_Motivo__c = mccMotivo.Id;
            caso.CC_MCC_Causa__c = mccCausa.Id;
            caso.CC_MCC_Solucion__c = mccSolucion.Id;
            caso.CC_En_Tercer_Nivel__c = true;
            caso.Status='Activo';
            casos.add(caso);
            
            Case caso2 = new Case();
            caso2.Subject = 'Caso de prueba TF7';
            caso2.recordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');
            caso2.Origin = 'Phone';
            caso2.CC_Canal_Procedencia__c = 'Teléfono FRAUDE Banca Internacional';
            caso2.CC_MCC_Tematica__c = mccTematica2.Id;
            caso2.CC_MCC_ProdServ__c = mccProducto2.Id;
            caso2.CC_MCC_Motivo__c = mccMotivo2.Id;
            caso2.CC_MCC_Causa__c = mccCausa2.Id;
            caso2.CC_MCC_Solucion__c = mccSolucion2.Id;
            caso2.CC_En_Tercer_Nivel__c = true;
            caso2.Status = 'Activo';
            casos.add(caso2);
            
            Case caso3 = new Case();
            caso3.Subject = 'Caso de prueba TF8';
            caso3.recordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');
            caso3.Origin = 'Phone';
            caso3.CC_MCC_Tematica__c = mccTematica2.Id;
            caso3.CC_MCC_ProdServ__c = mccProducto2.Id;
            caso3.CC_MCC_Motivo__c = mccMotivo2.Id;
            caso3.CC_MCC_Causa__c = mccCausa2.Id;
            caso3.CC_MCC_Solucion__c = mccSolucion2.Id;
            caso3.CC_En_Tercer_Nivel__c = true;
            caso3.Status = 'Activo';
            casos.add(caso3);
            
            insert casos;
        }    
    }
    
    @isTest
    public static void getTematicas() {
        Case caso = [SELECT Id FROM Case WHERE SUbject='Caso de prueba TF7' LIMIT 1];
        Case caso2 = [SELECT Id FROM Case WHERE SUbject='Caso de prueba TF8' LIMIT 1];
        Id tematicaCli = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'MCC Tematica 2'].Id;
        Id tematicaEmp = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            List<OT_Picklist.Item> productosCliente = FRA_Case_Gestion_Controller.getTematicas('Cliente', caso.Id);
            List<OT_Picklist.Item> productosEmpleado = FRA_Case_Gestion_Controller.getTematicas('Empleado',caso2.Id);
            System.assertNotEquals(null, productosCliente);
            System.assertNotEquals(null, productosEmpleado);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getProductos() {
        Id tematicaCli = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'MCC Tematica 2'].Id;
        Id tematicaEmp = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            List<OT_Picklist.Item> productos = FRA_Case_Gestion_Controller.getProductos('Cliente','');
            List<OT_Picklist.Item> productosCliente = FRA_Case_Gestion_Controller.getProductos('Cliente', tematicaCli);
            List<OT_Picklist.Item> productosEmpleado = FRA_Case_Gestion_Controller.getProductos('Empleado',tematicaEmp);
            System.assertNotEquals(null, productosCliente);
            System.assertNotEquals(null, productosEmpleado);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getMotivos() {
        Id prodCli = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Cuenta corriente 2'].Id;
        Id prodEmp = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Cuenta corriente'].Id;
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            List<OT_Picklist.Item> motivos = FRA_Case_Gestion_Controller.getMotivos('','');
            List<OT_Picklist.Item> motivosCliente = FRA_Case_Gestion_Controller.getMotivos('Cliente', prodCli);
            List<OT_Picklist.Item> motivosEmpleado = FRA_Case_Gestion_Controller.getMotivos('Empleado', prodEmp);
            System.assertNotEquals(null, motivosCliente);
            System.assertNotEquals(null, motivosEmpleado);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getCausas() {
        Id motivoCli = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Apertura sin autorización 2'].Id;
        Id motivoEmp = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Apertura sin autorización'].Id;
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            List<OT_Picklist.Item> causas = FRA_Case_Gestion_Controller.getCausas('', '');
            List<OT_Picklist.Item> causasCliente = FRA_Case_Gestion_Controller.getCausas('Cliente', motivoCli);
            List<OT_Picklist.Item> causasEmpleado = FRA_Case_Gestion_Controller.getCausas('Empleado', motivoEmp);
            System.assertNotEquals(null, causasCliente);
            System.assertNotEquals(null, causasEmpleado);
            Test.stopTest();
        }  
    }
    
    @isTest
    public static void getSoluciones() {
        Id causaCli = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Causa 2'].Id;
        Id causaEmp = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Causa 1'].Id;
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            List<OT_Picklist.Item> soluciones = FRA_Case_Gestion_Controller.getSoluciones('', '');
            List<OT_Picklist.Item> solucionesCliente = FRA_Case_Gestion_Controller.getSoluciones('Cliente', causaCli);
            List<OT_Picklist.Item> solucionesEmpleado = FRA_Case_Gestion_Controller.getSoluciones('Empleado', causaEmp);
            System.assertNotEquals(null, solucionesCliente);
            System.assertNotEquals(null, solucionesEmpleado);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void validarGuardarTest() {
        Case caso = [SELECT CC_Canal_Procedencia__c, CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, CC_MCC_Motivo__r.Name
                     FROM Case LIMIT 1];
        CC_MCC__c mccMotivo4 = new CC_MCC__c();
        mccMotivo4.Name = 'Apertura sin autorización 3';
        mccMotivo4.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo4.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccMotivo4.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        mccMotivo4.CC_Codigo_Externo__c = 'MO-000004';
        mccMotivo4.CC_Producto_Servicio__c = [SELECT ID FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Producto_Servicio' LIMIT 1].Id;
        mccMotivo4.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
        insert mccMotivo4;
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            FRA_Case_Gestion_Controller.init(caso.Id);
            Map<String, Object> resultado = FRA_Case_Gestion_Controller.validarGuardar(caso.Id, caso.CC_MCC_Tematica__c, caso.CC_MCC_ProdServ__c, mccMotivo4.Id, true, 'Asesoramiento', 'Test referencia operacion', 'TEST', 'TEST');
            System.assertNotEquals(null, resultado);
            Test.stopTest();
        } 
    }

    @isTest
    public static void metodosSueltos() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        Case caso = [SELECT Id, Subject, Description, CC_Canal_Procedencia__c, CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, CC_MCC_Motivo__r.Name
                     FROM Case LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            FRA_Case_Gestion_Controller.crearActividad(caso.Id, caso.Subject, caso.Description);
            System.assertEquals('Caso de prueba TF7', caso.Subject);
            Test.stopTest();
        }
    }
}