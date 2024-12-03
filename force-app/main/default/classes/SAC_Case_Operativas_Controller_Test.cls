/*****************************************************************
 * Name: SAC_Case_Operativas_Controller_Test
 * Copyright © 2019  CaixaBank 
 * 
 * Proposito: Testear la clase SAC_Case_Operativas_Controller_Test
 * 
 * Historial 
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US200397         Carlos Solis         23/04/21     Creación
 * 1.1            US204743         Luis Mesa            30/04/21     Adición Métodos Etiquetados
 * 1.2            US200397         Jose Gonzalez        11/06/21     Modificación
 * 1.3			  US507573		   Jose Carlos Blanco	18/01/23	 Modificación (agregada assertion y QualityCloud)
*****************************************************************/
@isTest
public with sharing class SAC_Case_Operativas_Controller_Test {
    @TestSetup
    static void makeData() {

        Account cuenta = new Account();
        cuenta.Name = 'cuentaTest';
        cuenta.CC_Tipo_Centro__c = 'DT';
        Database.insert(cuenta);

        Id cops = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();
        Id recType = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        Id letrados = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_Letrados').getRecordTypeId();
        
        String profileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];

        List<CC_Grupo_Colaborador__c> grupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupoCOPS = new CC_Grupo_Colaborador__c();
        grupoCOPS.name = 'COPS';
        grupoCOPS.SAC_DeveloperName__c = 'COPS';
        grupoCOPS.RecordTypeId = COPS;
        grupoCOPS.SAC_MaximoCasosDiarios__c = 30;
        grupos.add(grupoCOPS);

        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
        grupoColaborador.name = 'grupoColaboradorTest';
        grupoColaborador.RecordTypeId = recType;
        grupoColaborador.SAC_PorcentajeAsignacion__c = 100;
        grupoColaborador.SAC_MaximoCasosDiarios__c = 30;
        grupos.add(grupoColaborador);
        
        CC_Grupo_Colaborador__c grupoColaboradorLetrado = new CC_Grupo_Colaborador__c();
        grupoColaboradorLetrado.name = 'grupoColaboradorTestLetrado';
        grupoColaboradorLetrado.RecordTypeId = letrados;
        grupoColaboradorLetrado.SAC_PorcentajeAsignacion__c = 100;
        grupoColaboradorLetrado.SAC_MaximoCasosDiarios__c = 30;
        grupos.add(grupoColaboradorLetrado);

        CC_Grupo_Colaborador__c grupoDXC = new CC_Grupo_Colaborador__c();
        grupoDXC.name = 'grupoDXC';
        grupoDXC.RecordTypeId = cops;
        grupoDXC.SAC_MaximoCasosDiarios__c = 30;
        grupoDXC.SAC_DeveloperName__c = 'DXC Zaragoza';
        grupos.add(grupoDXC);

        Database.insert(grupos);

        // Usuarios a usar en las test
        User usuario1 = new User();
        usuario1.Username = 'Name124@test.com';
        usuario1.Email = 'email@test.com';
        usuario1.LastName = 'Usuario Test';
        usuario1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'GMT';
        usuario1.LocaleSidKey = 'es_ES';
        usuario1.EmailEncodingKey = 'ISO-8859-1';
        usuario1.LanguageLocaleKey = 'en_US';
        usuario1.isActive = true;
        //Database.insert(usuario1);

        User usuarioGeneral = new User();
        usuarioGeneral.Username = 'usergeneral11111@test.com';
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
        
        User usuarioGeneralLetrado = new User();
        usuarioGeneralLetrado.Username = 'usergeneralLetrado@test.com';
        usuarioGeneralLetrado.Email = 'emailLetrado@test.com';
        usuarioGeneralLetrado.LastName = 'usuarioGeneralLetrado Test';
        usuarioGeneralLetrado.ProfileId = profileId;
        usuarioGeneralLetrado.Alias = 'aliasL';
        usuarioGeneralLetrado.TimeZoneSidKey = 'GMT';
        usuarioGeneralLetrado.LocaleSidKey = 'es_ES';
        usuarioGeneralLetrado.EmailEncodingKey = 'ISO-8859-1';
        usuarioGeneralLetrado.LanguageLocaleKey = 'en_US';
        usuarioGeneralLetrado.SAC_GruposPerteneciente__c = grupoColaboradorLetrado.id;
        usuarioGeneralLetrado.isActive = true;       


        User usuarioFallo = new User();
        usuarioFallo.Username = 'userfallo0983257@test.com';
        usuarioFallo.Email = 'email2@test.com';	
        usuarioFallo.LastName = 'usuarioFallo Test';
        usuarioFallo.ProfileId = profileId;
        usuarioFallo.Alias = 'aliasF';
        usuarioFallo.TimeZoneSidKey = 'GMT';
        usuarioFallo.LocaleSidKey = 'es_ES';
        usuarioFallo.EmailEncodingKey = 'ISO-8859-1';
        usuarioFallo.LanguageLocaleKey = 'en_US';
        usuarioFallo.SAC_GruposPerteneciente__c = grupoColaboradorLetrado.id;
        usuarioFallo.isActive = true; 

        User usuario2 = new User();
        usuario2.Username = 'usertest49i2342@test.test';
        usuario2.Email = 'emailtest@test.test';	
        usuario2.LastName = 'usuario2 Test';
        usuario2.ProfileId = profileId;
        usuario2.Alias = 'alias2';
        usuario2.TimeZoneSidKey = 'GMT';
        usuario2.LocaleSidKey = 'es_ES';
        usuario2.EmailEncodingKey = 'ISO-8859-1';
        usuario2.LanguageLocaleKey = 'en_US';
        usuario2.isActive = true; 

        List<User> listadoUsuarios = new List<User>();
        listadoUsuarios.add(usuario1);
        listadoUsuarios.add(usuarioGeneral);
        listadoUsuarios.add(usuarioFallo);
        listadoUsuarios.add(usuario2);

        Database.insert(listadoUsuarios);

        List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
        CC_Grupo_Colaborador_Contact__c grupoColabContact = new CC_Grupo_Colaborador_Contact__c();
        grupoColabContact.CC_Grupo_Colaborador__c = grupoColaborador.id;
        grupoColabContact.CC_Usuario__c = usuarioGeneral.id;
        grupoColabContact.SAC_Supervisor__c = true;
        
        CC_Grupo_Colaborador_Contact__c grupoColabContactLetrado = new CC_Grupo_Colaborador_Contact__c();
        grupoColabContactLetrado.CC_Grupo_Colaborador__c = grupoColaboradorLetrado.id;
        grupoColabContactLetrado.CC_Usuario__c = usuarioFallo.id;
        grupoColabContactLetrado.SAC_Administrador__c = true;

        CC_Grupo_Colaborador_Contact__c grupoColabContactLetrado2 = new CC_Grupo_Colaborador_Contact__c();
        grupoColabContactLetrado2.CC_Grupo_Colaborador__c = grupoColaboradorLetrado.id;
        grupoColabContactLetrado2.CC_Usuario__c = usuarioGeneral.id;
        grupoColabContactLetrado2.SAC_Administrador__c = true;

        CC_Grupo_Colaborador_Contact__c grupoColabContact2 = new CC_Grupo_Colaborador_Contact__c();
        grupoColabContact2.CC_Grupo_Colaborador__c = grupoColaborador.id;
        grupoColabContact2.CC_Usuario__c = usuario2.id;

        CC_Grupo_Colaborador_Contact__c grupoColabContact3 = new CC_Grupo_Colaborador_Contact__c();
        grupoColabContact3.CC_Grupo_Colaborador__c = grupoCOPS.id;
        grupoColabContact3.CC_Usuario__c = usuario2.id;


        listaColaboradores.add(grupoColabContact);
        listaColaboradores.add(grupoColabContact3);
        listaColaboradores.add(grupoColabContact2);
        listaColaboradores.add(grupoColabContactLetrado);
        listaColaboradores.add(grupoColabContactLetrado2);
        Database.insert(listaColaboradores);
        
		Test.startTest();

        Group supervisores = [SELECT id FROM Group WHERE DeveloperName = 'SAC_PteSupervisor'];

        List<Case> listaReclamaciones = new List<Case>();
        Case caso = new Case();
        caso.Subject = 'ReclamacionTest';
        caso.Status = 'Pre-Alta';
        caso.SAC_StatusAuxiliar__c = caso.Status;
        caso.SEG_Grupo__c = grupoColaborador.id;
        caso.AccountId = cuenta.Id;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        caso.OwnerId = usuarioGeneral.Id;
        listaReclamaciones.add(caso);

        //RECLAMACION 1 - NECESITO SU ID PARA EJECUTAR EL METODO 1     
        Case casoReclamacion = new Case();
        casoReclamacion.Subject = 'TestRec';
        casoReclamacion.Origin = 'Backoffice';
        casoReclamacion.Status = 'SAC_001';
        casoReclamacion.SAC_StatusAuxiliar__c = casoReclamacion.Status;
        casoReclamacion.AccountId = cuenta.Id;
        casoReclamacion.OwnerId = usuarioGeneral.Id;
        casoReclamacion.SEG_Grupo__C = grupoColaboradorLetrado.id;
        casoReclamacion.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        casoReclamacion.SAC_UserElevoASupervisor__c = usuarioGeneral.Id;
        listaReclamaciones.add(casoReclamacion);

        //RECLAMACION 2 - PARA AUTOASIGNAR CASO   
        Case casoReclamacion2 = new Case();
        casoReclamacion2.Subject = 'TestRec2';
        casoReclamacion2.Origin = 'Backoffice';
        casoReclamacion2.Status = 'Alta';
        casoReclamacion2.SAC_StatusAuxiliar__c = casoReclamacion2.Status;
        casoReclamacion2.SEG_Grupo__c = grupoColaborador.Id;
        casoReclamacion2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        casoReclamacion2.OwnerId = usuarioFallo.Id;
        listaReclamaciones.add(casoReclamacion2);


        Case testRecCC = new Case();
        testRecCC.Subject = 'TestRecCC';
        testRecCC.Origin = 'Backoffice';
        testRecCC.Status = 'Alta';
        testRecCC.AccountId = cuenta.Id;
        testRecCC.SAC_StatusAuxiliar__c = casoReclamacion2.Status;
        testRecCC.SEG_Grupo__c = grupoColaborador.Id;
        testRecCC.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        testRecCC.OwnerId = usuarioGeneral.Id;
        listaReclamaciones.add(testRecCC);

        //RECLAMACION 3   
        Case casoReclamacion3 = new Case();
        casoReclamacion3.Subject = 'TestRec3';
        casoReclamacion3.Origin = 'Backoffice';
        casoReclamacion3.Status = 'Alta';
        casoReclamacion3.SAC_StatusAuxiliar__c = casoReclamacion3.Status;
        casoReclamacion3.AccountId = cuenta.Id;
        casoReclamacion3.OwnerId = usuarioGeneral.Id;
        casoReclamacion3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        listaReclamaciones.add(casoReclamacion3);

        //RECLAMACION 4
        Case casoReclamacion4 = new Case();
        casoReclamacion4.Subject = 'TestRec4';
        casoReclamacion4.Origin = 'Backoffice';
        casoReclamacion4.Status = 'SAC_003';
        casoReclamacion4.SAC_StatusAuxiliar__c = casoReclamacion4.Status;
        casoReclamacion4.AccountId = cuenta.Id;
        casoReclamacion4.OwnerId = usuarioGeneral.Id;
        casoReclamacion4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        listaReclamaciones.add(casoReclamacion4);

        //RECLAMACION 5
        Case casoReclamacion5 = new Case();
        casoReclamacion5.Subject = 'TestRec5';
        casoReclamacion5.Origin = 'Backoffice';
        casoReclamacion5.Status = 'Rechazado';
        casoReclamacion5.SAC_StatusAuxiliar__c = casoReclamacion5.Status;
        casoReclamacion5.AccountId = cuenta.Id;
        casoReclamacion5.OwnerId = usuarioGeneral.Id;
        casoReclamacion5.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        listaReclamaciones.add(casoReclamacion5);

        //Reclamacion 6 
        Case casoReclamacion6 = new Case();
        casoReclamacion6.Subject = 'TestCOPS';
        casoReclamacion6.Origin = 'Backoffice';
        casoReclamacion6.Status = 'Alta';
        casoReclamacion6.SAC_StatusAuxiliar__c = casoReclamacion6.Status;
        casoReclamacion6.SEG_Grupo__c = grupoCOPS.Id;
        casoReclamacion6.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        casoReclamacion6.OwnerId = usuario2.Id;
        listaReclamaciones.add(casoReclamacion6);

        //Reclamacion 7 - Caso PSD2 Respuesta Email
        Case casoReclamacion7 = new Case();
        casoReclamacion7.Subject = 'Caso PSD2 Email';
        casoReclamacion7.Origin = 'Backoffice';
        casoReclamacion7.Status = 'Alta';
        casoReclamacion7.SAC_StatusAuxiliar__c = casoReclamacion7.Status;
        casoReclamacion7.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        casoReclamacion7.OwnerId = usuarioGeneral.Id;
        casoReclamacion7.CC_Canal_Respuesta__c = 'Email';
        listaReclamaciones.add(casoReclamacion7);

        //Reclamacion 8 - Caso PSD2 Respuesta Postal
        Case casoReclamacion8 = new Case();
        casoReclamacion8.Subject = 'Caso PSD2 Postal';
        casoReclamacion8.Origin = 'Backoffice';
        casoReclamacion8.Status = 'Alta';
        casoReclamacion8.SAC_StatusAuxiliar__c = casoReclamacion8.Status;
        casoReclamacion8.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        casoReclamacion8.OwnerId = usuarioGeneral.Id;
        casoReclamacion8.CC_Canal_Respuesta__c = 'SAC_CartaPostal';
        casoReclamacion8.SAC_DireccionContacto__c = 'test';
        casoReclamacion8.SAC_CodigoPostalContacto__c = '12345';
        casoReclamacion8.SAC_PoblacionContacto__c = 'prorroga';
        casoReclamacion8.SAC_ProvinciaContacto__c = 'PSD2';
        casoReclamacion8.SAC_PaisContacto__c = 'España';
        listaReclamaciones.add(casoReclamacion8);

        //Reclamacion 9 - Caso PSD2 
        Case casoReclamacion9 = new Case();
        casoReclamacion9.Subject = 'Caso PSD2';
        casoReclamacion9.Origin = 'Backoffice';
        casoReclamacion9.Status = 'Alta';
        casoReclamacion9.SAC_StatusAuxiliar__c = casoReclamacion9.Status;
        casoReclamacion9.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        casoReclamacion9.OwnerId = usuarioGeneral.Id;
        casoReclamacion9.CC_Canal_Respuesta__c = 'Phone';
        listaReclamaciones.add(casoReclamacion9);


        //CONSULTA 1
        Case casoConsulta1 = new Case();
        casoConsulta1.Subject = 'TestCons1';
        casoConsulta1.Origin = 'Backoffice';
        casoConsulta1.Status = 'Alta';
        casoConsulta1.SAC_StatusAuxiliar__c = casoConsulta1.Status;
        casoConsulta1.SEG_Grupo__c = grupoColaborador.Id;
        casoConsulta1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
        casoConsulta1.OwnerId = usuarioGeneral.Id;
        casoConsulta1.AccountId = cuenta.Id;
        listaReclamaciones.add(casoConsulta1);

        //CONSULTA 2
        Case casoConsulta2 = new Case();
        casoConsulta2.Subject = 'TestCons2';
        casoConsulta2.Origin = 'Backoffice';
        casoConsulta2.Status = 'Alta';
        casoConsulta2.SAC_StatusAuxiliar__c = casoConsulta2.Status;
        casoConsulta2.SEG_Grupo__c = grupoColaborador.Id;
        casoConsulta2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
        casoConsulta2.OwnerId = usuarioGeneral.Id;
        casoConsulta2.AccountId = cuenta.Id;
        listaReclamaciones.add(casoConsulta2);

        //CONSULTA 3
        Case casoConsulta3 = new Case();
        casoConsulta3.Subject = 'TestCons3';
        casoConsulta3.Origin = 'Backoffice';
        casoConsulta3.Status = 'Alta';
        casoConsulta3.SAC_StatusAuxiliar__c = casoConsulta3.Status;
        casoConsulta3.SEG_Grupo__c = grupoColaborador.Id;
        casoConsulta3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
        casoConsulta3.OwnerId = usuario1.Id;
        casoConsulta3.AccountId = cuenta.Id;
        listaReclamaciones.add(casoConsulta3);

        //CONSULTA 4
        Case casoConsulta4 = new Case();
        casoConsulta4.Subject = 'TestCons4';
        casoConsulta4.Origin = 'Backoffice';
        casoConsulta4.Status = 'SAC_011';
        casoConsulta4.SAC_StatusAuxiliar__c = casoConsulta4.Status;
        casoConsulta4.SEG_Grupo__c = grupoColaborador.Id;
        casoConsulta4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_ConsultaSAC').getRecordTypeId();
        casoConsulta4.OwnerId = usuario1.Id;
        casoConsulta4.AccountId = cuenta.Id;
        listaReclamaciones.add(casoConsulta4);

        Database.insert(listaReclamaciones);
		Test.stopTest();
                   
        //PRETENSION 1 -
        Case casoPretension = new Case();
        casoPretension.SuppliedCompany = 'prueba';
        casoPretension.Origin = 'Backoffice';        
        casoPretension.Status = 'SAC_001';
        casoPretension.SAC_StatusAuxiliar__c = casoPretension.Status;
        casoPretension.AccountId = cuenta.Id;
        casoPretension.SEG_Grupo__C = grupoColaboradorLetrado.id;
        casoPretension.SAC_Reclamacion__c = casoReclamacion.Id;
        casoPretension.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        
        Case casoPretension2 = new Case();
        casoPretension2.SuppliedCompany = 'prueba2';
        casoPretension2.Origin = 'Backoffice';        
        casoPretension2.Status = 'SAC_001';
        casoPretension2.SAC_StatusAuxiliar__c = casoPretension.Status;
        casoPretension2.AccountId = cuenta.Id;
        casoPretension2.SEG_Grupo__C = grupoColaboradorLetrado.id;
        casoPretension2.SAC_Reclamacion__c = casoReclamacion.Id;
        casoPretension.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

        Case casoPretension3 = new Case();
        casoPretension3.SuppliedCompany = 'prueba3';
        casoPretension3.Origin = 'Backoffice';        
        casoPretension3.Status = 'SAC_001';
        casoPretension3.SAC_StatusAuxiliar__c = casoPretension3.Status;
        casoPretension3.AccountId = cuenta.Id;
        casoPretension3.SEG_Grupo__C = grupoCOPS.id;
        casoPretension3.SAC_Reclamacion__c = casoReclamacion6.Id;
        casoPretension.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

        Case casoPretension4 = new Case();
        casoPretension4.SuppliedCompany = 'prueba4';
        casoPretension4.Origin = 'Backoffice';        
        casoPretension4.Status = 'SAC_001';
        casoPretension4.SAC_StatusAuxiliar__c = casoPretension4.Status;
        casoPretension4.AccountId = cuenta.Id;
        casoPretension4.SEG_Grupo__C = grupoCOPS.id;
        casoPretension4.SAC_Reclamacion__c = testRecCC.Id;
        casoPretension4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

        //Pretension PSD2
        Case casoPretension5 = new Case();
        casoPretension5.SuppliedCompany = 'Pret PSD2 Email';
        casoPretension5.Origin = 'Backoffice';        
        casoPretension5.Status = 'SAC_001';
        casoPretension5.SAC_StatusAuxiliar__c = casoPretension5.Status;
        casoPretension5.SAC_Reclamacion__c = casoReclamacion7.Id;
        casoPretension5.SAC_CASE_esPSD2__c = true;
        casoPretension5.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        
        //Pretension PSD2
        Case casoPretension6 = new Case();
        casoPretension6.SuppliedCompany = 'Pret PSD2 Postal';
        casoPretension6.Origin = 'Backoffice';        
        casoPretension6.Status = 'SAC_001';
        casoPretension6.SAC_StatusAuxiliar__c = casoPretension6.Status;
        casoPretension6.SAC_Reclamacion__c = casoReclamacion8.Id;
        casoPretension6.SAC_CASE_esPSD2__c = true;
        casoPretension6.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

        //Pretension PSD2
        Case casoPretension7 = new Case();
        casoPretension7.SuppliedCompany = 'Pret PSD2 Postal';
        casoPretension7.Origin = 'Backoffice';        
        casoPretension7.Status = 'SAC_001';
        casoPretension7.SAC_StatusAuxiliar__c = casoPretension7.Status;
        casoPretension7.SAC_Reclamacion__c = casoReclamacion9.Id;
        casoPretension7.SAC_CASE_esPSD2__c = true;
        casoPretension7.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

        //Lista casos evitar operaciones DML
        List<Case> casosAInsertar = new List<Case>();
        casosAInsertar.add(casoPretension);
        casosAInsertar.add(casoPretension2);
        casosAInsertar.add(casoPretension4);
        casosAInsertar.add(casoPretension5);
        casosAInsertar.add(casoPretension6);
        casosAInsertar.add(casoPretension7);
        Database.insert(casosAInsertar);

        //List Custom Setting
        List<SAC_EmailService__c> customSetting = new List<SAC_EmailService__c>();
        SAC_EmailService__c csMailS = new SAC_EmailService__c();
        csMailS.SAC_GroupName__c = 'DXC Zaragoza';
        csMailS.SAC_RecordTypeDeveloperName__c = 'SAC_Consulta';
        csMailS.Name = 'DXC_Zaragoza';
        csMailS.SAC_EmailEntrante__c = 'dx@zar.com';
        customSetting.add(csMailS);
        Database.insert(customSetting);

        Topic  t = new Topic(Name = 'Topic');
        Database.insert(t);

        TopicAssignment topicAssig = new TopicAssignment(TopicId=t.Id, EntityId=casoReclamacion.Id);
        Database.insert(topicAssig);

        Blob body = blob.valueOf('Unit.Test');
        ContentVersion cv = new ContentVersion(
            Title= 'Carta postal test', 
            PathOnClient ='SampleTitle.pdf',
            VersionData = body,
            FirstPublishLocationId = testRecCC.Id,
            SAC_StringRedaccion_fileupload__c = 'redaccion'
        );
        Database.insert(cv);

        /*EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
        String headerValueSTR = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details FROM above.
        emailMsg.ToAddress = 't@t.com';
        emailMsg.Subject = 'em.Subject';
        emailMsg.HtmlBody = 'em.HtmlBody';
        emailMsg.MessageDate = system.today();
        emailMsg.Status = '3';
        //emailMsg.FromAddress = 'email@test.com';
        emailMsg.ParentId = testRecCC.Id;
        emailMsg.Headers = '[{"value": "' + headerValueSTR + '","name": "X-SDFC-Original-RCPT"}]';

        Database.insert(emailMsg);*/

        System.runAs(usuario1) {
            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuario1.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }

        System.runAs(usuario1){
            EmailTemplate validEmailTemplate = new EmailTemplate(
                isActive = true, 
                Name = 'nombreTest',
                DeveloperName = 'SAC_Test',
                TemplateType = 'text', 
                HtmlValue = '<p>htmlValue<p>', 
                Body = 'Texted', 
                FolderId = usuario1.Id
            );
            Database.insert(validEmailTemplate);  
            
            List<SAC_PlantillaRedaccion__c> plantillas = new List<SAC_PlantillaRedaccion__c>();
            //Plantilla
            SAC_PlantillaRedaccion__c plantilla = new SAC_PlantillaRedaccion__c();
            plantilla.SAC_TipoPlantilla__c = 'SAC_Prorroga';
            plantilla.SAC_CanalRespuesta__c = 'Email';
            plantilla.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
            plantilla.SAC_PlantillaCatalanId__c = validEmailTemplate.Id;
            plantilla.SAC_PlantillaInglesId__c = validEmailTemplate.Id;
            plantilla.RecordTypeId = Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Redaccion').getRecordTypeId();
            plantilla.Name = 'testPlantilla';
            plantillas.add(plantilla);

            //Plantilla 2
            SAC_PlantillaRedaccion__c plantilla2 = new SAC_PlantillaRedaccion__c();
            plantilla2.SAC_TipoPlantilla__c = 'SAC_Prorroga';
            plantilla2.SAC_CanalRespuesta__c = 'SAC_CartaPostal';
            plantilla2.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
            plantilla2.SAC_PlantillaCatalanId__c = validEmailTemplate.Id;
            plantilla2.SAC_PlantillaInglesId__c = validEmailTemplate.Id;
            plantilla2.RecordTypeId = Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Redaccion').getRecordTypeId();
            plantilla2.Name = 'testPlantilla2';
            plantillas.add(plantilla2);

            Database.insert(plantillas);
        }  
    }

    @isTest
    static void tomarPropiedadCasoTest() {

        Test.startTest();
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias' and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        Case caso = [SELECT id, Status, SEG_Grupo__C, OwnerId, AccountId, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case WHERE subject = 'ReclamacionTest' limit 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuario) {
            SAC_Case_Operativas_Controller.tomarPropiedadCaso(caso.id, usuario.id);
        }
        Case casoActualizado = [SELECT id, Status, SEG_Grupo__C, OwnerId, AccountId, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case WHERE subject = 'ReclamacionTest' limit 1];
        Test.stopTest();
        system.assertEquals(usuario.Id, casoActualizado.ownerId, 'No se ha podido tomar propiedad del caso');
    }

    @isTest
    static void tomarPropiedadCasoTestNegativo() {
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias' and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        Case caso = [SELECT id, Status, SEG_Grupo__C, OwnerId, AccountId, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case limit 1];
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);
        try {
            Test.startTest();
            System.runAs(usuario) {
            	SAC_Case_Operativas_Controller.tomarPropiedadCaso(caso.id, usuario.id);
        	}
            Test.stopTest();
        } catch (AuraHandledException except) {
            system.assertNotEquals(usuario.Id, caso.ownerId, 'No ha salido la condicion "No tienes permisos"');
        }
    }
    @isTest
    static void autoasignarPropiedadCasoTest() {
       
        Test.startTest();
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias' and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        Case caso = [SELECT id, Subject, Status, SEG_Grupo__C, OwnerId, AccountId, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case WHERE Subject = 'TestRec2' limit 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuario) {
            SAC_Case_Operativas_Controller.autoasignarPropiedadCaso(caso.Id, usuario.Id);
        }
        
        Case casoActualizado = [SELECT id, Subject, Status, SEG_Grupo__C, OwnerId, AccountId, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case WHERE Subject = 'TestRec2'limit 1];
        Test.stopTest();
        system.assertEquals(usuario.Id, casoActualizado.ownerId, 'No se ha podido autoasignar la propiedad del caso');
    }
    @isTest
    static void recuperarUserTest() {
        Case caso = [SELECT id, OwnerId, SEG_Grupo__c FROM Case WHERE Subject = 'ReclamacionTest'];
        User usuario = [SELECT id, name FROM user WHERE Alias = 'alias' and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
		PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Map<String,String> resultado = new Map<String,String>();

        System.runAs(usuario) {
            Test.startTest();            
            resultado = SAC_Case_Operativas_Controller.recuperarUser(caso, caso.OwnerId);
            Test.stopTest();
        }
        system.assertNotEquals(null, resultado, 'No se ha recuperado el usuario');
    }

    /** INI - ADD: US204743 -> Luis Mesa Garcia
     * 
     *  Métodos test para funcionalidad historia de usuario US204743: Alta Pretensiones
     *  
     */

    @isTest
    static void marcarPretensionPrincipalTest() {
        Case pretension = [SELECT id, SAC_Reclamacion__r.Status, SAC_Reclamacion__c, SAC_Entidad_Afectada__c, SAC_EntidadProductora__c FROM Case WHERE SuppliedCompany = 'prueba'];
        Case reclamacionPretensionPrincipal = [SELECT id, SAC_PretensionPrincipal__c FROM Case WHERE subject = 'TestRec'];
		User usuario = [SELECT id FROM User WHERE Username = 'Name124@test.com' AND isActive = true Limit 1];

        System.runAs(usuario) {
            Test.startTest();
        	SAC_Case_Operativas_Controller.marcarPretensionPrincipal(pretension);
            Test.stopTest();
        }
        
        Case reclamacionPretensionPrincipal2 = [SELECT id, SAC_PretensionPrincipal__c FROM Case WHERE subject = 'TestRec'];
        system.assertNotEquals(reclamacionPretensionPrincipal.SAC_PretensionPrincipal__c,reclamacionPretensionPrincipal2.SAC_PretensionPrincipal__c, 'No se ha podido actualizar la pretension principal');
    }

    @isTest
    static void auraHandledExceptionTest() {
        
        Test.startTest();
            Case pretension = [SELECT id, SAC_Reclamacion__r.Status, SAC_Reclamacion__c, SAC_Entidad_Afectada__c, SAC_EntidadProductora__c FROM Case WHERE SuppliedCompany = 'prueba'];
            User usuarioFalso = [SELECT id FROM User WHERE alias = 'aliasF'  and isActive = true Limit 1];
            system.runAs(usuarioFalso){
                try{
                    SAC_Case_Operativas_Controller.marcarPretensionPrincipal(pretension);
                }
                catch(AuraHandledException e){
                    system.assertEquals( null, null, 'La ejecucion no ha podido obtener la lista de reclamaciones asignadas al mismo propietario que la reclamacion actual');
                }
            }
        Test.stopTest();
    }
    
    @isTest
    static void multiplesCasosMismoAccountTest(){

        Case reclamacion = [SELECT id FROM Case WHERE Subject = 'TestRec'];
        User usuario = [SELECT id FROM User WHERE alias = 'alias'  and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        reclamacion.ownerId = usuario.Id;
        Boolean resultado = false;
        Test.startTest();
        System.runAs(usuario) {
        	resultado = SAC_Case_Operativas_Controller.multiplesCasosMismoAccount(reclamacion.Id, usuario.Id);
        }
        
        Test.stopTest();

        system.assertEquals(false, resultado, 'La ejecucion no se ha podido realizar');
    }

    /** FIN - ADD: US204743 -> Luis Mesa Garcia
     * 
     *  Métodos test para funcionalidad historia de usuario US204743: Alta Pretensiones
     *  
     */

	 @isTest
    static void devolverCasoTest() {
        
        Test.startTest();
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias'  and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        Case caso = [SELECT id, Status, SEG_Grupo__C, OwnerId, AccountId, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case WHERE subject = 'ReclamacionTest' limit 1];
        
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuario) {
            SAC_Case_Operativas_Controller.devolverCaso(caso.id, null);
            
        }
        Test.stopTest();
		Case casoActualizado = [SELECT id, Status, SAC_NumDevoluciones__c,SAC_Motivo__c, OwnerId FROM Case WHERE subject = 'ReclamacionTest' limit 1];
		List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar'];
        system.assertEquals(cola[0].Id, casoActualizado.ownerId, 'No se ha podido devolver el caso');
		system.assertEquals(1, casoActualizado.SAC_NumDevoluciones__c, 'No se ha podido devolver el caso');
		system.assertEquals(null, casoActualizado.SAC_Motivo__c, 'No se ha podido devolver el caso');
    }
	@isTest
    static void fetchMotivos() {
		
        Test.startTest();
        User usuario = [SELECT id, name FROM User WHERE alias = 'alias'  and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);
		Map<String, String> mapMotivos;

        System.runAs(usuario) {
            mapMotivos = SAC_Case_Operativas_Controller.fetchMotivos();
        }
        Test.stopTest();
        System.assertNotEquals(null, mapMotivos, 'Valor retornado');
	}
	@isTest
    static void postOnChatterTest() {
        
        Test.startTest();
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias'  and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        Case caso = [SELECT id, Status, SEG_Grupo__C, OwnerId, AccountId, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case WHERE subject = 'ReclamacionTest' limit 1];
        
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuario) {
            SAC_Case_Operativas_Controller.postOnChatter(caso.id, 'Observación ejemplo', null);
            
        }
        Test.stopTest();
		List<FeedItem> feeds = [SELECT Id, Body FROM FeedItem WHERE ParentId =:caso.Id];
        system.assertNotEquals(null, feeds[0].Body, 'Se ha devuelto el caso a la cola genérica\n Observación: Observación ejemplo');
    }

    @isTest
    static void postOnChatterDescartarTest() {
        
        Test.startTest();
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias'  and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        Case caso = [SELECT id, Status, SEG_Grupo__C, OwnerId, AccountId, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case WHERE subject = 'ReclamacionTest' limit 1];
        
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuario) {
            SAC_Case_Operativas_Controller.postOnChatterDescartar(caso.id, 'Observación ejemplo', null);
            
        }
        Test.stopTest();
		List<FeedItem> feeds = [SELECT Id, Body FROM FeedItem WHERE ParentId =:caso.Id];
        system.assertNotEquals(null, feeds[0].Body, 'Se ha descartado la consulta por siguiente motivo: null\n Observación: Observación ejemplo');
    }

    
    @isTest
    static void derivarACCTest(){
        
        Test.startTest();
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias'  and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        Case caso = [SELECT id, Status, SEG_Grupo__C, OwnerId, AccountId, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case WHERE subject = 'TestRecCC' limit 1];

        
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuario) {
            SAC_Case_Operativas_Controller.derivarACC(caso.id);
        }
        Test.stopTest();
        Case casov2 = [SELECT id, Status, SEG_Grupo__C, OwnerId, AccountId, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case WHERE subject = 'TestRecCC' limit 1];
        system.assertNotEquals(caso.Status, casov2.Status, 'Ha fallado derivar el caso a CC.');
    }

    @isTest
    static void tienePretensionesTest(){

        SAC_Case_Operativas_Controller.WrapperPretensiones resultado =  new SAC_Case_Operativas_Controller.WrapperPretensiones(false, false);

        Test.startTest();
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias'  and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        Case caso = [SELECT id, Status, SEG_Grupo__C, OwnerId, AccountId, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case WHERE subject = 'TestRec2' limit 1];
        
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuario) {
            resultado = SAC_Case_Operativas_Controller.tienePretensiones(caso.id);
        }
        Test.stopTest();

        system.assertEquals(resultado.tienePretensiones, false, 'Ha fallado el comprobar.');
    }

    @isTest
    static void multiplesCasosMismoAccountConsultaTest() {
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias'  and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        Case caso = [SELECT id, Status, OwnerId, AccountId FROM Case WHERE subject = 'TestCons1' LIMIT 1];
        Boolean resultado = false;
		PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Test.startTest();
        System.runAs(usuario) {
            resultado = SAC_Case_Operativas_Controller.multiplesCasosMismoAccountConsulta(caso.Id, caso.OwnerId);
        }
        Test.stopTest();

        system.assertEquals(true, resultado, 'Ha fallado el comprobar.');
    }

    @isTest
    static void multiplesCasosMismoAccountAsignadosTest() {
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias'  and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        Case caso = [SELECT id, Status, OwnerId, AccountId FROM Case WHERE subject = 'TestRec3' LIMIT 1];
        Boolean resultado = false;
		PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Test.startTest();
        system.runAs(usuario) {
        	resultado = SAC_Case_Operativas_Controller.multiplesCasosMismoAccountAsignados(caso.Id, caso.OwnerId);
        }    
        Test.stopTest();

        system.assertEquals(true, resultado, 'Ha fallado el comprobar.');
    }

    @isTest
    static void casosMismoAccountAsignadosConsultaTest() {
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias'  and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        Case caso = [SELECT id, Status, OwnerId, AccountId FROM Case WHERE subject = 'TestCons2' LIMIT 1];
        Boolean resultado = false;
		PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Test.startTest();
        system.runAs(usuario) {
        	resultado = SAC_Case_Operativas_Controller.casosMismoAccountAsignadosConsulta(caso.Id, caso.OwnerId);
        }   
        Test.stopTest();

        system.assertEquals(true, resultado, 'Ha fallado el comprobar.');
    }

    @isTest
    static void tomarPropiedadCasoConsultaFalloTest() {
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias'  and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        Case caso = [SELECT id, Status, OwnerId, AccountId FROM Case WHERE subject = 'TestCons3' LIMIT 1];
		PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Test.startTest();
        system.runAs(usuario) {
        	try {
            	SAC_Case_Operativas_Controller.tomarPropiedadCasoConsulta(caso.Id, caso.OwnerId);
        	} catch (Exception except) {
            	system.assertNotEquals(null, except, 'Ha tomado propiedad.');
        	}
        }  
        
        Test.stopTest();
    }

    @isTest
    static void modificarEstadoCasoTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'Name124@test.com' AND isActive = true Limit 1];
        Case caso = [SELECT id, Status, OwnerId, AccountId FROM Case WHERE subject = 'TestCons3' LIMIT 1];

        Test.startTest();
        system.runAs(usuario) {
        	SAC_Case_Operativas_Controller.modificarEstadoCaso(caso.Id, 'SAC_002', 'SAC_FaltaInstrucciones');
        }
        
        Test.stopTest();
        Case caso2 = [SELECT id, Status, OwnerId, AccountId FROM Case WHERE subject = 'TestCons3' LIMIT 1];
        system.assertNotEquals(caso.Status, caso2.Status, 'No se ha podido cambiar el estado de la consulta');
    }

    @isTest
    static void descartarConsultaTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'Name124@test.com' AND isActive = true Limit 1];

        Case caso = [SELECT id, Status, OwnerId, AccountId FROM Case WHERE subject = 'TestCons3' LIMIT 1];
        Test.startTest();
        system.runAs(usuario) {
        	SAC_Case_Operativas_Controller.descartarConsulta(caso.Id, 'SAC_013', 'SAC_Reiterativo');
        }
        
        Test.stopTest();
        Case caso2 = [SELECT id, Status, OwnerId, AccountId FROM Case WHERE subject = 'TestCons3' LIMIT 1];
        system.assertNotEquals(caso.Status, caso2.Status, 'No se ha podido cambiar el estado de la consulta');
    }


    @isTest
    static void convertirReclamacionTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usergeneral11111@test.com' AND isActive = true Limit 1];
        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        Database.insert(psa);

        Case caso = [SELECT id, Status, OwnerId, AccountId FROM Case WHERE subject = 'TestRec' LIMIT 1];
        Test.startTest();
        system.runAs(usuario) {
        	SAC_Case_Operativas_Controller.convertirReclamacion(caso.Id, 'ConsultaCOPS');
        }
        
        Test.stopTest();
        Case caso2 = [SELECT id, Status, OwnerId, AccountId FROM Case WHERE subject = 'TestRec' LIMIT 1];
        system.assertEquals('Rechazado', caso2.Status, 'No se ha rechazado por conversion la reclamacion');
    }

    @isTest
    static void convertirReclamacionTest2() {
        User usuario = [SELECT id FROM User WHERE Username = 'usergeneral11111@test.com' AND isActive = true Limit 1];
        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        Database.insert(psa);

        Case caso = [SELECT id, Status, OwnerId, AccountId FROM Case WHERE subject = 'TestCons3' LIMIT 1];
        Test.startTest();
        system.runAs(usuario) {
        	SAC_Case_Operativas_Controller.convertirReclamacion(caso.Id, 'Consulta');
        }
        
        Test.stopTest();
        Case caso2 = [SELECT id, Status, OwnerId, AccountId FROM Case WHERE subject = 'TestCons3' LIMIT 1];
        system.assertEquals('Rechazado', caso2.Status, 'No se ha rechazado por conversion la consulta');
    }

    @isTest
    static void convertirReclamacionTest3() {
        User usuario = [SELECT id FROM User WHERE Username = 'usergeneral11111@test.com' AND isActive = true Limit 1];
        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        Database.insert(psa);

        Case caso = [SELECT id, Status, OwnerId, AccountId FROM Case WHERE subject = 'TestCons4' LIMIT 1];
        Test.startTest();
        system.runAs(usuario) {
        	SAC_Case_Operativas_Controller.convertirReclamacion(caso.Id, 'Reclamacion');
        }
        
        Test.stopTest();
        Case caso2 = [SELECT id, RecordType.DeveloperName FROM Case WHERE subject = 'TestRec3' LIMIT 1];
        system.assertEquals('SAC_Reclamacion', caso2.RecordType.DeveloperName, 'No se ha convertido correctamente la consulta');
    }

    @isTest
    static void copiarEmailAdjuntosTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usergeneral11111@test.com' AND isActive = true Limit 1];

        Case reclamacion = [SELECT id, Status, OwnerId, AccountId FROM Case WHERE subject = 'TestRecCC' LIMIT 1];

        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob2=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob2; 
        content.origin = 'H';
        Database.insert(content);

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId = reclamacion.id;
        contentlink.contentdocumentid=[SELECT contentdocumentid FROM contentversion WHERE id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';        
        
        Database.insert(contentlink);

        
        Case reclamacion2 = [SELECT id, Status, OwnerId, AccountId FROM Case WHERE subject = 'TestRec3' LIMIT 1];

        Test.startTest();
        system.runAs(usuario) {
        	SAC_Case_Operativas_Controller.copiarEmailsAdjuntos(reclamacion.id, reclamacion2.id);
        }
        
        Test.stopTest();
        List<ContentDocumentLink> listaConDocLink = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,
                    ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId =: reclamacion2.id];
        system.assertNotEquals(null, listaConDocLink, 'No se ha copiado el documento');
    }

    @isTest
    static void getPickListValuesIntoListTest() {
		User usuario = [SELECT id, name FROM user WHERE alias = 'alias'  and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        List<SAC_Case_Operativas_Controller.plantillasWrapper> plantillas = new List<SAC_Case_Operativas_Controller.plantillasWrapper>();
        Test.startTest();
        system.runAs(usuario) {
        	plantillas = SAC_Case_Operativas_Controller.getPickListValuesIntoList();
        }
        
        Test.stopTest();
        System.assertNotEquals(null, plantillas, 'No hay plantillas');
    }

    @isTest
    static void escalarCOPSTest(){
		User usuario = [SELECT id FROM User WHERE Username = 'Name124@test.com' AND isActive = true Limit 1];

        Case caso = [SELECT Id, Status, OwnerId, AccountId FROM Case WHERE Subject = 'TestCons3' LIMIT 1];
        Test.startTest();
        system.runAs(usuario) {
        	SAC_Case_Operativas_Controller.escalarCOPS(caso.Id, 'motivo');
        }
        
        Test.stopTest();
        Case caso2 = [SELECT Id, Status, OwnerId, AccountId FROM Case WHERE Subject = 'TestCons3' LIMIT 1];
        
        System.assertNotEquals(caso.OwnerId, caso2.OwnerId, 'La escalada a COPS no ha funcionado.');
    }

    @isTest
    static void retornarEscaladoConsultaTest(){
		User usuario = [SELECT id FROM User WHERE Username = 'Name124@test.com' AND isActive = true Limit 1];
  
        Case caso = [SELECT Id, Status, OwnerId, AccountId FROM Case WHERE Subject = 'TestCons3' LIMIT 1];
        Test.startTest();
        system.runAs(usuario) {
        	SAC_Case_Operativas_Controller.retornarEscaladoConsulta(caso.Id, 'motivo');
        }
        
        Test.stopTest();
        Case caso2 = [SELECT Id, Status, OwnerId, AccountId FROM Case WHERE Subject = 'TestCons3' LIMIT 1];
        
        System.assertNotEquals(caso.OwnerId, caso2.OwnerId, 'La devolucion de escalada a COPS no ha funcionado.');
    } 
    
    @isTest
    static void esPropietarioFamiliaCasoTest(){
		User usuario = [SELECT id, name FROM user WHERE alias = 'alias'  and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Test.startTest();
        Boolean respuesta = false;        
        Case caso = [SELECT Id, Status, OwnerId, AccountId FROM Case WHERE SuppliedCompany = 'prueba' LIMIT 1]; 
        system.runAs(usuario) {
        	respuesta = SAC_Case_Operativas_Controller.esPropietarioFamiliaCaso(caso.Id, usuario.id);
        }
        
        Test.stopTest();
        System.assertEquals(True, respuesta, 'No tiene permisos');
    } 

    @isTest
    static void reabrirConsultaTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'Name124@test.com' AND isActive = true Limit 1];

        Case reclamacion = [SELECT Id, Status, OwnerId, AccountId FROM Case WHERE SuppliedCompany = 'prueba' LIMIT 1];   
        
        reclamacion.Status = 'SAC_005';
        reclamacion.SAC_StatusAuxiliar__c = 'SAC_005';
        Database.update(reclamacion);

        String motivo = 'test';
        system.runAs(usuario) {
        	SAC_Case_Operativas_Controller.reabrirConsulta(reclamacion.Id, motivo);
        }
        
        Case reclamacion2 = [SELECT Id, Status FROM Case WHERE SuppliedCompany = 'prueba'];
        Test.stopTest();
        
        system.assertEquals(reclamacion.Status, 'SAC_005','No se ha podido actualizar el estado de la Reclamación. Falla parte 1');
        system.assertEquals(reclamacion2.Status, 'SAC_001', 'No se ha podido actualizar el estado de la Reclamación. Falla parte 2');
    }

    @isTest
    static void reabrirReclamacionTest() {
        Test.startTest();
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias' and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec4'];
		PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);
        system.runAs(usuario) {
            Case pretension = new Case();
            pretension.SAC_Reclamacion__c = reclamacion.Id;
            pretension.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
            pretension.Status = 'Cerrado';
            Database.insert(pretension);

            SAC_Accion__c tarea = new SAC_Accion__c();
            tarea.SAC_Observaciones__c='test observacion test'; 
            tarea.SAC_PlazoMaximo__c = 10;
            tarea.SAC_Reclamacion__c = reclamacion.id;
            tarea.RecordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_OtrasTareas').getRecordTypeId();
            Database.insert(tarea);
            
            tarea.SAC_Estado__c = 'SAC_PendienteAsignar';
            Database.update(tarea);

            String motivo = 'test';
    
            SAC_Case_Operativas_Controller.reabrirReclamacion(reclamacion.Id, motivo);
            SAC_Accion__c tarea2 = [SELECT Id, SAC_Estado__c, SAC_Reclamacion__c, SAC_Observaciones__c 
                                    FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'test observacion test'];
    
            System.assertNotEquals(tarea.SAC_Estado__c, tarea2.SAC_Estado__c, 'No se ha actualizado el estado de la tarea.');
            System.assertEquals('SAC_StandBy', tarea2.SAC_Estado__c, 'No se ha actualizado el estado de la tarea.');
        }
        Test.stopTest();
        
    }

    @isTest
    static void reabrirReclamacionTest2() {
        Test.startTest();
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias' and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        
        PermissionSet ps = [SELECT id FROM PermissionSet WHERE  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        Database.insert(psa);
        
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec5'];

        system.runAs(usuario) {
            Case pretension = new Case();
            pretension.SuppliedCompany = 'prueba2';
            pretension.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
            pretension.Status = 'SAC_001';
            pretension.SAC_StatusAuxiliar__c = 'SAC_001';
            pretension.SAC_Reclamacion__c = reclamacion.id;
            Database.insert(pretension);

            Case pretensionOld = [SELECT Id, Status, SAC_StatusAuxiliar__c, RecordTypeId, SAC_Reclamacion__c
                                  FROM Case WHERE SuppliedCompany = 'prueba2'];

            pretension.Status = 'SAC_009';
            pretension.SAC_StatusAuxiliar__c = pretension.Status;
            Database.update(pretension);
        
            String motivo = 'test';
            
            SAC_Case_Operativas_Controller.reabrirReclamacion(reclamacion.Id, motivo);
            
            System.assertNotEquals(pretensionOld.Status, pretension.Status, 'No se ha actualizado el estado de la pretensión.');
        }
        Test.stopTest();
    }

    @istest
    static void nuevaReclamacionVinculadaTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'Name124@test.com' AND isActive = true Limit 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec'];
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'prueba'];
        List<Id> listaIdsCasosRetornar = new List<Id>();

        Test.startTest();
        reclamacion.SAC_PretensionPrincipal__c = pretension.id;        

        Database.update(reclamacion);
		system.runAs(usuario) {
        	reclamacion = SAC_Case_Operativas_Controller.recuperarCaso(reclamacion.Id);
        }
        
        
        listaIdsCasosRetornar = SAC_Case_Operativas_Controller.nuevaReclamacionVinculada(reclamacion);
        Test.stopTest();

        System.assertNotEquals(Null, listaIdsCasosRetornar, 'No se ha creado la nueva reclamación');
    }

    @istest
    static void nuevaReclamacionVinculadaPage2Test(){

        Test.startTest();

        User usuario2 = [SELECT id FROM User WHERE Username = 'Name124@test.com' AND isActive = true Limit 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec'];
        Case nuevaReclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec2'];
        
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
        String headerValueSTR = headerValue.LocalPart + '@' + headerValue.EmailDomainName;
    
        EmailMessage em = new EmailMessage(ParentId = reclamacion.id, 
                            SAC_EnvioRedaccion__c = 'primerenvioredaccion',
                            FromAddress = 'email@email.com',
                            ToAddress = 'test06-03-2024-10-24@test1.com.invalid', 
                            CcAddress = 'test06-03-2024-10-24@test2.com.invalid', 
                            BccAddress = 'test06-03-2024-10-24@test3.com.invalid', 
                            Subject = 'Asunto',
                            Incoming = true,
                            Headers = '[{"value": "' + headerValueSTR + '","name": "X-SFDC-Original-RCPT"}]');
        Database.insert(em);

        EmailMessage em2 = [SELECT id FROM EmailMessage WHERE ParentId =: reclamacion.Id];

        Attachment attach = new Attachment();   	
    	attach.Name='Test';
    	Blob bodyBlob = Blob.valueOf('Testing Body of Attachment');
    	attach.body = bodyBlob;
        attach.ParentId = em2.id;       

        Database.insert(attach);

               
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob2=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob2; 
        content.origin = 'H';
        Database.insert(content);

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId = reclamacion.id;
        contentlink.contentdocumentid=[SELECT contentdocumentid FROM contentversion WHERE id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';        
        
        Database.insert(contentlink);

        List<Id> listaIdCasos = new List<Id>();
        listaIdCasos.add(nuevaReclamacion.id);
        listaIdCasos.add(reclamacion.id);
      	System.runAs(usuario2) {
        	SAC_Case_Operativas_Controller.nuevaReclamacionVinculadaPage2(listaIdCasos);
        }

        ContentDocumentLink cdl = [SELECT LinkedEntityId, contentdocumentid   
                                    FROM ContentDocumentLink 
                                    WHERE LinkedEntityId =: nuevaReclamacion.id]; 
        Test.stopTest();

        System.assertNotEquals(Null, cdl, 'No se ha creado el ContentDocumentLink para la nueva reclamación');
    }
 
    @istest
    static void  devolverPretensionesApexTest(){

        Case reclamacion = [SELECT Id,OwnerId FROM Case WHERE Subject = 'TestRec'];
        Case pretension = [SELECT Id,OwnerId FROM Case WHERE SuppliedCompany = 'prueba'];
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias' and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
		PermissionSet ps = [SELECT id FROM PermissionSet WHERE  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);

        Database.insert(psa);
        
        Test.startTest();
        system.runAs(usuario) {
        	SAC_Case_Operativas_Controller.devolverPretensionesApex(reclamacion.id, 'SAC_Otros');
        }
        
        Test.stopTest();
        
        Case pretension2 = [SELECT Id,OwnerId FROM Case WHERE SuppliedCompany = 'prueba'];

        System.assertEquals(pretension.OwnerId, pretension2.OwnerId, 'No se ha tomado propiedad');
    }
    
    @isTest 
    static void propietarioCOPSTest(){
        User usuario = [SELECT id, name FROM user WHERE LastName = 'usuario2 Test' and isActive = true limit 1];
        Case caso = [SELECT id, SAC_PretensionPrincipal__r.SEG_Grupo__c, SEG_Grupo__c FROM Case WHERE ownerId =: usuario.Id LIMIT 1];
        Boolean resultado;
        system.runAs(usuario) {
            Test.startTest();
            resultado = SAC_Case_Operativas_Controller.propietarioCOPSAdministrador(caso);
            Test.stopTest();
        }
        
        System.assertEquals(true, resultado, 'No se ha podido comprobar si es usuario COPS');
    }


    @isTest 
    static void esGrupoLetradoTest(){
        User usuario = [SELECT id, name FROM user WHERE LastName = 'usuarioFallo Test' and isActive = true limit 1];
        PermissionSet ps = [SELECT id FROM PermissionSet WHERE  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);

        Database.insert(psa);
        
        Boolean resultado;
        system.runAs(usuario) {
            Test.startTest();
            resultado = SAC_Case_Operativas_Controller.esGrupoLetrado();
            Test.stopTest();
        }
        
        System.assertEquals(true, resultado, 'No se ha podido comprobar si es usuario perteneciente al grupo letrados');
    }
    
    @isTest
    static void getGruposLetradoTest(){
        User usuario = [SELECT id, name FROM user WHERE LastName = 'usuarioFallo Test' and isActive = true limit 1];
        Map<Id, String> resultado = new Map<Id, String>();
        PermissionSet ps = [SELECT id FROM PermissionSet WHERE  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);

        Database.insert(psa);
        
        Test.startTest();
        system.runAs(usuario) {
        	resultado = SAC_Case_Operativas_Controller.getGruposLetrado();
        }
        
        Test.stopTest();
        
        CC_Grupo_Colaborador__c grupoLetrado = [SELECT id,Name FROM CC_Grupo_Colaborador__c WHERE Name = 'grupoColaboradorTestLetrado'];
        Map<Id, String> resultadoV2 = new Map<Id, String>();
        resultadoV2.put(grupoLetrado.id, grupoLetrado.Name);
        
        System.assertEquals(resultado, resultadoV2, 'No se ha recuperado ningún grupo letrado');
        
    }

    @isTest
    static void resolverCartaPostalTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'Name124@test.com' AND isActive = true Limit 1];
        Case reclamacion = [SELECT id, Status FROM Case WHERE subject = 'TestRec'];
        SAC_DocumentoEnvio__c carta = new SAC_DocumentoEnvio__c(SAC_Provincia__c = 'pruebaTest', SAC_TipoDocumento__c = 'resolución consulta', SAC_Caso__c = reclamacion.Id);
        Database.insert(carta);
        
        Test.startTest();
        System.runAs(usuario) {
            SAC_Case_Operativas_Controller.resolverCartaPostal(reclamacion.Id);
        }
        
        Test.stopTest();
        
        Case reclamacionNew = [SELECT id, Status FROM Case WHERE subject = 'TestRec'];

        System.assertNotEquals(reclamacionNew.Status, reclamacion.Status, 'No se ha resuelto la consulta');
    }
    
    
    @isTest
    static void reasignarPretensionesTest(){
        User usuario = [SELECT id, name FROM user WHERE LastName = 'usuarioFallo Test' and isActive = true limit 1];

        List<PermissionSetAssignment> permisos = new List<PermissionSetAssignment>();

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        permisos.add(permiSetAssi);

        PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuario.Id;
        permiSetAssi2.PermissionSetId = permiSet2.Id;
        permisos.add(permiSetAssi2);

        Database.insert(permisos);
        
        Case reclamacion = [SELECT id FROM Case WHERE subject = 'TestRec'];
        CC_Grupo_Colaborador__c grupoLetrado = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name = 'grupoColaboradorTestLetrado'];
        
        Test.startTest();
        System.runAs(usuario) {
            SAC_Case_Operativas_Controller.reasignarPretensiones(reclamacion.id, grupoLetrado.id, 'motivoTest');
        }
        Test.stopTest();
        
        Case pretensionV2 = [SELECT id, SEG_Grupo__c FROM Case WHERE SuppliedCompany = 'prueba2'];
        
        System.assertEquals(pretensionV2.SEG_Grupo__c, grupoLetrado.id , 'No se ha reasignado las pretensiones');
        
    }

    @isTest
    static void elevarCasoSupervisorTest() {
        Case reclamacion = [SELECT id,SAC_ObservacionesSupervisor__c,SAC_UserElevoASupervisor__c FROM Case WHERE subject = 'TestRec'];
        Case pretension = [SELECT id, SEG_Grupo__c FROM Case WHERE SuppliedCompany = 'prueba'];
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias' and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
		
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuario) {
            Test.startTest();
            SAC_Case_Operativas_Controller.elevarCasoSupervisor(reclamacion, 'test');
            SAC_Case_Operativas_Controller.devolverCasoSupervisores(reclamacion, 'test');
            SAC_Case_Operativas_Controller.elevarCasoSupervisorPre(pretension.id, 'test');
            SAC_Case_Operativas_Controller.devolverPropietarioAnterior(reclamacion, 'test');
            Test.stopTest();
        }
        
        reclamacion = [SELECT id, OwnerId FROM Case WHERE subject = 'TestRec'];
        System.assertNotEquals(null, reclamacion.OwnerId, 'El propietario no puede estar vacio.');
    }


    @isTest
    public static void rellenarCampoCuerpoMensajeProrrogaTest() {
        String stringFinal = '';
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias' and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        PermissionSet ps = [SELECT id FROM PermissionSet WHERE  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        Database.insert(psa);
        
        Case reclamacion = [SELECT id FROM Case WHERE subject = 'TestRec'];


        Test.startTest();
        System.runAs(usuario) {
    		stringFinal = SAC_Case_Operativas_Controller.rellenarCampoCuerpoMensajeProrroga(reclamacion.id);
        }
        Test.stopTest();
        
       	System.assertNotEquals(null, stringFinal, 'El campo HTML de la consulta es nulo');        
    }

    @isTest
    public static void rellenarCampoCuerpoMensajeProrrogaTestEmailPSD2() {
        String stringFinal = '';
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias' and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        PermissionSet ps = [SELECT id FROM PermissionSet WHERE  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        Database.insert(psa);
        
        Case reclamacion = [SELECT id FROM Case WHERE subject = 'Caso PSD2 Email'];
        
        Test.startTest();
        System.runAs(usuario) {
    		stringFinal = SAC_Case_Operativas_Controller.rellenarCampoCuerpoMensajeProrroga(reclamacion.id);
        }
        Test.stopTest();
        
       	System.assertEquals(null, stringFinal, 'El campo HTML de la consulta es nulo');        
    }

    @isTest
    public static void rellenarCampoCuerpoMensajeProrrogaTestPostalPSD2() {
        String stringFinal = '';
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias' and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        PermissionSet ps = [SELECT id FROM PermissionSet WHERE  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        Database.insert(psa);
        
        Case reclamacion = [SELECT id, Subject, CC_Canal_Respuesta__c FROM Case WHERE subject = 'Caso PSD2 Postal'];
        
        Test.startTest();
        System.runAs(usuario) {
            reclamacion.CC_Canal_Respuesta__c = 'SAC_CartaPostal';
            Database.update(reclamacion);
    		stringFinal = SAC_Case_Operativas_Controller.rellenarCampoCuerpoMensajeProrroga(reclamacion.id);
        }
        Test.stopTest();
        
       	System.assertEquals(null, stringFinal, 'El campo HTML de la consulta es nulo');        
    }

    @isTest
    public static void rellenarCampoSubjectMensajeProrrogaTest() {
        String stringFinal = '';
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias' and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        PermissionSet ps = [SELECT id FROM PermissionSet WHERE  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        Database.insert(psa);
        
        Case reclamacion = [SELECT id FROM Case WHERE subject = 'TestRec'];


        Test.startTest();
        System.runAs(usuario) {
    		stringFinal = SAC_Case_Operativas_Controller.rellenarCampoSubjectMensajeProrroga(reclamacion.id);
        }
        Test.stopTest();
        
       	System.assertNotEquals(null, stringFinal, 'El campo HTML de la consulta es nulo');        
    }

    @isTest
    public static void rellenarCampoSubjectMensajeProrrogaTestEmailPSD2() {
        String stringFinal = '';
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias' and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        PermissionSet ps = [SELECT id FROM PermissionSet WHERE  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        Database.insert(psa);
        
        Case reclamacion = [SELECT id FROM Case WHERE subject = 'Caso PSD2 Email'];


        Test.startTest();
        System.runAs(usuario) {
    		stringFinal = SAC_Case_Operativas_Controller.rellenarCampoSubjectMensajeProrroga(reclamacion.id);
        }
        Test.stopTest();
        
       	System.assertNotEquals(null, stringFinal, 'El campo HTML de la consulta es nulo');        
    }

    @isTest
    public static void rellenarCampoSubjectMensajeProrrogaTestPostalPSD2() {
        String stringFinal = '';
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias' and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        PermissionSet ps = [SELECT id FROM PermissionSet WHERE  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        Database.insert(psa);
        
        Case reclamacion = [SELECT id, Subject, CC_Canal_Respuesta__c FROM Case WHERE subject = 'Caso PSD2 Postal'];


        Test.startTest();
        System.runAs(usuario) {
            reclamacion.CC_Canal_Respuesta__c = 'SAC_CartaPostal';
            Database.update(reclamacion);
    		stringFinal = SAC_Case_Operativas_Controller.rellenarCampoSubjectMensajeProrroga(reclamacion.id);
        }
        Test.stopTest();
        
       	System.assertNotEquals(null, stringFinal, 'El campo HTML de la consulta es nulo');        
    }

    @isTest
    public static void rellenarCampoSubjectMensajeProrrogaTestPSD2() {
        String stringFinal = '';
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias' and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        PermissionSet ps = [SELECT id FROM PermissionSet WHERE  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        Database.insert(psa);
        
        Case reclamacion = [SELECT id, Subject, CC_Canal_Respuesta__c FROM Case WHERE subject = 'Caso PSD2'];


        Test.startTest();
        System.runAs(usuario) {
            reclamacion.CC_Canal_Respuesta__c = 'Phone';
            Database.update(reclamacion);
    		stringFinal = SAC_Case_Operativas_Controller.rellenarCampoSubjectMensajeProrroga(reclamacion.id);
        }
        Test.stopTest();
        
       	System.assertNotEquals(null, stringFinal, 'El campo HTML de la consulta es nulo');        
    }

    @isTest
    public static void rellenarCampoCuerpoMensajeProrrogaTestPSD2() {
        String stringFinal = '';
        User usuario = [SELECT id, name FROM user WHERE alias = 'alias' and isActive = true and Username = 'usergeneral11111@test.com' limit 1];
        PermissionSet ps = [SELECT id FROM PermissionSet WHERE  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        Database.insert(psa);
        
        Case reclamacion = [SELECT id, Subject, CC_Canal_Respuesta__c FROM Case WHERE subject = 'Caso PSD2'];


        Test.startTest();
        System.runAs(usuario) {
            reclamacion.CC_Canal_Respuesta__c = 'Phone';
            Database.update(reclamacion);
    		stringFinal = SAC_Case_Operativas_Controller.rellenarCampoCuerpoMensajeProrroga(reclamacion.id);
        }
        Test.stopTest();
        
       	System.assertNotEquals(null, stringFinal, 'El campo HTML de la consulta es nulo');        
    }

}