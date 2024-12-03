@isTest
global with sharing class SEG_receiveFromCognitive_Test {
       
    @isTest public static void SEG_receiveFromCognitive(){
        
        String sFakeRespuesta = '';

        sFakeRespuesta = '{"sr": "2-912076545","model_name": "model-001","category": "Credit Cards","categories": [{"category": "Credit Cards", "ratio": "0.52114"},{"category": "Credit Cards", "ratio": "0.22389"},{"category": "Credit Cards", "ratio": "0.20729"},{"category": "Credit Cards", "ratio": "0.02778"},{"category": "Credit Cards", "ratio": "0.01109"},{"category": "Credit Cards", "ratio": "0.00698"},{"category": "Credit Cards", "ratio": "0.00155"},{"category": "Robot no encontrado", "ratio": "0.00027"}]}';

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        SEG_receiveFromCognitive receiveFromCognitive = SEG_receiveFromCognitive.parse(sFakeRespuesta);
        Test.stopTest();
        
        System.assertNotEquals(null , receiveFromCognitive,'No se ha recibido ningún valor en receiveFromCognitive');   

        }
    }

}