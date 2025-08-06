@isTest
public class CSBD_Reclamaciones_Prestamos_Test {

    @testSetup
    public static void altaDatosPrueba() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
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
            valor.CC_Activa__c = true;
            insert valor;

            Pricebook2 listaPrecios = new Pricebook2();
            listaPrecios.Name = 'CSBD Price Book';
            listaPrecios.Description = 'CSBD Price Book';
            listaPrecios.IsActive = true;
            insert listaPrecios;

            Map<String, SObject> cuentaContacto = CSBD_TestDataFactory.crearCuentaContacto('12345678R');
            Account cuenta = (Account)cuentaContacto.get('cuenta');
            Contact contacto = (Contact)cuentaContacto.get('contacto');

            User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

            Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
                'CSBD_Titulo__c' => 'prestamoTest',
                'CSBD_Estado__c' => 'Activa',
                'AccountId' => cuenta.Id,
                'CSBD_Contact__c' => contacto.Id,
                'CSBD_Now_NIF__c' => cuenta.CC_Numero_Documento__c,
                'CSBD_Referencia_Correo_Saliente__c' => 'refcorreo',
                'CSBD_Dejar_Pendiente_Cliente__c' => true,
                'CSBD_Email_Solicitud__c' => 'test@test.com',
                'CSBD_Telefono_Solicitud__c' => '666666666',
                'OwnerId' => usuarioGestor.Id
            });

            System.runAs(usuarioGestor) {
                EmailTemplate plantillaReclamacionSms = new EmailTemplate();
                plantillaReclamacionSms.isActive = true;
                plantillaReclamacionSms.Name = 'Préstamos - Reclamación SMS CaixaBank Castellano';
                plantillaReclamacionSms.DeveloperName = 'CSBD_Test_plantillaReclamacionSms_' + System.now().getTime();
                plantillaReclamacionSms.TemplateType = 'text';
                plantillaReclamacionSms.HtmlValue = 'cuerpo plantilla';
                plantillaReclamacionSms.FolderId = usuarioGestor.Id;
                EmailTemplate plantillaReclamacionCorreo = new EmailTemplate();
                plantillaReclamacionCorreo.isActive = true;
                plantillaReclamacionCorreo.Name = 'Préstamos - Reclamación Email CaixaBank Castellano';
                plantillaReclamacionCorreo.DeveloperName = 'CSBD_Test_plantillaReclamacionCorreo_' + System.now().getTime();
                plantillaReclamacionCorreo.TemplateType = 'text';
                plantillaReclamacionCorreo.HtmlValue = 'cuerpo plantilla';
                plantillaReclamacionCorreo.FolderId = usuarioGestor.Id;
                EmailTemplate plantillaCierre = new EmailTemplate();
                plantillaCierre.isActive = true;
                plantillaCierre.Name = 'Préstamos - Cierre Email CaixaBank Castellano';
                plantillaCierre.DeveloperName = 'CSBD_Test_plantillaCierre_' + System.now().getTime();
                plantillaCierre.TemplateType = 'text';
                plantillaCierre.HtmlValue = 'cuerpo plantilla';
                plantillaCierre.FolderId = usuarioGestor.Id;
                insert new List<EmailTemplate>{plantillaReclamacionSms, plantillaReclamacionCorreo, plantillaCierre};
            }
        }
    }

    @isTest
    private static void crearReclamaciones() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD'];
        Opportunity prestamo = [SELECT CSBD_Email_Solicitud__c FROM Opportunity WHERE CSBD_Titulo__c = 'prestamoTest'];
        System.runAs(usuarioGestor) {
            OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName LIKE 'CSBD%' LIMIT 1];
            CSBD_Remitente_Enviar_Correo__c config = new CSBD_Remitente_Enviar_Correo__c();
            config.CSBD_Buzon_CaixaBank__c = owa.Address;
            config.CSBD_Buzon_ImaginBank__c = owa.Address;
            config.CSBD_Buzon_Alta_digital_de_menores__c = owa.Address;
            insert config;

            EmailMessage correo = new EmailMessage();
            correo.CC_Aplicacion__c = 'CSBD';
            correo.RelatedToId = prestamo.Id;
            correo.CSBD_Oportunidad_Id__c = prestamo.Id;
            correo.Incoming = false;
            correo.FromAddress = owa.Address;
            correo.ToAddress = 'test@test.com';
            correo.Subject = 'asunto correo saliente';
            correo.HtmlBody = '#@refcorreo#';
            insert correo;

            Test.startTest();
            //1a reclamación
            CSBD_Reclamaciones_Prestamos.ReclamacionClienteCsbd reclamacion1 = new CSBD_Reclamaciones_Prestamos.ReclamacionClienteCsbd();
            reclamacion1.numeroReclamacion = 1;
            reclamacion1.idOportunidad = prestamo.Id;
            CSBD_Reclamaciones_Prestamos.enviarReclamacion(
                new List<CSBD_Reclamaciones_Prestamos.ReclamacionClienteCsbd>{reclamacion1}
            );

            //2a reclamación
            CSBD_Reclamaciones_Prestamos.ReclamacionClienteCsbd reclamacion2 = new CSBD_Reclamaciones_Prestamos.ReclamacionClienteCsbd();
            reclamacion2.numeroReclamacion = 2;
            reclamacion2.idOportunidad = prestamo.Id;
            CSBD_Reclamaciones_Prestamos.enviarReclamacion(
                new List<CSBD_Reclamaciones_Prestamos.ReclamacionClienteCsbd>{reclamacion2}
            );

            //3a reclamación
            CSBD_Reclamaciones_Prestamos.ReclamacionClienteCsbd reclamacion3 = new CSBD_Reclamaciones_Prestamos.ReclamacionClienteCsbd();
            reclamacion3.numeroReclamacion = 3;
            reclamacion3.idOportunidad = prestamo.Id;
            CSBD_Reclamaciones_Prestamos.enviarReclamacion(
                new List<CSBD_Reclamaciones_Prestamos.ReclamacionClienteCsbd>{reclamacion3}
            );
            Test.stopTest();

            List<EmailMessage> mailEnviado = [SELECT MessageDate, FromAddress, ToAddress, CcAddress, Subject, HtmlBody, TextBody FROM EmailMessage WHERE CSBD_Oportunidad_Id__c = :prestamo.Id];
            System.assertEquals('test@test.com', mailEnviado[0].ToAddress);
            System.assertEquals(prestamo.CSBD_Email_Solicitud__c, mailEnviado[1].ToAddress);
            System.assertEquals(prestamo.CSBD_Email_Solicitud__c, mailEnviado[2].ToAddress);
        }
    }
}