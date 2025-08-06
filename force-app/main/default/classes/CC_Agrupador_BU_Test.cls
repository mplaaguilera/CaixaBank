@IsTest
public class CC_Agrupador_BU_Test {
    
    @isTest
    static void cerrarAgrupadorComunicacion() {
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
        
        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
        oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'TEST';
        insert oClasif;
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
        oAgr.CC_Estado__c = 'Activo';
        insert oAgr;
        
        CC_PlantillaAsociada__c oTexto = new CC_PlantillaAsociada__c();
        oTexto.CC_Canal__c = 'Email';
        oTexto.CC_Idioma__c = 'es';
        oTexto.CC_Agrupador__c = oAgr.Id;
        oTexto.CC_CuerpoNotificacion__c = 'text';        
        oTexto.CC_Revisada__c = true;
        insert oTexto;
        
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
        
        Test.startTest();
        
        Boolean bError = false;
        
        try
        {
            // Cerrar el Máximo.
            oAgr.CC_Estado__c = 'Cerrado';
            oAgr.CC_Fecha_Cierre__c = Datetime.newInstance(2019,05,05);
            update oAgr;
        } catch(Exception e) {
            bError = true;
        }
        
        CC_Agrupador__c oRes = [SELECT Id, CC_Estado__c FROM CC_Agrupador__c WHERE Id = :oAgr.Id LIMIT 1];
        
        if (bError) {
            System.assertEquals(oRes.CC_Estado__c,'Activo');
        }
        else {
            System.assertEquals(oRes.CC_Estado__c,'Cerrado');
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void cerrarAgrupadorComunicacion_error01() {
        CC_Grupo_Colaborador__c oGrupoCI = new CC_Grupo_Colaborador__c();
        oGrupoCI.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
        oGrupoCI.Name = 'GrupoC';
        oGrupoCI.CC_External__c = 'CI-00001';
        insert oGrupoCI;
        
        CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
        oGrupo.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        oGrupo.Name = 'Grupo1';
        oGrupo.CC_External__c = 'GM-00004';
        insert oGrupo;
        
        CC_Grupo_Colaborador_Contact__c oGrupoUser = new CC_Grupo_Colaborador_Contact__c();
        oGrupoUser.CC_Usuario__c = UserInfo.getUserId();
        oGrupoUser.CC_Grupo_Colaborador__c = oGrupo.Id;
        insert oGrupoUser;
        
        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
        oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'TEST';
        insert oClasif;
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
        oAgr.CC_Estado__c = 'Activo';
        insert oAgr;
        
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

        List<Case> listaCasos = new List<Case>();
        listaCasos.add(oCaso.clone());
        listaCasos.add(oCaso.clone());
        oCaso.CC_Idioma__c = 'ca';
        listaCasos.add(oCaso.clone());
        insert listaCasos;
        for (Case caso : listaCasos) {
            caso.CC_CanalNotifCli__c = 'Email';
        }
        update listaCasos;
        
        // Test para plantillas sin asociar al agrupador
        Test.startTest();
        Boolean bError = false;
        try {
            // Cerrar el Máximo.
            oAgr.CC_Estado__c = 'Cerrado';
            oAgr.CC_Fecha_Cierre__c = Datetime.newInstance(2019,05,05);
            update oAgr;
        } catch(Exception e) {
            bError = true;
        }
        System.assertEquals(bError, true);   

        List<CC_PlantillaAsociada__c> listaPlantillas = new List<CC_PlantillaAsociada__c>();
        listaPlantillas.add(new CC_PlantillaAsociada__c(
            CC_Canal__c = 'Email',
            CC_Idioma__c = 'es',
            CC_Agrupador__c = oAgr.Id,
            CC_CuerpoNotificacion__c = 'text'
        ));
        listaPlantillas.add(new CC_PlantillaAsociada__c(
            CC_Canal__c = 'Email',
            CC_Idioma__c = 'ca',
            CC_Agrupador__c = oAgr.Id,
            CC_CuerpoNotificacion__c = 'text'
        ));
        insert listaPlantillas;
        
        // Test con plantillas asociadas al agrupador pero sin revisar
        bError = false;
        try {
            // Cerrar el Máximo.
            oAgr.CC_Estado__c = 'Cerrado';
            oAgr.CC_Fecha_Cierre__c = Datetime.newInstance(2019,05,05);
            update oAgr;
        } catch(Exception e) {
            bError = true;
        }
        System.assertEquals(bError, true);   
        Test.stopTest();
    }
}