@isTest
public class CSBD_Activity_Test {

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
        
        Pricebook2 listaPrecios = new Pricebook2();
        listaPrecios.Name = 'Standard Price Book';
        insert listaPrecios;

        Pricebook2 listaPreciosCsbd = new Pricebook2();
        listaPreciosCsbd.Name = 'CSBD Price Book';
        listaPreciosCsbd.Description = 'CSBD Price Book';
        listaPreciosCsbd.IsActive = true;
        insert listaPreciosCsbd;
    }

    @isTest
    public static void crearActividad() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo');
            
        OpportunityShare oppshare = new OpportunityShare();
        oppshare.UserOrGroupId = usuarioGestor.Id;
        oppshare.OpportunityId = oportunidad.Id;
        oppshare.OpportunityAccessLevel = 'Edit';
        insert oppshare;

        System.runAs (usuarioGestor) {
            oportunidad.OwnerId = usuarioGestor.Id;
            update oportunidad;
            //Ejecución de la prueba
            Test.startTest();
            Task actividad = CSBD_Activity.crearActividad(oportunidad.Id, 'Reactivación', 'Completed', 'asunto', 'cuerpo');
            Test.stopTest();

            //Evaluación del resultado de la prueba
            System.assertEquals('Reactivación', actividad.Type);
            System.assertEquals(oportunidad.Id, actividad.WhatId);
            System.assertEquals('asunto', actividad.Subject);
            System.assertEquals('cuerpo', actividad.Description);
            System.assertEquals('Completed', actividad.Status);
            System.assert(actividad.ActivityDate != null);
        }
    }

    @isTest
    public static void crearActividadReasignacion() {
        Opportunity oportunidad1 = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo');
        Opportunity oportunidad2 = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo');

        Set<Id> idOportunidades = new Set<Id>{oportunidad1.Id, oportunidad2.Id};

        System.runAs (CSBD_Usuarios.usuarioAdministrador()) {
            //Ejecución de la prueba
            Test.startTest();
            CSBD_Activity.crearActividadReasignacion(idOportunidades, 'Reasignación automática', '');
            Test.stopTest();

            //Evaluación del resultado de la prueba
            Integer actividadesCreadas = [SELECT Count() FROM Task WHERE WhatId IN :idOportunidades AND Status = 'Completed'];
            System.assertEquals(2, actividadesCreadas, 'Deberían haberse creado 2 actividades');
        }
    }

    @isTest
    private static void cerrarActividadPendienteCliente() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo');
        Task actividad = CSBD_Activity.crearActividad(prestamo.Id, 'Pendiente Cliente', 'Open', 'asunto', 'cuerpo');

        OpportunityShare oppshare = new OpportunityShare();
        oppshare.UserOrGroupId = usuarioGestor.Id;
        oppshare.OpportunityId = prestamo.Id;
        oppshare.OpportunityAccessLevel = 'Edit';
        insert oppshare;

        System.runAs (usuarioGestor) {
            prestamo.OwnerId = usuarioGestor.Id;
            update prestamo;
            Test.startTest();
            CSBD_Activity.cerrarActividadPendienteCliente(prestamo.Id);
            Test.stopTest();

            List<Task> tareasPendienteCliente = [SELECT Id FROM Task WHERE WhatId = :prestamo.Id AND Status = 'Completed'];

            System.assert(!tareasPendienteCliente.isEmpty());
        }
    }

    @isTest
    public static void crearActividadReturn() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Opportunity oportunidad1 = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo');
        oportunidad1.OwnerId = usuarioGestor.Id;
        update oportunidad1;

        System.runAs (usuarioGestor) {
            //Ejecución de la prueba
            Test.startTest();
            Task actividad = CSBD_Activity.crearActividad(oportunidad1.Id, 'Reactivación', 'Completed', 'asunto', 'cuerpo');
            Task actividadActualizada = CSBD_Activity.crearActividadReturn(actividad, oportunidad1.Id, 'Consulta', 'Completed', 'asunto nuevo', 'cuerpo nuevo', null);
            Test.stopTest();

            //Evaluación del resultado de la prueba
            System.assertEquals('asunto nuevo', actividadActualizada.Subject);
            System.assertEquals('cuerpo nuevo', actividadActualizada.Description);
            System.assertEquals('Consulta', actividadActualizada.Type);
        }
    }
}