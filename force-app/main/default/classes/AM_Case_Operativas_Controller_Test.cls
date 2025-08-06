@isTest
public class AM_Case_Operativas_Controller_Test {
    
    @TestSetup
    static void makeData() {
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'CAM'].Id;
        User usuarioAdmin = new User();        
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = roleCC;
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';	
        insert usuarioAdmin;

        System.runAs ( usuarioAdmin ) {
            //	GRUPO COLABORADOR
            Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        
            CC_Grupo_Colaborador__c	grupo = new CC_Grupo_Colaborador__c();
            grupo.RecordTypeId = recordTypeGrupoColaborador;
            grupo.name='Servicio bastanteo';
            grupo.OS_Negocio__c = 'COPS';
            insert grupo;
            
            
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
            campana.OS_Negocio__c = 'COPS';
            campana.CC_Descripcion__c = 'Descripción de campaña';
            campana.CC_Fecha_Vigencia_Inicio__c = date.today();
            campana.RecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId();
            listaCaracteristicas.add(campana);

            CC_Caracteristica__c campana2 = new CC_Caracteristica__c();
            campana2.Name = 'Campaña Test 2';
            campana2.OS_Negocio__c = 'COPS';
            campana2.CC_Descripcion__c = 'Descripción de campaña 2';
            campana2.CC_Fecha_Vigencia_Inicio__c = date.today();
            campana2.RecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId();
            listaCaracteristicas.add(campana2);
            insert listaCaracteristicas;


            //LISTA DE TEMATICAS
            List<CC_MCC__c> listaTematicas = new List<CC_MCC__c>();
            CC_MCC__c mccTematica = new CC_MCC__c();
            mccTematica.Name = 'MCC Tematica';
            mccTematica.CC_Tipo_Cliente__c = 'Empleado';
            mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccTematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
            mccTematica.CC_Codigo_Externo__c = 'TE-000001';
            listaTematicas.add(mccTematica);

            CC_MCC__c mccTematica2 = new CC_MCC__c();
            mccTematica2.Name = 'MCC Tematica 2';
            mccTematica2.CC_Tipo_Cliente__c = 'Cliente';
            mccTematica2.CC_Canal_Operativo__c = '';
            mccTematica2.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccTematica2.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
            mccTematica2.CC_Codigo_Externo__c = 'TE-000002';
            mccTematica2.CC_Canal_Operativo__c = 'App BrokerNow';
            listaTematicas.add(mccTematica2);

            CC_MCC__c mccTematica3 = new CC_MCC__c();
            mccTematica3.Name = 'MCC Tematica 3';
            mccTematica3.CC_Tipo_Cliente__c = 'Empleado';
            mccTematica3.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccTematica3.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
            mccTematica3.CC_Codigo_Externo__c = 'TE-000003';
            listaTematicas.add(mccTematica3);
            insert listaTematicas;


            //LISTA DE PRODUCTOS
            List<CC_MCC__c> listaProductos = new List<CC_MCC__c>();
            CC_MCC__c mccProducto = new CC_MCC__c();
            mccProducto.Name = 'Cuenta corriente';
            mccProducto.CC_Tipo_Cliente__c = 'Empleado';
            mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccProducto.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
            mccProducto.CC_Tematica__c = mccTematica.Id;
            mccProducto.CC_Codigo_Externo__c = 'PR-000001';
            listaProductos.add(mccProducto);

            CC_MCC__c mccProducto2 = new CC_MCC__c();
            mccProducto2.Name = 'Cuenta corriente 2';
            mccProducto2.CC_Tipo_Cliente__c = 'Cliente';
            mccProducto2.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccProducto2.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
            mccProducto2.CC_Tematica__c = mccTematica2.Id;
            mccProducto2.CC_Codigo_Externo__c = 'PR-000002';
            listaProductos.add(mccProducto2);

            CC_MCC__c mccProducto3 = new CC_MCC__c();
            mccProducto3.Name = 'Cuenta corriente 3';
            mccProducto3.CC_Tipo_Cliente__c = 'Empleado';
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
            mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
            mccMotivo.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccMotivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
            mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
            mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
            mccMotivo.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
            listaMotivos.add(mccMotivo);

            CC_MCC__c mccMotivo2 = new CC_MCC__c();
            mccMotivo2.Name = 'Apertura sin autorización 2';
            mccMotivo2.CC_Tipo_Cliente__c = 'Cliente';
            mccMotivo2.CC_Fecha_Vigencia_Inicio__c = Date.today();
            mccMotivo2.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
            mccMotivo2.CC_Codigo_Externo__c = 'MO-000002';
            mccMotivo2.CC_Producto_Servicio__c = mccProducto2.Id;
            mccMotivo2.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
            listaMotivos.add(mccMotivo2);

            CC_MCC__c mccMotivo3 = new CC_MCC__c();
            mccMotivo3.Name = 'Apertura sin autorización 3';
            mccMotivo3.CC_Tipo_Cliente__c = 'Empleado';
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
            mccCausa.CC_Tipo_Cliente__c = 'Empleado';
            mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccCausa.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
            mccCausa.CC_Motivo__c = mccMotivo.Id;
            mccCausa.CC_Codigo_Externo__c = 'CA-000001';
            listaCausas.add(mccCausa);

            CC_MCC__c mccCausa2 = new CC_MCC__c();
            mccCausa2.Name = 'Causa 2';
            mccCausa2.CC_Tipo_Cliente__c = 'Cliente';
            mccCausa2.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccCausa2.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
            mccCausa2.CC_Motivo__c = mccMotivo2.Id;
            mccCausa2.CC_Codigo_Externo__c = 'CA-000002';
            listaCausas.add(mccCausa2);

            CC_MCC__c mccCausa3 = new CC_MCC__c();
            mccCausa3.Name = 'Causa 3';
            mccCausa3.CC_Tipo_Cliente__c = 'Empleado';
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
            mccSolucion.CC_Tipo_Cliente__c = 'Empleado';
            mccSolucion.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccSolucion.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
            mccSolucion.CC_Causa__c = mccCausa.Id;
            mccSolucion.CC_Codigo_Externo__c = 'SO-000001';
            mccSolucion.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
            listaSoluciones.add(mccSolucion);

            CC_MCC__c mccSolucion2 = new CC_MCC__c();
            mccSolucion2.Name = 'Solucion 2';
            mccSolucion2.CC_Tipo_Cliente__c = 'Cliente';
            mccSolucion2.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccSolucion2.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
            mccSolucion2.CC_Causa__c = mccCausa2.Id;
            mccSolucion2.CC_Codigo_Externo__c = 'SO-000002';
            mccSolucion2.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
            listaSoluciones.add(mccSolucion2);

            CC_MCC__c mccSolucion3 = new CC_MCC__c();
            mccSolucion3.Name = 'Solucion 3';
            mccSolucion3.CC_Tipo_Cliente__c = 'Empleado';
            mccSolucion3.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccSolucion3.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
            mccSolucion3.CC_Causa__c = mccCausa.Id;
            mccSolucion3.CC_Codigo_Externo__c = 'SO-000003';
            mccSolucion3.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
            listaSoluciones.add(mccSolucion3);
            insert listaSoluciones;


            //LISTA DE CASOS
            List<Case> casos= new List<Case>();
            Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.Subject='Caso de prueba TF7';
            caso.recordtypeId= recordTypeCaso;
            caso.Origin='Email';
            caso.CC_Canal_Procedencia__c = 'Buzón Carteras';
            caso.CC_Tipo_Contacto__c = 'Operativa';
            caso.CC_MCC_Tematica__c = mccTematica.Id;
            caso.CC_MCC_ProdServ__c = mccProducto.Id;
            caso.CC_MCC_Motivo__c = mccMotivo.Id;
            caso.CC_MCC_Causa__c = mccCausa.Id;
            caso.CC_MCC_Solucion__c = mccSolucion.Id;
            caso.CC_En_Tercer_Nivel__c=true;
            caso.Status='Activo';
            casos.add(caso);
            
            Id recordTypeCasoCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
            Case caso2 = new Case();
            caso2.Subject = 'Caso de prueba TF7';
            caso2.recordtypeId= recordTypeCasoCliente;
            caso2.Origin = 'Email';
            caso2.CC_Canal_Procedencia__c = 'Buzón Carteras';
            caso2.CC_Canal_Operativo__c = 'App BrokerNow';
            caso2.CC_Tipo_Contacto__c = 'Operativa';
            caso2.CC_MCC_Tematica__c = mccTematica2.Id;
            caso2.CC_MCC_ProdServ__c = mccProducto2.Id;
            caso2.CC_MCC_Motivo__c = mccMotivo2.Id;
            caso2.CC_MCC_Causa__c = mccCausa2.Id;
            caso2.CC_MCC_Solucion__c = mccSolucion2.Id;
            caso2.CC_En_Tercer_Nivel__c = true;
            caso2.Status = 'Activo';
            casos.add(caso2);

            Case caso3 = new Case();
            caso3.Subject = 'Caso de prueba mcc';
            caso3.recordtypeId= recordTypeCasoCliente;
            caso3.Origin = 'Email';
            caso3.CC_Canal_Procedencia__c = 'Buzón Carteras';
            caso3.CC_Canal_Operativo__c = 'App BrokerNow';
            caso3.CC_Tipo_Contacto__c = 'Operativa';
            caso3.CC_MCC_Tematica__c = mccTematica.Id;
            caso3.CC_MCC_ProdServ__c = mccProducto.Id;
            caso3.CC_MCC_Motivo__c = mccMotivo3.Id;
            caso3.CC_En_Tercer_Nivel__c = true;
            caso3.Status = 'Activo';
            casos.add(caso3);
            
            insert casos;
            
            List<Case> casolist =[SELECT Id FROM Case];
            Case newCase = AM_Case_Operativas_Controller.datosCaso(casolist[0].Id);

            System.assertNotEquals(null, newCase);
            
            CC_MCC_Grupo_Colaborador__c grupoColaboradorMCC = new CC_MCC_Grupo_Colaborador__c();
            grupoColaboradorMCC.CC_MCC__c = mccMotivo3.Id;
            grupoColaboradorMCC.CC_Grupo_Colaborador__c = grupo.Id;
            grupoColaboradorMCC.Name = 'Grupo Colaborador MCC';
            insert grupoColaboradorMCC;

            Folder[] carpetaAM = [SELECT Id FROM Folder WHERE DeveloperName LIKE 'AM_%'];
            if(!carpetaAM.isEmpty())EmailTemplate e = new EmailTemplate (developerName = 'CarpetaplantillaCAM', FolderId = carpetaAM[0].Id, TemplateType= 'Text', Name = 'CarpetaplantillaCAM');
        }        
    }
    
    @isTest
    public static void validarCamposCasoTest()
    {
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-00000112';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-00000121';
        insert mccProducto;
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today().addDays(7);
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-0000012';
        insert mccMotivo;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Empleado').getRecordTypeId();
        List<Case> caseList = new List<Case>();
        caseList.add(new Case(recordtypeId = recordTypeCaso, CC_Idioma__c = null));
        caseList.add(new Case(recordtypeId = recordTypeCaso, Origin = 'Email', CC_Detalles_Consulta__c= 'AAAAA', CC_Canal_Procedencia__c = 'Buzón Fondos', CC_Tipo_Contacto__c = 'Consulta',
        CC_MCC_Tematica__c = mccTematica.Id, CC_MCC_ProdServ__c = mccProducto.Id, CC_MCC_Motivo__c = mccMotivo.Id));
        insert caseList;

        // Todos los campos fallan, excepto el que requiere una comprobación a los MCCs
        List<String> invalidFieldsList = AM_Case_Operativas_Controller.validarCamposCaso(caseList[0].Id, 'botonResponder');
        System.assertEquals(8, invalidFieldsList.size());

        // Sólo falla que el MCC se encuentra inactivo
        invalidFieldsList = AM_Case_Operativas_Controller.validarCamposCaso(caseList[1].Id, 'botonResponder');
        System.assertEquals(2, invalidFieldsList.size());
        System.assertEquals('Cuenta y Contacto', invalidFieldsList[0]);
    }
    
    @isTest
    public static void validarCamposCasoOldTest()
    {
        User usuario = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1];    

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-00325320001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-02200001';
        insert mccProducto;
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today().addDays(7);
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-00000221';
        insert mccMotivo;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Empleado').getRecordTypeId();
        List<Case> caseList = new List<Case>();
        caseList.add(new Case(recordtypeId = recordTypeCaso, CC_Idioma__c = null));
        caseList.add(new Case(recordtypeId = recordTypeCaso, Origin = 'Email', CC_Detalles_Consulta__c= 'AAAAA', CC_Canal_Procedencia__c = 'Buzón Fondos', CC_Tipo_Contacto__c = 'Consulta',
        CC_MCC_Tematica__c = mccTematica.Id, CC_MCC_ProdServ__c = mccProducto.Id, CC_MCC_Motivo__c = mccMotivo.Id));
        insert caseList;

        // Todos los campos fallan, excepto el que requiere una comprobación a los MCCs
        List<String> invalidFieldsList = AM_Case_Operativas_Controller.validarCamposCasoOld(caseList[0].Id);
        System.assertEquals(7, invalidFieldsList.size());

        // Sólo falla que el MCC se encuentra inactivo
        invalidFieldsList = AM_Case_Operativas_Controller.validarCamposCasoOld(caseList[1].Id);
        System.assertEquals(1, invalidFieldsList.size());
        System.assertEquals('Clasificación inactiva', invalidFieldsList[0]);
    }
    
    @isTest
    public static void getGruposMCC() {
        User usuario = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1];    

        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de prueba mcc' LIMIT 1];
        
        System.runAs ( usuario) {
            Test.startTest();
            List<OT_Picklist.Item> items = AM_Case_Operativas_Controller.getGruposMCC(caso.Id);
            Test.stopTest();

            System.assertEquals('Servicio bastanteo', items[0].label);
        }
    }
    
    @isTest
    public static void prepararCaso() {
        User usuario = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1];    

       	Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de prueba TF7' LIMIT 1];
        EmailTemplate template1 = new EmailTemplate();
        template1.FolderId = usuario.Id;
        template1.Name = 'Plantilla de prueba';
        template1.Subject = 'esto es una prueba';
        template1.HtmlValue = '[datos_casos]';
        template1.DeveloperName = 'AM_Plantilla_Prueba';
        template1.TemplateType = 'Text';
        System.runAs ( usuario) {
            insert template1;
        
            Test.startTest();
            AM_Case_Operativas_Controller.prepararCaso(caso.Id,'AM_Plantilla_Prueba',true,'trasladar');
            Test.stopTest();
            Case newCase = [SELECT CC_MCC_Plantilla__c, CC_Ultima_Operativa_Correo__c, CC_Referencia_Correo_Saliente__c  FROM Case WHERE Id = :caso.Id LIMIT 1];
            
            System.assertEquals('AM_Plantilla_Prueba', newCase.CC_MCC_Plantilla__c);
            System.assertEquals('trasladar', newCase.CC_Ultima_Operativa_Correo__c);
            System.assertNotEquals(null, newCase.CC_Referencia_Correo_Saliente__c);
        }        
    }
    
    @isTest
    public static void obenerColaboradores() {
        Id colaboradorRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        //Creamos una cuenta y un grupo asociado a ésta, además creamos y asignamos un contacto a dicho grupo
        Account cuenta = new Account(
            Name = 'Cuenta Test',
            CC_Email__c = 'cuenta@test.com'
        );
        insert cuenta;

        Contact contacto = new Contact(
        RecordTypeId = colaboradorRecordTypeId,
        FirstName = 'Contacto',
        LastName = 'Test',
        AccountId = cuenta.Id,
        CC_Idioma__c = 'es',
        Email = 'contacto@test.com'
        );
        insert contacto;

        Id grupoColaboradorRecordTypeId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c(
            Name = 'Grupo colaborador Test',
            CC_External__c = 'GC-00003',
            CC_Cuenta__c = cuenta.Id,
            RecordTypeId = grupoColaboradorRecordTypeId
        );
        insert grupoColaborador;

        CC_Grupo_Colaborador_Contact__c colaborador = new CC_Grupo_Colaborador_Contact__c(
            CC_Grupo_Colaborador__c = grupoColaborador.Id,
            CC_Para_CC__c = 'Para',
            CC_Contacto__c = contacto.Id
        );
        insert colaborador;

        //Comprobamos que obtenemos el mapa con el mail y el Para/CC del colaborador
        Map<String, String> idMapContactoDevuelto = AM_Case_Operativas_Controller.destinatariosColaborador(grupoColaborador.Id);
        System.assert(idMapContactoDevuelto.containsKey(contacto.Email));
        System.assertEquals('Para', idMapContactoDevuelto.get(contacto.Email));
    }
    
    
    
    
    
    
    @isTest
    public static void obtenerPlantillas() {
        User usuario = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1];    

        Folder[] carpetaAM = [SELECT Id FROM Folder WHERE DeveloperName LIKE 'AM_%'];
        EmailTemplate e = new EmailTemplate (developerName = 'CarpetaplantillaCAM', FolderId = usuario.Id, TemplateType= 'Text', Name = 'CarpetaplantillaCAM');
        System.runAs ( usuario) {
            insert e;

            test.startTest();
            List<EmailTemplate> plantillas = AM_Case_Operativas_Controller.buscarPlantillas('C');
            
            Test.stopTest();
            System.assert(plantillas.size() > 0);
        }
    }
	
    //Test para los métodos getPlantillaGrupoList
    @isTest
    public static void obtenerListaPlantillasGrupo() {
        Id recordTypeIdGrupo = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c(
            Name = 'Grupo Test',
            CC_External__c = 'GC-00004',
            RecordTypeId = recordTypeIdGrupo 
            
        );
        insert grupo;
        List<EmailTemplate> plantillas = [SELECT Name, DeveloperName FROM EmailTemplate];
        List<CC_Grupo_Colaborador_Plantilla__c> grupoPlantillas = new List<CC_Grupo_Colaborador_Plantilla__c>();
        for (EmailTemplate plantilla : plantillas) {
            CC_Grupo_Colaborador_Plantilla__c plantillaGrupo = new CC_Grupo_Colaborador_Plantilla__c(
                CC_Grupo_Colaborador__c = grupo.Id,
                CC_Plantilla_Name__c = plantilla.Name,
                CC_Plantilla_DeveloperName__c = plantilla.DeveloperName,
                CC_Operativa__c = 'Trasladar'
            );
            grupoPlantillas.add(plantillaGrupo);
        }
        insert grupoPlantillas;
        //Comprobamos que obtenemos la lista de plantillas
        List<OT_Picklist.Item> plantillaListGrupo = AM_Case_Operativas_Controller.getPlantillaGrupoList(grupo.Id, 'Trasladar');
        System.assertEquals(plantillas.size(), plantillaListGrupo.size());
    }
    
    //Test para el método getPlantillasResponder
    @isTest
    public static void obtenerListaPlantillasResponder() {
        Id tematicaId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Empleado').getRecordTypeId();

        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)',
            CC_Codigo_Externo__c = 'TE-003240001'
        );
        insert tematica;
        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)',
            CC_Codigo_Externo__c = 'PR-000332001'
        );
        insert producto;
        CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo Test',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)',
            CC_Codigo_Externo__c = 'MO-0342500001'
        );
        insert motivo;

        Case caso = new Case(
            recordtypeId= recordTypeCaso,
            CC_MCC_Tematica__c = tematica.Id,
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivo.Id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Buzón Fondos'
        );
        insert caso;

        //Comprobamos en el caso de que no haya plantillas asociadas
        AM_Case_Operativas_Controller.getPlantillasResponder(caso.Id, 'CC_Responder_ca_informal');
        

        //Comprobamos en el caso de que haya alguna plantilla asociada
        EmailTemplate plantilla = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = 'CC_Responder_es_informal' LIMIT 1];
        CC_MCC_Plantilla__c mccPlantilla = new CC_MCC_Plantilla__c(
            CC_MCC__c = tematica.Id,
            CC_MCC_Plantilla_Name__c = plantilla.Name,
            CC_MCC_Plantilla_DeveloperName__c = plantilla.DeveloperName
        );
        insert mccPlantilla;
        //No perteneciente a la carpeta
        AM_Case_Operativas_Controller.getPlantillasResponder(caso.Id, 'CC_Responder_es_informal');
        
        //Perteneciente a la carpeta
        AM_Case_Operativas_Controller.getPlantillasResponder(caso.Id, 'CC_Responder_ca_informal');
    }
    
    @isTest
    public static void correoCaso() {
        Contact contacto = new Contact(
            FirstName = 'Contacto',
            LastName = 'Test',
            CC_Idioma__c = 'es',
            Email = 'contacto@test.com'
        );
        insert contacto;

        Case caso = new Case(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'AM_Cliente'),
            ContactId = contacto.Id,
            Origin = 'Email'
        );
        insert caso;

        //Comprobamos que se ha recuperado el email
        Contact contactoSelect = [SELECT Email, Name FROM Contact WHERE Email = 'contacto@test.com'];
        Map<String, List<String>> correoCaso = AM_Case_Operativas_Controller.correoCaso(String.valueOf(caso.Id));

        System.assertEquals(correoCaso.get('Para')[0], contactoSelect.Email);
    }
    
    @isTest
    public static void subdirectoriosTest() {        
        List<Folder> carpetas = AM_Case_Operativas_Controller.subdirectorios('CC_Responder');
        System.assertNotEquals(null, carpetas);
        
        carpetas = AM_Case_Operativas_Controller.getCarpetas(null);
        System.assertNotEquals(null, carpetas);

        //Caso de dar carpeta raíz
        AM_Case_Operativas_Controller.getCarpetas('CC_Operativas');
    }
    
    @isTest
    public static void recuperarCarpetasYCuerpoPlantillaTest()
    {
        // CC_Solicitar contiene 3 carpetas y una plantilla
        List<Folder> folderList = AM_Case_Operativas_Controller.subdirectorios('CC_Solicitar');
        System.assertEquals(3, folderList.size());

        List<EmailTemplate> templateList = AM_Case_Operativas_Controller.plantillas('CC_Solicitar_es_formal');
        System.assert(templateList.size()>0);   
        
    }
    
    @isTest
    public static void obtenerListaPlantillasResponder1() {
        Id tematicaId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Empleado').getRecordTypeId();

        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)',
            CC_Canal_Operativo__c = 'App BrokerNow',
            CC_Codigo_Externo__c = 'TE-031200001'
        );
        insert tematica;
        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)',
            CC_Codigo_Externo__c = 'PR-003250001'
        );
        insert producto;
        CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo Test',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)',
            CC_Codigo_Externo__c = 'MO-000032101'
        );
        insert motivo;

        Case caso = new Case(
            recordtypeId= recordTypeCaso,
            CC_MCC_Tematica__c = tematica.Id,
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivo.Id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Buzón Fondos'
        );
        insert caso;

        //Comprobamos en el caso de que no haya plantillas asociadas
        List<OT_Picklist.Item> plantillasList = AM_Case_Operativas_Controller.getPlantillas(caso.Id, 'CC_Responder_ca_informal');
        System.assert(plantillasList.size() > 0);

        //Comprobamos en el caso de que haya alguna plantilla asociada
        EmailTemplate plantilla = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = 'CC_Responder_es_informal' LIMIT 1];
        CC_MCC_Plantilla__c mccPlantilla = new CC_MCC_Plantilla__c(
            CC_MCC__c = tematica.Id,
            CC_MCC_Plantilla_Name__c = plantilla.Name,
            CC_MCC_Plantilla_DeveloperName__c = plantilla.DeveloperName
        );
        insert mccPlantilla;
        //No perteneciente a la carpeta
        plantillasList = AM_Case_Operativas_Controller.getPlantillas(caso.Id, 'CC_Responder_es_informal');
        System.assert(plantillasList.size() > 0);
        //Perteneciente a la carpeta
        plantillasList = AM_Case_Operativas_Controller.getPlantillas(caso.Id, 'CC_Responder_ca_informal');
        System.assert(plantillasList.size() > 0);
    }
    
    
    @isTest
    public static void duplicarCaso() {
        User usuario = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1];    

		Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();

        Case caso1 = new Case();
        caso1.CC_Idioma__c = 'es';
        caso1.RecordTypeId = recordTypeCaso;
        caso1.Subject = 'Prueba Duplicar Caso';
        caso1.Status = 'Activo';
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c = 'Buzón Carteras';
        caso1.CC_Canal_Resolucion__c = 'Buzón Carteras';
        caso1.CC_Tipo_Contacto__c = 'Operativa';
        insert caso1;

        List<Task> tareas = new List<Task>();
        for (Integer x = 0; x < 2; x++) {
            Task tarea = new Task();
            tarea.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task');
            tarea.WhatId = caso1.Id;
            tarea.Type = 'Automática';
            tarea.Status = 'Completed';
            tarea.Subject = 'Prueba' + x;
            tarea.Description = 'Esto es una prueba';
            tarea.ActivityDate = System.today();
            tareas.add(tarea);
        }
        insert tareas;

        System.runAs ( usuario) {
            Test.startTest();
            Case casoHijo = AM_Case_Operativas_Controller.duplicarCaso(caso1);
            Test.stopTest();

            //Probar que se ha insertado el caso
            System.assertNotEquals(null, casoHijo.Id);

            //Probar que se ha creado la actividad de caso duplicado
            List<Task> tareasDuplicar = [SELECT Id FROM Task
                                            WHERE WhatId = :casoHijo.Id AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task')];
            System.assert(tareasDuplicar.size() == 3);
        }
    }
    
    @isTest
    public static void cambiarRecordType() {
        User usuario = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1];    

        Case casoClientes = new Case();
        casoClientes.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'AM_Cliente');
        insert casoClientes;

        Case casoEmpleados = new Case();
        casoEmpleados.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'AM_Empleado');
        insert casoEmpleados;

        System.runAs ( usuario) {
            Test.startTest();

            AM_Case_Operativas_Controller.cambiarRecordType(casoClientes.Id);
            AM_Case_Operativas_Controller.cambiarRecordType(casoEmpleados.Id);

            Test.stopTest();

            String casoClientesNuevoRT = [SELECT RecordType.DeveloperName FROM Case WHERE Id = :casoClientes.Id].RecordType.DeveloperName;
            String casoEmpleadosNuevoRT = [SELECT RecordType.DeveloperName FROM Case WHERE Id = :casoEmpleados.Id].RecordType.DeveloperName;

            System.assertEquals('AM_Empleado', casoClientesNuevoRT);
            System.assertEquals('AM_Cliente', casoEmpleadosNuevoRT);
        }
    }
    
    
    
    @isTest
    public static void existeCarpeta() {
        User usuario = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1];    

        System.runAs ( usuario) {
            Test.startTest();
            Boolean carpeta = AM_Case_Operativas_Controller.existeCarpeta('AM_Responder');
            Test.stopTest();
            System.assertEquals(true, carpeta);
        }
    }

    @isTest
    public static void actualizarCampoCerradoOperativa(){
        User usuario = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1];    

        Case caso = new Case();
        caso.OS_Cerrado_Operativa__c = false;
        insert caso;

        System.runAs ( usuario) {
            Test.startTest();
            AM_Case_Operativas_Controller.actualizarCampoCerradoOperativa(caso.Id, true);
            Test.stopTest();
            
            Boolean cerradoOperativa = [SELECT Id, OS_Cerrado_Operativa__c FROM Case WHERE Id = :caso.Id].OS_Cerrado_Operativa__c;

            System.assertEquals(true, cerradoOperativa);
        }
    }

}