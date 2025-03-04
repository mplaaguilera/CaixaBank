@isTest
public class OS_Case_Operativas_Controller_Test {

    @testSetup
    public static void altaDatosPrueba() {
        User usuarioOperador = OS_Usuarios.usuarioOperador();
        
        //LISTA DE TEMATICAS
        List<CC_MCC__c> listaTematicas = new List<CC_MCC__c>();
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'MCC Tematica';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.OS_Departamento__c = 'UAFE';
        mccTematica.CC_idCognitivo__c = '985792';
        listaTematicas.add(mccTematica);

        CC_MCC__c mccTematica2 = new CC_MCC__c();
        mccTematica2.Name = 'MCC Tematica 2';
        mccTematica2.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccTematica2.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica2.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica2.CC_Codigo_Externo__c = 'TE-000002';
        mccTematica2.OS_Departamento__c = 'UAFE';
        listaTematicas.add(mccTematica2);

        CC_MCC__c mccTematica3 = new CC_MCC__c();
        mccTematica3.Name = 'MCC Tematica 3';
        mccTematica3.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccTematica3.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica3.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica3.CC_Codigo_Externo__c = 'TE-000003';
        mccTematica3.OS_Departamento__c = 'UAFE';
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
        
        
        CC_Grupo_Colaborador__c	grupo = new CC_Grupo_Colaborador__c();
        grupo.RecordTypeId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        grupo.name='Servicio bastanteo';
        grupo.OS_Negocio__c = 'COPS';
        insert grupo;
        
        CC_MCC_Grupo_Colaborador__c grupoColaboradorMCC = new CC_MCC_Grupo_Colaborador__c();
        grupoColaboradorMCC.CC_MCC__c = mccMotivo3.Id;
        grupoColaboradorMCC.CC_Grupo_Colaborador__c = grupo.Id;
        grupoColaboradorMCC.Name = 'Grupo Colaborador MCC';
        insert grupoColaboradorMCC;             
        
        CC_Lista_Valores__c a1 = new CC_Lista_Valores__c();
        a1.Name = 'COPS: Activar Encuesta por canal de procedencia';
        a1.CC_Activa__c = true;
        a1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        insert a1;
        
        CC_Lista_Valores__c a2 = new CC_Lista_Valores__c();
        a2.Name = 'Buzón UAFE';
        a2.CC_Activa__c = true;
        a2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        a2.CC_Lista__c = a1.Id;
        insert a2;

        //CUSTOM SETTING
        OS_Envio_LimeSurvey__C encuesta = new OS_Envio_LimeSurvey__C();
        encuesta.Name = 'OS_URL_Encuesta';
        encuesta.OS_LimeSurvey_Link__c = 'https://opina.caixabank.com/index.php?r=survey/index&';
        insert encuesta;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.CC_Matricula__c = 'U01AXXXX';
        insert contacto;
                
        List<Case> casos= new List<Case>();
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.Subject='Caso de prueba TF7';
        caso.recordtypeId= recordTypeCaso;
        caso.Origin='Email';
        caso.CC_Canal_Procedencia__c = 'Buzón UAFE';
        caso.CC_Tipo_Contacto__c = 'Formación';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_MCC_Causa__c = mccCausa.Id;
        caso.CC_MCC_Solucion__c = mccSolucion.Id;
        caso.CC_En_Tercer_Nivel__c=true;
        caso.Status='Activo';
        caso.CC_Idioma__c = 'es';
        caso.ContactId = contacto.Id;
        caso.OwnerId = usuarioOperador.Id;
        casos.add(caso);

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.Name = 'account temp';
        cuenta.OwnerId = usuarioOperador.Id;
        insert cuenta;
        
        Case caso2 = new Case();
        caso2.Subject = 'Caso de prueba mcc';
        caso2.recordtypeId =  Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();
        caso2.Origin = 'Email';
        caso2.CC_Canal_Procedencia__c = 'Buzón UAFE';
        caso2.CC_Tipo_Contacto__c = 'Formación';
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo3.Id;
        caso2.CC_En_Tercer_Nivel__c = true;
        caso2.ContactId = contacto.Id;
        caso2.AccountId = cuenta.Id;
        caso2.CC_Idioma__c = 'es';
        caso2.Status = 'Activo';
        caso2.OwnerId = usuarioOperador.Id;
        casos.add(caso2);
        insert casos;

        EmailTemplate template1 = new EmailTemplate();
        template1.FolderId = usuarioOperador.Id;
        template1.Name = 'Plantilla de prueba';
        template1.Subject = 'esto es una prueba';
        template1.HtmlValue = '[datos_casos]';
        template1.DeveloperName = 'OS_Plantilla_Prueba';
        template1.TemplateType = 'Text';
        System.runAs (usuarioOperador) {
            insert template1;
        }
    }

