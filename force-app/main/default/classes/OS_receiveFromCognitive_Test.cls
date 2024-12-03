@isTest
public class OS_receiveFromCognitive_Test {

    @isTest public static void receiveFromCognitiveTest(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();

        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto01';
        contacto.LastName = 'Contacto01';
        contacto.CC_NumPerso__c = '25345561';
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'correo@prueba.com';
        insert contacto;
                
        System.runAs (usuarioOperador) {       
            Test.startTest();
            OS_receiveFromCognitive cognitive = OS_receiveFromCognitive.parse('{"sr": "2-912076545","model_name": "model-001","category": "UAFE Confirming","categories": [{"category": "UAFE Confirming", "ratio": "0.52114"},{"category": "UAFE Factoring", "ratio": "0.22389"},{"category": "UAFE Grandes Clientes", "ratio": "0.20729"},{"category": "UAFE Sucursales Internacionales", "ratio": "0.02778"},{"category": "UAFE Export Finance", "ratio": "0.01109"},{"category": "UAFE Cartera de Efectos", "ratio": "0.00698"},{"category": "UAFE Clasificador", "ratio": "0.00155"},{"category": "Robot no encontrado", "ratio": "0.00027"}]}');
            Test.stopTest();
    
            system.assertEquals('2-912076545', cognitive.sr, 'Comprobación sr.');
            system.assertEquals('model-001', cognitive.model_name, 'Comprobación del nombre.');
            system.assertEquals('UAFE Confirming', cognitive.categories.get(0).category, 'Comprobación de la categoría.');
            system.assertEquals('0.52114', cognitive.categories.get(0).ratio, 'Comprobación del ratio de la categoría.');
        }
    }
}