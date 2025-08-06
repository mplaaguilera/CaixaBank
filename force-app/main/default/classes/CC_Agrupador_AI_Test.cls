@IsTest
public class CC_Agrupador_AI_Test {
    
    @TestSetup
    static void makeData() {
        // Primero creamos los objetos de configuración (setup objects)
        User admin = CC_TestDataFactory.insertUserAdmin();
        
        System.runAs(admin) {
            String recordTypeDeveloperName = 'CC_Comunicacion_Informativa_de_Campana';
            CC_Lista_Valores__c lovAvisosSobreAgrupadores = new CC_Lista_Valores__c();
            lovAvisosSobreAgrupadores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            lovAvisosSobreAgrupadores.CC_Activa__c = true;
            lovAvisosSobreAgrupadores.Name = 'Avisos sobre agrupadores';
            lovAvisosSobreAgrupadores.CC_Valor__c = '1';
            insert lovAvisosSobreAgrupadores;

            CC_Lista_Valores__c valorUmbralPrimerAviso = new CC_Lista_Valores__c();
            valorUmbralPrimerAviso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorUmbralPrimerAviso.CC_Activa__c = true;
            valorUmbralPrimerAviso.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
            valorUmbralPrimerAviso.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName) + ' - Umbral primer aviso';
            valorUmbralPrimerAviso.CC_Valor__c = '2';
            insert valorUmbralPrimerAviso;

            CC_Lista_Valores__c valorUmbralSegundoAviso = new CC_Lista_Valores__c();
            valorUmbralSegundoAviso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorUmbralSegundoAviso.CC_Activa__c = true;
            valorUmbralSegundoAviso.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
            valorUmbralSegundoAviso.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName) + ' - Umbral siguientes avisos';
            valorUmbralSegundoAviso.CC_Valor__c = '3';
            insert valorUmbralSegundoAviso;

            // Ahora creamos los objetos no-configuración (non-setup objects)
            CC_Grupo_Colaborador__c oGrupoCI = new CC_Grupo_Colaborador__c();
            oGrupoCI.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
            oGrupoCI.Name = 'GrupoC';
            oGrupoCI.CC_External__c = 'CI-00001';
            insert oGrupoCI;

            String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
            CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
            oGrupo.RecordTypeId = sRecordType3;
            oGrupo.Name = 'Grupo1';
            oGrupo.CC_External__c = 'GM-00004';
            insert oGrupo;
            
            CC_Grupo_Colaborador_Contact__c oGrupoUser = new CC_Grupo_Colaborador_Contact__c();
            oGrupoUser.CC_Usuario__c = UserInfo.getUserId();
            oGrupoUser.CC_Grupo_Colaborador__c = oGrupo.Id;
            insert oGrupoUser;
            
            CC_Caracteristica__c caracteristica = new CC_Caracteristica__c();
            caracteristica.RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId();
            caracteristica.Name = 'Campa Prueba';
            caracteristica.CC_Descripcion__c = 'Decripcion Prueba';

            insert caracteristica;

            CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
            oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
            oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
            oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
            oClasif.CC_Activa__c = true;
            oClasif.CC_Propietario__c = 'TEST';
            insert oClasif;

            Contact oContacto = new Contact();
            oContacto.LastName = 'Test contacto';
            oContacto.Email = 'test@test.es';
            insert oContacto;

            Case oCaso = new Case();
            oCaso.Subject = 'Test Incidencia';
            oCaso.Origin = 'Email';
            oCaso.ContactId = oContacto.Id;
            oCaso.CC_NotIncidencia__c = '1';
            oCaso.CC_MailTelfNotif__c = 'test@test.es';
            oCaso.CC_CanalNotifCli__c = 'Email';
            oCaso.CC_Idioma__c = 'es';
            oCaso.CC_Campana__c = caracteristica.Id;
            insert oCaso;

            CC_MCC__c tematica = new CC_MCC__c();
            tematica.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
            tematica.Name = 'Tematica Prueba';
            tematica.CC_Tipo_Cliente__c = 'Cliente';
            tematica.CC_Codigo_Externo__c = 'TE00-01';
            tematica.CC_Canal_Operativo__c = 'App Imagin';
            insert tematica;

            CC_MCC__c producto = new CC_MCC__c();
            producto.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
            producto.Name = 'Causa Prueba';
            producto.CC_Tipo_Cliente__c = 'Cliente';
            producto.CC_Codigo_Externo__c = 'PR00-01';
            producto.CC_Tematica__c = tematica.Id;
            insert producto;

