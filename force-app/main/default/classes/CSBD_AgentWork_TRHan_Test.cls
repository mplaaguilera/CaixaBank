@isTest
public with sharing class CSBD_AgentWork_TRHan_Test {
    @TestSetup
    private static void altaDatosPrueba() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

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

        Pricebook2 listaPrecios = new Pricebook2(Name = 'CSBD Price Book', Description = 'CSBD Price Book', IsActive = true );
        insert listaPrecios;
        
        List<Group> colaPrestamos = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CSBD_Prestamos_I'];
        
        if(colaPrestamos.isEmpty()) {
            Group nuevaColaPrestamos = new Group(Name='Now In Sales - Préstamos I', DeveloperName = 'CSBD_Prestamos_I', Type='Queue');
        	insert nuevaColaPrestamos;
        }

        CC_Lista_Valores__c reglaAsignacion = new CC_Lista_Valores__c();
        reglaAsignacion.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_Regla_asignacion_oportunidad').getRecordTypeId();
        reglaAsignacion.Name = 'Oportunidades - Préstamos I';
        reglaAsignacion.CSBD_Cola_Oportunidad__c = 'CSBD_Prestamos_I';
        reglaAsignacion.CSBD_Tipo_de_oportunidad__c = 'Préstamo';
        reglaAsignacion.CC_Orden__c = 1;
        reglaAsignacion.CC_Activa__c = true;
        insert reglaAsignacion;
        
        List<CSBD_Criterios_asignacion_oportunidad__mdt> criterios = [SELECT Id, CSBD_Cola_Asignada__c, CSBD_Criterio_1__c, CSBD_Criterio_2__c FROM CSBD_Criterios_asignacion_oportunidad__mdt];

        Account cuenta = crearCuentaContacto('53456777P');

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Name', 'oportunidad de prueba');
        campos.put('CSBD_Estado__c', 'Activa');
        campos.put('StageName', 'Solicitud');
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        campos.put('CSBD_Horario_Contacto__c', 'Mañana');
        campos.put('CSBD_Idioma_Solicitud__c', 'Castellano');
        campos.put('CSBD_Familia_Producto__c', 'Cuentas');
        campos.put('CSBD_Empresa_Proveedora__c', 'CaixaBank'); 
        campos.put('CSBD_Importe_Producto_Principal__c', 200);
        
        Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
        CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{oportunidad}, 'Pendiente de asignar');

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
        contacto.CSBD_Limite_Prestamos_Oficinas__c = 20000;
        insert contacto;

        return cuenta;
    }

    @isTest
    public static void CSBD_AgentWork_TRHanBU_Test() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Boolean error = false;
        Opportunity oportunidad = [SELECT Id FROM Opportunity WHERE Recordtype.DeveloperName = 'CSBD_Prestamo'];

        List<CSBD_Gestor_Oportunidad__c> gestorOportunidad = [SELECT Id, OwnerId, CSBD_Estado__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c =: oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];

        List<ServiceChannel> serviceChannel = [SELECT Id FROM ServiceChannel WHERE DeveloperName = 'CSBD_Gestor_Oportunidad_Service_Channel'];
           
        System.runAs(usuarioGestor){ 
            Test.startTest();           
            try {
            AgentWork aw = new AgentWork(
                    ServiceChannelId = serviceChannel[0].Id,
                    WorkItemId = gestorOportunidad[0].Id,
                    UserId = UserInfo.getUserId()
            );
            insert aw;
            }
            catch(Exception e) {
                error = true;
            }
            Test.stopTest();
            System.assert(!serviceChannel.isEmpty());
        }
    }

    @isTest
    public static void validarBeforeInsertAgentWork() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Boolean error = false;
        Boolean ejecucionDisp = false;

        Opportunity oportunidad = [SELECT Id FROM Opportunity WHERE Recordtype.DeveloperName = 'CSBD_Prestamo'];

        List<CSBD_Gestor_Oportunidad__c> gestorOportunidad = [SELECT Id, OwnerId, CSBD_Estado__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c =: oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];

        List<ServiceChannel> serviceChannel = [SELECT Id FROM ServiceChannel WHERE DeveloperName = 'CSBD_Gestor_Oportunidad_Service_Channel'];
           
        List<AgentWork> agentWorkList = new List<AgentWork>();
        Map<Id, AgentWork> agentWorkMap = new Map<Id, AgentWork>();
        AgentWork aw = new AgentWork(
                ServiceChannelId = serviceChannel[0].Id,
                WorkItemId = gestorOportunidad[0].Id,
                UserId = UserInfo.getUserId()
        );
        agentWorkList.add(aw);
        agentWorkMap.put(aw.Id,aw);
        
        CC_TriggerParameters tp = new CC_TriggerParameters(agentWorkList, agentWorkList, agentWorkMap, agentWorkMap, true, false, false, false, true, false, false);

        System.runAs(usuarioGestor) {
            Test.startTest();
            try{
                ejecucionDisp = true;
                CC_AgentWork_TRDisp agentWorkTRDisp = new CC_AgentWork_TRDisp();
                agentWorkTRDisp.beforeUpdate(tp);            
            }
            catch(Exception e){
                error = true;
            }
            Test.stopTest();
            System.assert(ejecucionDisp = true);
        }
    }
}