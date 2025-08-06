public class SEG_Desmarcado_prioridad_Segmentos_Batch implements Database.Batchable<sObject>
{   
    ID recordTypeCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
    ID recordTypeClientePA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
    List<Id> listIdRecordTypeClientes = new List<Id> ();

    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        listIdRecordTypeClientes.add(recordTypeCliente);
        listIdRecordTypeClientes.add(recordTypeClientePA);
        //Date dateSQL = system.today().addDays(-1);
        
        
        return Database.getQueryLocator([SELECT ID, RecordTypeId, AV_OficinaPrincipal__c,SEG_Oficina_Gestora_Segmentos__c,AV_EAPGestor__c,SEG_Empleado_gestor_Segmentos__c,SEG_Prioridad_Carterizacion_Segmentos__c 
        from Account where RecordTypeId in :listIdRecordTypeClientes and SEG_Prioridad_Carterizacion_Segmentos__c=true]);
    }
    public void execute(Database.BatchableContext bc, List<Account> records) 
    {
        List<Account> acc2Upd = new List<Account>();
        for(Account acc : records)
        {
            if((acc.AV_OficinaPrincipal__c==acc.SEG_Oficina_Gestora_Segmentos__c) && (acc.AV_EAPGestor__c==acc.SEG_Empleado_gestor_Segmentos__c))
            {
                acc.SEG_Prioridad_Carterizacion_Segmentos__c=false;
                acc2Upd.add(acc);
            }
            
        }
        if(acc2Upd.size()>0)
        {
            Database.update(acc2Upd);
        }
        
    }
    public void finish(Database.BatchableContext bc) {}
}