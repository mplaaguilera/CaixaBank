@isTest
public class OS_Case_Gestion_Controller_Test {
    
    @TestSetup
    static void makeData(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = a.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;
 
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
        campana.RecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId();
        listaCaracteristicas.add(campana);

        CC_Caracteristica__c campana2 = new CC_Caracteristica__c();
		campana2.Name = 'Campaña Test 2';
        campana2.CC_Descripcion__c = 'Descripción de campaña 2';
        campana2.OS_Negocio__c = 'COPS';
        campana2.CC_Fecha_Vigencia_Inicio__c = date.today();
        campana2.RecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId();
        listaCaracteristicas.add(campana2);
        insert listaCaracteristicas;


        //LISTA DE TEMATICAS
        List<CC_MCC__c> listaTematicas = new List<CC_MCC__c>();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'MCC Tematica';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'Oficina';
        mccTematica.OS_Departamento__c = 'UAC';
        listaTematicas.add(mccTematica);

        CC_MCC__c mccTematica2 = new CC_MCC__c();
		mccTematica2.Name = 'MCC Tematica 2';
        mccTematica2.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccTematica2.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica2.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica2.CC_Codigo_Externo__c = 'TE-000002';
        mccTematica2.CC_Canal_Operativo__c = 'Oficina';
        mccTematica2.OS_Departamento__c = 'UAC';
        listaTematicas.add(mccTematica2);

        CC_MCC__c mccTematica3 = new CC_MCC__c();
		mccTematica3.Name = 'MCC Tematica 3';
        mccTematica3.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccTematica3.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica3.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica3.CC_Codigo_Externo__c = 'TE-000003';
        mccTematica3.CC_Canal_Operativo__c = 'Oficina';
        mccTematica3.OS_Departamento__c = 'UAC';
        listaTematicas.add(mccTematica3);
        insert listaTematicas;


        //LISTA DE PRODUCTOS
        List<CC_MCC__c> listaProductos = new List<CC_MCC__c>();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccProducto.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        listaProductos.add(mccProducto);

        CC_MCC__c mccProducto2 = new CC_MCC__c();
        mccProducto2.Name = 'Cuenta corriente 2';
        mccProducto2.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccProducto2.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccProducto2.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto2.CC_Tematica__c = mccTematica2.Id;
        mccProducto2.CC_Codigo_Externo__c = 'PR-000002';
        listaProductos.add(mccProducto2);

        CC_MCC__c mccProducto3 = new CC_MCC__c();
        mccProducto3.Name = 'Cuenta corriente 3';
        mccProducto3.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccProducto3.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccProducto3.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto3.CC_Tematica__c = mccTematica.Id;
        mccProducto3.CC_Codigo_Externo__c = 'PR-000003';
        listaProductos.add(mccProducto3);
        insert listaProductos;


        //LISTA DE MOTIVOS
        List<CC_MCC__c> listaMotivos = new List<CC_MCC__c>();
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccMotivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
        mccMotivo.OwnerId = usuarioOperador.Id;
        mccMotivo.OS_Requiere_Ref_Operacion__c = false;
        listaMotivos.add(mccMotivo);

        CC_MCC__c mccMotivo2 = new CC_MCC__c();
        mccMotivo2.Name = 'Apertura sin autorización 2';
        mccMotivo2.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccMotivo2.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccMotivo2.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        mccMotivo2.CC_Codigo_Externo__c = 'MO-000002';
        mccMotivo2.CC_Producto_Servicio__c = mccProducto2.Id;
        mccMotivo2.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
        listaMotivos.add(mccMotivo2);

        CC_MCC__c mccMotivo3 = new CC_MCC__c();
        mccMotivo3.Name = 'Apertura sin autorización 3';
        mccMotivo3.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccMotivo3.CC_Fecha_Vigencia_Inicio__c = Date.today();
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
        mccCausa.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
        listaCausas.add(mccCausa);

        CC_MCC__c mccCausa2 = new CC_MCC__c();
        mccCausa2.Name = 'Causa 2';
        mccCausa2.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccCausa2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa2.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        mccCausa2.CC_Motivo__c = mccMotivo2.Id;
        mccCausa2.CC_Codigo_Externo__c = 'CA-000002';
        listaCausas.add(mccCausa2);

        CC_MCC__c mccCausa3 = new CC_MCC__c();
        mccCausa3.Name = 'Causa 3';
        mccCausa3.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccCausa3.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa3.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        mccCausa3.CC_Motivo__c = mccMotivo.Id;
        mccCausa3.CC_Codigo_Externo__c = 'CA-000003';
        listaCausas.add(mccCausa3);
        insert listaCausas;


        //LISTA DE SOLUCIONES
        List<CC_MCC__c> listaSoluciones = new List<CC_MCC__c>();
        CC_MCC__c mccSolucion = new CC_MCC__c();
        mccSolucion.Name = 'Solucion 1';
        mccSolucion.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccSolucion.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccSolucion.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        mccSolucion.CC_Causa__c = mccCausa.Id;
        mccSolucion.CC_Codigo_Externo__c = 'SO-000001';
        mccSolucion.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
        listaSoluciones.add(mccSolucion);

        CC_MCC__c mccSolucion2 = new CC_MCC__c();
        mccSolucion2.Name = 'Solucion 2';
        mccSolucion2.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccSolucion2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccSolucion2.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        mccSolucion2.CC_Causa__c = mccCausa2.Id;
        mccSolucion2.CC_Codigo_Externo__c = 'SO-000002';
        mccSolucion2.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
        listaSoluciones.add(mccSolucion2);

        CC_MCC__c mccSolucion3 = new CC_MCC__c();
        mccSolucion3.Name = 'Solucion 3';
        mccSolucion3.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccSolucion3.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccSolucion3.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        mccSolucion3.CC_Causa__c = mccCausa.Id;
        mccSolucion3.CC_Codigo_Externo__c = 'SO-000003';
        mccSolucion3.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
        listaSoluciones.add(mccSolucion3);
        insert listaSoluciones;


        //LISTA DE CASOS
        List<Case> casos= new List<Case>();
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.Subject='Caso de prueba TF7';
        caso.recordtypeId= recordTypeCaso;
        caso.Origin='Email';
        caso.CC_Canal_Procedencia__c = 'Buzón KYC Renewal';
        caso.CC_Canal_Resolucion__c = 'Buzón KYC Renewal';
        caso.CC_Tipo_Contacto__c='Formación';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_MCC_Causa__c = mccCausa.Id;
        caso.CC_MCC_Solucion__c = mccSolucion.Id;
        caso.CC_En_Tercer_Nivel__c=true;
        caso.OwnerId = usuarioOperador.Id;
        caso.Status='Activo';
        casos.add(caso);
        
        Id recordTypeCasoCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Case caso2 = new Case();
        caso2.Subject='Caso de prueba TF8';
        caso2.recordtypeId= recordTypeCasoCliente;
        caso2.Origin='Email';
        caso2.CC_Canal_Procedencia__c='Buzón KYC Renewal';
        caso2.CC_Canal_Resolucion__c = 'Buzón KYC Renewal';
        caso.CC_Tipo_Contacto__c='Formación';
        caso2.CC_MCC_Tematica__c = mccTematica2.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto2.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo2.Id;
        caso2.CC_MCC_Causa__c = mccCausa2.Id;
        caso2.CC_MCC_Solucion__c = mccSolucion2.Id;
        caso2.CC_En_Tercer_Nivel__c=true;
        caso2.Status='Activo';
        casos.add(caso2);

        insert casos;

        CaseShare csNuevo2 = new CaseShare();
        csNuevo2.CaseId = caso2.Id;
        csNuevo2.UserOrGroupId = usuarioOperador.Id;
        csNuevo2.CaseAccessLevel='Edit';
        insert csNuevo2;
    }


