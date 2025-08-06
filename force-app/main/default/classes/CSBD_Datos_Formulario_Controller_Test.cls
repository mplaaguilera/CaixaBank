@isTest
public class CSBD_Datos_Formulario_Controller_Test {

    @TestSetup
    private static void altaDatosPrueba() {
        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
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

        CSBD_TestDataFactory.crearCuentaContacto('46979396X', new Map<String, Object>{
            'CC_NumPerso__c' => '21444982',
            'FirstName' => 'Nombre',
            'LastName' => 'Apellido',
            'Email' => 'test@test.com',
            'Phone' => '666666666'
        });
    }

    @isTest
    public static void getSolicitud() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

            Contact contacto = [SELECT AccountId, Account.CC_Numero_Documento__c FROM Contact WHERE Account.CC_Numero_Documento__c = '46979396X'];
            Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
                'OwnerId' => usuarioGestor.Id
            });

            String jsonPrestamo = [SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_Prestamo_JSON' LIMIT 1].Body.toString();
            Task actividad = CSBD_Activity.crearActividad(prestamo.Id, 'Solicitud recibida', 'Completed', 'Solicitud recibida', jsonPrestamo);
            actividad.OwnerId = usuarioGestor.Id;
            update actividad;

            System.runAs(usuarioGestor) {
                Test.startTest();
                CSBD_Datos_Formulario_Controller.Retorno respuesta = CSBD_Datos_Formulario_Controller.getSolicitud(prestamo.Id);
                Test.stopTest();

                System.assertNotEquals(null, respuesta.datosFormulario, 'No se ha devuelto el formulario');
            }
        }
    }
}