@isTest
public class CC_Agrupador_CIC_Asignacion_Casos_Test {

    @TestSetup
    static void makeData() {

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        Id roleDirectorioCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center_sin_acceso_a_Directorio'].Id;
        PermissionSet psOperadorCliente = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
        PermissionSet psAVGestorOp = [SELECT Id FROM PermissionSet WHERE Name = 'AV_GestorOperativa'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        List<User> userList = new List<User>();
        List<PermissionSetAssignment> insertPSAssOperadores = new List<PermissionSetAssignment>();
        List<CC_MCC__c> mccCreado = new List<CC_MCC__c>();
        List<CC_MCC__Share> totalPermisosMCC = new List<CC_MCC__Share>();
        
        User usuarioAdmin = new User();
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = roleCC;        
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';
        insert usuarioAdmin;
        
        User operadorCliente = new User();
        operadorCliente.profileId = profileId;
        operadorCliente.UserRoleId = roleDirectorioCC;
        operadorCliente.AV_ExternalID__c = 'U0124112';
        operadorCliente.FirstName = 'Operador';
        operadorCliente.LastName = 'Operador Cliente';
        operadorCliente.Email = 'tuser000@amamama.com';
        operadorCliente.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        operadorCliente.CompanyName = 'MST';
        operadorCliente.Title = 'title';
        operadorCliente.Alias = 'alias';
        operadorCliente.TimeZoneSidKey = 'Europe/Paris';
        operadorCliente.EmailEncodingKey = 'UTF-8';
        operadorCliente.LanguageLocaleKey = 'es';
        operadorCliente.LocaleSidKey = 'es_ES';
        insert operadorCliente;
        
        PermissionSetAssignment psaOperadorCliente = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psOperadorCliente.Id);
        insertPSAssOperadores.add(psaOperadorCliente);

        PermissionSetAssignment psaOperadorClasses = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psClasses.Id);
        insertPSAssOperadores.add(psaOperadorClasses);

        PermissionSetAssignment psaOperadorAV = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psAVGestorOp.Id);
        insertPSAssOperadores.add(psaOperadorAV);

        insert insertPSAssOperadores;

        System.runAs(usuarioAdmin) {
            Id tematicaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            Id productoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c','CC_Producto_Servicio');
            Id motivoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            Id causaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
            
            CC_MCC__c tematica = new CC_MCC__c(
                Name = 'Tematica Test',
                RecordTypeId = tematicaId,
                CC_Tipo_Cliente__c = 'Cliente',
                CC_Canal_Operativo__c = 'Cajero',
                CC_Codigo_Externo__c = 'TE-000001'
            );
            mccCreado.add(tematica);
            insert tematica;

          CC_MCC__c producto = new CC_MCC__c(
          	Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000001'
          );
          mccCreado.add(producto);
          insert producto;

          CC_MCC__c motivo = new CC_MCC__c(
          	Name = 'Motivo Test',
            RecordTypeId = motivoId,
           	CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000001'
          );
          mccCreado.add(motivo);
          insert motivo;

         CC_MCC__c causa = new CC_MCC__c(
          	Name = 'Causa Test',
            RecordTypeId = causaId,
            CC_Producto_Servicio__c = motivo.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'CA-000001'
            );
         mccCreado.add(causa);
         insert causa;
        
        //Alta de datos para la prueba
        String recordTypeDeveloperName = 'CC_Comunicacion_Informativa_de_Campana';
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
        
        String umbralPrimerAvisoString = [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Avisos sobre agrupadores' AND Name = :CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName) + ' - Umbral primer aviso'].CC_Valor__c;
        Integer umbralPrimerAviso = Integer.valueOf(umbralPrimerAvisoString);
        Id recordTypeIdCampana = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Caracteristica__c', 'CC_Campana');
		CC_Caracteristica__c campana = new CC_Caracteristica__c();
        campana.Name = 'Campana';
        campana.RecordTypeId = recordTypeIdCampana;
        campana.CC_Descripcion__c = 'Descripcion';
        campana.CC_Fecha_vigencia_inicio__c = Datetime.now();
        insert campana;
        
		CC_Caracteristica__c campana2 = new CC_Caracteristica__c();
        campana2.Name = 'Campana 2';
        campana2.RecordTypeId = recordTypeIdCampana;
        campana2.CC_Descripcion__c = 'Descripcion';
        campana2.CC_Fecha_vigencia_inicio__c = Datetime.now();
        insert campana2;
        
        List<Id> idsCasos = new List<Id>();
		List<Case> casosInsert = new List<Case>();
        
        Id recordTypeIdAgrupador = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Comunicacion_Informativa_de_Campana');
        CC_Agrupador__c agrupado = new CC_Agrupador__c();
        agrupado.RecordTypeId = recordTypeIdAgrupador;
        agrupado.CC_Estado__c = 'Activo';
        agrupado.CC_Campana__c = campana.Id;
        agrupado.CC_Titulo__c = campana.Name;
        
        insert agrupado;
            
        for (Integer i = 0; i < umbralPrimerAviso+1; i++) {
            Case caso = new Case();
            caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso.CC_Idioma__c = 'es';
            caso.Origin = 'Chat';
            caso.CC_Canal_Procedencia__c = 'Web';
            caso.CC_Tipo_Contacto__c = 'Consulta';
            caso.Subject = 'Asunto';
            caso.CC_Campana__c = campana.Id;
            caso.Status = 'Cerrado';
            caso.CC_MCC_Tematica__c = tematica.Id;
            caso.CC_MCC_ProdServ__c = producto.Id;
            caso.CC_MCC_Motivo__c = motivo.Id;
            caso.CC_MCC_Causa__c = causa.Id;
            casosInsert.add(caso);
        }
        
        for (Integer i = 0; i < umbralPrimerAviso+2; i++) {
            Case caso2 = new Case();
            caso2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso2.CC_Idioma__c = 'es';
            caso2.Origin = 'Chat';
            caso2.CC_Canal_Procedencia__c = 'Web';
            caso2.CC_Tipo_Contacto__c = 'Consulta';
            caso2.Subject = 'Asunto 2';
            caso2.CC_Campana__c = campana2.Id;
            caso2.Status = 'Cerrado';
            caso2.CC_MCC_Tematica__c = tematica.Id;
            caso2.CC_MCC_ProdServ__c = producto.Id;
            caso2.CC_MCC_Motivo__c = motivo.Id;
            caso2.CC_MCC_Causa__c = causa.Id;
            casosInsert.add(caso2);
        }
        
        insert casosInsert;
        
           
        }
    }

	@isTest
    public static void asociarCasosAComunicacionInformativa() {
        List<Id> idsCasos = new List<Id>();

        for (Case caso : [SELECT Id FROM Case WHERE CreatedDate = TODAY]) {
            idsCasos.add(caso.Id);
        }

        Test.startTest();
            CC_Agrupador_CIC_Asignacion_Casos.asociarCasosAComunicacionInformativa(idsCasos);
        Test.stopTest();

        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
        
            List<Case> casosActualizados = [SELECT CC_Comunicacion_Informativa_Campana__c, CC_Admin__c FROM Case WHERE Id IN :idsCasos];
            for (Case caso : casosActualizados) {
                System.assertEquals(caso.CC_Admin__c, false);
            }
        }
    }
}