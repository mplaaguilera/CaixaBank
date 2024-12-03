/*****************************************************************
 Name:  SIRE_LCMP_ReassignOwner
 Copyright © 2023  CaixaBank

 Proposito:   Clase controladora externa del LWC Sire_lwc_ReassignOwner                                                                                                                    

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         06/04/2023    	  Created    
*****************************************************************/
public with sharing class SIRE_LCMP_ReassignOwner {    

    /*****************************************************************
        @description  Realizamos query para saber el ID                                             
        @param  Ninguno
        @return List<String>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         06/04/2023    	  Created      
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<String> getQueryRecordTypeProceso(){
        List<String> procesos = new List<String>();
        if(RecordType.SObjectType.getDescribe().isAccessible()){
            Map<String,Schema.RecordTypeInfo> mapRTsObjectsProceso = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName();
            Id rtProcesoPreventivo = mapRTsObjectsProceso.get('SIRE_RT_PREVEMP').getRecordTypeId();
            Id rtProcesoFlujo = mapRTsObjectsProceso.get('SIRE_RT_Amistoso').getRecordTypeId();           
            procesos.add(rtProcesoPreventivo);
            procesos.add(rtProcesoFlujo);                                   
        }
        return procesos;
    }
    /*****************************************************************
        Proposito:  Realizamos query para encontrar la oficina del gestor actual                                                      
        Parameters: 
        Returns: String                                                                
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         06/04/2023    	  Created       
    *****************************************************************/
    @AuraEnabled(Cacheable=true)
	public static String getOficinaGestorActual(){	
        String oficina = '';
        if(User.SObjectType.getDescribe().isAccessible() && Account.SObjectType.getDescribe().isAccessible()){
            List<User> emp = [Select Id, AV_NumeroOficinaEmpresa__c, AV_Funcion__c From User Where Id = :UserInfo.getUserId() LIMIT 1];       
            List<Account> cuenta = [SELECT Id FROM Account Where CC_Numero_Oficina_Empresa__c = :emp[0].AV_NumeroOficinaEmpresa__c LIMIT 1];
            if(!cuenta.isEmpty()){
                oficina = emp[0].AV_NumeroOficinaEmpresa__c + '*' + cuenta[0].Id;
            } 
        }
		return oficina;		
	}
    
    /*****************************************************************
        Proposito:  Realizamos query para encontrar la oficina del gestor actual                                                      
        Parameters: 
        Returns: String                                                                
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         06/04/2023    	  Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=true)
	public static String getOficinaString(Id oficina){	
        String oficinaId = '';
        if(Account.SObjectType.getDescribe().isAccessible()){
            List<Account> cuenta = [SELECT CC_Numero_Oficina_Empresa__c FROM Account Where Id = :oficina LIMIT 1];
            oficinaId = cuenta[0].CC_Numero_Oficina_Empresa__c;
        }
		return oficinaId;		
	}


    /*****************************************************************
        Proposito:  Realizamos query para encontrar todas las oficinas que puede visualizar por jerarquia/funcion                                                        
        Parameters: String oficina
        Returns: List<optionsEmployee>                                                                
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0                             Atmira         06/04/2023    	  Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=true)
	public static List<optionsEmployee> getOficinas(String idOficina){
        List<optionsEmployee> oficinas = new List<optionsEmployee>();
		List<optionsEmployee> oficinasSorted = new List<optionsEmployee>();
		List<Id> oficinasId = new List<Id>();		
		List<Account> ofi = new List<Account>();								
		if(Account.SObjectType.getDescribe().isAccessible() && User.SObjectType.getDescribe().isAccessible()){
            ofi = [SELECT Id, Name FROM Account WHERE Id = :idOficina AND RecordType.DeveloperName ='CC_CentroCaixaBank'];
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

    
	/*****************************************************************
        Proposito:  Realizamos query para encontrar todos empleados de la oficina del gestor actual                                                        
        Parameters: String oficina
        Returns: List<Contract>                                                                
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0                             Atmira         06/04/2023    	  Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<optionsEmployee> getEmployees(String idOficina){
        List<optionsEmployee> employees = new List<optionsEmployee>();
        List<optionsEmployee> employeesSorted = new List<optionsEmployee>();
        List<Id> employeesId = new List<Id>();	
        if(Contact.SObjectType.getDescribe().isAccessible() && User.SObjectType.getDescribe().isAccessible() && Account.SObjectType.getDescribe().isAccessible()){                  
            List<Contact> contactOficinas = [SELECT Id, AV_UsuarioAsociado__c, AV_UsuarioAsociado__r.Name, Account.CC_Numero_Oficina_Empresa__c FROM Contact WHERE AccountId =: idOficina AND AV_UsuarioAsociado__c !=''];
            if(!contactOficinas.isEmpty()){
                for(contact contacto : contactOficinas){
                    employeesId.add(contacto.AV_UsuarioAsociado__c);
                    employeesSorted.add(new optionsEmployee(contacto.AV_UsuarioAsociado__c,contacto.AV_UsuarioAsociado__r.Name + ' (' + contacto.Account.CC_Numero_Oficina_Empresa__c + ')'));
                }
            }
            String employeesAlls=string.join(employeesId,',');
            if(employeesId.size()>1) {
                employees.add(new optionsEmployee('Todos'+','+employeesAlls,'TODOS - CENTRO '));
            }
            employees.add(new optionsEmployee('UserIntegracion','Sin Gestor / Eap - CENTRO '));          
        }
        employeesSorted.sort();
        employees.addAll(employeesSorted);
        return employees;
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
		1.0                             Atmira         06/04/2023    	  Created    
    *****************************************************************/    
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> buscarProcesos(Id clienteId, Date fechaInicio, String valueSituacion, String valueEstrategia, String valueTipoProceso, String valueEmpleado, String oficina) {
        List<SIREC__SIREC_obj_proceso__c> procesos = new List<SIREC__SIREC_obj_proceso__c>(); 
        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible() && User.SObjectType.getDescribe().isAccessible() && Account.SObjectType.getDescribe().isAccessible()){  
            String soqlQuery = 'SELECT Id, Name, SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_cliente__r.Name, SIREC__SIREC_fld_cliente__r.CC_Numero_Documento__c ,';
            soqlQuery += 'SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__c, SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__r.Name,'; 
            soqlQuery += 'toLabel(SIREC__SIREC_fld_estrategia__c), SIREC__SIREC_fld_fechaInicio__c, toLabel(SIR_fld_Situacion_SF__c), SIR_DeudaTotal__c,';                             
            soqlQuery += 'OwnerId, SIREC__SIREC_fld_cliente__r.AV_EAPGestor__r.Name,';
            soqlQuery += 'TYPEOF Owner WHEN User THEN Name, AV_NumeroOficinaEmpresa__c ELSE Name END ';                        
            soqlQuery += 'FROM SIREC__SIREC_obj_proceso__c WHERE ';
            Set<Id> setIdUser = new Set<Id>();   
            Set<Id> setIdUserIntegracion = new Set<Id>(); 
            if(valueEmpleado == 'UserIntegracion' || valueEmpleado.startsWith('Todos')){
                List<User> userIntegracion = [SELECT id, Profile.Name, Name FROM User WHERE Profile.Name LIKE '%API%' ];
                for (User usuario : userIntegracion) {
                    setIdUserIntegracion.add(usuario.Id);
                }
            }
            if(valueEmpleado == 'UserIntegracion'){ 
                soqlQuery += ' OwnerId in :setIdUserIntegracion AND SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__c =: oficina AND '; 
            } else if(valueEmpleado.startsWith('Todos')){                 
                List<String> idsEmpleado = valueEmpleado.split(',');
                for (Integer i = 1; i < idsEmpleado.size(); ++i) {                       
                    setIdUser.add(idsEmpleado[i]);
                }                 
                soqlQuery += ' (OwnerId in :setIdUser OR (OwnerId in :setIdUserIntegracion AND SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__c =: oficina )) AND ';
            } else {
                setIdUser.add(valueEmpleado);
                soqlQuery += ' OwnerId in :setIdUser AND ';
            }

            if(clienteId != null){
                soqlQuery += 'SIREC__SIREC_fld_cliente__c =: clienteId AND ';
            }
            if(fechaInicio != null){
                soqlQuery += 'SIREC__SIREC_fld_fechaInicio__c =: fechaInicio AND ';
            }
            if(valueSituacion != null){
                soqlQuery += 'SIR_fld_Situacion_SF__c =: valueSituacion AND ';
            }
            if(valueEstrategia != null){
                soqlQuery += 'SIREC__SIREC_fld_estrategia__c =: valueEstrategia AND ';
            }
            Set<Id> setIdProceso = new Set<Id>();
            if(valueTipoProceso != null){
                List<String> idsProceso = valueTipoProceso.split(',');
                for (Integer i = 0; i < idsProceso.size(); ++i) {                       
                    setIdProceso.add(idsProceso[i]);
                }
                soqlQuery += 'RecordTypeId in : setIdProceso AND ';
            }             
            
            String sitFinalizado = 'SF_FINALIZ';
            String procesoObjetivoInformativo = SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO;
            soqlQuery += 'SIR_fld_Situacion_SF__c !=: sitFinalizado AND SIR_ObjetivoProceso__c !=:procesoObjetivoInformativo ';             
            soqlQuery += 'LIMIT 49900';
            List<SObject> resultProcesosFiltro = Database.query(soqlQuery);  
               
            return resultProcesosFiltro;            
        }
        return null;          
    }   
    
	/*****************************************************************
        Proposito: Realizamos query                                                      
        Parameters: String searchKey, String oficina
        Returns: List<sobject>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         06/04/2023    	  Created    
    *****************************************************************/ 
    @AuraEnabled(cacheable=true)  
    public static List<sobject> findRecords(String searchKey, String oficina) {
        String searchText = '%' + String.escapeSingleQuotes(searchKey) + '%'; 
        if(oficina == ''){
            return [SELECT Id, Name, AV_NumeroOficinaEmpresa__c FROM User WHERE Name LIKE :searchText AND IsActive = true LIMIT 10];
        } else{
            String oficinaTexto = String.escapeSingleQuotes(oficina);
            return [SELECT Id, Name, AV_NumeroOficinaEmpresa__c FROM User WHERE Name LIKE :searchText AND AV_NumeroOficinaEmpresa__c = :oficinaTexto AND IsActive = true LIMIT 10];
        }     
    }     
    
    /*****************************************************************
        Proposito: Cambiamos los procesos de propietario                                                      
        Parameters: No
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         06/04/2023    	  Created     
    *****************************************************************/                              
    @AuraEnabled
    public static String changeGestor(Id nuevoGestor, List<String> procesos) {
        String resultado = '';
        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isUpdateable()){        
            List<SIREC__SIREC_obj_proceso__c> procesosQuery = [SELECT Id, OwnerId FROM SIREC__SIREC_obj_proceso__c WHERE Id in : procesos];
            for(SIREC__SIREC_obj_proceso__c proceso : procesosQuery){           
                proceso.OwnerId = nuevoGestor;
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
}