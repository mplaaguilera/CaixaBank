@isTest
public class CBK_InboundEmailUtils_Test {

    @isTest
    public static void getPriorityHeaderLimitsPriority(){

        
        List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {

        List<Messaging.InboundEmail.Header> header = new List<Messaging.InboundEmail.Header>();
        Messaging.InboundEmail.Header headerElement = new Messaging.InboundEmail.Header();
        
        headerElement.name = 'To';
        headerElement.value = 'testPara@test.com';
        header.add(headerElement);

        headerElement = new Messaging.InboundEmail.Header();
        headerElement.name = 'From';
        headerElement.value = 'testDe@test.com';
        header.add(headerElement);

        headerElement = new Messaging.InboundEmail.Header();
        headerElement.name = 'Subject';
        headerElement.value = 'AsuntoTest';
        header.add(headerElement);

        headerElement = new Messaging.InboundEmail.Header();
        headerElement.name = 'Test';
        headerElement.value = 'Tue, 02 Apr 2024 11:12:36 +0000';
        header.add(headerElement);

        Test.startTest();
        CBK_InboundEmailUtils.PriorityHeaderPetition petition = new CBK_InboundEmailUtils.PriorityHeaderPetition();
        petition.app = 'Test';
        petition.header = header;
        petition.limitCharacters = 100;
        Test.stopTest();

        CBK_InboundEmailUtils.PriorityHeaderResult result = CBK_InboundEmailUtils.getPriorityHeader(petition);
        System.assertEquals(2, result.priorityHeaders.size(), 'El header de prioridades debe devolver solo 2 elementos');
        System.assertEquals(2, result.secondPriorityHeaders.size(), 'El header sin prioridad debe devolver solo 2 elementos');
        System.assertEquals('AsuntoTest', result.secondPriorityHeaders[0].value, 'El asunto no cabe en el header de prioridad y debe ser el primer elemento del header sin prioridad');    
        }
    }
    
    @isTest
    public static void getPriorityHeaderLimitsNoPriority(){

        List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {

        List<Messaging.InboundEmail.Header> header = new List<Messaging.InboundEmail.Header>();
        Messaging.InboundEmail.Header headerElement = new Messaging.InboundEmail.Header();
        
        headerElement.name = 'To';
        headerElement.value = 'testPara@test.com';
        header.add(headerElement);

        headerElement = new Messaging.InboundEmail.Header();
        headerElement.name = 'From';
        headerElement.value = 'testDe@test.com';
        header.add(headerElement);

        headerElement = new Messaging.InboundEmail.Header();
        headerElement.name = 'Test';
        headerElement.value = 'Tue, 02 Apr 2024 11:12:36 +0000';
        header.add(headerElement);

        Test.startTest();
        CBK_InboundEmailUtils.PriorityHeaderPetition petition = new CBK_InboundEmailUtils.PriorityHeaderPetition();
        petition.app = 'Test';
        petition.header = header;
        petition.limitCharacters = 100;
        Test.stopTest();

        CBK_InboundEmailUtils.PriorityHeaderResult result = CBK_InboundEmailUtils.getPriorityHeader(petition);
        System.assertEquals(2, result.priorityHeaders.size(), 'El header de prioridades debe devolver solo 2 elementos');
        System.assertEquals(1, result.secondPriorityHeaders.size(), 'El header sin prioridad debe devolver solo 1 elemento');
        }
    }

