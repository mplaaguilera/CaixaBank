/**********************************************************************************************************************
 Name:    AV_ConfidentialBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para asociar al Gestor cualquier cliente que tenga carterizado.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION     USER_STORY      AUTHOR              DATE                Description
    1.0         App FSC         Carolina Alonso     18/05/2020          Init version
    1.1         App FSC         Víctor Santiago     15/01/2021          Add condition to check active book
    1.2         FIX             David Rufo          31/05/2021          Use the Query FWK
    1.3         FIX Confiden... Víctor Santiago     04/10/2021          Added condition to check for existing gestores
                                                                        and deleted set of AV_ClienteConfidencial__c field.
    1.4         US245181        Daniel Rodriguez    02/12/2021          Added condition to check AV_Empleado__c
    1.5         AV_Query IT     Daniel Rodríguez    02/03/2022          Change AV_Query to SOQL for User, Account, Contact
    2.0         Fix Confidencial    Carolina Alonso 26/09/2022          Modify the logic to calculate the hierarchy 
***********************************************************************************************************************/
global class AV_ConfidentialBatch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {

    global Integer recordsProcessed = 0;
    global static final String BATCHNAME = 'AV_ConfidentialBatch';
    global static final String TIPOMC  = 'MC';
    
    /**
     * Create a list of Clients that are Confidential or Employees.
     *
     * @param bc  Database.BatchableContext param that contains the batch job ID
     */ 
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String methodName = 'start';
        String avQuery = '';
        String limitBatch = AV_SchedulerBatches.getLimit(BATCHNAME);
        if(String.isNotBlank(limitBatch)){
            avQuery = 'select Id,AV_EAPGestor__c from Account where RecordType.DeveloperName IN ('+ '\'CC_Cliente\''+','+'\'CC_ClientePA\''+') and (AV_Confidencial__c = true or AV_Empleado__c = true) and AV_EAPGestor__c != null limit '+ Integer.valueOf(limitBatch)+' ';
        }else{
            avQuery = 'select Id,AV_EAPGestor__c from Account where RecordType.DeveloperName IN ('+ '\'CC_Cliente\''+','+'\'CC_ClientePA\''+') and (AV_Confidencial__c = true or AV_Empleado__c = true) and AV_EAPGestor__c != null ';
        }

        AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);
        return Database.getQueryLocator(avQuery);
    }

    /**
     * Insert the AccountTeamMembers
     *
     * @param bc    Database.BatchableContext param that contains the batch job ID
     * @param listClients List<Account> param with the list of Confidential Clients.
     */
    global void execute(Database.BatchableContext bc, List<Account> listClients){
        // Procesar cada batch de registros
        String methodName = 'execute';
        try{
            recordsProcessed = listClients.size();
            AV_LogDebug.printLogDebug(methodName,'Confidential Clients: ' + listClients.size());
            
            //Retrive all employees associated to Confidential Clients
            Map<String, Contact> mapGestores = getGestores(listClients);
            AV_LogDebug.printLogDebug(methodName, 'Record gestores ' + mapGestores);
            List<AccountTeamMember> listAccountTeamMembers = new List<AccountTeamMember>();
            for(Account clienteConfidencial : listClients){
                Contact gestor = mapGestores.get(clienteConfidencial.AV_EAPGestor__c);
                if(gestor != null){
                    if (gestor.AccountId != null && gestor.Account.AV_MatriculaResponsable1__c != null &&
                        gestor.Account.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__c != null &&
                        gestor.Account.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__r.IsActive){
                        createAccountTeamMember(listAccountTeamMembers, gestor.Account.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__c, clienteConfidencial.Id);  
                    }
                    if (gestor.AccountId != null && gestor.Account.AV_CentroSuperior__c != null &&
                        gestor.Account.AV_CentroSuperior__r.AV_MatriculaResponsable1__c != null &&
                        gestor.Account.AV_CentroSuperior__r.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__c != null &&
                        gestor.Account.AV_CentroSuperior__r.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__r.IsActive){
                        createAccountTeamMember(listAccountTeamMembers, gestor.Account.AV_CentroSuperior__r.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__c, clienteConfidencial.Id); 
                    }
                    if (gestor.AccountId != null && gestor.Account.AV_CentroSuperior__c != null &&
                        gestor.Account.AV_CentroSuperior__r.AV_CentroSuperior__c != null &&
                        gestor.Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_MatriculaResponsable1__c != null &&
                        gestor.Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__c != null &&
                        gestor.Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__r.IsActive){
                        createAccountTeamMember(listAccountTeamMembers, gestor.Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__c, clienteConfidencial.Id);    
                    }
                    if (gestor.AccountId != null && gestor.Account.AV_CentroSuperior__c != null &&
                        gestor.Account.AV_CentroSuperior__r.AV_CentroSuperior__c != null &&
                        gestor.Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c != null &&
                        gestor.Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_MatriculaResponsable1__c != null &&
                        gestor.Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__c != null &&
                        gestor.Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__r.IsActive){
                        createAccountTeamMember(listAccountTeamMembers, gestor.Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__c, clienteConfidencial.Id);   
                    }
                }
            }

            if(!listAccountTeamMembers.isEmpty()){
                    CBK_Log.debug('Record to insert: ' + listAccountTeamMembers, logginglevel.DEBUG);
                    Database.insert(listAccountTeamMembers);
            }

        }catch(System.Exception e){
            CBK_Log.error(methodName, e);
        }
    }   

    /**
     * Executes the scheduled Apex job
     *
     * @param sc    SchedulableContext param that contains the job ID
     */
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new AV_ConfidentialBatch());
    }

    /**
     * Print the results of the batch process
     *
     * @param bc    Database.BatchableContext param that contains the batch job ID
     */
    global void finish(Database.BatchableContext bc){
        String methodName='finish';
        CBK_Log.debug('Record Processes: ' + recordsProcessed, logginglevel.DEBUG);
    }

    /**
     * Create List of Users associated with the EAPGestor responsibles.
     *
     * @param listClients   lista de Confidential Clients
     */
    private Map<String, Contact> getGestores(List<Account> listClients) {
        Set<Id> setIdsEAPGestor = new Set<Id>();
        for(Account clienteConfidencial : listClients){
            if(String.isNotBlank(clienteConfidencial.AV_EAPGestor__c)){
                setIdsEAPGestor.add(clienteConfidencial.AV_EAPGestor__c);
            }               
        }
        //Recupero todos los responsables de los centros superiores asociados al EAP/Gestor
        List<Contact> listGestores = [select Id, AccountId, Account.AV_MatriculaResponsable1__c, Account.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__c,Account.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__r.IsActive, Account.AV_CentroSuperior__c, Account.AV_CentroSuperior__r.AV_MatriculaResponsable1__c, Account.AV_CentroSuperior__r.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__c, Account.AV_CentroSuperior__r.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__r.IsActive, Account.AV_CentroSuperior__r.AV_CentroSuperior__c, Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_MatriculaResponsable1__c, Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__c, Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__r.IsActive, Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c, Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_MatriculaResponsable1__c, Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__c,Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_MatriculaResponsable1__r.AV_UsuarioAsociado__r.IsActive from Contact where Id in :setIdsEAPGestor ];
        Map<String, Contact> mapGestores = new Map<String, Contact>();
        
        if (listGestores != null && !listGestores.isEmpty()) {
            for(Contact gestor : listGestores){
                mapGestores.put(gestor.Id, gestor);
            }
        }
        
        return mapGestores;
    }

    /**
     * Create AccountTeamMember
     *
     * @param listAccTM Lista de AccountTeamMembers created
     * @param usuarioAsociado   AV_UsuarioAsociado__c from Contact
     * @param cliente   AV_Cliente__c Confidencial/Empleado
     */
    private void createAccountTeamMember(List<AccountTeamMember> listAccTM, Id usuarioAsociado, Id cliente) {
        if(String.isNotBlank(usuarioAsociado) && String.isNotBlank(cliente)){
            AccountTeamMember accTeamMember = new AccountTeamMember();
            accTeamMember.UserId = usuarioAsociado; 
            accTeamMember.AccountId = cliente;
            accTeamMember.AccountAccessLevel = 'Read';
            accTeamMember.OpportunityAccessLevel = 'Read';
            accTeamMember.CaseAccessLevel = 'Read';
            accTeamMember.ContactAccessLevel = 'Read';
            accTeamMember.AV_Tipo__c = TIPOMC;
            listAccTM.add(accTeamMember);
        }   
    }
}