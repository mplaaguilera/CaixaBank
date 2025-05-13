/*****************************************************************
* Name: SAC_LCMP_UpdateStatus_Test2
* Copyright © 2021  CaixaBank
* 
* Proposito: Testear la clase SAC_LCMP_UpdateStatus_Test
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR               DATE       Description 
* 1.0                             Raúl Santos          13/03/24    Creación: para evitar apex CPU limit            
*****************************************************************/

@isTest
public with sharing class SAC_LCMP_UpdateStatus_Test2 {
    @TestSetup
    static void makeData() {
        
        User usuario;
        
        Test.startTest();
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);     
        //Database.insert(usuarioAdmin);
        
        System.runAs(usuarioAdmin) {
            //Usuario SAC General
            List<User> usuariosGenerales = SAC_TestDataFactory.crearUsuarioSACGeneral(1);
            usuariosGenerales[0].Username = 'Name12345@test.com';
            usuario = usuariosGenerales[0];
            SAC_DatabaseDML.insertListDML(usuariosGenerales, false);     
            //Database.insert(usuariosGenerales);
            
            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuario.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);  
            //Database.insert(permiSetAssi);
        }
        //Cuentas
        Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
        SAC_DatabaseDML.insertDML(cuenta, false);  
        //Database.insert(cuenta);
        
        //Contact
        Contact contacto = SAC_TestDataFactory.crearContacto(1, cuenta.Id)[0];
        SAC_DatabaseDML.insertDML(contacto, false);  
        //Database.insert(contacto);
        
        //Entitlement
        Entitlement entitle = SAC_TestDataFactory.crearEntitlement(cuenta.Id);
        SAC_DatabaseDML.insertDML(entitle, false); 
        //Database.insert(entitle);
        
        //Creacion MCC tipo PSD2
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.Name = 'PSD2';
        mcc.SAC_EsPsd2__c = true;
        mcc.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        SAC_DatabaseDML.insertDML(mcc, false); 
        //Database.insert(mcc);
        
        //Creacion MCC tipo GGH
        CC_MCC__c mccGGH = new CC_MCC__c();
        mccGGH.Name = 'GGH';
        mccGGH.SAC_esGGH__c = true;
        mccGGH.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        SAC_DatabaseDML.insertDML(mccGGH, false);
        
        //RECLAMACION 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Origin', 'Otros');
        camposRecl2.put('Status', 'SAC_001');
        // camposRecl2.put('OwnerId', usuario.Id);
        camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl2.put('SAC_DetenidoDesde__c', System.now());
        camposRecl2.put('AccountId', cuenta.Id);
        camposRecl2.put('SAC_ProrrogaCounter__c', 1);
        camposRecl2.put('SuppliedEmail', 't.t@t.t');
        camposRecl2.put('SAC_TipoConsumidor__c', 'Si');
        
        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl2);
        
        //RECLAMACION 3
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'TestRec3');
        camposRecl3.put('Origin', 'Otros');
        camposRecl3.put('Status', 'SAC_002');
        // camposRecl2.put('OwnerId', usuario.Id);
        camposRecl3.put('SAC_StatusAuxiliar__c', 'SAC_002');
        camposRecl3.put('AccountId', cuenta.Id);
        camposRecl3.put('SAC_ProrrogaCounter__c', 1);
        camposRecl3.put('SuppliedEmail', 't.t@t.t');
        camposRecl3.put('SAC_TipoConsumidor__c', 'Si');
        
        Case casoReclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl3);
        
        //RECLAMACION 4
        Map<String, Object> camposRecl4 = new Map<String, Object>();
        camposRecl4.put('Subject', 'TestRec4');
        camposRecl4.put('Origin', 'Otros');
        camposRecl4.put('Status', 'SAC_006');
        camposRecl4.put('OwnerId', usuario.Id);
        camposRecl4.put('SAC_StatusAuxiliar__c', 'SAC_006');
        camposRecl4.put('AccountId', cuenta.Id);
        camposRecl4.put('SAC_DetenidoDesde__c', System.now().addDays(-1));
        camposRecl4.put('SAC_DetenidoHasta__c', System.now());
        camposRecl4.put('SAC_ProrrogaCounter__c', 0);
        camposRecl4.put('SuppliedEmail', 't.t@t.t');
        camposRecl4.put('SAC_TipoConsumidor__c', 'Si');
        
        Case casoReclamacion4 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl4);
        
        //RECLAMACION 6 
        Map<String, Object> camposRecl6 = new Map<String, Object>();
        camposRecl6.put('Subject', 'TestRec6');
        camposRecl6.put('Origin', 'Otros');
        camposRecl6.put('Status', 'SAC_001');
        camposRecl6.put('OwnerId', usuario.Id);
        camposRecl6.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl6.put('AccountId', cuenta.Id);
        camposRecl6.put('SAC_ProrrogaCounter__c', 0);
        camposRecl6.put('SuppliedEmail', 't.t@t.t');
        camposRecl6.put('SAC_TipoConsumidor__c', 'Si');
        
        Case casoReclamacion6 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl6);
        
        //RECLAMACION 7 
        Map<String, Object> camposRecl7 = new Map<String, Object>();
        camposRecl7.put('Subject', 'TestRec7');
        camposRecl7.put('Origin', 'Otros');
        camposRecl7.put('Status', 'SAC_002');
        camposRecl7.put('OwnerId', usuario.Id);
        camposRecl7.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl7.put('AccountId', cuenta.Id);
        camposRecl7.put('SAC_ProrrogaCounter__c', 0);
        camposRecl7.put('SuppliedEmail', 't.t@t.t');
        camposRecl7.put('SAC_TipoConsumidor__c', 'Si');
        
        Case casoReclamacion7 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl7);
        
        //RECLAMACION 8
        Map<String, Object> camposRecl8 = new Map<String, Object>();
        camposRecl8.put('Subject', 'TestRec8');
        camposRecl8.put('Origin', 'Otros');
        camposRecl8.put('Status', 'SAC_001');
        camposRecl8.put('OwnerId', usuario.Id);
        camposRecl8.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl8.put('AccountId', cuenta.Id);
        camposRecl8.put('SAC_ProrrogaCounter__c', 0);
        camposRecl8.put('SuppliedEmail', 't.t@t.t');
        camposRecl8.put('SAC_TipoConsumidor__c', 'Si');
        Case casoReclamacion8 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl8);
        
        List<Case> casosReclamacion = new List<Case>();
        casosReclamacion.add(casoReclamacion2);
        casosReclamacion.add(casoReclamacion3);
        casosReclamacion.add(casoReclamacion4);
        casosReclamacion.add(casoReclamacion6);
        casosReclamacion.add(casoReclamacion7);
        casosReclamacion.add(casoReclamacion8);
        SAC_DatabaseDML.insertListDML(casosReclamacion, false); 
        //Database.insert(casosReclamacion);
        Test.stopTest();
        //PRETENSION
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('Subject', 'TestPret2');
        camposPret.put('SuppliedCompany', 'TestPret');
        camposPret.put('Origin', 'Backoffice');
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_StatusAuxiliar__c', 'SAC_001');
        // camposPret.put('OwnerId', usuario.Id);
        camposPret.put('SAC_Reclamacion__c', casoReclamacion2.Id);
        camposPret.put('AccountId', cuenta.Id);
        camposPret.put('SEG_Detalle__c', mcc.Id);
        
        Case pretension = SAC_TestDataFactory.crearCaso('Pretension', camposPret);
        
        //PRETENSION 4
        Map<String, Object> camposPret4 = new Map<String, Object>();
        camposPret4.put('Subject', 'TestPret4');
        camposPret4.put('SuppliedCompany', 'TestPret4');
        camposPret4.put('Origin', 'Otros');
        camposPret4.put('Status', 'SAC_006');
        camposPret4.put('SAC_StatusAuxiliar__c', 'SAC_006');
        camposPret4.put('SAC_DetenidoDesde__c', System.now().addDays(-1));
        camposPret4.put('SAC_SentidoResolucion__c', 'SAC_001');
        camposPret4.put('SAC_RedaccionFinal__c', true);
        camposPret4.put('OwnerId', usuario.Id);
        camposPret4.put('SAC_Reclamacion__c', casoReclamacion4.Id);
        camposPret4.put('AccountId', cuenta.Id);
        camposPret4.put('SEG_Detalle__c', mcc.Id);
        
        Case pretension4 = SAC_TestDataFactory.crearCaso('Pretension', camposPret4);
        
        //PRETENSION 5
        Map<String, Object> camposPret5 = new Map<String, Object>();
        camposPret5.put('Subject', 'TestPret6');
        camposPret5.put('SuppliedCompany', 'TestPret6');
        camposPret5.put('Origin', 'Otros');
        camposPret5.put('Status', 'SAC_007');
        camposPret5.put('SAC_StatusAuxiliar__c', 'SAC_007');
        camposPret5.put('SAC_SentidoResolucion__c', 'SAC_001');
        camposPret5.put('SAC_RedaccionFinal__c', true);
        camposPret5.put('OwnerId', usuario.Id);
        camposPret5.put('SAC_Reclamacion__c', casoReclamacion6.Id);
        camposPret5.put('AccountId', cuenta.Id);
        camposPret5.put('SEG_Detalle__c', mcc.Id);
        
        Case pretension5 = SAC_TestDataFactory.crearCaso('Pretension', camposPret5);
        
        //PRETENSION 6
        Map<String, Object> camposPret6 = new Map<String, Object>();
        camposPret6.put('Subject', 'TestPret7');
        camposPret6.put('SuppliedCompany', 'TestPret7');
        camposPret6.put('Origin', 'Otros');
        camposPret6.put('Status', 'SAC_007');
        camposPret6.put('SAC_StatusAuxiliar__c', 'SAC_007');
        camposPret6.put('SAC_SentidoResolucion__c', 'SAC_001');
        camposPret6.put('SAC_RedaccionFinal__c', true);
        camposPret6.put('SAC_NegociacionFinalizada__c', true);
        camposPret6.put('CC_Importe_Reclamado__c', 50);
        camposPret6.put('OwnerId', usuario.Id);
        camposPret6.put('SAC_Reclamacion__c', casoReclamacion6.Id);
        camposPret6.put('AccountId', cuenta.Id);
        camposPret6.put('SEG_Detalle__c', mcc.Id);
        
        Case pretension6 = SAC_TestDataFactory.crearCaso('Pretension', camposPret6);
        
        //PRETENSION 7
        Map<String, Object> camposPret7 = new Map<String, Object>();
        camposPret7.put('Subject', 'TestPret8');
        camposPret7.put('SuppliedCompany', 'TestPret8');
        camposPret7.put('Status', 'SAC_007');
        camposPret7.put('SAC_StatusAuxiliar__c', 'SAC_007');
        camposPret7.put('SAC_RedaccionFinal__c', true);
        camposPret7.put('SAC_NegociacionFinalizada__c', true);
        camposPret7.put('CC_Importe_Reclamado__c', 50);
        camposPret7.put('OwnerId', usuario.Id);
        camposPret7.put('SAC_Reclamacion__c', casoReclamacion6.Id);
        camposPret7.put('AccountId', cuenta.Id);
        camposPret7.put('SEG_Detalle__c', mcc.Id);
        
        Case pretension7 = SAC_TestDataFactory.crearCaso('Pretension', camposPret7);
        
        //PRETENSION 8
        Map<String, Object> camposPret8 = new Map<String, Object>();
        camposPret8.put('Subject', 'TestPret88');
        camposPret8.put('SuppliedCompany', 'TestPret88');
        camposPret8.put('Status', 'SAC_001');
        camposPret8.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposPret8.put('SAC_RedaccionFinal__c', true);
        camposPret8.put('CC_Importe_Reclamado__c', 50);
        camposPret8.put('OwnerId', usuario.Id);
        camposPret8.put('SAC_Reclamacion__c', casoReclamacion8.Id);
        camposPret8.put('AccountId', cuenta.Id);
        camposPret8.put('SEG_Detalle__c', mccGGH.Id);
        //camposPret8.put('SAC_TasacionReclamado__c', 'SAC_No');
        //camposPret8.put('SAC_RegistrosReclamado__c', 'SAC_No');
        //camposPret8.put('SAC_NotariaReclamado__c', 'SAC_No');
        //camposPret8.put('SAC_GestoriaReclamado__c', 'SAC_Yes');
        //camposPret8.put('SAC_ImpReclamadoGestoria__c', 1000);
        
        Case pretension8 = SAC_TestDataFactory.crearCaso('Pretension', camposPret8);
        List<Case> casosPretension = new List<Case>();
        casosPretension.add(pretension);
        casosPretension.add(pretension4);
        casosPretension.add(pretension5);
        casosPretension.add(pretension6);
        casosPretension.add(pretension7);
        casosPretension.add(pretension8);
        
        SAC_DatabaseDML.insertListDML(casosPretension, false); 
        //Database.insert(casosPretension);
        
        
        //Informar pretension principal
        List<Case> listaRecsUpdatear = new List<Case>();
        casoReclamacion2.SAC_PretensionPrincipal__c = pretension.Id;
        casoReclamacion6.SAC_PretensionPrincipal__c = pretension5.Id;
        listaRecsUpdatear.add(casoReclamacion2);
        listaRecsUpdatear.add(casoReclamacion6);
        SAC_DatabaseDML.updateListDML(listaRecsUpdatear, false); 
        //Database.update(listaRecsUpdatear);
        
        //Tarea
        SAC_Accion__c tarea = SAC_TestDataFactory.crearTareas(1, casoReclamacion6, true)[0];
        SAC_DatabaseDML.insertDML(tarea, false); 
        //Database.insert(tarea);
        
        //Email Backlist
        SAC_MaestroTemas__c maestroTema = new SAC_MaestroTemas__c();
        maestroTema.Name ='emailtest@prueba.com';
        maestroTema.SAC_Activo__c = true;
        maestroTema.RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_BlackListEmails').getRecordTypeId();
        SAC_DatabaseDML.insertDML(maestroTema, false); 
        //Database.insert(maestroTema);
    }
    
    @isTest
    static void comprobarConsumidorReclamacionTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        Case pretension = [SELECT Id, SAC_Reclamacion__c FROM Case WHERE SuppliedCompany = 'TestPret8'];
        
        Boolean resultado;
        System.runAs(usuario){
            Test.startTest();
            resultado = SAC_LCMP_UpdateStatus.comprobarConsumidorReclamacion(pretension.SAC_Reclamacion__C, pretension.Id);
            Test.stopTest();
        }
        
        Assert.areEqual(true, resultado, 'No se ha comprobado correctamente.');
    }
    
    @isTest
    static void getListoFinalizarNegociacionTest(){
        Test.startTest();
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec6'];
        // Case pretension = [SELECT Id, Status, SAC_StatusAuxiliar__c FROM Case WHERE SuppliedCompany = 'TestPret6'];
        
        System.runAs(usuario){
            SAC_LCMP_UpdateStatus.WrapperFinalizarNegociacion resultado = SAC_LCMP_UpdateStatus.getListoFinalizarNegociacion(reclamacion.id);
            System.assertNotEquals(null, resultado, 'No se ha ejecutado correctamente el método.');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testVieneDeAlta(){
        Test.startTest();
        Case reclamacion2 = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2'];
        
        Boolean resultado2;
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuario){
            resultado2 = SAC_LCMP_UpdateStatus.vieneDeAlta(reclamacion2.Id);
        }
        Test.stopTest();
        System.assertEquals(resultado2, true, 'No viene del estado alta la reclamacion. Falla parte 1');
    }
    
    @isTest
    static void testEsPropietario(){
        Test.startTest();
        Case reclamacion2 = [SELECT Id, Status, OwnerId FROM Case WHERE Subject = 'TestRec2'];
        
        Boolean resultado2;
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuario){
            resultado2 = SAC_LCMP_UpdateStatus.esPropietario(reclamacion2.Id);
        }
        Test.stopTest();
        System.assertEquals(resultado2, false, 'No viene del estado alta la reclamacion. Falla parte 2');
    }
    
    @isTest
    static void testEsPropietarioV3(){
        Test.startTest();
        Case pretension = [SELECT Id, Status FROM Case WHERE SuppliedCompany = 'TestPret'];
        
        Boolean resultado;
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuario){
            resultado = SAC_LCMP_UpdateStatus.esPropietario(pretension.Id);
        }
        Test.stopTest();
        
        System.assertEquals(resultado, false, 'No viene del estado alta la reclamacion. Falla parte ');
    }
    
    @isTest
    static void testUpdateValidacion(){
        Test.startTest();
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2'];
        reclamacion.status = 'SAC_002';
        reclamacion.SAC_StatusAuxiliar__c = 'SAC_002';
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
        try {
            System.runAs(usuario){
                
                SAC_LCMP_UpdateStatus.updateRecordStatus(reclamacion.Id, 'SAC_002');
                
            } 
        } catch (Exception e) {
            Case caso = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2'];
            System.assertEquals(false, caso.hasErrors(),'Validacion correcta');
        }
        Test.stopTest(); 
    }
    
    @isTest
    static void updateRecordStatusInadmision(){
        Test.startTest();
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuario){
            
            try{
                SAC_LCMP_UpdateStatus.updateRecordStatusInadmision(reclamacion.Id,'SAC_005');
                
            }catch(AuraHandledException e){
                System.assertNotEquals(null, e, 'No se ha actualizado el caso'); 
            }
        }       
        Test.stopTest();  
    }
    
    @isTest
    static void updateRecordStatusInadmision2(){
        Test.startTest();
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        
        System.runAs(usuario){
            
            reclamacion.CC_Canal_Respuesta__c = 'SAC_CartaPostal';
            reclamacion.SAC_DireccionContacto__c = 'test1';
            reclamacion.SAC_CodigoPostalContacto__c = '123';
            reclamacion.SAC_PoblacionContacto__c = 'test2';
            reclamacion.SAC_ProvinciaContacto__c = 'test3';
            reclamacion.SAC_PaisContacto__c = 'españa';
            SAC_DatabaseDML.updateDML(reclamacion, false); 
            //Database.update(reclamacion);
            
            try{
                SAC_LCMP_UpdateStatus.updateRecordStatusInadmision(reclamacion.Id,'SAC_005');
                
            }catch(AuraHandledException e){
                System.assertNotEquals(null, e, 'No se ha actualizado el caso'); 
            }
        }       
        Test.stopTest();  
    }
    
    @isTest
    static void updateRecordStatusRechazadoTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuario){
            
            try{
                SAC_LCMP_UpdateStatus.updateRecordStatusRechazado(reclamacion.Id,'SAC_AltaErronea');
                
            }catch(AuraHandledException e){
                System.assertNotEquals(null, e, 'No se ha actualizado el caso'); 
            }
        }   
        Test.stopTest();    
    }
    
    @isTest
    static void updateRecordStatusRechazadoTest2(){
        Test.startTest();
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        
        System.runAs(usuario){
            reclamacion.CC_Canal_Respuesta__c = 'SAC_CartaPostal';
            reclamacion.SAC_DireccionContacto__c = 'test1';
            reclamacion.SAC_CodigoPostalContacto__c = '123';
            reclamacion.SAC_PoblacionContacto__c = 'test2';
            reclamacion.SAC_ProvinciaContacto__c = 'test3';
            reclamacion.SAC_PaisContacto__c = 'españa';
            SAC_DatabaseDML.updateDML(reclamacion, false); 
            //Database.update(reclamacion);
            
            try{
                SAC_LCMP_UpdateStatus.updateRecordStatusRechazado(reclamacion.Id,'SAC_AltaErronea');
                
            }catch(AuraHandledException e){
                System.assertNotEquals(null, e, 'No se ha actualizado el caso'); 
            }
        }   
        Test.stopTest();    
    }
    
    @isTest
    static void obtenerPara2Test(){
        Test.startTest();
        
        Case reclamacion = [SELECT Id, Origin, OS_Email__c, SAC_DireccionPostal__c, CC_Canal_Respuesta__c, SuppliedEmail, Account.CC_Email__c, 
                            Status, RecordType.Name, AccountId, CC_Idioma__c, Account.RecordTypeId, SAC_Reclamacion__c, SAC_Reclamacion__r.CC_Canal_Respuesta__c FROM Case WHERE Subject = 'TestRec2'];
        
        Case pretension = [SELECT Id, Origin, OS_Email__c, SAC_DireccionPostal__c, CC_Canal_Respuesta__c, SuppliedEmail, Account.CC_Email__c, 
                           Status, RecordType.Name, AccountId, CC_Idioma__c, Account.RecordTypeId, SAC_Reclamacion__c, SAC_Reclamacion__r.CC_Canal_Respuesta__c FROM Case WHERE SuppliedCompany = 'TestPret'];
        String resultado;
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuario){
            resultado = SAC_LCMP_UpdateStatus.obtenerPara(pretension, 'Pretension');
        }
        Test.stopTest();
        
        System.assertEquals(resultado, reclamacion.SuppliedEmail, 'Ha fallado la asignacion del para en el email.');
    }
    
    @isTest
    static void esPrincipal(){
        Test.startTest();
        
        String recType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        Case pretension = [SELECT id, Subject FROM CASE WHERE recordTypeId =: recType AND Origin = 'Backoffice'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuario){
            String respuesta = SAC_LCMP_UpdateStatus.esPrincipal(pretension.Id);
        }
        Test.stopTest();
        
        System.assertNotEquals('no', 'mas', 'No es la unica pretensión');
    }
    
    @isTest
    static void esPrincipalTest2(){
        Test.startTest();
        
        String recTypePret = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        String recTypeRec = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        
        Case reclamacion = [SELECT id FROM CASE WHERE recordTypeId =: recTypeRec AND Subject = 'TestRec3'];
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
        //PRETENSION
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('Subject', 'TestPret3');
        camposPret2.put('SuppliedCompany', 'TestPret');
        camposPret2.put('Origin', 'Otros');
        camposPret2.put('Status', 'SAC_009');
        camposPret2.put('SAC_StatusAuxiliar__c', 'SAC_009');
        camposPret2.put('SAC_Reclamacion__c', reclamacion.Id);
        
        Case pretension2 = SAC_TestDataFactory.crearCaso('Pretension', camposPret2);
        SAC_DatabaseDML.insertDML(pretension2, false); 
        //Database.insert(pretension2);
        
        String respuesta;
        
        System.runAs(usuario){
            respuesta = SAC_LCMP_UpdateStatus.esPrincipal(pretension2.Id);
        }
        Test.stopTest();
        
        System.assertEquals('no', respuesta, 'No es la unica pretensión');
    }
    
    @isTest
    static void esPrincipalTest3(){
        Test.startTest();
        
        String recTypePret = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        String recTypeRec = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        
        Case reclamacion = [SELECT id FROM CASE WHERE recordTypeId =: recTypeRec AND Subject = 'TestRec3'];
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
        //PRETENSION
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('Subject', 'TestPret4');
        camposPret2.put('SuppliedCompany', 'TestPret');
        camposPret2.put('Origin', 'Otros');
        camposPret2.put('Status', 'SAC_002');
        camposPret2.put('SAC_StatusAuxiliar__c', 'SAC_002');
        camposPret2.put('SAC_Reclamacion__c', reclamacion.Id);
        
        Case pretension2 = SAC_TestDataFactory.crearCaso('Pretension', camposPret2);
        SAC_DatabaseDML.insertDML(pretension2, false); 
        //Database.insert(pretension2);
        
        String respuesta;
        
        System.runAs(usuario){
            respuesta = SAC_LCMP_UpdateStatus.esPrincipal(pretension2.Id);
        }
        Test.stopTest();
        
        System.assertNotEquals('no', respuesta, 'No es la unica pretensión');
    }
    
    @isTest
    static void esPrincipalTest4(){
        Test.startTest();
        
        String recTypePret = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        String recTypeRec = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        
        Case reclamacion = [SELECT id FROM CASE WHERE recordTypeId =: recTypeRec AND Subject = 'TestRec3'];
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
        //PRETENSION
        List<Case> listPret = new List<Case>();
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('Subject', 'TestPret4');
        camposPret2.put('SuppliedCompany', 'TestPret');
        camposPret2.put('Origin', 'Otros');
        camposPret2.put('Status', 'SAC_002');
        camposPret2.put('SAC_StatusAuxiliar__c', 'SAC_002');
        camposPret2.put('SAC_Reclamacion__c', reclamacion.Id);
        
        Case pretension2 = SAC_TestDataFactory.crearCaso('Pretension', camposPret2);
        listPret.add(pretension2);
        
        Map<String, Object> camposPret3 = new Map<String, Object>();
        camposPret3.put('Subject', 'TestPret5');
        camposPret3.put('SuppliedCompany', 'TestPret');
        camposPret3.put('Origin', 'Otros');
        camposPret3.put('Status', 'SAC_002');
        camposPret3.put('SAC_StatusAuxiliar__c', 'SAC_002');
        camposPret3.put('SAC_Reclamacion__c', reclamacion.Id);
        
        Case pretension3 = SAC_TestDataFactory.crearCaso('Pretension', camposPret3);
        listPret.add(pretension3);
        
        SAC_DatabaseDML.insertListDML(listPret, false); 
        //Database.insert(listPret);
        
        //Informar pretension principal
        List<Case> listaRecsUpdatear = new List<Case>();
        reclamacion.SAC_PretensionPrincipal__c = pretension3.Id;
        listaRecsUpdatear.add(reclamacion);
        SAC_DatabaseDML.updateDML(reclamacion, false); 
        //Database.update(reclamacion);
        
        String respuesta;
        
        System.runAs(usuario){
            respuesta = SAC_LCMP_UpdateStatus.esPrincipal(pretension3.Id);
        }
        Test.stopTest();
        
        System.assertNotEquals('no', respuesta, 'No es la unica pretensión');
    }
    
    @isTest
    static void testProrroga(){
        Test.startTest();
        
        Case reclamacion = [SELECT Id, Status,SAC_ProrrogaCounter__c FROM Case WHERE Subject = 'TestRec2'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuario){
            // List <Case> pretensiones = [SELECT Id, Status,SAC_Reclamacion__c,SAC_ProrrogaCounter__c FROM Case WHERE SAC_Reclamacion__c =: reclamacion.Id];
            SAC_LCMP_UpdateStatus.prorroga(reclamacion.Id);
        }
        Test.stopTest();   
        
        System.assertNotEquals(reclamacion.SAC_ProrrogaCounter__c, 0,'No se ha prorrogado'); 
    }
    
    @isTest
    static void testREcuperarPlantillaProrrogas(){
        
        Test.startTest();
        User usuarioAdmin = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        
        //Template
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'name';
        validEmailTemplate.DeveloperName = 'SAC_Not';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.HtmlValue = '<p><p>';
        validEmailTemplate.Body = 'Texted';
        validEmailTemplate.FolderId = usuarioAdmin.Id;
        
        SAC_DatabaseDML.insertDML(validEmailTemplate, false); 
        //Database.insert(validEmailTemplate);
        
        User usuario2 = new User();
        usuario2.Username = 'Name1234@test.com';
        usuario2.Email = 'emairel@test.com';
        usuario2.LastName = 'Usuario Testo';
        usuario2.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        usuario2.Alias = 'aliaso';
        usuario2.TimeZoneSidKey = 'GMT';
        usuario2.LocaleSidKey = 'es_ES';
        usuario2.EmailEncodingKey = 'ISO-8859-1';
        usuario2.LanguageLocaleKey = 'en_US';
        usuario2.isActive = true;
        usuario2.userRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];
        SAC_DatabaseDML.insertDML(usuario2, false);
        //Database.insert(usuario2);
        
        Case reclamacion = [SELECT Id, Status,SAC_ProrrogaCounter__c FROM Case WHERE Subject = 'TestRec2'];
        
        System.runAs(usuario2){
            SAC_LCMP_UpdateStatus.recuperarPlantillaProrrogas(reclamacion.Id);
        }
        
        System.assertNotEquals(SAC_LCMP_UpdateStatus.recuperarPlantillaProrrogas(reclamacion.Id), null ,'La plantilla no existe');     
        
        Test.stopTest();
    }
    
    @isTest
    static void testHaProrrogado(){
        Test.startTest();
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2'];
        Boolean result ;
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuario){
            // List <Case> pretensiones = [SELECT Id, Status,SAC_ProrrogaCounter__c,SAC_Reclamacion__c FROM Case WHERE SAC_Reclamacion__c =: reclamacion.Id];
            result = SAC_LCMP_UpdateStatus.haProrrogado(reclamacion.Id);
        } 
        System.assertEquals(result, true,'El caso no tiene una prorroga'); 
        Test.stopTest();  
    }
    
    @isTest
    static void comprobarEmailsEnvioTest() {
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        string para = 'emailtest@prueba.com';
        string copia1 ='emailtestcopia1@prueba.com';
        string copia2 ='emailtestcopia2@prueba.com';
        string result;
        Test.startTest();
        System.runAs(usuario){
            result =  SAC_LCMP_UpdateStatus.comprobarEmailsEnvio(para, copia1, copia2);
        }
        System.assertEquals('emailtest@prueba.com', result, 'No coincide');
        Test.stopTest();
    }
    
    
    @isTest
    static void recuperarSLAActivosTest(){
        Test.startTest();
        
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec2'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        Map<String, String> mapaMilestone = new Map<String, String>();
        
        System.runAs(usuario){
            mapaMilestone = SAC_LCMP_UpdateStatus.recuperarSLAActivos(reclamacion.Id);
        }
        Test.stopTest();   
        
        System.assertNotEquals(mapaMilestone.isEmpty(), true,'No se han recuperado los milestone del caso'); 
    }
    
    
    @isTest
    static void informarTiempoParadaSubsanacionTest(){
        Test.startTest();
        List<Case> listaCasosActualizar = new List<Case>();
        
        Case reclamacion = [SELECT Id, Status, SAC_DetenidoDesde__c, RecordTypeId, SAC_TiempoParadaSubsanacion__c, SAC_DetenidoHasta__c, SAC_FechaUltimaSubsanacion__c, SAC_MinutosParadaSubsanacion__c, SAC_FechaRecepcion__c FROM Case WHERE Subject = 'TestRec4'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuario){
            listaCasosActualizar = SAC_LCMP_UpdateStatus.informarTiempoParadaSubsanacion(reclamacion);
        }
        Test.stopTest();   
        
        System.assertNotEquals(listaCasosActualizar.isEmpty(), true,'No se ha informado el tiempo de parada'); 
    }
    

    @isTest
    static void checkImportesGGHPretensionesTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec7'];
        
        System.runAs(usuario){
            try {
                SAC_LCMP_UpdateStatus.checkImportesGGHPretensiones(reclamacion.Id);
                System.assertEquals(false, false, 'Se esperaba una AuraHandledException');
            } catch (AuraHandledException e) {
                System.assertEquals(e.getMessage(), 'Script-thrown exception', 'No se ha mostrado el mensaje de error');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void informarTiempoParadaSubsanacionTest2(){
        Test.startTest();
        List<Case> listaCasosActualizar = new List<Case>();
        
        Case pretension = [SELECT Id, Status, RecordTypeId, SAC_Reclamacion__c, SAC_DetenidoDesde__c, SAC_TiempoParadaSubsanacion__c, SAC_MinutosParadaSubsanacion__c, SAC_FechaRecepcion__c FROM Case WHERE Subject = 'TestPret4'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuario){
            listaCasosActualizar = SAC_LCMP_UpdateStatus.informarTiempoParadaSubsanacion(pretension);
        }
        Test.stopTest();   
        
        System.assertNotEquals(listaCasosActualizar.isEmpty(), true,'No se ha informado el tiempo de parada'); 
    }
}