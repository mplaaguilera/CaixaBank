/*
* @description: SAC_LCMP_PrestamoGlobal test class
* @author: iria.alvarez.novoa@ibm.com
* @date: september 2024
*/
@isTest
public class SAC_LCMP_PrestamoGlobalTest {
    private final static Id RECORDTYPEPRESTAMO = Schema.SObjectType.SAC_Prestamo__c.getRecordTypeInfosByDeveloperName().get('SAC_Prestamo').getRecordTypeId();
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
        // Reclamación Anterior
        Case reclamacionAnterior = new Case();
        reclamacionAnterior.Subject = 'ReclamacionAnteriorTest';
        reclamacionAnterior.Status = 'SAC_001';
        reclamacionAnterior.SAC_StatusAuxiliar__c = reclamacionAnterior.Status;
        reclamacionAnterior.SEG_Grupo__c = grupoColaborador.id;
        reclamacionAnterior.AccountId = cuenta.Id;
        reclamacionAnterior.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        reclamacionAnterior.OwnerId = usuarioGeneral.Id;
        reclamacionAnterior.SAC_FechaRecepcion__c = System.today().addDays(-1);
        reclamacionAnterior.CC_MCC_Tematica__c = tematica.Id;
        reclamacionAnterior.CC_MCC_ProdServ__c = productoServicio.Id;
        reclamacionAnterior.CC_MCC_Motivo__c = motivo.Id;
        reclamacionAnterior.SEG_Detalle__c = detalle.Id;
        insert reclamacionAnterior;
        // Antecedentes
        SAC_Antecedentes__c antecedente = new SAC_Antecedentes__c();
        antecedente.SAC_RelacionHistRecCaso__c = reclamacion.Id;
        antecedente.SAC_FechaAlta__c = System.today();
        antecedente.SAC_ProductoServicio__c = productoServicio.Name;
        antecedente.SAC_Detalle__c = detalle.Name;
        insert antecedente;
        // DocumentoEnvio
        List<SAC_DocumentoEnvio__c> docEnvio = SAC_TestDataFactory.crearDocumentoEnvio(1, reclamacion);
        docEnvio[0].Name = 'TestDocumentoEnvio';
        docEnvio[0].SAC_Documento__c = null;
        docEnvio[0].SAC_TipoDocumento__c = 'inadmision - prestamo';
        insert docEnvio[0];  
        // ContentVersion
        ContentVersion doc = new ContentVersion();
        doc.Title = 'Test';
        doc.SAC_ValidadoCV__c = true;
        doc.FirstPublishLocationId = reclamacion.Id;
        doc.PathOnClient = 'Test';
        doc.VersionData = Blob.valueOf('Test Content');
        insert doc;
        // Plantillas SAC
        SAC_PlantillaRedaccion__c plantilla = new SAC_PlantillaRedaccion__c();
        plantilla.Name = 'Plantilla';
        plantilla.SAC_PlantillaCastellanoId__c = null;
        plantilla.SAC_TipoPlantilla__c = 'SAC_ResolucionExpress';
        insert plantilla;
        
