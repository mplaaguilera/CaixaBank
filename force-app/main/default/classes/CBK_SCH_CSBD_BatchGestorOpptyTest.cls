@isTest
public class CBK_SCH_CSBD_BatchGestorOpptyTest {
    
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
           
       List<CBK_SCH_PendingProcess__c> pendingProcessInsertList = new List<CBK_SCH_PendingProcess__c>(); 
      
         for (Integer i = 0; i < listaGestorOportunidad.size(); i++) {
              
                CSBD_Gestor_Oportunidad__c oportunidadGestionada = listaGestorOportunidad[i];
                CBK_SCH_PendingProcess__c pendingProcess = new CBK_SCH_PendingProcess__c();
                pendingProcess.RecordId__c = oportunidadGestionada.Id;
                pendingProcess.Schedule_Time__c = System.now();
                pendingProcess.ClassName__c = 'CBK_SCH_CSBD_ScheduleBatchGestorOppty';
                pendingProcessInsertList.add(pendingProcess);
         }
         insert pendingProcessInsertList;   
           
         
        CSBD_ParametrosBatch__c parametrosBatch = new CSBD_ParametrosBatch__c();
		parametrosBatch.CSBD_RegistrosPorLote__c = 10; 
		parametrosBatch.CSBD_TiempoIntervalos__c = 5;
		insert parametrosBatch;

    }
    
    @isTest
    private static void CBK_SCH_CSBD_ScheduleBatchGestorOppty_Test() {
          User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        List<CBK_SCH_PendingProcess__c> pendingProcess= [select id, Schedule_Time__c,RecordId__c from CBK_SCH_PendingProcess__c where ClassName__c = 'CBK_SCH_CSBD_ScheduleBatchGestorOppty'];     
        
        System.runAs ( usuarioGestor ) {
        Test.startTest();
        CBK_SCH_CSBD_ScheduleBatchGestorOppty implClass = new CBK_SCH_CSBD_ScheduleBatchGestorOppty();
        implClass.lstInfoProcess = pendingProcess;
        System.enqueueJob(implClass);
        Test.stopTest();
        }
        List<CSBD_Gestor_Oportunidad__c> gestorOportunidad = [SELECT Id, OwnerId, CSBD_Estado__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Estado__c =: 'Fuera horario comercial'];

        System.assertEquals(!gestorOportunidad.isEmpty(), true);
    }


}