    @isTest
    public static void validarGuardarTest() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case caso = [SELECT CC_Canal_Procedencia__c, CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, CC_MCC_Motivo__r.Name
                    FROM Case WHERE Subject = 'Caso de prueba TF7' LIMIT 1];
        
        CC_MCC__c mccMotivo4 = new CC_MCC__c();
        mccMotivo4.Name = 'Apertura sin autorización 3';
        mccMotivo4.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccMotivo4.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccMotivo4.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        mccMotivo4.CC_Codigo_Externo__c = 'MO-000004';
        mccMotivo4.CC_Producto_Servicio__c = [SELECT ID FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Producto_Servicio' LIMIT 1].Id;
        mccMotivo4.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
        mccMotivo4.OS_Requiere_Ref_Operacion__c = false;
        mccMotivo4.OwnerId = usuarioOperador.Id;
        insert mccMotivo4;

        System.runAs (usuarioOperador) {
            Test.startTest();
            Map<String, Object> resultado = OS_Case_Gestion_Controller.validarGuardar(caso.Id, caso.CC_MCC_Tematica__c, caso.CC_MCC_ProdServ__c, caso.CC_MCC_Motivo__c, true, 'Asesoramiento', '', 'TEST', 'TEST');
            OS_Case_Gestion_Controller.validarGuardar(caso.Id, caso.CC_MCC_Tematica__c, caso.CC_MCC_ProdServ__c, mccMotivo4.Id, true, 'Asesoramiento', 'Test referencia operacion', 'TEST', 'TEST');
            Test.stopTest();

            system.assertEquals(false, resultado.get('retipificar'), 'Comprobamos no hay retipifación.');
            system.assertEquals(null, resultado.get('tematicaAnteriorName'), 'Comprobamos no hay cambio de temática.');
            system.assertEquals(null, resultado.get('productoAnteriorName'), 'Comprobamos no hay cambio de producto.');
            system.assertEquals(null, resultado.get('motivoAnteriorName'), 'Comprobamos no hay cambio de motivo.');
        }
    }

