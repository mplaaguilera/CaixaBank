/*****************************************************************
 * Name: SAC_BatchCargaSLAMCC
 * Copyright © 2021  CaixaBank
 *  
 * Proposito: Carga de datos.
 *  
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             US335889  	Marcela Neira   17/02/22        Creación
*****************************************************************/

public with sharing class SAC_BatchCargaSLAMCC implements Database.Batchable<sObject> {

    private static final Id RECTYPEDETALLE= Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
    private static final Id RECTYPEALTA= Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_SLAAlta').getRecordTypeId();
    private static final Id RECTYPELETRADO= Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_SLALetrado').getRecordTypeId();
    private static final Id RECTYPEREGULATORIO= Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_SLARegulatorio').getRecordTypeId();


    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT ID, Name, SAC_EsPsd2__c  FROM CC_MCC__c WHERE RecordTypeId =: RECTYPEDETALLE
        ]);
    }
    public void execute(Database.BatchableContext bc, List<CC_MCC__c> listaMCCDetalle){
        List<SAC_ParametrizacionSLATME__c> parametrizaciones = new List<SAC_ParametrizacionSLATME__c> ();

        if (!listaMCCDetalle.isEmpty()) {
            for (CC_MCC__c mcc : listaMCCDetalle) {
                SAC_ParametrizacionSLATME__c slaAlta = new SAC_ParametrizacionSLATME__c();
                SAC_ParametrizacionSLATME__c slaAltaJunta = new SAC_ParametrizacionSLATME__c();
                SAC_ParametrizacionSLATME__c slaRegulatorio = new SAC_ParametrizacionSLATME__c();
                SAC_ParametrizacionSLATME__c slaRegulatorioJunta = new SAC_ParametrizacionSLATME__c();
                SAC_ParametrizacionSLATME__c slaLetrado = new SAC_ParametrizacionSLATME__c();
                SAC_ParametrizacionSLATME__c slaLetradoJunta = new SAC_ParametrizacionSLATME__c();

                slaAlta.Name = mcc.Name + ' Alta';
                slaAlta.SAC_MCC__c = mcc.Id;
                slaAlta.RecordTypeId = RECTYPEALTA;

                slaAltaJunta.Name = mcc.Name + ' Alta Junta Andalucia';
                slaAltaJunta.SAC_MCC__c = mcc.Id;
                slaAltaJunta.SAC_CanalProcedencia__c = 'Junta Andalucia';
                slaAltaJunta.RecordTypeId = RECTYPEALTA;

                slaRegulatorio.Name = mcc.Name + ' regulatorio' ;
                slaRegulatorio.SAC_MCC__c = mcc.Id;
                slaRegulatorio.RecordTypeId = RECTYPEREGULATORIO;

                slaRegulatorioJunta.Name = mcc.Name + ' regulatorio Junta Andalucia' ;
                slaRegulatorioJunta.SAC_CanalProcedencia__c = 'Junta Andalucia';
                slaRegulatorioJunta.SAC_MCC__c = mcc.Id;
                slaRegulatorioJunta.RecordTypeId = RECTYPEREGULATORIO;

                slaLetrado.Name = mcc.Name + ' letrado' ;
                slaLetrado.SAC_MCC__c = mcc.Id;
                slaLetrado.RecordTypeId = RECTYPELETRADO;

                slaLetradoJunta.Name = mcc.Name + ' letrado Junta Andalucia' ;
                slaLetradoJunta.SAC_CanalProcedencia__c = 'Junta Andalucia';
                slaLetradoJunta.SAC_MCC__c = mcc.Id;
                slaLetradoJunta.RecordTypeId = RECTYPELETRADO;

                /*Valor de las parametrizaciones*/
                slaAlta.SAC_Duracion__c = 1;
                slaAltaJunta.SAC_Duracion__c = 1;                             
                slaLetrado.SAC_Duracion__c = 15;
                slaLetradoJunta.SAC_Duracion__c = 5;
                slaRegulatorioJunta.SAC_Duracion__c = 10;

                if(mcc.SAC_EsPsd2__c){
                    slaRegulatorio.SAC_Duracion__c = 15; 
                }else{
                    slaRegulatorio.SAC_Duracion__c = 30;                      
                }                
                
                parametrizaciones.add(slaAlta);
                parametrizaciones.add(slaAltaJunta);
                parametrizaciones.add(slaRegulatorio);
                parametrizaciones.add(slaRegulatorioJunta);
                parametrizaciones.add(slaLetrado);
                parametrizaciones.add(slaLetradoJunta);
            }             
        }

        if (!parametrizaciones.isEmpty()) {
            insert parametrizaciones;
        }
    }
    public void finish(Database.BatchableContext bc){
        System.debug('Done');
    }
}