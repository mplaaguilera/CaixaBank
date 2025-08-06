/***************************************************************************
 * Name: SAC_AuditoriaAutomatica_Test.cls
 * 
 * Proposito: Probar la clase SAC_AuditoriaAutomatica
 * 
 * Historial
 * VERSION        USER_STORY       AUTHOR           DATE         Description
 *  1.0            US791098      Raúl Santos      17/01/24         Creación          
***************************************************************************/

@isTest
public with sharing class SAC_AuditoriaAutomatica_Test {
   
    @TestSetup
    static void makeData() {
        Test.startTest();
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];

        //Usuario Admin
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        usuarioAdmin.SAC_PerteneceCOPSAJ__c = true;
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);  
        //Database.insert(usuarioAdmin);

        User usuario = new User();

        System.RunAs(usuarioAdmin) {
            usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            usuario.Username = 'ustestesteo@test.com'; 
            usuario.UserRoleId = uRole.id; 
            SAC_DatabaseDML.insertDML(usuario, false);      
            //Database.insert(usuario);
        }
        Test.stopTest();

        Id recTypeTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recTypeProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recTypeMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recTypeDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();

        //MCC
        CC_MCC__c mccTematica1 = new CC_MCC__c(
        RecordTypeId = recTypeTematica,
        Name = 'Avales MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-0101');
        SAC_DatabaseDML.insertDML(mccTematica1, false);  
        //Database.insert(mccTematica1);

        CC_MCC__c mccProdServ1 = new CC_MCC__c(
        RecordTypeId = recTypeProdServ,
        Name = 'Avales Fianzas y Otras Garantías MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101',
        CC_Tematica__c = mccTematica1.id);
        SAC_DatabaseDML.insertDML(mccProdServ1, false);
       //Database.insert(mccProdServ1);

        CC_MCC__c mccMotivo1 = new CC_MCC__c(
        RecordTypeId = recTypeMotivo,
        Name = 'Discrepancia con importe deuda reclamada MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Producto_Servicio__c = mccProdServ1.id,
        CC_Codigo_Externo__c = 'TEST-0102');
        SAC_DatabaseDML.insertDML(mccMotivo1, false);
       // Database.insert(mccMotivo1);

        CC_MCC__c mccDetalle2 = new CC_MCC__c(
        RecordTypeId = recTypeDetalle,
        Name = 'Discrepancia con importe deuda MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101012',
        CC_Motivo__c = mccMotivo1.id,
        SAC_GenerarTaskMisClientes__c = true);
        SAC_DatabaseDML.insertDML(mccDetalle2, false);
        //Database.insert(mccDetalle2);

        //GRUPOS
        List<CC_Grupo_Colaborador__c> listGrupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupo1 = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor', 1)[0];
        grupo1.OwnerId = usuario.id;
        listGrupos.add(grupo1);

        CC_Grupo_Colaborador__c grupo2 = SAC_TestDataFactory.crearGrupoColaborador('GrupoLetrados', 1)[0];
        grupo2.OwnerId = usuario.id;
        listGrupos.add(grupo2);
        SAC_DatabaseDML.insertListDML(listGrupos, false);
        //Database.insert(listGrupos);
       
        //RECLAMACION 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'Cerrado');
        camposRecl.put('SAC_StatusAuxiliar__c', 'Cerrado');
        camposRecl.put('OwnerId', usuario.Id);
        camposRecl.put('SEG_SRAuditoria__c', false);
        camposRecl.put('SEG_Grupo__c', listGrupos[0].Id);
        camposRecl.put('SAC_GrupoLetrado__c', listGrupos[1].Id);
        camposRecl.put('SAC_Letrado__c', usuario.Name);
        camposRecl.put('CC_Importe_Abonado__c', 50);
        camposRecl.put('SAC_FechaFinNegociacion__c', System.now());
        camposRecl.put('SAC_FechaUltimaAsignacionLetrado__c', System.now());
        camposRecl.put('CC_MCC_Tematica__c', mccTematica1.Id);
        camposRecl.put('CC_MCC_ProdServ__c', mccProdServ1.Id);
        camposRecl.put('CC_MCC_Motivo__c', mccMotivo1.Id);
        camposRecl.put('SEG_Detalle__c', mccDetalle2.Id);
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(casoReclamacion, false);
        //Database.insert(casoReclamacion);


        //PRETENSION 1
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'prueba');
        camposPret.put('Origin', 'Backoffice');
        camposPret.put('OwnerId', usuario.Id);
        camposPret.put('Status', 'SAC_009');
        camposPret.put('SAC_StatusAuxiliar__c', 'SAC_009');
		camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret.put('CC_MCC_Tematica__c', mccTematica1.Id);
        camposPret.put('CC_MCC_ProdServ__c', mccProdServ1.Id);
        camposPret.put('CC_MCC_Motivo__c', mccMotivo1.Id);
        camposPret.put('SEG_Detalle__c', mccDetalle2.Id);
        
        Case casoPretension1 = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        SAC_DatabaseDML.insertDML(casoPretension1, false);
        //Database.insert(casoPretension1);


        //AUDITORIA
        List<SEG_Auditoria__c> listAuditorias = new List<SEG_Auditoria__c>();
        SEG_Auditoria__c auditoriaAutomatica = new SEG_Auditoria__c();
        auditoriaAutomatica.SAC_NombreAuditoria__c = 'AuditoriaAutomaticaClaseTest';
        auditoriaAutomatica.SAC_Tipo__c = 'SAC_Negociacion';
        auditoriaAutomatica.RecordTypeId = Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName().get('SAC_AuditoriaAutomatica').getRecordTypeId();
        auditoriaAutomatica.OwnerId = usuario.Id;
        auditoriaAutomatica.SAC_FechaInicio__c = Date.today().addDays(-1);
        auditoriaAutomatica.SAC_FechaFin__c = Date.today().addDays(1);
        auditoriaAutomatica.SAC_Activo__c = false;
        auditoriaAutomatica.SAC_PeriocidadEjecucion__c = 'Diaria: Todos los días';
        auditoriaAutomatica.SAC_FechaCierre__c = 'Hoy';
        auditoriaAutomatica.SAC_SoloPretPpal__c = true;
        auditoriaAutomatica.SAC_NumMaxReclamaciones__c = 1;
        auditoriaAutomatica.SAC_GrupoProveedor__c = listGrupos[0].Id;
        auditoriaAutomatica.SAC_GrupoLetrado__c = listGrupos[1].Id;
        auditoriaAutomatica.SAC_ImporteAbonadoDesde__c = 40;
        auditoriaAutomatica.SAC_ImporteAbonadoHasta__c = 60;
        auditoriaAutomatica.SAC_MCCTematicaList__c = mccTematica1.Id;
        auditoriaAutomatica.SAC_MCCProductoList__c = mccProdServ1.Id;
        auditoriaAutomatica.SAC_MCCMotivoList__c = mccMotivo1.Id;
        auditoriaAutomatica.SAC_MCCDetalleList__c = mccDetalle2.Id;
        listAuditorias.add(auditoriaAutomatica);

        SEG_Auditoria__c auditoriaAutomatica2 = new SEG_Auditoria__c();
        auditoriaAutomatica2.SAC_NombreAuditoria__c = 'AuditoriaAutomaticaClaseTest2';
        auditoriaAutomatica2.SAC_Tipo__c = 'SAC_Analisis';
        auditoriaAutomatica2.RecordTypeId = Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName().get('SAC_AuditoriaAutomatica').getRecordTypeId();
        auditoriaAutomatica2.OwnerId = usuario.Id;
        auditoriaAutomatica2.SAC_FechaInicio__c = Date.today().addDays(-1);
        auditoriaAutomatica2.SAC_FechaFin__c = Date.today().addDays(1);
        auditoriaAutomatica2.SAC_Activo__c = false;
        auditoriaAutomatica2.SAC_PeriocidadEjecucion__c = 'Mensual: Todos los meses';
        auditoriaAutomatica2.SAC_FechaCierre__c = 'Últimos 5 días';
        auditoriaAutomatica2.SAC_SoloPretPpal__c = false;
        auditoriaAutomatica2.SAC_NumMaxReclamaciones__c = 1;
        auditoriaAutomatica2.SAC_GrupoProveedor__c = listGrupos[0].Id;
        auditoriaAutomatica2.SAC_GrupoLetrado__c = listGrupos[1].Id;
        auditoriaAutomatica2.SAC_ImporteAbonadoDesde__c = 40;
        auditoriaAutomatica2.SAC_ImporteAbonadoHasta__c = 60;
        auditoriaAutomatica2.SAC_MCCTematicaList__c = mccTematica1.Id;
        auditoriaAutomatica2.SAC_MCCProductoList__c = mccProdServ1.Id;
        auditoriaAutomatica2.SAC_MCCMotivoList__c = mccMotivo1.Id;
        auditoriaAutomatica2.SAC_MCCDetalleList__c = mccDetalle2.Id;
        listAuditorias.add(auditoriaAutomatica2);

        SAC_DatabaseDML.insertListDML(listAuditorias, false);
        //Database.insert(listAuditorias);
    }

    @isTest
    static void auditoriaAutomaticaTest() {
        User usuarioAdmin = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];
       
        System.runAs(usuarioAdmin){
            Test.startTest();
            SEG_Auditoria__c auditoriaAuto = [SELECT Id, SAC_FechaCierre__c, SAC_NombreAuditoria__c FROM SEG_Auditoria__c WHERE SAC_NombreAuditoria__c = 'AuditoriaAutomaticaClaseTest' LIMIT 1];
            auditoriaAuto.SAC_Activo__c = true;
            SAC_DatabaseDML.updateDML(auditoriaAuto, false);
            //Database.update(auditoriaAuto);
            
            Id batchId = Database.executeBatch(new SAC_AuditoriaAutomatica(), 1);

            Assert.areNotEqual(batchId, null, 'Error al lanzar el batch SAC_AuditoriaAutomatica en la clase Test');
            Test.stopTest();
        }
    }

    @isTest
    static void auditoriaAutomaticaTest2() {
        User usuarioAdmin = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];
       
        System.runAs(usuarioAdmin){
            Test.startTest();

            SEG_Auditoria__c auditoriaAuto = [SELECT Id, SAC_FechaCierre__c, SAC_NombreAuditoria__c FROM SEG_Auditoria__c WHERE SAC_NombreAuditoria__c = 'AuditoriaAutomaticaClaseTest2' LIMIT 1];
            auditoriaAuto.SAC_Activo__c = true;
            SAC_DatabaseDML.updateDML(auditoriaAuto, false);
            //Database.update(auditoriaAuto);
                
            Id batchId = Database.executeBatch(new SAC_AuditoriaAutomatica(), 1);

            Assert.areNotEqual(batchId, null, 'Error al lanzar el batch SAC_AuditoriaAutomatica en la clase Test');
            Test.stopTest();
        }
    }
}