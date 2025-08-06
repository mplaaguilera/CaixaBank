@isTest
public class CC_Grupo_Colaborador_Contact_Test {
	@TestSetup
    static void makeData(){
        
        Group grupo = new Group();
        grupo.Name = 'Test Group';
        grupo.DeveloperName = 'CC_Test_Group';
        grupo.Type = 'Regular'; 
        insert grupo;

        Group cola = new Group();
        cola.Name = 'Test Queue';
        cola.DeveloperName = 'CC_Test_Queue';
        cola.Type = 'Queue'; 
        insert cola;
        
    }
    
    @isTest
    public static void test(){
        Id centroRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id empleadoRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        
        Account cuentaCentroCaixaBank = new Account(
        	RecordTypeId = centroRecordTypeId,
            Name = 'Cuenta Centro CaixaBank Test 1',
            CC_Tipo_Centro__c = 'OF'
        );
        insert cuentaCentroCaixaBank;
        
        Contact contacto1 = new Contact(
            RecordTypeId = empleadoRecordTypeId,
            FirstName = 'Contacto OF',
            LastName = 'Test',
            AccountId = cuentaCentroCaixaBank.Id,
            CC_Idioma__c = 'es',
            Email = 'test@contact.com',
            AV_DescFuncion__c = 'DIRECTOR'
        );
        insert contacto1;
        
        Contact contacto2 = new Contact(
            RecordTypeId = empleadoRecordTypeId,
            FirstName = 'Contacto OF',
            LastName = 'Test',
            AccountId = cuentaCentroCaixaBank.Id,
            CC_Idioma__c = 'es',
            Email = 'test@contact.com',
            AV_DescFuncion__c = 'DIRECCION'
        );        
        insert contacto2;
        
        Test.startTest();
        List<Id> idsContactos = new List<Id>();
        idsContactos.add(contacto1.Id);
        idsContactos.add(contacto2.Id);
        CC_Grupo_Colaborador_Contact.tratarColaborador(idsContactos);
        Test.stopTest();
        
        List<CC_Grupo_Colaborador_Contact__c> colabs = [SELECT Id FROM CC_Grupo_Colaborador_Contact__c];
        System.assertNotEquals(0, colabs.size(), 'El tratamiento ha fallado.');
    }
}