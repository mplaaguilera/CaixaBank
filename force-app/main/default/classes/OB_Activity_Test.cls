@isTest
public with sharing class OB_Activity_Test {

    @isTest
    public static void crearActividad() {

        CC_Llamada__c llamada = OB_Llamada.crearLlamada('OB_Cliente', null);

        Task tarea = OB_Activity.crearActividad(
            llamada.Id,
            new Map<String, Object>{'Type' => 'Test'}
        );

        System.assertEquals(
            llamada.Id,
            [SELECT WhatId FROM Task WHERE Id = :tarea.Id].WhatId,
            'La tarea no está vinculada a la oportunidad'
        );
    }

}