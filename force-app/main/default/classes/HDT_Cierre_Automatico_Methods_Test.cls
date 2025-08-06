/**
* @description       :
* @author            : Moisés Cano
* @group             :
* @last modified on  : 03-23-2023
* @last modified by  : Moisés Cano
* Modifications Log
* Ver   Date         Author            Modification
* 1.0   03-23-2022   Moisés Cano   Initial Version
**/
@IsTest
public with sharing class HDT_Cierre_Automatico_Methods_Test {
    
    
    
    @TestSetup
    static void makeData() {
        
        EmailTemplate templateClienteEs = new EmailTemplate();
        templateClienteEs.FolderId = UserInfo.getUserId();
        templateClienteEs.Name = 'Segunda Comunicación - Castellano Formal';
        templateClienteEs.DeveloperName = 'Segunda_Comunicacion_Castellano_Formal';
        templateClienteEs.TemplateType = 'Text';
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert templateClienteEs;
        }
        
        
        EmailTemplate templateEmpleadoEs = new EmailTemplate();
        templateEmpleadoEs.FolderId = UserInfo.getUserId();
        templateEmpleadoEs.Name = 'Segunda Comunicación Empleado - Castellano Formal';
        templateEmpleadoEs.DeveloperName = 'Segunda_Comunicacion_Empleado_Castellano_Formal';
        templateEmpleadoEs.TemplateType = 'Text';
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert templateEmpleadoEs;
        }
        
    }
    
    /*static void CC_Cierre_Automatico_SolicitudInformacion() {
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            CC_Lista_Valores__c lov = new CC_Lista_Valores__c();
            lov.CC_Valor__c = '24';
            lov.Name = 'Plazo Genérico';
            insert lov;
            
            Contact contacto = new Contact();
            contacto.FirstName = 'Pepe';
            contacto.LastName = 'Botillo';
            contacto.email = 'email@test.com';
            contacto.RecordTypeId  = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            insert contacto;
            
            Id contactBusq = [SELECT Id FROM Contact LIMIT 1].Id;
            system.debug('contactBusq ' + contactBusq);
            //Id mccMotivBusq = [SELECT Id FROM CC_MCC__c LIMIT 1].Id;
            
            
            Case caso = new Case();
            //caso.CC_MCC_Motivo__c = mccMotivo.Id;
            caso.CC_Buzon_Salida__c = 'prueba@prueba.com';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Prueba';
            caso.CC_Tipo_Cliente__c = 'Empleado';
            caso.ContactId = contactBusq;
            caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso.Status = 'Activo';
            caso.Origin = 'Email';
            caso.CC_Tipo_Contacto__c = 'Consulta';
            caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
            
            insert caso;
            
            
            Id casoBusq = caso.Id;
            
            System.debug('++++++++HOLA +++++++++');
            System.debug(casoBusq);
            
            System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()){
                test.startTest();
                Datetime decalaje = HDT_Cierre_Automatico_Methods.CC_Cierre_Automatico_SolicitudInformacion(casoBusq);
                
                test.stopTest();
                Date fechaEsperada = decalaje.date();
                
                Date fechaDeHoy = System.now().date();
                
                System.assertNotEquals(null,decalaje);
                System.assert(fechaEsperada > fechaDeHoy);
            }
        } 
        
    }*/
    
    @IsTest
    static void CC_Cierre_Automatico_SolicitudInformacionEmpleado() {
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            CC_Lista_Valores__c lov = new CC_Lista_Valores__c();
            lov.CC_Valor__c = '24';
            lov.Name = 'Plazo genérico empleados';
            insert lov;
            
            Id recordTypeAccount = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            
            Account cuenta1 = new Account();
            cuenta1.Name = 'CuentaEmpleado1';
            cuenta1.CC_Email__c = 'cuentasemp1@test.com';
            cuenta1.RecordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            
            insert cuenta1;
            
            Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            
            Contact contacto1 = new Contact();
            contacto1.AccountId = cuenta1.Id;
            contacto1.FirstName = 'Empleado Test1';
            contacto1.LastName = 'Apellido Empleado Test1';
            contacto1.email = 'emailempleado1@test.com';
            contacto1.RecordTypeId = recordTypeContacto;
            insert contacto1;
            
            Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
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
            System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()){
                Test.startTest();
                Datetime fechaCierre = HDT_Cierre_Automatico_Methods.CC_Cierre_Automatico_SolicitudInformacion(caso.Id);
                
                Test.stopTest();
                BusinessHours diasLaborables = [SELECT Id FROM BusinessHours WHERE name='CC_Empleados'];
                Datetime fechaEsperada = System.now();
                do{
                    fechaEsperada = fechaEsperada.addHours(24);
                }while(!BusinessHours.isWithin(diasLaborables.id, fechaEsperada));
                
                System.assertNotEquals(null,fechaCierre);
                System.assert(fechaEsperada.isSameDay(fechaCierre));
                
            }
        }
        
        
    }
    
    @IsTest
    static void sendMailSolicitudInfES() {
        //[SELECT Id FROM EmailTemplate WHERE Folder.DeveloperName = : 'Solicitud información'
        //AND Name = : 'Plantilla solicitud información'].Id;
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Contact contacto = new Contact();
            contacto.FirstName = 'Pepe';
            contacto.LastName = 'Botillo';
            contacto.email = 'email@test.com';
            contacto.RecordTypeId  = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            
            insert contacto;
            
            List<Case> casesInsert = new List<Case>();
            
            //Caso 'es'
            Id contactBusq = [SELECT Id FROM Contact WHERE FirstName='Pepe' LIMIT 1].Id;
            Case caso = new Case();
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Prueba1';
            caso.CC_Tipo_Cliente__c = 'Empleado';
            caso.ContactId = contactBusq;
            caso.Status = 'Activo';
            caso.Origin = 'Email';
            caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            
            caso.CC_Tipo_Contacto__c = 'Consulta';
            caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
            casesInsert.add(caso);
            
            Case caso2 = new Case();
            caso2.CC_Idioma__c = 'es';
            caso2.Subject = 'Prueba2';
            caso2.CC_Tipo_Cliente__c = 'Empleado';
            caso2.ContactId = contactBusq;
            caso2.Status = 'Activo';
            caso2.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            
            caso2.Origin = 'Email';
            caso2.CC_Tipo_Contacto__c = 'Consulta';
            caso2.CC_Canal_Procedencia__c = 'Servicios Centrales';
            casesInsert.add(caso2);
            
            insert casesInsert;
            
            List<Case> listCasos = casesInsert;
            List<ID> idCasos = new List<ID>();
            for (Case c: ListCasos){
                idCasos.add(c.Id);
            }
            
            System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()){
                test.startTest();
                system.debug('idCasos ' + idCasos);
                
                HDT_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
                
                test.stopTest();
                
                //Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
                List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información'];
                system.debug('tareas ' + tareas);
                System.assert(tareas.size() > 0);
            }
        }
    }
    
    
    @IsTest
    static void sendMailSolicitudInfCA() {
        //[SELECT Id FROM EmailTemplate WHERE Folder.DeveloperName = : 'Solicitud información'
        //AND Name = : 'Plantilla solicitud información'].Id;
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Contact contacto = new Contact();
            contacto.FirstName = 'Pepe';
            contacto.LastName = 'Botillo';
            contacto.email = 'email@test.com';
            insert contacto;
            
            //Caso 'ca'
            Case caso1 = new Case();
            caso1.CC_Idioma__c = 'ca';
            caso1.Subject = 'Prueba3';
            caso1.CC_Tipo_Cliente__c = 'Empleado';
            caso1.ContactId = contacto.Id;
            caso1.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso1.Status = 'Activo';
            caso1.Origin = 'Email';
            caso1.CC_Tipo_Contacto__c = 'Consulta';
            caso1.CC_Canal_Procedencia__c = 'Servicios Centrales';
            
            Case caso2 = new Case();
            caso2.CC_Idioma__c = 'ca';
            caso2.Subject = 'Prueba4';
            caso2.CC_Tipo_Cliente__c = 'Empleado';
            caso2.ContactId = contacto.Id;
            caso2.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso2.Status = 'Activo';
            caso2.Origin = 'Email';
            caso2.CC_Tipo_Contacto__c = 'Consulta';
            caso2.CC_Canal_Procedencia__c = 'Servicios Centrales';
            
            insert new List<Case>{caso1, caso2};
            
            
            List<Id> idCasos = new List<Id>{caso1.Id, caso2.Id};
            
            
            System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
                
                test.startTest();
                
                HDT_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
                
                test.stopTest();
                
                //Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
                List<Task> tareas2 = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información'];
                system.debug('tareas2 ' + tareas2);
                System.assert(tareas2.size() > 0);
            }
        }
        
    }
    
    @IsTest
    static void sendMailSolicitudInfEN() {
        //[SELECT Id FROM EmailTemplate WHERE Folder.DeveloperName = : 'Solicitud información'
        //AND Name = : 'Plantilla solicitud información'].Id;
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Contact contacto = new Contact();
            contacto.FirstName = 'Pepe';
            contacto.LastName = 'Botillo';
            contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            
            contacto.email = 'email@test.com';
            insert contacto;
            
            Id contactBusq = contacto.Id;
            
            List<Case> casesInsert = new List<Case>();
            
            //Caso 'en'
            Case caso5 = new Case();
            caso5.CC_Idioma__c = 'en';
            caso5.Subject = 'Prueba5';
            caso5.CC_Tipo_Cliente__c = 'Empleado';
            caso5.ContactId = contactBusq;
            caso5.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            
            caso5.Status = 'Activo';
            caso5.Origin = 'Email';
            caso5.CC_Tipo_Contacto__c = 'Consulta';
            caso5.CC_Canal_Procedencia__c = 'Servicios Centrales';
            casesInsert.add(caso5);
            
            Case caso6 = new Case();
            caso6.CC_Idioma__c = 'en';
            caso6.Subject = 'Prueba6';
            caso6.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            
            caso6.CC_Tipo_Cliente__c = 'Empleado';
            caso6.ContactId = contactBusq;
            caso6.Status = 'Activo';
            caso6.Origin = 'Email';
            caso6.CC_Tipo_Contacto__c = 'Consulta';
            caso6.CC_Canal_Procedencia__c = 'Servicios Centrales';
            casesInsert.add(caso6);
            
            Case caso7 = new Case();
            caso7.CC_Idioma__c = '';
            caso7.Subject = 'Prueba6';
            caso7.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            
            caso7.CC_Tipo_Cliente__c = 'Empleado';
            caso7.ContactId = contactBusq;
            caso7.Status = 'Activo';
            caso7.Origin = 'Email';
            caso7.CC_Tipo_Contacto__c = 'Consulta';
            caso7.CC_Canal_Procedencia__c = 'Servicios Centrales';
            casesInsert.add(caso7);
            
            insert casesInsert;
            
            List<Case> listCasos3 = casesInsert;
            List<ID> idCasos3 = new List<ID>();
            for (Case c: listCasos3){
                idCasos3.add(c.Id);
            }
            System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
                test.startTest();
                HDT_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos3);
                test.stopTest();
                
                //Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
                List<Task> tareas3 = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información'];
                System.assert(tareas3.size() > 0);
            }
        }
    }
    
    
    
    ///////////////////////////////////// CLASES TEST Sergio Castro //////////////
    
    
    @IsTest
    static void sendMailSolicitudInfEmpleado() {
        //[SELECT Id FROM EmailTemplate WHERE Folder.DeveloperName = : 'Solicitud información'
        //AND Name = : 'Plantilla solicitud información'].Id;
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
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
            
            Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            
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
                System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
                    Test.startTest();
                    
                    Test.stopTest();
                    
                    HDT_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
                    //Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
                    List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND WhatId = :casoEs.Id];
                    //List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información'];
                    System.assert(tareas.size() > 0);
                }
            }
        }
        
        @IsTest
        static void sendMailSolicitudInfEmpleado2() {
            //[SELECT Id FROM EmailTemplate WHERE Folder.DeveloperName = : 'Solicitud información'
            //AND Name = : 'Plantilla solicitud información'].Id;
            
            System.runAs(new User(Id = UserInfo.getUserId())) {
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
                
                Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
                
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
                    System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
                        Test.startTest();
                        
                        Test.stopTest();
                        HDT_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
                        //Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
                        List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND WhatId = :casoCa.Id];
                        //List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información'];
                        System.assert(tareas.size() > 0);
                        
                    }
                }
            }
            
            @IsTest
            static void CC_Cierre_Automatico_SolicitudInformacionDetalleConsultaInformado1() {
                
                System.runAs(new User(Id = UserInfo.getUserId())) {
                    Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
                    
                    Account cuenta = new Account();
                    cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
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
                    
                    Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
                    
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
                    caso.CC_Detalles_Solucion__c = 'Servicios Centrales';
                    caso.CC_Detalles_Consulta__c = 'Servicios Centrales';
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
                    casoEs.CC_Detalles_Solucion__c = 'Servicios Centrales';
                    casoEs.CC_Detalles_Consulta__c = 'Servicios Centrales';
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
                    casoCa.CC_Detalles_Solucion__c = 'Servicios Centrales';
                    casoCa.CC_Detalles_Consulta__c = 'Servicios Centrales';
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
                    casoEn.CC_Detalles_Solucion__c = 'Servicios Centrales';
                    casoEn.CC_Detalles_Consulta__c = 'Servicios Centrales';
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
                        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
                            Test.startTest();
                            
                            HDT_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
                            
                            Test.stopTest();
                            //Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
                            List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND WhatId = :casoEs.Id];
                            //List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información'];
                            System.assert(tareas.size() > 0);
                        }
                    }                    
                }
                @IsTest
                static void CC_Cierre_Automatico_SolicitudInformacionDetalleConsultaInformado2() {
                    
                    System.runAs(new User(Id = UserInfo.getUserId())) {
                        Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
                        
                        Account cuenta = new Account();
                        cuenta.Name = 'Cuenta Test Solicitud Info Empleado';
                        cuenta.CC_Email__c = 'cuentasolinfoemp@test.com';
                        cuenta.RecordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
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
                        
                        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
                        
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
                        caso.CC_Detalles_Solucion__c = 'Servicios Centrales';
                        caso.CC_Detalles_Consulta__c = 'Servicios Centrales';
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
                        casoEs.CC_Detalles_Solucion__c = 'Servicios Centrales';
                        casoEs.CC_Detalles_Consulta__c = 'Servicios Centrales';
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
                        casoCa.CC_Detalles_Solucion__c = 'Servicios Centrales';
                        casoCa.CC_Detalles_Consulta__c = 'Servicios Centrales';
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
                        casoEn.CC_Detalles_Solucion__c = 'Servicios Centrales';
                        casoEn.CC_Detalles_Consulta__c = 'Servicios Centrales';
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
                            System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
                                HDT_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
                                
                                
                                Test.stopTest();
                                //Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
                                List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND WhatId = :casoCa.Id];
                                //List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información'];
                                System.assert(tareas.size() > 0);
                            }
                        }
                    }
                    
                    /********************************************** Casos Empleado CSI Bankia ************************************************************************/
                    
                    /*@IsTest
                    static void CC_Cierre_Automatico_SolicitudInformacionEmpleadoCSI() {
                        CC_Lista_Valores__c lov = new CC_Lista_Valores__c();
                        lov.CC_Valor__c = '24';
                        lov.Name = 'Plazo genérico empleados';
                        insert lov;
                        
                        Id recordTypeAccount = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
                        
                        Account cuenta1 = new Account();
                        cuenta1.Name = 'CuentaEmpleado1';
                        cuenta1.RecordTypeId  =Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
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
                        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
                        caso.Subject = 'Prueba1';
                        caso.AccountId = cuenta1.Id;
                        caso.ContactId = contacto1.Id;
                        //caso.ContactId = contactBusq;
                        caso.Status = 'Activo';
                        caso.Origin = 'Email';
                        caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
                        caso.CC_Tipo_Contacto__c = 'Consulta';
                        insert caso;
                        
                        
                        Id casoBusq = caso.Id;
                        
                        test.startTest();
                        //Datetime decalaje = HDT_Cierre_Automatico_Methods.CC_Cierre_Automatico_SolicitudInformacion(caso.Id);
                        test.stopTest();
                        
                        //Date fechaEsperada = decalaje.date();
                        
                        // Date fechaDeHoy = System.now().date();
                        
                        // System.assertNotEquals(null,decalaje);
                        //System.assert(fechaEsperada > fechaDeHoy);
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
                        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
                        caso.Subject = 'Prueba';
                        caso.AccountId = cuenta.Id;
                        caso.ContactId = contacto.Id;
                        caso.Status = 'Activo';
                        caso.Origin = 'Email';
                        caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
                        caso.CC_Tipo_Contacto__c = 'Consulta';
                        casesInsert.add(caso);
                        
                        //Caso 'es'
                        Case casoEs = new Case();
                        casoEs.CC_Idioma__c = 'es';
                        casoEs.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
                        casoEs.Subject = 'Prueba1';
                        casoEs.AccountId = cuenta.Id;
                        casoEs.ContactId = contacto.Id;
                        casoEs.Status = 'Activo';
                        casoEs.Origin = 'Email';
                        casoEs.CC_Canal_Procedencia__c = 'Servicios Centrales';
                        casoEs.CC_Tipo_Contacto__c = 'Consulta';
                        casesInsert.add(casoEs);
                        
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
                            
                            HDT_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
                            Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
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
                            
                            //Caso 'es'
                            Case casoEs = new Case();
                            casoEs.CC_Idioma__c = 'es';
                            casoEs.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
                            casoEs.Subject = 'Prueba1';
                            casoEs.AccountId = cuenta.Id;
                            casoEs.ContactId = contacto.Id;
                            casoEs.Status = 'Activo';
                            casoEs.Origin = 'Email';
                            casoEs.CC_Canal_Procedencia__c = 'Servicios Centrales';
                            casoEs.CC_Tipo_Contacto__c = 'Consulta';
                            casesInsert.add(casoEs);
                            
                            
                            insert casesInsert;
                            
                            
                            //List<Case> ListCasos = [SELECT Id FROM Case WHERE ContactId =: contactBusq];
                            List<ID> idCasos = new List<ID>();
                            //for (Case c: ListCasos){
                                //        idCasos.add(casoEs.Id);
                                idCasos.add(casoEs.Id);
                                //        idCasos.add(caso.Id);
                                //}
                                
                                Test.startTest();
                                
                                HDT_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
                                Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
                                List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND WhatId = :casoEs.Id AND RecordTypeId =: taskRecordTypeId];
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
                                cuenta.RecordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
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
                                
                                Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
                                
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
                                caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
                                caso.CC_Tipo_Contacto__c = 'Consulta';
                                caso.CC_Detalles_Solucion__c = 'Servicios Centrales';
                                caso.CC_Detalles_Consulta__c = 'Servicios Centrales';
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
                                casoEs.CC_Canal_Procedencia__c = 'Servicios Centrales';
                                casoEs.CC_Tipo_Contacto__c = 'Consulta';
                                casoEs.CC_Detalles_Solucion__c = 'Servicios Centrales';
                                casoEs.CC_Detalles_Consulta__c = 'Servicios Centrales';
                                casesInsert.add(casoEs);
                                
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
                                    
                                    HDT_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
                                    Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
                                    List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND WhatId = :casoEs.Id AND RecordTypeId =: taskRecordTypeId];
                                    //List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información'];
                                    System.assert(tareas.size() > 0);
                                    
                                    Test.stopTest();
                                }
                                
                                /*@IsTest
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
                                    
                                    //Caso 'ca'
                                    Case casoCa = new Case();
                                    casoCa.CC_Idioma__c = 'es';
                                    casoCa.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
                                    casoCa.Subject = 'Prueba2';
                                    casoCa.AccountId = cuenta.Id;
                                    casoCa.ContactId = contacto.Id;
                                    casoCa.Status = 'Activo';
                                    casoCa.Origin = 'Email';
                                    casoCa.CC_Canal_Procedencia__c = 'Servicios Centrales';
                                    casoCa.CC_Tipo_Contacto__c = 'Consulta';
                                    casoCa.CC_Detalles_Solucion__c = 'Servicios Centrales';
                                    casoCa.CC_Detalles_Consulta__c = 'Servicios Centrales';
                                    casesInsert.add(casoCa);
                                    
                                    insert casesInsert;
                                    
                                    
                                    //List<Case> ListCasos = [SELECT Id FROM Case WHERE ContactId =: contactBusq];
                                    List<ID> idCasos = new List<ID>();
                                    //for (Case c: ListCasos){
                                        //idCasos.add(casoEs.Id);
                                        idCasos.add(casoCa.Id);
                                        
                                        //idCasos.add(caso.Id);
                                        //}
                                        
                                        Test.startTest();
                                        
                                        HDT_Cierre_Automatico_Methods.sendMailSolicitudInf(idCasos);
                                        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
                                        List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND WhatId = :casoCa.Id AND RecordTypeId =: taskRecordTypeId];
                                        //List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información'];
                                        System.assert(tareas.size() > 0);
                                        
                                        Test.stopTest();
                                    }
                                    /******************************************************************************************************************************************/
                                    
                                    /*@IsTest
                                    static void sendMailSolicitudInfCAM() {
                                        
                                        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
                                        CC_MCC__c mccProducto = new CC_MCC__c();
                                        mccProducto.Name = 'Cuenta corriente';
                                        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
                                        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
                                        mccProducto.RecordTypeId = recordTypeIdProducto;
                                        //mccProducto.CC_Tematica__c = mccTematica.Id;
                                        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
                                        Insert mccProducto;
                                        
                                        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                                        CC_MCC__c mccMotivo = new CC_MCC__c();
                                        mccMotivo.Name = 'Apertura sin autorización';
                                        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
                                        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
                                        mccMotivo.RecordTypeId = recordTypeIdMotivo;
                                        //mccMotivo.CC_Tematica__c = mccTematica.Id;
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
                                        //caso.CC_MCC_Tematica__c = mccTematica.Id;
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
                                        //caso2.CC_MCC_Tematica__c = mccTematica.Id;
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
                                        
                                        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
                                        List<Task> tareas = [SELECT Id FROM Task WHERE Subject = 'Cierre Automático Solicitud Información' AND RecordTypeId =: taskRecordTypeId];
                                        test.stopTest();
                                        
                                        // System.assert(tareas.size() > 0);
                                    }*/
                                    @isTest
                                    static void cierreAutomatico3N()
                                    {
                                        
                                        System.runAs(new User(Id = UserInfo.getUserId())) {
                                            Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                                            CC_MCC__c mccMotivo = new CC_MCC__c();
                                            mccMotivo.Name = 'Apertura sin autorización';
                                            mccMotivo.CC_Tipo_Cliente__c = 'HDT Empleado';
                                            mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
                                            mccMotivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                                            //mccMotivo.CC_Tematica__c = mccTematica.Id;
                                            //mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
                                            mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
                                            Insert mccMotivo;
                                            
                                            Id recordTypeAccount = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
                                            
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
                                            
                                            Id recordTypeClienteCC = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
                                            
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
                                            caso1.CC_Tipo_Cliente__c = 'Empleado';
                                            caso1.AccountId=cuenta1.id;
                                            caso1.ContactId = contactBusq;
                                            caso1.Status = 'Activo';
                                            caso1.Origin = 'Email';
                                            caso1.RecordtypeId=recordTypeClienteCC;
                                            caso1.CC_En_Tercer_Nivel__c = TRUE;
                                            //caso1.CC_MCC_Tematica__c = mccTematica.Id;
                                            //caso1.CC_MCC_ProdServ__c = mccProducto.Id;
                                            caso1.CC_MCC_Motivo__c = mccMotivo.Id;
                                            listaCasos.add(caso1);
                                            insert caso1;
                                            casesIds.add(caso1.Id);
                                            
                                            //Caso2
                                            Case caso2 = new Case();
                                            caso2.CC_Idioma__c = 'es';
                                            caso2.Subject = 'Prueba1';
                                            caso2.CC_Tipo_Cliente__c = 'Empleado';
                                            caso2.AccountId=cuenta1.id;
                                            caso2.ContactId = contactBusq;
                                            caso2.Status = 'Activo';
                                            caso2.Origin = 'Email';
                                            caso2.RecordtypeId=recordTypeClienteCC;
                                            caso2.CC_En_Tercer_Nivel__c = FALSE;
                                            //caso2.CC_MCC_Tematica__c = mccTematica.Id;
                                            //caso2.CC_MCC_ProdServ__c = mccProducto.Id;
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
                                            
                                            // setup the data for the email
                                            email.subject = 'Create Contact';
                                            email.fromAddress = 'ac@email.com';
                                            email.plainTextBody = 'Hola\n#@refSolInfo#\nAdios\n#@2019120425226698#';
                                            email.htmlBody = 'Hola\n#@refSolInfo#\nAdios\n#@2019120425226698#';
                                            
                                            // call the email service class and test it with the data in the testMethod
                                            CC_AC_EmailService testInbound = new CC_AC_EmailService();
                                            testInbound.handleInboundEmail(email, env);
                                            
                                            test.startTest();
                                            
                                            // update casos estado
                                            caso1.Status = 'Pendiente Cliente';
                                            update caso1;
                                            caso2.Status = 'Pendiente Cliente';
                                            update caso2;
                                            System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
                                                HDT_Cierre_Automatico_Methods.sendMailSolicitudInf(casesIds);
                                                test.stopTest();

                                                Case statusCase1 = [SELECT Status FROM Case WHERE Id =: caso1.Id];
                                                Case statusCase2 = [SELECT Status FROM Case WHERE Id =: caso2.Id];
                                                System.assertNotEquals('Cerrado', statusCase1.Status);
                                                //System.assertEquals('Cerrado', statusCase2.Status);
                                               
                                            }
                                        }

                                    }
                                }