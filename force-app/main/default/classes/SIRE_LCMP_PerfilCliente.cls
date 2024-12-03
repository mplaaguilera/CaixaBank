/*****************************************************************
 Name:  SIR_LCMP_GetProfileClient
 Copyright © 2023  CaixaBank

Proposito:   Clase controladora externa del lwc Sire_lwc_perfilCliente                                                                                                                   

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         28/05/2023         Created    

*****************************************************************/
public with sharing class SIRE_LCMP_PerfilCliente {
    
	/*****************************************************************
        Proposito:  Recuperar datos del objeto SIREC__SIREC_obj_informacionCliente__c 
        Parameters: recordId
        Returns: List<PerfilClienteWrapper>
        Throws [Exceptions]: Se controla las Exceptions devolviendo el mensaje al LWC para que se muestre por pantalla                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         28/05/2023     	  Created    
    *****************************************************************/
	@AuraEnabled(cacheable=true)
	public static List<PerfilClienteWrapper> wrapperCabecera(String recordId){

        List<PerfilClienteWrapper> wrapper = new List<PerfilClienteWrapper>();
        try{        
            if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible() && SIREC__SIREC_obj_informacionCliente__c.SObjectType.getDescribe().isAccessible()
                && SIR_CatalogoSirec__c.SObjectType.getDescribe().isAccessible()){
                String clienteId = null;
                if(!recordId.startsWith('001')){
                    List<SIREC__SIREC_obj_proceso__c> proceso = [SELECT SIREC__SIREC_fld_cliente__c FROM SIREC__SIREC_obj_proceso__c WHERE Id =: recordId LIMIT 1];
                    if(!proceso.isEmpty()){ 
                        clienteId = proceso[0].SIREC__SIREC_fld_cliente__c;
                    }
                } else {
                    clienteId = recordId;
                }
                List<SIREC__SIREC_obj_informacionCliente__c> infoCliente = [
                    SELECT SIR_saldActivo__c, SIREC__SIREC_fld_saldPasivo__c, SIREC__SIREC_fld_deudaTotal__c, SIREC__SIREC_fld_deudaPendienteTotal__c, 
                    SIREC__SIREC_fld_deudaVencidaTotal__c, SIREC__SIREC_fld_diasImpago__c, SIREC__SIREC_fld_numCiclosImpago__c, SIREC__SIREC_fld_ciclosImpago__c,
                    SIREC__SIREC_fld_cliente__r.AV_CNAE__c 
                    FROM SIREC__SIREC_obj_informacionCliente__c WHERE SIREC__SIREC_fld_cliente__c =: clienteId LIMIT 1];
                if(!infoCliente.isEmpty()){ 
                    
                    List<SIR_CatalogoSirec__c> catalogo = [SELECT SIR_Descripcion__c FROM SIR_CatalogoSirec__c WHERE SIR_Codigo__c =: infoCliente[0].SIREC__SIREC_fld_cliente__r.AV_CNAE__c];
                    String sectorCnae = '';
                    if(!catalogo.isEmpty()){
                        sectorCnae = string.valueOf(catalogo[0].SIR_Descripcion__c);
                    } 
                    PerfilClienteWrapper wrapperCabecera = new PerfilClienteWrapper();
                    wrapperCabecera.saldosActivos        = valorConvert(infoCliente[0].SIR_saldActivo__c);
                    wrapperCabecera.sector               = sectorCnae;
                    wrapperCabecera.saldosPasivos        = valorConvert(infoCliente[0].SIREC__SIREC_fld_saldPasivo__c);
                    wrapperCabecera.cuotaCirbe           = '';
                    wrapperCabecera.totalActivo          = '';
                    wrapperCabecera.morosidadCirbe       = '';
                    wrapperCabecera.ffpp                 = '';
                    wrapperCabecera.deuda                = valorConvert(infoCliente[0].SIREC__SIREC_fld_deudaTotal__c);
                    wrapperCabecera.deudaFinanciera      = '';
                    wrapperCabecera.deudaPendienteVender = valorConvert(infoCliente[0].SIREC__SIREC_fld_deudaPendienteTotal__c);
                    wrapperCabecera.ventas               = '';
                    wrapperCabecera.deudaVencida         = valorConvert(infoCliente[0].SIREC__SIREC_fld_deudaVencidaTotal__c);
                    wrapperCabecera.resultado            = '';
                    wrapperCabecera.diasImpagoMax        = string.valueOf(infoCliente[0].SIREC__SIREC_fld_diasImpago__c);
                    wrapperCabecera.cf                   = '';
                    wrapperCabecera.ciclosImpago12m      = string.valueOf(infoCliente[0].SIREC__SIREC_fld_numCiclosImpago__c);
                    wrapperCabecera.ebitda               = '';
                    wrapperCabecera.ciclosImpagoTotal    = string.valueOf(infoCliente[0].SIREC__SIREC_fld_ciclosImpago__c);
                    wrapper.add(wrapperCabecera);
                }
            }
        }catch(exception e){
            CBK_log.error(e, 'Error : SIRE_LCMP_PerfilCliente - ' + e.getTypeName() + ': ' + e.getMessage());
        }
        return wrapper;
    }

    /****************************************
        Proposito:  Wrapper
        Parameters: 
        Returns:                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         28/05/2023     	  Created    
    *****************************************************************/
    public Class PerfilClienteWrapper{
        @AuraEnabled
        public String saldosActivos {get;set;}
        @AuraEnabled
        public String sector {get;set;}
        @AuraEnabled
        public String saldosPasivos {get;set;}
        @AuraEnabled
        public String cuotaCirbe {get;set;}
        @AuraEnabled
        public String totalActivo {get;set;}
        @AuraEnabled
        public String morosidadCirbe {get;set;}
        @AuraEnabled
        public String ffpp {get;set;}
        @AuraEnabled
        public String deuda {get;set;}
        @AuraEnabled
        public String deudaFinanciera {get;set;}
        @AuraEnabled
        public String deudaPendienteVender {get;set;}
        @AuraEnabled
        public String ventas {get;set;}
        @AuraEnabled
        public String deudaVencida {get;set;}
        @AuraEnabled
        public String resultado {get;set;}
        @AuraEnabled
        public String diasImpagoMax {get;set;}
        @AuraEnabled
        public String cf {get;set;}
        @AuraEnabled
        public String ciclosImpago12m {get;set;}
        @AuraEnabled
        public String ebitda {get;set;}
        @AuraEnabled
        public String ciclosImpagoTotal {get;set;} 
    }

    /*****************************************************************
        Proposito:  convertir datos                                                         
        Parameters: valor
        Returns: String
        Throws                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         28/05/2023     	  Created    
    *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static String valorConvert(decimal valor){        
        String campo = null;
        SIR_Constantes constante = new SIR_Constantes();
        List<String> args = new String[]{constante.STRING_0,constante.STRING_NUMBER,constante.STRING_EXPRE_REGU};
        if(valor != null){
            campo =  String.format(valor.format(), args);       
            if(!campo.contains(constante.STRING_COMA)){
                campo = campo + constante.STRING_COMILLA_00;
            }else{
                string campoSplit = campo.substringAfter(constante.STRING_COMA); 
                if(campoSplit.length() == 1 ){
                    campo = campo + constante.STRING_0;
                }                
                campo = campo + constante.STRING_EURO;
            }  
        }else{
            campo = constante.STRING_0_COMA_00;
        }            
        return campo;
    }

}