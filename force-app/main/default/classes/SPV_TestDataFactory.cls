/*********************************************************************************************************
 * Name: SPV_TestDataFactory
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Clase para crear datos para las clases test de forma centralizada.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY            AUTHOR               DATE             Description
 * 1.0               ---             Raúl Santos          29/04/24             Creación
**********************************************************************************************************/

public with sharing class SPV_TestDataFactory {
    
    /*-----CREACION USUARIO-----*/
    public static List<User> crearUsuarioSPVGeneral(Integer numUsers){
        List<User> userList = new List<User>();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'SPV_General'].Id;
        Id uRoleId = [SELECT Id FROM userRole WHERE DeveloperName = 'SPV_General'].Id;

        for(Integer i=0;i<numUsers;i++){
            User user = new User(
                Username = 'usertest' + i + '@testSPV.com.testSetup',
                Email = 'email' + i + '@testSPV.com',
                LastName = 'Usuario Test SPV' + i,
                ProfileId = profileId,
                Alias = 'alias' + i,
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'es_ES',
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                isActive = true,
                userRoleId = uRoleId
            );
            userList.add(user);
        }
        return userList;
    }

    /*-----CREACION GRUPO COLABORADOR-----*/ //recordTypes: 'GrupoGestor', 'GrupoLetrado', 'GrupoDeTareas' 
    public static List<CC_Grupo_Colaborador__c> crearGrupoColaborador(String recordType, Integer numGrupos){
        List<CC_Grupo_Colaborador__c> listGrupos = new List<CC_Grupo_Colaborador__c>();
        for(Integer i=0;i<numGrupos;i++) {
            CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();
            if(recordType == 'GrupoGestor'){
                grupo.name = 'Grupo Gestor ' + i;
                grupo.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoGestor').getRecordTypeId();
                listGrupos.add(grupo); 
            }
            else if(recordType == 'GrupoLetrado'){
                grupo.name = 'Grupo Letrado ' + i;
                grupo.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoLetrado').getRecordTypeId();
                listGrupos.add(grupo); 
            }
            else if(recordType == 'GrupoDeTareas'){
                grupo.name = 'Grupo De Tareas ' + i;
                grupo.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoDeTareas').getRecordTypeId();
                listGrupos.add(grupo); 
            }
        }
        return listGrupos;
    }

     /*-----CREACION COLABORADOR CONTACT-----*/
    public static CC_Grupo_Colaborador_Contact__c crearColaboradorContact(Id usuario, Id grupoColab){
        CC_Grupo_Colaborador_Contact__c colabContact = new CC_Grupo_Colaborador_Contact__c(
            CC_Usuario__c = usuario,
            CC_Grupo_Colaborador__c = grupoColab
        );
        return colabContact;
    }


    /*-----CREACION OBJETO CASO-----*/ //recordTypes: 'Reclamacion', 'Pretension', 'Consulta'
    public static Case crearCaso(String recordType, Map<String, Object> campos) {
        Case caso = new Case();
        if(recordType == 'Reclamacion'){
            caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();  
            //caso.SAC_Naturaleza__c = 'SAC_004';
            for (String campo : campos.keySet()) {
                caso.put(campo, campos.get(campo));
            }
        }
        else if(recordType == 'Pretension'){
            caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Pretension').getRecordTypeId();
            for (String campo : campos.keySet()) {
                caso.put(campo, campos.get(campo));
            }
        }
       /* else if(recordType == 'Consulta'){
            caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
            for (String campo : campos.keySet()) {
                caso.put(campo, campos.get(campo));
            }
        }*/
        return caso;
    }


     /*-----CREACION USUARIO-----*/
     public static List<User> crearUsuarioAdministrador(Integer numUsers){
        List<User> userList = new List<User>();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' or Name = 'Administrador del sistema'].Id;
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SPV_General'];
        for(Integer i=0;i<numUsers;i++){
            User user = new User(
                Username = 'useradmintest' + i + '@test.com.testSetup',
                Email = 'emailadmin' + i + '@test.com',
                LastName = 'Usuario adminTest' + i,
                ProfileId = profileId,
                Alias = 'aladmin' + i,
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'es_ES',
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                isActive = true,
                userRole = uRole // <---- añadido recientemente   
            );
            userList.add(user);
        }
        return userList;
    }

    /*-----CREACION TAREAS-----*/ 
    public static List<SAC_Accion__c> crearTareas (Integer numTareas, Case reclamacion, Case pretension){
        List<SAC_Accion__c> listTareas = new List<SAC_Accion__c>();
        for(Integer i=0;i<numTareas;i++) {
            SAC_Accion__c tarea = new SAC_Accion__c();
            if(reclamacion != null && pretension == null){
                tarea.SAC_Reclamacion__c = reclamacion.Id;
                tarea.recordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SPV_Acciones').getRecordTypeId();
                listTareas.add(tarea);
            }
            else if(reclamacion != null && pretension != null){
                tarea.SAC_Reclamacion__c = reclamacion.Id;
                tarea.SAC_Pretension__c = pretension.Id;
                tarea.recordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SPV_Acciones').getRecordTypeId();
                listTareas.add(tarea);
            }     
        }
        return listTareas;
    }

    /*-----CREACION MAESTRO ACCIONES-----*/
    public static List<SAC_MaestroAccionesReclamacion__c> crearMaestroAcciones(Integer numMaestro, Id grupoColabId){
        List<SAC_MaestroAccionesReclamacion__c> listMaestros = new List<SAC_MaestroAccionesReclamacion__c>();
        for(Integer i=0;i<numMaestro;i++) {
            SAC_MaestroAccionesReclamacion__c maestroAcciones = new SAC_MaestroAccionesReclamacion__c(
                Name = 'NombreTareaTest' + i,
                SAC_Descripcion__c = 'DescTareaTest' + i,
                SAC_EquipoResponsable__c = grupoColabId,
                SAC_PlazoMaximo__c = 2,
                RecordTypeId = Schema.SObjectType.SAC_MaestroAccionesReclamacion__c.getRecordTypeInfosByDeveloperName().get('SPV_MaestroAcciones').getRecordTypeId(),
                SAC_Prorroga__c = 2,
                SAC_Activo__c=true
            );
            listMaestros.add(maestroAcciones);
        }
        return listMaestros;
    }

    /*-----CREACION INTERACCION-----*/
    public static SAC_Interaccion__c crearInteraccion(String recordType, Map<String, Object> campos){
        SAC_Interaccion__c interaccion = new SAC_Interaccion__c();
        if(recordType == 'Escalado'){
            interaccion.RecordTypeId = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SPV_Escalado').getRecordTypeId();
            for (String campo : campos.keySet()) {
                interaccion.put(campo, campos.get(campo));
            }
        } else if(recordType == 'Consulta'){
            interaccion.RecordTypeId = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SPV_Consulta').getRecordTypeId();  
            for (String campo : campos.keySet()) {
                interaccion.put(campo, campos.get(campo));
            }
        }
        return interaccion;
    }
    
    /*-----CREACION CUENTAS-----*/
    public static List<Account> crearCuentas(Integer numCuentas){
        List<Account> listCuentas = new List<Account>();
        for(Integer i=0;i<numCuentas;i++) {
            Account cuenta = new Account(Name = 'cuentaTest' + i);
            listCuentas.add(cuenta);
        }
        return listCuentas;
    }
     /*-----CREACION CUENTA PA-----*/

    public static List<Account> crearCuentasNoClientePA(Integer numCuentas){
        List<Account> listCuentas = new List<Account>();
        for(Integer i=0;i<numCuentas;i++) {
            Account cuenta = new Account(
                FirstName = 'Target ' + i, 
                LastName = 'acuseRecibo ' + i, 
                PersonEmail = 'acuserecibo'+i+'@acuse.com.test', 
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SAC_NoCliente_PA').getRecordTypeId()
            );
                
            listCuentas.add(cuenta);
        }
        return listCuentas;
    }
        /*-----CREACION CONTACT-----*/
    public static List<Contact> crearContacto(Integer numContactos, Id cuentaId){
        List<Contact> listContactos = new List<Contact>();
        for(Integer i=0;i<numContactos;i++) {
            Contact contacto = new Contact(
                AccountId = cuentaId,
		        FirstName = 'Test' + i,
		        LastName = 'Apellido'
            );
            listContactos.add(contacto);
        }
        return listContactos;
    }

      /*-----CREACION RECLAMANTE-----*/
      public static SAC_CaseReclamante__c crearReclamante(Boolean principal, Case caso, Id cuentaId){
        SAC_CaseReclamante__c reclamante = new SAC_CaseReclamante__c();
        if(caso.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId()){
            if(principal){
                reclamante.SAC_ReclamantePrincipal__c = true;
                reclamante.SAC_Case__c = caso.Id;
                reclamante.SAC_Account__c = cuentaId;
            }
            else{
                reclamante.SAC_ReclamantePrincipal__c = false;
                reclamante.SAC_Case__c = caso.Id;
                reclamante.SAC_Account__c = cuentaId;
            }
        }
        else if(caso.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Pretension').getRecordTypeId()){
            if(principal){
                reclamante.SAC_ReclamantePrincipal__c = true;
                reclamante.SAC_Pretension__c = caso.Id;
                reclamante.SAC_Account__c = cuentaId;
            }
            else{
                reclamante.SAC_ReclamantePrincipal__c = false;
                reclamante.SAC_Pretension__c = caso.Id;
                reclamante.SAC_Account__c = cuentaId;
            }
        }
        return reclamante;
    }

    /*-----CREACION CONTENT VERSION -----*/
    public static ContentVersion crearContentVersion(Case caso) {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title='ABC Test';
        contentVersion.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        contentVersion.FirstPublishLocationId = caso.Id;
        contentVersion.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        contentVersion.SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion';
        return contentVersion;  
    }

    public static List<SAC_DocumentoEnvio__c> crearDocumentoEnvio(Integer numDoc, Case caso){
        List<SAC_DocumentoEnvio__c> listaDocs = new List<SAC_DocumentoEnvio__c>();
        for(Integer i=0;i<numDoc;i++){
            SAC_DocumentoEnvio__c documento = new SAC_DocumentoEnvio__c(
                SAC_Caso__c = caso.Id
            );
            listaDocs.add(documento);
        }
        return listaDocs;
    }
}