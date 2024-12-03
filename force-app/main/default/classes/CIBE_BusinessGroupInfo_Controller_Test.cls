@isTest
public with sharing class CIBE_BusinessGroupInfo_Controller_Test {
  @TestSetup
  static void setup() {
    CIBE_TestInitialSetup.setupInitialDataEMP();
    // List<String> psA = new List<String>{ CIBE_AppConstants.CIBE_OPERATIVACIB, CIBE_AppConstants.CIBE_CUSTOMMETADATA, CIBE_AppConstants.CIBE_OPERATIVAEMP };

    // CIBE_TestInitialSetup.setupInitialData(null, CIBE_AppConstants.CIBE_ROLEMP, null, null, null, psA);
    User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
    User usrGes = [SELECT Id, Name FROM User WHERE AV_ExternalID__c = 'U0000001'];

    System.runAs(usrSetup) {
      User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];
      RecordType rtAccGC = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_G_COMERCIAL_RT);
      Id rtRole = Schema.SObjectType.FinServ__ReciprocalRole__c.getRecordTypeInfosByDeveloperName().get('AccountRole').getRecordTypeId();
      Id rtAccR = Schema.SObjectType.FinServ__AccountAccountRelation__c.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();
      Account acc = CIBE_TestHelper.createCustomer(u);

      Product2 prodPF = CIBE_TestHelper.createProduct(null, null);
      RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
      Opportunity opp = new Opportunity();
      opp.RecordTypeId = rt.Id;
      opp.AccountId = acc.Id;
      opp.Name = 'Alerta Comercial';
      opp.StageName = 'En curso';
      opp.CloseDate = System.today() + 5;
      opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
      opp.AV_PF__c = prodPF.Id;
      opp.ownerId = u.Id;
      insert opp;

      Account accGC = new Account(Name = 'Grupo Comercial Test', RecordTypeId = rtAccGC.Id, AV_InterlocName__c = 'Grupo Comercial Test', OwnerId = u.Id);
      insert accGC;

      FinServ__ReciprocalRole__c role = new FinServ__ReciprocalRole__c(Name = 'Parent', RecordTypeId = rtRole, FinServ__InverseRole__c = 'Child');

      insert role;

      FinServ__AccountAccountRelation__c relation = new FinServ__AccountAccountRelation__c(FinServ__Account__c = accGC.Id, FinServ__RelatedAccount__c = opp.AccountId, FinServ__Role__c = role.Id, OwnerId = u.Id, RecordTypeId = rtAccR);
      insert relation;

      DateTime activityDate = Datetime.newInstance(2022, 9, 9);
      Event event = CIBE_TestHelper.createEvent(u, activityDate, acc);
      CIBE_TestHelper.createTareaOportunidad(opp, event.AV_Task__c);
    }
  }

  @isTest
  public static void getDataTest() {
    User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

    System.runAs(u) {
      Map<Id, Account> clients = new Map<Id, Account>([SELECT Id FROM Account WHERE Recordtype.DeveloperName = 'CC_Cliente']);
      List<Account> clientList = new List<Account>(clients.values());

      Test.startTest();
      CIBE_BusinessGroupInfo_Controller.BusinessGroupInfo result = CIBE_BusinessGroupInfo_Controller.getParentAccountOfCommercialGroup(clientList[0].Id);

      System.assert(result.businessGroupName != null);
      Test.stopTest();
    }
  }
}