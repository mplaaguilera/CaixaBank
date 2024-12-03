/**********************************************************************************************************************
Name:      CIBE_CXBTeamNewOppController_TestCIBE_CXBTeamNewOppController_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Class Test of CIBE_CXBTeamNewOpportunityController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION  USER_STORY				AUTHOR			DATE            Description
    1.0      Initial				Alicia     		09/02/2023      Init version
    1.1      US379981				Lucía     		04/05/2023      Add getAccountTeamMemberTest method


***********************************************************************************************************************/
@isTest
public class CIBE_CXBTeamNewOppController_Test {
    @TestSetup
	static void setup(){
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        User usrGes = CIBE_TestHelper.loginUser('CIBE_Gestor', null, 'U0009003',ps);
        Account accTest = new Account();
        List<Account> lstAcc = new List<Account>();

        User usuarioG = [SELECT Id, name FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' LIMIT 1];

        System.runAs(new User(Id = UserInfo.getUserId())) {
            User usuarioGe = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' LIMIT 1];
            ID recordTypeCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            List<Account> lstCen = new List <Account>();
                accTest.Name = '00615 STORE DOS DE MAIG-ROSSELLO';
                accTest.CC_Numero_Oficina_Empresa__c = '00615';
                accTest.CC_Numero_Oficina__c = '00615';
                accTest.RecordTypeId = recordTypeCentro;
                accTest.OwnerId = usuarioGe.Id;
            lstCen.add(accTest);
            Account center2 = new Account(
                Name = '00803 TEST CENTER',
                CC_Numero_Oficina_Empresa__c = '00803',
                CC_Numero_Oficina__c = '00803',
                RecordTypeId = recordTypeCentro,
                AV_CentroSuperior__c = accTest.Id,
                CIBE_SectoresPaises__c = 'Energy',
                ownerId = usuarioGe.Id
            );
            lstCen.add(center2);
            insert lstCen;
            system.debug('### lstCen '+lstCen);
            center2.AV_CentroSuperior__c = lstCen[0].Id;
            update center2;
            
            Account centroCaixa = CIBE_TestHelper.createCaixaCenter();

            ID rtCon = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.EMPLOYEE_RT).getRecordTypeId();
            Contact empleado = new Contact();
                empleado.RecordTypeId = rtCon;
                empleado.FirstName = 'Empleado 1';
                empleado.LastName = '1';
                empleado.CC_Idioma__c = 'es';
                empleado.CC_Matricula__c = usuarioGe.AV_ExternalId__c;
                empleado.CIBE_Sector__c = '001';
                empleado.CIBE_Cartera__c = '001';
                empleado.AccountId = lstCen[0].Id;
                empleado.AV_UsuarioAsociado__c = usuarioGe.Id;
                empleado.OwnerId = usrGes.Id;
            insert empleado;
            system.debug('### empleado '+empleado);

            ///

            User user1 = CIBE_TestHelper.createUser('Standard User');

            Contact empleado2 = new Contact();
                empleado2.RecordTypeId = rtCon;
                empleado2.FirstName = 'Empleado 2';
                empleado2.LastName = '2';
                empleado2.CC_Idioma__c = 'es';
                empleado2.CIBE_Sector__c = '002';
                empleado2.CIBE_Cartera__c = '002';
                empleado2.AccountId = lstCen[0].Id;
                empleado2.AV_UsuarioAsociado__c = user1.Id;
                empleado2.OwnerId = usrGes.Id;
            insert empleado2;

            Account accCliente = CIBE_TestHelper.createCustomer();
            accCliente.ownerId = usrGes.Id;
            accCliente.AV_EAPGestor__c = empleado.Id;
            update accCliente;

            AccountTeamMember accTM = new AccountTeamMember();
                accTM.AccountId = accCliente.Id;
                accTM.UserId = user1.Id;
            insert accTM;
        }
    }
        
    @isTest
    public static void searchTest(){
        
        User usuarioGe = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' LIMIT 1];
        Contact contactEAP = [SELECT Id FROM Contact WHERE CC_Matricula__c = 'U0009003' LIMIT 1];

        System.runAs(usuarioGe){     
            Test.startTest();
            List<Task> taskId = [SELECT id From Task LIMIT 10];
            List<String> selectedIds = new List<String>();     
            String searchTerm= 'CIBE_';    
            for(Task auxId : taskId){
                selectedIds.add(auxId.id);
            }       
            List<AV_LookupSearchResult> results = CIBE_CXBTeamNewOpportunityController.search(searchTerm, contactEAP.Id);
            Test.stopTest();
            System.assertNotEquals(null, results);
        }
    }

    @isTest
    public static void getMembersTest(){
                
        User usuarioGe = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' LIMIT 1]; 
                
        System.runAs(usuarioGe) {

            List<Contact> contactIds = [SELECT id From Contact LIMIT 10];
            List<String> selectedIds = new List<String>();
                for(Contact auxId : contactIds){
                    selectedIds.add(auxId.id);
                }         

            CIBE_CXBTeamNewOpportunityController.getMembers(selectedIds);
            
            System.assertNotEquals(null, selectedIds);
        }
    }

    @isTest
    public static void getAccountTeamMemberTest(){

        User usuarioGe = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' LIMIT 1];
        Test.StartTest();
        System.runAs(usuarioGe){

            Map<Id, Contact> mapContact = new Map<Id, Contact>();
           
            Account acc = [SELECT Id, AV_EAPGestor__c FROM Account WHERE Name = 'Name' AND AV_NumPerso__c = '123' AND AV_Negocio__c = 'CIB' LIMIT 1];
            System.debug('acc --> ' +  acc);
            AccountTeamMember acTM = [SELECT Id, UserId FROM AccountTeamMember LIMIT 1]; 
            mapContact = new Map<Id, Contact>([SELECT Id, Name, AV_UsuarioAsociado__c, CC_Numero_Oficina__c, AV_DescFuncion__c, AV_Responsabilidad__c FROM Contact WHERE FirstName = 'Empleado 2' LIMIT 1]);

            CIBE_CXBTeamNewOpportunityController.getAccountTeamMember(acc.Id, acc.AV_EAPGestor__c);

            System.assertEquals(1, mapContact.size());
        }
        Test.stopTest();

    }
}