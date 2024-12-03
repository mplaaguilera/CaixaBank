/**********************************************************************************************************************
 Name:	EV_lookupEmployees_Controller
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controller para la recuperación de empleados en las altas masivas de eventos.
---------------------------------------------------------------------------------------------------------------------- 
 * VERSION	USER_STORY	    AUTHOR			        DATE		    Description
 * 1.0		US585725	    Humberto Vilchez		25/07/2023   	Init Version
 * 1.1      US704873        Carolina Lopez          09/10/2023      Add AV_UsuarioAsociado__r filter in searchEmployees, getDirectGestContactIds.
***********************************************************************************************************************/
public with sharing class EV_lookupEmployees_Controller {
    
    @AuraEnabled
    public static List<Contact> searchEmployees(String valueIn){ 
        EV_LogDebug.printLogDebug('searchEmployees ',String.valueof(valueIn));
        List<List<Contact>> employeesList = new List<List<Contact>>();   
        valueIn +='*';
        if(Test.isRunningTest()){
            employeesList = [FIND :valueIn IN Name FIELDS RETURNING Contact(id, Name, CC_Nombre_Oficina__c, Account.CC_Numero_Oficina__c, AccountId, Account.BillingCity, Account.Name, Account.BillingStreet, Account.BillingPostalCode, CC_Matricula__c, AV_Responsabilidad__c, AV_UsuarioAsociado__c, AV_UsuarioAsociado__r.isActive  LIMIT 5)];
        }else{
            employeesList = [FIND :valueIn IN Name FIELDS RETURNING Contact(id, Name, CC_Nombre_Oficina__c, Account.CC_Numero_Oficina__c, AccountId, Account.BillingCity, Account.Name, Account.BillingStreet, Account.BillingPostalCode, CC_Matricula__c, AV_Responsabilidad__c, AV_UsuarioAsociado__c, AV_UsuarioAsociado__r.isActive WHERE RecordType.DeveloperName = 'CC_Empleado' AND (CC_Matricula__c != null AND (not(CC_Matricula__c like '%INVALID%') )) AND AV_UsuarioAsociado__c != null  AND AV_UsuarioAsociado__r.isActive = true AND Account.CC_Numero_Oficina__c	!= null LIMIT 5)];
        }
        if(!employeesList.isEmpty() && !employeesList.get(0).isEmpty()){
            return employeesList[0];     
        }
        else { 
            return null;
        }                
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getCentrosHierarchy(){ 
        List<Account> centrosList = new List<Account>();
        centrosList =  [SELECT id, Name, BillingState,
                        AV_CentroSuperior__r.Name, AV_CentroSuperior__r.AV_CentroSuperior__r.Name, AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Name, 
                        AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Name,
                        AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Name,
                        AV_CentroSuperior__r.Id, AV_CentroSuperior__r.AV_CentroSuperior__r.Id, AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id,
                        AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id,
                        AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id,
                        AV_CentroSuperior__r.BillingState, AV_CentroSuperior__r.AV_CentroSuperior__r.BillingState, AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.BillingState
                        FROM Account WHERE RecordType.DeveloperName = 'CC_CentroCaixaBank' 
                        AND AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c != null
                        AND AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c = '001-09016'
                        ORDER BY AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c                      
                       ];
        return centrosList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getDirectGestContactIds(List<String> officeList, Boolean isCentros, Boolean isResponsabilidad){ 
        List<Contact> contactsDir = new List<Contact>();
        String jobLevelV = '120';
        String invalidV = '%INVALID%';
            
        
        String contactsQuery = 'SELECT id, Name, CC_Numero_Oficina__c, CC_Matricula__c, AV_UsuarioAsociado__c, AV_Responsabilidad__c, CC_Nombre_Oficina__c, ' + 
                                'AccountId, Account.name, Account.BillingCity, Account.BillingStreet, Account.BillingPostalCode, Account.BillingState, AV_UsuarioAsociado__r.isActive ' +
                                'FROM Contact ' + 
                                'WHERE AccountId IN: officeList ' +
                                'AND (CC_Matricula__c != null AND (not(CC_Matricula__c like :invalidV ) )) ' +
                                'AND AV_UsuarioAsociado__c != null AND AV_UsuarioAsociado__r.isActive = true AND Account.CC_Numero_Oficina__c != null ';
        if(isCentros){
            contactsQuery += 'AND (AV_JobLevels__c <= :jobLevelV AND AV_JobLevels__c != null)';
        }
        if(isResponsabilidad){
            contactsQuery += 'AND (AV_JobLevels__c > :jobLevelV AND AV_JobLevels__c != null)';
        }
        
        contactsDir = Database.query(String.escapeSingleQuotes(contactsQuery));
        return contactsDir;
    } 
}