    //Test para el método buscarGruposColaboradores
    @isTest
    public static void obtenerGrupos() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        Id grupoColaboradorRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Colaborador');

        List<CC_Grupo_Colaborador__c> grupos = new List<CC_Grupo_Colaborador__c>();

        CC_Grupo_Colaborador__c grupo1 = new CC_Grupo_Colaborador__c();
        grupo1.Name = 'Grupo Test 1';
        grupo1.CC_External__c = 'GC-00001';
        grupo1.RecordTypeId = grupoColaboradorRecordTypeId;
        grupo1.OS_Negocio__c = 'COPS';
        grupos.add(grupo1);

        CC_Grupo_Colaborador__c grupo2 = new CC_Grupo_Colaborador__c();
        grupo2.Name = 'Grupo Test 2';
        grupo2.CC_External__c = 'GC-00002';
        grupo2.RecordTypeId = grupoColaboradorRecordTypeId;
        grupo2.OS_Negocio__c = 'COPS';
        grupos.add(grupo2);

        CC_Grupo_Colaborador__c grupo3 = new CC_Grupo_Colaborador__c();
        grupo3.Name = 'Grupo Test 3';
        grupo3.CC_External__c = 'GC-00003';
        grupo3.RecordTypeId = grupoColaboradorRecordTypeId;
        grupo3.OS_Negocio__c = 'CC';
        grupos.add(grupo3);
        
        insert grupos;

