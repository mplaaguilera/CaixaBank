@isTest
public class CSBD_Denegacion_Auto_Oportunidades_Test {

    @TestSetup
    private static void testSetup() {
        System.runAs(CSBD_Usuarios.usuarioAdministrador()) {
            Id recordTypeIdListaValores = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
            CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
            listaValores.RecordTypeId = recordTypeIdListaValores;
            listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
            CC_Lista_Valores__c listaProductosIniciales = new CC_Lista_Valores__c();
            listaProductosIniciales.RecordTypeId = recordTypeIdListaValores;
            listaProductosIniciales.Name = 'CSBD: Productos iniciales oportunidad';
            insert new List<CC_Lista_Valores__c>{listaValores, listaProductosIniciales};

            Id recordTypeIdListaValoresValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            CC_Lista_Valores__c valorPrestamo = new CC_Lista_Valores__c();
            valorPrestamo.RecordTypeId = recordTypeIdListaValoresValor;
            valorPrestamo.CC_Lista__c = listaValores.Id;
            valorPrestamo.Name = 'Préstamo';
            valorPrestamo.CC_Valor__c = '1';
            CC_Lista_Valores__c valorProductosIniciales = new CC_Lista_Valores__c();
            valorProductosIniciales.RecordTypeId = recordTypeIdListaValoresValor;
            valorProductosIniciales.CC_Lista__c = listaProductosIniciales.Id;
            valorProductosIniciales.Name = 'Préstamo';
            valorProductosIniciales.CC_Valor__c = 'Préstamo';
            valorProductosIniciales.CC_Orden__c = 1;
            insert new List<CC_Lista_Valores__c>{valorPrestamo, valorProductosIniciales};

            Pricebook2 listaPreciosCsbd = new Pricebook2();
            listaPreciosCsbd.Name = 'CSBD Price Book';
            listaPreciosCsbd.Description = 'CSBD Price Book';
            listaPreciosCsbd.IsActive = true;
            insert listaPreciosCsbd;

            Product2 productoPrestamo = new Product2();
            productoPrestamo.Name = 'Préstamo';
            productoPrestamo.Family = 'Préstamos';
            productoPrestamo.IsActive = true;
            insert productoPrestamo;

            PricebookEntry precioProducto = new PricebookEntry();
            precioProducto.Pricebook2Id = Test.getStandardPricebookId();
            precioProducto.Product2Id = productoPrestamo.Id;
            precioProducto.UnitPrice = 0;
            precioProducto.IsActive = true;
            PricebookEntry precioProductoCsbd = new PricebookEntry();
            precioProductoCsbd.Pricebook2Id = listaPreciosCsbd.Id;
            precioProductoCsbd.Product2Id = productoPrestamo.Id;
            precioProductoCsbd.UnitPrice = 0;
            precioProductoCsbd.IsActive = true;
            insert new List<PricebookEntry>{precioProducto, precioProductoCsbd};

            CSBD_Denegacion_Auto_Solicitud__c regla1 = new CSBD_Denegacion_Auto_Solicitud__c();
            regla1.CSBD_Record_Type_Oportunidad__c = 'CSBD_Prestamo';
            regla1.CSBD_Orden__c = 1;
            regla1.CSBD_Empresa_Proveedora__c = 'CaixaBank';
            regla1.CSBD_Circuito_Contratacion_Online__c = true;
            regla1.CSBD_Importe_Desde__c = 1000;
            regla1.CSBD_Importe_Hasta__c = 2000;
            regla1.CSBD_Escala_Maestra_Desde__c = 2;
            regla1.CSBD_Escala_Maestra_Hasta__c = 4;
            regla1.CSBD_Excluir_Clientes_Limite__c = false;
            regla1.CSBD_Denegada__c = true;
            regla1.CSBD_Resolucion__c = 'res1';
            regla1.CSBD_Enviar_Correo_Auto__c = true;
            regla1.CSBD_Plantilla_Correo_Castellano__c = 'plantilla es';
            regla1.CSBD_Plantilla_Correo_Catalan__c = 'plantilla ca';
            regla1.CSBD_Scoring_Riesgo__c = 'Denegado SIR';
            CSBD_Denegacion_Auto_Solicitud__c regla2 = new CSBD_Denegacion_Auto_Solicitud__c();
            regla2.CSBD_Record_Type_Oportunidad__c = 'CSBD_Prestamo';
            regla2.CSBD_Orden__c = 2;
            regla2.CSBD_Empresa_Proveedora__c = 'CaixaBank';
            regla2.CSBD_Circuito_Contratacion_Online__c = true;
            regla2.CSBD_Importe_Desde__c = 1000;
            regla2.CSBD_Importe_Hasta__c = 2000;
            regla2.CSBD_Escala_Maestra_Desde__c = 2;
            regla2.CSBD_Escala_Maestra_Hasta__c = 4;
            regla2.CSBD_Excluir_Clientes_Limite__c = false;
            regla2.CSBD_Denegada__c = true;
            regla2.CSBD_Resolucion__c = 'res1';
            regla2.CSBD_Enviar_Correo_Auto__c = true;
            regla2.CSBD_Plantilla_Correo_Castellano__c = 'plantilla es';
            regla2.CSBD_Plantilla_Correo_Catalan__c = 'plantilla ca';
            regla2.CSBD_Scoring_Riesgo__c = 'Denegado SIR';
            insert new List<CSBD_Denegacion_Auto_Solicitud__c>{regla1, regla2};

            User usuarioGestor = CSBD_Usuarios.usuarioGestor();
            System.runAs(usuarioGestor) {
                EmailTemplate plantillaCastellano = new EmailTemplate();
                plantillaCastellano.isActive = true;
                plantillaCastellano.Name = 'plantilla es';
                plantillaCastellano.DeveloperName = 'CSBD_Test_' + System.now().getTime();
                plantillaCastellano.TemplateType = 'text';
                plantillaCastellano.FolderId = usuarioGestor.Id;
                insert plantillaCastellano;
            }
        }
    }

