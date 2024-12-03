/*
* @description: SAC_VisualizacionPrestamos test class
* @author: iria.alvarez.novoa@ibm.com
* @date: august 2024
*/
@isTest
public class SAC_VisualizacionPrestamosTest {
    private final static Id RECORDTYPEPRESTAMO = Schema.SObjectType.SAC_Prestamo__c.getRecordTypeInfosByDeveloperName().get('SAC_Prestamo').getRecordTypeId();
    private final static Id RECORDTYPETITULARPRESTAMO = Schema.SObjectType.SAC_Prestamo__c.getRecordTypeInfosByDeveloperName().get('SAC_Titular_Prestamo').getRecordTypeId();
    private final static Id RECORDTYPETITULARCUENTA = Schema.SObjectType.SAC_Prestamo__c.getRecordTypeInfosByDeveloperName().get('SAC_Titular_Cuenta').getRecordTypeId();
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
        reclamacion.Status = 'Alta';
        reclamacion.SAC_StatusAuxiliar__c = reclamacion.Status;
        reclamacion.SEG_Grupo__c = grupoColaborador.id;
        reclamacion.AccountId = cuenta.Id;
        reclamacion.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        reclamacion.OwnerId = usuarioGeneral.Id;
        reclamacion.CC_MCC_Tematica__c = tematica.Id;
        reclamacion.CC_MCC_ProdServ__c = productoServicio.Id;
        reclamacion.CC_MCC_Motivo__c = motivo.Id;
        reclamacion.SEG_Detalle__c = detalle.Id;
        insert reclamacion;
        List<SAC_Prestamo_Titular__c> relationsToCreate = new List<SAC_Prestamo_Titular__c>();
        System.runAs(usuarioGeneral){
            // Préstamos
            SAC_Prestamo__c prestamo = new SAC_Prestamo__c(
                RecordTypeId = RECORDTYPEPRESTAMO, SAC_Id_cuenta_actual__c = '000002', SAC_Codigo_Contrato__c = '000001'
            );
            SAC_Prestamo__c titularPrestamo = new SAC_Prestamo__c(
                RecordTypeId = RECORDTYPETITULARPRESTAMO, SAC_Id_persona_en_Origen__c = cuenta.CC_NumPerso__c, SAC_Codigo_Contrato__c = '000001'            
            );
            SAC_Prestamo__c titularCuenta = new SAC_Prestamo__c(
                RecordTypeId = RECORDTYPETITULARCUENTA, SAC_Id_persona_en_Origen__c = cuenta.CC_NumPerso__c, SAC_Id_cuenta_actual__c = '000002'            
            );
            
            insert new List<SAC_Prestamo__c>{prestamo, titularPrestamo, titularCuenta};
            // Relations
            SAC_Prestamo_Titular__c relationPrestamo = new SAC_Prestamo_Titular__c();
            relationPrestamo.SAC_Prestamo__c = prestamo.Id;
            relationPrestamo.SAC_Titular__c = titularPrestamo.Id;
            relationsToCreate.add(relationPrestamo);
            SAC_Prestamo_Titular__c relationCuenta = new SAC_Prestamo_Titular__c();
            relationCuenta.SAC_Prestamo__c = prestamo.Id;
            relationCuenta.SAC_Titular__c = titularCuenta.Id;
            relationsToCreate.add(relationCuenta);
            insert relationsToCreate;
                }
    }
    @isTest
    static void testGetPrestamosByAccountIdWithAccount() {
        Boolean isMCC = false;
        // Get Reclamación, User and Préstamos
        Case reclamacion = [SELECT Id, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name, SEG_Detalle__r.Name FROM Case WHERE AccountId != null LIMIT 1];
        User usuario = [SELECT  Id FROM User WHERE Username = 'userSACgeneral01@test.com' AND isActive = true LIMIT 1];
        Map<String, List<SAC_VisualizacionPrestamos.PrestamoWrapper>> result = new  Map<String, List<SAC_VisualizacionPrestamos.PrestamoWrapper>>();
        System.runAs(usuario){
            Test.startTest();
            result = SAC_VisualizacionPrestamos.getPrestamosByAccountId(reclamacion.Id);
            isMCC = SAC_VisualizacionPrestamos.checkMCCs(reclamacion);
            Test.stopTest();
        }
        // Asserts
        System.assert(result.size() > 0, 'El resultado debería contener registros.');
        System.assertEquals(3, result.values().size(), 'Debería haber 3 ficheros en el resultado.');
        System.assertEquals(isMCC, true, 'El MCC forma parte del listado proporcionado por negocio.');
    }
}