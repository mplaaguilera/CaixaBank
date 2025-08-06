@isTest
public with sharing class TMS_WS_Upd_Case_Aux_Test {

    @isTest
    public static void updateTasksWithoutSharing() {
        Map<String, User> usuarios = new Map<String, User>{
            'supervisor' => TMS_Usuarios.usuarioSupervisor(),
            'integracion' => TMS_Usuarios.usuarioAPI(),
            'letrado' => TMS_Usuarios.usuarioLetrado()
        };

        System.runAs(usuarios.get('supervisor')) {
            Case expediente = new Case();
            expediente.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TMS_Expediente').getRecordTypeId();
            expediente.Subject = 'Expediente Test';
			expediente.Origin = 'Backend';
            expediente.CC_Canal_Procedencia__c = 'Testamentarias';
            expediente.TMS_Numexp__c = '11111111';
            expediente.CC_Tipo_Contacto__c = 'Gestión expediente';
            insert expediente;

            Task tareaTms = new Task();
            tareaTms.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('TMS_Tarea').getRecordTypeId();
            tareaTms.WhatId = expediente.Id;
            tareaTms.Subject = 'Tarea TMS';
            tareaTms.Status = 'Open';
            insert tareaTms;

            System.runAs(usuarios.get('integracion')) {
                Test.startTest();
                tareaTms.OwnerId = usuarios.get('letrado').Id;
                TMS_WS_Upd_Case_Aux.updateTasksWithoutSharing(new List<Task>{tareaTms});

                String errorMessage;
                try {
                    tareaTms.OwnerId = tareaTms.Id; //Id no válido
                    TMS_WS_Upd_Case_Aux.updateTasksWithoutSharing(new List<Task>{tareaTms});
                } catch (Exception e) {
                    errorMessage = e.getMessage();
                }
                Test.stopTest();

                Id idUsuarioLetrado = usuarios.get('letrado').Id;
                System.assertEquals(idUsuarioLetrado, [SELECT OwnerId FROM Task WHERE Id = :tareaTms.Id].OwnerId, 'Owner tarea TMS no actualizado');
                System.assert(String.isNotBlank(errorMessage), 'Debería haberse producido una excepción');
            }
        }
    }
}