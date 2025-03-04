/*****************************************************************
 * Name: SAC_TestDataFactory
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Clase para crear datos para las clases test de forma centralizada.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US535374         Jose Carlos Blanco   08/02/23     Creación
*****************************************************************/
public with sharing class SAC_TestDataFactory {

    /*-----CREACION OBJETO CASO-----*/ //recordTypes: 'Reclamacion', 'Pretension', 'Consulta'
    public static Case crearCaso(String recordType, Map<String, Object> campos) {
        Case caso = new Case();
        if(recordType == 'Reclamacion'){
            caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();  
            caso.SAC_Naturaleza__c = 'SAC_004';
            for (String campo : campos.keySet()) {
                caso.put(campo, campos.get(campo));
            }
        }
        else if(recordType == 'Pretension'){
            caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
            for (String campo : campos.keySet()) {
                caso.put(campo, campos.get(campo));
            }
        }
        else if(recordType == 'Consulta'){
            caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
            for (String campo : campos.keySet()) {
                caso.put(campo, campos.get(campo));
            }
        }
        return caso;
    }
    /*-----CREACION RECLAMACION-----*/ // NO USAR, CAMBIARLO POR EL CREARCASO DE MAS ARRIBA
    public static List<Case> crearReclamacion(Integer numCases){
        List<Case> listCases = new List<Case>();
        for(Integer i=0;i<numCases;i++){
            Case caso = new Case(
                Subject = 'TestReclamacion' + i,
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId(),
                SAC_Naturaleza__c = 'SAC_004'
            );
            listCases.add(caso);
        }
        return listCases;
    }
    /*-----CREACION CONSULTA-----*/ // NO USAR, CAMBIARLO POR EL CREARCASO DE MAS ARRIBA
    public static List<Case> crearConsulta(Integer numCons){
        List<Case> listCons = new List<Case>();
        for(Integer i=0;i<numCons;i++){
            Case consulta = new Case(
                Subject = 'TestConsulta' + i,
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId()
            );
            listCons.add(consulta);
        }
        return listCons;
    }
    /*-----CREACION PRETENSION-----*/ // NO USAR, CAMBIARLO POR EL CREARCASO DE MAS ARRIBA
    public static List<Case> crearPretension(Integer numPret, Id casoId){
        List<Case> listPret = new List<Case>();
        for(Integer i=0;i<numPret;i++){
            Case pret = new Case(
                Subject = 'TestPretension' + i,
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId(),
                SAC_Reclamacion__c = casoId
            );
            listPret.add(pret);
        }
        return listPret;
    }
    /*-----CREACION RECLAMANTE-----*/
    public static SAC_CaseReclamante__c crearReclamante(Boolean principal, Case caso, Id cuentaId){
        SAC_CaseReclamante__c reclamante = new SAC_CaseReclamante__c();
        if(caso.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId()){
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
        else if(caso.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId()){
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
     /*-----CREACION CUENTA OFICINA-----*/
    public static List<Account> crearCuentasOficina(Integer numCuentas){
        List<Account> listCuentas = new List<Account>();
        for(Integer i=0;i<numCuentas;i++) {
            Account cuenta = new Account(
                Name = 'cuentaTest Oficina' + i,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId()
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
    /*-----CREACION GRUPO-----*/
    public static List<Group> crearGrupo(Integer numGrupos){
        List<Group> listGrupos = new List<Group>();
        for(Integer i=0;i<numGrupos;i++) {
            Group grupo = new Group(
		        Name = 'Test' + i
            );
            listGrupos.add(grupo);
        }
        return listGrupos;
    }
    /*-----CREACION GRUPO COLABORADOR-----*/ //recordTypes: 'ResponsableAccion', 'GrupoProveedor', 'GrupoLetrados' 
    public static List<CC_Grupo_Colaborador__c> crearGrupoColaborador(String recordType, Integer numGrupos){
        List<CC_Grupo_Colaborador__c> listGrupos = new List<CC_Grupo_Colaborador__c>();
        for(Integer i=0;i<numGrupos;i++) {
            CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();
            if(recordType == 'ResponsableAccion'){
                grupo.name = 'Grupo Responsable Accion ' + i;
                grupo.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();
                grupo.SAC_PermiteTareas__c= true;  
                listGrupos.add(grupo); 
            }
            else if(recordType == 'GrupoProveedor'){
                grupo.name = 'Grupo Proveedor ' + i;
                grupo.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
                grupo.SAC_PermiteTareas__c= true;  
                listGrupos.add(grupo); 
            }
            else if(recordType == 'GrupoLetrados'){
                grupo.name = 'Grupo Letrados ' + i;
                grupo.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_Letrados').getRecordTypeId();
                grupo.SAC_PermiteTareas__c= true;  
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
    /*-----CREACION MAESTRO ACCIONES-----*/
    public static List<SAC_MaestroAccionesReclamacion__c> crearMaestroAcciones(Integer numMaestro, Id grupoColabId){
        List<SAC_MaestroAccionesReclamacion__c> listMaestros = new List<SAC_MaestroAccionesReclamacion__c>();
        for(Integer i=0;i<numMaestro;i++) {
            SAC_MaestroAccionesReclamacion__c maestroAcciones = new SAC_MaestroAccionesReclamacion__c(
                Name = 'NombreTareaTest' + i,
                SAC_Descripcion__c = 'DescTareaTest' + i,
                SAC_EquipoResponsable__c = grupoColabId,
                SAC_PlazoMaximo__c = 2,
                RecordTypeId = Schema.SObjectType.SAC_MaestroAccionesReclamacion__c.getRecordTypeInfosByDeveloperName().get('SAC_MaestroAcciones').getRecordTypeId(),
                SAC_Prorroga__c = 2,
                SAC_Activo__c=true
            );
            listMaestros.add(maestroAcciones);
        }
        return listMaestros;
    }
    /*-----CREACION TAREAS-----*/ 
    public static List<SAC_Accion__c> crearTareas (Integer numTareas, Case caso, Boolean maestro){
        List<SAC_Accion__c> listTareas = new List<SAC_Accion__c>();
        for(Integer i=0;i<numTareas;i++) {
            SAC_Accion__c tarea = new SAC_Accion__c();
            if(caso.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId()){
                if(maestro){
                    tarea.SAC_Estado__c = 'SAC_PendienteEnviar';
                    tarea.SAC_Reclamacion__c = caso.Id;
                    tarea.recordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_MaestroDeTareas').getRecordTypeId();
                    listTareas.add(tarea);
                }
                else{
                    tarea.SAC_Estado__c = 'SAC_PendienteEnviar';
                    tarea.SAC_Reclamacion__c = caso.Id;
                    tarea.recordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_OtrasTareas').getRecordTypeId();
                    listTareas.add(tarea);
                }
            }
            else if(caso.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId()){
                if(maestro){
                    tarea.SAC_Estado__c = 'SAC_PendienteEnviar';
                    tarea.SAC_Pretension__c = caso.Id;
                    tarea.recordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_MaestroDeTareas').getRecordTypeId();
                    listTareas.add(tarea);
                }
                else{
                    tarea.SAC_Estado__c = 'SAC_PendienteEnviar';
                    tarea.SAC_Pretension__c = caso.Id;
                    tarea.recordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_OtrasTareas').getRecordTypeId();
                    listTareas.add(tarea);
                }
            }     
        }
        return listTareas;
    }
    /*-----CREACION INTERACCION-----*/ //recordTypes: 'Consulta', 'Escalado', 'EscaladoNV3'
    public static SAC_Interaccion__c crearInteraccion(String recordType, Map<String, Object> campos){
        SAC_Interaccion__c interaccion = new SAC_Interaccion__c();
        if(recordType == 'Consulta'){
            interaccion.RecordTypeId = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();  
            for (String campo : campos.keySet()) {
                interaccion.put(campo, campos.get(campo));
            }
        }
        else if(recordType == 'Escalado'){
            interaccion.RecordTypeId = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Escalado').getRecordTypeId();
            for (String campo : campos.keySet()) {
                interaccion.put(campo, campos.get(campo));
            }
        }
        else if(recordType == 'EscaladoNV3'){
            interaccion.RecordTypeId = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_EscaladoNV3').getRecordTypeId();
            for (String campo : campos.keySet()) {
                interaccion.put(campo, campos.get(campo));
            }
        }
        return interaccion;
    }
    /*-----CREACION INTERACCION-----*/ //NO USAR, CAMBIARLO POR EL crearInteraccion DE MAS ARRIBA
    public static List<SAC_Interaccion__c> crearInteraccionn(Integer numInter, Id reclId, Id groupId){
        List<SAC_Interaccion__c> listInt = new List<SAC_Interaccion__c>();
        for(Integer i=0;i<numInter;i++) {
            SAC_Interaccion__c interaccion = new SAC_Interaccion__c(
                RecordTypeId = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId(),
                SAC_Reclamacion__c = reclId,
                SAC_GrupoColaborador__c = groupId
            );
            listInt.add(interaccion);
        }
        return listInt;
    }
    /*-----CREACION INTERACCION ESCALADO-----*/ //NO USAR, CAMBIARLO POR EL crearInteraccion DE MAS ARRIBA
    public static List<SAC_Interaccion__c> crearInteraccionEsc(Integer numInter, Id reclId, Id groupId){
        List<SAC_Interaccion__c> listInt = new List<SAC_Interaccion__c>();
        for(Integer i=0;i<numInter;i++) {
            SAC_Interaccion__c interaccion = new SAC_Interaccion__c(
                RecordTypeId = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Escalado').getRecordTypeId(),
                SAC_CasoEscalado__c = reclId,
                SAC_GrupoColaborador__c = groupId
            );
            listInt.add(interaccion);
        }
        return listInt;
    }
    /*-----CREACION MCCS-----*/ // NO USAR POR EL MOMENTO 
    public static List<CC_MCC__c> crearMCCs(){
        List<CC_MCC__c> listaMCCs = new List<CC_MCC__c>();
        DateTime inicioVigencia = System.now();
        Id recTypeTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recTypeProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recTypeMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recTypeDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();

        CC_MCC__c mccTematica1 = new CC_MCC__c(
            RecordTypeId = recTypeTematica,
            Name = 'Tematica',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-0101');
        listaMCCs.add(mccTematica1);

        CC_MCC__c mccProdServ1 = new CC_MCC__c(
            RecordTypeId = recTypeProdServ,
            Name = 'ProdServ',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-010101',
            CC_Tematica__c = mccTematica1.id);
        listaMCCs.add(mccProdServ1);

        CC_MCC__c mccMotivo1 = new CC_MCC__c(
            RecordTypeId = recTypeMotivo,
            Name = 'Motivo',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Producto_Servicio__c = mccProdServ1.id,
            CC_Codigo_Externo__c = 'TEST-0102');
        listaMCCs.add(mccMotivo1);

        CC_MCC__c mccDetalle1 = new CC_MCC__c(
            RecordTypeId = recTypeDetalle,
            Name = 'Detalle',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-01010101',
            CC_Motivo__c = mccMotivo1.id);
        listaMCCs.add(mccDetalle1);

        //////////////////////

        CC_MCC__c mccTematica2 = new CC_MCC__c(
            RecordTypeId = recTypeTematica,
            Name = 'Avales',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Tipo_Cliente__c = 'SAC',
            CC_Codigo_Externo__c = 'TEST-0201');
        listaMCCs.add(mccTematica2);

        CC_MCC__c mccProdServ2 = new CC_MCC__c(
            RecordTypeId = recTypeProdServ,
            Name = 'Avales Fianzas y Otras Garantías',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-01010102',
            CC_Tematica__c = mccTematica2.id);
        listaMCCs.add(mccProdServ2);

        CC_MCC__c mccMotivo2 = new CC_MCC__c(
            RecordTypeId = recTypeMotivo,
            Name = 'Gastos de formalización, gestorías, tasación',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Producto_Servicio__c = mccProdServ2.id,
            CC_Codigo_Externo__c = 'TEST-0202');
        listaMCCs.add(mccMotivo2);

        CC_MCC__c mccDetalle2 = new CC_MCC__c(
            RecordTypeId = recTypeDetalle,
            Name = 'Gastos de formalización, gestorías, tasación',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-01010103',
            CC_Motivo__c = mccMotivo2.id);
        listaMCCs.add(mccDetalle2);

        //////////////////////

        CC_MCC__c mccTematica3 = new CC_MCC__c(
            RecordTypeId = recTypeTematica,
            Name = 'Créditos',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-0301');
        listaMCCs.add(mccTematica3);

        CC_MCC__c mccProdServ3 = new CC_MCC__c(
            RecordTypeId = recTypeProdServ,
            Name = 'Créditos Hipotecarios Interés Variable',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-010101004',
            CC_Tematica__c = mccTematica3.id);
        listaMCCs.add(mccProdServ3);

        CC_MCC__c mccMotivo3 = new CC_MCC__c(
            RecordTypeId = recTypeMotivo,
            Name = 'IRPH',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Producto_Servicio__c = mccProdServ3.id,
            CC_Codigo_Externo__c = 'TEST-0302');
        listaMCCs.add(mccMotivo3);

        CC_MCC__c mccDetalle3 = new CC_MCC__c(
            RecordTypeId = recTypeDetalle,
            Name = 'IRPH',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-010101005',
            CC_Motivo__c = mccMotivo3.id);
        listaMCCs.add(mccDetalle3);

        return listaMCCs;
    }
    /*-----CREACION PARAMETRIZACIONES SLA TME-----*/ //recordTypes: 'TME', 'Regulatorio', 'Letrado', 'SLAAlta', 'SLANegociacion'  
    public static List<SAC_ParametrizacionSLATME__c> crearParamsSla(String recordType, Integer numParams){
        List<SAC_ParametrizacionSLATME__c> listaParams = new List<SAC_ParametrizacionSLATME__c>();
        for(Integer i=0;i<numParams;i++) {
            SAC_ParametrizacionSLATME__c param = new SAC_ParametrizacionSLATME__c();
            if(recordType == 'TME'){
                param.RecordTypeId = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_TME').getRecordTypeId();
                listaParams.add(param);
            }
            else if(recordType == 'Regulatorio'){
                param.RecordTypeId = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_SLARegulatorio').getRecordTypeId();
                listaParams.add(param);
            }
            else if(recordType == 'Letrado'){
                param.RecordTypeId = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_SLALetrado').getRecordTypeId();
                listaParams.add(param);
            }
            else if(recordType == 'SLAAlta'){
                param.RecordTypeId = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_SLAAlta').getRecordTypeId();
                listaParams.add(param);
            }
            else if(recordType == 'SLANegociacion'){
                param.RecordTypeId = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_SLANegociacion').getRecordTypeId();
                listaParams.add(param);
            }
        }
        return listaParams; 
    }
    /*-----CREACION USUARIO-----*/
    public static List<User> crearUsuarioSACGeneral(Integer numUsers){
        List<User> userList = new List<User>();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];
        for(Integer i=0;i<numUsers;i++){
            User user = new User(
                Username = 'usertest' + i + '@test.com.testSetup',
                Email = 'email' + i + '@test.com',
                LastName = 'Usuario Test' + i,
                ProfileId = profileId,
                Alias = 'alias' + i,
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
     /*-----CREACION USUARIO-----*/
     public static List<User> crearUsuarioAdministrador(Integer numUsers){
        List<User> userList = new List<User>();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' or Name = 'Administrador del sistema'].Id;
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];
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
    /*-----CREACION ALERTAS-----*/
    public static List<SAC_Alerta__c> crearAlerta(Integer numAlertas, Id casoId){
        List<SAC_Alerta__c> listaAlertas = new List<SAC_Alerta__c>();
        for(Integer i=0;i<numAlertas;i++){
            SAC_Alerta__c alerta = new SAC_Alerta__c(
                SAC_Reclamacion__c = casoId,
                RecordTypeId = Schema.SObjectType.SAC_Alerta__c.getRecordTypeInfosByDeveloperName().get('SAC_Alerta').getRecordTypeId()
            );
            listaAlertas.add(alerta);
        }
        return listaAlertas;
    }
    /*-----CREACION ENTITLEMENT-----*/
    public static Entitlement crearEntitlement(Id cuentaId){
        Entitlement entitlement = new Entitlement(
            name = 'EntitleTest',
            AccountId = cuentaId,
            SlaProcessId = [select id, name from SlaProcess where name = 'SAC_Process' limit 1].id
        );
        return entitlement;
    }
    /*-----CREACION DOCUMENTO ENVIO-----*/
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
    /*-----CREACION CLASIFICACIÓN RÁPIDA-----*/
    public static SEG_ClasificacionRapida__c crearClasificacionRapida(Map<String, Object> campos) {
        SEG_ClasificacionRapida__c clasR = new SEG_ClasificacionRapida__c();
        clasR.CBK_Negocio__c = 'SAC';   
            for (String campo : campos.keySet()) {
                clasR.put(campo, campos.get(campo));
            } 
        return clasR;  
    }
    /*-----CREACION REGLAS CLASIFICACIÓN-----*/
    public static SEG_Regladeclasificacion__c crearReglasClasificacion(Id clasR, Map<String, Object> campos) {
        SEG_Regladeclasificacion__c reglas = new SEG_Regladeclasificacion__c();
        reglas.CBK_Negocio__c = 'SAC';
        reglas.SEG_ClasificacionRapida__c = clasR;   
            for (String campo : campos.keySet()) {
                reglas.put(campo, campos.get(campo));
            } 
        return reglas;  
    }
    /*-----CREACION MULTIVALOR-----*/ // tipoValor: 'Remitente', 'Asunto', 'Destinatario', 'Destinatario CC', 
    //                                              'Cuerpo', 'Asunto a excluir', 'Cuerpo a excluir', 
    //                                              'Remitente a excluir', 'Destinatario a excluir', 'Destinatario CC a excluir'
    public static List<SEG_Multivalor__c> crearMultivalor(Integer numValor, Id reglasId, String tipoValor){
        List<SEG_Multivalor__c> listMultivalor = new List<SEG_Multivalor__c>();
        for(Integer i=0;i<numValor;i++) {
            SEG_Multivalor__c multivalor = new SEG_Multivalor__c();
            multivalor.SEG_Reglas_Clasificacion__c = reglasId;
            multivalor.CBK_Negocio__c = 'SAC';
            multivalor.SEG_TipodeValor__c = tipoValor;
            multivalor.SEG_Valor__c = 'Valor';
            listMultivalor.add(multivalor);             
        }
        return listMultivalor;
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

    /*-----CREACION MAESTRO TEMAS -----*/ // recordType: 'SAC_TipoAdjuntos', 'SAC_InformacionCualitativa'
    public static List<SAC_MaestroTemas__c> crearMaestroTemas(Integer numMaestro, String recordType) {
        List<SAC_MaestroTemas__c> listMaestroTemas = new List<SAC_MaestroTemas__c>();
        for(Integer i=0;i<numMaestro;i++) {
            if(recordType == 'SAC_TipoAdjuntos'){
                SAC_MaestroTemas__c maestroTema = new SAC_MaestroTemas__c(
                Name = 'maestroAdjuntoTest' + i,
                RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_TipoAdjuntos').getRecordTypeId(),
                SAC_Seccion__c = 'Test maestro adjunto'
                );
                
                listMaestroTemas.add(maestroTema);
            }
            else if(recordType == 'SAC_InformacionCualitativa'){
                SAC_MaestroTemas__c maestroTema = new SAC_MaestroTemas__c(
                Name = 'maestroInforCual' + i,
                RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_InformacionCualitativa').getRecordTypeId(),
                SAC_Seccion__c = 'Test maestro InforCual'
                );
                
                listMaestroTemas.add(maestroTema);
            } 
            else if(recordType == 'SAC_Temas'){
                SAC_MaestroTemas__c maestroTema = new SAC_MaestroTemas__c(
                Name = 'maestroTemas' + i,
                RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_Temas').getRecordTypeId(),
                SAC_Seccion__c = 'Test maestro temas',
                SAC_OrdenPrelacion__c = i + 1
                );
                
                listMaestroTemas.add(maestroTema);
            } 
            else if(recordType == 'SAC_ControlAltas'){
                SAC_MaestroTemas__c maestroTema = new SAC_MaestroTemas__c(
                Name = 'maestroControlAlta' + i,
                RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_ControlAltas').getRecordTypeId(),
                SAC_Seccion__c = 'Test control alta',
                SAC_Descripcion__c = 'Test control alta'
                );
                
                listMaestroTemas.add(maestroTema);
            } 
        }
        return listMaestroTemas;
    }
    /*-----CREACION PARAMETRIZACION ESCALADOS-----*/
    public static SAC_ParametrizacionEscalado__c crearParamEsc(Map<String, Object> campos){
        SAC_ParametrizacionEscalado__c params = new SAC_ParametrizacionEscalado__c();
        for (String campo : campos.keySet()) {
            params.put(campo, campos.get(campo));
        }
        return params;
    }
    /*-----CREACION TMEs-----*/
    public static SAC_TMECaso__c crearTMECaso(Map<String, Object> campos){
        SAC_TMECaso__c tmeCaso = new SAC_TMECaso__c();
        for (String campo : campos.keySet()) {
            tmeCaso.put(campo, campos.get(campo));
        }
        return tmeCaso;
    }
    /*-----CREACION TIEMPO ESTADOS-----*/
    public static SAC_TiempoEstados__c crearTiempoEstados(Id tme, Map<String, Object> campos){
        SAC_TiempoEstados__c tiempoEstados = new SAC_TiempoEstados__c();
        tiempoEstados.SAC_TMECaso__c = tme;
        for (String campo : campos.keySet()) {
            tiempoEstados.put(campo, campos.get(campo));
        }
        return tiempoEstados;
    }
}