/*****************************************************************
* Name: SAC_GenialScheSendAzure_Test
* Copyright © 2024  CaixaBank
* 
* Proposito: Test de SAC_GenialScheSendAzure
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR                 DATE         Description
* 1.0            US727970         Alex Pérez             09/05/24     Creación     
*****************************************************************/
@isTest
public class SAC_GenialScheSendAzure_Test {
    
    @isTest
    static void envioProgramadoTest() {

        //usuario admin que se ejecutará en el fwk de schedulables
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];      

        Database.insert(usuarioAdmin);

        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Subject de prueba');
        camposRecl.put('Description', 'Descripcion de prueba');
        camposRecl.put('SAC_GenialEstado__c', 'SAC_005');
        camposRecl.put('Origin', 'Email');
        //para error en Class.SAC_Utils.comprobarEmailsBlackListAuto
        camposRecl.put('SuppliedEmail', 'test07032024931@test1.com.invalid');

        //crear caso
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        Database.insert(reclamacion);
        
        CBK_SCH_PendingProcess__c procesoPendiente = new CBK_SCH_PendingProcess__c(RecordId__c = reclamacion.Id);
        insert procesoPendiente;

        CBK_IntegrationSetting__c csGenialAzureAI = new CBK_IntegrationSetting__c();
        csGenialAzureAI.Name = 'SAC_GenialAzureAI';
        csGenialAzureAI.NamedCredential__c = 'callout:API_GWT_SAC/tech/geni06/notify-case';
        csGenialAzureAI.CBK_Method__c = 'POST';
        csGenialAzureAI.CBK_TimeOut__c = 120000;
        csGenialAzureAI.CBK_ContentType__c = 'application/json';
        
        Database.insert(csGenialAzureAI);
        
        //el cambio de fwk capando por fechas al antiguo, obliga a realizar esta operación
        dateTime fechaAnteriorfwkInt = dateTime.newInstance(2023, 4, 16);
        Test.setCreatedDate(csGenialAzureAI.Id, fechaAnteriorfwkInt);
        update csGenialAzureAI;
        
        // Llamar al método execute
        Test.startTest();
        SAC_GenialScheSendAzure schedulable = new SAC_GenialScheSendAzure();
        schedulable.lstInfoProcess = new list<CBK_SCH_PendingProcess__c>();
        schedulable.lstInfoProcess.add(procesoPendiente);
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(201, 'OK', '', new Map<String, String>()));
        system.runAs(usuarioAdmin){
            schedulable.execute(null);
        }
        Test.stopTest();
        
        case reclamaResult = [SELECT Id, SAC_GenialEstado__c FROM Case WHERE Id = : reclamacion.Id];

        system.assertEquals('SAC_001', reclamaResult.SAC_GenialEstado__c);
    }
}