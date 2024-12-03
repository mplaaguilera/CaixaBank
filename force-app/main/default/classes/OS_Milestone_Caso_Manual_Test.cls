@isTest
public class OS_Milestone_Caso_Manual_Test {

    @TestSetup
    static void makeData(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();
    }

    @isTest
    public static void informarMilestoneCasoManual() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = a.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        Entitlement e = new Entitlement();
        e.Name = 'Entitlement COPS';
        e.Type = 'Phone Support';
        e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'Entitlement Process COPS' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'cops'].Id;
        e.StartDate = Date.today();
        e.EndDate = Date.today();
        insert e;
                
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón International Operations';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Milestone_Caso_Manual.informarMilestoneCasoManual(new List<Id>{caso.Id});
            Test.stopTest();
            
            caso = [SELECT EntitlementId FROM Case WHERE Id = :caso.Id LIMIT 1 ];
            
            System.assertNotEquals(null, caso.entitlementId);
        }
    }
}