    @isTest
    private static void test() {
        System.runAs(CSBD_Usuarios.usuarioAdministrador()) {
            Contact contacto = (Contact)CSBD_TestDataFactory.crearCuentaContacto('123123123K', new Map<String, Object>{'CSBD_Escala_Maestra__c' => 3}).get('contacto');

            List<Opportunity> oportunidades = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new List<Map<String, Object>>{
                new Map<String, Object>{
                    'CSBD_Empresa_Proveedora__c' => 'CaixaBank',
                    'CSBD_Importe_Producto_Principal__c' => 1500,
                    'CSBD_Circuito_Contratacion_Online__c' => true,
                    'Amount' => 1000, 'CSBD_Scoring_Riesgo__c' => 'Denegado SIR',
                    'AccountId' => contacto.AccountId, 'CSBD_Contact__c' => contacto.Id,
                    'CSBD_Email_Solicitud__c' => 'test@test.com'
                },
                new Map<String, Object>{
                    'CSBD_Empresa_Proveedora__c' => 'CaixaBank',
                    'CSBD_Circuito_Contratacion_Online__c' => true,
                    'Amount' => 3000, 'CSBD_Scoring_Riesgo__c' => 'Denegado SIR',
                    'AccountId' => contacto.AccountId, 'CSBD_Contact__c' => contacto.Id,
                    'CSBD_Email_Solicitud__c' => 'test@test.com'
                }
            });
            Test.startTest();
            CSBD_Denegacion_Automatica_Oportunidades.denegacionAutomaticaOportunidades(new List<Id>{oportunidades[0].Id, oportunidades[1].Id});
            Test.stopTest();

            oportunidades = [SELECT CSBD_Estado__c, StageName, CSBD_Resolucion__c FROM Opportunity
                                WHERE Id IN :(new List<Id>{oportunidades[0].Id, oportunidades[1].Id})];

            Opportunity oportunidad1 = oportunidades[0];
            Opportunity oportunidad2 = oportunidades[1];

            System.assertEquals('Cerrada', oportunidad1.CSBD_Estado__c, 'No se ha denegado la oportunidad');
            System.assertEquals('Perdida', oportunidad1.StageName, 'No se ha denegado la oportunidad');
            System.assertEquals('res1', oportunidad1.CSBD_Resolucion__c, 'La denegación automática no ha informado la resolución correcta');
            System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :oportunidad1.Id AND Type = 'Denegación automática' LIMIT 2], 'La denegación automática no ha creado tarea');

            System.assertEquals('Nueva', oportunidad2.CSBD_Estado__c, 'Se ha denegado una solicitud que no cumple las reglas');
            System.assertEquals('Solicitud', oportunidad2.StageName, 'Se ha denegado una solicitud que no cumple las reglas');
            System.assertEquals(null, oportunidad2.CSBD_Resolucion__c, 'Se ha denegado una solicitud que no cumple las reglas');
            System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhatId = :oportunidad2.Id AND Type = 'Denegación automática' LIMIT 1], 'Se ha denegado una solicitud que no cumple las reglas');
        }
    }
}