    @isTest
    public static void getPriorityHeaderNoLimits(){

        List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {

        List<Messaging.InboundEmail.Header> header = new List<Messaging.InboundEmail.Header>();
        Messaging.InboundEmail.Header headerElement = new Messaging.InboundEmail.Header();
        
        headerElement = new Messaging.InboundEmail.Header();
        headerElement.name = 'To';
        headerElement.value = 'testPara@test.com';
        header.add(headerElement);

        headerElement = new Messaging.InboundEmail.Header();
        headerElement.name = 'From';
        headerElement.value = 'testDe@test.com';
        header.add(headerElement);

        headerElement = new Messaging.InboundEmail.Header();
        headerElement.name = 'Subject';
        headerElement.value = 'AsuntoTest';
        header.add(headerElement);

        headerElement = new Messaging.InboundEmail.Header();
        headerElement.name = 'Test';
        headerElement.value = 'Tue, 02 Apr 2024 11:12:36 +0000';
        header.add(headerElement);

        Test.startTest();
        CBK_InboundEmailUtils.PriorityHeaderPetition petition = new CBK_InboundEmailUtils.PriorityHeaderPetition();
        petition.app = 'Test';
        petition.header = header;
        petition.limitCharacters = 31999;
        Test.stopTest();

        CBK_InboundEmailUtils.PriorityHeaderResult result = CBK_InboundEmailUtils.getPriorityHeader(petition);
        System.assertEquals(4, result.priorityHeaders.size(), 'El header de prioridades debe contener todos los elementos del header');
        System.assertEquals(null, result.secondPriorityHeaders, 'El header sin prioridad debe estar vacío');
        }
    }

    @isTest
    public static void getPriorityHeaderLimitsRestPriority(){

        List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {

        List<Messaging.InboundEmail.Header> header = new List<Messaging.InboundEmail.Header>();
        Messaging.InboundEmail.Header headerElement = new Messaging.InboundEmail.Header();
        
        headerElement.name = 'To';
        headerElement.value = 'testPara@test.com';
        header.add(headerElement);

        headerElement = new Messaging.InboundEmail.Header();
        headerElement.name = 'From';
        headerElement.value = 'testDe@test.com';
        header.add(headerElement);

        headerElement = new Messaging.InboundEmail.Header();
        headerElement.name = 'Subject';
        headerElement.value = 'AsuntoTest';
        header.add(headerElement);

        headerElement = new Messaging.InboundEmail.Header();
        headerElement.name = 'Test';
        headerElement.value = 'Tue, 02 Apr 2024 11:12:36 +0000';
        header.add(headerElement);

        headerElement = new Messaging.InboundEmail.Header();
        headerElement.name = 'Test2';
        headerElement.value = 'Tue, 02 Apr 2024 11:12:36';
        header.add(headerElement);

        Test.startTest();
        CBK_InboundEmailUtils.PriorityHeaderPetition petition = new CBK_InboundEmailUtils.PriorityHeaderPetition();
        petition.app = 'Test';
        petition.header = header;
        petition.limitCharacters = 50;
        Test.stopTest();

        CBK_InboundEmailUtils.PriorityHeaderResult result = CBK_InboundEmailUtils.getPriorityHeader(petition);
        System.assertEquals(1, result.priorityHeaders.size(), 'El header de prioridades debe tener sólo 1 elemento');
        System.assertEquals(1, result.secondPriorityHeaders.size(), 'El header sin prioridad debe tener sólo un elemento');
        }
    }

    @isTest
    public static void getPriorityHeaderLimitsRest(){

        List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {

        List<Messaging.InboundEmail.Header> header = new List<Messaging.InboundEmail.Header>();
        Messaging.InboundEmail.Header headerElement = new Messaging.InboundEmail.Header();
        
        headerElement.name = 'To';
        headerElement.value = 'testPara@test.com';
        header.add(headerElement);

        headerElement = new Messaging.InboundEmail.Header();
        headerElement.name = 'Test';
        headerElement.value = 'Tue, 02 Apr 2024';
        header.add(headerElement);

        headerElement = new Messaging.InboundEmail.Header();
        headerElement.name = 'Test2';
        headerElement.value = 'Tue, 02 Apr 2024 11:12:36 +0000';
        header.add(headerElement);

        Test.startTest();
        CBK_InboundEmailUtils.PriorityHeaderPetition petition = new CBK_InboundEmailUtils.PriorityHeaderPetition();
        petition.app = 'Test';
        petition.header = header;
        petition.limitCharacters = 50;
        Test.stopTest();

        CBK_InboundEmailUtils.PriorityHeaderResult result = CBK_InboundEmailUtils.getPriorityHeader(petition);
        System.assertEquals(1, result.priorityHeaders.size(), 'El header de prioridades debe tener sólo 1 elemento');
        System.assertEquals(1, result.secondPriorityHeaders.size(), 'El header sin prioridad debe tener sólo un elemento');
        }
    }

}