        System.runAs (usuarioOperador) {
            //Comprobamos que la búsqueda nos devuelve los grupos creados
            Test.startTest();
            List<CC_Grupo_Colaborador__c> resultadoBusqueda = OS_Case_Operativas_Controller.buscarGruposColaboradores('Grupo');
            Test.stopTest();

            System.assertEquals(2, resultadoBusqueda.size(), 'Comprobamos haya dos grupos.');

            List<String> nombresEntrada = new List<String>{grupo1.Name, grupo2.Name};
            System.assertEquals(new List<String>{grupo1.Name, grupo2.Name}, new List<String>{resultadoBusqueda[0].Name, resultadoBusqueda[1].Name}, 'Comprobamos los dos grupos.');
        }
    }
    
    //Test para el método destinatariosColaborador
    @isTest
    public static void obenerColaboradores() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

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

        System.runAs (usuarioOperador) {
            Test.startTest();
            //Comprobamos que obtenemos el mapa con el mail y el Para/CC del colaborador
            Map<String, String> idMapContactoDevuelto = OS_Case_Operativas_Controller.destinatariosColaborador(grupoColaborador.Id);
            Test.stopTest();

            System.assert(idMapContactoDevuelto.containsKey(contacto.Email), 'Comprobamos el mapa contenga el mail del contacto.');
            System.assertEquals('Para', idMapContactoDevuelto.get(contacto.Email), 'Comprobamos contenga el Para.');
        }
    }
    
    @isTest
    public static void validarCamposCasoTest() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-00000112';
        mccTematica.OS_Departamento__c = 'UAFE';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-00000121';
        insert mccProducto;
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today().addDays(7);
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-0000012';
        insert mccMotivo;

        List<Case> caseList = new List<Case>();
        caseList.add(new Case(CC_Idioma__c = null));
        caseList.add(new Case(Origin = 'Phone', CC_Detalles_Consulta__c= 'AAAAA', 
        CC_MCC_Tematica__c = mccTematica.Id, CC_MCC_ProdServ__c = mccProducto.Id, CC_MCC_Motivo__c = mccMotivo.Id));
        insert caseList;

        // Todos los campos fallan, excepto el que requiere una comprobación a los MCCs
        List<String> invalidFieldsList = OS_Case_Operativas_Controller.validarCamposCaso(caseList[0].Id, 'botonResponder');
        System.assertEquals(8, invalidFieldsList.size(), 'Validamos las 8 excepciones.');

        System.runAs (usuarioOperador) {
            Test.startTest();
            // Sólo falla que el MCC se encuentra inactivo
            invalidFieldsList = OS_Case_Operativas_Controller.validarCamposCaso(caseList[1].Id, 'botonResponder');
            Test.stopTest();

            System.assertEquals(4, invalidFieldsList.size(), 'Validamos 4 excepciones.');
      
        }
    }
        
    @isTest
    public static void obtenerPlantillas() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        System.runAs (usuarioOperador) {
            Test.startTest();
            List<EmailTemplate> plantillas = OS_Case_Operativas_Controller.buscarPlantillas('C');
            Map<String,Object> adjuntos = OS_Case_Operativas_Controller.getAdjuntosPlantilla(plantillas[0].Id);
            Test.stopTest();

            System.assert(plantillas.size() > 0, 'Validamos que hemos encontrado plantillas.');
        }
    }
	
    //Test para los métodos getPlantillaGrupoList
    @isTest
    public static void obtenerListaPlantillasGrupo() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeIdGrupo = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

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

        System.runAs (usuarioOperador) {
            Test.startTest();
            //Comprobamos que obtenemos la lista de plantillas
            List<OT_Picklist.Item> plantillaListGrupo = OS_Case_Operativas_Controller.getPlantillaGrupoList(grupo.Id, 'Trasladar');
            Test.stopTest();

            System.assertEquals(plantillas.size(), plantillaListGrupo.size(), 'Validamos haya plantillas.');
        }
    }
    
    //Test para el método getPlantillasResponder
    @isTest
    public static void obtenerListaPlantillasResponder() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id tematicaId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();      
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)',
            CC_Codigo_Externo__c = 'TE-003240001',
            OS_Departamento__c = 'UAFE'

        );
        insert tematica;
        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)',
            CC_Codigo_Externo__c = 'PR-000332001'
        );
        insert producto;
        CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo Test',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)',
            CC_Codigo_Externo__c = 'MO-0342500001'
        );
        insert motivo;

        Case caso = new Case(
            CC_MCC_Tematica__c = tematica.Id,
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivo.Id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web'
        );
        insert caso;

        //Comprobamos en el caso de que no haya plantillas asociadas
        OS_Case_Operativas_Controller.getPlantillasResponder(caso.Id, 'CC_Responder_ca_informal');

        //Comprobamos en el caso de que haya alguna plantilla asociada
        EmailTemplate plantilla = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = 'CC_Responder_es_informal' LIMIT 1];
        CC_MCC_Plantilla__c mccPlantilla = new CC_MCC_Plantilla__c(
            CC_MCC__c = tematica.Id,
            CC_MCC_Plantilla_Name__c = plantilla.Name,
            CC_MCC_Plantilla_DeveloperName__c = plantilla.DeveloperName
        );
        insert mccPlantilla;
        //No perteneciente a la carpeta 
        List<OS_Case_Operativas_Controller.PickListWrapper> plantillaDevuelta = OS_Case_Operativas_Controller.getPlantillasResponder(caso.Id, 'CC_Responder_es_informal');
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            //Perteneciente a la carpeta
            OS_Case_Operativas_Controller.getPlantillasResponder(caso.Id, 'CC_Responder_ca_informal');
            Test.stopTest();

		    system.assert(plantillaDevuelta.size() > 0, 'Comprobamos existe la plantilla.');
        }
    }
    
    @isTest
    public static void correoCaso() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Contact contacto = new Contact(
            FirstName = 'Contacto',
            LastName = 'Test',
            CC_Idioma__c = 'es',
            Email = 'contacto@test.com'
        );
        insert contacto;

        Case caso = new Case(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente'),
            ContactId = contacto.Id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Buzón Service Desk',
            CC_Tipo_Contacto__c = 'Asesoramiento'
        );
        insert caso;

        EmailMessage email = new EmailMessage(
            HtmlBody = 'Prueba',
            ParentId = caso.Id,
            Incoming = false,
            ToAddress = 'pruebamail@prueba.com',
            CcAddress = ' pruebaCC@prueba.com'
        );

        insert email;

        caso.OS_Email_Seleccionado__c = email.Id;
        update caso;

        //Comprobamos que se ha recuperado el email
        Contact contactoSelect = [SELECT Email, Name FROM Contact WHERE Email = 'contacto@test.com'];

        System.runAs (usuarioOperador) {
            Test.startTest();
                Map<String, List<String>> correoCaso = OS_Case_Operativas_Controller.correoCaso(String.valueOf(caso.Id));
                System.assertEquals(correoCaso.get('Para')[0], 'pruebamail@prueba.com', 'Validamos el mail del contacto sea el para.');
            Test.stopTest();
        }
    }

    @isTest
    public static void correoCaso2() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Contact contacto = new Contact(
            FirstName = 'Contacto',
            LastName = 'Test',
            CC_Idioma__c = 'es',
            Email = 'contacto2@test.com'
        );
        insert contacto;

        Case caso = new Case(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente'),
            ContactId = contacto.Id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Buzón Service Desk',
            CC_Tipo_Contacto__c = 'Asesoramiento'
        );
        insert caso;

        EmailMessage email = new EmailMessage(
            HtmlBody = 'Prueba2',
            ParentId = caso.Id,
            Incoming = true,
            FromAddress = 'pruebasvarias@prueba.com',
            ToAddress = 'pruebamail2@prueba.com',
            CcAddress = ' pruebaCC2@prueba.com'
        );

        insert email;

        caso.OS_Email_Seleccionado__c = email.Id;
        update caso;

        //Comprobamos que se ha recuperado el email
        Contact contactoSelect = [SELECT Email, Name FROM Contact WHERE Email = 'contacto2@test.com'];

        System.runAs (usuarioOperador) {
            Test.startTest();
                Map<String, List<String>> correoCaso = OS_Case_Operativas_Controller.correoCaso(String.valueOf(caso.Id));
                System.assertEquals(correoCaso.get('Para')[0], 'pruebasvarias@prueba.com', 'Validamos el mail del contacto sea el para.');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void subdirectoriosTest() {  
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        System.runAs (usuarioOperador) {
            Test.startTest();
            List<Folder> carpetas = OS_Case_Operativas_Controller.subdirectorios('CC_Responder');
            System.assertNotEquals(null, carpetas, 'Validamos no haya carpetas de responder.');
            
            carpetas = OS_Case_Operativas_Controller.getCarpetas(null);
            System.assertNotEquals(null, carpetas, 'Validamos no haya carpetas.');

            //Caso de dar carpeta raíz
            OS_Case_Operativas_Controller.getCarpetas('CC_Operativas');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void recuperarCarpetasYCuerpoPlantillaTest() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        System.runAs (usuarioOperador) {
            Test.startTest();
            // CC_Solicitar contiene 3 carpetas y una plantilla
            List<Folder> folderList = OS_Case_Operativas_Controller.subdirectorios('CC_Solicitar');
            List<EmailTemplate> templateList = OS_Case_Operativas_Controller.plantillas('CC_Solicitar_es_formal');
            Test.stopTest();

            System.assertEquals(3, folderList.size(), 'Validamos haya 3 carpetas.');
            System.assert(templateList.size()>0, 'Validamos que tengas template para solicitar.');  
        } 
    }
        
    @isTest
    public static void programarAlerta() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
        User usuarioOperador2 = OS_Usuarios.usuarioOperador();

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Case caso1 = new Case();
        caso1.CC_Idioma__c = 'es';
        caso1.RecordTypeId = recordTypeCaso;
        caso1.Subject = 'Prueba Alerta';
        caso1.Status = 'Pendiente Alerta';
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        caso1.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso1.OS_Alerta_Fecha__c = System.now();
        caso1.OS_Alerta_Nuevo_Propietario__c = usuarioOperador2.Id;
        caso1.OwnerId = usuarioOperador.Id;
        insert caso1;
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Case_Operativas_Controller.programarAlerta(caso1.Id, Datetime.now(), caso1.OwnerId, 'Descripcion');
            Test.stopTest();

            List<Event> evento = [SELECT Id FROM Event WHERE WhatId = :caso1.Id];

            System.assertNotEquals(null, evento, 'Validamos haya evento.');
            System.assertNotEquals(new List<Event>(), [SELECT Id FROM Event WHERE WhatId = :caso1.Id], 'Validamos haya evento.');   
        }            
    }

    @isTest
    public static void desprogramarAlerta() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Case caso1 = new Case();
        caso1.CC_Idioma__c = 'es';
        caso1.RecordTypeId = recordTypeCaso;
        caso1.Subject = 'Prueba Alerta';
        caso1.Status = 'Pendiente Alerta';
        caso1.Origin = 'Email';
        caso1.OwnerId = UserInfo.getUserId();
        caso1.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        caso1.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso1.OS_Alerta_Fecha__c = System.now();
        caso1.OS_Alerta_Nuevo_Propietario__c = UserInfo.getUserId();
        insert caso1;
        
        insert new Event(WhatId = caso1.Id, startDateTime = caso1.OS_Alerta_Fecha__c, RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Event', 'OS_Alerta'),
        Type = 'Alerta programada', OwnerId = UserInfo.getUserId(), Subject = 'Alerta programada', EndDateTime = caso1.OS_Alerta_Fecha__c);
        
        List<Event> evento = [SELECT Id FROM Event WHERE WhatId = :caso1.Id];
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Case_Operativas_Controller.desprogramarAlerta(caso1.Id, caso1.OS_Alerta_Fecha__c);
            Test.stopTest();

            System.assertEquals(new List<Event>(), [SELECT Id FROM Event WHERE WhatId = :caso1.Id], 'Validamos haya evento.'); 
        }          
    }

    @isTest
    public static void plantillaCuerpo() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            String plantilla = OS_Case_Operativas_Controller.plantillaCuerpo('OS_Plantilla_Prueba', true);
            Test.stopTest();
            System.assertEquals('[datos_casos]', plantilla, 'Validamos el html sea el mismo que el template cargado.');
        }
    }
        
    @isTest
    public static void existeCarpeta() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        System.runAs (usuarioOperador) {
            Test.startTest();
            Boolean carpeta = OS_Case_Operativas_Controller.existeCarpeta('OS_Responder');
            Test.stopTest();
            System.assertEquals(true, carpeta, 'Validamos existe carpeta.');
        }
    }

    @isTest
    public static void getGruposMCC() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case caso = [SELECT CaseNumber, OwnerId FROM Case WHERE Subject = 'Caso de prueba mcc' LIMIT 1];
        caso.OwnerId = usuarioOperador.Id;
        update caso;
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            List<OT_Picklist.Item> items = OS_Case_Operativas_Controller.getGruposMCC(caso.Id);
            Test.stopTest();

            System.assertEquals('Servicio bastanteo', items[0].label, 'Validamos el servicio coincide.');
        }
    }
    
    @isTest
    public static void prepararCaso() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case caso = [SELECT CaseNumber, OwnerId FROM Case WHERE Subject = 'Caso de prueba TF7' LIMIT 1];
        caso.OwnerId = usuarioOperador.Id;
        update caso;
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            Case casoNuevo = OS_Case_Operativas_Controller.datosCaso(caso.Id);   
            OS_Case_Operativas_Controller.prepararCaso(caso.Id,'OS_Plantilla_Prueba',true,'trasladar', false,'', '');
            Test.stopTest();
        
            Case newCase = [SELECT CC_MCC_Plantilla__c, CC_Ultima_Operativa_Correo__c, CC_Referencia_Correo_Saliente__c  FROM Case WHERE Id = :caso.Id LIMIT 1];
            System.assertNotEquals(null, casoNuevo, 'Validamos hay caso nuevo.');
            System.assertEquals('OS_Plantilla_Prueba', newCase.CC_MCC_Plantilla__c, 'Validamos el caso nuevo coge la plantilla.');
            System.assertEquals('trasladar', newCase.CC_Ultima_Operativa_Correo__c, 'Validamos el caso nuevo venga de un trasladar.');
            System.assertNotEquals(null, newCase.CC_Referencia_Correo_Saliente__c, 'Validamos sea saliente');
        }
    }

    @isTest
    public static void prepararCasoLimeSurvey() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case caso = [SELECT CaseNumber, OwnerId FROM Case WHERE Subject = 'Caso de prueba mcc' LIMIT 1];

        System.runAs (usuarioOperador) {
            Test.startTest();
            Case casoNuevo = OS_Case_Operativas_Controller.datosCaso(caso.Id);   
            OS_Case_Operativas_Controller.prepararCaso(caso.Id,'OS_Plantilla_Prueba',true,'responderCliente', true,'', '');
            Test.stopTest();

            Case newCase = [SELECT CC_MCC_Plantilla__c, CC_Ultima_Operativa_Correo__c, CC_Referencia_Correo_Saliente__c, CC_URL_Encuesta_3N__c FROM Case WHERE Id = :caso.Id LIMIT 1];
    
            System.assertNotEquals(null, casoNuevo, 'Validamos hay caso nuevo.');
            System.assertEquals('OS_Plantilla_Prueba', newCase.CC_MCC_Plantilla__c, 'Validamos el caso nuevo coge la plantilla.');
            System.assertEquals('Cerrado con encuesta', newCase.CC_Ultima_Operativa_Correo__c, 'Validamos el caso nuevo venga de un Responder que envía la encuesta.');
            System.assertNotEquals(null, newCase.CC_Referencia_Correo_Saliente__c, 'Validamos sea saliente');
            System.assertNotEquals(null, newCase.CC_URL_Encuesta_3N__c, 'Validamos se rellene la URL');
        }
    }
    
    @isTest
    public static void vincularLlamada() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case caso = new Case();
        caso.Origin = 'Email';
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        caso.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.Subject = 'caso prueba llamada';
        caso.OwnerId = usuarioOperador.Id;
        insert caso;

        CC_Llamada__c llamada = new CC_Llamada__c();
        llamada.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'OS_Cliente');
        llamada.CC_Tipo__c = 'Entrante';
        llamada.CC_Fecha_Inicio__c = System.now();
        llamada.OwnerId = usuarioOperador.Id;
        insert llamada;
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Case_Operativas_Controller.vincularLlamada(caso.Id);
            Test.stopTest();

            Task tarea = [SELECT WhatId FROM Task WHERE WhatId = :caso.Id LIMIT 1];

            System.assertEquals(caso.Id, tarea.WhatId, 'Validamos la relación entre la tarea y el caso.');
        }
    }

    @isTest
    public static void cambiarRecordType() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        List<Case> casos = new List<Case>();
        Case casoClientes = new Case();
        casoClientes.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        casoClientes.Origin = 'Email';
        casoClientes.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        casoClientes.CC_Tipo_Contacto__c = 'Asesoramiento';
        casoClientes.OwnerId = usuarioOperador.Id;
        casos.add(casoClientes);

        Case casoEmpleados = new Case();
        casoEmpleados.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Empleado');
        casoEmpleados.Origin = 'Email';
        casoEmpleados.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        casoEmpleados.CC_Tipo_Contacto__c = 'Asesoramiento';
        casoEmpleados.OwnerId = usuarioOperador.Id;
        casos.add(casoEmpleados);
        insert casos;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Case_Operativas_Controller.cambiarRecordType(casoClientes.Id);
            OS_Case_Operativas_Controller.cambiarRecordType(casoEmpleados.Id);
            Test.stopTest();

            String casoClientesNuevoRT = [SELECT RecordType.DeveloperName FROM Case WHERE Id = :casoClientes.Id].RecordType.DeveloperName;
            String casoEmpleadosNuevoRT = [SELECT RecordType.DeveloperName FROM Case WHERE Id = :casoEmpleados.Id].RecordType.DeveloperName;
            
            System.assertEquals('OS_Empleado', casoClientesNuevoRT, 'Validamos el RT del caso sea el de empleado.');
            System.assertEquals('OS_Cliente', casoEmpleadosNuevoRT, 'Validamos el RT del caso sea el de cliente.');
        }
    }
    @isTest
    public static void actualizarCampoCerradoOperativa() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

    	Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.OwnerId = usuarioOperador.Id;
		insert caso;

        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Case_Operativas_Controller.actualizarCampoCerradoOperativa(caso.Id, true);
            Test.stopTest();
        
            System.assertEquals(true, [SELECT OS_Cerrado_Operativa__c FROM Case WHERE Id=:caso.Id].OS_Cerrado_Operativa__c, 'Validamos haya habido un cierre de operativa.');
        }
    }
    
    @isTest
    public static void getEmailsCaso() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

		Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.OS_Negocio__c = 'COPS';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;  
        
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        caso.Subject = 'Caso listview Correos electronicos';
        caso.Origin = 'Email';
		caso.CC_Canal_Procedencia__c = 'Buzón Service Desk'; 
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.Status = 'Activo';
        caso.CC_Idioma__c = 'es';
        caso.CC_Detalles_Consulta__c = 'Detalles consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles solución';
        insert caso;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        String fromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'OS_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

        List<EmailMessage> listaCorreos = new List<EmailMessage>();
        EmailMessage correo1 = new EmailMessage();
        correo1.Subject = 'Prueba de correo 1';
        correo1.status = '3'; // email was sent 
        correo1.CC_Grupo_Colab__c = grupoColab.Name;
        correo1.CC_Procedencia__c = 'Traslado Colaborador';
        correo1.FromAddress = fromAddress;
        correo1.ToAddress = 'prueba@ibm.com';
        correo1.Incoming = false;
        correo1.ParentId = caso.Id;
        correo1.RelatedToId = caso.Id;
        
        List<String> cuerpoCorreo1 = new List<String>();
        cuerpoCorreo1.add('<html>');
        cuerpoCorreo1.add('Cuerpo del correo');
        cuerpoCorreo1.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpoCorreo1.add('</html>');
        correo1.HtmlBody = String.join(cuerpoCorreo1, '<br/>');
        listaCorreos.add(correo1);
        
        EmailMessage correo2 = new EmailMessage();
        correo2.Subject = 'Prueba de correo 2';
        correo2.status = '2'; 
        correo2.CC_Grupo_Colab__c = grupoColab.Name;
        correo2.CC_Procedencia__c = 'Traslado Colaborador';
        correo2.FromAddress = fromAddress;
        correo2.ToAddress = 'prueba@ibm.com';
        correo2.Incoming = true;
        correo2.ParentId = caso.Id;
        correo2.RelatedToId = caso.Id;
        correo2.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        
        List<String> cuerpoCorreo2 = new List<String>();
        cuerpoCorreo2.add('<html>');
        cuerpoCorreo2.add('Cuerpo del correo');
        cuerpoCorreo2.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpoCorreo2.add('</html>');
        correo2.HtmlBody = String.join(cuerpoCorreo2, '<br/>');
        listaCorreos.add(correo2);

        insert listaCorreos;

        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');

        ContentVersion cv = new ContentVersion();
        cv.title = 'test content pdf';
        cv.PathOnClient = 'Test_Pdf.pdf';
        cv.VersionData = beforeblob;
        insert cv;
        
        ContentVersion testContent = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentlink.LinkedEntityId = correo2.Id;
        contentlink.ShareType = 'V';
        contentlink.ContentDocumentId = testcontent.ContentDocumentId;
        insert contentLink;
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            List<OS_Case_Operativas_Controller.CorreoElectronico> correosElectronicos = OS_Case_Operativas_Controller.getEmailsCaso(caso.Id, 'fecha', 'desc');
            List<OS_Case_Operativas_Controller.CorreoElectronico> correosElectronicos2 = OS_Case_Operativas_Controller.getEmailsCaso(caso.Id, 'estado', 'desc');
            List<OS_Case_Operativas_Controller.CorreoElectronico> correosElectronicos3 = OS_Case_Operativas_Controller.getEmailsCaso(caso.Id, 'de', 'desc');
            List<OS_Case_Operativas_Controller.CorreoElectronico> correosElectronicos5 = OS_Case_Operativas_Controller.getEmailsCaso(caso.Id, 'nameUrl', 'desc');
            List<OS_Case_Operativas_Controller.CorreoElectronico> correosElectronicos7 = OS_Case_Operativas_Controller.getEmailsCaso(caso.Id, 'HasAttachment', 'desc');
            Test.stopTest();

            System.assertEquals(2, correosElectronicos.size(), 'Validamos haya dos emails.');
            System.assertEquals('Prueba de correo 2',correosElectronicos5[0].asunto, 'Validamos el asunto del primer email.');
            System.assertEquals('Prueba de correo 1',correosElectronicos5[1].asunto, 'Validamos el asunto del segundo email.');
        }
    }
    
    @isTest
    public static void mergeCops() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        List<Case> casos = new List<Case>();

        Case casoMaster = new Case();
        casoMaster.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();
        casoMaster.Subject = 'CASO INICIAL';
        casoMaster.Status = 'Activo';
        casoMaster.Origin = 'Email';
        casoMaster.CC_Canal_Procedencia__c='Buzón Comercio Exterior';
        casoMaster.CC_Cola_Procedencia__c = 'OS_Buzon_Comercio_Exterior';
        casoMaster.CC_Tipo_Contacto__c = 'Asesoramiento';
        casos.add(casoMaster);
                
        Case casoFusionado = new Case();
        casoFusionado.Subject = 'CORREO ENTRANTE';
        casoFusionado.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        casoFusionado.Status = 'Activo';
        casoFusionado.Origin = 'Email';
        casoFusionado.CC_Canal_Procedencia__c='Buzón Comercio Exterior';
        casoFusionado.CC_Cola_Procedencia__c = 'OS_Buzon_Comercio_Exterior';
        casoFusionado.CC_Tipo_Contacto__c = 'Asesoramiento';
        casos.add(casoFusionado);
        
        Case casoFusionado2 = new Case();
        casoFusionado2.Subject = 'CORREO ENTRANTE';
        casoFusionado2.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        casoFusionado2.Status = 'Activo';
        casoFusionado2.Origin = 'Email';
        casoFusionado2.CC_Canal_Procedencia__c='Buzón Comercio Exterior';
        casoFusionado2.CC_Cola_Procedencia__c = 'OS_Buzon_Comercio_Exterior';
        casoFusionado2.CC_Tipo_Contacto__c = 'Asesoramiento';
        casos.add(casoFusionado2);
        insert casos;
        
        Set<Id> setCasos = new Set<Id>{casoMaster.Id};

        System.runAs ( usuarioOperador ) {
            Test.startTest();
            OS_Case_Operativas_Controller.mergeCase(casoMaster.Id, new List<Id>{casoFusionado.Id, casoFusionado2.Id});
            Test.stopTest();

            System.assertEquals(0,[SELECT Count() FROM Case WHERE Subject = 'CORREO ENTRANTE'], 'Validamos no haya correo entrante.');       
        }
	}
    
    @isTest
    public static void getCaso() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'account temp';
        insert cuenta;
        
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = recordTypeCliente;
        insert contacto;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba Caso';
        caso.Status = 'Activo';
        caso.Origin = 'Phone';
        caso.CC_ContactoRelacionado__c = contacto.Id;
        caso.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso.CC_Canal_Resolucion__c = 'Teléfono COPS atención clientes';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso;

        System.runAs (usuarioOperador) {
            Test.startTest();
            Map<String, Object> retorno = OS_Case_Operativas_Controller.getCaso(caso.Id);
            Test.stopTest();

            System.assertNotEquals(null, retorno, 'Validamos no haya retorno.');
        }
    }
    
    @isTest
    public static void getPlantillas() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        CC_MCC__c mcc = new CC_MCC__c();

		Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'account temp';
        insert cuenta;
        
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = recordTypeCliente;
        insert contacto;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        
        String carpeta = 'Carpeta';
        
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba Caso';
        caso.Status = 'Activo';
        caso.Origin = 'Phone';
        caso.CC_ContactoRelacionado__c = contacto.Id;
        caso.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso.CC_Canal_Resolucion__c = 'Teléfono COPS atención clientes';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso;

        System.runAs (usuarioOperador) {
            Test.startTest();
            List<OT_Picklist.Item> wrapPlantilla = OS_Case_Operativas_Controller.getPlantillas(caso.Id, carpeta);
            Test.stopTest(); 

            System.assertNotEquals(null, wrapPlantilla, 'Validamos no haya plantilla.');
        }
    }
}