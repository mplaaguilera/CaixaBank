/**
 * @description       :
 * @author            : Adrian Mariscal
 * @group             :
 * @last modified on  : 03-23-2022
 * @last modified by  : Adrian Mariscal
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   03-23-2022   Adrian Mariscal   Initial Version
 * 1.1   02-22-2023   Jorge Heras       Setup header for the email
**/
@IsTest //(SeeAllData=true)
public with sharing class CC_Cierre_Automatico_Methods_Test {

    @IsTest
    static void creacionPlantillas() {

        EmailTemplate templateClienteEs = new EmailTemplate();
        templateClienteEs.FolderId = UserInfo.getUserId();
        templateClienteEs.Name = 'Segunda Comunicación - Castellano Formal';
        templateClienteEs.DeveloperName = 'Segunda_Comunicacion_Castellano_Formal';
        templateClienteEs.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
          insert templateClienteEs;
        }

        EmailTemplate templateClienteCa = new EmailTemplate();
        templateClienteCa.FolderId = UserInfo.getUserId();
        templateClienteCa.Name = 'Segunda Comunicación - Catalán Formal';
        templateClienteCa.DeveloperName = 'Segunda_Comunicacion_Catalan_Formal';
        templateClienteCa.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
           insert templateClienteCa;
        }

        EmailTemplate templateClienteEn = new EmailTemplate();
        templateClienteEn.FolderId = UserInfo.getUserId();
        templateClienteEn.Name = 'Segunda Comunicación - Inglés';
        templateClienteEn.DeveloperName = 'Segunda_Comunicacion_Ingles';
        templateClienteEn.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
           insert templateClienteEn;
        }

         EmailTemplate templateEmpleadoEs = new EmailTemplate();
        templateEmpleadoEs.FolderId = UserInfo.getUserId();
        templateEmpleadoEs.Name = 'Segunda Comunicación Empleado - Castellano Formal';
        templateEmpleadoEs.DeveloperName = 'Segunda_Comunicacion_Empleado_Castellano_Formal';
        templateEmpleadoEs.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
          insert templateEmpleadoEs;
        }

        EmailTemplate templateEmpleadoCa = new EmailTemplate();
        templateEmpleadoCa.FolderId = UserInfo.getUserId();
        templateEmpleadoCa.Name = 'Segunda Comunicación Empleado - Catalán Formal';
        templateEmpleadoCa.DeveloperName = 'Segunda_Comunicacion_Empleado_Catalan_Formal';
        templateEmpleadoCa.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
           insert templateEmpleadoCa;
        }

        EmailTemplate templateEmpleadoEn = new EmailTemplate();
        templateEmpleadoEn.FolderId = UserInfo.getUserId();
        templateEmpleadoEn.Name = 'Segunda Comunicación Empleado - Inglés';
        templateEmpleadoEn.DeveloperName = 'Segunda_Comunicacion_Empleado_Ingles';
        templateEmpleadoEn.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
           insert templateEmpleadoEn;
        }
        System.assertEquals(true, templateEmpleadoEn.Id != null);
    }


    @IsTest
    static void CC_Cierre_Automatico_SolicitudInformacion() {
        CC_Lista_Valores__c lov = new CC_Lista_Valores__c();
        lov.CC_Valor__c = '24';
        lov.Name = 'Plazo Genérico';
        insert lov;

        Contact contacto = new Contact();
        contacto.FirstName = 'Pepe';
        contacto.LastName = 'Botillo';
        insert contacto;


        Id contactBusq = [SELECT Id FROM Contact LIMIT 1].Id;
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.ContactId = contactBusq;
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        //caso.CC_MCC_Tematica__c.Name = 'Cajeros';
        //caso.CC_MCC_ProdServ__c.Name = 'Activadores';
        //caso.CC_MCC_Motivo__c.Name = 'Captura de activadores';

    insert caso;


        Id casoBusq = caso.Id;

        test.startTest();
        Datetime decalaje = CC_Cierre_Automatico_Methods.CC_Cierre_Automatico_SolicitudInformacion(casoBusq);
        test.stopTest();

        Date fechaEsperada = decalaje.date();

        Date fechaDeHoy = System.now().date();

        System.assertNotEquals(null,decalaje);
        System.assert(fechaEsperada > fechaDeHoy);
    }

      @IsTest
      static void CC_Cierre_Automatico_SolicitudInformacionEmpleado() {
        CC_Lista_Valores__c lov = new CC_Lista_Valores__c();
        lov.CC_Valor__c = '24';
        lov.Name = 'Plazo genérico empleados';
        insert lov;

        Id recordTypeAccount = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        Account cuenta1 = new Account();
        cuenta1.Name = 'CuentaEmpleado1';
        cuenta1.CC_Email__c = 'cuentasemp1@test.com';
        cuenta1.RecordTypeId= recordTypeAccount;
        insert cuenta1;

        Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Contact contacto1 = new Contact();
        contacto1.AccountId = cuenta1.Id;
        contacto1.FirstName = 'Empleado Test1';
        contacto1.LastName = 'Apellido Empleado Test1';
        contacto1.email = 'emailempleado1@test.com';
        contacto1.RecordTypeId = recordTypeContacto;
        insert contacto1;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id contactBusq = contacto1.Id;

        //Caso 'es'
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba1';
        caso.AccountId = cuenta1.Id;
        caso.ContactId = contacto1.Id;
        //caso.ContactId = contactBusq;
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Oficina Feedback';
        caso.CC_Tipo_Contacto__c = 'Consulta';
    insert caso;


        Id casoBusq = caso.Id;

        Test.startTest();
        Datetime fechaCierre = CC_Cierre_Automatico_Methods.CC_Cierre_Automatico_SolicitudInformacion(casoBusq);
        Test.stopTest();

        BusinessHours diasLaborables = [SELECT Id FROM BusinessHours WHERE name='CC_Empleados'];
        Datetime fechaEsperada = System.now();
        do{
            fechaEsperada = fechaEsperada.addHours(24);
        }while(!BusinessHours.isWithin(diasLaborables.id, fechaEsperada));

        System.assertNotEquals(null,fechaCierre);
        System.assert(fechaEsperada.isSameDay(fechaCierre));
    }

       @IsTest
       static void sendMailSolicitudInfES() {
    //[SELECT Id FROM EmailTemplate WHERE Folder.DeveloperName = : 'Solicitud información'
                    //AND Name = : 'Plantilla solicitud información'].Id;
        Contact contacto = new Contact();
        contacto.FirstName = 'Pepe';
        contacto.LastName = 'Botillo';
        contacto.email = 'email@test.com';
        insert contacto;

        List<Case> casesInsert = new List<Case>();

        //Caso 'es'
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id contactBusq = [SELECT Id FROM Contact WHERE FirstName='Pepe' LIMIT 1].Id;
        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba1';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.ContactId = contactBusq;
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
    caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
    casesInsert.add(caso);

        Case caso2 = new Case();
        caso2.RecordTypeId = recordTypeCaso;
        caso2.CC_Idioma__c = 'es';
        caso2.Subject = 'Prueba2';
        caso2.CC_Tipo_Cliente__c = 'Cliente';
        caso2.ContactId = contactBusq;
        caso2.Status = 'Activo';
        caso2.Origin = 'Comentarios Stores';
    caso2.CC_Tipo_Contacto__c = 'Consulta';
        caso2.CC_Canal_Procedencia__c = 'Google Play Store';
    casesInsert.add(caso2);

        insert casesInsert;

        List<Case> ListCasos = casesInsert;
        List<ID> idCasos = new List<ID>();
        for (Case c: ListCasos){
            idCasos.add(c.Id);
        }

        test.startTest();
        CC_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
        test.stopTest();

        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND RecordTypeId =: taskRecordTypeId];
        System.assert(tareas.size() > 0);
        delete ListCasos;
    }


    @IsTest
    static void sendMailSolicitudInfCA() {
    //[SELECT Id FROM EmailTemplate WHERE Folder.DeveloperName = : 'Solicitud información'
                    //AND Name = : 'Plantilla solicitud información'].Id;
        Contact contacto = new Contact();
        contacto.FirstName = 'Pepe';
        contacto.LastName = 'Botillo';
        contacto.email = 'email@test.com';
        insert contacto;

        Id contactBusq = contacto.Id;

        List<Case> casesInsert = new List<Case>();

        //Caso 'ca'
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Case caso3 = new Case();
        caso3.CC_Idioma__c = 'ca';
        caso3.RecordTypeId = recordTypeCaso;
        caso3.Subject = 'Prueba3';
        caso3.CC_Tipo_Cliente__c = 'Cliente';
        caso3.ContactId = contactBusq;
        caso3.Status = 'Activo';
        caso3.Origin = 'Comentarios Stores';
    caso3.CC_Tipo_Contacto__c = 'Consulta';
        caso3.CC_Canal_Procedencia__c = 'Google Play Store';
    casesInsert.add(caso3);

        Case caso4 = new Case();
        caso4.CC_Idioma__c = 'ca';
        caso4.RecordTypeId = recordTypeCaso;
        caso4.Subject = 'Prueba4';
        caso4.CC_Tipo_Cliente__c = 'Cliente';
        caso4.ContactId = contactBusq;
        caso4.Status = 'Activo';
        caso4.Origin = 'Comentarios Stores';
    caso4.CC_Tipo_Contacto__c = 'Consulta';
        caso4.CC_Canal_Procedencia__c = 'Google Play Store';
    casesInsert.add(caso4);

        insert casesInsert;

        List<Case> ListCasos2 = casesInsert;
        List<ID> idCasos2 = new List<ID>();
        for (Case c: ListCasos2){
            idCasos2.add(c.Id);
        }

        test.startTest();
        CC_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos2);
        test.stopTest();

        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        List<Task> tareas2 = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND RecordTypeId =: taskRecordTypeId];
        System.assert(tareas2.size() > 0);
        delete ListCasos2;
    }

    @IsTest
    static void sendMailSolicitudInfEN() {
    //[SELECT Id FROM EmailTemplate WHERE Folder.DeveloperName = : 'Solicitud información'
                    //AND Name = : 'Plantilla solicitud información'].Id;
        Contact contacto = new Contact();
        contacto.FirstName = 'Pepe';
        contacto.LastName = 'Botillo';
        contacto.email = 'email@test.com';
        insert contacto;

        Id contactBusq = contacto.Id;

        List<Case> casesInsert = new List<Case>();

        //Caso 'en'
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Case caso5 = new Case();
        caso5.RecordTypeId = recordTypeCaso;
        caso5.CC_Idioma__c = 'en';
        caso5.Subject = 'Prueba5';
        caso5.CC_Tipo_Cliente__c = 'Cliente';
        caso5.CC_Canal_Operativo__c = 'App BrokerNow';
        caso5.ContactId = contactBusq;
        caso5.Status = 'Activo';
        caso5.Origin = 'Comentarios Stores';
    caso5.CC_Tipo_Contacto__c = 'Consulta';
        caso5.CC_Canal_Procedencia__c = 'Google Play Store';
    casesInsert.add(caso5);

        Case caso6 = new Case();
        caso6.RecordTypeId = recordTypeCaso;
        caso6.CC_Idioma__c = 'en';
        caso6.Subject = 'Prueba6';
        caso6.CC_Canal_Operativo__c = 'App BrokerNow';
        caso6.CC_Tipo_Cliente__c = 'Cliente';
        caso6.ContactId = contactBusq;
        caso6.Status = 'Activo';
        caso6.Origin = 'Comentarios Stores';
    caso6.CC_Tipo_Contacto__c = 'Consulta';
        caso6.CC_Canal_Procedencia__c = 'Google Play Store';
    casesInsert.add(caso6);

        Case caso7 = new Case();
        caso7.RecordTypeId = recordTypeCaso;
        caso7.CC_Idioma__c = '';
        caso7.CC_Canal_Operativo__c = 'App BrokerNow';
        caso7.Subject = 'Prueba6';
        caso7.CC_Tipo_Cliente__c = 'Cliente';
        caso7.ContactId = contactBusq;
        caso7.Status = 'Activo';
        caso7.Origin = 'Comentarios Stores';
    caso7.CC_Tipo_Contacto__c = 'Consulta';
        caso7.CC_Canal_Procedencia__c = 'Google Play Store';
    casesInsert.add(caso7);

        insert casesInsert;

        List<Case> ListCasos3 = casesInsert;
        List<ID> idCasos3 = new List<ID>();
        for (Case c: ListCasos3){
            idCasos3.add(c.Id);
        }

        test.startTest();
        CC_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos3);
        test.stopTest();

        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        List<Task> tareas3 = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND RecordTypeId =: taskRecordTypeId];
        System.assert(tareas3.size() > 0);
    }



 ///////////////////////////////////// CLASES TEST Sergio Castro //////////////


  @IsTest
    static void sendMailSolicitudInfEmpleado() {
    //[SELECT Id FROM EmailTemplate WHERE Folder.DeveloperName = : 'Solicitud información'
                    //AND Name = : 'Plantilla solicitud información'].Id;

       Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Solicitud Info Empleado';
        cuenta.CC_Email__c = 'cuentasolinfoemp@test.com';
        cuenta.RecordTypeId = recordTypeCuenta;
        insert cuenta;

        Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Contact contacto = new Contact();
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'Empleado Test';
        contacto.LastName = 'Apellido Empleado Test';
        contacto.email = 'emailempleado@test.com';
    contacto.RecordTypeId = recordTypeContacto;
        insert contacto;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        List<Case> casesInsert = new List<Case>();

        //Caso sin idioma
        Case caso = new Case();
        caso.CC_Idioma__c = '';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Oficina Feedback';
        caso.CC_Tipo_Contacto__c = 'Consulta';
    casesInsert.add(caso);

        //Caso 'es'
        Case casoEs = new Case();
        casoEs.CC_Idioma__c = 'es';
        casoEs.RecordTypeId = recordTypeCaso;
        casoEs.Subject = 'Prueba1';
        casoEs.AccountId = cuenta.Id;
        casoEs.ContactId = contacto.Id;
        casoEs.Status = 'Activo';
        casoEs.Origin = 'Email';
        casoEs.CC_Canal_Procedencia__c = 'Oficina Feedback';
        casoEs.CC_Tipo_Contacto__c = 'Consulta';
    casesInsert.add(casoEs);
/*
         //Caso 'ca'
        Case casoCa = new Case();
        casoCa.CC_Idioma__c = 'ca';
        casoCa.RecordTypeId = recordTypeCaso;
        casoCa.Subject = 'Prueba2';
        casoCa.AccountId = cuenta.Id;
        casoCa.ContactId = contacto.Id;
        casoCa.Status = 'Activo';
        casoCa.Origin = 'Email';
        casoCa.CC_Canal_Procedencia__c = 'Oficina Feedback';
        casoCa.CC_Tipo_Contacto__c = 'Consulta';
    casesInsert.add(casoCa);

          //Caso 'en'
        Case casoEn = new Case();
        casoEn.CC_Idioma__c = 'en';
        casoEn.RecordTypeId = recordTypeCaso;
        casoEn.Subject = 'Prueba3';
        casoEn.AccountId = cuenta.Id;
        casoEn.ContactId = contacto.Id;
        casoEn.Status = 'Activo';
        casoEn.Origin = 'Email';
        casoEn.CC_Canal_Procedencia__c = 'Oficina Feedback';
        casoEn.CC_Tipo_Contacto__c = 'Consulta';
    casesInsert.add(casoEn);*/

        insert casesInsert;


        //List<Case> ListCasos = [SELECT Id FROM Case WHERE ContactId =: contactBusq];
        List<ID> idCasos = new List<ID>();
        //for (Case c: ListCasos){
        idCasos.add(casoEs.Id);
        //idCasos.add(casoCa.Id);
        //idCasos.add(casoEn.Id);
        idCasos.add(caso.Id);
        //}

        Test.startTest();

        CC_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
    List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND WhatId = :casoEs.Id AND RecordTypeId =: taskRecordTypeId];
        //List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información'];
        System.assert(tareas.size() > 0);

         Test.stopTest();
    }

  @IsTest
    static void sendMailSolicitudInfEmpleado2() {
    //[SELECT Id FROM EmailTemplate WHERE Folder.DeveloperName = : 'Solicitud información'
                    //AND Name = : 'Plantilla solicitud información'].Id;

       Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Solicitud Info Empleado';
        cuenta.CC_Email__c = 'cuentasolinfoemp@test.com';
        cuenta.RecordTypeId = recordTypeCuenta;
        insert cuenta;

        Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Contact contacto = new Contact();
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'Empleado Test';
        contacto.LastName = 'Apellido Empleado Test';
        contacto.email = 'emailempleado@test.com';
    contacto.RecordTypeId = recordTypeContacto;
        insert contacto;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        List<Case> casesInsert = new List<Case>();
/*
        //Caso sin idioma
        Case caso = new Case();
        caso.CC_Idioma__c = '';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Oficina Feedback';
        caso.CC_Tipo_Contacto__c = 'Consulta';
    casesInsert.add(caso);

        //Caso 'es'
        Case casoEs = new Case();
        casoEs.CC_Idioma__c = 'es';
        casoEs.RecordTypeId = recordTypeCaso;
        casoEs.Subject = 'Prueba1';
        casoEs.AccountId = cuenta.Id;
        casoEs.ContactId = contacto.Id;
        casoEs.Status = 'Activo';
        casoEs.Origin = 'Email';
        casoEs.CC_Canal_Procedencia__c = 'Oficina Feedback';
        casoEs.CC_Tipo_Contacto__c = 'Consulta';
    casesInsert.add(casoEs);*/

         //Caso 'ca'
        Case casoCa = new Case();
        casoCa.CC_Idioma__c = 'ca';
        casoCa.RecordTypeId = recordTypeCaso;
        casoCa.Subject = 'Prueba2';
        casoCa.AccountId = cuenta.Id;
        casoCa.ContactId = contacto.Id;
        casoCa.Status = 'Activo';
        casoCa.Origin = 'Email';
        casoCa.CC_Canal_Procedencia__c = 'Oficina Feedback';
        casoCa.CC_Tipo_Contacto__c = 'Consulta';
    casesInsert.add(casoCa);

          //Caso 'en'
        Case casoEn = new Case();
        casoEn.CC_Idioma__c = 'en';
        casoEn.RecordTypeId = recordTypeCaso;
        casoEn.Subject = 'Prueba3';
        casoEn.AccountId = cuenta.Id;
        casoEn.ContactId = contacto.Id;
        casoEn.Status = 'Activo';
        casoEn.Origin = 'Email';
        casoEn.CC_Canal_Procedencia__c = 'Oficina Feedback';
        casoEn.CC_Tipo_Contacto__c = 'Consulta';
    casesInsert.add(casoEn);

        insert casesInsert;


        //List<Case> ListCasos = [SELECT Id FROM Case WHERE ContactId =: contactBusq];
        List<ID> idCasos = new List<ID>();
        //for (Case c: ListCasos){
        //idCasos.add(casoEs.Id);
        idCasos.add(casoCa.Id);
        idCasos.add(casoEn.Id);
        //idCasos.add(caso.Id);
        //}

        Test.startTest();

        CC_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
    List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND WhatId = :casoCa.Id AND RecordTypeId =: taskRecordTypeId];
        //List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información'];
        System.assert(tareas.size() > 0);

         Test.stopTest();
    }

    @IsTest
    static void CC_Cierre_Automatico_SolicitudInformacionDetalleConsultaInformado1() {
        Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Solicitud Info Empleado';
        cuenta.CC_Email__c = 'cuentasolinfoemp@test.com';
        cuenta.RecordTypeId = recordTypeCuenta;
        insert cuenta;

        Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Contact contacto = new Contact();
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'Empleado Test';
        contacto.LastName = 'Apellido Empleado Test';
        contacto.email = 'emailempleado@test.com';
    contacto.RecordTypeId = recordTypeContacto;
        insert contacto;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        List<Case> casesInsert = new List<Case>();

        //Caso sin idioma
        Case caso = new Case();
        caso.CC_Idioma__c = '';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Oficina Feedback';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Detalles_Solucion__c = 'Google Play Store';
        caso.CC_Detalles_Consulta__c = 'Google Play Store';
    casesInsert.add(caso);

        //Caso 'es'
        Case casoEs = new Case();
        casoEs.CC_Idioma__c = 'es';
        casoEs.RecordTypeId = recordTypeCaso;
        casoEs.Subject = 'Prueba1';
        casoEs.AccountId = cuenta.Id;
        casoEs.ContactId = contacto.Id;
        casoEs.Status = 'Activo';
        casoEs.Origin = 'Email';
        casoEs.CC_Canal_Procedencia__c = 'Oficina Feedback';
        casoEs.CC_Tipo_Contacto__c = 'Consulta';
        casoEs.CC_Detalles_Solucion__c = 'Google Play Store';
        casoEs.CC_Detalles_Consulta__c = 'Google Play Store';
    casesInsert.add(casoEs);

         //Caso 'ca'
/*        Case casoCa = new Case();
        casoCa.CC_Idioma__c = 'ca';
        casoCa.RecordTypeId = recordTypeCaso;
        casoCa.Subject = 'Prueba2';
        casoCa.AccountId = cuenta.Id;
        casoCa.ContactId = contacto.Id;
        casoCa.Status = 'Activo';
        casoCa.Origin = 'Email';
        casoCa.CC_Canal_Procedencia__c = 'Oficina Feedback';
        casoCa.CC_Tipo_Contacto__c = 'Consulta';
        casoCa.CC_Detalles_Solucion__c = 'Google Play Store';
        casoCa.CC_Detalles_Consulta__c = 'Google Play Store';
    casesInsert.add(casoCa);

          //Caso 'en'
        Case casoEn = new Case();
        casoEn.CC_Idioma__c = 'en';
        casoEn.RecordTypeId = recordTypeCaso;
        casoEn.Subject = 'Prueba3';
        casoEn.AccountId = cuenta.Id;
        casoEn.ContactId = contacto.Id;
        casoEn.Status = 'Activo';
        casoEn.Origin = 'Email';
        casoEn.CC_Canal_Procedencia__c = 'Oficina Feedback';
        casoEn.CC_Tipo_Contacto__c = 'Consulta';
    casoEn.CC_Detalles_Solucion__c = 'Google Play Store';
        casoEn.CC_Detalles_Consulta__c = 'Google Play Store';
    casesInsert.add(casoEn);*/

        insert casesInsert;


        //List<Case> ListCasos = [SELECT Id FROM Case WHERE ContactId =: contactBusq];
        List<ID> idCasos = new List<ID>();
        //for (Case c: ListCasos){
        idCasos.add(casoEs.Id);
        //idCasos.add(casoCa.Id);
        //idCasos.add(casoEn.Id);
        idCasos.add(caso.Id);
        //}

        Test.startTest();

        CC_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND WhatId = :casoEs.Id AND RecordTypeId =: taskRecordTypeId];
        //List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información'];
        System.assert(tareas.size() > 0);

         Test.stopTest();
    }
        @IsTest
    static void CC_Cierre_Automatico_SolicitudInformacionDetalleConsultaInformado2() {
        Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Solicitud Info Empleado';
        cuenta.CC_Email__c = 'cuentasolinfoemp@test.com';
        cuenta.RecordTypeId = recordTypeCuenta;
        insert cuenta;

        Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Contact contacto = new Contact();
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'Empleado Test';
        contacto.LastName = 'Apellido Empleado Test';
        contacto.email = 'emailempleado@test.com';
    contacto.RecordTypeId = recordTypeContacto;
        insert contacto;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        List<Case> casesInsert = new List<Case>();
/*
        //Caso sin idioma
        Case caso = new Case();
        caso.CC_Idioma__c = '';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Oficina Feedback';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Detalles_Solucion__c = 'Google Play Store';
        caso.CC_Detalles_Consulta__c = 'Google Play Store';
    casesInsert.add(caso);

        //Caso 'es'
        Case casoEs = new Case();
        casoEs.CC_Idioma__c = 'es';
        casoEs.RecordTypeId = recordTypeCaso;
        casoEs.Subject = 'Prueba1';
        casoEs.AccountId = cuenta.Id;
        casoEs.ContactId = contacto.Id;
        casoEs.Status = 'Activo';
        casoEs.Origin = 'Email';
        casoEs.CC_Canal_Procedencia__c = 'Oficina Feedback';
        casoEs.CC_Tipo_Contacto__c = 'Consulta';
        casoEs.CC_Detalles_Solucion__c = 'Google Play Store';
        casoEs.CC_Detalles_Consulta__c = 'Google Play Store';
    casesInsert.add(casoEs);*/

         //Caso 'ca'
        Case casoCa = new Case();
        casoCa.CC_Idioma__c = 'ca';
        casoCa.RecordTypeId = recordTypeCaso;
        casoCa.Subject = 'Prueba2';
        casoCa.AccountId = cuenta.Id;
        casoCa.ContactId = contacto.Id;
        casoCa.Status = 'Activo';
        casoCa.Origin = 'Email';
        casoCa.CC_Canal_Procedencia__c = 'Oficina Feedback';
        casoCa.CC_Tipo_Contacto__c = 'Consulta';
        casoCa.CC_Detalles_Solucion__c = 'Google Play Store';
        casoCa.CC_Detalles_Consulta__c = 'Google Play Store';
    casesInsert.add(casoCa);

          //Caso 'en'
        Case casoEn = new Case();
        casoEn.CC_Idioma__c = 'en';
        casoEn.RecordTypeId = recordTypeCaso;
        casoEn.Subject = 'Prueba3';
        casoEn.AccountId = cuenta.Id;
        casoEn.ContactId = contacto.Id;
        casoEn.Status = 'Activo';
        casoEn.Origin = 'Email';
        casoEn.CC_Canal_Procedencia__c = 'Oficina Feedback';
        casoEn.CC_Tipo_Contacto__c = 'Consulta';
    casoEn.CC_Detalles_Solucion__c = 'Google Play Store';
        casoEn.CC_Detalles_Consulta__c = 'Google Play Store';
    casesInsert.add(casoEn);

        insert casesInsert;


        //List<Case> ListCasos = [SELECT Id FROM Case WHERE ContactId =: contactBusq];
        List<ID> idCasos = new List<ID>();
        //for (Case c: ListCasos){
        //idCasos.add(casoEs.Id);
        idCasos.add(casoCa.Id);
        idCasos.add(casoEn.Id);
        //idCasos.add(caso.Id);
        //}

        Test.startTest();

        CC_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND WhatId = :casoCa.Id AND RecordTypeId =: taskRecordTypeId];
        //List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información'];
        System.assert(tareas.size() > 0);

         Test.stopTest();
    }

    /********************************************** Casos Empleado CSI Bankia ************************************************************************/

    @IsTest
    static void CC_Cierre_Automatico_SolicitudInformacionEmpleadoCSI() {
        CC_Lista_Valores__c lov = new CC_Lista_Valores__c();
        lov.CC_Valor__c = '24';
        lov.Name = 'Plazo genérico empleados';
        insert lov;

        Id recordTypeAccount = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        Account cuenta1 = new Account();
        cuenta1.Name = 'CuentaEmpleado1';
        cuenta1.CC_Email__c = 'cuentasemp1@test.com';
        cuenta1.RecordTypeId= recordTypeAccount;
        insert cuenta1;

        Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Contact contacto1 = new Contact();
        contacto1.AccountId = cuenta1.Id;
        contacto1.FirstName = 'Empleado Test1';
        contacto1.LastName = 'Apellido Empleado Test1';
        contacto1.email = 'emailempleado1@test.com';
        contacto1.RecordTypeId = recordTypeContacto;
        insert contacto1;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Id contactBusq = contacto1.Id;

        //Caso 'es'
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba1';
        caso.AccountId = cuenta1.Id;
        caso.ContactId = contacto1.Id;
        //caso.ContactId = contactBusq;
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'CCO CSI';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        insert caso;


        Id casoBusq = caso.Id;

        test.startTest();
        Datetime decalaje = CC_Cierre_Automatico_Methods.CC_Cierre_Automatico_SolicitudInformacion(casoBusq);
        test.stopTest();

        Date fechaEsperada = decalaje.date();

        Date fechaDeHoy = System.now().date();

        System.assertNotEquals(null,decalaje);
        System.assert(fechaEsperada > fechaDeHoy);
    }

    @IsTest
    static void sendMailSolicitudInfEmpleadoCSI1() {
    //[SELECT Id FROM EmailTemplate WHERE Folder.DeveloperName = : 'Solicitud información'
                    //AND Name = : 'Plantilla solicitud información'].Id;

       Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Solicitud Info Empleado';
        cuenta.CC_Email__c = 'cuentasolinfoemp@test.com';
        cuenta.RecordTypeId = recordTypeCuenta;
        insert cuenta;

        Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Contact contacto = new Contact();
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'Empleado Test';
        contacto.LastName = 'Apellido Empleado Test';
        contacto.email = 'emailempleado@test.com';
    contacto.RecordTypeId = recordTypeContacto;
        insert contacto;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();

        List<Case> casesInsert = new List<Case>();

        //Caso sin idioma
        Case caso = new Case();
        caso.CC_Idioma__c = '';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'CCO CSI';
        caso.CC_Tipo_Contacto__c = 'Consulta';
    casesInsert.add(caso);

        //Caso 'es'
        Case casoEs = new Case();
        casoEs.CC_Idioma__c = 'es';
        casoEs.RecordTypeId = recordTypeCaso;
        casoEs.Subject = 'Prueba1';
        casoEs.AccountId = cuenta.Id;
        casoEs.ContactId = contacto.Id;
        casoEs.Status = 'Activo';
        casoEs.Origin = 'Email';
        casoEs.CC_Canal_Procedencia__c = 'CCO CSI';
        casoEs.CC_Tipo_Contacto__c = 'Consulta';
    casesInsert.add(casoEs);
/*
         //Caso 'ca'
        Case casoCa = new Case();
        casoCa.CC_Idioma__c = 'ca';
        casoCa.RecordTypeId = recordTypeCaso;
        casoCa.Subject = 'Prueba2';
        casoCa.AccountId = cuenta.Id;
        casoCa.ContactId = contacto.Id;
        casoCa.Status = 'Activo';
        casoCa.Origin = 'Email';
        casoCa.CC_Canal_Procedencia__c = 'CCO CSI';
        casoCa.CC_Tipo_Contacto__c = 'Consulta';
    casesInsert.add(casoCa);

          //Caso 'en'
        Case casoEn = new Case();
        casoEn.CC_Idioma__c = 'en';
        casoEn.RecordTypeId = recordTypeCaso;
        casoEn.Subject = 'Prueba3';
        casoEn.AccountId = cuenta.Id;
        casoEn.ContactId = contacto.Id;
        casoEn.Status = 'Activo';
        casoEn.Origin = 'Email';
        casoEn.CC_Canal_Procedencia__c = 'CCO CSI';
        casoEn.CC_Tipo_Contacto__c = 'Consulta';
    casesInsert.add(casoEn);*/

        insert casesInsert;


        //List<Case> ListCasos = [SELECT Id FROM Case WHERE ContactId =: contactBusq];
        List<ID> idCasos = new List<ID>();
        //for (Case c: ListCasos){
        idCasos.add(casoEs.Id);
        //idCasos.add(casoCa.Id);
        //idCasos.add(casoEn.Id);
        idCasos.add(caso.Id);
        //}

        Test.startTest();

        CC_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
    List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND WhatId = :casoEs.Id AND RecordTypeId =: taskRecordTypeId];
        //List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información'];
        System.assert(tareas.size() > 0);

         Test.stopTest();
    }

    @IsTest
    static void sendMailSolicitudInfEmpleadoCSI2() {
    //[SELECT Id FROM EmailTemplate WHERE Folder.DeveloperName = : 'Solicitud información'
                    //AND Name = : 'Plantilla solicitud información'].Id;

       Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Solicitud Info Empleado';
        cuenta.CC_Email__c = 'cuentasolinfoemp@test.com';
        cuenta.RecordTypeId = recordTypeCuenta;
        insert cuenta;

        Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Contact contacto = new Contact();
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'Empleado Test';
        contacto.LastName = 'Apellido Empleado Test';
        contacto.email = 'emailempleado@test.com';
    contacto.RecordTypeId = recordTypeContacto;
        insert contacto;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();

        List<Case> casesInsert = new List<Case>();
/*
        //Caso sin idioma
        Case caso = new Case();
        caso.CC_Idioma__c = '';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'CCO CSI';
        caso.CC_Tipo_Contacto__c = 'Consulta';
    casesInsert.add(caso);

        //Caso 'es'
        Case casoEs = new Case();
        casoEs.CC_Idioma__c = 'es';
        casoEs.RecordTypeId = recordTypeCaso;
        casoEs.Subject = 'Prueba1';
        casoEs.AccountId = cuenta.Id;
        casoEs.ContactId = contacto.Id;
        casoEs.Status = 'Activo';
        casoEs.Origin = 'Email';
        casoEs.CC_Canal_Procedencia__c = 'CCO CSI';
        casoEs.CC_Tipo_Contacto__c = 'Consulta';
    casesInsert.add(casoEs);*/

         //Caso 'ca'
        Case casoCa = new Case();
        casoCa.CC_Idioma__c = 'ca';
        casoCa.RecordTypeId = recordTypeCaso;
        casoCa.Subject = 'Prueba2';
        casoCa.AccountId = cuenta.Id;
        casoCa.ContactId = contacto.Id;
        casoCa.Status = 'Activo';
        casoCa.Origin = 'Email';
        casoCa.CC_Canal_Procedencia__c = 'CCO CSI';
        casoCa.CC_Tipo_Contacto__c = 'Consulta';
    casesInsert.add(casoCa);

          //Caso 'en'
        Case casoEn = new Case();
        casoEn.CC_Idioma__c = 'en';
        casoEn.RecordTypeId = recordTypeCaso;
        casoEn.Subject = 'Prueba3';
        casoEn.AccountId = cuenta.Id;
        casoEn.ContactId = contacto.Id;
        casoEn.Status = 'Activo';
        casoEn.Origin = 'Email';
        casoEn.CC_Canal_Procedencia__c = 'CCO CSI';
        casoEn.CC_Tipo_Contacto__c = 'Consulta';
    casesInsert.add(casoEn);

        insert casesInsert;


        //List<Case> ListCasos = [SELECT Id FROM Case WHERE ContactId =: contactBusq];
        List<ID> idCasos = new List<ID>();
        //for (Case c: ListCasos){
//        idCasos.add(casoEs.Id);
        idCasos.add(casoCa.Id);
        idCasos.add(casoEn.Id);
//        idCasos.add(caso.Id);
        //}

        Test.startTest();

        CC_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
    List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND WhatId = :casoCa.Id AND RecordTypeId =: taskRecordTypeId];
        //List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información'];
        System.assert(tareas.size() > 0);

         Test.stopTest();
    }

    @IsTest
    static void CC_Cierre_Automatico_SolicitudInformacionDetalleConsultaInformado_EmpleadoCSI1() {
        Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Solicitud Info Empleado';
        cuenta.CC_Email__c = 'cuentasolinfoemp@test.com';
        cuenta.RecordTypeId = recordTypeCuenta;
        insert cuenta;

        Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Contact contacto = new Contact();
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'Empleado Test';
        contacto.LastName = 'Apellido Empleado Test';
        contacto.email = 'emailempleado@test.com';
    contacto.RecordTypeId = recordTypeContacto;
        insert contacto;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();

        List<Case> casesInsert = new List<Case>();

        //Caso sin idioma
        Case caso = new Case();
        caso.CC_Idioma__c = '';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'CCO CSI';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Detalles_Solucion__c = 'Google Play Store';
        caso.CC_Detalles_Consulta__c = 'Google Play Store';
    casesInsert.add(caso);

        //Caso 'es'
        Case casoEs = new Case();
        casoEs.CC_Idioma__c = 'es';
        casoEs.RecordTypeId = recordTypeCaso;
        casoEs.Subject = 'Prueba1';
        casoEs.AccountId = cuenta.Id;
        casoEs.ContactId = contacto.Id;
        casoEs.Status = 'Activo';
        casoEs.Origin = 'Email';
        casoEs.CC_Canal_Procedencia__c = 'CCO CSI';
        casoEs.CC_Tipo_Contacto__c = 'Consulta';
        casoEs.CC_Detalles_Solucion__c = 'Google Play Store';
        casoEs.CC_Detalles_Consulta__c = 'Google Play Store';
    casesInsert.add(casoEs);
/*
         //Caso 'ca'
        Case casoCa = new Case();
        casoCa.CC_Idioma__c = 'ca';
        casoCa.RecordTypeId = recordTypeCaso;
        casoCa.Subject = 'Prueba2';
        casoCa.AccountId = cuenta.Id;
        casoCa.ContactId = contacto.Id;
        casoCa.Status = 'Activo';
        casoCa.Origin = 'Email';
        casoCa.CC_Canal_Procedencia__c = 'CCO CSI';
        casoCa.CC_Tipo_Contacto__c = 'Consulta';
        casoCa.CC_Detalles_Solucion__c = 'Google Play Store';
        casoCa.CC_Detalles_Consulta__c = 'Google Play Store';
    casesInsert.add(casoCa);

          //Caso 'en'
        Case casoEn = new Case();
        casoEn.CC_Idioma__c = 'en';
        casoEn.RecordTypeId = recordTypeCaso;
        casoEn.Subject = 'Prueba3';
        casoEn.AccountId = cuenta.Id;
        casoEn.ContactId = contacto.Id;
        casoEn.Status = 'Activo';
        casoEn.Origin = 'Email';
        casoEn.CC_Canal_Procedencia__c = 'CCO CSI';
        casoEn.CC_Tipo_Contacto__c = 'Consulta';
    casoEn.CC_Detalles_Solucion__c = 'Google Play Store';
        casoEn.CC_Detalles_Consulta__c = 'Google Play Store';
    casesInsert.add(casoEn);*/

        insert casesInsert;


        //List<Case> ListCasos = [SELECT Id FROM Case WHERE ContactId =: contactBusq];
        List<ID> idCasos = new List<ID>();
        //for (Case c: ListCasos){
        idCasos.add(casoEs.Id);
        //idCasos.add(casoCa.Id);
        //idCasos.add(casoEn.Id);
        idCasos.add(caso.Id);
        //}

        Test.startTest();

        CC_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND WhatId = :casoEs.Id AND RecordTypeId =: taskRecordTypeId];
        //List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información'];
        System.assert(tareas.size() > 0);

         Test.stopTest();
    }

    @IsTest
    static void CC_Cierre_Automatico_SolicitudInformacionDetalleConsultaInformado_EmpleadoCSI2() {
        Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Solicitud Info Empleado';
        cuenta.CC_Email__c = 'cuentasolinfoemp@test.com';
        cuenta.RecordTypeId = recordTypeCuenta;
        insert cuenta;

        Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Contact contacto = new Contact();
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'Empleado Test';
        contacto.LastName = 'Apellido Empleado Test';
        contacto.email = 'emailempleado@test.com';
    contacto.RecordTypeId = recordTypeContacto;
        insert contacto;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();

        List<Case> casesInsert = new List<Case>();
/*
        //Caso sin idioma
        Case caso = new Case();
        caso.CC_Idioma__c = '';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'CCO CSI';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Detalles_Solucion__c = 'Google Play Store';
        caso.CC_Detalles_Consulta__c = 'Google Play Store';
    casesInsert.add(caso);

        //Caso 'es'
        Case casoEs = new Case();
        casoEs.CC_Idioma__c = 'es';
        casoEs.RecordTypeId = recordTypeCaso;
        casoEs.Subject = 'Prueba1';
        casoEs.AccountId = cuenta.Id;
        casoEs.ContactId = contacto.Id;
        casoEs.Status = 'Activo';
        casoEs.Origin = 'Email';
        casoEs.CC_Canal_Procedencia__c = 'CCO CSI';
        casoEs.CC_Tipo_Contacto__c = 'Consulta';
        casoEs.CC_Detalles_Solucion__c = 'Google Play Store';
        casoEs.CC_Detalles_Consulta__c = 'Google Play Store';
    casesInsert.add(casoEs);*/

         //Caso 'ca'
        Case casoCa = new Case();
        casoCa.CC_Idioma__c = 'ca';
        casoCa.RecordTypeId = recordTypeCaso;
        casoCa.Subject = 'Prueba2';
        casoCa.AccountId = cuenta.Id;
        casoCa.ContactId = contacto.Id;
        casoCa.Status = 'Activo';
        casoCa.Origin = 'Email';
        casoCa.CC_Canal_Procedencia__c = 'CCO CSI';
        casoCa.CC_Tipo_Contacto__c = 'Consulta';
        casoCa.CC_Detalles_Solucion__c = 'Google Play Store';
        casoCa.CC_Detalles_Consulta__c = 'Google Play Store';
    casesInsert.add(casoCa);

          //Caso 'en'
        Case casoEn = new Case();
        casoEn.CC_Idioma__c = 'en';
        casoEn.RecordTypeId = recordTypeCaso;
        casoEn.Subject = 'Prueba3';
        casoEn.AccountId = cuenta.Id;
        casoEn.ContactId = contacto.Id;
        casoEn.Status = 'Activo';
        casoEn.Origin = 'Email';
        casoEn.CC_Canal_Procedencia__c = 'CCO CSI';
        casoEn.CC_Tipo_Contacto__c = 'Consulta';
    casoEn.CC_Detalles_Solucion__c = 'Google Play Store';
        casoEn.CC_Detalles_Consulta__c = 'Google Play Store';
    casesInsert.add(casoEn);

        insert casesInsert;


        //List<Case> ListCasos = [SELECT Id FROM Case WHERE ContactId =: contactBusq];
        List<ID> idCasos = new List<ID>();
        //for (Case c: ListCasos){
        //idCasos.add(casoEs.Id);
        idCasos.add(casoCa.Id);
        idCasos.add(casoEn.Id);
        //idCasos.add(caso.Id);
        //}

        Test.startTest();

        CC_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND WhatId = :casoCa.Id AND RecordTypeId =: taskRecordTypeId];
        //List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información'];
        System.assert(tareas.size() > 0);

         Test.stopTest();
    }
    /******************************************************************************************************************************************/

    @IsTest
    static void sendMailSolicitudInfCAM() {


     Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
     CC_MCC__c mccTematica = new CC_MCC__c();
     mccTematica.Name = 'Ahorro a la vista';
     mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
     mccTematica.CC_Tipo_Cliente__c = 'Cliente';
     mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
     mccTematica.RecordTypeId = recordTypeIdTematica;
     mccTematica.CC_Codigo_Externo__c = 'TE-000001';
     Insert mccTematica;

     Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
     CC_MCC__c mccProducto = new CC_MCC__c();
     mccProducto.Name = 'Cuenta corriente';
     mccProducto.CC_Tipo_Cliente__c = 'Cliente';
     mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
     mccProducto.RecordTypeId = recordTypeIdProducto;
     mccProducto.CC_Tematica__c = mccTematica.Id;
     mccProducto.CC_Codigo_Externo__c = 'PR-000001';
     Insert mccProducto;

     Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        CC_MCC__c mccMotivo = new CC_MCC__c();
     mccMotivo.Name = 'Apertura sin autorización';
     mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
     mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
     mccMotivo.RecordTypeId = recordTypeIdMotivo;
     mccMotivo.CC_Tematica__c = mccTematica.Id;
     mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
     mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
     Insert mccMotivo;


        Id recordTypeAccount = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

     Account cuenta1 = new Account();
     cuenta1.Name = 'CuentaEmpleado1';
     cuenta1.CC_Email__c = 'cuentasemp1@test.com';
     cuenta1.RecordTypeId= recordTypeAccount;
     insert cuenta1;


     //[SELECT Id FROM EmailTemplate WHERE Folder.DeveloperName = : 'Solicitud información'
                 //AND Name = : 'Plantilla solicitud información'].Id;
     Contact contacto = new Contact();
     contacto.FirstName = 'Pepe';
     contacto.LastName = 'Botillo';
     contacto.email = 'email@test.com';
     contacto.AccountId=cuenta1.id;
     insert contacto;

     List<Case> casesInsert = new List<Case>();
     Id recordTypeClienteCAM = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
     Id recordTypeEmpleadoCAM = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Empleado').getRecordTypeId();
     //Caso 'es'
     Id contactBusq = contacto.Id;
     Case caso = new Case();
     caso.CC_Idioma__c = 'es';
     caso.Subject = 'Prueba1';
     caso.CC_Tipo_Cliente__c = 'Cliente';
     caso.AccountId=cuenta1.id;
     caso.ContactId = contactBusq;
     caso.Status = 'Activo';
     caso.Origin = 'Email';
     caso.RecordtypeId=recordTypeClienteCAM;
     //caso.CC_Tipo_Contacto__c = 'Consulta';
     //caso.CC_Canal_Procedencia__c = 'Buzón Valores';
     caso.CC_MCC_Tematica__c = mccTematica.Id;
     caso.CC_MCC_ProdServ__c = mccProducto.Id;
     caso.CC_MCC_Motivo__c = mccMotivo.Id;
     casesInsert.add(caso);

     Case caso2 = new Case();
     caso2.CC_Idioma__c = 'es';
     caso2.Subject = 'Prueba2';
     caso2.CC_Tipo_Cliente__c = 'Cliente';
     caso2.AccountId=cuenta1.id;
     caso2.ContactId = contactBusq;
     caso2.Status = 'Activo';
     caso2.Origin = 'Email';
     caso2.RecordtypeId=recordTypeEmpleadoCAM;
     //caso2.CC_Tipo_Contacto__c = 'Consulta';
     //caso2.CC_Canal_Procedencia__c = 'Buzón Valores';
     caso2.CC_MCC_Tematica__c = mccTematica.Id;
     caso2.CC_MCC_ProdServ__c = mccProducto.Id;
     caso2.CC_MCC_Motivo__c = mccMotivo.Id;
     casesInsert.add(caso2);

     insert casesInsert;

     List<Case> ListCasos = casesInsert;
     List<ID> idCasos = new List<ID>();
     for (Case c: ListCasos){
         idCasos.add(c.Id);
     }
     test.startTest();
     AM_Cierre_Automatico_Methods.closeTaskSolicitudInfCAM(idCasos);
     Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Task').getRecordTypeId();
     List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND RecordTypeId =: taskRecordTypeId];
     test.stopTest();

     System.assert(tareas.size() > 0);
 }
    @isTest
 static void cierreAutomatico3N()
 {    
    Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
    CC_MCC__c mccTematica = new CC_MCC__c();
    mccTematica.Name = 'Ahorro a la vista';
    mccTematica.CC_Tipo_Cliente__c = 'Cliente';
    mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
    mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
    mccTematica.RecordTypeId = recordTypeIdTematica;
    mccTematica.CC_Codigo_Externo__c = 'TE-000001';
    Insert mccTematica;
    
    Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
    CC_MCC__c mccProducto = new CC_MCC__c();
    mccProducto.Name = 'Cuenta corriente';
    mccProducto.CC_Tipo_Cliente__c = 'Cliente';
    mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
    mccProducto.RecordTypeId = recordTypeIdProducto;
    mccProducto.CC_Tematica__c = mccTematica.Id;
    mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
    Insert mccProducto; 
    
    Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
    CC_MCC__c mccMotivo = new CC_MCC__c();
    mccMotivo.Name = 'Apertura sin autorización';
    mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
    mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
    mccMotivo.RecordTypeId = recordTypeIdMotivo;
    mccMotivo.CC_Tematica__c = mccTematica.Id;
    mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
    mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
    Insert mccMotivo;
         
    Id recordTypeAccount = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        
    Account cuenta1 = new Account();
    cuenta1.Name = 'CuentaEmpleado1';
    cuenta1.CC_Email__c = 'cuentasemp1@test.com';
    cuenta1.RecordTypeId= recordTypeAccount;
    insert cuenta1;    
    
    Contact contacto = new Contact();
    contacto.FirstName = 'Pepe';
    contacto.LastName = 'Botillo';
    contacto.email = 'email@test.com';
    contacto.AccountId=cuenta1.id;
    insert contacto;

    Id recordTypeClienteCC = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

    //Lista de valores para reducir plazo cierre automatico
    CC_Lista_Valores__c clasificacionesAutomaticas = new CC_Lista_Valores__c();
    clasificacionesAutomaticas.Name = 'Plazo Genérico';
    clasificacionesAutomaticas.CC_Activa__c = true;
    clasificacionesAutomaticas.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
    clasificacionesAutomaticas.CC_Valor__c = '0';
    insert clasificacionesAutomaticas;
    
    List<Id> casesIds = new List<Id>();
    List<Case> listaCasos = new List<Case>();
    //Caso1
    Id contactBusq = contacto.Id;
    Case caso1 = new Case();
    caso1.CC_Idioma__c = 'es';
    caso1.Subject = 'Prueba1';
    caso1.CC_Tipo_Cliente__c = 'Cliente';
    caso1.AccountId=cuenta1.id;
    caso1.ContactId = contactBusq;
    caso1.CC_Canal_Operativo__c = 'App BrokerNow';
    caso1.Status = 'Activo';
    caso1.Origin = 'Email';
    caso1.RecordtypeId=recordTypeClienteCC;
    caso1.CC_En_Tercer_Nivel__c = TRUE;
    caso1.CC_MCC_Tematica__c = mccTematica.Id;
    caso1.CC_MCC_ProdServ__c = mccProducto.Id;
    caso1.CC_MCC_Motivo__c = mccMotivo.Id;
    listaCasos.add(caso1);
    insert caso1;
    casesIds.add(caso1.Id);

    //Caso2
    Case caso2 = new Case();
    caso2.CC_Idioma__c = 'es';
    caso2.Subject = 'Prueba1';
    caso2.CC_Tipo_Cliente__c = 'Cliente';
    caso2.AccountId=cuenta1.id;
    caso2.ContactId = contactBusq;
    caso2.Status = 'Activo';
    caso2.Origin = 'Email';
    caso2.CC_Canal_Operativo__c = 'App BrokerNow';
    caso2.RecordtypeId=recordTypeClienteCC;
    caso2.CC_En_Tercer_Nivel__c = FALSE;
    caso2.CC_MCC_Tematica__c = mccTematica.Id;
    caso2.CC_MCC_ProdServ__c = mccProducto.Id;
    caso2.CC_MCC_Motivo__c = mccMotivo.Id;    
    listaCasos.add(caso2);
    insert caso2;
    casesIds.add(caso2.Id);

    Map<Id, EmailTemplate> mapaCasosPlantillas = new Map<Id, EmailTemplate>();
    EmailTemplate templateClienteEs = new EmailTemplate();
    templateClienteEs.FolderId = UserInfo.getUserId();
    templateClienteEs.Name = 'Segunda comunicación - Castellano formal';
    templateClienteEs.DeveloperName = 'Segunda_Comunicacion_Castellano_Formal';
    templateClienteEs.TemplateType = 'Text';
    mapaCasosPlantillas.put(caso1.Id, templateClienteEs);

    //Actividad de solicitud de información
    /*Task actividadSolicitudInfo1 = new Task();
    actividadSolicitudInfo1.WhatId = caso1.Id;
    actividadSolicitudInfo1.Type = 'Solicitud Información';
    actividadSolicitudInfo1.Subject = 'Solicitud Información';
    actividadSolicitudInfo1.Status = 'Open';
    actividadSolicitudInfo1.CC_Referencia_Correo_Saliente__c = 'refRemitir';
    insert actividadSolicitudInfo1;

    Task actividadSolicitudInfo2 = new Task();
    actividadSolicitudInfo2.WhatId = caso2.Id;
    actividadSolicitudInfo2.Type = 'Solicitud Información';
    actividadSolicitudInfo2.Subject = 'Solicitud Información';
    actividadSolicitudInfo2.Status = 'Open';
    actividadSolicitudInfo2.CC_Referencia_Correo_Saliente__c = 'refRemitir';    
    insert actividadSolicitudInfo2;*/

    // create a new email and envelope object
    Messaging.InboundEmail email = new Messaging.InboundEmail() ;
    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    env.fromAddress = 'ac@email.com';
    env.toAddress = 'ac@email.com';

    //Setup header for the email
    List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1 ];
    String headerValueStr;
    EmailServicesAddress headerValue= new EmailServicesAddress();
    if (!EmailServicesList.isEmpty()) {
        headerValue=emailServicesList[0];
        headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
    } else {
        headerValueStr = 'Prueba@IBM';    
    }
    Messaging.InboundEmail.Header header = new  Messaging.InboundEmail.Header();
    header.value = headerValueStr;
    header.name = 'X-SFDC-Original-RCPT';

    // setup the data for the email
    email.subject = 'Create Contact';
    email.fromAddress = 'ac@email.com';
    email.plainTextBody = 'Hola\n#@refSolInfo#\nAdios\n#@2019120425226698#';
    email.htmlBody = 'Hola\n#@refSolInfo#\nAdios\n#@2019120425226698#';
    email.headers = new List<Messaging.InboundEmail.Header>{header};

    // call the email service class and test it with the data in the testMethod
    CC_AC_EmailService testInbound = new CC_AC_EmailService();
    testInbound.handleInboundEmail(email, env);

    test.startTest();
    // update casos estado
    caso1.Status = 'Pendiente Cliente';
    update caso1;
    caso2.Status = 'Pendiente Cliente';
    update caso2;
    CC_Cierre_Automatico_Methods.sendMailSolicitudInf(casesIds);
    test.stopTest();
    Case statusCase1 = [SELECT Status FROM Case WHERE Id =: caso1.Id];
    Case statusCase2 = [SELECT Status FROM Case WHERE Id =: caso2.Id];
    System.assertNotEquals('Cerrado', statusCase1.Status);
    System.assertEquals('Cerrado', statusCase2.Status);
 }
}