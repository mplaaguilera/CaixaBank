@isTest
public class SAC_PrestamoRelacionBatchTest {
    private final static Id RECORDTYPEPRESTAMO = Schema.SObjectType.SAC_Prestamo__c.getRecordTypeInfosByDeveloperName().get('SAC_Prestamo').getRecordTypeId();
    private final static Id RECORDTYPETITULAR = Schema.SObjectType.SAC_Prestamo__c.getRecordTypeInfosByDeveloperName().get('SAC_Titular_Prestamo').getRecordTypeId();

    @testSetup
    static void setupData() {
        Id recType = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        String profileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];
        // Account
        Account cuenta = new Account();
        cuenta.Name = 'cuentaTest';
        cuenta.CC_Tipo_Centro__c = 'DT';
        cuenta.CC_NumPerso__c = '123456789';
        insert cuenta;
        // Grupo colaborador
        List<CC_Grupo_Colaborador__c> grupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
        grupoColaborador.name = 'grupoColaboradorTest';
        grupoColaborador.RecordTypeId = recType;
        grupoColaborador.SAC_PorcentajeAsignacion__c = 100;
        grupoColaborador.SAC_MaximoCasosDiarios__c = 30;
        grupos.add(grupoColaborador);
        insert grupos;
        // User
        User usuarioGeneral = new User();
        usuarioGeneral.Username = 'userSACgeneral01@test.com';
        usuarioGeneral.Email = 'email@test.com';
        usuarioGeneral.LastName = 'usuarioGeneral Test';
        usuarioGeneral.ProfileId = profileId;
        usuarioGeneral.Alias = 'alias';
        usuarioGeneral.TimeZoneSidKey = 'GMT';
        usuarioGeneral.LocaleSidKey = 'es_ES';
        usuarioGeneral.EmailEncodingKey = 'ISO-8859-1';
        usuarioGeneral.LanguageLocaleKey = 'en_US';
        usuarioGeneral.SAC_GruposPerteneciente__c = grupoColaborador.id;
        usuarioGeneral.isActive = true;
        usuarioGeneral.userRole = uRole; 
        insert usuarioGeneral;
        // MCCs
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();        
        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = recordTem;
        tematica.Name = 'A. OPERACIONES DE ACTIVO';
        tematica.CC_Tipo_Cliente__c = 'Cliente';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        tematica.CC_Canal_Operativo__c = 'App Imagin';
        insert tematica;
        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = recordProd;
        productoServicio.Name = 'Créditos Hipotecarios Interés Variable';
        productoServicio.CC_Detalle__c = 'CaixaBank';
        productoServicio.CC_Tipo_Cliente__c = 'Cliente';
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001';
        insert productoServicio;
        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = recordMot;
        motivo.Name = '6. Multiquejas';
        motivo.CC_Tipo_Cliente__c = 'Cliente';
        motivo.CC_Producto_Servicio__c = productoServicio.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001';
        insert motivo;  
        CC_MCC__c detalle = new CC_MCC__c();
        detalle.RecordTypeId = recordDet;
        detalle.Name = 'Multiqueja: Gastos Constitución / Otras Abusivas';
        detalle.CC_Tipo_Cliente__c = 'SAC';
        detalle.CC_Codigo_Externo__c = 'DE-000001';
        insert detalle; 
        // Reclamación
        Case reclamacion = new Case();
        reclamacion.Subject = 'ReclamacionTest';
        reclamacion.Status = 'SAC_001';
        reclamacion.SAC_StatusAuxiliar__c = reclamacion.Status;
        reclamacion.SEG_Grupo__c = grupoColaborador.id;
        reclamacion.AccountId = cuenta.Id;
        reclamacion.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        reclamacion.OwnerId = usuarioGeneral.Id;
        reclamacion.SAC_FechaRecepcion__c = System.today();
        reclamacion.CC_MCC_Tematica__c = tematica.Id;
        reclamacion.CC_MCC_ProdServ__c = productoServicio.Id;
        reclamacion.CC_MCC_Motivo__c = motivo.Id;
        reclamacion.SEG_Detalle__c = detalle.Id;
        reclamacion.CC_Idioma__c = 'es';
        insert reclamacion; 
        
