@isTest
public class CSBD_BatchJob_Motor_Test {

    @TestSetup
    public static void crearDatosPrueba() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

        Opportunity oportunidad = new Opportunity();
        oportunidad.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_CMB').getRecordTypeId();
        oportunidad.Name = 'Oportunidad Test';
        oportunidad.StageName = 'Solicitud';
        oportunidad.CSBD_Estado__c = 'Cerrada';
        insert oportunidad;

        OpportunityShare oppshare = new OpportunityShare();
        oppshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1].Id;
        oppshare.OpportunityId = oportunidad.Id;
        oppshare.OpportunityAccessLevel = 'Edit';
        insert oppshare;


        
       List<CSBD_Gestor_Oportunidad__c> listaGestorOportunidad = new List<CSBD_Gestor_Oportunidad__c>();

        for (Integer i = 0; i < 100; i++) {
            CSBD_Gestor_Oportunidad__c gestorOportunidad = new CSBD_Gestor_Oportunidad__c();
            gestorOportunidad.Name = 'Gestor oportunidad ' + (i + 1); // Asignar un nombre único
            gestorOportunidad.CSBD_Oportunidad__c = oportunidad.Id;
            gestorOportunidad.CSBD_Estado__c = 'Fuera horario comercial';
            listaGestorOportunidad.add(gestorOportunidad);
        }
        insert listaGestorOportunidad;  
        
    
        
        CSBD_ParametrosBatch__c parametrosBatch = new CSBD_ParametrosBatch__c();
		parametrosBatch.CSBD_RegistrosPorLote__c = 10; 
		parametrosBatch.CSBD_TiempoIntervalos__c = 5;
		insert parametrosBatch;

    }

   

    @isTest
    public static void test() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        System.runAs ( usuarioGestor ) {
            Test.startTest();
            CSBD_BatchJob_Motor batchTest = new CSBD_BatchJob_Motor();
            Database.executeBatch(batchTest);
            Test.stopTest();

            List<CBK_SCH_PendingProcess__c> pP= [select id, Schedule_Time__c from CBK_SCH_PendingProcess__c where ClassName__c = 'CBK_SCH_CSBD_ScheduleBatchGestorOppty'];
            List<CSBD_Gestor_Oportunidad__c> gestorOportunidad = [SELECT Id, OwnerId, CSBD_Estado__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Estado__c =: 'Pendiente de asignar'];
            
            System.assertEquals(!pP.isEmpty(), true);
            System.assertEquals(!gestorOportunidad.isEmpty(), true);
        }
    }
    
   
}