    @isTest
    public static void initErroresTF() {        
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        List<CC_Lista_Valores__c> valores =  [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Errores Terminal Financiero'];
        Id recordTypeEmpleado =  Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();
        Case casoEmpleado = [SELECT Id, RecordType.Name, CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, 
                            CC_MCC_Motivo__r.Name, CC_MCC_Causa__c, CC_MCC_Causa__r.Name, CC_MCC_Solucion__c, CC_MCC_Solucion__r.Name, OS_Departamento__c, Origin, 
                            CC_Canal_Procedencia__c  FROM Case WHERE recordTypeId = :recordTypeEmpleado];

        Id recordTypeCliente =  Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Case casoCliente = [SELECT Id, RecordType.Name, CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, 
                            CC_MCC_Motivo__r.Name, CC_MCC_Causa__c, CC_MCC_Causa__r.Name, CC_MCC_Solucion__c, CC_MCC_Solucion__r.Name, OS_Departamento__c, Origin, 
                            CC_Canal_Procedencia__c FROM Case WHERE recordTypeId = :recordTypeCliente];
        
        List<OT_Picklist.Item> listaErrores = new List<OT_Picklist.Item>();
        for (CC_Lista_Valores__c val : valores) {
            listaErrores.add(new OT_Picklist.Item(val.CC_Valor__c, val.CC_Valor__c));
        }

        System.runAs (usuarioOperador) {
            Test.startTest();
            Map<String, Object> resultadoEmpleado = OS_Case_Gestion_Controller.init(casoEmpleado.Id);
            Map<String, Object> resultadoCliente = OS_Case_Gestion_Controller.init(casoCliente.Id);
            Test.stopTest();

            system.assertEquals(casoEmpleado.RecordType.Name, resultadoEmpleado.get('RecordTypeName'), 'Comprobamos el RT.');
            system.assertEquals(casoEmpleado.CC_MCC_Tematica__c, resultadoEmpleado.get('Tematica_Caso'), 'Comprobamos el id de la temática.');
            system.assertEquals(casoEmpleado.CC_MCC_Tematica__r.Name, resultadoEmpleado.get('Tematica_Caso_Name'), 'Comprobamos el nombre de la temática.');
            system.assertEquals(casoEmpleado.CC_MCC_ProdServ__c, resultadoEmpleado.get('Producto_Caso'), 'Comprobamos el id del producto.');
            system.assertEquals(casoEmpleado.CC_MCC_ProdServ__r.Name, resultadoEmpleado.get('Producto_Caso_Name'), 'Comprobamos el nombre del producto.');
            system.assertEquals(casoEmpleado.CC_MCC_Motivo__c, resultadoEmpleado.get('Motivo_Caso'), 'Comprobamos el id del motivo.');
            system.assertEquals(casoEmpleado.CC_MCC_Motivo__r.Name, resultadoEmpleado.get('Motivo_Caso_Name'), 'Comprobamos el nombre del motivo.');
            system.assertEquals(casoEmpleado.CC_MCC_Causa__c, resultadoEmpleado.get('Causa_Caso'), 'Comprobamos el id de la causa.');
            system.assertEquals(casoEmpleado.CC_MCC_Causa__r.Name, resultadoEmpleado.get('Causa_Caso_Name'), 'Comprobamos el nombre de la causa.');
            system.assertEquals(casoEmpleado.CC_MCC_Solucion__c, resultadoEmpleado.get('Solucion_Caso'), 'Comprobamos el id de la solución.');
            system.assertEquals(casoEmpleado.CC_MCC_Solucion__r.Name, resultadoEmpleado.get('Solucion_Caso_Name'), 'Comprobamos el nombre de la solución.');
            system.assertEquals(casoEmpleado.OS_Departamento__c, resultadoEmpleado.get('Departamento'), 'Comprobamos el departamento.');
            system.assertEquals(casoEmpleado.Origin, resultadoEmpleado.get('Canal_Entrada'), 'Comprobamos el canal de entrada.');
            system.assertEquals(casoEmpleado.CC_Canal_Procedencia__c, resultadoEmpleado.get('Canal_Procedencia'), 'Comprobamos el canal de procedencia.');
        }     
    }
    
    
    @isTest
    public static void getTematicas() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        System.runAs (usuarioOperador) {
            Test.startTest();
            List<OT_Picklist.Item> tematicasDepart = OS_Case_Gestion_Controller.getTematicas('','BOS');
            List<OT_Picklist.Item> tematicasClienteDepart = OS_Case_Gestion_Controller.getTematicas('Cliente','BOS');
            List<OT_Picklist.Item> tematicasEmpleadoDepart = OS_Case_Gestion_Controller.getTematicas('Empleado','BOS');
            List<OT_Picklist.Item> tematicas = OS_Case_Gestion_Controller.getTematicas('','');
            List<OT_Picklist.Item> tematicasCliente = OS_Case_Gestion_Controller.getTematicas('Cliente','');
            List<OT_Picklist.Item> tematicasEmpleado = OS_Case_Gestion_Controller.getTematicas('Empleado','');
            System.assertNotEquals(null, tematicasClienteDepart, 'Comprobamos temática departamento/cliente nula.');
            System.assertNotEquals(null, tematicasEmpleadoDepart, 'Comprobamos temática departamento/empleado nula.');
            System.assertNotEquals(null, tematicasCliente, 'Comprobamos temática cliente nula.');
            System.assertNotEquals(null, tematicasEmpleado, 'Comprobamos temática empleado nula.');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getProductos() {        
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id tematicaCli = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'MCC Tematica 2'].Id;
        Id tematicaEmp = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            List<OT_Picklist.Item> productos = OS_Case_Gestion_Controller.getProductos('Cliente','');
            List<OT_Picklist.Item> productosCliente = OS_Case_Gestion_Controller.getProductos('Cliente', tematicaCli);
            List<OT_Picklist.Item> productosEmpleado = OS_Case_Gestion_Controller.getProductos('Empleado',tematicaEmp);
            Test.stopTest();

            System.assertNotEquals(null, productosCliente, 'Comprobamos producto cliente nula.');
            System.assertNotEquals(null, productosEmpleado, 'Comprobamos producto empleado nula.');
        }
    }
    
