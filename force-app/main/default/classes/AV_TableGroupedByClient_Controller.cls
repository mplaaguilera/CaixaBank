/**********************************************************************************************************************
 Name:	  AV_TableGroupedByClient_Controller
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para el componente LWC AV_TableGroupedByClient
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Ainhoa				01/04/2023			Init version
	1.0			App FSC			Sandra				09/05/2023			Fix order by
    1.1         US584234        Laura  M            17/05/2023          Modified method valueOf to add all initiatives
    1.2         US646244        Oscar Moreno        07/08/2023          Add parameter origenFilter in getData method
    1.3         US646244        Oscar Moreno        07/08/2023          Add searchSubject method
    1.4         US646244        Oscar Moreno        07/08/2023          Add orderTaskByOrigen method
    1.5         US720234        Oscar Moreno        04/10/2023          Modify getData query. Change the query for search by subject
***********************************************************************************************************************/
public without sharing class AV_TableGroupedByClient_Controller {

    private final static Integer MAX_RESULTS 	= 10;

    public static String userId = String.valueOf(UserInfo.getUserId());

    public class TableGroupedByClientWrapper {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String origen;
        @AuraEnabled
        public String subject;
        @AuraEnabled
        public String value1;
        @AuraEnabled
        public String value2;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Date expirationDate;
        @AuraEnabled
        public String business;
        @AuraEnabled
        public Decimal age;
        @AuraEnabled
        public Double savingsAndInvestment;
        @AuraEnabled
        public Double financing;
        @AuraEnabled
        public Double income;
        @AuraEnabled
        public Double preApproved;
        @AuraEnabled
        public String mybox;
        @AuraEnabled
        public String targetAuto;
        @AuraEnabled
        public Id accountId;
        @AuraEnabled
        public Id taskId;
        @AuraEnabled
        public String groupField;
        @AuraEnabled
        public String interlocName;
        @AuraEnabled 
        public Decimal prio;
        @AuraEnabled
        public AV_GrupoInterlocucion__c interlocutionGroup;
        
    }

    public class Filters {
        @AuraEnabled
        public String subjectFilterValue {get; set;} 
        @AuraEnabled
        public Boolean preconcedidoFilterValue {get; set;}
        @AuraEnabled
        public String myBoxFilterValue {get; set;}
        @AuraEnabled
        public String targetAutoFilterValue {get; set;}
        @AuraEnabled
        public String origenFilterValue {get; set;}
        
    }


	/**
	* @description     	get data 
    * @param filterResults
    * @param origenFilter
	*/
    @AuraEnabled(cacheable=false)
    public static List<TableGroupedByClientWrapper> getData(Filters filterResults, String [] origenFilter) {
        String methodName = 'getData';

        Boolean isBpr = FeatureManagement.checkPermission(AV_AppConstants.PS_PRIVATEBANKING);

        List <TableGroupedByClientWrapper> wrapperList = new List <TableGroupedByClientWrapper>();
        List <Id> idAccountsList = new List <Id>();
        Set <Id> idSet = new Set<Id>();

        List<String> statusList = new List<String>{AV_AppConstants.TASK_STATUS_PENDIENTE, AV_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL};
        List<String> recordTypeList = new List<String>{AV_AppConstants.TASKALERTACOM_RT, AV_AppConstants.TASKPRIORIZADOR_RT, AV_AppConstants.TASKONBOARDING_RT, AV_AppConstants.TASKEXPCLIENT_RT};

        String avQuery = 'Select Id, AV_OrigenAct__c,AV_Origen__c , AccountId, WhatId, OwnerId, RecordType.Name, Subject, Status, ActivityDate, AV_Valor1__c, AV_Valor2__c,Account.AV_Priority__c,RecordType.DeveloperName FROM Task ';

        avQuery = avQuery +  'WHERE Status IN ' + AV_AppUtilities.arrayToStringIn(statusList) + ' AND OwnerId = : userId  AND AV_ToDelete__c = FALSE';
        

        String debugQuery = '';

        if(filterResults.subjectFilterValue != null ){
            avQuery = avQuery + ' AND Subject like \'%'+ filterResults.subjectFilterValue+'%\''; 

        }

       

        if(origenFilter != null && !origenFilter.isEmpty()){
            if(origenFilter.contains(AV_AppConstants.TASKINICIATIVA_RT) && origenFilter.size() == 1){
                    avQuery = avQuery + ' AND RecordType.DeveloperName  = \'' + AV_AppConstants.TASKINICIATIVA_RT + '\'' ;
                    avQuery = avQuery + ' AND (ActivityDate = LAST_N_DAYS:7 OR ActivityDate = TODAY)';
                }
            else if(!origenFilter.contains(AV_AppConstants.TASKINICIATIVA_RT)){
                    avQuery = avQuery + ' AND RecordType.DeveloperName  IN ' + AV_AppUtilities.arrayToStringIn(origenFilter);
                avQuery = avQuery + ' AND (ActivityDate = TODAY OR ActivityDate = NEXT_N_DAYS:180)';
            }else{
                    origenFilter.remove(origenFilter.indexOf(AV_AppConstants.TASKINICIATIVA_RT));
                avQuery = avQuery + ' AND ((RecordType.DeveloperName IN ' + AV_AppUtilities.arrayToStringIn(origenFilter) ; 
                avQuery = avQuery + ' AND (ActivityDate = TODAY OR ActivityDate = NEXT_N_DAYS:180)) OR (RecordType.DeveloperName = \'' + AV_AppConstants.TASKINICIATIVA_RT + '\'' ;
                avQuery = avQuery + ' AND (ActivityDate = LAST_N_DAYS:7 OR ActivityDate = TODAY)))';
            }


        }else{
            avQuery = avQuery + ' AND ((RecordType.DeveloperName IN ' + AV_AppUtilities.arrayToStringIn(recordTypeList) ; 
                avQuery = avQuery + ' AND (ActivityDate = TODAY OR ActivityDate = NEXT_N_DAYS:180)) OR (RecordType.DeveloperName = \'' + AV_AppConstants.TASKINICIATIVA_RT + '\'' ;
            avQuery = avQuery + ' AND (ActivityDate = LAST_N_DAYS:7 OR ActivityDate = TODAY)))';
        }
       
            if(isBpr){
                avQuery = avQuery + ' ORDER BY Account.AV_InterlocName__c , Account.AV_Priority__c  DESC, Subject ASC';
            }else{
        avQuery = avQuery + ' ORDER BY Account.AV_Priority__c DESC, Subject ASC';
            }
        AV_LogDebug.printLogDebug(methodName, 'QUERY--> ' + avQuery);

        List<Task> listOfTask = capsulateQuery(avQuery);
        listOfTask = orderTaskByOrigen(listOfTask);

    if(listOfTask != null && !listOfTask.isEmpty()){

        
        for(Task t : listOfTask){

            idSet.add(t.AccountId);
        }
        Map <Id, Account> accountIdObjMap;
        
            Map<Id,AV_GrupoInterlocucion__c> clientGroupMap = new Map<Id,AV_GrupoInterlocucion__c>();

        if(isBpr){
            accountIdObjMap = new Map<Id, Account>([SELECT Name, AV_Negocio__c, AV_Age__c, AV_AhorroEInversion__c, AV_Financiacion__c, AV_Ingresos__c, AV_Preconceived__c, AV_IsPreconceived__c, AV_MyBox__c,AV_TargetAuto__c, AV_Priority__c,AV_Group__c,AV_InterlocName__c
                                                                    FROM Account WHERE Id IN :idSet ORDER BY AV_Priority__c]);

                List<AV_GrupoInterlocucion__c> interlocutionGroup = [SELECT Name, AV_Numper__c, AV_Numper__r.Name, AV_IsInterlocutor__c FROM AV_GrupoInterlocucion__c WHERE AV_Numper__c IN :idSet AND RecordType.DeveloperName =: AV_AppConstants.INTERLOC_GROUP_RT];
                
                
                if(interlocutionGroup != null && !interlocutionGroup.isEmpty()){

                    for(AV_GrupoInterlocucion__c ig : interlocutionGroup){

                        clientGroupMap.put(ig.AV_Numper__c,ig);
                    }
                }                                             

        }else{
            accountIdObjMap = new Map<Id, Account>([SELECT Name, AV_Negocio__c, AV_Age__c, AV_AhorroEInversion__c, AV_Financiacion__c, AV_Ingresos__c, AV_Preconceived__c, AV_IsPreconceived__c, AV_MyBox__c,AV_TargetAuto__c, AV_Priority__c
            FROM Account WHERE Id IN :idSet ORDER BY AV_Priority__c]);
        }
      
        DescribeFieldResult fieldResultStatus = Task.Status.getDescribe();
        DescribeFieldResult fieldResultMyBox = Account.AV_MyBox__c.getDescribe();
        DescribeFieldResult fieldResultTarget = Account.AV_TargetAuto__c.getDescribe();
        DescribeFieldResult fieldResultNegocio = Account.AV_Negocio__c.getDescribe();
        List<Schema.PicklistEntry> picklistValuesStatus = fieldResultStatus.getPicklistValues();
        List<String> picklistValuesOrigen = new List<String>();
        picklistValuesOrigen.add('Alerta Comercial');
        picklistValuesOrigen.add('Experiencia Cliente');
        picklistValuesOrigen.add('Iniciativa Gestor/a');
        picklistValuesOrigen.add('Priorizador');
        picklistValuesOrigen.add('AV_Onboarding');
        List<Schema.PicklistEntry> picklistValuesMyBox = fieldResultMyBox.getPicklistValues();
        List<Schema.PicklistEntry> picklistValuesTarget = fieldResultTarget.getPicklistValues();
        List<Schema.PicklistEntry> picklistValuesNegocio = fieldResultNegocio.getPicklistValues();

        Decimal score = getScore();

        for(Task t: listOfTask){

            TableGroupedByClientWrapper wrapper = new TableGroupedByClientWrapper();
            Account dataAccount = new Account();
            dataAccount = accountIdObjMap.get(t.AccountId);

            if(dataAccount != null){

            
            if( (filterResults.preconcedidoFilterValue != null && filterResults.preconcedidoFilterValue != dataAccount.AV_IsPreconceived__c) 
                || (filterResults.myBoxFilterValue != null && filterResults.myBoxFilterValue != dataAccount.AV_MyBox__c) 
                || (filterResults.targetAutoFilterValue != null && filterResults.targetAutoFilterValue != dataAccount.AV_TargetAuto__c) ){

                    continue;
            }else{
                wrapper.name = dataAccount.Name;
                wrapper.subject = t.Subject;
                wrapper.value1 = t.AV_Valor1__c;
                wrapper.value2 = t.AV_Valor2__c;
                wrapper.expirationDate = t.ActivityDate;
                wrapper.accountId = t.AccountId;
                wrapper.taskId = t.Id;
                wrapper.prio = t.Account.AV_Priority__c;
                if(isBpr){
                    wrapper.groupField = dataAccount.AV_Group__c;
                        wrapper.interlocName = dataAccount.AV_InterlocName__c;
                        wrapper.interlocutionGroup = clientGroupMap.get(dataAccount.Id);
                }
                
               wrapper.origen = t.AV_Origen__c;
                
                String picklistValueStatus = (String) t.get(Task.Status);
                for (Schema.PicklistEntry entry : picklistValuesStatus) {
                    if (entry.getValue().equals(picklistValueStatus)) {
                        wrapper.Status = entry.getLabel();
                        break;
                    }
                }
                
                    wrapper.age = dataAccount.AV_Age__c;
                    if(dataAccount.AV_AhorroEInversion__c != null){
                    wrapper.savingsAndInvestment = dataAccount.AV_AhorroEInversion__c;
                    }
                    if(dataAccount.AV_Financiacion__c != null){
                    wrapper.financing = dataAccount.AV_Financiacion__c;
                    }
                    if(dataAccount.AV_Ingresos__c != null){
                    wrapper.income = dataAccount.AV_Ingresos__c;
                    }
                    if(dataAccount.AV_Preconceived__c != null){
                    wrapper.preApproved = dataAccount.AV_Preconceived__c;
                    }
                
            
                    String picklistValueMyBox = (String) dataAccount.get(Account.AV_MyBox__c);
                    for (Schema.PicklistEntry entry : picklistValuesMyBox) {
                        if (entry.getValue().equals(picklistValueMyBox)) {
                            wrapper.mybox = entry.getLabel();
                            break;
                        }
                    }
                    String picklistValueTarget = (String) dataAccount.get(Account.AV_TargetAuto__c);
                    for (Schema.PicklistEntry entry : picklistValuesTarget) {
                        if (entry.getValue().equals(picklistValueTarget)) {
                            wrapper.targetAuto = entry.getLabel();
                            break;
                        }
                    }
                    String picklistValueNegocio = (String) dataAccount.get(Account.AV_Negocio__c);
                    for (Schema.PicklistEntry entry : picklistValuesNegocio) {
                        if (entry.getValue().equals(picklistValueNegocio)) {
                            wrapper.business = entry.getLabel();
                            break;
                        }
                    }

                

                String picklistValue = (String) t.get(Task.AV_Origen__c);
                for (String entry : picklistValuesOrigen) {
                    if (entry.equals(picklistValue)) {
                        wrapper.origen = entry;
                        break;
                }
                }
                
                

                idAccountsList.add(dataAccount.Id);

                wrapperList.add(wrapper);
            }
        }
        }
        return wrapperList;

    }else{
            return null;
    }
        
    }

    private static List<Task> capsulateQuery(String q){
		return (List<Task>) Database.query(q);
	}

	/**
	* @description     	get score of alerta comercial of task
	*/
    public static Decimal getScore(){
        AV_Score__c scoreTaskAlert = [SELECT AV_Score__c  FROM AV_Score__c WHERE AV_Object__c = 'Task' AND AV_RecordType__c = :AV_AppConstants.TASKALERTACOM_RT LIMIT 1];
        if(scoreTaskAlert != null){
            return scoreTaskAlert.AV_Score__c;
        }else{
            return null;
        }
    }


    /**
	* @description     	order a list of task by Origen 
    * @param task List of Task
	*/
    public static List<Task> orderTaskByOrigen(List<Task> tasks){
        
        Map<Decimal,List<Task>> mapTaskPriority = new Map<Decimal,List<Task>>();
    
        List<Task> result = new List<Task>();
        if(tasks!=null){
            for(Task t:tasks){
                if(mapTaskPriority.keySet().contains(t.Account.AV_Priority__c)){     
                    mapTaskPriority.get(t.Account.AV_Priority__c).add(t);       
                }else{
                    mapTaskPriority.put(t.Account.AV_Priority__c,new List<Task>{t});
                }
            }
            List<String> ordenTareas = new List<String>{'Alerta Comercial', 'Experiencia de Cliente', 'Iniciativa gestor', 'Priorizador', 'Onboarding'};
            Map<String,Integer> orderRt = new Map<String,Integer>{
                AV_AppConstants.TASKALERTACOM_RT=> 1,
                AV_AppConstants.TASKEXPCLIENT_RT=> 2,
                AV_AppConstants.TASKINICIATIVA_RT=> 3,
                AV_AppConstants.TASKPRIORIZADOR_RT=> 4,
                AV_AppConstants.TASKONBOARDING_RT=> 5
            };
            for(Decimal ky : mapTaskPriority.keySet()){
                
                List<Task> tskPrio = mapTaskPriority.get(ky);
                
                if(tskPrio != null && tskPrio.size()>1){
                    List<OrderByRt> listWrapperOrder = new List<OrderByRt>();
                    for(Task tskToOrder : tskPrio){
                        listWrapperOrder.add(new OrderByRt(tskToOrder,orderRt.get(tskToOrder.RecordType.DeveloperName)));
                    }

                    listWrapperOrder.sort();

                    tskPrio.clear();

                    for(OrderByRt order : listWrapperOrder){
                        tskPrio.add(order.tsk);
                    }

                }
            }

            List<Decimal> mapKeysParsedList = new List<Decimal>(mapTaskPriority.keySet());
            mapKeysParsedList.sort();
        


            for(Integer i=mapKeysParsedList.size()-1;i>=0;i--){
                
                result.addAll(mapTaskPriority.get(
                    mapKeysParsedList.get(i)
                        ));
                }
            return result;
        }
        return null;
    }

    private class OrderByRt implements Comparable{
        public Task tsk;
        public Integer order;
    
        public OrderByRt(Task tsk,Integer order){
            this.tsk = tsk;
            this.order = order;
        }

        public Integer compareTo(Object compareTo) {
			OrderByRt compareToEmp = (OrderByRt) compareTo;
			 if (this.order > compareToEmp.order) {
                return 1;
            }
            if (this.order == compareToEmp.order) {
                return 0;
            }
            return -1;        
		}

    }

}