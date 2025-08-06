@isTest
public class SEG_Case_EmailBuscador_Controller_Test2 {


    @IsTest
    static void alternativasTestTrue(){

        Account centro1 = new Account();
        centro1.Name = 'centro1';
        centro1.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		insert centro1;

        Account cuenta = new account();
        cuenta.Name = 'testeoclap';
        cuenta.SEG_Prioridad_Carterizacion_Segmentos__c = true;
        cuenta.SEG_Oficina_Gestora_Segmentos__c = centro1.id;
        insert cuenta;

        Case caso = new Case();
        caso.Subject = 'oepa';
        caso.AccountId = cuenta.id;
        insert caso;
        
        Contact contacto = new Contact();
        contacto.AccountId = cuenta.id; 
        contacto.FirstName = 'Primero'; 
        contacto.LastName = 'Contactos';
        insert contacto;  

        cuenta.SEG_GestorOperativaInternacional__c = contacto.id;
        update cuenta;
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        Map<String, Object> mapaGetIdentidadBoton = SEG_Case_EmailBuscador_Controller.getIdentidadBoton(caso.id);
        Test.stopTest();

        System.assertNotEquals(null , mapaGetIdentidadBoton,'No se ha recibido la identidad boton caso.id');
        }
    }

    @IsTest
    static void alternativasTestTrue2(){

        Account centro1 = new Account();
        centro1.Name = 'centro1';
        centro1.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		insert centro1;

        Account cuenta = new account();
        cuenta.Name = 'testeoclap';
        cuenta.SEG_Prioridad_Carterizacion_Segmentos__c = true;
        cuenta.SEG_Oficina_Gestora_Segmentos__c = centro1.id;
        insert cuenta;

        Case caso = new Case();
        caso.Subject = 'oepa';
        caso.AccountId = cuenta.id;
        insert caso;
        
        Contact contacto = new Contact();
        contacto.AccountId = cuenta.id; 
        contacto.FirstName = 'Primero'; 
        contacto.LastName = 'Contactos';
        insert contacto;  

        cuenta.SEG_GestorFinEstructurada__c= contacto.id;
        update cuenta;
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        Map<String, Object> mapaGetIdentidadBoton2 = SEG_Case_EmailBuscador_Controller.getIdentidadBoton(caso.id);
        Test.stopTest();

        System.assertNotEquals(null , mapaGetIdentidadBoton2,'No se ha recibido la identidad boton caso.id 2');
        }
    }

    @IsTest
    static void alternativasTestTrue3(){

        Account centro1 = new Account();
        centro1.Name = 'centro1';
        centro1.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		insert centro1;

        Account cuenta = new account();
        cuenta.Name = 'testeoclap';
        cuenta.SEG_Prioridad_Carterizacion_Segmentos__c = true;
        cuenta.SEG_Oficina_Gestora_Segmentos__c = centro1.id;
        insert cuenta;

        Case caso = new Case();
        caso.Subject = 'oepa';
        caso.AccountId = cuenta.id;
        insert caso;
        
        Contact contacto = new Contact();
        contacto.AccountId = cuenta.id; 
        contacto.FirstName = 'Primero'; 
        contacto.LastName = 'Contactos';
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        insert contacto;  

        cuenta.SEG_GestorOperativaNacional__c= contacto.id;
        update cuenta;
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        Map<String, Object> mapaGetIdentidadBoton3 = SEG_Case_EmailBuscador_Controller.getIdentidadBoton(caso.id);
        Test.stopTest();

        System.assertNotEquals(null , mapaGetIdentidadBoton3,'No se ha recibido la identidad boton caso.id 3');
        }
    }

    @IsTest
    static void alternativasTestFalse(){

        Account centro1 = new Account();
        centro1.Name = 'centro1';
        centro1.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		insert centro1;

        Account cuenta = new account();
        cuenta.Name = 'testeoclap';
        cuenta.SEG_Prioridad_Carterizacion_Segmentos__c = false;
        cuenta.SEG_Oficina_Gestora_Segmentos__c = centro1.id;
        insert cuenta;

        Case caso = new Case();
        caso.Subject = 'oepa';
        caso.AccountId = cuenta.id;
        insert caso;
        
        Contact contacto = new Contact();
        contacto.AccountId = cuenta.id; 
        contacto.FirstName = 'Primero'; 
        contacto.LastName = 'Contactos';
        insert contacto;  

        cuenta.SEG_GestorOperativaInternacional__c = contacto.id;
        update cuenta;
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        Map<String, Object> mapaGetIdentidadBoton4 = SEG_Case_EmailBuscador_Controller.getIdentidadBoton(caso.id);
        Test.stopTest();

        System.assertNotEquals(null , mapaGetIdentidadBoton4,'No se ha recibido la identidad boton caso.id 4');
        }
    }

    @IsTest
    static void alternativasTestFalse2(){

        Account centro1 = new Account();
        centro1.Name = 'centro1';
        centro1.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		insert centro1;

        Account cuenta = new account();
        cuenta.Name = 'testeoclap';
        cuenta.SEG_Prioridad_Carterizacion_Segmentos__c = false;
        cuenta.SEG_Oficina_Gestora_Segmentos__c = centro1.id;
        insert cuenta;

        Case caso = new Case();
        caso.Subject = 'oepa';
        caso.AccountId = cuenta.id;
        insert caso;
        
        Contact contacto = new Contact();
        contacto.AccountId = cuenta.id; 
        contacto.FirstName = 'Primero'; 
        contacto.LastName = 'Contactos';
        insert contacto;  

        cuenta.SEG_GestorFinEstructurada__c= contacto.id;
        update cuenta;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        
        Test.startTest();
        Map<String, Object> mapaGetIdentidadBoton5 =  SEG_Case_EmailBuscador_Controller.getIdentidadBoton(caso.id);
        Test.stopTest();

        System.assertNotEquals(null , mapaGetIdentidadBoton5,'No se ha recibido la identidad boton caso.id 5');
        }
    }
    @IsTest
    static void alternativasTestFalse3(){

        Account centro1 = new Account();
        centro1.Name = 'centro1';
        centro1.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		insert centro1;

        Account cuenta = new account();
        cuenta.Name = 'testeoclap';
        cuenta.SEG_Prioridad_Carterizacion_Segmentos__c = false;
        cuenta.SEG_Oficina_Gestora_Segmentos__c = centro1.id;
        insert cuenta;

        Case caso = new Case();
        caso.Subject = 'oepa';
        caso.AccountId = cuenta.id;
        insert caso;
        
        Contact contacto = new Contact();
        contacto.AccountId = cuenta.id; 
        contacto.FirstName = 'Primero'; 
        contacto.LastName = 'Contactos';
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        insert contacto;  

        cuenta.SEG_GestorOperativaNacional__c= contacto.id;
        update cuenta;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        
        Test.startTest();
        Map<String, Object> mapaGetIdentidadBoton6 = SEG_Case_EmailBuscador_Controller.getIdentidadBoton(caso.id);
        Test.stopTest();

        System.assertNotEquals(null , mapaGetIdentidadBoton6,'No se ha recibido la identidad boton caso.id 6');
        }
    }
}