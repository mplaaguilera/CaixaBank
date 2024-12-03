public without sharing class SPV_DatabaseDML { 
    public static void insertDML(SObject objeto, Boolean error){
        
        List<sObject> lstObject = new List<sObject>();
        lstObject.add(objeto);
        insertListDML(lstObject, error);
    }
    
    public static void insertListDML(List<sObject> lstObject, Boolean error){
        
        List<Database.SaveResult> lstResults = Database.insert(lstObject, error);
        crearLog(lstResults, lstObject);
    }
    
	public static void updateDML(SObject objeto, Boolean error){
        
        List<sObject> lstObject = new List<sObject>();
        lstObject.add(objeto);
        updateListDML(lstObject, error);
    }
        
    public static void updateListDML(List<sObject> lstObject, Boolean error){
        
        List<Database.SaveResult> lstResults = Database.update(lstObject, error);
        crearLog(lstResults, lstObject);
    }
    
    public static void upsertDML(SObject objeto, Boolean error){
        
        List<sObject> lstObject = new List<sObject>();
        lstObject.add(objeto);
        upsertListDML(lstObject, error);
    }
      
    public static void upsertListDML(List<sObject> lstObject, Boolean error){
        
        List<Database.UpsertResult> lstResults = Database.upsert(lstObject, error);
        crearUpsertLog(lstResults, lstObject);
    }

    public static void deleteDML(SObject objeto, Boolean error){
        
        List<sObject> lstObject = new List<sObject>();
        lstObject.add(objeto);
        deleteListDML(lstObject, error);
    }
      
    public static void deleteListDML(List<sObject> lstObject, Boolean error){
        
        List<Database.DeleteResult> lstResults = Database.delete(lstObject, error);
        crearDeleteLog(lstResults, lstObject);
    }
    
    public static void crearLog(List<Database.SaveResult> lstResults, List<sObject> lstObject){
        
        String methodName = 'crearLog';
        Boolean hasError = false;
        List<Object> objs = new List<Object>();
        Map<String, String> msjs = new Map<String, String>();
        for (Integer i = 0; i < lstObject.size(); i++) {
            Database.SaveResult sr = lstResults[i];
            if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                msjs.put(methodName, ((String) sr.getErrors()[0].getMessage()));
                objs.add(lstObject[i]);
                hasError = true;
            }
        }
        
        if(hasError) {
            CBK_Log.error(msjs, objs);
        }
    }
    
    public static void crearUpsertLog(List<Database.UpsertResult> lstResults, List<sObject> lstObject){
        
        String methodName = 'crearUpsertLog';
        Boolean hasError = false;
        List<Object> objs = new List<Object>();
        Map<String, String> msjs = new Map<String, String>();
        for (Integer i = 0; i < lstObject.size(); i++) {
            Database.UpsertResult sr = lstResults[i];
            if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                msjs.put(methodName, ((String) sr.getErrors()[0].getMessage()));
                objs.add(lstObject[i]);
                hasError = true;
            }
        }
        
        if(hasError) {
            CBK_Log.error(msjs, objs);
        }
    }

    public static void crearDeleteLog(List<Database.DeleteResult> lstResults, List<sObject> lstObject){
        
        String methodName = 'crearDeleteLog';
        Boolean hasError = false;
        List<Object> objs = new List<Object>();
        Map<String, String> msjs = new Map<String, String>();
        for (Integer i = 0; i < lstObject.size(); i++) {
            Database.DeleteResult sr = lstResults[i];
            if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                msjs.put(methodName, ((String) sr.getErrors()[0].getMessage()));
                objs.add(lstObject[i]);
                hasError = true;
            }
        }
        
        if(hasError) {
            CBK_Log.error(msjs, objs);
        }
    }
}