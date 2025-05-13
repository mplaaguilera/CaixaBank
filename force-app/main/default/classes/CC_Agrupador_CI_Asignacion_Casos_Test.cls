@isTest
public class CC_Agrupador_CI_Asignacion_Casos_Test {
	
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
        //Alta de datos para la prueba
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
        String umbralPrimerAvisoString = [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Avisos sobre agrupadores' AND Name = :CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName) + ' - Umbral primer aviso'].CC_Valor__c;
        Integer umbralPrimerAviso = Integer.valueOf(umbralPrimerAvisoString);
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
    	mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App Imagin';
        insert mccTematica;
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto; 
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        insert mccMotivo;
        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
		CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Sin causa';
        mccCausa.CC_Tipo_Cliente__c = 'Cliente';
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Desviacion_Media_LV__c = 20;
        insert mccCausa;
        Id rtPrevision = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Prevision__c','CC_PrevisionCaso');
        CC_Prevision__c prevision = new CC_Prevision__c(
            RecordTypeId = rtPrevision,
            CC_MCC__c = mccCausa.Id,
            CC_Activo__c = true,
            CC_00__c = 1,
            CC_01__c = 1,
            CC_02__c = 1,
            CC_03__c = 1,
            CC_04__c = 1,
            CC_05__c = 1,
            CC_06__c = 1,
            CC_07__c = 1,
            CC_08__c = 1,
            CC_09__c = 1,
            CC_10__c = 1,
            CC_11__c = 1,
            CC_12__c = 1,
            CC_13__c = 1,
            CC_14__c = 1,
            CC_15__c = 1,
            CC_16__c = 1,
            CC_17__c = 1,
            CC_18__c = 1,
            CC_19__c = 1,
            CC_20__c = 1,
            CC_21__c = 1,
            CC_22__c = 1, 
            CC_23__c = 1
        );
        insert prevision;
        List<Id> idsCasos = new List<Id>();
        List<Case> casosInsert = new List<Case>();
        //for (Integer i = 0; i < umbralPrimerAviso+1; i++) {
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        caso.CC_Idioma__c = 'es';
        caso.Origin = 'Chat';
        caso.CC_Canal_Procedencia__c = 'Web';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.Subject = 'Asunto';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_MCC_Causa__c = mccCausa.Id;
        caso.Status = 'Cerrado';
        casosInsert.add(caso);
        
        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        caso2.CC_Idioma__c = 'es';
        caso2.Origin = 'Chat';
        caso2.CC_Canal_Procedencia__c = 'Web';
        caso2.CC_Tipo_Contacto__c = 'Consulta';
        caso2.Subject = 'Asunto';
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        caso2.CC_MCC_Causa__c = mccCausa.Id;
        caso2.Status = 'Cerrado';
        casosInsert.add(caso2);
        //}
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
            CC_Agrupador_CI_Asignacion_Casos.asociarCasosAComunicacionInformativa(idsCasos);
        Test.stopTest();

        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
        
            List<Case> casosActualizados = [SELECT CC_Comunicacion_Informativa__c, CC_Admin__c FROM Case WHERE Id IN :idsCasos];
            for (Case caso : casosActualizados) {
                System.assertEquals(caso.CC_Admin__c, false);
            }
        }
    }
    
}