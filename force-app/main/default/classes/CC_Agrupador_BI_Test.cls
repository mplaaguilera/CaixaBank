@IsTest
public class CC_Agrupador_BI_Test {
    @TestSetup
    static void makeData() {

        String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
        oGrupo.RecordTypeId = sRecordType3;
        oGrupo.Name = 'Grupo1';
        oGrupo.CC_External__c = 'GM-00004';
        insert oGrupo;

        CC_MCC__c causa = new CC_MCC__c();
        causa.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        causa.Name = 'Causa Prueba';
        causa.CC_Tipo_Cliente__c = 'Cliente';
        causa.CC_Codigo_Externo__c = 'CA00-01';

        insert causa;

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
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
        String sRecordTypeCampana = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa_de_Campana').getRecordTypeId();
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
        oAgr.CC_Estado__c = 'Activo';
        oAgr.CC_Causa__c = causa.Id;
        insert oAgr;

        CC_Agrupador__c oAgrCam = new CC_Agrupador__c();
        oAgrCam.RecordTypeId = sRecordTypeCampana;
        oAgrCam.CC_Titulo__c = 'Test 2';
        oAgrCam.CC_Descripcion__c = 'Test';
        oAgrCam.CC_GrupoMaximo__c = oGrupo.Id;
        oAgrCam.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgrCam.CC_Clasificacion_Maximo__c = oClasif.Id;
        oAgrCam.CC_Estado__c = 'Activo';
        oAgrCam.CC_Campana__c = caracteristica.Id;
        insert oAgrCam; 
    }

    @IsTest
    static void impedirCreacionComunicacionInformativaDuplicada_Test() {
        Test.startTest();
        try {

            CC_Clasificacion_Maximo__c oClasif = [SELECT Id FROM CC_Clasificacion_Maximo__c WITH SECURITY_ENFORCED LIMIT 1];
            CC_Grupo_Colaborador__c oGrupo = [SELECT Id FROM CC_Grupo_Colaborador__c WITH SECURITY_ENFORCED LIMIT 1];
            CC_MCC__c causa = [SELECT Id FROM CC_MCC__c WHERE Name = 'Causa Prueba' WITH SECURITY_ENFORCED LIMIT 1];

            CC_Agrupador__c oAgr = new CC_Agrupador__c();
            oAgr.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
            oAgr.CC_Titulo__c = 'Test';
            oAgr.CC_Descripcion__c = 'Test';
            oAgr.CC_GrupoMaximo__c = oGrupo.Id;
            oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
            oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
            oAgr.CC_Estado__c = 'Activo';
            oAgr.CC_Causa__c = causa.Id;
            insert oAgr;
        } catch (Exception e) {
            System.debug(e);
        }
        Test.stopTest();
    }

    @IsTest
    static void impedirCreacionComunicacionInformativaDuplicada_Test2() {
        Test.startTest();
        try {

            CC_Clasificacion_Maximo__c oClasif = [SELECT Id FROM CC_Clasificacion_Maximo__c WITH SECURITY_ENFORCED LIMIT 1];
            CC_Grupo_Colaborador__c oGrupo = [SELECT Id FROM CC_Grupo_Colaborador__c WITH SECURITY_ENFORCED LIMIT 1];
            CC_Caracteristica__c caracteristica = [SELECT Id FROM CC_Caracteristica__c WHERE Name = 'Campa Prueba' WITH SECURITY_ENFORCED LIMIT 1];

            CC_Agrupador__c oAgr = new CC_Agrupador__c();
            oAgr.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa_de_Campana').getRecordTypeId();
            oAgr.CC_Titulo__c = 'Test';
            oAgr.CC_Descripcion__c = 'Test';
            oAgr.CC_GrupoMaximo__c = oGrupo.Id;
            oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
            oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
            oAgr.CC_Estado__c = 'Activo';
            oAgr.CC_Campana__c = caracteristica.Id;
            insert oAgr;
        } catch (Exception e) {
            System.debug(e);
        }
        Test.stopTest();
    }
}