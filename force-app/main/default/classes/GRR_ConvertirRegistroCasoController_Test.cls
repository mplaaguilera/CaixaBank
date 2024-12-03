@isTest
public with sharing class GRR_ConvertirRegistroCasoController_Test {

    @TestSetup
    static void makeData(){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User usuario = new User();
        usuario.IsActive = true;
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'GRR_Usuario_CaixaBank'].Id;
        usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'GRR'].Id;
        usuario.FirstName = 'GRR Prueba Clases Test';
        usuario.LastName = 'GRR Prueba Clases Test';
        usuario.Alias = uniqueName.substring(18, 23);
        usuario.Email = uniqueName + '@test' + orgId + '.org';
        usuario.Username = uniqueName + '@test' + orgId + '.org';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        usuario.TimezonesIdKey = 'Europe/Madrid';
        insert usuario;
        List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
        for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('GRR_Agente','GRR_Supervisor')]) {
            PermissionSetAssignment psAssignment = new PermissionSetAssignment();
            psAssignment.AssigneeId = usuario.Id;
            psAssignment.PermissionSetId = ps.Id;
            psAssignments.add(psAssignment);
        }
        insert psAssignments;
    
        Group grupo = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE DeveloperName = 'GRR_Buzon_Murcia' and Type = 'Regular' LIMIT 1];
        GroupMember miembroGrupo = new GroupMember();
        miembroGrupo.GroupId = grupo.Id;
        miembroGrupo.UserOrGroupId = usuario.Id;
        insert miembroGrupo;
    }
    
    private static void crearMCCRecobro() {
        CC_MCC__c mccTematica = new CC_MCC__c(
            Name = 'Recobro',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'TEGR-392001',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
        );
        insert mccTematica;
    }

    private static void crearMCCsActaComite() {
        CC_MCC__c mccTematica = new CC_MCC__c(
            Name = 'Comités',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'TEGR-000001',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
        );
        insert mccTematica;

        CC_MCC__c mccProducto = new CC_MCC__c(
            Name = 'Morosidad',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'PRGR-000001',
            CC_Tematica__c = mccTematica.Id,
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio')
        );
        insert mccProducto;

        CC_MCC__c mccMotivo = new CC_MCC__c(
            Name = 'No colabora',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'MOGR-000001',
            CC_Producto_Servicio__c = mccProducto.Id,
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo')
        );
        insert mccMotivo;
    }

    private static void crearCuenta() {
        Account cuenta = new Account (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'GRR_NoCliente_PA'),
            LastName = 'No cliente',
            CC_Numero_Documento__c = '1234567Z'
        );
        insert cuenta;
    }
    
    private static GRR_UR__c crearUR() {
        GRR_UR__c ur = new GRR_UR__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_UR__c', 'GRR_UR'),
            GRR_Id_UR__c = '00000001'
        );
        insert ur;
        return ur;
    }
    
    private static void crearListaExcepciones(){
        //Lista valores - excepciones
        List<CBK_Lista_Valores__c> lista = new List <CBK_Lista_Valores__c>();
        List<CBK_Lista_Valores__c> valoresLista = new List <CBK_Lista_Valores__c>();
        
        CBK_Lista_Valores__c excepcionesLista = new CBK_Lista_Valores__c();
        excepcionesLista.Name = 'GRR_EXCEPCIONES_CODIGOS_DT';
        excepcionesLista.CBK_Activa__c = true;
        excepcionesLista.CBK_Negocio__c = 'GRR';
        excepcionesLista.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CBK_Lista_Valores__c', 'CBK_Lista_de_valores');
        lista.add(excepcionesLista);
        insert lista;
        
        CBK_Lista_Valores__c valor = new CBK_Lista_Valores__c();
        valor.Name = '9097';
        valor.CBK_Activa__c = true;
        valor.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CBK_Lista_Valores__c', 'CBK_Valor');
        valor.CBK_Lista__c = excepcionesLista.Id;
        valor.CBK_Valor__c = 'TARRagona';
        valor.CBK_Negocio__c = 'GRR';
        valoresLista.add(valor);
        insert valoresLista;
    }
    
    private static GRR_Carga__c crearFicheroRecobro() {
        GRR_Carga__c fichero = new GRR_Carga__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_Carga__c', 'GRR_Carga'),
            GRR_NombreDelFichero__c = 'Fichero prueba',
            GRR_TipoDeFichero__c = 'Recobro'
        );
        insert fichero;
        return fichero;
    }

    private static GRR_RegistroCarga__c crearRegistroCargaRecobro(String idfichero, String urid) {
        GRR_Carga__c fichero = [SELECT Id FROM GRR_Carga__c WHERE Id = :idfichero];
        GRR_UR__c ur = [SELECT Id, GRR_Id_UR__c FROM GRR_UR__c WHERE Id = :urid];
        GRR_RegistroCarga__c registroCarga = new GRR_RegistroCarga__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Recobro'),
            GRR_Fichero__c = fichero.Id,
            GRR_UR__c = ur.Id,
            GRR_CodigoUR__c = ur.GRR_Id_UR__c,
            GRR_CodigoOficina__c = '1234',
            GRR_Provincia__c = 'MURCIA',
            GRR_NIFs_Con_RR__c = '1234567Z',
            GRR_NIF__c = '1234567D',
            GRR_GRR__c = 'Sí'
        );
        insert registroCarga;
        return registroCarga;
    }

    private static GRR_Carga__c crearFicheroActaComite() {
        GRR_Carga__c fichero = new GRR_Carga__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_Carga__c', 'GRR_Carga'),
            GRR_NombreDelFichero__c = 'Fichero prueba 2',
            GRR_TipoDeFichero__c = 'Acta de comité'
        );
        insert fichero;
        return fichero;
    }

    private static void crearRegistrosCargaActaComite(String idfichero, String urid) {
        List<GRR_RegistroCarga__c> registrosInsert = new List<GRR_RegistroCarga__c>();
        GRR_Carga__c fichero = [SELECT Id FROM GRR_Carga__c WHERE Id = :idfichero];
        GRR_UR__c ur = [SELECT Id, GRR_Id_UR__c FROM GRR_UR__c WHERE Id = :urid];
        GRR_RegistroCarga__c registroCarga = new GRR_RegistroCarga__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Acta_comite'),
            GRR_Fichero__c = fichero.Id,
            GRR_UR__c = ur.Id,
            GRR_CodigoUR__c = ur.GRR_Id_UR__c,
            GRR_CodigoOficina__c = '1234',
            GRR_Provincia__c = 'Barcelona',
            GRR_CodigoDT__c = '9097',
            GRR_GRR__c = 'Sí', 
            GRR_Vulnerabilidad__c = 'COVID',
            GRR_Departamento__c = 'Morosidad',
            GRR_Motivos__c = 'No Colabora',
            GRR_Direccion__c = 'Test Dirección GRR', 
            GRR_Poblacion__c = 'Barcelona',
            GRR_Comunidad__c = 'Catalunya',
            GRR_ObservacionesCP__c = 'Test ObservacionsCP GRR',
            GRR_ComentariosSancionBC__c = 'Test Comentarios Sanción GRR'
        );
        registrosInsert.add(registroCarga);

        GRR_RegistroCarga__c registroCarga2 = new GRR_RegistroCarga__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Acta_comite'),
            GRR_Fichero__c = fichero.Id,
            GRR_UR__c = ur.Id,
            GRR_CodigoUR__c = ur.GRR_Id_UR__c,
            GRR_CodigoOficina__c = '1234',
            GRR_Provincia__c = 'SDNO',
            GRR_GRR__c = 'Sí', 
            GRR_Vulnerabilidad__c = 'COVID',
            GRR_Departamento__c = 'Morosidad',
            GRR_Motivos__c = '',
            GRR_Direccion__c = 'Test Dirección GRR 2', 
            GRR_Poblacion__c = 'Fuenlabrada',
            GRR_Comunidad__c = 'Comunidad de Madrid',
            GRR_ObservacionesCP__c = 'Test ObservacionsCP GRR 2',
            GRR_ComentariosSancionBC__c = 'Test Comentarios Sanción GRR 2'
        );
        registrosInsert.add(registroCarga2);

        insert registrosInsert;
    }

    private static GRR_Carga__c crearFicheroHistorico() {
        GRR_Carga__c fichero = new GRR_Carga__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_Carga__c', 'GRR_Carga'),
            GRR_NombreDelFichero__c = 'Fichero prueba 3',
            GRR_TipoDeFichero__c = 'Histórico'
        );
        insert fichero;
        return fichero;
    }

    private static GRR_RegistroCarga__c crearRegistroHistorico(String idfichero, String urid) {
        GRR_Carga__c fichero = [SELECT Id FROM GRR_Carga__c WHERE Id = :idfichero];
        GRR_UR__c ur = [SELECT Id, GRR_Id_UR__c FROM GRR_UR__c WHERE Id = :urid];
        GRR_RegistroCarga__c registroCarga = new GRR_RegistroCarga__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Historico'),
            GRR_Fichero__c = fichero.Id,
            GRR_UR__c = ur.Id,
            GRR_CodigoUR__c = ur.GRR_Id_UR__c,
            GRR_CodigoOficina__c = '1234',
            GRR_Provincia__c = 'MURCIA',
            GRR_NIFs_Con_RR__c = '1234567Z',
            GRR_NIF__c = '1234567D',
            GRR_GRR__c = 'Sí',
            GRR_Informacion_Cliente__c = 'Test Información Cliente GRR'
        );
        insert registroCarga;
        return registroCarga;
    }

    @isTest
    public static void testGetListadoRegistros() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            GRR_UR__c ur = crearUR();
            GRR_Carga__c fichero = crearFicheroRecobro();
            GRR_RegistroCarga__c registroCarga = crearRegistroCargaRecobro(fichero.Id, ur.Id);

            Test.startTest();
            List<GRR_RegistroCarga__c> lstRegistrosCarga = GRR_Convertir_Registro_Caso_Controller.getListadoRegistros(fichero.Id);
            Test.stopTest();
            
            System.assertEquals(false, lstRegistrosCarga.isEmpty());
        }
    }
    
    @isTest
    public static void testGetGruposUsuario() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];
        
        System.runAs(usuario) {

            Test.startTest();
            List<GRR_Convertir_Registro_Caso_Controller.pickListWrapper> gruposUsuario = GRR_Convertir_Registro_Caso_Controller.getGruposUsuario();
            Test.stopTest();
            
            System.assertEquals(false, gruposUsuario.isEmpty());
        }
    }

    @isTest
    public static void testGenerarCasosRecobros() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];
        
        System.runAs(usuario) {
            crearCuenta();
            crearMCCRecobro();
            GRR_UR__c ur = crearUR();
            GRR_Carga__c fichero = crearFicheroRecobro();
            GRR_RegistroCarga__c registroCarga = crearRegistroCargaRecobro(fichero.Id, ur.Id);
            GRR_RegistroCarga__c registroCarga2 = crearRegistroCargaRecobro(fichero.Id, ur.Id);
            String procedencia = 'DT Ebro';
            registroCarga2.GRR_NIFs_Con_RR__c = '1234567D';
            registroCarga2.GRR_NIF__c = '1234567Z';
            update registroCarga2;
            Map<String, String> mapaRegistrosCarga = new Map<String, String>();
            List<Map<String, String>> lstMapaRegistrosCarga = new List<Map<String, String>>();
            List<GRR_RegistroCarga__c> lstRegistrosCarga = [SELECT Id, GRR_Caso__c, RecordTypeId, GRR_Fichero__c, GRR_UR__c, RecordType.Name, GRR_CodigoOficina__c, GRR_NIFs_Con_RR__c, GRR_Provincia__c, GRR_NIF__c FROM GRR_RegistroCarga__c];
            for (GRR_RegistroCarga__c registro : lstRegistrosCarga) {
                mapaRegistrosCarga.put('Id', registro.Id);
                mapaRegistrosCarga.put('GRR_Caso__c', null);
                mapaRegistrosCarga.put('RecordTypeId', registro.RecordTypeId);
                mapaRegistrosCarga.put('RecordTypeName', registro.RecordType.Name);
                mapaRegistrosCarga.put('GRR_Provincia__c', registro.GRR_Provincia__c);
                mapaRegistrosCarga.put('GRR_UR__c', registro.GRR_UR__c);
                mapaRegistrosCarga.put('GRR_Fichero__c',registro.GRR_Fichero__c);
                mapaRegistrosCarga.put('Name',null);
                mapaRegistrosCarga.put('GRR_GRR__c', null);
                mapaRegistrosCarga.put('GRR_Vulnerabilidad__c',null);
                mapaRegistrosCarga.put('GRR_Departamento__c', null);
                mapaRegistrosCarga.put('GRR_Motivos__c', null);
                mapaRegistrosCarga.put('GRR_Direccion__c', null);
                mapaRegistrosCarga.put('GRR_Poblacion__c', null);
                mapaRegistrosCarga.put('GRR_Comunidad__c', null);
                mapaRegistrosCarga.put('GRR_CodigoOficina__c', registro.GRR_CodigoOficina__c);
                mapaRegistrosCarga.put('GRR_CodigoDAN__c',null);
                mapaRegistrosCarga.put('GRR_CodigoDT__c',null);
                mapaRegistrosCarga.put('GRR_NIF__c', registro.GRR_NIF__c);
                mapaRegistrosCarga.put('GRR_Intervinientes__c',null);
                mapaRegistrosCarga.put('GRR_NIFs_Con_RR__c', registro.GRR_NIFs_Con_RR__c);
                mapaRegistrosCarga.put('GRR_Intervinientes_Con_RR__c',null);
                mapaRegistrosCarga.put('GRR_Informacion_Cliente__c',null);
                mapaRegistrosCarga.put('GRR_ObservacionesCP__c', null);
                mapaRegistrosCarga.put('GRR_ComentariosSancionBC__c', null);
                lstMapaRegistrosCarga.add(mapaRegistrosCarga);
                mapaRegistrosCarga = new Map<String, String>();
            }

            Test.startTest();
            String resultado = GRR_Convertir_Registro_Caso_Controller.validarMultiplesRegistros(fichero, lstMapaRegistrosCarga, procedencia);
            Test.stopTest();
            
            System.assertEquals('Han sido generados correctamente todos los casos solicitados (2)', resultado);
        }
    }
    

    @isTest
    public static void testGenerarCasosActasComite() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];

        System.runAs(usuario) {        
            GRR_UR__c ur = crearUR();
            crearListaExcepciones();
            GRR_Carga__c fichero = crearFicheroActaComite();
            crearRegistrosCargaActaComite(fichero.Id, ur.Id);
            Map<String, String> mapaRegistrosCarga = new Map<String, String>();
            List<Map<String, String>> lstMapaRegistrosCarga = new List<Map<String, String>>();
            List<GRR_RegistroCarga__c> lstRegistrosCarga = [SELECT Id, GRR_Caso__c, RecordTypeId, GRR_Fichero__c, GRR_UR__c, RecordType.Name, GRR_GRR__c, GRR_Vulnerabilidad__c,
                                                            GRR_Departamento__c, GRR_Motivos__c, GRR_Direccion__c, GRR_Poblacion__c, GRR_Comunidad__c, GRR_Provincia__c, GRR_CodigoOficina__c,
                                                            GRR_ObservacionesCP__c, GRR_ComentariosSancionBC__c, GRR_CodigoDT__c FROM GRR_RegistroCarga__c];
            
            for (GRR_RegistroCarga__c registro : lstRegistrosCarga) {
                mapaRegistrosCarga.put('Id', registro.Id);
                mapaRegistrosCarga.put('GRR_Caso__c', registro.GRR_Caso__c);
                mapaRegistrosCarga.put('RecordTypeId', registro.RecordTypeId);
                mapaRegistrosCarga.put('RecordTypeName', registro.RecordType.Name);
                mapaRegistrosCarga.put('GRR_Provincia__c', registro.GRR_Provincia__c);
                mapaRegistrosCarga.put('GRR_UR__c', registro.GRR_UR__c);
                mapaRegistrosCarga.put('GRR_Fichero__c',registro.GRR_Fichero__c);
                mapaRegistrosCarga.put('Name',null);
                mapaRegistrosCarga.put('GRR_GRR__c', registro.GRR_GRR__c);
                mapaRegistrosCarga.put('GRR_Vulnerabilidad__c',registro.GRR_Vulnerabilidad__c);
                mapaRegistrosCarga.put('GRR_Departamento__c', registro.GRR_Departamento__c);
                mapaRegistrosCarga.put('GRR_Motivos__c', registro.GRR_Motivos__c);
                mapaRegistrosCarga.put('GRR_Direccion__c', registro.GRR_Direccion__c);
                mapaRegistrosCarga.put('GRR_Poblacion__c',registro.GRR_Poblacion__c);
                mapaRegistrosCarga.put('GRR_Comunidad__c',registro.GRR_Comunidad__c);
                mapaRegistrosCarga.put('GRR_CodigoOficina__c',registro.GRR_CodigoOficina__c);
                mapaRegistrosCarga.put('GRR_CodigoDAN__c',null);
                mapaRegistrosCarga.put('GRR_CodigoDT__c', registro.GRR_CodigoDT__c);
                mapaRegistrosCarga.put('GRR_NIF__c',null);
                mapaRegistrosCarga.put('GRR_Intervinientes__c',null);
                mapaRegistrosCarga.put('GRR_NIFs_Con_RR__c',null);
                mapaRegistrosCarga.put('GRR_Intervinientes_Con_RR__c',null);
                mapaRegistrosCarga.put('GRR_Informacion_Cliente__c',null);
                mapaRegistrosCarga.put('GRR_ObservacionesCP__c',registro.GRR_ObservacionesCP__c);
                mapaRegistrosCarga.put('GRR_ComentariosSancionBC__c',registro.GRR_ComentariosSancionBC__c);
                
                lstMapaRegistrosCarga.add(mapaRegistrosCarga);
                mapaRegistrosCarga = new Map<String, String>();
            } 
            crearMCCsActaComite();

            Test.startTest();
            String resultado = GRR_Convertir_Registro_Caso_Controller.validarMultiplesRegistros(fichero, lstMapaRegistrosCarga, null);
            Test.stopTest();
            
            System.assertEquals('Han sido generados correctamente todos los casos solicitados (2)', resultado);       
        }
    }

    @isTest
    public static void testGenerarCasosHistorico() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];

        System.runAs(usuario) {
            GRR_UR__c ur = crearUR();
            GRR_Carga__c fichero = crearFicheroHistorico();
            GRR_RegistroCarga__c registroCarga = crearRegistroHistorico(fichero.Id, ur.Id);
            Map<String, String> mapaRegistrosCarga = new Map<String, String>();
            List<Map<String, String>> lstMapaRegistrosCarga = new List<Map<String, String>>();
            List<GRR_RegistroCarga__c> lstRegistrosCarga = [SELECT Id, GRR_Caso__c, RecordTypeId, RecordType.Name, GRR_Provincia__c, GRR_UR__c, GRR_CodigoOficina__c, GRR_NIF__c, GRR_Informacion_Cliente__c FROM GRR_RegistroCarga__c];
            for (GRR_RegistroCarga__c registro : lstRegistrosCarga) {
                mapaRegistrosCarga.put('Id', registro.Id);
                mapaRegistrosCarga.put('GRR_Caso__c', registro.GRR_Caso__c);
                mapaRegistrosCarga.put('RecordTypeId', registro.RecordTypeId);
				mapaRegistrosCarga.put('RecordTypeName', registro.RecordType.Name);
                mapaRegistrosCarga.put('GRR_Provincia__c', registro.GRR_Provincia__c);
                mapaRegistrosCarga.put('GRR_UR__c', registro.GRR_UR__c);
                mapaRegistrosCarga.put('GRR_Fichero__c',null);
                mapaRegistrosCarga.put('Name',null);
                mapaRegistrosCarga.put('GRR_GRR__c',null);
                mapaRegistrosCarga.put('GRR_Vulnerabilidad__c',null);
                mapaRegistrosCarga.put('GRR_Departamento__c',null);
                mapaRegistrosCarga.put('GRR_Motivos__c',null);
                mapaRegistrosCarga.put('GRR_Direccion__c',null);
                mapaRegistrosCarga.put('GRR_Poblacion__c',null);
                mapaRegistrosCarga.put('GRR_Comunidad__c',null);
                mapaRegistrosCarga.put('GRR_CodigoOficina__c', registro.GRR_CodigoOficina__c);
                mapaRegistrosCarga.put('GRR_CodigoDAN__c',null);
                mapaRegistrosCarga.put('GRR_CodigoDT__c',null);
                mapaRegistrosCarga.put('GRR_NIF__c', registro.GRR_NIF__c);
                mapaRegistrosCarga.put('GRR_Intervinientes__c',null);
                mapaRegistrosCarga.put('GRR_NIFs_Con_RR__c',null);
                mapaRegistrosCarga.put('GRR_Intervinientes_Con_RR__c',null);
				mapaRegistrosCarga.put('GRR_Informacion_Cliente__c', registro.GRR_Informacion_Cliente__c);
                mapaRegistrosCarga.put('GRR_ObservacionesCP__c', null);
                mapaRegistrosCarga.put('GRR_ComentariosSancionBC__c', null);
                lstMapaRegistrosCarga.add(mapaRegistrosCarga);
            }

            Test.startTest();
            String resultado = GRR_Convertir_Registro_Caso_Controller.validarRegistroIndividual(lstMapaRegistrosCarga);
            Test.stopTest();
            
            System.assertEquals('Han sido generados correctamente todos los casos solicitados (1)', resultado);
        }
    }
}