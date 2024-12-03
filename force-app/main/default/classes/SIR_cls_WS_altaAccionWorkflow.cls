/******************************************************************************
    Name:  SIR_cls_WS_altaAccionWorkflow
    Copyright © 2022  CaixaBank

    Proposito:   WS2001 - Envio a sirec de altas de Accion en procesos Workflow

        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US448852         Atmira         27/09/2022     	  Created    

*****************************************************************************/
public with sharing class SIR_cls_WS_altaAccionWorkflow {

    public static List<Object> sendAction(String accionId) { 
                
        List<Object> response = new List<Object>();  
        
        if(SIREC__SIREC_obj_acciones__c.SObjectType.getDescribe().isAccessible() ){
                
            SIREC__SIREC_obj_acciones__c[] lstAccion = [SELECT id ,SIREC__SIREC_fld_accion__c , SIREC__SIREC_fld_resultado__c , SIREC__SIREC_fld_tipo__c, 
                                                                SIREC__SIREC_fld_comentarios__c , 
                                                                SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c , SIREC__SIREC_fld_fechaContacto__c,
                                                                SIREC__SIREC_fld_responsable__r.EmployeeNumber,
                                                                SIREC__SIREC_fld_interviniente__r.name,
                                                                SIREC__SIREC_fld_interviniente__c,
                                                                SIREC__SIREC_fld_persona__c,
                                                                SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_masterRecordId__c,
                                                                recordtypeId, RecordType.DeveloperName,
                                                                SIR_contactoAccionEmp__r.Name , SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_codProceso__c
                                                                FROM SIREC__SIREC_obj_acciones__c 
                                                                WHERE Id = :accionId];
            
            if(SIR_WS_Configuration__mdt.getInstance('altaAccion').SIR_fld_isActive__c){                
                if(lstAccion.size() > 0){
                    SIREC__SIREC_obj_acciones__c accion = lstAccion[0];
                    
                    //trae record Types de retail
                    Set<Id> setRTRetail = SIR_cls_Utils.getAppRtIds(SIR_Constantes.APP_RETAIL_DEVELOPERNAME, 'SIREC__SIREC_obj_acciones__c');
                    // nombre del interviniente en Retail y nombre del contacto en Empresas
                    String nameContactada = setRTRetail.contains((accion.recordtypeId)) ? accion.SIREC__SIREC_fld_interviniente__r.Name : accion.SIR_contactoAccionEmp__r.Name;
                                                
                    List<Integer> listIdPersonas = new List<Integer>(); 
                    SIREC__SIREC_obj_informacionCliente__c[] persona = [SELECT  SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_masterRecordId__c
                                                                        FROM SIREC__SIREC_obj_informacionCliente__c
                                                                        WHERE SIREC__SIREC_fld_cliente__c = :accion.SIREC__SIREC_fld_persona__c];
                    
                    if(persona.size() > 0){
                        listIdPersonas.add(integer.valueOf(persona[0].SIREC__SIREC_fld_masterRecordId__c));
                    }    
                    
                    // creamos el wraper con el contenido de las variables
                    WrapperclassAction wrapper = new WrapperclassAction(accion, nameContactada, listIdPersonas);                                              
                    String prefix = SIR_cls_Utils.getActorPrefix();
					
                    String body = JSON.serialize(wrapper);
                    response = SIR_cls_WS_SIREC.llamar(body, prefix +  'altaAccion' , 'POST');                    
                }else{
                    response.add('KO');
                    response.add('No se ha encontrado la accion que ha de enviarse con id = ' + accionId);
                    CBK_log.error('Error : SIR_cls_WS_altaAccionWorkflow.sendAccion - No se ha encontrado la accion que ha de enviarse con id = ' + accionId, lstAccion);
                }
            }else{
                //llamada al mock, por ahora siempre devuelve ok                 
                response.add('OK');
                response.add('MOCK');
            }                                                                        
        }else{
            response.add('KO');
            response.add('No tiene permisos para acceder a las acciones');            
        }    
        return response;    
    }    

    public class WrapperclassAction{
        
        public String codigoAccion;        
        public String codigoResultadoAccion;        
        public String codigoTipoAccion;        
        public String comentario;
        public String fechaAccion;
        public String fechaFinalizacion;
        public String empleado;        
        public String idPersona;        
        // cliente del proceso al que se le crea la accion
        public Integer[] idPersonas;        
        public String idProcesoGestion;        
        public String idActividadOrigen;
        //parametros no utilizados en SF pero definidos 
        public String codigoModelo;
        public String codigoMotivo;
        public String codigoPrioridad;
        public String codigoReaccion;
        public String codigoModulo;
        public String fechaLimite;
        public Integer[] idBienes;
        public Integer[] idCuentas;
        public Integer idObjetoIni=0;        
        public Integer idUnidadGestion=0;
        public String tipoAlta;
        public Integer tipoObjetoIni=0;
        public String[] tipoDatoRes;
        public List<String> tipoDato = new List<String>();
        public List<String> valorDato = new List<String>();
        public List<String> valorDatoRes = new List<String>();
        
        public WrapperclassAction(SIREC__SIREC_obj_acciones__c accion, String nameContactada, List<Integer> listIdPersonas ){
            
            codigoTipoAccion        = accion.SIREC__SIREC_fld_tipo__c;  
            // mapear codigos de accion y resultado a codigos SIREC
            codigoAccion            = mapeoAccionSirecSF(accion, 'A');  
            codigoResultadoAccion   = mapeoAccionSirecSF(accion, 'R');  
            //
            comentario              = String.isNotEmpty(accion.SIREC__SIREC_fld_comentarios__c) ? accion.SIREC__SIREC_fld_comentarios__c.left(499) : '';            
            fechaAccion             = SIR_cls_WS_Wrapper.formatDate(accion.SIREC__SIREC_fld_fechaContacto__c);
            fechaFinalizacion       = SIR_cls_WS_Wrapper.formatDate(accion.SIREC__SIREC_fld_fechaContacto__c);                   
            empleado                = String.isNotEmpty(accion.SIREC__SIREC_fld_responsable__r.EmployeeNumber) ? accion.SIREC__SIREC_fld_responsable__r.EmployeeNumber : '';                        
            // personas 
            idPersonas              = listIdPersonas ;
                    
            // id de la persona del proceso (id de SIREC masterRecord de InformacionCliente)
            if(listIdPersonas.size() > 0){
               tipoDato.add(SIR_Constantes.DATO_PERSONA);
               valorDato.add(String.valueOf(listIdPersonas[0]));
               valorDatoRes.add(String.valueOf(listIdPersonas[0]));
            }    

            // nombre de la persona contactada en empresas o nombre de la persona interviniente en flujo
            // en SIREC el valorDato tiene long 50, enviamos con ese límite sino da error
            if(nameContactada != null){
               tipoDato.add(SIR_Constantes.DATO_CONTACTADA);
               valorDato.add(nameContactada.left(50));
               valorDatoRes.add(nameContactada.left(50));
            }    

            idProcesoGestion        = accion.SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c;
            idActividadOrigen       = accion.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_masterRecordId__c ;

            if (accion.SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_codProceso__c == SIR_Constantes.PROCESO_CODIGO_PRESOL_WORKFLOW){
                codigoModulo = SIR_Constantes.CODIGO_MODULO_PRESOL;
            } else if(accion.SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_codProceso__c == SIR_Constantes.PROCESO_CODIGO_FLUJO_WORKFLOW){
                    codigoModulo = SIR_Constantes.CODIGO_MODULO_FLUJO;
            }        
        }
    }  
  
    // Mapear codigos SF a codigos SIREC con el catalogo  hasta que se realice el api de conversion en el conector
    private static String mapeoAccionSirecSF(SIREC__SIREC_obj_acciones__c accion, String tipo){       
        // tipo A --> traducir acciones
        // tipo R --> traducir resultado
            
        String accionSIREC;
        String masterRecord;
        String codigo;
        String prefijo;
        String prefijoTipo;        

        if (tipo=='A'){
           codigo=accion.SIREC__SIREC_fld_accion__c;
        }else{
            codigo=accion.SIREC__SIREC_fld_resultado__c;
        }
        
        // el master record del catalogo se compone del name de catalogo + el tipo de accion + el tipo de traduccion (A/R) + codigo de accion o de resultado
        // Segun el RT de la accion se monta una clave diferente para acceder a catalogo
        
        if (accion.RecordType.DeveloperName == SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_PRESOL){
            prefijo=SIR_Constantes.CATALOGO_API_MAPEO_ACCIONES_PRESOL + '|' + accion.SIREC__SIREC_fld_tipo__c ;
        }else if (accion.RecordType.DeveloperName == SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_AMISTOSO_EMPRESA){
            // en EMPRESAS la primera parte de la clave es diferente si es accion o resultado porque hay duplicidad de codigos
            
            if (tipo=='A'){
                prefijoTipo=accion.SIREC__SIREC_fld_tipo__c;
             }else{
                prefijoTipo=accion.SIREC__SIREC_fld_accion__c;
             }
             
            prefijo=SIR_Constantes.CATALOGO_API_MAPEO_ACCIONES_FLUJO + '|' + prefijoTipo ;
        }        
        masterRecord=prefijo + '|' + tipo + '|' + codigo;          
        
        SIR_CatalogoSirec__c[] lstCatalogo = [SELECT SIR_Descripcion__c
                                                    from SIR_CatalogoSirec__c 
                                                    where SIR_MasterRecordId__c = :masterRecord];
        if(lstCatalogo.size() > 0){
           accionSIREC = lstCatalogo[0].SIR_Descripcion__c;
        } else { 
            CBK_log.error('Error : SIR_cls_WS_altaAccionWorkflow.mapeoAccionSirecSF - No se ha encontrado traduccion en catalogo = ' + masterRecord);                
        }   
        return accionSIREC;
    }
}