    @isTest
    public static void getMotivos() {    
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
    
        Id prodCli = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Cuenta corriente 2'].Id;
        Id prodEmp = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Cuenta corriente'].Id;
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            List<OT_Picklist.Item> motivos = OS_Case_Gestion_Controller.getMotivos('','');
            List<OT_Picklist.Item> motivosCliente = OS_Case_Gestion_Controller.getMotivos('Cliente', prodCli);
            List<OT_Picklist.Item> motivosEmpleado = OS_Case_Gestion_Controller.getMotivos('Empleado', prodEmp);
            Test.stopTest();

            System.assertNotEquals(null, motivosCliente, 'Comprobamos motivo cliente nula.');
            System.assertNotEquals(null, motivosEmpleado, 'Comprobamos motivo cliente nula.');
        }
    }
    
    @isTest
    public static void getCausas() {        
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

		Id motivoCli = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Apertura sin autorización 2'].Id;
        Id motivoEmp = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Apertura sin autorización'].Id;
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            List<OT_Picklist.Item> causas = OS_Case_Gestion_Controller.getCausas('', '');
            List<OT_Picklist.Item> causasCliente = OS_Case_Gestion_Controller.getCausas('Cliente', motivoCli);
            List<OT_Picklist.Item> causasEmpleado = OS_Case_Gestion_Controller.getCausas('Empleado', motivoEmp);
            System.assertNotEquals(null, causasCliente, 'Comprobamos causa cliente nula.');
            System.assertNotEquals(null, causasEmpleado, 'Comprobamos causa cliente nula.');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getSoluciones() {    
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
    
		Id causaCli = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Causa 2'].Id;
        Id causaEmp = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Causa 1'].Id;
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            List<OT_Picklist.Item> soluciones = OS_Case_Gestion_Controller.getSoluciones('', '');
            List<OT_Picklist.Item> solucionesCliente = OS_Case_Gestion_Controller.getSoluciones('Cliente', causaCli);
            List<OT_Picklist.Item> solucionesEmpleado = OS_Case_Gestion_Controller.getSoluciones('Empleado', causaEmp);
            System.assertNotEquals(null, solucionesCliente, 'Comprobamos solución cliente nula.');
            System.assertNotEquals(null, solucionesEmpleado, 'Comprobamos solución cliente nula.');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void crearActividad() {        
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

		Case caso = [SELECT CaseNumber, OwnerId FROM Case WHERE Subject = 'Caso de prueba TF7' LIMIT 1];

        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Case_Gestion_Controller.crearActividad(caso.Id, 'Rechazar', 'Prueba rechazar');
            Test.stopTest();
            
            System.assertEquals(1, [SELECT COUNT() FROM Task WHERE Type = 'Rechazar' AND Subject = 'Rechazar' AND WhatId = :caso.Id], 'Comprobamos que existe una tarea.');  
        }          
    }
    
        
    @isTest
    public static void crearActividadRetipificacion() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case caso = [SELECT Id, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c FROM Case WHERE Subject = 'Caso de prueba TF7' LIMIT 1];

        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Case_Gestion_Controller.crearActividadRetipificacion(caso.Id, 'TEMATICA', 'PRODUCTE', 'MOTIVO');
            Test.stopTest();
            
            System.assertNotEquals(0, [SELECT Id FROM Task where WhatId = :caso.Id].size(), 'Comprobamos que existe tarea.');
        }
    }
    
    @isTest
    public static void reabrirTareaTrasladoColaborador() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de prueba TF7' LIMIT 1];
		
        Task tarea = new Task();
        tarea.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Task').getRecordTypeId();
        tarea.Type = 'Traslado Colaborador';
        tarea.Status = 'Completed';
        tarea.whatId = caso.Id;
        insert tarea;
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Case_Gestion_Controller.reabrirTareaTrasladoColaborador(caso.Id);
            Test.stopTest();
            
            System.assertEquals('Open', [SELECT Id, Status FROM Task where Type = 'Traslado Colaborador' AND WhatId = :caso.Id LIMIT 1].Status, 'Comprobamos que existe una tarea abierta.');
        }
    }
    
	@isTest
    public static void envioCorreoTrasladoAutomatico() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.Name = 'Apertura sin autorización 3';
        motivo.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        motivo.CC_Fecha_Vigencia_Inicio__c = Date.today();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CBK_Traslado_Remitido__c = 'Remitido';
        motivo.OS_Requiere_Ref_Operacion__c = false;
        motivo.OwnerId = usuarioOperador.Id;
        insert motivo;
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            String motivoTrasladoRemitido = OS_Case_Gestion_Controller.envioCorreoTrasladoAutomatico(motivo.Id);
            Test.stopTest();
            
            System.assertEquals('Remitido', motivoTrasladoRemitido, 'Comprobamos el motivo es remitido.');
        }
    }

    @isTest
    public static void accionesCambioCanalProcedencia() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de prueba TF7' LIMIT 1];

        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Case_Gestion_Controller.accionesCambioCanalProcedencia(caso.Id,'Buzón KYC Renewal');
            Test.stopTest();

            Case casoActualizado = [SELECT Id, CC_Canal_Procedencia__c, OS_Canal_Procedencia_Anterior__c FROM Case WHERE Subject = 'Caso de prueba TF7' LIMIT 1];
            Task tareaActualizado = [SELECT Id, WhatId FROM Task WHERE WhatId = :caso.Id LIMIT 1];
            
            System.assertEquals('Buzón KYC Renewal', casoActualizado.OS_Canal_Procedencia_Anterior__c, 'Comprobamos que el canal de procedencia anterior ha sido actualizado.');
            System.assertNotEquals(null, casoActualizado.CC_Canal_Procedencia__c, 'Comprobamos que el canal de procedencia nuevo no está vacío.');
            System.assertEquals(caso.Id, tareaActualizado.WhatId, 'Comprobamos que se ha creado una tarea del cambio de procedencia.');
        }
    }

}