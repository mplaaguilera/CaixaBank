@isTest
public class CC_Agrupador_CIM_Asignacion_Casos_Test {

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

        Database.insert(insertPSAssOperadores);

        System.runAs(usuarioAdmin) {
            Datetime myDateNow = Datetime.valueOf(System.now());
            Datetime newDate = myDateNow.addHours(1);
            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            Id tematicaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            Id productoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c','CC_Producto_Servicio');
            Id motivoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            Id causaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
            Id caracteristicaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Caracteristica__c', 'Marca');
            Id agrupadorId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Comunicacion_Informativa_de_Marca');

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

            for(CC_MCC__c record : mccCreado) {
                CC_MCC__Share mccShare = new CC_MCC__Share();
                mccShare.ParentId = record.Id;
                mccShare.UserOrGroupId = operadorCliente.Id;
                mccShare.AccessLevel = 'Edit';
                totalPermisosMCC.add(mccShare);
            }
            insert totalPermisosMCC;

            CC_Caracteristica__c caracteristica = new CC_Caracteristica__c(
            Name = 'BREXIT',
            CC_Descripcion__c = 'Marca para el Brexit',
            RecordTypeId = caracteristicaId,
            CC_Fecha_vigencia_inicio__c = myDateNow,
            CC_Fecha_vigencia_fin__c = newDate,
            OS_Negocio__c = 'CC',
            CC_Casos_requeridos_CIM__c = 0
            );
            insert caracteristica;
            
            List<Case> casos = new List<Case>();
            Case caso = new Case(
                Subject = 'Caso de prueba',
                Status = 'Cerrado',
                CC_MCC_Tematica__c = tematica.Id,
                CC_MCC_ProdServ__c = producto.Id,
                CC_MCC_Motivo__c = motivo.Id,
                CC_MCC_Causa__c = causa.Id,
                recordTypeId = recordTypeCaso
            );
            casos.add(caso);
            Case caso2 = new Case(
                Subject = 'Caso de prueba 2',
                Status = 'Cerrado',
                CC_MCC_Tematica__c = tematica.Id,
                CC_MCC_ProdServ__c = producto.Id,
                CC_MCC_Motivo__c = motivo.Id,
                CC_MCC_Causa__c = causa.Id,
                recordTypeId = recordTypeCaso
            );
            casos.add(caso2);
            insert casos;

            CaseShare caseShare = new CaseShare();
            caseShare.CaseId = caso.Id;
            caseShare.UserOrGroupId = operadorCliente.Id;
            caseShare.CaseAccessLevel = 'Edit';
            insert caseShare;

            List<CC_Marca_Case__c> lstCaseMarca = new List<CC_Marca_Case__c>();
            CC_Marca_Case__c marca = new CC_Marca_Case__c(
                CC_Case__c = caso.Id,
                CC_Marca__c = caracteristica.Id
            );
            lstCaseMarca.add(marca);
            CC_Marca_Case__c marca2 = new CC_Marca_Case__c(
                CC_Case__c = caso2.Id,
                CC_Marca__c = caracteristica.Id
            );
            lstCaseMarca.add(marca2);
            insert lstCaseMarca;
        }
    }

    @isTest
    public static void asociarCasosAComunicacionInformativa() {
        List<Id> idsCasos = new List<Id>();

        for (Case caso : [SELECT Id FROM Case WHERE CreatedDate = TODAY]) {
            idsCasos.add(caso.Id);
        }

        Test.startTest();
            CC_Agrupador_CIM_Asignacion_Casos.asociarCasosAComunicacionInformativa(idsCasos);
        Test.stopTest();

        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
        
            List<Case> casosActualizados = [SELECT CC_Comunicacion_Informativa__c, CC_Admin__c FROM Case WHERE Id IN :idsCasos];
            for (Case caso : casosActualizados) {
                System.assertEquals(caso.CC_Admin__c, false);
            }
        }
    }
}