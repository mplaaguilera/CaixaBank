@isTest
public with sharing class CSBD_Task_AU_TRHan_Test {

    @TestSetup
    private static void altaDatosPrueba() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

        Account cuenta = crearCuentaContacto('46979396X');

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor.CC_Lista__c = listaValores.Id;
        valor.Name = 'Préstamo';
        valor.CC_Valor__c = '1';
        listaValores.CC_Activa__c = true;
        insert valor;

        Pricebook2 listaPrecios = new Pricebook2();
        listaPrecios.Name = 'CSBD Price Book';
        listaPrecios.Description = 'CSBD Price Book';
        listaPrecios.IsActive = true;
        insert listaPrecios;

        List<EmailTemplate> plantillas = new List<EmailTemplate>();

        EmailTemplate plantillaReclamacionSms = new EmailTemplate();
        plantillaReclamacionSms.isActive = true;
        plantillaReclamacionSms.Name = 'Préstamos - Reclamación SMS CaixaBank Castellano';
        plantillaReclamacionSms.DeveloperName = 'CSBD_Test_plantillaReclamacionSms_' + System.now().getTime();
        plantillaReclamacionSms.TemplateType = 'text';
        plantillaReclamacionSms.FolderId = usuarioGestor.Id;
        plantillas.add(plantillaReclamacionSms);

        EmailTemplate plantillaReclamacionCorreo = new EmailTemplate();
        plantillaReclamacionCorreo.isActive = true;
        plantillaReclamacionCorreo.Name = 'Préstamos - Reclamación Email CaixaBank Castellano';
        plantillaReclamacionCorreo.DeveloperName = 'CSBD_Test_plantillaReclamacionCorreo_' + System.now().getTime();
        plantillaReclamacionCorreo.TemplateType = 'text';
        plantillaReclamacionCorreo.FolderId = usuarioGestor.Id;
        plantillas.add(plantillaReclamacionCorreo);

        EmailTemplate plantillaCierre = new EmailTemplate();
        plantillaCierre.isActive = true;
        plantillaCierre.Name = 'Préstamos - Cierre Email CaixaBank Castellano';
        plantillaCierre.DeveloperName = 'CSBD_Test_plantillaCierre_' + System.now().getTime();
        plantillaCierre.TemplateType = 'text';
        plantillaCierre.FolderId = usuarioGestor.Id;
        plantillas.add(plantillaCierre);
        System.runAs ( usuarioGestor ) {
            insert plantillas;
        }
    }

    private static Account crearCuentaContacto(String nif) {
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = nif;
        cuenta.Phone = '666666666';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.Phone = '666666666';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        return cuenta;
    }

    @isTest
    public static void CSBD_Task_AU_TRHan_Test() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '46979396X'];

        Map<String, Object> campos = new Map<String, Object>();
        campos.put('CSBD_Estado__c', 'Activa');
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        campos.put('CSBD_Referencia_Correo_Saliente__c', 'refcorreo');
        campos.put('CSBD_Dejar_Pendiente_Cliente__c', true);
        campos.put('CSBD_Email_Solicitud__c', 'test@test.com');
        campos.put('CSBD_Telefono_Solicitud__c', '666666666');
        Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);

        OpportunityShare oppshare = new OpportunityShare();
        oppshare.UserOrGroupId = usuarioGestor.Id;
        oppshare.OpportunityId = prestamo.Id;
        oppshare.OpportunityAccessLevel = 'Edit';
        insert oppshare;

        EmailMessage correo = new EmailMessage();
        correo.CC_Aplicacion__c = 'CSBD';
        correo.RelatedToId = prestamo.Id;
        correo.CSBD_Oportunidad_Id__c = prestamo.Id;
        correo.Incoming = false;
        correo.FromAddress = [SELECT Address FROM OrgWideEmailAddress WHERE DisplayName = 'CSBD - CaixaBank'].Address;
        correo.ToAddress = 'test@test.org';
        correo.Subject = 'asunto correo saliente';
        correo.HtmlBody = '#@refcorreo#';
        insert correo;
        
        System.runAs ( usuarioGestor ) {
            prestamo.OwnerId = usuarioGestor.Id;
            update prestamo;
            Test.startTest();
            Task tareaPendienteCliente = [SELECT Id, Status FROM Task WHERE WhatId = :prestamo.Id
                                                AND Status = 'Open' AND Type = 'Pendiente Cliente'];

            tareaPendienteCliente.Status = 'Rechazada';
            update tareaPendienteCliente;
            Test.stopTest();

            System.assertEquals(
                'Activa', [SELECT CSBD_Estado__c FROM Opportunity WHERE Id = :prestamo.Id].CSBD_Estado__c,
                'La oportunidad no se ha reactivado'
            );
        }
    }
}