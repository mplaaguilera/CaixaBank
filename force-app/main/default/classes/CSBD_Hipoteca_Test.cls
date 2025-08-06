@isTest
public class CSBD_Hipoteca_Test {

    @testSetup
    private static void altaDatosPrueba() {
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        Id idRecordTypeValor = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        CC_Lista_Valores__c valorPrestamo = new CC_Lista_Valores__c();
        valorPrestamo.RecordTypeId = idRecordTypeValor;
        valorPrestamo.CC_Lista__c = listaValores.Id;
        valorPrestamo.Name = 'Préstamo';
        valorPrestamo.CC_Valor__c = '1';
        CC_Lista_Valores__c valorTpv = new CC_Lista_Valores__c();
        valorTpv.RecordTypeId = idRecordTypeValor;
        valorTpv.CC_Lista__c = listaValores.Id;
        valorTpv.Name = 'TPV';
        valorTpv.CC_Valor__c = '5';
        insert new List<CC_Lista_Valores__c>{valorPrestamo, valorTpv};

        Pricebook2 listaPrecios = new Pricebook2();
        listaPrecios.Name = 'Standard Price Book';
        Pricebook2 listaPreciosCsbd = new Pricebook2();+
        listaPreciosCsbd.Name = 'CSBD Price Book';
        listaPreciosCsbd.Description = 'CSBD Price Book';
        listaPreciosCsbd.IsActive = true;
        insert new List<Pricebook2>{listaPrecios, listaPreciosCsbd};
    }

    @isTest
    private static void hipotecaAutomatismoOportunidad() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            CSBD_TestDataFactory.crearEmpleadoOficina('00044');

            Map<String, Object> cuentaContacto = CSBD_TestDataFactory.crearCuentaContacto('12345678M');
            Account cuenta = (Account)cuentaContacto.get('cuenta');
            Contact contacto = (Contact)cuentaContacto.get('contacto');

            User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
            System.runAs(usuarioGestor) {
                EmailTemplate plantilla1 = new EmailTemplate();
                plantilla1.isActive = true;
                plantilla1.Name = 'Prestamos Hipotecarios CLIENTE - CAT';
                plantilla1.DeveloperName = 'CSBD_Test1_' + System.now().getTime();
                plantilla1.TemplateType = 'text';
                plantilla1.FolderId = usuarioGestor.Id;
                EmailTemplate plantilla2 = new EmailTemplate();
                plantilla2.isActive = true;
                plantilla2.Name = 'Prestamos Hipotecarios CLIENTE - CAST';
                plantilla2.DeveloperName = 'CSBD_Test2_' + System.now().getTime();
                plantilla2.TemplateType = 'text';
                plantilla2.FolderId = usuarioGestor.Id;
                EmailTemplate plantilla3 = new EmailTemplate();
                plantilla3.isActive = true;
                plantilla3.Name = 'Prestamos Hipotecarios OFI - CAST';
                plantilla3.DeveloperName = 'CSBD_Test3_' + System.now().getTime();
                plantilla3.TemplateType = 'text';
                plantilla3.FolderId = usuarioGestor.Id;
                EmailTemplate plantilla4 = new EmailTemplate();
                plantilla4.isActive = true;
                plantilla4.Name = 'Prestamos Hipotecarios OFI - CAT';
                plantilla4.DeveloperName = 'CSBD_Test4_' + System.now().getTime();
                plantilla4.TemplateType = 'text';
                plantilla4.FolderId = usuarioGestor.Id;
                insert new List<EmailTemplate>{plantilla1, plantilla2, plantilla3, plantilla4};

                Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', new Map<String, Object>{
                    'CSBD_Estado__c' => 'Activa',
                    'AccountId' => cuenta.Id,
                    'CSBD_Contact__c' => contacto.Id,
                    'CSBD_Now_NIF__c' => cuenta.CC_Numero_Documento__c,
                    'CSBD_Now_Num_Oficina__c' => 00044
                });

                Test.startTest();
                CSBD_Hipoteca.automatismosHipotecas(new List<Id>{hipoteca.Id});
                Test.stopTest();

                System.assertNotEquals(0, [SELECT COUNT() FROM EmailMessage WHERE RelatedToId = :hipoteca.Id LIMIT 1], 'Correo no enviado');
            }
        }
    }
}