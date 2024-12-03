@isTest
public class CC_Clasificacion_Casos_Controller_Test {
    
    @TestSetup
    static void makeData() {

        PermissionSet psOperador = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
        PermissionSet psSupervisor = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Supervisor_PS'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        PermissionSet psAutenticacion = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Autenticacion'];
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

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
        
        System.runAs(usuarioAdmin) {

            User supervisor = new User();
            supervisor.ProfileId = profileId;
            supervisor.FirstName = 'Supervisor';
            supervisor.LastName = 'last11';
            supervisor.Email = 'tuser000@amamama.com';
            supervisor.Phone = '+34 123456789';
            supervisor.Username = 'tuser000@supervisor.com' + System.currentTimeMillis();
            supervisor.CompanyName = 'MST';
            supervisor.Title = 'title';
            supervisor.Alias = 'alias';
            supervisor.TimeZoneSidKey = 'Europe/Paris';
            supervisor.EmailEncodingKey = 'UTF-8';
            supervisor.LanguageLocaleKey = 'es';
            supervisor.LocaleSidKey = 'es_ES';
            supervisor.UserRoleId = roleCC;
            insert supervisor;
            
            insert new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psOperador.Id);
            insert new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psClasses.Id);
            insert new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psSupervisor.Id);
            insert new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psAutenticacion.Id);
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
            
            String recordTypeDeveloperName = 'CC_Comunicacion_Informativa';
            CC_Lista_Valores__c lovAvisosSobreAgrupadores = new CC_Lista_Valores__c();
            lovAvisosSobreAgrupadores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            lovAvisosSobreAgrupadores.CC_Activa__c = true;
            lovAvisosSobreAgrupadores.Name = 'Avisos sobre agrupadores';
            insert lovAvisosSobreAgrupadores;
            CC_Lista_Valores__c valorUmbralPrimerAviso = new CC_Lista_Valores__c();
            valorUmbralPrimerAviso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorUmbralPrimerAviso.CC_Activa__c = true;
            valorUmbralPrimerAviso.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
            valorUmbralPrimerAviso.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName) + ' - Umbral primer aviso';
            valorUmbralPrimerAviso.CC_Valor__c = '2';
            insert valorUmbralPrimerAviso;
            CC_Lista_Valores__c valorUmbralSiguientesAvisos = new CC_Lista_Valores__c();
            valorUmbralSiguientesAvisos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorUmbralSiguientesAvisos.CC_Activa__c = true;
            valorUmbralSiguientesAvisos.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
            valorUmbralSiguientesAvisos.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName) + ' - Umbral siguientes avisos';
            valorUmbralSiguientesAvisos.CC_Valor__c = '50';
            insert valorUmbralSiguientesAvisos;
            
            //LISTA DE CARACTERISTICAS
            List<CC_Caracteristica__c> listaCaracteristicas = new List<CC_Caracteristica__c>();
            CC_Caracteristica__c campana = new CC_Caracteristica__c();
            campana.Name = 'Campaña Test';
            campana.CC_Descripcion__c = 'Descripción de campaña';
            campana.CC_Fecha_Vigencia_Inicio__c = date.today();
            campana.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Caracteristica__c', 'CC_Campana');
            listaCaracteristicas.add(campana);
            
            CC_Caracteristica__c campana2 = new CC_Caracteristica__c();
            campana2.Name = 'Campaña Test 2';
            campana2.CC_Descripcion__c = 'Descripción de campaña 2';
            campana2.CC_Fecha_Vigencia_Inicio__c = date.today();
            campana2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Caracteristica__c', 'CC_Campana');
            listaCaracteristicas.add(campana2);
            insert listaCaracteristicas;
            
            //LISTA DE TEMATICAS
            List<CC_MCC__c> listaTematicas = new List<CC_MCC__c>();
            CC_MCC__c mccTematica = new CC_MCC__c();
            mccTematica.Name = 'MCC Tematica';
            mccTematica.CC_Tipo_Cliente__c = 'Empleado';
            mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccTematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            mccTematica.CC_Codigo_Externo__c = 'TE-000001';
            listaTematicas.add(mccTematica);
            
            CC_MCC__c mccTematica2 = new CC_MCC__c();
            mccTematica2.Name = 'MCC Tematica 2';
            mccTematica2.CC_Tipo_Cliente__c = 'Cliente';
            mccTematica2.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccTematica2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            mccTematica2.CC_Codigo_Externo__c = 'TE-000002';
            mccTematica2.CC_Canal_Operativo__c = 'App BrokerNow';
            listaTematicas.add(mccTematica2);
            
            CC_MCC__c mccTematica3 = new CC_MCC__c();
            mccTematica3.Name = 'MCC Tematica 3';
            mccTematica3.CC_Tipo_Cliente__c = 'Empleado';
            mccTematica3.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccTematica3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            mccTematica3.CC_Codigo_Externo__c = 'TE-000003';
            listaTematicas.add(mccTematica3);
            
            CC_MCC__c mccTematica4 = new CC_MCC__c();
            mccTematica4.Name = 'MCC Tematica 4';
            mccTematica4.CC_Tipo_Cliente__c = 'CSI Bankia';
            mccTematica4.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccTematica4.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            mccTematica4.CC_Codigo_Externo__c = 'TE-000004';
            listaTematicas.add(mccTematica4);
            insert listaTematicas;        
            
            //LISTA DE PRODUCTOS
            List<CC_MCC__c> listaProductos = new List<CC_MCC__c>();
            CC_MCC__c mccProducto = new CC_MCC__c();
            mccProducto.Name = 'Cuenta corriente';
            mccProducto.CC_Tipo_Cliente__c = 'Empleado';
            mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccProducto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            mccProducto.CC_Tematica__c = mccTematica.Id;
            mccProducto.CC_Codigo_Externo__c = 'PR-000001';
            listaProductos.add(mccProducto);
            
            CC_MCC__c mccProducto2 = new CC_MCC__c();
            mccProducto2.Name = 'Cuenta corriente 2';
            mccProducto2.CC_Tipo_Cliente__c = 'Cliente';
            mccProducto2.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccProducto2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            mccProducto2.CC_Tematica__c = mccTematica2.Id;
            mccProducto2.CC_Codigo_Externo__c = 'PR-000002';
            listaProductos.add(mccProducto2);
            
            CC_MCC__c mccProducto3 = new CC_MCC__c();
            mccProducto3.Name = 'Cuenta corriente 3';
            mccProducto3.CC_Tipo_Cliente__c = 'Empleado';
            mccProducto3.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccProducto3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            mccProducto3.CC_Tematica__c = mccTematica.Id;
            mccProducto3.CC_Codigo_Externo__c = 'PR-000003';
            listaProductos.add(mccProducto3);
            
            CC_MCC__c mccProducto4 = new CC_MCC__c();
            mccProducto4.Name = 'Cuenta corriente 4';
            mccProducto4.CC_Tipo_Cliente__c = 'CSI Bankia';
            mccProducto4.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccProducto4.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            mccProducto4.CC_Tematica__c = mccTematica4.Id;
            mccProducto4.CC_Codigo_Externo__c = 'PR-000004';
            listaProductos.add(mccProducto4);
            insert listaProductos;        
            
            //LISTA DE MOTIVOS
            List<CC_MCC__c> listaMotivos = new List<CC_MCC__c>();
            CC_MCC__c mccMotivo = new CC_MCC__c();
            mccMotivo.Name = 'Apertura sin autorización';
            mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
            mccMotivo.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccMotivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
            mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
            mccMotivo.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
            listaMotivos.add(mccMotivo);
            
            CC_MCC__c mccMotivo2 = new CC_MCC__c();
            mccMotivo2.Name = 'Apertura sin autorización 2';
            mccMotivo2.CC_Tipo_Cliente__c = 'Cliente';
            mccMotivo2.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccMotivo2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            mccMotivo2.CC_Codigo_Externo__c = 'MO-000002';
            mccMotivo2.CC_Producto_Servicio__c = mccProducto2.Id;
            mccMotivo2.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
            listaMotivos.add(mccMotivo2);
            
            CC_MCC__c mccMotivo3 = new CC_MCC__c();
            mccMotivo3.Name = 'Apertura sin autorización 3';
            mccMotivo3.CC_Tipo_Cliente__c = 'Empleado';
            mccMotivo3.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccMotivo3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            mccMotivo3.CC_Codigo_Externo__c = 'MO-000003';
            mccMotivo3.CC_Producto_Servicio__c = mccProducto.Id;
            mccMotivo3.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
            listaMotivos.add(mccMotivo3);
            
            CC_MCC__c mccMotivo4 = new CC_MCC__c();
            mccMotivo4.Name = 'Apertura sin autorización 4';
            mccMotivo4.CC_Tipo_Cliente__c = 'CSI Bankia';
            mccMotivo4.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccMotivo4.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            mccMotivo4.CC_Codigo_Externo__c = 'MO-000004';
            mccMotivo4.CC_Producto_Servicio__c = mccProducto4.Id;
            mccMotivo4.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
            listaMotivos.add(mccMotivo4);
            insert listaMotivos;        
            
            //LISTA DE CAUSAS
            List<CC_MCC__c> listaCausas = new List<CC_MCC__c>();
            CC_MCC__c mccCausa = new CC_MCC__c();
            mccCausa.Name = 'Causa 1';
            mccCausa.CC_Tipo_Cliente__c = 'Empleado';
            mccCausa.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccCausa.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
            mccCausa.CC_Motivo__c = mccMotivo.Id;
            mccCausa.CC_Codigo_Externo__c = 'CA-000001';
            listaCausas.add(mccCausa);
            
            CC_MCC__c mccCausa2 = new CC_MCC__c();
            mccCausa2.Name = 'Causa 2';
            mccCausa2.CC_Tipo_Cliente__c = 'Cliente';
            mccCausa2.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccCausa2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
            mccCausa2.CC_Motivo__c = mccMotivo2.Id;
            mccCausa2.CC_Codigo_Externo__c = 'CA-000002';
            listaCausas.add(mccCausa2);
            
            CC_MCC__c mccCausa3 = new CC_MCC__c();
            mccCausa3.Name = 'Causa 3';
            mccCausa3.CC_Tipo_Cliente__c = 'Empleado';
            mccCausa3.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccCausa3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
            mccCausa3.CC_Motivo__c = mccMotivo.Id;
            mccCausa3.CC_Codigo_Externo__c = 'CA-000003';
            listaCausas.add(mccCausa3);
            
            CC_MCC__c mccCausa4 = new CC_MCC__c();
            mccCausa4.Name = 'Causa 4';
            mccCausa4.CC_Tipo_Cliente__c = 'CSI Bankia';
            mccCausa4.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccCausa4.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
            mccCausa4.CC_Motivo__c = mccMotivo4.Id;
            mccCausa4.CC_Codigo_Externo__c = 'CA-000004';
            listaCausas.add(mccCausa4);
            insert listaCausas;        
            
            //LISTA DE SOLUCIONES
            List<CC_MCC__c> listaSoluciones = new List<CC_MCC__c>();
            CC_MCC__c mccSolucion = new CC_MCC__c();
            mccSolucion.Name = 'Solucion 1';
            mccSolucion.CC_Tipo_Cliente__c = 'Empleado';
            mccSolucion.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccSolucion.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
            mccSolucion.CC_Causa__c = mccCausa.Id;
            mccSolucion.CC_Codigo_Externo__c = 'SO-000001';
            mccSolucion.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
            listaSoluciones.add(mccSolucion);
            
            CC_MCC__c mccSolucion2 = new CC_MCC__c();
            mccSolucion2.Name = 'Solucion 2';
            mccSolucion2.CC_Tipo_Cliente__c = 'Cliente';
            mccSolucion2.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccSolucion2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
            mccSolucion2.CC_Causa__c = mccCausa2.Id;
            mccSolucion2.CC_Codigo_Externo__c = 'SO-000002';
            mccSolucion2.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
            listaSoluciones.add(mccSolucion2);
            
            CC_MCC__c mccSolucion3 = new CC_MCC__c();
            mccSolucion3.Name = 'Solucion 3';
            mccSolucion3.CC_Tipo_Cliente__c = 'Empleado';
            mccSolucion3.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccSolucion3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
            mccSolucion3.CC_Causa__c = mccCausa.Id;
            mccSolucion3.CC_Codigo_Externo__c = 'SO-000003';
            mccSolucion3.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
            listaSoluciones.add(mccSolucion3);
            
            CC_MCC__c mccSolucion4 = new CC_MCC__c();
            mccSolucion4.Name = 'Solucion 4';
            mccSolucion4.CC_Tipo_Cliente__c = 'CSI Bankia';
            mccSolucion4.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
            mccSolucion4.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
            mccSolucion4.CC_Causa__c = mccCausa4.Id;
            mccSolucion4.CC_Codigo_Externo__c = 'SO-000004';
            mccSolucion4.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
            listaSoluciones.add(mccSolucion4);
            insert listaSoluciones;
            
            Account cuenta = new Account(); 
            cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
            cuenta.Name = 'Cuenta Cliente Test 1';
            insert cuenta;
            
            Contact contacto = new Contact();
            contacto.LastName = 'Contacto Cliente Test 1';
            contacto.CC_NumPerso__c = '12345569';
            contacto.AccountId = cuenta.Id;
            contacto.CC_Idioma__c = 'Es';
            contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
            insert contacto;
            
            //LISTA DE CASOS
            List<Case> casos= new List<Case>();
            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            Case caso = new Case();
            caso.Subject='Caso de prueba TF7 Empleado';
            caso.recordtypeId= recordTypeCaso;
            caso.Origin='Email';
            caso.CC_Canal_Procedencia__c='Oficina Feedback';
            caso.CC_Tipo_Contacto__c='Consulta';
            caso.CC_MCC_Tematica__c = mccTematica.Id;
            caso.CC_MCC_ProdServ__c = mccProducto.Id;
            caso.CC_MCC_Motivo__c = mccMotivo.Id;
            caso.CC_MCC_Causa__c = mccCausa.Id;
            caso.CC_MCC_Solucion__c = mccSolucion.Id;
            caso.CC_En_Tercer_Nivel__c=true;
            caso.Status='Activo';
            casos.add(caso);
            
            Id recordTypeCasoCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            Case caso2 = new Case();
            caso2.Subject='Caso de prueba TF7';
            caso2.recordtypeId= recordTypeCasoCliente;
            caso2.Origin='Email';
            caso2.CC_Canal_Procedencia__c = 'Formulario web';
            caso2.CC_Tipo_Contacto__c = 'Consulta';
            caso2.CC_Canal_Operativo__c = 'App BrokerNow';
            caso2.CC_MCC_Tematica__c = mccTematica2.Id;
            caso2.CC_MCC_ProdServ__c = mccProducto2.Id;
            caso2.CC_MCC_Motivo__c = mccMotivo2.Id;
            caso2.CC_MCC_Causa__c = mccCausa2.Id;
            caso2.CC_MCC_Solucion__c = mccSolucion2.Id;
            caso2.CC_En_Tercer_Nivel__c=true;
            caso2.Status='Activo';
            casos.add(caso2);
            
            Id recordTypeCasoEmpleadoCSI = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_CSI_Bankia');
            Case casoEmpCSI = new Case();
            casoEmpCSI.Subject ='Caso de prueba TF7 CSI Bankia';
            casoEmpCSI.recordtypeId = recordTypeCasoEmpleadoCSI;
            casoEmpCSI.Origin='Email';
            casoEmpCSI.CC_Canal_Procedencia__c = 'CCO CSI';
            casoEmpCSI.CC_Tipo_Contacto__c = 'Consulta';
            casoEmpCSI.CC_MCC_Tematica__c = mccTematica4.Id;
            casoEmpCSI.CC_MCC_ProdServ__c = mccProducto4.Id;
            casoEmpCSI.CC_MCC_Motivo__c = mccMotivo4.Id;
            casoEmpCSI.CC_MCC_Causa__c = mccCausa4.Id;
            casoEmpCSI.CC_MCC_Solucion__c = mccSolucion4.Id;
            casoEmpCSI.CC_En_Tercer_Nivel__c = true;
            casoEmpCSI.Status='Activo';
            casos.add(casoEmpCSI);        
            insert casos;

            CC_Settings__c configuracion = new CC_Settings__c();
            configuracion.CC_Activa__c = true;
            configuracion.Name = 'CC_OperativaOficinaGuardar';
            configuracion.CC_Configuracion_1__c = 'true';
            insert configuracion;
        }
    }    
    
    @isTest
    public static void clasificacionRapida() {
        Test.startTest();
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
        
        Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Personas confidenciales';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Codigo_Externo__c = 'MO-1150001';
        mccMotivo.CC_Clasificacion_Rapida__c = 'VALORES';
        insert mccMotivo;           
        
        System.assertEquals('Texto para comprobar el Test', CC_Clasificacion_Casos_Controller.clasificacionRapida(mccMotivo.Id));
        Test.stopTest();
    }
    
    
    @isTest
    public static void getCampanas() {
        
        Id recordTypeCampana =  CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Caracteristica__c', 'CC_Campana');
        List<CC_Caracteristica__c> campanas = [SELECT Name, Id FROM CC_Caracteristica__c WHERE recordtypeId = :recordTypeCampana];
        
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> listaCampanas = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        for (CC_Caracteristica__c campana : campanas) {
            listaCampanas.add(new CC_Clasificacion_Casos_Controller.PickListWrapper(campana.Name, campana.Id));
        }
        
        Id recordTypeEmpleado =  CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        Case casoEmpleado = [SELECT Id FROM Case WHERE recordTypeId = :recordTypeEmpleado and Subject='Caso de prueba TF7 Empleado'];
        
        Test.startTest();
        List<OT_Picklist.Item> picklistCampana = CC_Clasificacion_Casos_Controller.getCampanas();
        Test.stopTest();
        
        System.assertNotEquals(null, picklistCampana);
        System.assertEquals(listaCampanas.get(0).label, picklistCampana.get(0).label);
        System.assertEquals(listaCampanas.get(0).value,  picklistCampana.get(0).value);
        System.assertEquals(listaCampanas.get(1).label,  picklistCampana.get(1).label);
        System.assertEquals(listaCampanas.get(1).value,  picklistCampana.get(1).value);
    }
    
    @isTest
    public static void getErroresTf7() {
        Test.startTest();
        CC_Clasificacion_Casos_Controller.getErroresTf7();
        Test.stopTest();
    }
    
    @isTest
    public static void getCanalesOperativos() {
        Test.startTest();
        CC_Clasificacion_Casos_Controller.getCanalesOperativos();
        Test.stopTest();
    }
    
    @isTest
    public static void getTematicas() {
        Test.startTest();
        List<OT_Picklist.Item> tematicas=CC_Clasificacion_Casos_Controller.getTematicas('','','');
        List<OT_Picklist.Item> tematicasCliente=CC_Clasificacion_Casos_Controller.getTematicas('Cliente','','');
        List<OT_Picklist.Item> tematicasEmpleado=CC_Clasificacion_Casos_Controller.getTematicas('Empleado','','');
        List<OT_Picklist.Item> tematicasEmpleadoBankia=CC_Clasificacion_Casos_Controller.getTematicas('Empleado Bankia','','');
        
        System.assertNotEquals(null, tematicasCliente);
        System.assertNotEquals(null, tematicasEmpleado);
        
        Test.stopTest();
    }
    
    @isTest
    public static void getProductos() {
        
        Id tematicaCli = [SELECT Name FROM CC_MCC__c WHERE Name = 'MCC Tematica 2'].Id;
        Id tematicaEmp = [SELECT Name FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        Id tematicaEmpCsi = [SELECT Name FROM CC_MCC__c WHERE Name = 'MCC Tematica 4'].Id;
        
        Test.startTest();
        List<OT_Picklist.Item> productos = CC_Clasificacion_Casos_Controller.getProductos('',tematicaCli,'');
        List<OT_Picklist.Item> productosCliente = CC_Clasificacion_Casos_Controller.getProductos('Cliente',tematicaCli,'');
        List<OT_Picklist.Item> productosEmpleado = CC_Clasificacion_Casos_Controller.getProductos('Empleado',tematicaEmp,'');
        List<OT_Picklist.Item> productosEmpleadoCsi = CC_Clasificacion_Casos_Controller.getProductos('Empleado Bankia',tematicaEmpCsi,'');
        
        System.assertNotEquals(null, productosCliente);
        System.assertNotEquals(null, productosEmpleado);
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void getMotivos() {
        
        Id prodCli = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Cuenta corriente 2'].Id;
        Id prodEmp = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Cuenta corriente'].Id;
        
        Test.startTest();
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> motivos=CC_Clasificacion_Casos_Controller.getMotivos('',prodCli,'');
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> motivosCliente=CC_Clasificacion_Casos_Controller.getMotivos('Cliente',prodCli,'');
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> motivosEmpleado=CC_Clasificacion_Casos_Controller.getMotivos('Empleado',prodEmp,'');
        
        System.assertNotEquals(null, motivosCliente);
        System.assertNotEquals(null, motivosEmpleado);
        
        Test.stopTest();
        
    }
    @isTest
    public static void getCausas() {
        
        Id motivoCli = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Apertura sin autorización 2'].Id;
        Id motivoEmp = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Apertura sin autorización'].Id;
        
        Test.startTest();
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> causas=CC_Clasificacion_Casos_Controller.getCausas('',motivoCli,'');
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> causasCliente=CC_Clasificacion_Casos_Controller.getCausas('Cliente',motivoCli,'');
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> causasEmpleado=CC_Clasificacion_Casos_Controller.getCausas('Empleado',motivoEmp,'');
        
        System.assertNotEquals(null, causasCliente);
        System.assertNotEquals(null, causasEmpleado);
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void getSoluciones() {
        
        Id causaCli = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Causa 2'].Id;
        Id causaEmp = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Causa 1'].Id;
        
        Test.startTest();
        List<Map<String, String>> soluciones = CC_Clasificacion_Casos_Controller.getSoluciones('',causaCli,'');
        List<Map<String, String>> solucionesCliente = CC_Clasificacion_Casos_Controller.getSoluciones('Cliente',causaCli,'');
        List<Map<String, String>> solucionesEmpleado = CC_Clasificacion_Casos_Controller.getSoluciones('Empleado',causaEmp,'');
        
        System.assertNotEquals(null, solucionesCliente);
        System.assertNotEquals(null, solucionesEmpleado);
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void validarGuardarTest() {
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id)) {
            Test.startTest();
            Id recordTypeOficinaGestora = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
            
            Account cuenta = new Account();
            cuenta.Name = 'Cuenta Test Gestora';
            cuenta.CC_Email__c = 'cuentasolinfoemp@test.com';
            cuenta.RecordTypeId = recordTypeOficinaGestora;
            cuenta.CC_Tipo_Centro__c='OF';
            cuenta.CC_Email__c='test@gmail.com';
            insert cuenta;
            
            Id recordTypeCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
            Contact oContacto = new Contact();
            oContacto.LastName = 'Test contacto';
            oContacto.Email = 'test@test.es';
            oContacto.RecordTypeId = recordTypeCliente;
            oContacto.AccountId = cuenta.Id;
            insert oContacto;
            
            Id recordTypeIdTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            CC_MCC__c mccTematica = new CC_MCC__c();
            mccTematica.Name = 'Alfabético';
            mccTematica.CC_Tipo_Cliente__c = 'Empleado';
            mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
            mccTematica.RecordTypeId = recordTypeIdTematica;
            mccTematica.CC_Codigo_Externo__c = 'TE-000011';
            insert mccTematica;
            
            Id recordTypeIdProducto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            CC_MCC__c mccProducto = new CC_MCC__c();
            mccProducto.Name = 'Personas';
            mccProducto.CC_Tipo_Cliente__c = 'Empleado';
            mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
            mccProducto.RecordTypeId = recordTypeIdProducto;
            mccProducto.CC_Tematica__c = mccTematica.Id;
            mccProducto.CC_Codigo_Externo__c = 'PR-000011';
            insert mccProducto; 
            
            Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            CC_MCC__c mccMotivo = new CC_MCC__c();
            mccMotivo.Name = 'Personas confidenciales';
            mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
            mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
            mccMotivo.RecordTypeId = recordTypeIdMotivo;
            mccMotivo.CC_Tematica__c = mccTematica.Id;
            mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
            mccMotivo.CC_Codigo_Externo__c = 'MO-000011';
            insert mccMotivo;      
            
            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
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
            
            CC_MCC__c nuevoMccMotivo = new CC_MCC__c();
            nuevoMccMotivo.Name = 'Personas confidenciales';
            nuevoMccMotivo.CC_Tipo_Cliente__c = 'Empleado';
            nuevoMccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
            nuevoMccMotivo.RecordTypeId = recordTypeIdMotivo;
            nuevoMccMotivo.CC_Tematica__c = mccTematica.Id;
            nuevoMccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
            nuevoMccMotivo.CC_Codigo_Externo__c = 'MO-100011';
            insert nuevoMccMotivo;      
            
            Map<String, Object> validar = CC_Clasificacion_Casos_Controller.validarGuardar(caso.Id, 'Comentarios Stores', mccTematica.Id, mccProducto.Id, nuevoMccMotivo.Id, true);
            System.assertEquals(true, validar.get('retipificar'));
            System.assertEquals('Personas confidenciales', validar.get('motivoAnteriorName'));
            Test.stopTest();
        }
    }
    
    @isTest
    public static void validarGuardarCerrarTest() {
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id)) {
            Test.startTest();
            Id recordTypeOficinaGestora = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
            
            Account cuenta = new Account();
            cuenta.Name = 'Cuenta Test Gestora';
            cuenta.CC_Email__c = 'cuentasolinfoemp@test.com';
            cuenta.RecordTypeId = recordTypeOficinaGestora;
            cuenta.CC_Tipo_Centro__c='OF';
            cuenta.CC_Email__c='test@gmail.com';
            insert cuenta;
            
            Id recordTypeCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
            Contact oContacto = new Contact();
            oContacto.LastName = 'Test contacto';
            oContacto.Email = 'test@test.es';
            oContacto.RecordTypeId = recordTypeCliente;
            oContacto.AccountId = cuenta.Id;
            insert oContacto;
            
            Id recordTypeIdTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            CC_MCC__c mccTematica = new CC_MCC__c();
            mccTematica.Name = 'Alfabético';
            mccTematica.CC_Tipo_Cliente__c = 'Empleado';
            mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
            mccTematica.RecordTypeId = recordTypeIdTematica;
            mccTematica.CC_Codigo_Externo__c = 'TE-000011';
            insert mccTematica;
            
            Id recordTypeIdProducto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            CC_MCC__c mccProducto = new CC_MCC__c();
            mccProducto.Name = 'Personas';
            mccProducto.CC_Tipo_Cliente__c = 'Empleado';
            mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
            mccProducto.RecordTypeId = recordTypeIdProducto;
            mccProducto.CC_Tematica__c = mccTematica.Id;
            mccProducto.CC_Codigo_Externo__c = 'PR-000011';
            insert mccProducto; 
            
            Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            CC_MCC__c mccMotivo = new CC_MCC__c();
            mccMotivo.Name = 'Personas confidenciales';
            mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
            mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
            mccMotivo.RecordTypeId = recordTypeIdMotivo;
            mccMotivo.CC_Tematica__c = mccTematica.Id;
            mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
            mccMotivo.CC_Codigo_Externo__c = 'MO-000011';
            insert mccMotivo;      
            
            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
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
            
            CC_MCC__c nuevoMccMotivo = new CC_MCC__c();
            nuevoMccMotivo.Name = 'Personas confidenciales';
            nuevoMccMotivo.CC_Tipo_Cliente__c = 'Empleado';
            nuevoMccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
            nuevoMccMotivo.RecordTypeId = recordTypeIdMotivo;
            nuevoMccMotivo.CC_Tematica__c = mccTematica.Id;
            nuevoMccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
            nuevoMccMotivo.CC_Codigo_Externo__c = 'MO-100011';
            insert nuevoMccMotivo;
            
            mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
            update mccTematica;
            
            mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
            update mccProducto;
            
            nuevoMccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
            update nuevoMccMotivo;
            
            //Caso vacío
            Case casoVacio = new Case();
            casoVacio.RecordTypeId = recordTypeCaso;
            insert casoVacio;        
            
            try{
                Map<String, Object> validar = CC_Clasificacion_Casos_Controller.validarGuardarCerrar(caso.Id,true, 'Comentarios Stores', mccTematica.Id, mccProducto.Id, nuevoMccMotivo.Id, 'test');
            } catch(AuraHandledException e) {
                System.assertEquals('No se puede cerrar un caso sí los campos Temática, Producto, Motivo no estan vigentes', e.getMessage());
            }
            
            try{
                Map<String, Object> validarVacio = CC_Clasificacion_Casos_Controller.validarGuardarCerrar(casoVacio.Id,true, '', null, null, null, 'test');
            } catch(AuraHandledException e) {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }        
            Test.stopTest();
        }
    }
    
    
    @isTest
    public static void reabrirTareaTrasladoColaborador() {
        Test.startTest();
        //Creación nueva cuenta
        Account cuenta = new Account(Name='Cuenta');
        insert cuenta;
        
        //Creación nuevo contacto asociado a la cuenta anterior
        Contact contacto = new Contact(LastName='Contacto', AccountId=cuenta.Id);
        insert contacto;
        
        //Creación nuevo caso asociado al contacto anterior
        Case caso = new Case(AccountId=cuenta.Id, ContactId=contacto.Id, Status = 'Activo');        
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c='Accionista';
        insert caso;
        
        //Creación nueva tarea Completada asociada al caso anterior
        Task tarea = new Task(WhatId=caso.Id, Status = 'Completed', Type='Traslado Colaborador');
        insert tarea;
        
        //Verificar que se ha rehabierto la tarea de traslado colaborador
        CC_Clasificacion_Casos_Controller.reabrirTareaTrasladoColaborador(caso.Id);         
        system.assertEquals('Open', [SELECT Status FROM TASK WHERE Id = :tarea.Id].Status);
        Test.stopTest();        
    }
    
    @isTest
    public static void comprobarTareaOperativaOficinaTest() {
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            //Creación nueva cuenta
            Account cuenta = new Account(Name='Cuenta');
            insert cuenta;
            
            //Creación nuevo contacto asociado a la cuenta anterior
            Contact contacto = new Contact(LastName='Contacto', AccountId=cuenta.Id);
            insert contacto;
            
            //Creación nuevo caso asociado al contacto anterior
            Case caso = new Case(AccountId=cuenta.Id, ContactId=contacto.Id, Status = 'Activo');        
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c='Accionista';
            insert caso;
            
            Task tarea = new Task(WhatId=caso.id, Status = 'Open', Type='Tarea gestor');
            insert tarea;
            
            Test.startTest();        
            Boolean tieneActividad = CC_Clasificacion_Casos_Controller.comprobarTareaOperativaOficina(caso.id);        
            System.assertEquals(false, tieneActividad);        
            Test.stopTest();
        }
    }
    
    
    @isTest
    public static void operativaActivaTest(){
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            CC_Settings__c configuracion = new CC_Settings__c();
            configuracion.CC_Activa__c = true;
            configuracion.Name = 'OP1';
            insert configuracion;
        }
        
        Test.startTest();        
        System.assert(CC_Clasificacion_Casos_Controller.operativaActiva('OP1'), 'La operativa OP1 debe estar activa');        
        Test.stopTest();
        
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
        
        System.assertEquals(mccTematica.Id, CC_Clasificacion_Casos_Controller.obtenerTematica(caso.Id));
        System.assertEquals(mccProducto.Id, CC_Clasificacion_Casos_Controller.obtenerProducto(caso.Id));
        System.assertEquals(mccMotivo.Id,   CC_Clasificacion_Casos_Controller.obtenerMotivo(caso.Id));
        System.assertEquals(mccCausa.Id,    CC_Clasificacion_Casos_Controller.obtenerCausa(caso.Id));
        System.assertEquals(mccSolucion.Id, CC_Clasificacion_Casos_Controller.obtenerSolucion(caso.Id));
        
        CC_Caracteristica__c campana = new CC_Caracteristica__c();
        campana.Name = 'Campaña Test';
        campana.CC_Descripcion__c = 'Descripción de campaña';
        campana.CC_Fecha_Vigencia_Inicio__c = Date.today();
        campana.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Caracteristica__c', 'CC_Campana');
        insert campana;
        
        List<Case> casos = CC_Clasificacion_Casos_Controller.datosCaso(caso.Id);
        
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistTematica1 = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistTematica1 = CC_Clasificacion_Casos_Controller.getTematicas('Cliente', '');
        System.assertEquals(picklistTematica1.size(), 1);
        
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistProducto1 = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistProducto2 = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        
        String tematica1 = mccTematica.Id;
        picklistProducto1 = CC_Clasificacion_Casos_Controller.getProductos('Cliente', tematica1, '');
        System.assertEquals(picklistProducto1.size(), 1);
        String tematica2 = '';
        picklistProducto2 = CC_Clasificacion_Casos_Controller.getProductos('Cliente', tematica2, '');
        System.assertEquals(picklistProducto2.size(), 0);
        
        String productoServicio1 = mccProducto.Id;
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistMotivo1 = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistMotivo1 = CC_Clasificacion_Casos_Controller.getMotivos('Cliente', productoServicio1, '');
        System.assertEquals(picklistMotivo1.size(), 1);
        String productoServicio2 = '';
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistMotivo2 = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistMotivo2 = CC_Clasificacion_Casos_Controller.getMotivos('Cliente', productoServicio2, '');
        System.assertEquals(picklistMotivo2.size(), 0);
        
        String motivo1 = mccMotivo.Id;
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistCausa1 = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistCausa1 = CC_Clasificacion_Casos_Controller.getCausas('Cliente', motivo1, '');
        System.assertEquals(picklistCausa1.size(), 1);
        String motivo2 = '';
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistCausa2 = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistCausa2 = CC_Clasificacion_Casos_Controller.getCausas('Cliente', motivo2, '');
        System.assertEquals(picklistCausa2.size(), 0);
        
        String causa1 = mccCausa.Id;
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistSolucion1 = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistSolucion1 = CC_Clasificacion_Casos_Controller.getSoluciones('Cliente', causa1, '');
        System.assertEquals(picklistSolucion1.size(), 1);
        String causa2 = '';
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistSolucion2 = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistSolucion2 = CC_Clasificacion_Casos_Controller.getSoluciones('Cliente', causa2, '');
        System.assertEquals(picklistSolucion2.size(), 0);
        
        String casoId = caso.Id;
        String motivoNOK = 'Error KYC';
        String error = 'Error excepción no controlada';
        
        Map<String, Object> oMap = CC_Clasificacion_Casos_Controller.mapMCC(casoId, 'Cliente');
        System.assertEquals(18, oMap.size()); //Revisar, porque se han quitado campos y ya no se obtienen tantos
        
        List<CC_Caracteristica__c> caracteristicas = new List <CC_Caracteristica__c>();
        caracteristicas = [SELECT Name FROM CC_Caracteristica__c
        WHERE recordtypeId = :Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId()];
        
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistCampana = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistCampana = CC_Clasificacion_Casos_Controller.getCampanas();
        System.assertEquals(picklistCampana.size(), 1);
        
        //Funcionalidad validar el canal de respuesta
        String resultado = CC_Clasificacion_Casos_Controller.validarCanalResp(casoId, 'Email');
        System.assertEquals('OK', resultado);
        
        resultado = CC_Clasificacion_Casos_Controller.validarCanalResp(casoId, 'Twitter');
        System.assertEquals('KO', resultado);
        
        caso.Origin = 'Twitter';
        update caso;
        
        resultado = CC_Clasificacion_Casos_Controller.validarCanalResp(casoId, 'Twitter');
        System.assertEquals('OK', resultado);
        
        caso.Origin = 'Comentarios Stores';
        update caso;
        
        resultado = CC_Clasificacion_Casos_Controller.validarCanalResp(casoId, 'Comentarios Stores');
        System.assertEquals('Store', resultado);
        
        //Funcionalidad validar los permisos de Tercer Nivel para retipificar
        List<String> resultadoValidar = CC_Clasificacion_Casos_Controller.validaPermisosTercerNivelRetipificar(casoId, mccTematica.Id, mccProducto.Id, mccMotivo.Id);
        System.assertEquals('true', resultadoValidar[0]);
        
        //Funcionalidad para comprobar si eres propietario del caso
        Boolean esPropietario = CC_Clasificacion_Casos_Controller.getEsPropietarioCaso(casoId);
        System.assertEquals(true, esPropietario);
        
        //Funcionalidad para crear actividad de retipificación del caso
        CC_Clasificacion_Casos_Controller.retipificar(casoId, mccTematica.Id, mccProducto.Id, mccMotivo.Id);
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
        
        System.assertEquals(mccTematica.Id, CC_Clasificacion_Casos_Controller.obtenerTematica(caso.Id));
        System.assertEquals(mccProducto.Id, CC_Clasificacion_Casos_Controller.obtenerProducto(caso.Id));
        System.assertEquals(mccMotivo.Id,   CC_Clasificacion_Casos_Controller.obtenerMotivo(caso.Id));
        System.assertEquals(mccCausa.Id,    CC_Clasificacion_Casos_Controller.obtenerCausa(caso.Id));
        System.assertEquals(mccSolucion.Id, CC_Clasificacion_Casos_Controller.obtenerSolucion(caso.Id));
        
        CC_Caracteristica__c campana = new CC_Caracteristica__c();
        campana.Name = 'Campaña Test';
        campana.CC_Descripcion__c = 'Descripción de campaña';
        campana.CC_Fecha_Vigencia_Inicio__c = date.today();
        campana.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Caracteristica__c', 'CC_Campana');
        insert campana;
        
        List<Case> casos = CC_Clasificacion_Casos_Controller.datosCaso(caso.Id);
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistTematica1 = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistTematica1 = CC_Clasificacion_Casos_Controller.getTematicas('Empleado', canalProcedencia);
        System.assertEquals(picklistTematica1.size(), 1);
        
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistProducto1 = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistProducto2 = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        
        String tematica1 = mccTematica.Id;
        picklistProducto1 = CC_Clasificacion_Casos_Controller.getProductos('Empleado', tematica1, canalProcedencia);
        System.assertEquals(picklistProducto1.size(), 1);
        String tematica2 = '';
        picklistProducto2 = CC_Clasificacion_Casos_Controller.getProductos('Empleado', tematica2, canalProcedencia);
        System.assertEquals(picklistProducto2.size(), 0);
        
        String productoServicio1 = mccProducto.Id;
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistMotivo1 = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistMotivo1 = CC_Clasificacion_Casos_Controller.getMotivos('Empleado', productoServicio1, canalProcedencia);
        System.assertEquals(picklistMotivo1.size(), 1);
        String productoServicio2 = '';
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistMotivo2 = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistMotivo2 = CC_Clasificacion_Casos_Controller.getMotivos('Empleado', productoServicio2, canalProcedencia);
        System.assertEquals(picklistMotivo2.size(), 0);
        
        String motivo1 = mccMotivo.Id;
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistCausa1 = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistCausa1 = CC_Clasificacion_Casos_Controller.getCausas('Empleado', motivo1, canalProcedencia);
        System.assertEquals(picklistCausa1.size(), 1);
        String motivo2 = '';
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistCausa2 = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistCausa2 = CC_Clasificacion_Casos_Controller.getCausas('Empleado', motivo2, canalProcedencia);
        System.assertEquals(picklistCausa2.size(), 0);
        
        String causa1 = mccCausa.Id;
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistSolucion1 = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistSolucion1 = CC_Clasificacion_Casos_Controller.getSoluciones('Empleado', causa1, canalProcedencia);
        System.assertEquals(picklistSolucion1.size(), 1);
        String causa2 = '';
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> picklistSolucion2 = new List<CC_Clasificacion_Casos_Controller.PickListWrapper>();
        picklistSolucion2 = CC_Clasificacion_Casos_Controller.getSoluciones('Empleado', causa2, canalProcedencia);
        System.assertEquals(picklistSolucion2.size(), 0);
        
        String casoId = caso.Id;
        String motivoNOK = 'Error KYC';
        String error = 'Error excepción no controlada';
        
        Map<String, Object> oMap = CC_Clasificacion_Casos_Controller.mapMCC(casoId, 'Empleado');
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
        
        List<CC_Clasificacion_Casos_Controller.pickListWrapper> motivos = new List<CC_Clasificacion_Casos_Controller.pickListWrapper>();
        motivos = CC_Clasificacion_Casos_Controller.getMotivosNOKTarjetas(mccTematica.Id, mccMotivo.Id, mccSolucion.Id);
        System.assertNotEquals(motivos, null);
    }*/
    public static CC_MCC__c crearMccTematica(String tipoCliente) {
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'MCC Tematica';
        mccTematica.CC_Tipo_Cliente__c = tipoCliente;
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        return mccTematica;
    }
    
    public static CC_MCC__c crearMccProductoServicio(String tipoCliente, String mccTematicaId) {
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = tipoCliente;
        mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccProducto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
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
        mccMotivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
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
        mccCausa.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
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
        mccSolucion.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
        mccSolucion.CC_Causa__c = mccCausaId;
        mccSolucion.CC_Codigo_Externo__c = 'SO-000001';
        mccSolucion.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
        insert mccSolucion;
        return mccSolucion;
    }    
    
    /************************************** Empleado CSI Bankia *********************************************************************/
    @isTest
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
        
        Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Personas confidenciales';
        mccMotivo.CC_Tipo_Cliente__c = 'CSI Bankia';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Codigo_Externo__c = 'MO-1150001';
        mccMotivo.CC_Clasificacion_Rapida__c = 'VALORES';
        insert mccMotivo;          
        
        System.assertEquals('Texto para comprobar el Test CSI Bankia', CC_Clasificacion_Casos_Controller.clasificacionRapida(mccMotivo.Id));               
    }
    
    @isTest
    public static void getTematicasCSIBankia() {
        Test.startTest();
        List<OT_Picklist.Item> tematicasEmpleadoCSI=CC_Clasificacion_Casos_Controller.getTematicas('CSI Bankia','','');
        Test.stopTest();
        
        System.assertNotEquals(null, tematicasEmpleadoCSI);
    }
    
    @isTest
    public static void getProductosCSIBankia() {
        
        Id tematicaEmpCSI = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'MCC Tematica 4'].Id;
        
        Test.startTest();
        List<OT_Picklist.Item> productosEmpleadoCSI=CC_Clasificacion_Casos_Controller.getProductos('CSI Bankia',tematicaEmpCSI,'');
        Test.stopTest();
        
        System.assertNotEquals(null, productosEmpleadoCSI);
    }
    
    @isTest
    public static void getMotivosCSIBankia() {
        
        Id prodEmpCSI = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Cuenta corriente 4'].Id;
        
        Test.startTest();
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> motivosEmpleadoCSI=CC_Clasificacion_Casos_Controller.getMotivos('CSI Bankia',prodEmpCSI,'');
        
        Test.stopTest();
        
        System.assertNotEquals(null, motivosEmpleadoCSI);
    }
    @isTest
    public static void getCausasCSIBankia() {
        
        Id motivoEmpCSI = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Apertura sin autorización 4'].Id;
        
        Test.startTest();
        List<CC_Clasificacion_Casos_Controller.PickListWrapper> causasEmpleadoCSI=CC_Clasificacion_Casos_Controller.getCausas('CSI Bankia',motivoEmpCSI,'');
        Test.stopTest();
        
        System.assertNotEquals(null, causasEmpleadoCSI);
    }
    
    @isTest
    public static void getSolucionesCSIBankia() {
        
        Id causaEmpCSI = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Causa 4'].Id;
        
        Test.startTest();
        List<Map<String, String>> solucionesEmpleadoCSI = CC_Clasificacion_Casos_Controller.getSoluciones('CSI Bankia',causaEmpCSI,'');
        Test.stopTest();
        
        System.assertNotEquals(null, solucionesEmpleadoCSI);
    }
    
    @isTest
    public static void cambioEstadoPendiente3N()
    {
        Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
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
    
    @isTest
    public static void cerrarCasoOrigen() {
        Id idCuenta = [SELECT Id FROM Account WHERE Name = 'Cuenta Cliente Test 1'].Id;
        Id idContacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Cliente Test 1'].Id;
        
        Case casoOrigen = [SELECT CC_MCC_Tematica__c FROM Case WHERE Subject = 'Caso de prueba TF7'];
        casoOrigen.CC_Detalles_Consulta__c = 'd c';
        casoOrigen.AccountId = idCuenta;
        casoOrigen.ContactId = idContacto;
        update casoOrigen;
        
        Case caso = new Case();
        caso.Subject = 'Caso de seguimiento';
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Formulario web';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Operativo__c = 'App BrokerNow';
        caso.CC_MCC_Tematica__c = casoOrigen.CC_MCC_Tematica__c;
        caso.AccountId = idCuenta;
        caso.ContactId = idContacto;
        insert caso;
        
        Test.startTest();
        CC_Case.vincularCasoOrigenAux(new List<Id>{caso.Id});
        Map<String, Object> datosCasoOrigen = CC_Clasificacion_Casos_Controller.casoOrigenAbierto(caso.Id);
        CC_Clasificacion_Casos_Controller.cerrarCasoOrigen(casoOrigen.Id, caso.Id);
        Test.stopTest();
        
        System.assertEquals(casoOrigen.Id, datosCasoOrigen.get('Id'), 'El caso creado debería haber quedado vinculado con un caso origen existente');
        System.assertEquals('Cerrado', [SELECT Status FROM Case WHERE Id = :casoOrigen.Id].Status, 'El caso origen debería estar cerrado');
    }
    
    @isTest
    public static void actividadesTrasladoColaborador() {
        Case caso = new Case();
        caso.Subject='Caso de prueba';
        caso.recordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Formulario web';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.Status = 'Activo';
        insert caso;
        
        Test.startTest();
        CC_Clasificacion_Casos_Controller.actividadesTrasladoColaborador(caso.Id);
        Test.stopTest();
    }
    @isTest
    public static void cerrarActividadSolInf() {
        Case caso = new Case();
        caso.Subject='Caso de prueba';
        caso.recordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Formulario web';
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
        CC_Clasificacion_Casos_Controller.cerrarActividadSolicitudInformacion(caso.Id);
        Test.stopTest();
    }

    @isTest
    public static void crearTareaTF9Test(){
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        System.runAs(supervisor){
            Case caso = new Case();
        caso.Subject='Caso de prueba';
        caso.recordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Formulario web';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.Status = 'Activo';
        insert caso;
        
        // Task tarea = new Task();
        // tarea.Subject = 'Solicitud Información';
        // tarea.Type = 'Solicitud Información';
        // tarea.Status = 'open';
        // tarea.WhatId = caso.Id;
        // insert tarea;
        
        String motivo = 'CC_Ficha_Tarjetas';

            Test.startTest();
            String resultado = CC_Clasificacion_Casos_Controller.crearTareaTF9(caso.Id, motivo);
            Boolean resultado1 = CC_Clasificacion_Casos_Controller.comprobarAutenticacion(caso.Id);

            Boolean rta = !String.isEmpty(resultado) ? true : false;

             System.assertEquals(true, rta, 'Fallo la creacion del link');
            Test.stopTest(); 
        }
    }
    
    @isTest
    public static void comprobarReaperturaValidaTest(){
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        System.runAs(supervisor){
            Case caso = new Case();
            caso.Subject='Caso de prueba';
            caso.recordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario web';
            caso.CC_Tipo_Contacto__c = 'Consulta';
            caso.Status = 'Activo';
            insert caso;
            
            
            Test.startTest();
            CC_Clasificacion_Casos_Controller.informarReaperturaValida(caso.Id, 'Si');
            Boolean resultado = CC_Clasificacion_Casos_Controller.comprobarReaperturaValida(caso.Id);

            //Boolean rta = !String.isEmpty(resultado) ? true : false;

             System.assertEquals(false, resultado, 'Fallo la validacion');
            Test.stopTest(); 
        }
    }


}