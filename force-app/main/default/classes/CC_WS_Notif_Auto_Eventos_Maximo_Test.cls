@IsTest
public class CC_WS_Notif_Auto_Eventos_Maximo_Test {
	@isTest
    static void crearActualizarEventoMaximoAutomatico() {
        // Inicialización de datos.
        List<CC_Lista_Valores__c> oListVal = new List<CC_Lista_Valores__c>();
        List<CC_Lista_Valores__c> oListVal2 = new List<CC_Lista_Valores__c>();
        
        ID sTipoRegL = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();        
        ID sTipoRegV = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();        
        
        CC_Lista_Valores__c a1 = new CC_Lista_Valores__c();
        a1.Name = 'Configuración Notificaciones Automáticas Eventos';
        a1.CC_Activa__c = true;
        a1.RecordTypeId = sTipoRegL;
        insert a1;
        
        CC_Lista_Valores__c a5 = new CC_Lista_Valores__c();
        a5.Name = 'Activar/Desactivar';
        a5.CC_Activa__c = true;
        a5.RecordTypeId = sTipoRegV;
        a5.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'Configuración Notificaciones Automáticas Eventos'].Id;
        a5.CC_Valor__c = 'Y';
        a5.CC_Valor_SFDC__c = 'Y';
        insert a5;
        
        String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
        oGrupo.RecordTypeId = sRecordType3;
        oGrupo.Name = 'Grupo1';
        oGrupo.CC_External__c = 'GC-00001';
        insert oGrupo;
		System.assertNotEquals(oGrupo, null);
        
        CC_Grupo_Colaborador_Contact__c oGrupoUser = new CC_Grupo_Colaborador_Contact__c();
        oGrupoUser.CC_Usuario__c = UserInfo.getUserId();
        oGrupoUser.CC_Grupo_Colaborador__c = oGrupo.Id;
        insert oGrupoUser;
		System.assertNotEquals(oGrupoUser, null);
        
        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
        oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'TEST';
        insert oClasif;
		System.assertNotEquals(oClasif, null);
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
        oAgr.CC_Id_Maximo__c = 'IN0001';
        oAgr.CC_Evento__c = true;
        insert oAgr;
		System.assertNotEquals(oAgr, null);
                
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
        oCaso.CC_Agrupador_Id__c = oAgr.Id;
        oCaso.CC_Idioma__c = 'es';
        insert oCaso;
        
        Case newCaso = new Case();
        newCaso.Subject = 'Test Incidencia';
        newCaso.Origin = 'Email';
        newCaso.ContactId = oContacto.Id;
        newCaso.CC_NotIncidencia__c = '1';
        newCaso.CC_MailTelfNotif__c = 'test@test.es';
        newCaso.CC_CanalNotifCli__c = 'Email';
        newCaso.CC_Agrupador_Id__c = oAgr.Id;
        newCaso.CC_Idioma__c = 'es';
        insert newCaso;
        
		System.assertNotEquals(oCaso, null);
        
        Test.startTest();

        Test.setMock(WebServiceMock.class, new CC_WS_Maximo_Mock_02());
        
        List<ID> oIDs = new List<ID>();
        oIDs.add(oAgr.Id);                
        CC_WS_Notif_Auto_Eventos_Maximo.crearActualizarEventoMaximoAutomatico(oIDs);
		
        //CC_Notificacion_Volumen__c oVol = [SELECT Id FROM CC_Notificacion_Volumen__c WHERE CC_Agrupador_Id__c = :oAgr.Id];
		//System.assertNotEquals(oVol, null);
        
        Test.stopTest();
    }
    
}