            CC_MCC__c motivo = new CC_MCC__c();
            motivo.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
            motivo.Name = 'Causa Prueba';
            motivo.CC_Tipo_Cliente__c = 'Cliente';
            motivo.CC_Codigo_Externo__c = 'MO00-01';
            motivo.CC_Producto_Servicio__c = producto.Id;
            insert motivo;

            CC_MCC__c causa = new CC_MCC__c();
            causa.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
            causa.Name = 'Causa Prueba';
            causa.CC_Tipo_Cliente__c = 'Cliente';
            causa.CC_Codigo_Externo__c = 'CA00-01';
            causa.CC_Motivo__c = motivo.Id;

            insert causa;

            Case oCaso2 = new Case();
            oCaso2.Subject = 'Test Consulta';
            oCaso2.Origin = 'Email';
            oCaso2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            oCaso2.ContactId = oContacto.Id;
            oCaso2.CC_Canal_Procedencia__c = 'Accionista';
            oCaso2.CC_Tipo_Contacto__c = 'Consulta';
            oCaso2.CC_MailTelfNotif__c = 'test@test.es';
            oCaso2.CC_CanalNotifCli__c = 'Email';
            oCaso2.CC_Idioma__c = 'es';
            oCaso2.CC_MCC_Causa__c = causa.Id;
            insert oCaso2;
        }
    }

    @IsTest
    static void asociarCasosAComunicacionInformativa_Test() {

        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa_de_Campana').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordType.DeveloperName = 'CC_GrupoMaximo' WITH SECURITY_ENFORCED LIMIT 1];
        CC_Clasificacion_Maximo__c oClasif = [SELECT Id FROM CC_Clasificacion_Maximo__c WITH SECURITY_ENFORCED LIMIT 1];
        CC_Caracteristica__c caracteristica = [SELECT Id FROM CC_Caracteristica__c WITH SECURITY_ENFORCED LIMIT 1];

        Test.startTest();

        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
        oAgr.CC_Estado__c = 'Activo';
        oAgr.CC_Numero_Casos__c = 0;
        oAgr.CC_Campana__c = caracteristica.Id;
        insert oAgr;

        Test.stopTest();
    }

    @IsTest
    static void asociarCasosAComunicacionInformativa2_Test() {

        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordType.DeveloperName = 'CC_GrupoMaximo' WITH SECURITY_ENFORCED LIMIT 1];
        CC_Clasificacion_Maximo__c oClasif = [SELECT Id FROM CC_Clasificacion_Maximo__c WITH SECURITY_ENFORCED LIMIT 1];
        CC_Caracteristica__c caracteristica = [SELECT Id FROM CC_Caracteristica__c WITH SECURITY_ENFORCED LIMIT 1];
        CC_MCC__c tematica = [SELECT Id FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Tematica' WITH SECURITY_ENFORCED LIMIT 1];
        CC_MCC__c producto = [SELECT Id FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Producto_Servicio' WITH SECURITY_ENFORCED LIMIT 1];
        CC_MCC__c motivo = [SELECT Id FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Motivo' WITH SECURITY_ENFORCED LIMIT 1];
        CC_MCC__c causa = [SELECT Id FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Causa' WITH SECURITY_ENFORCED LIMIT 1];

        Test.startTest();

        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
        oAgr.CC_Estado__c = 'Activo';
        oAgr.CC_Numero_Casos__c = 0;
        oAgr.CC_Tematica_Id__c = tematica.Id;
        oAgr.CC_Producto_Servicio__c = producto.Id;
        oAgr.CC_Motivo__c = motivo.Id;
        oAgr.CC_Causa__c = causa.Id;
        insert oAgr;

        Test.stopTest();
    }

    @IsTest
    static void gestionAgrupador_Test() {
        User admin = CC_TestDataFactory.getUserAdmin();

        System.runAs(admin) {
            Test.startTest();

            Id sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
            CC_Agrupador__c oAgr = new CC_Agrupador__c();
            oAgr.RecordTypeId = sRecordType;
            oAgr.CC_Titulo__c = 'Test';
            oAgr.CC_Descripcion__c = 'Test';
            oAgr.CC_Estado__c = 'Activo';
            oAgr.CC_Publica__c = true;
            insert oAgr;

            CC_Agrupador__c agrupadorActualizado = [SELECT Id, CC_Id__c FROM CC_Agrupador__c WHERE Id = :oAgr.Id  LIMIT 1];

            System.assertEquals(agrupadorActualizado.Id, agrupadorActualizado.CC_Id__c, 'El ID Interno del agrupador no coincide con el ID del agrupador');
        
            Test.stopTest();
        }
    }
}