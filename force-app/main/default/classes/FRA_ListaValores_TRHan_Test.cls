@isTest
public with sharing class FRA_ListaValores_TRHan_Test {

    @TestSetup
    static void makeData(){

        Id perfilAdministradorId = [SELECT Id FROM Profile
									WHERE Name IN ('System Administrator', 'Administrador del sistema') LIMIT 1].Id;

        User usuario = new User();
        usuario.FirstName = 'Agente';
        usuario.LastName = 'Uno';
        usuario.Alias='AUno';
        usuario.Email = 'agente2@invalid.comtest';
        usuario.Username= 'agente1@caixa.comtest_cc_fraude';
        usuario.ProfileId = perfilAdministradorId;
        usuario.EmailEncodingkey='UTF-8';
        usuario.LanguageLocaleKey='en_US';
        usuario.LocalesIdKey='en_US';
        usuario.TimezonesIdKey='Europe/Berlin';

        insert new List<User>{usuario};
    }

    @isTest
    public static void crearEquivalenciaTest() {

        User usuario = [SELECT Id FROM User WHERE Username = 'agente1@caixa.comtest_cc_fraude' LIMIT 1];

        System.runAs(usuario) {

            Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');

            CC_MCC__c mccMotivo = new CC_MCC__c();
            mccMotivo.Name = 'Test Motivo CC para lista valores';
            mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
            mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccMotivo.RecordTypeId = recordTypeIdMotivo;
            mccMotivo.CC_Ambito_Tareas_Caixa__c = 'Caso a Fraude';
            mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
            insert mccMotivo;

            CC_MCC__c mccMotivo2 = new CC_MCC__c();
            mccMotivo2.Name = 'Test motivo FRAUDE para lista valores';
            mccMotivo2.CC_Tipo_Cliente__c = 'Cliente (FRA)';
            mccMotivo2.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccMotivo2.RecordTypeId = recordTypeIdMotivo;
            mccMotivo2.CC_Codigo_Externo__c = 'MO-000002';
            insert mccMotivo2;

            Id tablaEquivalenciasRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'FRA_TablaEquivalenciasDerivacion_CC_FRAUDE');

            CC_Lista_Valores__c equivalencia = new CC_Lista_Valores__c();
            equivalencia.Name = 'Tets equivalencia MCC CC FRAUDE';
            equivalencia.RecordTypeId = tablaEquivalenciasRecordTypeId;
            equivalencia.FRA_MotivoOrigen__c = mccMotivo.Id;
            equivalencia.FRA_MotivoDestino__c = mccMotivo2.Id;
            insert equivalencia;

            System.assert(equivalencia.Id != null, 'Error al insertar la equivalencia');
        }
    }

    @isTest
    public static void crearEquivalenciaTest2() {

        User usuario = [SELECT Id FROM User WHERE Username = 'agente1@caixa.comtest_cc_fraude' LIMIT 1];

        System.runAs(usuario) {

            Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');

            CC_MCC__c mccMotivo = new CC_MCC__c();
            mccMotivo.Name = 'Test Motivo CC para lista valores';
            mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
            mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccMotivo.RecordTypeId = recordTypeIdMotivo;
            mccMotivo.CC_Ambito_Tareas_Caixa__c = 'Caso a Fraude';
            mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
            insert mccMotivo;

            CC_MCC__c mccMotivo3 = new CC_MCC__c();
            mccMotivo3.Name = 'Test Motivo CC para lista valores2';
            mccMotivo3.CC_Tipo_Cliente__c = 'Cliente';
            mccMotivo3.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccMotivo3.RecordTypeId = recordTypeIdMotivo;
            mccMotivo3.CC_Ambito_Tareas_Caixa__c = 'Caso a Fraude';
            mccMotivo3.CC_Codigo_Externo__c = 'MO-000003';
            insert mccMotivo3;

            CC_MCC__c mccMotivo2 = new CC_MCC__c();
            mccMotivo2.Name = 'Test motivo FRAUDE para lista valores';
            mccMotivo2.CC_Tipo_Cliente__c = 'Cliente (FRA)';
            mccMotivo2.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccMotivo2.RecordTypeId = recordTypeIdMotivo;
            mccMotivo2.CC_Codigo_Externo__c = 'MO-000002';
            insert mccMotivo2;

            Id tablaEquivalenciasRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'FRA_TablaEquivalenciasDerivacion_CC_FRAUDE');

            CC_Lista_Valores__c equivalencia = new CC_Lista_Valores__c();
            equivalencia.Name = 'Tets equivalencia MCC CC FRAUDE';
            equivalencia.RecordTypeId = tablaEquivalenciasRecordTypeId;
            equivalencia.FRA_MotivoOrigen__c = mccMotivo.Id;
            equivalencia.FRA_MotivoDestino__c = mccMotivo2.Id;
            insert equivalencia;

            equivalencia.FRA_MotivoOrigen__c = mccMotivo3.Id;
            update equivalencia;

            System.assert(equivalencia.Id != null, 'Error al insertar la equivalencia');
        }
    }
}