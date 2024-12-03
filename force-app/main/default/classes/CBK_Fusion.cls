/**
 * @description Helper del Framework de procesos Apex Batch
 */
public without sharing class CBK_Fusion {
    /** @description objeto retorno fusión */
    public class resExec{
       @AuraEnabled public String resultado { get; set; }
       @AuraEnabled public Boolean error { get; set; }
    }
    
    /** @description applicationExceptionntidad fusión */
    public class ApplicationException extends Exception {}

    /**
     * @description Fusión de entidades
     * @param idFusion  : Id del la entidad fusión
     */
    @AuraEnabled 
    public static resExec exec(string idFusion){   
        string resultado='';
        boolean error=false;

        list<CBK_Fusion__c> fus = [select Id, Config__c ,Tipo__c, Id_Principal__c, ID_Secundario__c, Entidad__c, Pendiente__c,ApexClass__c,resultado__c,error__c from CBK_Fusion__c  where Pendiente__c=true and Id= :idFusion LIMIT 1];
        try {
            if (fus.size()==1){
                if (string.IsNotBlank(fus[0].Config__c)) {
                    string confName = fus[0].Config__c; 
                    list<CBK_Fusion_Entidad__mdt> conf = [Select Id, DeveloperName, Entidad__c, Tipo__c, ApexClass__c 
                                                            from CBK_Fusion_Entidad__mdt where DeveloperName=:confName];
                    if (conf.size()>0){
                        fus[0].Tipo__c=conf[0].Tipo__c;
                        fus[0].ApexClass__c=conf[0].ApexClass__c;  
                        fus[0].Entidad__c=conf[0].Entidad__c;  
                    } else {
                        throw new applicationException('No existe la configuración '+ fus[0].Config__c);
                    }
                }   
                switch on fus[0].Tipo__c {
                    when 'Merge' {
                        cambioRT(fus[0]);
                        fusion_merge(fus[0]);       //Include fields desde metadata
                    }	
                    when 'Merge_Fields' {
                        cambioRT(fus[0]);
                        fusion_merge_Fields(fus[0]); //Include fields desde metadata
                    }
                    when 'Merge_NULLS' {
                        cambioRT(fus[0]);
                        fusion_merge_Nulls(fus[0]);  //Exclude fields desde metadata
                    }
                    when 'APEX' {
                        fusion_merge_Apex(fus[0]);
                    }               
                    when else {
                        fus[0].error__c = true;
                        fus[0].Pendiente__c = false;
                        fus[0].resultado__c = 'Método de fusión no válido';
                    }
                }
                resultado=fus[0].resultado__c;
                error =fus[0].error__c;
            } else {
                resultado = 'No exixte registro pendiente de procesar';
                error = true;
            }
            
        } catch (Exception e) {
                resultado =  e.getMessage();
            	error=true;
           		CBK_Log.error(e);
                fus[0].error__c = true;
            	fus[0].Pendiente__c = false;
                fus[0].resultado__c = resultado;
        }
        update fus;
        
        resExec res = new resExec();
        res.resultado = resultado;
        res.error = error;
        return res;
    }

    /**
     * @description Fusión de entidades con merge estándar
     * @param dus: Obj del la entidad fusión
     */
    public static void fusion_merge(CBK_Fusion__c fus){ 
        string idPri = fus.Id_Principal__c;
		string isSec = fus.Id_Secundario__c;        
        list<SObject> principal  = Database.query('SELECT Id FROM ' + String.escapeSingleQuotes(fus.Entidad__c) + ' WHERE Id = :idPri LIMIT 1');
        list<SObject> secundario = Database.query('SELECT Id FROM ' + String.escapeSingleQuotes(fus.Entidad__c) + ' WHERE ID = :isSec LIMIT 1');
        
        if (principal.size()==0) {
			fus.resultado__c ='No existe el Id Principal';
            fus.Error__c=true;
            fus.Pendiente__c=false;
        } else if (secundario.size()==0){
			fus.resultado__c ='No existe el Id Secundario';  
            fus.Error__c=true;
            fus.Pendiente__c=false;            
        } else {
            fusion_core(fus,principal[0],secundario[0]);    
        }
        
    }
      

    /**
     * @description Fusión de entidades con merge estándar con selecion custom de campos
     * @param dus: Obj del la entidad fusión
     */
    public static void fusion_merge_Fields(CBK_Fusion__c fus){ 
        string idPri = fus.Id_Principal__c;
		string isSec = fus.Id_Secundario__c;
        
        boolean isPersonAccount = false;
        if (fus.Entidad__c=='Account'){
            isPersonAccount = [Select isPersonAccount from Account WHERE Id = :idPri LIMIT 1].isPersonAccount;
        }
        
        SObjectType objectType = Schema.getGlobalDescribe().get(fus.Entidad__c);
        Map<String,Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        List<string>  fields = new List<string>();

        fields.add('Id');
        list<string> incluir = new list<string>();
        if (fus.Config__c!='') {
            string confName = fus.Config__c; 
            for(CBK_Fusion_Fields__mdt ifield : [select Id,Label from CBK_Fusion_Fields__mdt where Fusion_de_Entidades__r.DeveloperName=:confName]){
                incluir.add(ifield.Label.toLowercase());
                system.debug('-----' + ifield.Label );
            }
        }
        //FILTRAR POR CAMPOS CONTENIDOS EN EL METADATA
        for (String fieldName : fieldMap.keySet()) {
            if ((fieldMap.get(fieldName).getDescribe().isUpdateable()) && 
                !(fieldMap.get(fieldName).getDescribe().isNameField()) &&  
                (fieldName.right(4)!='__pc' || isPersonAccount) &&
                (incluir.contains(fieldName))){
                fields.add(fieldName);
            }
            else {
                system.debug(fieldName);
                system.debug(fieldMap.get(fieldName).getDescribe().isUpdateable());
                system.debug(fieldMap.get(fieldName).getDescribe().isNameField());
            }
        }

        string txtQuery = 'SELECT ' + string.join(fields,', ') + ' FROM ' + fus.Entidad__c;
        system.debug (txtQuery);
        
        list<SObject> principal  = Database.query(String.escapeSingleQuotes(txtQuery) + ' WHERE Id = :idPri LIMIT 1');
        list<SObject> secundario = Database.query(String.escapeSingleQuotes(txtQuery) + ' WHERE Id = :isSec LIMIT 1');

        if (principal.size()==0) {
			fus.resultado__c ='No existe el Id Principal';
            fus.Error__c=true;
        } else if (secundario.size()==0){
			fus.resultado__c ='No existe el Id Secundario';            
        } else {
            for (string f : fields){
                if ((principal[0].get(f) == null) && (secundario[0].get(f) != null)) {
                    system.debug(f + ': ' + principal[0].get(f) + '<---->' + secundario[0].get(f));
                    principal[0].put(f,secundario[0].get(f));
                }
            }
            fusion_core(fus,principal[0],secundario[0]);  
        }
    }


    /**
     * @description Fusión de entidades con merge estándar con copia automática de campos no nulos en el secundario
     * @param dus: Obj del la entidad fusión
     */
    public static void fusion_merge_Nulls(CBK_Fusion__c fus) { 
        string idPri = fus.Id_Principal__c;
		string isSec = fus.Id_Secundario__c;
        
		boolean isPersonAccount = false;
        if (fus.Entidad__c=='Account'){
            isPersonAccount = [Select isPersonAccount from Account WHERE Id = :idPri LIMIT 1].isPersonAccount;
        }
        SObjectType objectType = Schema.getGlobalDescribe().get(fus.Entidad__c);
        Map<String,Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        List<string>  fields = new List<string>();

        fields.add('Id');
        list<string> excluir = new list<string>();
        if (fus.Config__c!='') {
            string confName = fus.Config__c; 
            for(CBK_Fusion_Fields__mdt ifield : [select Id,Label from CBK_Fusion_Fields__mdt where Fusion_de_Entidades__r.DeveloperName=:confName]){
                excluir.add(ifield.Label);
            }
        }
        excluir.add('ispartner');

        for (String fieldName : fieldMap.keySet()) {
            if ((fieldMap.get(fieldName).getDescribe().isUpdateable()) && 
                !(fieldMap.get(fieldName).getDescribe().isNameField()) && 
                (fieldName.right(4)!='__pc' || isPersonAccount) &&
                !(excluir.contains(fieldName))) {
                fields.add(fieldName);
            }
        }
        //Exclude fields desde metadata --> Eliminar del map valores
        

        string txtQuery = 'SELECT ' + string.join(fields,', ') + ' FROM ' + fus.Entidad__c;
        system.debug (txtQuery);
        
        SObject principal  = Database.query(String.escapeSingleQuotes(txtQuery) + ' WHERE Id = :idPri LIMIT 1');
        SObject secundario = Database.query(String.escapeSingleQuotes(txtQuery) + ' WHERE Id = :isSec LIMIT 1');
        
        for (string f : fields){
            if ((principal.get(f) == null) && (secundario.get(f) != null)) {
                system.debug(f + ': ' + principal.get(f) + '<---->' + secundario.get(f));
                principal.put(f,secundario.get(f));
            }
        }
        
        fusion_core(fus,principal,secundario);
        
    }
    
    /**
     * @description Fusión de entidades con merge estándar con copia automática de campos no nulos en el secundario
     * @param dus: Obj del la entidad fusión
     */
     public static void fusion_merge_Apex(CBK_Fusion__c fus) { 
        final String className = fus.ApexClass__c;
        final String methodName = 'exec';
         
         list<ApexClass> lstClass = [SELECT ID,Name FROM ApexClass WHERE NAME=:className];
         if (lstClass.size()>0){
            // Obtain callable interface (this instantiates the class, but since the class has only one-non static member there's no overhead):
            Callable c = (Callable) Type.forName(className).newInstance();
             
            Object o = c.call(
                    methodName,               // objects
                    new Map<String, Object> { // argument map
                            'reg' => fus
                    });
			fus.error__c = !((boolean)o);
             
         } else {
             fus.resultado__c ='No existe la clase seleccionada';
             fus.error__c = true;
         }
		
         fus.Pendiente__c = false;         
     }

    /**
     * @description Moculo centralizado de fusión
     * @param dus: Obj del la entidad fusión
     */
    public static void fusion_core(CBK_Fusion__c fus,Object principal,Object secundario){ 
        string resultado='Registro fusionado correctamente';
//		if (resultado==''){
            try { 
                switch on fus.Entidad__c {
                    when 'Account' {
                        Account accPrincipal = (Account)principal;
                        Account accSecundario = (Account)secundario;
                        merge AccPrincipal AccSecundario;
                        fus.error__c = false;
                        fus.resultado__c='';
                    }	
                    when else {
                        resultado =  'Entidad no fusionable';
                        fus.error__c = true;
                    }
                }
            } catch (Exception e) {
                resultado =  e.getMessage();
                CBK_Log.error(e);
                fus.error__c = true;
            }            
//        }   
        fus.Pendiente__c = false;
        fus.resultado__c = resultado;
    }
    
    /**
     * @description Cambio de RT en secundario para alinearlo con el principal
     * @param fus: Obj del la entidad fusión
     */

    public static void cambioRT(CBK_Fusion__c fus){
        string idPri = fus.Id_Principal__c;
		string idSec = fus.Id_Secundario__c;
        switch on fus.Entidad__c {
            when 'Account' {
				list<Account> principal  = [SELECT Id,isPersonAccount,RecordTypeId FROM Account WHERE Id = :idPri LIMIT 1];
                list<Account> secundario = [SELECT Id,isPersonAccount,RecordTypeId FROM Account WHERE Id = :idSec LIMIT 1];

                if ((principal.size()==1) && (secundario.size()==1) && principal[0].isPersonAccount && !secundario[0].isPersonAccount)	{
                    secundario[0].RecordTypeId = principal[0].RecordTypeId;
                    update secundario[0];
                }	            
            }
        }
    }

}