        System.runAs(usuarioGeneral){
            // Préstamos
            SAC_Prestamo__c prestamo = new SAC_Prestamo__c(
                SAC_Id_persona_en_Origen__c = cuenta.CC_NumPerso__c, SAC_Codigo_Contrato_TF7__c = '1234-123-1234567-10',
                SAC_Codigo_Contrato__c = '000001', SAC_Id_cuenta_actual__c = '000002', SAC_Codigo_CNAE__c = '12', SAC_Empleado__c = false,
                SAC_Provincia_centro_gestor__c = 'Barcelona', SAC_Fecha_cancelacion_real_prestamo__c = System.today(),
                RecordTypeId = RECORDTYPEPRESTAMO
            );
            SAC_Prestamo__c titularCuenta = new SAC_Prestamo__c(
                SAC_Id_persona_en_Origen__c = cuenta.CC_NumPerso__c, SAC_Codigo_Contrato_TF7__c = '1234-123-1234567-12',
                SAC_Id_cuenta_actual__c = '000002', SAC_Codigo_CNAE__c = '99', SAC_Codigo_Tipo_Convenio__c = 'BONHOE',
                SAC_Provincia_centro_gestor__c = 'Barcelona', SAC_Fecha_cancelacion_real_prestamo__c = System.today(),
                RecordTypeId = RECORDTYPETITULAR
            );
            SAC_Prestamo__c titularCuenta2 = new SAC_Prestamo__c(
                SAC_Id_persona_en_Origen__c = cuenta.CC_NumPerso__c, SAC_Codigo_Contrato_TF7__c = '1234-123-1234567-11',
                SAC_Id_cuenta_actual__c = '000002', SAC_Codigo_CNAE__c = '99', SAC_Codigo_Tipo_Convenio__c = 'BONHOE',
                SAC_Provincia_centro_gestor__c = 'Barcelona', SAC_Fecha_cancelacion_real_prestamo__c = System.today(),
                RecordTypeId = RECORDTYPETITULAR
            );
            SAC_Prestamo__c titularPrestamo = new SAC_Prestamo__c(
                SAC_Id_persona_en_Origen__c = cuenta.CC_NumPerso__c, SAC_Codigo_Contrato_TF7__c = '1234-123-1234567-13',
                SAC_Codigo_Contrato__c = '000001', SAC_Codigo_CNAE__c = '99', SAC_Empleado__c = false,
                SAC_Provincia_centro_gestor__c = 'Barcelona', SAC_Fecha_cancelacion_real_prestamo__c = System.today().addYears(-11),
                RecordTypeId = RECORDTYPETITULAR
            );
            SAC_Prestamo__c titularPrestamo2 = new SAC_Prestamo__c(
                SAC_Id_persona_en_Origen__c = cuenta.CC_NumPerso__c, SAC_Codigo_Contrato_TF7__c = '1234-123-1234567-14',
                SAC_Codigo_Contrato__c = '000001', SAC_Codigo_CNAE__c = '99', SAC_Empleado__c = false,
                SAC_Provincia_centro_gestor__c = 'Barcelona', SAC_Fecha_cancelacion_real_prestamo__c = System.today().addYears(-11),
                RecordTypeId = RECORDTYPETITULAR
            );
            insert new List<SAC_Prestamo__c>{prestamo, titularCuenta, titularCuenta2, titularPrestamo, titularPrestamo2};
                }
    }
    
	@isTest
    static void checkPrestamosWithoutRelations(){
                User usuario = [SELECT  Id FROM User WHERE Username = 'userSACgeneral01@test.com' AND isActive = true LIMIT 1];
        List<SAC_Prestamo__c> prestamoList = [SELECT Id, SAC_Id_cuenta_actual__c, SAC_Codigo_Contrato__c FROM SAC_Prestamo__c];
        System.runAs(usuario){
            SAC_PrestamoRelacionBatch btch = new SAC_PrestamoRelacionBatch();
            Test.startTest();
            btch.execute(null, prestamoList);
            Test.stopTest();
        }
        // Asserts
        List<SAC_Prestamo_Titular__c> result = [SELECT Id FROM SAC_Prestamo_Titular__c];
        System.assertEquals(!result.isEmpty(), true, 'La lista contiene registros de Préstamo Titular.');
    }
    
    @isTest
    static void checkPrestamosWithRelations(){
        User usuario = [SELECT  Id FROM User WHERE Username = 'userSACgeneral01@test.com' AND isActive = true LIMIT 1];
		List<SAC_Prestamo_Titular__c> relationsToCreate = new List<SAC_Prestamo_Titular__c>();
        List<SAC_Prestamo__c> pretamoList = [SELECT Id, SAC_Id_persona_en_Origen__c, SAC_Id_cuenta_actual__c, SAC_Codigo_Contrato__c FROM SAC_Prestamo__c WHERE RecordTypeId =: RECORDTYPEPRESTAMO LIMIT 2];
        List<SAC_Prestamo__c> titularesList = [SELECT Id, SAC_Id_persona_en_Origen__c, SAC_Id_cuenta_actual__c, SAC_Codigo_Contrato__c FROM SAC_Prestamo__c WHERE RecordTypeId =: RECORDTYPETITULAR LIMIT 2];
        for(SAC_Prestamo__c prestamo: pretamoList){
            SAC_Prestamo_Titular__c relation = new SAC_Prestamo_Titular__c();
            relation.SAC_Prestamo__c = prestamo.Id;
            relation.SAC_Titular__c = titularesList[0].Id;
            relationsToCreate.add(relation);
        }
        System.runAs(usuario){
            insert relationsToCreate;
            SAC_PrestamoRelacionBatch btch = new SAC_PrestamoRelacionBatch();
            Test.startTest();
            btch.execute(null, pretamoList);
            Test.stopTest();
        }
        // Asserts
        List<SAC_Prestamo_Titular__c> result = [SELECT Id FROM SAC_Prestamo_Titular__c];
        System.assertEquals(!result.isEmpty(), true, 'La lista contiene registros de Préstamo Titular.');
    }
}