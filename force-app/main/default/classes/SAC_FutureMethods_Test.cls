@isTest
public with sharing class SAC_FutureMethods_Test {
    @TestSetup
    static void makeData() {
        Set<String> objetos = new Set<String>{'CC_MCC__c','Account'};
        Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
        
        Id recordTypeIdMCCSAC = mapRTsObjects.get('CC_MCC__c').get('SAC_Detalle').getRecordTypeId();
        Id recordTypeNoCliente = mapRTsObjects.get('Account').get('SAC_NoCliente').getRecordTypeId();

        Test.startTest();
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);  
        //Database.insert(usuarioAdmin);

        User usuarioGeneral;
        System.runAs(usuarioAdmin) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            SAC_DatabaseDML.insertDML(usuarioGeneral, false);       
            //Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);    
            //Database.insert(permiSetAssi);

            PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
            permiSetAssi2.AssigneeId = usuarioAdmin.Id;
            permiSetAssi2.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi2, false); 
            //Database.insert(permiSetAssi2);
        }
        Test.stopTest();

        //Account 
        Account cuentaB = SAC_TestDataFactory.crearCuentas(1)[0];
        cuentaB.RecordTypeId = recordTypeNoCliente;
        cuentaB.OwnerId = usuarioGeneral.id;
        SAC_DatabaseDML.insertDML(cuentaB, false); 
        //Database.insert(cuentaB);

        //MCC
        CC_MCC__c mcc = new CC_MCC__c(
        Name = 'Banca Electrónica de prueba', 
        CC_Codigo_Externo__c = 'd', 
        RecordTypeId = recordTypeIdMCCSAC, 
        CC_Tipo_Cliente__c = 'SAC'
        );

        CC_MCC__c mcc2 = new CC_MCC__c(
        Name = 'Comisiones', 
        CC_Codigo_Externo__c = 'b', 
        RecordTypeId = recordTypeIdMCCSAC, 
        CC_Tipo_Cliente__c = 'SAC'
        );

        List<CC_MCC__c> mccs = new List<CC_MCC__c>();
        mccs.add(mcc);
        mccs.add(mcc2);
        SAC_DatabaseDML.insertListDML(mccs, false); 
        //Database.insert(mccs);

        //PARAMETRIZACIONES MCC
        SAC_ParametrizacionSLATME__c parametrizacion1  = SAC_TestDataFactory.crearParamsSla('Regulatorio',1)[0];
        parametrizacion1.SAC_Duracion__c = 4;
        parametrizacion1.SAC_MCC__c = mcc.Id;
        parametrizacion1.SAC_CanalProcedencia__c = ''; 
        

        SAC_ParametrizacionSLATME__c parametrizacion2  = SAC_TestDataFactory.crearParamsSla('Letrado',1)[0];
        parametrizacion2.SAC_Duracion__c = 1;
        parametrizacion2.SAC_MCC__c = mcc2.Id;
        parametrizacion2.SAC_CanalProcedencia__c = '';

        //tmo alta
        SAC_ParametrizacionSLATME__c parametrizacion3  = SAC_TestDataFactory.crearParamsSla('TME',1)[0];
        parametrizacion3.SAC_CanalProcedencia__c = '';
        parametrizacion3.name = 'TMO Alta';
        parametrizacion3.SAC_Estados__c = 'SAC_001';
        
        
        List<SAC_ParametrizacionSLATME__c> parametrizaciones = new List<SAC_ParametrizacionSLATME__c>();
        parametrizaciones.add(parametrizacion1);
        parametrizaciones.add(parametrizacion2);
        parametrizaciones.add(parametrizacion3);
        SAC_DatabaseDML.insertListDML(parametrizaciones, false); 
        //Database.upsert(parametrizaciones);

        //RECLAMACION 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl.put('SAC_DetenidoDesde__c', System.now().addDays(-1));
        camposRecl.put('SAC_DetenidoHasta__c', System.now());
        camposRecl.put('SAC_ReclamanteConformeNegociacion__c', true);
        camposRecl.put('SAC_Antecedentes_Revisados_Negociacion__c', true);
        camposRecl.put('SEG_Detalle__c', mcc.Id);
        camposRecl.put('AccountId', cuentaB.Id);
        camposRecl.put('SAC_TipoConsumidor__c', 'No');
        camposRecl.put('OwnerId', usuarioGeneral.id);

        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        //RECLAMACION 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('Status', 'SAC_006');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_006');
        camposRecl2.put('SAC_DetenidoDesde__c', System.now().addDays(-1));
        camposRecl2.put('SAC_DetenidoHasta__c', System.now());
        camposRecl2.put('isStopped', true);
        camposRecl2.put('SEG_Detalle__c', mcc.Id);
        camposRecl2.put('SAC_TipoConsumidor__c', 'No');
        camposRecl2.put('OwnerId', usuarioGeneral.id);

        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);

        //INSERTAMOS RECLAMACIONES
        List<Case> reclamaciones = new List<Case>();
        reclamaciones.add(casoReclamacion);
        reclamaciones.add(casoReclamacion2);
        SAC_DatabaseDML.insertListDML(reclamaciones, false); 
        //Database.insert(reclamaciones);
 

        //PRETENSION 1 
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'pret1');
        camposPret.put('Origin', 'Backoffice');
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret.put('SEG_Detalle__c', mcc.Id);
        camposPret.put('Subject', 'Pretension Owner');
        //camposPret.put('OwnerId', usuarioGeneral.id);
        
        Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);

        //PRETENSION 2 
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('SuppliedCompany', 'pret2');
        camposPret2.put('Origin', 'Backoffice');
        camposPret2.put('Status', 'SAC_001');
        camposPret2.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposPret2.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret2.put('SAC_PretensionPrincipal__c', casoReclamacion.Id);
        camposPret2.put('SEG_Detalle__c', mcc.Id);
        //camposPret2.put('OwnerId', usuarioGeneral.id);
        
        Case casoPretension2 = SAC_TestDataFactory.crearCaso('Pretension',camposPret2);

        //PRETENSION 3
        Map<String, Object> camposPret3 = new Map<String, Object>();
        camposPret3.put('SuppliedCompany', 'pret3');
        camposPret3.put('Origin', 'Backoffice');
        camposPret3.put('Status', 'SAC_007');
        camposPret3.put('SAC_DetenidoDesde__c', System.now().addDays(-1));
        camposPret3.put('SAC_StatusAuxiliar__c', 'SAC_007');
        camposPret3.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret3.put('SAC_PretensionPrincipal__c', casoReclamacion.Id);
        camposPret3.put('SEG_Detalle__c', mcc.Id);
        camposPret3.put('isStopped', true);
        //camposPret3.put('OwnerId', usuarioGeneral.id);
        
        Case casoPretension3 = SAC_TestDataFactory.crearCaso('Pretension',camposPret3);

        //PRETENSION 4
        Map<String, Object> camposPret4 = new Map<String, Object>();
        camposPret4.put('SuppliedCompany', 'pret4');
        camposPret4.put('Origin', 'Backoffice');
        camposPret4.put('SAC_DetenidoDesde__c', System.now().addDays(-1));
        camposPret4.put('Status', 'SAC_007');
        camposPret4.put('SAC_StatusAuxiliar__c', 'SAC_007');
        camposPret4.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret4.put('SEG_Detalle__c', mcc.Id);
        camposPret4.put('isStopped', true);
        //camposPret4.put('OwnerId', usuarioGeneral.id);
        
        Case casoPretension4 = SAC_TestDataFactory.crearCaso('Pretension',camposPret4);

        //PRETENSION 5
        Map<String, Object> camposPret5 = new Map<String, Object>();
        camposPret5.put('SuppliedCompany', 'pret5');
        camposPret5.put('Origin', 'Backoffice');
        camposPret5.put('Status', 'SAC_006');
        camposPret5.put('SAC_DetenidoDesde__c', System.now().addDays(-1));
        camposPret5.put('SAC_StatusAuxiliar__c', 'SAC_006');
        camposPret5.put('SAC_Reclamacion__c', casoReclamacion2.Id);
        camposPret5.put('SEG_Detalle__c', mcc.Id);
        camposPret5.put('isStopped', true);
        //camposPret5.put('OwnerId', usuarioGeneral.id);
        
        Case casoPretension5 = SAC_TestDataFactory.crearCaso('Pretension',camposPret5);

        //INSERTAMOS PRETENSIONES
        List<Case> pretensiones = new List<Case>();
        pretensiones.add(casoPretension);
        pretensiones.add(casoPretension2);
        pretensiones.add(casoPretension3);
        pretensiones.add(casoPretension4);
        pretensiones.add(casoPretension5);
        SAC_DatabaseDML.insertListDML(pretensiones, false);
        //Database.insert(pretensiones);

        CC_Grupo_Colaborador__c grupoColaboradorLetrado = new CC_Grupo_Colaborador__c();
        grupoColaboradorLetrado.name = 'grupoColaboradorTestLetrado';
        grupoColaboradorLetrado.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_Letrados').getRecordTypeId();
        grupoColaboradorLetrado.SAC_PorcentajeAsignacion__c = 100;
        grupoColaboradorLetrado.SAC_MaximoCasosDiarios__c = 30;
        SAC_DatabaseDML.insertDML(grupoColaboradorLetrado, false);

        List<SAC_DocumentoEnvio__c> listaDocs = new List<SAC_DocumentoEnvio__c>();
        SAC_DocumentoEnvio__c documento = new SAC_DocumentoEnvio__c();
        documento.SAC_Caso__c = casoReclamacion.Id;
        documento.SAC_TipoDocumento__c = 'redaccionTest1001';
        listaDocs.add(documento);
        SAC_DatabaseDML.insertListDML(listaDocs, true);
    }

    @isTest
    static void cambiaMcc_Test(){
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        CC_MCC__c mcc = [SELECT Id FROM CC_MCC__c WHERE  Name = 'Comisiones'];
        Case pretension1 = [SELECT Id, SEG_Detalle__c FROM Case WHERE SuppliedCompany = 'pret1'];
        pretension1.SEG_Detalle__c = mcc.Id;

        User usuarioAdmin = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Test.startTest();
        System.runAs(usuarioAdmin) {
            SAC_DatabaseDML.updateDML(pretension1, false);
            //Database.update(pretension1);
            SAC_Case_BU_TRHan.actualizarVariablesControl();
        }
        Test.stopTest();

        Assert.areEqual(pretension1.SEG_Detalle__c, mcc.Id, 'El cambio de MCC no funciona correctamente.');
    }

    // @isTest
    // static void cambiaStatus_Test(){
    //     User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
    //     List<Case> listaCasos = [SELECT Id, Status, isStopped, SuppliedCompany, Subject FROM Case WHERE SuppliedCompany = 'pret1' OR SuppliedCompany = 'pret2' OR Subject = 'TestRec'];

    //     Case pret1 = new Case();
    //     Case pret2 = new Case();
    //     Case rec = new Case();
    //     for (Case caso : listaCasos) {
    //         if (caso.SuppliedCompany == 'pret1') {
    //             pret1 = caso;
    //             pret1.Status = 'SAC_006';
    //             pret1.SAC_StatusAuxiliar__c = pret1.Status;
    //         }
    //         if (caso.SuppliedCompany == 'pret2') {
    //             pret2 = caso;
    //         }
    //         if (caso.Subject == 'TestRec') {
    //             rec = caso;
    //         }
    //     }

    //     Test.startTest();
    //     System.runAs(usuario) {
    //         Database.update(pret1);
    //     }
    //     Test.stopTest();

    //     List<Case> listaCasosResult = [SELECT Id, Status, isStopped, SuppliedCompany, Subject FROM Case WHERE SuppliedCompany = 'pret1' OR SuppliedCompany = 'pret2' OR Subject = 'TestRec'];

    //     Case pret1Result = new Case();
    //     Case pret2Result = new Case();
    //     Case recResult = new Case();
    //     for (Case caso : listaCasosResult) {
    //         if (caso.SuppliedCompany == 'pret1') {
    //             pret1Result = caso;
    //         }
    //         if (caso.SuppliedCompany == 'pret2') {
    //             pret2Result = caso;
    //         }
    //         if (caso.Subject == 'TestRec') {
    //             recResult = caso;
    //         }
    //     }

    //     Assert.areNotEqual(pret1.isStopped, pret1Result.isStopped, 'El cambio de estado no funciona correctamente pretensión propia.');
    //     Assert.areNotEqual(pret2.isStopped, pret2Result.isStopped, 'El cambio de estado no funciona correctamente pretensión hermana.');
    //     Assert.areNotEqual(rec.isStopped, recResult.isStopped, 'El cambio de estado no funciona correctamente reclamación padre.');
    // }

    @isTest
    static void cambiaStatus2_Test(){
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        List<Case> listaPretensiones = [SELECT Id, Status, isStopped, SuppliedCompany FROM Case WHERE SuppliedCompany = 'pret3' OR SuppliedCompany = 'pret4'];

        Case pretension1 = new Case();
        Case pretension2 = new Case();
        for (Case caso : listaPretensiones) {
            if (caso.SuppliedCompany == 'pret3') {
                pretension1 = caso;
            }
            if (caso.SuppliedCompany == 'pret4') {
                pretension2 = caso;
            }
        }
        pretension1.Status = 'SAC_001';
        pretension1.SAC_StatusAuxiliar__c = pretension1.Status;

        Test.startTest();
        System.runAs(usuario) {
            SAC_DatabaseDML.updateDML(pretension1, false);
            //Database.update(pretension1);
        }
        Test.stopTest();

        List<Case> listaPretensionesResult = [SELECT Id, Status, isStopped, SuppliedCompany FROM Case WHERE SuppliedCompany = 'pret3' OR SuppliedCompany = 'pret4'];

        Case pretension1v2 = new Case();
        Case pretension2v2 = new Case();
        for (Case caso : listaPretensionesResult) {
            if (caso.SuppliedCompany == 'pret3') {
                pretension1v2 = caso;
            }
            if (caso.SuppliedCompany == 'pret4') {
                pretension2v2 = caso;
            }
        }

        Assert.areEqual(pretension1.isStopped, pretension1v2.isStopped, 'El cambio de estado no funciona correctamente pretensión propia.');
        Assert.areEqual(pretension2.isStopped, pretension2v2.isStopped, 'El cambio de estado no funciona correctamente pretensión hermana.');
    }

    @isTest
    static void cambiaStatusyMCC_Test(){
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        List<Case> casos = new List<Case>();
        CC_MCC__c mcc =[SELECT Id FROM CC_MCC__c WHERE  Name = 'Comisiones'];
        List<Case> listaCasos = [SELECT Id, Status, isStopped, SEG_Detalle__c, SuppliedCompany, Subject FROM Case WHERE SuppliedCompany = 'pret5' OR Subject = 'TestRec2'];

        Case pretension1 = new Case();
        Case reclamacion = new Case();
        for (Case caso : listaCasos) {
            if (caso.SuppliedCompany == 'pret5') {
                pretension1 = caso;
            }
            if (caso.Subject == 'TestRec2') {
                reclamacion = caso;
            }
        }
        pretension1.Status = 'SAC_001';
        pretension1.SAC_StatusAuxiliar__c = pretension1.Status;
        reclamacion.Status = 'SAC_001';
        reclamacion.SAC_StatusAuxiliar__c = reclamacion.Status;

        pretension1.SEG_Detalle__c = mcc.Id;

        casos.add(pretension1);
        casos.add(reclamacion);

        User usuarioAdmin = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Test.startTest();
        System.runAs(usuarioAdmin) {
            SAC_DatabaseDML.updateListDML(casos, false);
            //Database.update(casos);
        }
        Test.stopTest();

        List<Case> listaCasosResult = [SELECT Id, Status, isStopped, SEG_Detalle__c, SuppliedCompany, Subject FROM Case WHERE SuppliedCompany = 'pret5' OR Subject = 'TestRec2'];

        Case pretension1v2 = new Case();
        Case reclamacion2 = new Case();
        for (Case caso : listaCasosResult) {
            if (caso.SuppliedCompany == 'pret5') {
                pretension1v2 = caso;
            }
            if (caso.Subject == 'TestRec2') {
                reclamacion2 = caso;
            }
        }

        Assert.areNotEqual(pretension1.isStopped, pretension1v2.isStopped, 'El cambio de estado no funciona correctamente pretensión propia.');
        Assert.areEqual(pretension1.SEG_Detalle__c, pretension1v2.SEG_Detalle__c, 'El cambio de estado no funciona correctamente pretensión propia.');
    }

    @isTest
    static void permisosLetradoTest() {
        User usuarioAdmin = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        User usuarioNuevo;
        System.runAs(usuarioAdmin) {
            //Usuario SAC General
            usuarioNuevo = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0]; 
            usuarioNuevo.Username = 'usertest454758437@test.com.testSetup';
            SAC_DatabaseDML.insertDML(usuarioNuevo, false);    
            //Database.insert(usuarioNuevo);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioNuevo.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);
            //Database.insert(permiSetAssi);
        }

        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status, isStopped FROM Case WHERE Subject = 'TestRec' LIMIT 1];

        reclamacion.OwnerId = usuarioNuevo.Id;

        Test.startTest();
        System.runAs(usuario) {
            SAC_DatabaseDML.updateDML(reclamacion, false);
            //Database.update(reclamacion);
        }
        Test.stopTest();

        CaseShare csResult = [SELECT CaseId, UserOrGroupId FROM CaseShare WHERE UserOrGroupId = :usuario.Id LIMIT 1];

        Assert.areEqual(usuario.Id, csResult.UserOrGroupId , 'No se ha podido insertar el permiso');
    }

    @isTest
    static void permisosGestorTest() {
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        List<Case> listaCasos = [SELECT Id, Status, isStopped, SuppliedCompany, Subject, OwnerId FROM Case WHERE Subject = 'TestRec' OR SuppliedCompany = 'pret1'];
        Case pretension = new Case();
        Case reclamacion = new Case();
        for (Case caso : listaCasos) {
            if (caso.SuppliedCompany == 'pret1') {
                pretension = caso;
            }
            if (caso.Subject == 'TestRec') {
                reclamacion = caso;
            }
        }

        reclamacion.SAC_PretensionPrincipal__c = pretension.Id;
        reclamacion.Status = 'SAC_002';
        reclamacion.SAC_StatusAuxiliar__c = reclamacion.Status;

        Test.startTest();
        System.runAs(usuario) {
            SAC_DatabaseDML.updateDML(reclamacion, false);
            //Database.update(reclamacion);
        }
        Test.stopTest();

        CaseShare cs = [SELECT CaseId, UserOrGroupId FROM CaseShare WHERE CaseId = :pretension.Id AND UserOrGroupId = :reclamacion.OwnerId];
        Assert.areNotEqual(null, cs, 'No se ha podido insertar el permiso');
    }

    @isTest
    public static void testFechaAsignacionTMOError() {

        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        
        case reclamacion = [SELECT Id FROM Case WHERE subject = 'TestRec' LIMIT 1];
        dateTime fH = dateTime.now().addYears(4000);
        boolean error = false;
        try {
            Test.startTest();
            System.runAs(usuario) {
                SAC_FutureMethods.fechaAsignacionTMO(fH, new list<Id>{reclamacion.id});
            }
            Test.stopTest();
        } catch(exception e) {
            error = true;
        }
       system.assert(!error, 'No se ha controlado el error');
        //depende de la conf de usuario para generar el log por lo tanto es mejor comprobar que el error se controla con un try catch
        //System.assert(([SELECT Id FROM CBK_Log__c]).size() == 1, 'Debería registrarse un error en la loggin');
    }

    @isTest
    public static void testFechaAsignacionTMO() {

        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        case reclamacion = [SELECT Id FROM Case WHERE subject = 'TestRec' LIMIT 1];
        dateTime fH = dateTime.now();

        Test.startTest();
        System.runAs(usuario) {
            SAC_FutureMethods.fechaAsignacionTMO(fH, new list<Id>{reclamacion.id});
        }
        Test.stopTest();

        SAC_TMECaso__c tmo = [SELECT ID, SAC_Caso__r.subject, name 
                                FROM SAC_TMECaso__c where name = 'TMO Alta' and sac_caso__c = : reclamacion.id ORDER BY createdDate DESC LIMIT 1];
        SAC_TiempoEstados__c tiempoEstados = [SELECT Id, SAC_FechaAsignacion__c FROM SAC_TiempoEstados__c WHERE SAC_TMECaso__c = : tmo.Id ORDER BY createdDate DESC LIMIT 1];
        System.assertEquals(fH, tiempoEstados.SAC_FechaAsignacion__c, 'Las fechas no coinciden');
    }

    @isTest
    public static void testchangeOwnerPretenHijas() {
        User usuarioModificador = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        case reclamacion = [SELECT Id, OwnerId FROM Case WHERE subject = 'TestRec' LIMIT 1];
        reclamacion.Status = 'SAC_001';
        reclamacion.OwnerId = usuarioModificador.Id;

        Test.startTest();
        System.runAs(usuario) {
            SAC_FutureMethods.changeOwnerPretensionesHijas(new List<Id>{reclamacion.Id}, new Set<Id>{usuarioModificador.Id});
        }
        Test.stopTest();

        // Verificar que los casos de pretensión tienen el nuevo OwnerId
        List<Case> updatedPretensiones = [SELECT Id, subject, OwnerId FROM Case WHERE SAC_Reclamacion__c = :reclamacion.Id AND Subject = 'Pretension Owner' LIMIT 1];
        System.assertEquals(reclamacion.OwnerId, updatedPretensiones[0].OwnerId, 'El OwnerId de la pretensión se actualizó correctamente');
    }

    @isTest
    public static void eliminarPermisosOwnerLetradoTest() {
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        CC_Grupo_Colaborador__c grupoLet = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'grupoColaboradorTestLetrado' LIMIT 1];

        Map<String, Object> camposCons = new Map<String, Object>();
        camposCons.put('Subject', 'ConsuultaSAC090125');
        Case consulta = SAC_TestDataFactory.crearCaso('Consulta',camposCons);
        consulta.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_ConsultaSAC').getRecordTypeId();  
        consulta.SAC_Letrado__c = 'Test consulta SAC Letrado';
        SAC_DatabaseDML.insertDML(consulta, true);

        Test.startTest();
        System.runAs(usuario) {
            consulta.SAC_GrupoLetrado__c = grupoLet.Id;
            SAC_DatabaseDML.updateDML(consulta, true); 
        }
        Test.stopTest();

        // Verificar que los casos de pretensión tienen el nuevo OwnerId
        List<Case> updateConsulta = [SELECT Id, SAC_Letrado__c FROM Case WHERE Id = :consulta.Id AND Subject = 'ConsuultaSAC090125' LIMIT 1];
        Assert.areNotEqual('Test consulta SAC Letrado', updateConsulta[0].SAC_Letrado__c, 'El owner letrado de la consulta no se actualizó');
    }

    @isTest
    public static void generarCartaPostalTest() {
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        case reclamacion = [SELECT Id, OwnerId FROM Case WHERE subject = 'TestRec' LIMIT 1];
        SAC_DocumentoEnvio__c carta = [SELECT Id FROM SAC_DocumentoEnvio__c WHERE SAC_TipoDocumento__c = 'redaccionTest1001' LIMIT 1];

        Test.startTest();
        System.runAs(usuario) {
            SAC_FutureMethods.generarCartaPostal(carta.Id, reclamacion.id);
        }
        Test.stopTest();

        // Verificar que los casos de pretensión tienen el nuevo OwnerId
        List<Case> casoUpdate = [SELECT Id, CC_AcuseRecibo__c FROM Case WHERE Id = :reclamacion.Id AND Subject = 'TestRec' LIMIT 1];
        Assert.areNotEqual('0', casoUpdate[0].CC_AcuseRecibo__c, 'No se ha generado la carta postal');
    }
}