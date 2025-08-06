/*****************************************************************
* Name: SAC_GenialScheEnvioIntegracion_Test
* Copyright © 2024  CaixaBank
* 
* @description : clase test de SAC_GenialScheEnvioIntegracion
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR                 DATE         Description
* 1.0            US967489         Alex Pérez             07/08/24     creación
*****************************************************************/
@istest
public with sharing class SAC_GenialScheEnvioIntegracion_Test {
@TestSetup
static void makeData(){
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
    


}
    @isTest
    static void envioAzureTest() {

        //Username = 'useradmintest' + i + '@test.com.testSetup',
        user usuarioAdmin = [SELECT Id FROM User WHERE UserName = 'useradmintest0@test.com.testSetup'];
        case reclamacion = [SELECT Id FROM Case WHERE Subject = 'Subject de prueba'];
        //usuario admin que se ejecutará en el fwk de schedulables
       /*  User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];      

        Database.insert(usuarioAdmin);

         */

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
        
        //crear el proceso schedulado del fwk
        CBK_SCH_PendingProcess__c procesoPendiente = new CBK_SCH_PendingProcess__c(RecordId__c = reclamacion.Id, param1__c = 'Azure');
        insert procesoPendiente;
        // Llamar al método execute
        Test.startTest();
        SAC_GenialScheEnvioIntegracion schedulable = new SAC_GenialScheEnvioIntegracion();
        schedulable.lstInfoProcess = new list<CBK_SCH_PendingProcess__c>();
        schedulable.lstInfoProcess.add(procesoPendiente);
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(201, 'OK', '', new Map<String, String>()));
        system.runAs(usuarioAdmin){
            schedulable.execute(null);
        }
        Test.stopTest();
        
        case reclamaResult = [SELECT Id, SAC_GenialEstado__c FROM Case WHERE Id = : reclamacion.Id];

        system.assertEquals('SAC_001', reclamaResult.SAC_GenialEstado__c, 'El estado de IA debería ser "Enviado"');
    }

    @isTest
    static void envioOpenServicesTest() {

        //usuario admin que se ejecutará en el fwk de schedulables
        //Username = 'useradmintest' + i + '@test.com.testSetup',
        user usuarioAdmin = [SELECT Id FROM User WHERE UserName = 'useradmintest0@test.com.testSetup'];
        case reclamacion = [SELECT Id FROM Case WHERE Subject = 'Subject de prueba'];

        CBK_IntegrationSetting__c csGenialAzureAI = new CBK_IntegrationSetting__c();
        csGenialAzureAI.Name = 'SAC_GenialOSEnviarDoc';
        csGenialAzureAI.NamedCredential__c = 'callout:API_GWT_SAC/TESTOPENSERVICES';
        csGenialAzureAI.CBK_Method__c = 'POST';
        csGenialAzureAI.CBK_TimeOut__c = 120000;
        
        Database.insert(csGenialAzureAI);

         //crear el proceso schedulado del fwk
         CBK_SCH_PendingProcess__c procesoPendiente = new CBK_SCH_PendingProcess__c(RecordId__c = reclamacion.Id, param1__c = 'OpenServices');
         insert procesoPendiente;
        
        //el cambio de fwk capando por fechas al antiguo, obliga a realizar esta operación
  /*       dateTime fechaAnteriorfwkInt = dateTime.newInstance(2023, 4, 16);
        Test.setCreatedDate(csGenialAzureAI.Id, fechaAnteriorfwkInt);
        update csGenialAzureAI; */
        AsyncOptions options = new AsyncOptions();
        options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                                        .addId(reclamacion.Id)
                                        .addString('OPdoc')
                                        .build();
        
        // Llamar al método execute
        Test.startTest();
        SAC_GenialScheEnvioIntegracion schedulable = new SAC_GenialScheEnvioIntegracion();
        schedulable.lstInfoProcess = new list<CBK_SCH_PendingProcess__c>();
        schedulable.lstInfoProcess.add(procesoPendiente);
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', '', new Map<String, String>()));
        system.runAs(usuarioAdmin){
            //schedulable.execute(null);
            System.enqueueJob(schedulable, options);
        }
        Test.stopTest();

        system.assert(![select iD from AsyncApexJob].isEmpty(), 'No hay job asíncrono');
    }
}