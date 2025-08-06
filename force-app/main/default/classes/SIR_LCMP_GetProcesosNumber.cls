/*****************************************************************
 Name:  SIR_LCMP_GetProcesosNumber
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase Test de la clase controladora externa del LWC sIR_LWC_GetProcesosNumber                                                                                                                 
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249684         Atmira         28/07/2021     	 Created    

*****************************************************************/
public with sharing class SIR_LCMP_GetProcesosNumber {
    
    /*****************************************************************
        Proposito:  Creamos la URL que hara la navegacion hacia la home de la app 'Mis Clientes Solutions'                                                      
        Parameters: No
        Returns: URL                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249684         Atmira         28/07/2021     	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static String getHomeUrl(){
        return 'https://' + Url.getSalesforceBaseUrl().getHost() + '/lightning/app/c__SIR_misClientesSolutions/page/home';
    }


    /*****************************************************************
        Proposito:  Realizamos una query para obtener todos los procesos del usuario actual
        Parameters: No
        Returns: Integer                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249684         Atmira         28/07/2021     	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=false)
    public static Integer getProcesosNumber(){
        Set<String> setSituaciones = new Set<String>{SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION, 
                                                     SIR_Constantes.PROCESO_SITUACION_NO_LOCALIZADO, 
                                                     SIR_Constantes.PROCESO_NAME_REPLANIFICAR_CONTACTO};
        String usuarioActual = UserInfo.getUserId();
        Integer numProcesos = Database.countQuery('SELECT Count() FROM SIREC__SIREC_obj_proceso__c WHERE OwnerId = :usuarioActual AND SIREC__SIREC_fld_situacion__c IN :setSituaciones');
        return numProcesos;
    }


}