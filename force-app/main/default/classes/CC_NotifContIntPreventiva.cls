public class CC_NotifContIntPreventiva extends CBK_SCH_Queueable_Abstract  {
    public override void execute(QueueableContext ctx) {
        List<CBK_SCH_PendingProcess__c> incomingPendingProcessList = this.lstInfoProcess;
        work(incomingPendingProcessList);
    }

    private void work(List<CBK_SCH_PendingProcess__c> incomingPendingProcessList) {  
        String methodName = 'work';
        Set<Id> pendingProcessCaseIdSet = new Set<Id>();
        for(CBK_SCH_PendingProcess__c pendingProcess: incomingPendingProcessList){
            pendingProcessCaseIdSet.add(pendingProcess.RecordId__c);
        }

        if (!pendingProcessCaseIdSet.isEmpty()) {
            if (pendingProcessCaseIdSet.size() > 0){
                List<ID> oIDList = new List<ID>(pendingProcessCaseIdSet);
                Integer j = 1;
                Map<Integer,List<ID>> oMap = new Map<Integer,List<ID>>();
                for (Integer i=0;i<oIDList.size();i++){
                    if (j > 50) {
                        j = 1;
                    }
    
                    // Inicializar listas.
                    if (oMap.get(j) == null){
                        List<ID> oSet = new List<ID>();
                        oMap.put(j,oSet);
                    }
    
                    // Añadir valor.
                    oMap.get(j).add(oIDList[i]);
    
                    j = j + 1;
                }
    
                // Lanzar llamadas Futuras.
                
                for (Integer i : oMap.keySet()){
                    CC_NotifSegCaso.gestionarBatchNotificacionCliente (oMap.get(i), 'CC_Contacto_Intermedio_Preventivas');
                }
    
                oIDList.clear();
                oIDList = null;
    
                oMap.clear();
                oMap = null;
            }
    
            pendingProcessCaseIdSet.clear();
            pendingProcessCaseIdSet = null;
        }
    }
	/*
        Método para enviar contacto intermedio para Preventiva en la creación de casos.
    */
    @InvocableMethod(label='Contacto Intermedio Preventiva' description='Contacto Intermedio Preventiva')
    static public void gestionarContactoInermedioPreventiva (List<ID> oIDs){
        // Gestionar notificaciones para el acuse.

        // Quitar duplicados.
        Set<ID> pendingProcessCaseIdSet = new Set<ID>(oIDs);

        // Lanzamos un máximo de 50 con las llamadas repartidas (límite Hard).
        if (pendingProcessCaseIdSet.size() > 0){
            List<ID> oIDList = new List<ID>(pendingProcessCaseIdSet);
            Integer j = 1;
            Map<Integer,List<ID>> oMap = new Map<Integer,List<ID>>();
            for (Integer i=0;i<oIDList.size();i++){
                if (j > 50) {
                    j = 1;
                }

                // Inicializar listas.
                if (oMap.get(j) == null){
                    List<ID> oSet = new List<ID>();
                    oMap.put(j,oSet);
                }

                // Añadir valor.
                oMap.get(j).add(oIDList[i]);

                j = j + 1;
            }

            // Lanzar llamadas Futuras.
            
            for (Integer i : oMap.keySet()){
                CC_NotifSegCaso.gestionarBatchNotificacionCliente (oMap.get(i), 'CC_Contacto_Intermedio_Preventivas');
            }

            oIDList.clear();
            oIDList = null;

            oMap.clear();
            oMap = null;
        }

        pendingProcessCaseIdSet.clear();
        pendingProcessCaseIdSet = null;
    }
}