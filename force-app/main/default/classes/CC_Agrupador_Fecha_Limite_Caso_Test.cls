@isTest
public with sharing class CC_Agrupador_Fecha_Limite_Caso_Test {
    @isTest
    public static void asignarFechaLimite_test()
    {
        List<Id> idList = new List<Id>();
        List<Case> caseList = new List<Case>();
        caseList.add(new Case(
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Atención al Cliente',
            CC_Tipo_Contacto__c = 'Petición documentación'
        ));

        caseList.add(new Case(
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Atención al Cliente'
        ));

        caseList.add(new Case(
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Atención al Cliente'
        ));

        caseList.add(new Case(
            Origin = 'Phone',
            CC_Canal_Procedencia__c = 'Atención al Cliente'
        ));

        caseList.add(new Case(
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Oficina Preventiva'
        ));
        
         caseList.add(new Case(
            Origin = 'Phone',
            CC_Canal_Procedencia__c = 'Atención al Cliente',
            CC_Tipo_Contacto__c = 'Petición documentación'
        ));
        
          caseList.add(new Case(
            Origin = 'Twitter',
            CC_Canal_Procedencia__c = 'ImaginBank'
        ));

        insert caseList;
        
        caseList[0].CC_Canal_Resolucion__c = 'Atención al Cliente';
        caseList[1].CC_Canal_Resolucion__c = 'Junta Andalucia';
        caseList[2].CC_Canal_Resolucion__c = 'Atención al Cliente';
        caseList[3].CC_Canal_Resolucion__c = 'Atención al Cliente';
        //el 4rt no va con canal de resolucion
        caseList[5].CC_Canal_Resolucion__c = 'Atención al Cliente';
        caseList[6].CC_Canal_Resolucion__c = 'Atención al Cliente';
        update caseList;

        idList.add(caseList[0].Id);
        idList.add(caseList[1].Id);
        idList.add(caseList[2].Id);
        idList.add(caseList[3].Id);
        idList.add(caseList[4].Id);
        idList.add(caseList[5].Id);
        idList.add(caseList[6].Id);

        Test.startTest();
        CC_Agrupador_Fecha_Limite_Caso.asignarFechaLimite(idList);
        Test.stopTest();
        
        caseList = [SELECT CC_Fecha_Limite_Resolucion_Verde__c,CC_Fecha_Limite_Resolucion_Naranja__c,CC_Fecha_Limite_Resolucion__c FROM Case];
        System.assertNotEquals(null, caseList[0].CC_Fecha_Limite_Resolucion_Verde__c);
        System.assertNotEquals(null, caseList[0].CC_Fecha_Limite_Resolucion_Naranja__c);
        System.assertNotEquals(null, caseList[0].CC_Fecha_Limite_Resolucion__c);

        System.assertNotEquals(null, caseList[1].CC_Fecha_Limite_Resolucion_Verde__c);
        System.assertNotEquals(null, caseList[1].CC_Fecha_Limite_Resolucion_Naranja__c);
        System.assertNotEquals(null, caseList[1].CC_Fecha_Limite_Resolucion__c);

        System.assertNotEquals(null, caseList[2].CC_Fecha_Limite_Resolucion_Verde__c);
        System.assertNotEquals(null, caseList[2].CC_Fecha_Limite_Resolucion_Naranja__c);
        System.assertNotEquals(null, caseList[2].CC_Fecha_Limite_Resolucion__c);

        System.assertNotEquals(null, caseList[3].CC_Fecha_Limite_Resolucion_Verde__c);
        System.assertNotEquals(null, caseList[3].CC_Fecha_Limite_Resolucion_Naranja__c);
        System.assertNotEquals(null, caseList[3].CC_Fecha_Limite_Resolucion__c);

        System.assertNotEquals(null, caseList[4].CC_Fecha_Limite_Resolucion_Verde__c);
        System.assertNotEquals(null, caseList[4].CC_Fecha_Limite_Resolucion_Naranja__c);
        System.assertNotEquals(null, caseList[4].CC_Fecha_Limite_Resolucion__c);
        
        System.assertNotEquals(null, caseList[5].CC_Fecha_Limite_Resolucion_Verde__c);
        System.assertNotEquals(null, caseList[5].CC_Fecha_Limite_Resolucion_Naranja__c);
        System.assertNotEquals(null, caseList[5].CC_Fecha_Limite_Resolucion__c);
        
        System.assertNotEquals(null, caseList[6].CC_Fecha_Limite_Resolucion_Verde__c);
        System.assertNotEquals(null, caseList[6].CC_Fecha_Limite_Resolucion_Naranja__c);
        System.assertNotEquals(null, caseList[6].CC_Fecha_Limite_Resolucion__c);
    }
}