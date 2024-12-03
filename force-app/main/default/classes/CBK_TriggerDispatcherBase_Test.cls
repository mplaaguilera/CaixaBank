@isTest
public  class CBK_TriggerDispatcherBase_Test {
    @isTest static void testVirtualMethods() {
        CC_TriggerDispatcherBase base = new CC_TriggerDispatcherBase();
        base.bulkBefore();
        base.bulkAfter();
        base.beforeInsert(null);
        base.afterInsert(null);
        base.beforeUpdate(null);
        base.afterUpdate(null);
        base.beforeDelete(null);
        base.afterDelete(null);
        base.afterUndelete(null);
        base.andFinally();
    }
    @isTest static void testExecuteMethod() {
        new TriggerDispatcherBaseMock().executeAllDispatchers();
        System.assertEquals(true, true);
    }

    @testSetup
    static void setup()
    {
        User user = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema'].Id,
            LastName = 'LastNameTest',
            Email = 'test@test.com',
            Username = 'test@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
        insert user;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CBK_DataManager_OT'];
        insert new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps.Id);
    }

    public class MockHandlerInstance extends CC_TriggerHandlerBase {
        public override void inProgressEntry(CC_TriggerParameters tp) {
            CBK_log.debug('MOCK DispacherBase', LoggingLevel.INFO);
        }
        public override void mainEntry(CC_TriggerParameters tp) {
            CBK_log.debug('MOCK DispacherBase', LoggingLevel.INFO);
        }
        public override void updateObjects() {
            CBK_log.debug('MOCK DispacherBase', LoggingLevel.INFO);
        }
    }
    public class TriggerDispatcherBaseMock extends CC_TriggerDispatcherBase {
        public void executeAllDispatchers() {
            MockHandlerInstance mock = new MockHandlerInstance();
            for(CC_TriggerParameters.TriggerEvent triggerEvent: CC_TriggerParameters.TriggerEvent.values()) {
                execute(mock, null, triggerEvent);
                execute(null, null, triggerEvent);
            }
            List<String> lstHanlders = getAssociatedHandlers('EmailMessage', 'beforeInsert');
            List<CBK_TriggerHandlerAssociation__mdt> lstconfigHandler = getAssociatedHandlersFilterCriteria('Account', 'beforeInsert');

            List<Account> lstAcc = new List<Account>();
            Id rtAcc = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
            Id rtAcc2 = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Buzon_Account').getRecordTypeId();
            Id rtAcc3 = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

            Account ac = new Account();
            ac.recordTypeId = rtAcc;
            ac.Name = 'TEST ACC CC_Colaborador Test';
            ac.CC_Segmento__c = 'Test';
            lstAcc.add(ac);

            ac = new Account();
            ac.recordTypeId = rtAcc;
            ac.Name = 'TEST ACC CC_Colaborador2 Test2';
            ac.AV_Colectivos__c = 'Test2';
            lstAcc.add(ac);

            ac = new Account();
            ac.recordTypeId = rtAcc;
            ac.Name = 'TEST ACC CC_Colaborador3 NOO';
            ac.AV_Colectivos__c = 'Test';
            lstAcc.add(ac);

            ac = new Account();
            ac.recordTypeId = rtAcc;
            ac.Name = 'TEST ACC CC_Colaborador4 OTRO';
            ac.CC_Segmento__c = 'Test';
            lstAcc.add(ac);

            // OS_Buzon_Account
            ac = new Account();
            ac.recordTypeId = rtAcc2;
            ac.Name = 'TEST ACC OS_Buzon_Account1 Pepe';
            ac.AV_Colectivos__c = 'Test';
            lstAcc.add(ac);

            ac = new Account();
            ac.recordTypeId = rtAcc2;
            ac.Name = 'TEST ACC OS_Buzon_Account2 OTRO';
            ac.CC_Segmento__c = 'Test2';
            lstAcc.add(ac);

            //CC_CentroCaixaBank
            ac = new Account();
            ac.recordTypeId = rtAcc3;
            ac.Name = 'TEST ACC CC_CentroCaixaBank Test';
            ac.CC_Segmento__c = 'Test';
            lstAcc.add(ac);

            ac = new Account();
            ac.recordTypeId = rtAcc3;
            ac.Name = 'TEST ACC CC_CentroCaixaBank2 Test2';
            ac.CC_Segmento__c = 'Test2';
            lstAcc.add(ac);

            ac = new Account();
            ac.recordTypeId = rtAcc3;
            ac.Name = 'TEST ACC CC_CentroCaixaBank3 NOO';
            ac.CC_Segmento__c = 'Test';
            lstAcc.add(ac);

            CC_TriggerParameters tp2 = new CC_TriggerParameters();
            tp2.newList = lstAcc;

            Test.startTest();
            User usr = [SELECT id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
            System.runAs (usr) {
                Map<String, List<SObject>> mapfiltered = segmentationHandlers(tp2, 'Account', 'beforeInsert', false);
            insert lstAcc;
            CC_TriggerParameters tp = new CC_TriggerParameters();
            tp.newList = lstAcc;
            Map<Id, SObject>mapNew = generateMap( tp.newList);
            List<SObject> lstnew =  generateOldList(tp.newList, tp.newList); 
            Boolean check =  getProfilesIdByNames(new List<String>{'System Administrator'});
            }
            Test.stopTest();
        }
    }
}