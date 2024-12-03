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
        if(RecordType.SObjectType.getDescribe().isAccessible()){
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
        if(User.SObjectType.getDescribe().isAccessible() && FinServ__AccountAccountRelation__c.SObjectType.getDescribe().isAccessible()){
            List<User> emp = [SELECT Id, AV_NumeroOficinaEmpresa__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];  
            List<FinServ__AccountAccountRelation__c> cuenta = [SELECT Id, FinServ__Account__c, FinServ__Account__r.Name, FinServ__RelatedAccount__c, FinServ__RelatedAccount__r.Name 
                                                                FROM FinServ__AccountAccountRelation__c 
                                                                WHERE FinServ__Account__r.CC_Numero_Oficina_Empresa__c = : emp[0].AV_NumeroOficinaEmpresa__c
                                                                AND Recordtype.Name = 'Relación CAR-CTO' AND FinServ__Active__c = true
                                                                LIMIT 1];            
            if(!cuenta.isEmpty()){
                oficina = cuenta[0].FinServ__Account__r.Name + '*' + cuenta[0].FinServ__RelatedAccount__c + '*' + cuenta[0].FinServ__RelatedAccount__r.Name;
            }
        }
		return oficina;		
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
		if(Account.SObjectType.getDescribe().isAccessible() && User.SObjectType.getDescribe().isAccessible()){
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

    
	/*****************************************************************
        Proposito:  Realizamos query para encontrar todos empleados de la oficina del gestor actual                                                        
        Parameters: String oficina
        Returns: List<Contract>                                                                
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0                             Atmira         19/06/2023    	  Created    
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
		1.0                             Atmira         19/06/2023    	  Created    
    *****************************************************************/    
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> buscarProcesos(String valueSituacion, String valueEstrategia, String valueEmpleado, String valueTipoGestion, String oficina, String valueTipoProceso) {
        List<SIREC__SIREC_obj_proceso__c> procesos = new List<SIREC__SIREC_obj_proceso__c>(); 
        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible() && User.SObjectType.getDescribe().isAccessible() && Account.SObjectType.getDescribe().isAccessible()){  
            String soqlQuery = 'SELECT Id, Name, SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_cliente__r.Name, SIREC__SIREC_fld_cliente__r.CC_Numero_Documento__c ,';
            soqlQuery += 'SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__c, SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__r.Name,'; 
            soqlQuery += 'toLabel(SIREC__SIREC_fld_estrategia__c), SIREC__SIREC_fld_fechaInicio__c, toLabel(SIR_fld_Situacion_SF__c), SIR_DeudaTotal__c,';                       
            soqlQuery += 'SIR_AnalistaRiesgo__c, SIR_AnalistaRiesgo__r.Name,';               
            soqlQuery += 'OwnerId,';
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
            
            if(valueSituacion != null){
                soqlQuery += 'SIR_fld_Situacion_SF__c =: valueSituacion AND ';
            }
            if(valueEstrategia != null){
                soqlQuery += 'SIREC__SIREC_fld_estrategia__c =: valueEstrategia AND ';
            }  
            if(valueTipoGestion != null){
                soqlQuery += 'SIR_TipoGestionPREVEMP__c =: valueTipoGestion AND ';
            } else {
                String tipoGestionNegocioRiesgos = '2';
                String tipoGestionRiesgos = '3';
                soqlQuery += '(SIR_TipoGestionPREVEMP__c =: tipoGestionNegocioRiesgos OR SIR_TipoGestionPREVEMP__c =: tipoGestionRiesgos) AND ';
            }

            String sitFinalizado = 'SF_FINALIZ';
            String procesoObjetivoInformativo = SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO;
            soqlQuery += 'RecordTypeId =: valueTipoProceso AND SIR_fld_Situacion_SF__c !=: sitFinalizado AND SIR_ObjetivoProceso__c !=:procesoObjetivoInformativo ';             
            soqlQuery += 'LIMIT 49900';
            List<SObject> resultProcesosFiltro = Database.query(soqlQuery);  
               
            return resultProcesosFiltro;            
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
        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isUpdateable()){        
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
}