/*
* @description: SAC_PrestamoRelacionBatch to create junction object relations between préstamo and titulares
* @schedulable: SAC_PrestamoRelacionSchedulable
* @test: SAC_PrestamoRelacionBatchTest
* @author: iria.alvarez.novoa@ibm.com
* @date: october 2024
*/
public class SAC_PrestamoRelacionBatch implements Database.Batchable<sObject>{
    
    private final static Id RECORDTYPEPRESTAMO = Schema.SObjectType.SAC_Prestamo__c.getRecordTypeInfosByDeveloperName().get('SAC_Prestamo').getRecordTypeId();
    
    public SAC_PrestamoRelacionBatch() {
        System.debug('Empty constructor');
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, SAC_Id_cuenta_actual__c, SAC_Codigo_Contrato__c FROM SAC_Prestamo__c WHERE RecordTypeId = \'' + RECORDTYPEPRESTAMO + '\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<SAC_Prestamo__c> prestamos){
        List<String> codigoTitCuenta = new List<String>();
        List<String> codigoTitPrestamo = new List<String>();
        List<Id> idsTitulares = new List<Id>();
        Map<String, List<String>> mapTitularCuenta = new Map<String, List<String>>();
        Map<String, List<String>> mapTitularPrestamo = new Map<String, List<String>>();
		List<SAC_Prestamo_Titular__c> relationsToCreate = new List<SAC_Prestamo_Titular__c>();
        // Identify Titulares
        for(SAC_Prestamo__c prestamo: prestamos){
            codigoTitCuenta.add(prestamo.SAC_Id_cuenta_actual__c);
            codigoTitPrestamo.add(prestamo.SAC_Codigo_Contrato__c);
        }
        // Get Titulares
        for(SAC_Prestamo__c titular : [SELECT Id, SAC_Id_cuenta_actual__c, SAC_Codigo_Contrato__c FROM SAC_Prestamo__c WHERE (SAC_Id_cuenta_actual__c IN: codigoTitCuenta OR SAC_Codigo_Contrato__c IN: codigoTitPrestamo) AND RecordTypeId !=: RECORDTYPEPRESTAMO]){
            idsTitulares.add(titular.Id);
            if(mapTitularCuenta.containsKey(titular.SAC_Id_cuenta_actual__c)){
                List<String> titList = mapTitularCuenta.get(titular.SAC_Id_cuenta_actual__c);
                titList.add(titular.Id);
                mapTitularCuenta.put(titular.SAC_Id_cuenta_actual__c, titList);
            }else{
                List<String> titList = new List<String>{titular.Id};
                    mapTitularCuenta.put(titular.SAC_Id_cuenta_actual__c, titList);
            }
            if(mapTitularPrestamo.containsKey(titular.SAC_Codigo_Contrato__c)){
                List<String> titList = mapTitularPrestamo.get(titular.SAC_Codigo_Contrato__c);
                titList.add(titular.Id);
                mapTitularPrestamo.put(titular.SAC_Codigo_Contrato__c, titList);
            }else{
                List<String> titList = new List<String>{titular.Id};
                    mapTitularPrestamo.put(titular.SAC_Codigo_Contrato__c, titList);
            }
        }
        // Get Relations (Préstamo Titular)
        Map<String, List<Id>> mapPrestamoTitular = new Map<String, List<Id>>();
        for(SAC_Prestamo_Titular__c pt: [SELECT Id, SAC_Prestamo__c, SAC_Titular__c FROM SAC_Prestamo_Titular__c WHERE SAC_Titular__c IN: idsTitulares]){
            if(mapPrestamoTitular.containsKey(pt.SAC_Prestamo__c)){
                List<Id> ptList = mapPrestamoTitular.get(pt.SAC_Prestamo__c);
                ptList.add(pt.SAC_Titular__c);
                mapPrestamoTitular.put(pt.SAC_Prestamo__c, ptList);
            }else{
                List<Id> ptList = new List<Id>{pt.SAC_Titular__c};
                    mapPrestamoTitular.put(pt.SAC_Prestamo__c, ptList);
            }
        }
        for(SAC_Prestamo__c prestamo: prestamos){
            if(mapTitularCuenta.containsKey(prestamo.SAC_Id_cuenta_actual__c)){
                // Get Titulares Cuenta
                List<Id> titularesCuentaIds = mapTitularCuenta.get(prestamo.SAC_Id_cuenta_actual__c);
                if(mapPrestamoTitular.containsKey(prestamo.Id)){
                    // Get relations
                    List<Id> relaciones = mapPrestamoTitular.get(prestamo.Id);
                    for(Id titular: titularesCuentaIds){
                        // Check if relation is already created and if not, create it
                        if(!relaciones.contains(titular)){
                            SAC_Prestamo_Titular__c relation = new SAC_Prestamo_Titular__c();
                            relation.SAC_Prestamo__c = prestamo.Id;
                            relation.SAC_Titular__c = titular;
                            relationsToCreate.add(relation);
                        }
                    }
                }else{
                    for(String titular: titularesCuentaIds){
                        SAC_Prestamo_Titular__c relation = new SAC_Prestamo_Titular__c();
                        relation.SAC_Prestamo__c = prestamo.Id;
                        relation.SAC_Titular__c = titular;
                        relationsToCreate.add(relation);
                    }
                }
            }
            if(mapTitularPrestamo.containsKey(prestamo.SAC_Codigo_Contrato__c)){
                // Get Titulares Préstamo
                List<Id> titularesPrestamoIds = mapTitularPrestamo.get(prestamo.SAC_Codigo_Contrato__c);
                if(mapPrestamoTitular.containsKey(prestamo.Id)){
                    // Get relations
                    List<Id> relaciones = mapPrestamoTitular.get(prestamo.Id);
                    for(Id titular: titularesPrestamoIds){
                        // Check if relation is already created and if not, create it
                        if(!relaciones.contains(titular)){
                            SAC_Prestamo_Titular__c relation = new SAC_Prestamo_Titular__c();
                            relation.SAC_Prestamo__c = prestamo.Id;
                            relation.SAC_Titular__c = titular;
                            relationsToCreate.add(relation);
                        }
                    }
                }else{
                    for(String titular: titularesPrestamoIds){
                        SAC_Prestamo_Titular__c relation = new SAC_Prestamo_Titular__c();
                        relation.SAC_Prestamo__c = prestamo.Id;
                        relation.SAC_Titular__c = titular;
                        relationsToCreate.add(relation);
                    }
                }
            }
        }
        if(!relationsToCreate.isEmpty()){
            insert relationsToCreate;
        }
    }
    
    public void finish(Database.BatchableContext bc){
        // Fin
        System.debug('Fin del batch');
    }
    
}