        System.runAs(usuarioGeneral){
            // Préstamos
            SAC_Prestamo__c prestamoNoConsumidor = new SAC_Prestamo__c(
                SAC_Id_persona_en_Origen__c = cuenta.CC_NumPerso__c, SAC_Codigo_Contrato_TF7__c = '1234-123-1234567-11',
                RecordTypeId = RECORDTYPEPRESTAMO,
                SAC_Codigo_Contrato__c = '000001', SAC_Codigo_CNAE__c = '12', SAC_Empleado__c = false,
                SAC_Provincia_centro_gestor__c = 'Barcelona', SAC_Fecha_cancelacion_real_prestamo__c = System.today()
            );
            SAC_Prestamo__c prestamoEmpleados = new SAC_Prestamo__c(
                SAC_Id_persona_en_Origen__c = cuenta.CC_NumPerso__c, SAC_Codigo_Contrato_TF7__c = '1234-123-1234567-12',
                RecordTypeId = RECORDTYPEPRESTAMO,
                SAC_Codigo_Contrato__c = '000002', SAC_Codigo_CNAE__c = '99', SAC_Codigo_Tipo_Convenio__c = 'BONHOE',
                SAC_Provincia_centro_gestor__c = 'Barcelona', SAC_Fecha_cancelacion_real_prestamo__c = System.today()
            );
            SAC_Prestamo__c prestamoCatalunyaPrescripcion = new SAC_Prestamo__c(
                SAC_Id_persona_en_Origen__c = cuenta.CC_NumPerso__c, SAC_Codigo_Contrato_TF7__c = '1234-123-1234567-13',
                RecordTypeId = RECORDTYPEPRESTAMO,
                SAC_Codigo_Contrato__c = '000003', SAC_Codigo_CNAE__c = '99', SAC_Empleado__c = false,
                SAC_Provincia_centro_gestor__c = 'Barcelona', SAC_Fecha_cancelacion_real_prestamo__c = System.today().addYears(-11)
            );
            SAC_Prestamo__c prestamoNavarraPrescripcion = new SAC_Prestamo__c(
                SAC_Id_persona_en_Origen__c = cuenta.CC_NumPerso__c, SAC_Codigo_Contrato_TF7__c = '1234-123-1234567-14',
                RecordTypeId = RECORDTYPEPRESTAMO,
                SAC_Codigo_Contrato__c = '000004', SAC_Codigo_CNAE__c = '99', SAC_Empleado__c = false,
                SAC_Provincia_centro_gestor__c = 'Navarra', SAC_Fecha_cancelacion_real_prestamo__c = System.today().addYears(-31)
            );
            SAC_Prestamo__c prestamoOthersPrescripcion = new SAC_Prestamo__c(
                SAC_Id_persona_en_Origen__c = cuenta.CC_NumPerso__c, SAC_Codigo_Contrato_TF7__c = '1234-123-1234567-15',
                RecordTypeId = RECORDTYPEPRESTAMO,
                SAC_Codigo_Contrato__c = '000005', SAC_Codigo_CNAE__c = '99', SAC_Empleado__c = false,
                SAC_Provincia_centro_gestor__c = 'Pontevedra', SAC_Fecha_cancelacion_real_prestamo__c = System.today().addYears(-11)
            );
            insert new List<SAC_Prestamo__c>{prestamoNoConsumidor, prestamoEmpleados, prestamoCatalunyaPrescripcion, prestamoNavarraPrescripcion, prestamoOthersPrescripcion};
                }
    }
    @isTest
    static void testCNAE() {
        String validation;
        Boolean showButton;
        Boolean docExists;
        Boolean hasPermission;
        Boolean prestamosExist;
        // Get Reclamación, User and Préstamo
        Case reclamacion = [SELECT Id, AccountId, OwnerId FROM Case WHERE AccountId != null AND Subject = 'ReclamacionTest' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE Username = 'userSACgeneral01@test.com' AND isActive = true LIMIT 1];
        SAC_Prestamo__c prestamo = [SELECT Id, SAC_Codigo_CNAE__c, SAC_Operacion_Empleado__c, SAC_Provincia_centro_gestor__c, SAC_Fecha_cancelacion_real_prestamo__c, SAC_Codigo_Contrato_TF7__c 
                                    FROM SAC_Prestamo__c WHERE SAC_Codigo_Contrato__c = '000001' LIMIT 1];
                
        System.runAs(usuario){
            Test.startTest();
            validation = SAC_LCMP_PrestamoGlobal.checkValidations(prestamo, System.today(), reclamacion.Id, reclamacion.AccountId);
            showButton = SAC_LCMP_PrestamoGlobal.inadmitirButtonVisibleOrHidden(reclamacion.Id, true);
            SAC_LCMP_PrestamoGlobal.lookupValues(reclamacion.Id);
            SAC_LCMP_PrestamoGlobal.motivoInadmision(reclamacion.Id, prestamo.Id);
            hasPermission = SAC_LCMP_PrestamoGlobal.recuperarPermiso(reclamacion);
            SAC_LCMP_PrestamoGlobal.obtenerPlantillaInadmision('es');
            SAC_LCMP_PrestamoGlobal.obtenerPlantillaInadmision('en');
            SAC_LCMP_PrestamoGlobal.obtenerPlantillaInadmision('ca');
            SAC_LCMP_PrestamoGlobal.obtenerPlantillaInadmision('va');
            SAC_LCMP_PrestamoGlobal.obtenerPlantillaInadmision('eu');
            SAC_LCMP_PrestamoGlobal.obtenerPlantillaInadmision('ga');
            SAC_LCMP_PrestamoGlobal.obtenerPlantillaInadmision(null);
            docExists = SAC_LCMP_PrestamoGlobal.compruebaDocumentoInadmision(reclamacion.Id);
            SAC_LCMP_PrestamoGlobal.visualizarDocumentoInadmision(reclamacion.Id);
            SAC_LCMP_PrestamoGlobal.compruebaPDFs(reclamacion.Id);
            SAC_LCMP_PrestamoGlobal.getCVRespuestas(reclamacion.Id);
            prestamosExist = SAC_LCMP_PrestamoGlobal.checkPrestamos(reclamacion.Id);
            Test.stopTest();
        }
        List<SAC_PlantillaRedaccion__c> plantillas = [SELECT Id FROM SAC_PlantillaRedaccion__c];
        // Asserts
        System.assertEquals(validation, 'No consumidor', 'Se cumple el criterio de validación');
        System.assertEquals(!plantillas.isEmpty(), true, 'La lista no está vacía');
        System.assertEquals(docExists, true, 'Existe documento');
        System.assertEquals(hasPermission, true, 'El usuario tiene permiso para llevar a cabo la acción');
    }
    @isTest
    static void testEmpleados() {
        String validation;
        String motivoInadmision;
        // Get Reclamación, User and Préstamo
        Case reclamacion = [SELECT Id, AccountId, OwnerId FROM Case WHERE AccountId != null AND Subject = 'ReclamacionTest' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE Username = 'userSACgeneral01@test.com' AND isActive = true LIMIT 1];
        SAC_Prestamo__c prestamo = [SELECT Id, SAC_Codigo_CNAE__c, SAC_Operacion_Empleado__c, SAC_Provincia_centro_gestor__c, SAC_Fecha_cancelacion_real_prestamo__c, SAC_Codigo_Contrato_TF7__c 
                                    FROM SAC_Prestamo__c WHERE SAC_Codigo_Contrato__c = '000002' LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            validation = SAC_LCMP_PrestamoGlobal.checkValidations(prestamo, System.today(), reclamacion.Id, reclamacion.AccountId);
            motivoInadmision = SAC_LCMP_PrestamoGlobal.motivoInadmision(reclamacion.Id, prestamo.Id);
            Test.stopTest();
        }
        // Asserts
        System.assertEquals(validation, 'Empleados', 'Se cumple el criterio de validación');
        System.assertEquals(motivoInadmision, 'Empleados', 'El motivo de inadmisión es correcto');
    }
    @isTest
    static void testCatalunyaPrescripcion() {
        String validation;
        String motivoInadmision;
        // Get Reclamación, User and Préstamo
        Case reclamacion = [SELECT Id, AccountId, OwnerId FROM Case WHERE AccountId != null AND Subject = 'ReclamacionTest' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE Username = 'userSACgeneral01@test.com' AND isActive = true LIMIT 1];
        SAC_Prestamo__c prestamo = [SELECT Id, SAC_Codigo_CNAE__c, SAC_Operacion_Empleado__c, SAC_Provincia_centro_gestor__c, SAC_Fecha_cancelacion_real_prestamo__c, SAC_Codigo_Contrato_TF7__c 
                                    FROM SAC_Prestamo__c WHERE SAC_Codigo_Contrato__c = '000003' LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            validation = SAC_LCMP_PrestamoGlobal.checkValidations(prestamo, System.today(), reclamacion.Id, reclamacion.AccountId);
            motivoInadmision = SAC_LCMP_PrestamoGlobal.motivoInadmision(reclamacion.Id, prestamo.Id);
            SAC_LCMP_PrestamoGlobal.getReclamacionesAnterioresToShow(reclamacion.Id);
            SAC_LCMP_PrestamoGlobal.getAntecedentesToShow(reclamacion.Id);
            SAC_LCMP_PrestamoGlobal.getDemandasEntidadToShow(reclamacion.Id);
            SAC_LCMP_PrestamoGlobal.getDemandasMorosidadToShow(reclamacion.Id);
            SAC_LCMP_PrestamoGlobal.getConcursosToShow(reclamacion.Id);
            Test.stopTest();
        }
        // Asserts
        System.assertEquals(validation, 'Prescripción', 'Se cumple el criterio de validación');
        System.assertEquals(motivoInadmision, 'Prescripción', 'El motivo de inadmisión es correcto');
    }
    @isTest
    static void testNavarraPrescripcion() {
        String validation;
        String motivoInadmision;
        // Get Reclamación, User and Préstamo
        Case reclamacion = [SELECT Id, AccountId, OwnerId FROM Case WHERE AccountId != null AND Subject = 'ReclamacionTest' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE Username = 'userSACgeneral01@test.com' AND isActive = true LIMIT 1];
        SAC_Prestamo__c prestamo = [SELECT Id, SAC_Codigo_CNAE__c, SAC_Operacion_Empleado__c, SAC_Provincia_centro_gestor__c, SAC_Fecha_cancelacion_real_prestamo__c, SAC_Codigo_Contrato_TF7__c 
                                    FROM SAC_Prestamo__c WHERE SAC_Codigo_Contrato__c = '000004' LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            validation = SAC_LCMP_PrestamoGlobal.checkValidations(prestamo, System.today(), reclamacion.Id, reclamacion.AccountId);
            motivoInadmision = SAC_LCMP_PrestamoGlobal.motivoInadmision(reclamacion.Id, prestamo.Id);
            Test.stopTest();
        }
        // Asserts
        System.assertEquals(validation, 'Prescripción', 'Se cumple el criterio de validación');
        System.assertEquals(motivoInadmision, 'Prescripción', 'El motivo de inadmisión es correcto');
    }
    @isTest
    static void testOtherPrescripcion() {
        String validation;
        String motivoInadmision;
        // Get Reclamación, User and Préstamo
        Case reclamacion = [SELECT Id, AccountId, OwnerId FROM Case WHERE AccountId != null AND Subject = 'ReclamacionTest' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE Username = 'userSACgeneral01@test.com' AND isActive = true LIMIT 1];
        SAC_Prestamo__c prestamo = [SELECT Id, SAC_Codigo_CNAE__c, SAC_Operacion_Empleado__c, SAC_Provincia_centro_gestor__c, SAC_Fecha_cancelacion_real_prestamo__c, SAC_Codigo_Contrato_TF7__c 
                                    FROM SAC_Prestamo__c WHERE SAC_Codigo_Contrato__c = '000005' LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            validation = SAC_LCMP_PrestamoGlobal.checkValidations(prestamo, System.today(), reclamacion.Id, reclamacion.AccountId);
            motivoInadmision = SAC_LCMP_PrestamoGlobal.motivoInadmision(reclamacion.Id, prestamo.Id);
            Test.stopTest();
        }
        // Asserts
        System.assertEquals(validation, 'Prescripción', 'Se cumple el criterio de validación');
        System.assertEquals(motivoInadmision, 'Prescripción', 'El motivo de inadmisión es correcto');
    }
    @isTest
    static void obtenerDatosEmailTest(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'ReclamacionTest' LIMIT 1];
        SAC_LCMP_RedaccionFinal.DatosEmailWrapper informacion;
        User usuario = [SELECT Id FROM User WHERE Username = 'userSACgeneral01@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuario){
            Test.startTest();
            reclamacion.CC_Canal_Respuesta__c = 'Email';
            update reclamacion;
            informacion = SAC_LCMP_PrestamoGlobal.obtenerDatosEmailInadmision(reclamacion.Id);
            Test.stopTest();
        }
        System.assertNotEquals(informacion, null, 'El objeto wrapper con datos del email no se ha instanciado correctamente.');
    }
    @isTest
    static void generarDocumentoInadmision(){
        Case reclamacion = [SELECT Id, AccountId, OwnerId FROM Case WHERE AccountId != null LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE Username = 'userSACgeneral01@test.com' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_PrestamoGlobal.generarDocumentoInadmision(reclamacion.Id, 'es');
            Test.stopTest();
        }
        List<SAC_DocumentoEnvio__c> docList = [SELECT Id FROM SAC_DocumentoEnvio__c LIMIT 1];
        // Asserts
        System.assertEquals(docList.isEmpty(), false, 'La lista contiene elementos.');
    }
}