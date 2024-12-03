public class CIBE_TaskTriggerHelperSharing {
    /**
* @description		 Calculo del Score a partir del RT de la task proviniente del Insert
* @param  listData   list of new Task records trigger
* @param origen		 contains the origin of the call
*/
    public static void calculateScoreTask(List<Task> listData, String origen){
        
        List<AV_Score__c> listScoresMetadata =[select id,AV_Active__c, AV_Object__c, Name,AV_RecordType__c, AV_Score__c from AV_Score__c where AV_Active__c = true ];
        System.debug('listScoresMetadata -->'+listScoresMetadata);
        
        Map<String, Decimal> mapListScoresMDT=new Map<String, Decimal>();
        List<String> listIdRT=new List<String>();
        for(AV_Score__c mdtScores:listScoresMetadata){
            mapListScoresMDT.put(mdtScores.AV_RecordType__c, mdtScores.AV_Score__c);
            listIdRT.add(mdtScores.AV_RecordType__c);
        }
        System.debug('listIdRT -->'+listIdRT);
        
        
        List<RecordType> listRT= [Select Id, developername from RecordType where developername IN  :listIdRT];
        Map<Id,RecordType> mapRT = new  Map<Id,RecordType>(listRT);
        List<ID> listIdAccounts=new List<Id>();
        List<Task> newListData=new List<Task>();
        System.debug('mapRT -->'+mapRT);
        System.debug('listData.dataTask.RecordTypeId -->'+listData[0].RecordTypeId);
        
        
        for(Task dataTask:listData){
            if(mapRT.get(dataTask.RecordTypeId)!=null){
                newListData.add(dataTask);
                if(!listIdAccounts.contains(dataTask.AccountId)){
                    listIdAccounts.add(dataTask.AccountId);
                }
            }
        }  
        
        
        List<Account> listAccounts= [Select id,AV_Priority__c from Account where id IN :listIdAccounts];
        Map<Id,Account> mapAccount = new  Map<Id,Account>(listAccounts);
        Map<Id,Account> mapAccToUpdate=new Map<Id,Account>();
        
        switch on origen {
            when 'insert' {
                scoreTaskAftInsert(newListData,mapAccToUpdate,mapAccount,mapRT,mapListScoresMDT);
            }
            when 'update' {
                scoreTaskAftUpdate(newListData,mapAccToUpdate,mapAccount,mapRT,mapListScoresMDT);
            }
            when 'delete' {
                scoreTaskAftDelete(newListData,mapAccToUpdate,mapAccount,mapRT,mapListScoresMDT);
            }
            
        }
    }
    
    private static void scoreTaskAftInsert(List<Task> listData,Map<Id,Account> mapAccToUpdate,Map<Id,Account> mapAccount,Map<Id,RecordType> mapRT,Map<String, Decimal> mapListScoresMDT){
        List<CBK_Activity_Extension__c> listActExtToUpdate=new List<CBK_Activity_Extension__C>();
        List<String> listIdString=new List<String>();
        for(Task tsk: listData){
            listIdString.add(String.ValueOf(tsk.id));
        }
        List<CBK_Activity_Extension__c> listActExt=[select Id,AV_ActivityId__c, AV_Scoring__c from CBK_Activity_Extension__c where AV_ActivityId__c IN:listIdString ];    
        Map<Id,CBK_Activity_Extension__c>mapTaskActivityEx = new Map<Id,CBK_Activity_Extension__c>();
        
        for(CBK_Activity_Extension__c ae:listActExt){
            mapTaskActivityEx.put(ae.AV_ActivityId__c,ae);
        }
        
        for(Task dataTask:listData){ 
            if(dataTask.Status!=CIBE_AppConstants.GESTIONADO_POSITIVO_ESTADO && dataTask.Status!=CIBE_AppConstants.GESTIONADO_NEGATIVA_ESTADO && dataTask.Status!=CIBE_AppConstants.GESTIONADO_NO_LOCALIZADO && dataTask.Status!=CIBE_AppConstants.NO_GESTIONADA ){
                if(!mapAccToUpdate.containsKey(dataTask.AccountId) && !mapAccount.isEmpty()){
                    Account acc=new Account();
                    acc.Id=dataTask.AccountId;
                    acc.AV_Priority__c=mapAccount.get(dataTask.AccountId).AV_Priority__c!=null?mapAccount.get(dataTask.AccountId).AV_Priority__c:0;
                    mapAccToUpdate.put(acc.Id,acc);
                }
                
                CBK_Activity_Extension__c actExt=new CBK_Activity_Extension__c(); 
                if(mapTaskActivityEx.get(dataTask.Id)!=null){
                    actExt.Id=mapTaskActivityEx.get(dataTask.Id).Id;
                }else{
                    actExt.AV_ActivityId__c=String.valueOf(dataTask.Id);
                }
                
                actExt.AV_Scoring__c=mapListScoresMDT.get(mapRT.get(dataTask.RecordtypeId).developername); 
                if(mapRT.get(dataTask.RecordtypeId).DeveloperName.equals(CIBE_AppConstants.TASK_PRIORIZADOS_CIB_RT) && dataTask.AV_PrioritizingSort__c != null || mapRT.get(dataTask.RecordtypeId).DeveloperName.equals(CIBE_AppConstants.TASK_PRIORIZADOS_EMP_RT) && dataTask.AV_PrioritizingSort__c != null){
                    actExt.AV_Scoring__c+=dataTask.AV_PrioritizingSort__c;                  
                }
                
                listActExtToUpdate.add(actExt);
                if(mapAccount!=null && !mapAccount.isEmpty()){
                    mapAccToUpdate.get(dataTask.AccountId).AV_Priority__c+=actExt.AV_Scoring__c;
                }
            }
        }
        if(!mapAccToUpdate.isEmpty()){
            update mapAccToUpdate.values();
        }
        
        if(!listActExtToUpdate.isEmpty()){
            upsert listActExtToUpdate;
        }
    }
    
    private static void scoreTaskAftUpdate(List<Task> listData,Map<Id,Account> mapAccToUpdate,Map<Id,Account> mapAccount,Map<Id,RecordType> mapRT,Map<String, Decimal> mapListScoresMDT ){
        List<CBK_Activity_Extension__c> listActExtToUpdate=new List<CBK_Activity_Extension__C>();
        Map<String, CBK_Activity_Extension__c> mapActExt=new Map<String,CBK_Activity_Extension__c>();
        List<String> listIdString=new List<String>();
        for(Task tsk: listData){
            listIdString.add(String.ValueOf(tsk.id));
        }
        List<CBK_Activity_Extension__c> listActExt=[select Id,AV_ActivityId__c, AV_Scoring__c from CBK_Activity_Extension__c where AV_ActivityId__c IN:listIdString ];
        if(!listActExt.isEmpty()){
            for(CBK_Activity_Extension__c actExt:listActExt){
                mapActExt.put(actExt.AV_ActivityId__c,actExt);            
            }
        }
        Map<Id,Account> listAccToUpdate=new Map<Id,Account>();
        for(Task dataTask:listData){
            if(CIBE_AppConstants.GESTIONADO_POSITIVO_ESTADO.equals(dataTask.Status) || CIBE_AppConstants.GESTIONADO_NEGATIVA_ESTADO.equals(dataTask.Status) || CIBE_AppConstants.GESTIONADO_NO_LOCALIZADO.equals(dataTask.Status) || CIBE_AppConstants.NO_GESTIONADA.equals(dataTask.Status)){
                CBK_Activity_Extension__c actExt=new CBK_Activity_Extension__c();
                // if(mapAccToUpdate.containsKey(dataTask.AccountId) && mapAccount!=null && !mapAccount.isEmpty()){
                if(!mapAccToUpdate.containsKey(dataTask.AccountId) && mapAccount!=null && !mapAccount.isEmpty()){
                    Account acc=new Account(); 
                    acc.Id=dataTask.AccountId;
                    acc.AV_Priority__c=mapAccount.get(dataTask.AccountId).AV_Priority__c!=null?mapAccount.get(dataTask.AccountId).AV_Priority__c:0;
                    mapAccToUpdate.put(acc.Id,acc);
                }
                if(!mapActExt.isEmpty() && mapActExt.get(dataTask.id) != null){
                    actExt.Id=mapActExt.get(dataTask.id).id;
                    actExt.AV_Scoring__c=(mapActExt.get(dataTask.id).AV_Scoring__c!=null?mapActExt.get(dataTask.id).AV_Scoring__c:0);
                    listActExtToUpdate.add(actExt);
                }
                if(mapAccount!=null && !mapAccount.isEmpty() && mapAccToUpdate.get(dataTask.AccountId).AV_Priority__c!=0 && mapAccToUpdate.get(dataTask.AccountId).AV_Priority__c!=null && actExt.AV_Scoring__c != null){
                    mapAccToUpdate.get(dataTask.AccountId).AV_Priority__c-=actExt.AV_Scoring__c;
                }
            }
        }        
        if(!mapAccToUpdate.isEmpty()){
            update mapAccToUpdate.values();
        }
        if(!listActExtToUpdate.isEmpty()){
            upsert listActExtToUpdate;
        }      
    }
    
    private static void scoreTaskAftDelete(List<Task> listData,Map<Id,Account> mapAccToUpdate,Map<Id,Account> mapAccount,Map<Id,RecordType> mapRT,Map<String, Decimal> mapListScoresMDT){
        List<String> listIdString=new List<String>();
        Map<String, CBK_Activity_Extension__c> mapActExt=new Map<String,CBK_Activity_Extension__c>();
        for(Task tsk: listData){
            listIdString.add(String.ValueOf(tsk.id));
        }
        List<CBK_Activity_Extension__c> listActExt= [select Id,AV_ActivityId__c, AV_Scoring__c from CBK_Activity_Extension__c where AV_ActivityId__c IN:listIdString ];
        if(!listActExt.isEmpty()){
            for(CBK_Activity_Extension__c actExt:listActExt){
                mapActExt.put(actExt.AV_ActivityId__c,actExt);            
            }
        }
        if(!listActExt.isEmpty()){
            delete listActExt;
        }
        CBK_Activity_Extension__c actExt=new CBK_Activity_Extension__c();
        for(Task dataTask:listData){
            if(!CIBE_AppConstants.GESTIONADO_POSITIVO_ESTADO.equals(dataTask.Status) && !CIBE_AppConstants.GESTIONADO_NEGATIVA_ESTADO.equals(dataTask.Status) && !CIBE_AppConstants.GESTIONADO_NO_LOCALIZADO.equals(dataTask.Status) && !CIBE_AppConstants.NO_GESTIONADA.equals(dataTask.Status)){	           
                if(!mapAccToUpdate.containsKey(dataTask.AccountId) && mapAccount!=null && !mapAccount.isEmpty()){
                    Account acc=new Account();
                    acc.Id=dataTask.AccountId;
                    acc.AV_Priority__c=mapAccount.get(dataTask.AccountId).AV_Priority__c!=null?mapAccount.get(dataTask.AccountId).AV_Priority__c:0;
                    mapAccToUpdate.put(acc.Id,acc);
                }
                if(!mapActExt.isEmpty() && mapActExt.get(dataTask.id) != null){
                    actExt.Id=mapActExt.get(dataTask.id).id;
                    actExt.AV_Scoring__c=(mapActExt.get(dataTask.id).AV_Scoring__c!=null?mapActExt.get(dataTask.id).AV_Scoring__c:0);
                }
                if( mapAccount!=null && !mapAccount.isEmpty() && mapAccToUpdate.get(dataTask.AccountId).AV_Priority__c!=0 && mapAccToUpdate.get(dataTask.AccountId).AV_Priority__c!=null && actExt.AV_Scoring__c != null){
                    mapAccToUpdate.get(dataTask.AccountId).AV_Priority__c-=actExt.AV_Scoring__c;
                }
            }
        }
        if(!mapAccToUpdate.isEmpty()){
            update mapAccToUpdate.values();
        }
    }
}