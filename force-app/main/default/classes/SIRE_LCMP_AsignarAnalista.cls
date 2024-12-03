/*****************************************************************
 Name:  SIRE_LCMP_AsignarAnalista
 Copyright © 2023  CaixaBank

 Proposito:   Clase controladora externa del LWC Sire_lwc_AsignarAnalista                                                                                                                    

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         19/06/2023    	  Created    
*****************************************************************/
public with sharing class SIRE_LCMP_AsignarAnalista {    

   /*****************************************************************
        @description  Realizamos query para saber el ID                                             
        @param  Ninguno
        @return String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         19/06/2023    	  Created      
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static String getQueryRecordTypeProceso(){
        String idProcesoPreventivo = '';
        if(Schema.SObjectType.RecordType.isAccessible()){
            Map<String,Schema.RecordTypeInfo> mapRTsObjectsProceso = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName();
            idProcesoPreventivo = mapRTsObjectsProceso.get('SIRE_RT_PREVEMP').getRecordTypeId();                                  
        }
        return idProcesoPreventivo;
    }

    /*****************************************************************
        Proposito:  Realizamos query para encontrar la oficina del gestor actual                                                      
        Parameters: 
        Returns: String                                                                
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         19/06/2023    	  Created       
    *****************************************************************/
    @AuraEnabled(Cacheable=true)
	public static String getOficinaGestorActual(){	
        String oficina = '';
        if(Schema.SObjectType.User.isAccessible() && Schema.SObjectType.FinServ__AccountAccountRelation__c.isAccessible()){
            List<User> emp = [SELECT Id, Name, AV_NumeroOficinaEmpresa__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]; 
            String analistaRefi = '';
            if(emp[0].AV_NumeroOficinaEmpresa__c == '001-16998'){
                analistaRefi = 'Si';
                oficina = emp[0].AV_NumeroOficinaEmpresa__c + '*' + '' + '*' + '' + '*' + emp[0].Name + '*' + analistaRefi;
            } else {
                analistaRefi = 'No';
                List<FinServ__AccountAccountRelation__c> cuenta = [SELECT Id, FinServ__Account__c, FinServ__Account__r.Name, FinServ__RelatedAccount__c, FinServ__RelatedAccount__r.Name 
                                                                FROM FinServ__AccountAccountRelation__c 
                                                                WHERE FinServ__Account__r.CC_Numero_Oficina_Empresa__c = : emp[0].AV_NumeroOficinaEmpresa__c
                                                                AND Recordtype.Name = 'Relación CAR-CTO' AND FinServ__Active__c = true
                                                                LIMIT 1];            
                if(!cuenta.isEmpty()){                      
                    oficina = cuenta[0].FinServ__Account__r.Name + '*' + cuenta[0].FinServ__RelatedAccount__c + '*' + cuenta[0].FinServ__RelatedAccount__r.Name + '*' + emp[0].Name + '*' + analistaRefi;
                }
            }          
            
        } 
		return oficina;		
	}


    /*****************************************************************
        Proposito:  Realizamos query para encontrar todas las oficinas DT                                                        
        Parameters: 
        Returns: List<optionsEmployee>                                                                
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0                             Atmira         17/09/2024    	  Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=true)
	public static List<optionsEmployee> getDt(){
        List<optionsEmployee> oficinasDT = new List<optionsEmployee>();
		List<optionsEmployee> oficinasDTSorted = new List<optionsEmployee>();
		List<Id> oficinasDtId = new List<Id>();		
		List<FinServ__AccountAccountRelation__c> dt = new List<FinServ__AccountAccountRelation__c>();								
		if(Schema.SObjectType.FinServ__AccountAccountRelation__c.isAccessible()){
            dt = [SELECT Id, FinServ__Account__c,  FinServ__RelatedAccount__c, FinServ__RelatedAccount__r.Name
                    FROM FinServ__AccountAccountRelation__c
                    WHERE Recordtype.Name = 'Relación CAR-CTO' AND FinServ__Active__c = true and (not FinServ__ExternalId__c like '%_inverse')
                ];
            if(!dt.isEmpty() && dt != null){
                for(FinServ__AccountAccountRelation__c oficinaDtQuery : dt){
                    oficinasDtId.add(oficinaDtQuery.FinServ__RelatedAccount__c);
                    oficinasDTSorted.add(new optionsEmployee(oficinaDtQuery.FinServ__RelatedAccount__c,oficinaDtQuery.FinServ__RelatedAccount__r.Name));
                }
            } 
        }
		oficinasDTSorted.sort();
		oficinasDT.addAll(oficinasDTSorted);
		return oficinasDT;		
	}


    /*****************************************************************
        Proposito:  Realizamos query para encontrar todas las oficinas que puede visualizar por jerarquia/funcion                                                        
        Parameters: String oficina
        Returns: List<optionsEmployee>                                                                
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0                             Atmira         19/06/2023    	  Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=true)
	public static List<optionsEmployee> getOficinas(String idOficina){
        List<optionsEmployee> oficinas = new List<optionsEmployee>();
		List<optionsEmployee> oficinasSorted = new List<optionsEmployee>();
		List<Id> oficinasId = new List<Id>();		
		List<Account> ofi = new List<Account>();								
		if(Schema.SObjectType.Account.isAccessible() && Schema.SObjectType.User.isAccessible()){
            ofi = [SELECT Id, Name FROM Account 
                    WHERE RecordType.DeveloperName ='CC_CentroCaixaBank' AND CC_SubTipo_Centro__c = 'EM' AND
                    (Id = :idOficina
                    OR AV_CentroSuperior__c =: idOficina
                    OR AV_CentroSuperior__r.AV_CentroSuperior__c =: idOficina
                    OR AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c =: idOficina
                    OR AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c =: idOficina
                    OR AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c =: idOficina )
                    ];
            if(!ofi.isEmpty() && ofi != null){
                for(Account oficinaQuery : ofi){
                    oficinasId.add(oficinaQuery.Id);
                    oficinasSorted.add(new optionsEmployee(oficinaQuery.Id,oficinaQuery.Name));
                }
            } 
        }
		oficinasSorted.sort();
		oficinas.addAll(oficinasSorted);
		return oficinas;		
	}

      
    public class OptionsEmployee implements Comparable  {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String label;
        public optionsEmployee(String value, String label){
            this.label = label;
            this.value = value;		
        }
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            optionsEmployee compareToEmp = (optionsEmployee)compareTo;
            if (this.label > compareToEmp.label) {
                return 1;
            }
            if (this.label == compareToEmp.label) {
                return 0;
            }
            return -1;        
        }
    }    
    
    /*****************************************************************
        Proposito:  Realizamos query para encontrar todos los procesos con los filtros pertinentes                                                        
        Parameters: IdAccount
        Returns: List<SIREC__SIREC_obj_proceso__c>                                                                
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0                             Atmira         19/06/2023    	  Created    
    *****************************************************************/    
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> buscarProcesos(String valueSituacion, String valueTipoGestion, String oficina, String valueTipoProceso, String valueAnalista, String analistaRefi, String stageTres) {
        List<SIREC__SIREC_obj_proceso__c> procesos = new List<SIREC__SIREC_obj_proceso__c>(); 
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible() && Schema.SObjectType.User.isAccessible() && Schema.SObjectType.Account.isAccessible()){  
            String soqlQuery = 'SELECT Id, Name, SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_cliente__r.Name, SIREC__SIREC_fld_cliente__r.CC_Numero_Documento__c ,';
            soqlQuery += 'SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__c, SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__r.Name,toLabel(SIR_TipoGestionPREVEMP__c),'; 
            soqlQuery += 'SIREC__SIREC_fld_descEstrategiaCatalogo__c, SIREC__SIREC_fld_fechaInicio__c, toLabel(SIR_fld_Situacion_SF__c), SIR_DeudaTotal__c, SIR_Stage__c,';
            soqlQuery += 'SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__r.SIREC__SIREC_fld_Descripcion__c,';                       
            soqlQuery += 'SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__r.SIREC__SIREC_fld_Codigo__c,';                       
            soqlQuery += 'SIR_AnalistaRiesgo__c, SIR_AnalistaRiesgo__r.Name,';               
            soqlQuery += 'OwnerId,';
            soqlQuery += 'TYPEOF Owner WHEN User THEN Name, AV_NumeroOficinaEmpresa__c ELSE Name END ';                        
            soqlQuery += 'FROM SIREC__SIREC_obj_proceso__c WHERE ';

            if(analistaRefi == 'Si'){
                Set<String> setIdOficinasResultado = new Set<String>();
                List<Account> ofi = [SELECT Id, Name FROM Account 
                        WHERE RecordType.DeveloperName ='CC_CentroCaixaBank' AND CC_SubTipo_Centro__c = 'EM' AND
                        (Id = :oficina
                        OR AV_CentroSuperior__c = : oficina
                        OR AV_CentroSuperior__r.AV_CentroSuperior__c = : oficina
                        OR AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c = : oficina
                        OR AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c = : oficina
                        OR AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c = : oficina )
                        ];
                if(!ofi.isEmpty() && ofi != null){  
                    for(Integer i = 0; i < ofi.size(); i++) {                
                        setIdOficinasResultado.add(ofi[i].Name.substring(0, 5));
                    }
                    soqlQuery += ' SIR_oficina__c in: setIdOficinasResultado AND ';
                } else {
                    String ningunaOfi = 'ningunaOfi';
                    soqlQuery += ' SIR_oficina__c =: ningunaOfi AND ';
                }
            } else {
                soqlQuery += ' SIR_oficina__c =: oficina AND ';
            }
            Integer stage3 = 3;
            if(stageTres == 'si'){
                soqlQuery += ' SIR_Stage__c =: stage3 AND ';
            } else {
                soqlQuery += ' SIR_Stage__c !=: stage3 AND ';
            }
            if(valueSituacion != null){
                Set<String> setSituaciones = new Set<String>();   
                List<String> situacionSplit = valueSituacion.split(',');           
                for (Integer i = 0; i < situacionSplit.size(); i++) {                
                    setSituaciones.add(situacionSplit[i]);
                }
                soqlQuery += 'SIREC__SIREC_fld_situacion__c in: setSituaciones AND ';
            }  
            if(valueTipoGestion != null){
                soqlQuery += 'SIR_TipoGestionPREVEMP__c =: valueTipoGestion AND ';
            } else {
                String tipoGestionNegocioRiesgos = '2';
                String tipoGestionRiesgos = '3';
                soqlQuery += '(SIR_TipoGestionPREVEMP__c =: tipoGestionNegocioRiesgos OR SIR_TipoGestionPREVEMP__c =: tipoGestionRiesgos) AND ';
            }
            String valorEnBlanco = '';
            if(valueAnalista != null && valueAnalista == 'sinAnalista'){
                soqlQuery += 'SIR_AnalistaRiesgo__c = :valorEnBlanco AND ';
            }   
            soqlQuery += 'SIR_AccionActual__c = true AND ';
            String sitFinalizado = 'SF_FINALIZ';
            String procesoObjetivoInformativo = SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO;
            soqlQuery += 'RecordTypeId =: valueTipoProceso AND SIR_ObjetivoProceso__c !=:procesoObjetivoInformativo ';             
            soqlQuery += 'LIMIT 49900';
            List<SObject> resultProcesosFiltro = Database.query(soqlQuery);  
               
            return resultProcesosFiltro;            
        }
        return null;          
    }  

    /*****************************************************************
        Proposito:  Realizamos query para encontrar todos los procesos con los filtros pertinentes                                                        
        Parameters: String[] oficina, String valueTipoProceso
        Returns: List<SIREC__SIREC_obj_proceso__c>                                                                
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0                             Atmira         07/12/2023    	  Created    
    *****************************************************************/    
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> buscarProcesosSinAnalista(String valueSituacion, String oficinasDt, String valueTipoProceso, String analistaRefi) {
        List<SIREC__SIREC_obj_proceso__c> procesos = new List<SIREC__SIREC_obj_proceso__c>(); 
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible() && Schema.SObjectType.User.isAccessible() && Schema.SObjectType.Account.isAccessible()){  
            String soqlQuery = 'SELECT Id, Name, SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_cliente__r.Name, SIREC__SIREC_fld_cliente__r.CC_Numero_Documento__c ,';
            soqlQuery += 'SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__c, SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__r.Name,toLabel(SIR_TipoGestionPREVEMP__c),'; 
            soqlQuery += 'SIREC__SIREC_fld_descEstrategiaCatalogo__c, SIREC__SIREC_fld_fechaInicio__c, toLabel(SIR_fld_Situacion_SF__c), SIR_DeudaTotal__c, SIR_Stage__c,';  
            soqlQuery += 'SIREC__SIREC_fld_informacionCliente__c, SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__c,';  
            soqlQuery += 'SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__r.SIREC__SIREC_fld_Descripcion__c,';                       
            soqlQuery += 'SIREC__SIREC_fld_informacionCliente__r.SIREC__SIREC_fld_CNAECatalogo__r.SIREC__SIREC_fld_Codigo__c,';                     
            soqlQuery += 'SIR_AnalistaRiesgo__c, SIR_AnalistaRiesgo__r.Name,';               
            soqlQuery += 'OwnerId,';
            soqlQuery += 'TYPEOF Owner WHEN User THEN Name, AV_NumeroOficinaEmpresa__c ELSE Name END ';                        
            soqlQuery += 'FROM SIREC__SIREC_obj_proceso__c WHERE ';
            
            if(analistaRefi == 'No'){
                Set<String> setIdOficinas = new Set<String>();   
                List<String> oficinasSplit = oficinasDt.split(',');           
                for (Integer i = 0; i < oficinasSplit.size(); i++) {                
                    setIdOficinas.add(oficinasSplit[i]);
                }
                soqlQuery += ' SIR_oficina__c in :setIdOficinas AND ';
            }
            Integer stage3 = 3;
            if(analistaRefi == 'Si'){
                soqlQuery += ' SIR_Stage__c =: stage3 AND ';
            } else {
                soqlQuery += ' SIR_Stage__c !=: stage3 AND ';
            }
            if(valueSituacion != null){
                Set<String> setSituaciones = new Set<String>();   
                List<String> situacionSplit = valueSituacion.split(',');           
                for (Integer i = 0; i < situacionSplit.size(); i++) {                
                    setSituaciones.add(situacionSplit[i]);
                }
                soqlQuery += 'SIREC__SIREC_fld_situacion__c in: setSituaciones AND ';
            }
            String tipoGestionNegocioRiesgos = '2';
            String tipoGestionRiesgos = '3';
            soqlQuery += '(SIR_TipoGestionPREVEMP__c =: tipoGestionNegocioRiesgos OR SIR_TipoGestionPREVEMP__c =: tipoGestionRiesgos) AND ';
            String valorEnBlanco = '';      
            soqlQuery += 'SIR_AnalistaRiesgo__c = :valorEnBlanco AND SIR_AccionActual__c = true AND ';             
            String procesoObjetivoInformativo = SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO;
            soqlQuery += 'RecordTypeId =: valueTipoProceso AND SIR_ObjetivoProceso__c !=:procesoObjetivoInformativo ';             
            soqlQuery += 'LIMIT 49900';
            List<SObject> resultProcesos = Database.query(soqlQuery); 
            return resultProcesos;            
        }
        return null;          
    }


    /*****************************************************************
        Proposito: Cambiamos los procesos de propietario                                                      
        Parameters: No
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         19/06/2023    	  Created     
    *****************************************************************/                              
    @AuraEnabled
    public static String changeAnalista(Id nuevoAnalista, List<String> procesos) {
        String resultado = '';
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isUpdateable()){        
            List<SIREC__SIREC_obj_proceso__c> procesosQuery = [SELECT Id, SIR_AnalistaRiesgo__c FROM SIREC__SIREC_obj_proceso__c WHERE Id in : procesos];
            for(SIREC__SIREC_obj_proceso__c proceso : procesosQuery){           
                proceso.SIR_AnalistaRiesgo__c = nuevoAnalista;
            } 
            if(!procesosQuery.isEmpty()){
                update procesosQuery; 
                resultado = 'OK';             
            } else {
                resultado = 'KO';
            }
        }
        return resultado;
    } 
    
    /*****************************************************************
        Proposito: Realizamos query                                                      
        Parameters: String searchKey
        Returns: List<sobject>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         26/07/2024     	  Created    
    *****************************************************************/ 
    @AuraEnabled(cacheable=true)  
    public static List<sobject> findRecords(String searchKey) {
        String searchText = '%' + String.escapeSingleQuotes(searchKey) + '%';        
        return [SELECT Id, Name, AV_NumeroOficinaEmpresa__c FROM User WHERE Name LIKE :searchText AND IsActive = true AND
                (AV_tipoGestor__c = 'Riesgo Emp.' OR AV_tipoGestor__c = 'Resp. Coor. Analistas' OR
                CIBE_FuncionEmpleado__c = 'ANALISTA DE RIESGO' OR CIBE_FuncionEmpleado__c = 'ANALISTA SENIOR DE RIESGO' OR
                CIBE_FuncionEmpleado__c = 'DIR.ADM.RIESGO DE LA D.T.' OR CIBE_FuncionEmpleado__c = 'DIRECCION RIESGO EMPRESAS' OR
                AV_NumeroOficinaEmpresa__c = '001-17539')
                LIMIT 10];
            
    }
}