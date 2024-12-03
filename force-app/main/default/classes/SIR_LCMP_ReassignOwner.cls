/*****************************************************************
 Name:  SIR_LCMP_ReassignOwner
 Copyright © 2022  CaixaBank

 Proposito:   Clase controladora externa del LWC Sir_lwc_ReassignOwner                                                                                                                    

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US372106         Atmira         05/05/2022     	  Created    
*****************************************************************/
public with sharing class SIR_LCMP_ReassignOwner {    

    /*****************************************************************
        @description  Realizamos query para saber el ID                                             
        @param  Ninguno
        @return List<SIREC__SIREC_obj_proceso__c>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         15/03/2023      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<RecordType> getQueryRecordTypeProceso(){
        List<RecordType> recordTypeProcesos = new List<RecordType>();
        if(RecordType.SObjectType.getDescribe().isAccessible()){         
            recordTypeProcesos = [SELECT id, name FROM RecordType WHERE SobjectType ='SIREC__SIREC_obj_proceso__c' 
                        AND (Name =: SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO OR Name =: SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL) 
                        ORDER BY Name];         
        }
        return recordTypeProcesos;
    }
    /*****************************************************************
        Proposito:  Realizamos query para encontrar la oficina del gestor actual                                                      
        Parameters: 
        Returns: String                                                                
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US372106         Atmira         05/05/2022	      Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=true)
	public static String getOficinaGestorActual(){	
        String oficina = '';
        if(User.SObjectType.getDescribe().isAccessible() && Account.SObjectType.getDescribe().isAccessible()){
            List<User> emp = [Select Id, AV_NumeroOficinaEmpresa__c, AV_Funcion__c From User Where Id = :UserInfo.getUserId() LIMIT 1];       
            oficina = emp[0].AV_NumeroOficinaEmpresa__c + '*'+ emp[0].AV_Funcion__c;           
              
            List<Account> cuenta = [SELECT Id, Name, AV_CentroSuperior__c FROM Account Where CC_Numero_Oficina_Empresa__c = :emp[0].AV_NumeroOficinaEmpresa__c LIMIT 1];
            if(!cuenta.isEmpty()){
                String esIntouch = 'noIntouch';
                if(cuenta[0].Name.contains('INTOUCH')){
                    esIntouch = 'siIntouch';
                }
                String esDan = 'noDan';
                if(emp[0].AV_Funcion__c == 'DAN'){
                    esDan = 'siDan';
                }
                oficina = emp[0].AV_NumeroOficinaEmpresa__c + '*' + emp[0].AV_Funcion__c + '*' + cuenta[0].Id + '*' + esIntouch + '*' + esDan + '*' + cuenta[0].AV_CentroSuperior__c;
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
        1.0            US372106         Atmira         05/05/2022	      Created    
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
		1.0            US372106         Atmira         27/07/2022	      Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=true)
	public static List<optionsEmployee> getOficinas(String funcionUsuario, String esIntouch, String esDan, String centroSuperiorUserActual, String idOficina){
		List<optionsEmployee> oficinas = new List<optionsEmployee>();
		List<optionsEmployee> oficinasSorted = new List<optionsEmployee>();
		List<Id> oficinasId = new List<Id>();		
		List<Account> ofi = new List<Account>();								
		if(Account.SObjectType.getDescribe().isAccessible() && User.SObjectType.getDescribe().isAccessible()){
            // Si el usuario logeado es de una oficina intouch y su funcion es Oficina
            if(esIntouch == 'siIntouch' && funcionUsuario == 'Oficina'){
                // Oficina superior = oficina superior del usuario
                List<Account> cuentasSuperiores = [SELECT Id, Name FROM Account WHERE (AV_CentroSuperior__c =: centroSuperiorUserActual OR AV_CentroSuperior__c =: idOficina) AND RecordType.DeveloperName ='CC_CentroCaixaBank'];
                List<Id> idCentros = new List<Id>();                	
                if(!cuentasSuperiores.isEmpty()){
                    String idTodasOficinas = '';
                    for(Account centros : cuentasSuperiores){
                        oficinasId.add(centros.Id);
                        oficinasSorted.add(new optionsEmployee(centros.Id,centros.Name));
                        idTodasOficinas = idTodasOficinas + centros.Id + ',';
                    }
                    oficinasSorted.add(new optionsEmployee(idTodasOficinas,'Todas las oficinas'));
                }                              
            // Si el usuario logeado es de una oficina D.A.N.    
            } else if(esDan == 'siDan'){
                // Oficina superior = oficina del usuario  y Oficina principal = oficina del usuario       
                List<Account> cuentasSuperiores = [SELECT Id, name FROM Account WHERE (AV_CentroSuperior__c =: idOficina OR Id =: idOficina) AND RecordType.DeveloperName ='CC_CentroCaixaBank'];
                List<Id> idCentros = new List<Id>();	
                if(!cuentasSuperiores.isEmpty()){
                    String idTodasOficinas = '';
                    for(Account centros : cuentasSuperiores){
                        oficinasId.add(centros.Id);
                        oficinasSorted.add(new optionsEmployee(centros.Id,centros.Name)); 
                        idTodasOficinas = idTodasOficinas + centros.Id + ',';                       
                    }
                    // Realizamos otra query para buscar todas las oficinas donde las oficinas resultantes de la anterior query tienen oficinas por debajo
                    List<Account> cuentasSuperiores2 = [SELECT Id, name FROM Account WHERE AV_CentroSuperior__c in :oficinasId AND RecordType.DeveloperName ='CC_CentroCaixaBank'];
                    if(!cuentasSuperiores2.isEmpty()){
                        for(Account centros2 : cuentasSuperiores2){ 
                            if(!oficinasId.contains(centros2.Id)){
                                oficinasId.add(centros2.Id);
                                oficinasSorted.add(new optionsEmployee(centros2.Id,centros2.Name));
                                idTodasOficinas = idTodasOficinas + centros2.Id + ',';
                            }                             
                        }
                    }
                    oficinasSorted.add(new optionsEmployee(idTodasOficinas,'Todas las oficinas'));
                }             
            // Si el usuario logeado no es oficina=Intouch/funcion=Oficina ni oficina=D.A.N.
            } else {
                ofi = [SELECT Id, Name FROM Account WHERE (AV_CentroSuperior__c =: idOficina OR Id = :idOficina) AND RecordType.DeveloperName ='CC_CentroCaixaBank'];
                if(!ofi.isEmpty() && ofi != null){
                    for(Account oficinaQuery : ofi){
                        oficinasId.add(oficinaQuery.Id);
                        oficinasSorted.add(new optionsEmployee(oficinaQuery.Id,oficinaQuery.Name));
                    }
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
		1.0            US372106         Atmira         05/05/2022	      Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<optionsEmployee> getEmployees(String idOficina, Boolean opcionTodasOficinas){
        List<optionsEmployee> employees = new List<optionsEmployee>();
        List<optionsEmployee> employeesSorted = new List<optionsEmployee>();
        List<Id> employeesId = new List<Id>();		
        List<User> emps = new List<User>();		
        List<Account> ofi = new List<Account>();
        if(Contact.SObjectType.getDescribe().isAccessible() && User.SObjectType.getDescribe().isAccessible() && Account.SObjectType.getDescribe().isAccessible()){            
            List<Id> idCentros = new List<Id>();
            if(opcionTodasOficinas == true){                
                List<String> oficinasSeparadas = idOficina.split(',');
                for(String oficinasString : oficinasSeparadas){
                    idCentros.add(oficinasString);
                }			
            } else{
                idCentros.add(idOficina);			 	
            }
            List<Contact> contactOficinas = [SELECT Id, AV_UsuarioAsociado__c, AV_UsuarioAsociado__r.Name, Account.CC_Numero_Oficina_Empresa__c FROM Contact WHERE AccountId in : idCentros AND AV_UsuarioAsociado__c !=''];
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
		1.0            US372106         Atmira         05/05/2022	      Created    
    *****************************************************************/    
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> buscarProcesos(Id clienteId, Date fechaInicio, String valueSituacion, String valueEstrategia, String valueTipoProceso, String valueEmpleado, String oficina, Boolean opcionTodasOficinas) {
        List<SIREC__SIREC_obj_proceso__c> procesos = new List<SIREC__SIREC_obj_proceso__c>(); 
        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible() && User.SObjectType.getDescribe().isAccessible() && Account.SObjectType.getDescribe().isAccessible()){  
            String soqlQuery = 'SELECT Id, Name, SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_cliente__r.Name, SIREC__SIREC_fld_cliente__r.CC_Numero_Documento__c ,';
            soqlQuery += 'SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__c, SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__r.Name,'; 
            soqlQuery += 'toLabel(SIREC__SIREC_fld_estrategia__c), SIREC__SIREC_fld_fechaInicio__c, toLabel(SIR_fld_Situacion_SF__c), SIR_DeudaTotal__c,';                             
            soqlQuery += 'OwnerId, SIREC__SIREC_fld_cliente__r.AV_EAPGestor__r.Name,';
            soqlQuery += 'TYPEOF Owner WHEN User THEN Name, AV_NumeroOficinaEmpresa__c ELSE Name END ';                        
            soqlQuery += 'FROM SIREC__SIREC_obj_proceso__c WHERE ';
            Set<Id> setIdUser = new Set<Id>();   
            Set<Id> idCentros = new Set<Id>(); 
            Set<Id> setIdUserIntegracion = new Set<Id>(); 
            if(valueEmpleado == 'UserIntegracion' || valueEmpleado.startsWith('Todos')){
                List<User> userIntegracion = [SELECT id, Profile.Name, Name FROM User WHERE Profile.Name LIKE '%API%' ];
                for (User usuario : userIntegracion) {
                    setIdUserIntegracion.add(usuario.Id);
                }
            }    
            if(valueEmpleado == 'UserIntegracion'){
                // Si el parametro es 'opcionTodasOficinas' es true la busqueda incluye todas las oficinas que tiene vision 
                if(opcionTodasOficinas == true){ 
					List<String> oficinasSeparadas = oficina.split(',');
					for(String oficinasString : oficinasSeparadas){
						idCentros.add(oficinasString);
					}                    

                // Si el parametro es 'opcionTodasOficinas' es false la busqueda solo se realiza sobre la oficina seleccionada
                } else {
                    idCentros.add(oficina);                    
                }
                soqlQuery += ' OwnerId in :setIdUserIntegracion AND SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__c in: idCentros AND ';    

            } else if(valueEmpleado.startsWith('Todos')){ 
                // Si el parametro es 'opcionTodasOficinas' es true la busqueda incluye todas las oficinas que tiene vision 
				if(opcionTodasOficinas == true){
					List<String> oficinasSeparadas = oficina.split(',');
					for(String oficinasString : oficinasSeparadas){
						idCentros.add(oficinasString);
					}                    
                    List<String> idsEmpleado = valueEmpleado.split(',');
                    for (Integer i = 1; i < idsEmpleado.size(); ++i) {                       
                        setIdUser.add(idsEmpleado[i]);
                    }
                    
                // Si el parametro es 'opcionTodasOficinas' es false la busqueda solo se realiza sobre la oficina seleccionada   
                } else {
                    List<String> idsEmpleado = valueEmpleado.split(',');
                    for (Integer i = 1; i < idsEmpleado.size(); ++i) {                       
                        setIdUser.add(idsEmpleado[i]);
                    }
                    idCentros.add(oficina);  
                } 
                soqlQuery += ' (OwnerId in :setIdUser OR (OwnerId in :setIdUserIntegracion AND SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__c in: idCentros )) AND ';
            
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
            // 16/02/2023 Se quitan los procesos SIN GESTION
            String procesoObjetivoInformativo = SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO;
            soqlQuery += 'SIR_fld_Situacion_SF__c !=: sitFinalizado AND SIR_AccionActual__c = true AND SIR_ObjetivoProceso__c !=:procesoObjetivoInformativo ';             
            soqlQuery += 'LIMIT 49900';
            List<SObject> resultProcesosFiltro = Database.query(soqlQuery);  
               
            return resultProcesosFiltro;            
        }
        return null;          
    }  

    /*****************************************************************
        Proposito: Metodo para recoger correctamente las picklist                                                     
        Parameters: 
        Returns:                                                         
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US372106          Atmira         02/08/2021     	  Created   
    *****************************************************************/
    public class SelectOption {
        public SelectOption(String value, String label) {
            this.value = value;
            this.label = label;
            this.disabled = false;
            this.escapeItem = false;
        }
        
        @AuraEnabled
        public String label { get;set; }
        @AuraEnabled
        public String value { get;set; }
        @AuraEnabled
        public Boolean disabled { get;set; }
        @AuraEnabled
        public Boolean escapeItem { get;set; }        
    }

    
	 /*****************************************************************
        Proposito: Realizamos query                                                      
        Parameters: String searchKey, String oficina
        Returns: List<sobject>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US372106         Atmira         05/05/2022     	  Created    
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
        Returns: List<SelectOption>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US372106         Atmira         05/05/2022     	  Created    
    *****************************************************************/                              
    @AuraEnabled
    public static String changeGestor(Id nuevoGestor, List<String> procesos) {
        String resultado = '';
        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isUpdateable() && SIR_FormularioRefinanciacion__c.SObjectType.getDescribe().isUpdateable()){        
            List<SIREC__SIREC_obj_proceso__c> procesosQuery = [SELECT Id, OwnerId FROM SIREC__SIREC_obj_proceso__c WHERE Id in : procesos];
            for(SIREC__SIREC_obj_proceso__c proceso : procesosQuery){           
                proceso.OwnerId = nuevoGestor;
            } 
            if(!procesosQuery.isEmpty()){
                update procesosQuery;
                List<SIR_FormularioRefinanciacion__c> formulariosQuery = [SELECT Id, OwnerId FROM SIR_FormularioRefinanciacion__c  WHERE SIR_Proceso__c in : procesos];
                for(SIR_FormularioRefinanciacion__c formulario : formulariosQuery){           
                    formulario.OwnerId = nuevoGestor;
                } 
                if(!formulariosQuery.isEmpty()){
                    update formulariosQuery;                
                    resultado = 'OK';
                } else {
                    resultado = 'OK';
                }                
            } else {
                resultado = 'KO';
            }
        }
        return resultado;
    }     
}