@isTest
public class CSBD_AgentWork_TRHan_Test {

    @TestSetup
    private static void altaDatosPrueba() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
            listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
            listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
            insert listaValores;

            CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
            valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            valor.CC_Lista__c = listaValores.Id;
            valor.Name = 'Consumo';
            valor.CC_Valor__c = '1';
            insert valor;

            insert new Pricebook2(Name = 'CSBD Price Book', Description = 'CSBD Price Book', IsActive = true );

            if ([SELECT COUNT() FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CSBD_Prestamos_I'] == 0) {
                insert new Group(Name = 'Now In Sales - Préstamos I', DeveloperName = 'CSBD_Prestamos_I', Type = 'Queue');
            }

            CC_Lista_Valores__c reglaAsignacion = new CC_Lista_Valores__c();
            reglaAsignacion.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_Regla_asignacion_oportunidad').getRecordTypeId();
            reglaAsignacion.Name = 'Oportunidades - Consumos I';
            reglaAsignacion.CSBD_Cola_Oportunidad__c = 'CSBD_Prestamos_I';
            reglaAsignacion.CSBD_Tipo_de_oportunidad__c = 'Consumo';
            reglaAsignacion.CC_Orden__c = 1;
            insert reglaAsignacion;
        }
    }

    @isTest
    public static void biTestKo() {
        User admin = CSBD_TestDataFactory.usuarioAdministrador();
        System.runAs(admin) {
            Contact contacto = (Contact)CSBD_TestDataFactory.crearCuentaContacto('53456777P').get('contacto');

            System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
                Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
                    'Name' => 'oportunidad de prueba', 'CSBD_Estado__c' => 'Activa',
                    'AccountId' => contacto.AccountId, 'CSBD_Contact__c' => contacto.Id,
                    'CSBD_Horario_Contacto__c' => 'Mañana', 'CSBD_Idioma_Solicitud__c' => 'Castellano',
                    'CSBD_Familia_Producto__c' => 'Cuentas', 'CSBD_Empresa_Proveedora__c' => 'CaixaBank',
                    'CSBD_Importe_Producto_Principal__c' => 200
                });
                CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{prestamo}, 'Pendiente de asignar');

                Test.startTest();
                String errorInsert;
                try {
                    AgentWork agentWork = new AgentWork();
                    agentWork.ServiceChannelId = [SELECT Id FROM ServiceChannel WHERE DeveloperName = 'CSBD_Gestor_Oportunidad_Service_Channel'].Id;
                    agentWork.WorkItemId = [SELECT Id FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c = :prestamo.Id ORDER BY CreatedDate DESC LIMIT 1].Id;
                    agentWork.UserId = admin.Id;
                    insert agentWork;
                } catch (Exception e) {
                    errorInsert = e.getMessage();
                }


                Test.stopTest();

                System.assert(errorInsert.contains('El estado del agente no está asociado con el canal para este trabajo.'), 'Se debería haber producido un error');
            }
        }
    }

    @isTest
    public static void validarBeforeInsertAgentWork() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Contact contacto = (Contact)CSBD_TestDataFactory.crearCuentaContacto('53456777P').get('contacto');

            User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
            System.runAs(usuarioGestor) {
                Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
                    'Name' => 'oportunidad de prueba', 'CSBD_Estado__c' => 'Activa',
                    'AccountId' => contacto.AccountId, 'CSBD_Contact__c' => contacto.Id,
                    'CSBD_Horario_Contacto__c' => 'Mañana', 'CSBD_Idioma_Solicitud__c' => 'Castellano',
                    'CSBD_Familia_Producto__c' => 'Cuentas', 'CSBD_Empresa_Proveedora__c' => 'CaixaBank',
                    'CSBD_Importe_Producto_Principal__c' => 200
                });
                CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{prestamo}, 'Pendiente de asignar');

                Test.startTest();
                Boolean error = false;
                try {
                    AgentWork agentWork = new AgentWork();
                    agentWork.ServiceChannelId = [SELECT Id FROM ServiceChannel WHERE DeveloperName = 'CSBD_Gestor_Oportunidad_Service_Channel'].Id;
                    agentWork.WorkItemId = [SELECT Id FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c = :prestamo.Id ORDER BY CreatedDate DESC LIMIT 1].Id;
                    agentWork.UserId = usuarioGestor.Id;

                    List<AgentWork> agentWorks = new List<AgentWork>{agentWork};
                    Map<Id, AgentWork> agentWorksMap = new Map<Id, AgentWork>{agentWork.Id => agentWork};

                    new CC_AgentWork_TRDisp().beforeUpdate(new CC_TriggerParameters(
                        agentWorks, agentWorks,
                        agentWorksMap, agentWorksMap,
                        true, false, false, false, true, false, false
                    ));
                } catch (Exception e) {
                    error = true;
                }
                Test.stopTest();

                System.assertEquals(false, error, 'No se ha producido ningún error');
            }
        }
    }
}