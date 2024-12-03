@isTest
public class CC_Enlaces_Controller_Test {    
    
    static testmethod void test()
    {
        Test.startTest();
        
        //Recupera enlaces a partir del caso
        List<CC_Enlace__c> enlaces = CC_Enlaces_Controller.getEnlaces();
        
        Test.stopTest();
        
        //Comprueba resultados devueltos
        if (enlaces.size() > 0)
        {
            System.assert(enlaces[0].CC_URL__c != '' && enlaces[0].CC_Nombre__c != '');
        }
    }
}