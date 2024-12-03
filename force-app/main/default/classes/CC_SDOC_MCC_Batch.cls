public class CC_SDOC_MCC_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts{
    

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT CC_MCC_Plantilla_Name__c, CC_Id_SDOC_Plantilla__c, CC_MCC__c FROM CC_MCC_Plantilla__c WHERE CC_Id_SDOC_Plantilla__c != '' ORDER BY CC_MCC__c]); 
    }

    public void execute(Database.BatchableContext bc, List<CC_MCC_Plantilla__c> mccPlantillasBuscar) {               
        Set<Id> idMCC = new Set<Id>();
        for(CC_MCC_Plantilla__c mccPlant : mccPlantillasBuscar){
            idMCC.add(mccPlant.CC_MCC__c);
        }
        
        List<CC_MCC_Plantilla__c> mccPlantillas = [SELECT CC_MCC_Plantilla_Name__c, CC_Id_SDOC_Plantilla__c, CC_MCC__c FROM CC_MCC_Plantilla__c WHERE CC_MCC__c IN :idMCC AND CC_Id_SDOC_Plantilla__c !=''];

     	List<CC_MCC__c> listMCC = [SELECT Id, CC_Id_SDOC_Plantilla__c, CC_Id_SDOC_Plantilla2__c, CC_Id_SDOC_Plantilla3__c FROM CC_MCC__c WHERE  Id IN :idMCC AND CC_Id_SDOC_Plantilla__c !=''];
        
        Set<Id> setIdPlantilla = new Set<Id>();
        Boolean first = true;       

        for (CC_MCC__c mcc : listMCC) {
            for (CC_MCC_Plantilla__c mccPlantilla: mccPlantillas) {
                if(first==true && !setIdPlantilla.contains(mccPlantilla.CC_Id_SDOC_Plantilla__c) && mccPlantilla.CC_MCC__c == mcc.Id){
                    // Blanquear los id de la plantilla ya que después se van a rellenar 
                    mcc.CC_Id_SDOC_Plantilla__c = '';
                	mcc.CC_Id_SDOC_Plantilla2__c = '';
                	mcc.CC_Id_SDOC_Plantilla3__c = '';
                    mcc.CC_Id_SDOC_Plantilla__c = mccPlantilla.CC_Id_SDOC_Plantilla__c;
                    first=false;
                    setIdPlantilla.add(mccPlantilla.CC_Id_SDOC_Plantilla__c);
                
                }else if (first==false && !setIdPlantilla.contains(mccPlantilla.CC_Id_SDOC_Plantilla__c) && mccPlantilla.CC_MCC__c == mcc.Id) {
                    String idPlantilla1 = '';
                    String idPlantilla2 = '';
                    String idPlantilla3 = '';

                    if(mcc.CC_Id_SDOC_Plantilla__c != null || mcc.CC_Id_SDOC_Plantilla__c != ''){
                        idPlantilla1 += ',' + mcc.CC_Id_SDOC_Plantilla__c;
                    }
                    if(mcc.CC_Id_SDOC_Plantilla2__c != null || mcc.CC_Id_SDOC_Plantilla2__c != ''){
                        idPlantilla2 += ',' + mcc.CC_Id_SDOC_Plantilla2__c;
                    }  
					if(mcc.CC_Id_SDOC_Plantilla3__c != null || mcc.CC_Id_SDOC_Plantilla3__c != ''){
                        idPlantilla3 += ',' + mcc.CC_Id_SDOC_Plantilla3__c;
                    }  
                    
                    if(idPlantilla1.length() < 234){
                    	mcc.CC_Id_SDOC_Plantilla__c += ',' + mccPlantilla.CC_Id_SDOC_Plantilla__c;
                    }else if(idPlantilla1.length() > 234 && idPlantilla2.length() < 234){
                    	mcc.CC_Id_SDOC_Plantilla2__c += ',' + mccPlantilla.CC_Id_SDOC_Plantilla__c;                    
                    }else if(idPlantilla2.length() > 234 && idPlantilla3.length() < 234){
                    	mcc.CC_Id_SDOC_Plantilla3__c += ',' + mccPlantilla.CC_Id_SDOC_Plantilla__c;
                    }
                    setIdPlantilla.add(mccPlantilla.CC_Id_SDOC_Plantilla__c);
                } 
            }

            if(setIdPlantilla.size() == 0){
                mcc.CC_Id_SDOC_Plantilla__c = ''; mcc.CC_Id_SDOC_Plantilla2__c = ''; mcc.CC_Id_SDOC_Plantilla3__c = '';
            }

            setIdPlantilla.clear();
            first = true;
        }

        update listMCC;
        
    }

    public void finish(Database.BatchableContext bc) {
        String scheduleName = 'Comprobar los id del MCC a partir de la plantilla s-Docs asignada ';
        if(!Test.isRunningTest())
        {   CC_SDOCS_MCC_Batch_Schedule newJob = new CC_SDOCS_MCC_Batch_Schedule();
            String dt = DateTime.now().addHours(24).format('s m H d M ? y');
            String CRON_EXP = string.valueOf(dt);
            System.schedule(scheduleName + dt, CRON_EXP, newJob);        
        }
    }
}