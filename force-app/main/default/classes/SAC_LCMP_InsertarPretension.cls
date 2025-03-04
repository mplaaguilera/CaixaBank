/*****************************************************************************************
* Name: SAC_LCMP_InsertarPretension
* Copyright © 2021  CaixaBank 
* ***************************************************************************************
* Proposito: Controlador  para poder insertar pretensiones desde 
* su propia pestaña, dentro de una reclamación. 
* Principal objetivo: poder relacionar directamente la pretensión
* a la reclamación que se está visualizando.
* LWC asociado: sAC_InsertarPretension
* ***************************************************************************************
* Historial
* -------
* VERSION        USER_STORY       AUTHOR         DATE          Description
* 1.0            US204743         Luis Mesa      29/04/21      Creación Clase
* 2.0            US242669         Carlos Solis   28/06/21      Modificación. Inserción de 
*                                                              la pretensión sin pop up
* 2.1            DE50250          Esteve Llaó    26/08/21      Modificacion del medotodo 
*                                                              para que devuelva la id
* 2.2            US911873         David Ramos    09/05/24      Modificar la funcion camposPretension 
*                                                              para que pase de private a public
******************************************************************************************/
public without sharing class SAC_LCMP_InsertarPretension {
    
    
    private static Set<String> objetos = new Set<String>{'Case'};
        private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    
    final static Id RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    final static Id RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    
    private static final String MSG_ERROR_PERMISSIONS = 'No tienes permisos para realizar la acción.';
    
    @AuraEnabled
    public static Case recuperarCaso(Id caseId){        
        Case caseSR = new Case();
        if (Schema.sObjectType.Case.isAccessible()) {
            caseSR = [SELECT id, Status, SEG_Grupo__c, SEG_Grupo__r.Name, OwnerId, AccountId, CaseNumber, Origin, RecordTypeId, SuppliedEmail, 
                      CC_MCC_Motivo__c,CC_MCC_ProdServ__c,CC_MCC_Tematica__c, RecordType.Name, CC_Idioma__c, Priority, SEG_Detalle__c, Subject, SAC_PretensionPrincipal__c,
                      SAC_Reclamacion__r.SAC_PretensionPrincipal__c, SAC_Motivo__c, RecordType.DeveloperName, CC_Canal_Respuesta__c, CC_No_Identificado__c, SAC_OrigenConsulta__c,
                      SAC_EsCliente__c, ContactId, OS_Email__c, SAC_NombreContacto__c, SAC_UsarDatos__c, SAC_DireccionPostalNotificacion__c, CC_Importe_Reclamado__c,
                      SAC_TipoDeRepresentante__c, SAC_DespachoRepresentante__c, SAC_TipoDeDocumento__c, SAC_NumeroDelDocumento__c, SAC_NombreRepresentante__c, SAC_DireccionPostal__c,
                      SAC_EmailRepresentante__c, SAC_TelefonoRepresentante__c, SAC_Naturaleza__c, SAC_CasoEspecial__c, SAC_CASE_esPSD2__c,SAC_DerivadoA__c, SAC_CasoRelacionado__c,
                      CC_Detalles_Solucion__c, CC_CasoRelacionado__c, SAC_PretensionPrincipal__r.Status, SAC_PretensionPrincipal__r.SEG_Grupo__c, SAC_PretensionPrincipal__r.SEG_Grupo__r.Name, SAC_PretensionPrincipal__r.OwnerId, 
                      SAC_PretensionPrincipal__r.AccountId, SAC_PretensionPrincipal__r.CaseNumber, SAC_PretensionPrincipal__r.Origin, SAC_PretensionPrincipal__r.RecordTypeId, 
                      SAC_PretensionPrincipal__r.SuppliedEmail, SAC_PretensionPrincipal__r.CC_MCC_Motivo__c, SAC_PretensionPrincipal__r.CC_MCC_ProdServ__c, SAC_PretensionPrincipal__r.CC_MCC_Tematica__c, 
                      SAC_PretensionPrincipal__r.RecordType.Name, SAC_PretensionPrincipal__r.CC_Idioma__c, SAC_PretensionPrincipal__r.Priority, SAC_PretensionPrincipal__r.SEG_Detalle__c,
                      SAC_PretensionPrincipal__r.Subject, SAC_PretensionPrincipal__r.SAC_Motivo__c, SAC_PretensionPrincipal__r.RecordType.DeveloperName, 
                      SAC_PretensionPrincipal__r.CC_Canal_Respuesta__c, SAC_PretensionPrincipal__r.CC_No_Identificado__c, SAC_PretensionPrincipal__r.SAC_OrigenConsulta__c,
                      SAC_PretensionPrincipal__r.SAC_EsCliente__c, SAC_PretensionPrincipal__r.ContactId, SAC_PretensionPrincipal__r.OS_Email__c, SAC_PretensionPrincipal__r.SAC_NombreContacto__c,
                      SAC_PretensionPrincipal__r.SAC_UsarDatos__c, SAC_PretensionPrincipal__r.SAC_DireccionPostalNotificacion__c, SAC_PretensionPrincipal__r.CC_Importe_Reclamado__c,
                      SAC_PretensionPrincipal__r.SAC_TipoDeRepresentante__c, SAC_PretensionPrincipal__r.SAC_DespachoRepresentante__c, SAC_PretensionPrincipal__r.SAC_TipoDeDocumento__c, 
                      SAC_PretensionPrincipal__r.SAC_NumeroDelDocumento__c, SAC_PretensionPrincipal__r.SAC_NombreRepresentante__c, SAC_PretensionPrincipal__r.SAC_DireccionPostal__c,
                      SAC_PretensionPrincipal__r.SAC_EmailRepresentante__c, SAC_PretensionPrincipal__r.SAC_TelefonoRepresentante__c, SAC_PretensionPrincipal__r.SAC_Naturaleza__c, 
                      SAC_PretensionPrincipal__r.SAC_CasoEspecial__c, SAC_PretensionPrincipal__r.SAC_CASE_esPSD2__c, CC_SuppliedNIF__c
                      FROM Case WHERE RecordType.DeveloperName LIKE 'SAC_%' AND Id = :caseId LIMIT 1];
        }
        
        return caseSR; 
    }
    
    @AuraEnabled
    public static WrapperPretension initInsertarPretension(Id caseId){
        
        Case caso = recuperarCaso(caseId);
        Boolean tienePermisos = tienePermisos(caseId);
        
        WrapperPretension newWrapperPretension = new WrapperPretension(caso, tienePermisos);
        
        return newWrapperPretension;
    }
    
    public class WrapperPretension{
        
        @AuraEnabled public Case caso{get;set;}
        @AuraEnabled public boolean esPropietario{get;set;}
        
        public WrapperPretension(Case miCaso, Boolean miPropietario){
            this.caso = miCaso;
            this.esPropietario = miPropietario;
        }
        
    }
    
    /*****************************************************************
    * Proposito: Método para insertar mas de una pretensión al sistema con el MCC predefinido
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0                           Daniel Benito    02/05/22       Creación Método
    *****************************************************************/
    @AuraEnabled
    public static Boolean insertarPretensiones(String idCase, List<SObject> mccsPretension) {
        List<Case> nuevasPretensiones = new List<Case>();
        List<Case> nuevasPretensionesCreadasCerradas = new List<Case>();
        List<Id> idsDetalle = new List<Id>();
        List<Id> idsDetalleRepetidos = new List<Id>();
        Set<Id> setIdsDetalleAux = new  Set<Id>();
        List<CC_MCC__c> listaMcc = new List<CC_MCC__c>();
        List<CC_MCC__c> listaMccRepetidos = new List<CC_MCC__c>();
        Map<Id, String> detalleSubject = new Map<Id, String>();
        Map<Id, String> prodServSubject = new Map<Id, String>();
        Map<Id, Id> detalleMotivo = new Map<Id, Id>();
        Map<Id, Id> motivoProdServ = new Map<Id, Id>(); 
        Map<Id, Id> prodServTematica = new Map<Id, Id>();
        Map<Id, Id> detalleMotivoRepetidos = new Map<Id, Id>();
        Map<Id, Id> motivoProdServRepetidos = new Map<Id, Id>();
        Map<Id, Id> prodServTematicaRepetidos = new Map<Id, Id>();
        Map<Id, CC_MCC__c> mapaMcc = new Map<Id, CC_MCC__c>();
        
        
        if(!Case.SObjectType.getDescribe().isCreateable()){
            throwAuraHandledException( MSG_ERROR_PERMISSIONS );
            return false;
        }
        
        Case reclamacionActual = [SELECT Id,CC_Canal_Procedencia__c, ContactId, AccountId, SAC_TiempoSLARegulatorio__c, SAC_TiempoSLALetradoAlta__c, Origin, Status,
                                  SAC_PretensionPrincipal__r.SEG_Grupo__c, SAC_PretensionPrincipal__r.OwnerId, OwnerId, SAC_CasoEspecial__c, CC_CasoRelacionado__c, CC_SuppliedNIF__c,
                                  CC_CasoRelacionado__r.Status, CC_CasoRelacionado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c, OS_Email__c, CC_Telefono_Contacto__c, SAC_DireccionPostalNotificacion__c, SuppliedEmail, SAC_CheckResumen__c
                                  FROM Case Where RecordType.DeveloperName LIKE 'SAC_%' AND Id =: idCase];
        
        for(SObject mcc : mccsPretension){
            if(!idsDetalle.contains(mcc.id)){
                idsDetalle.add(mcc.Id);
            }else{
                idsDetalleRepetidos.add(mcc.Id);
            }  
            setIdsDetalleAux.add(mcc.Id);      
        }
        
        List<CC_MCC__c> listaMccAux = [SELECT id, Name, SAC_EntidadAfectada__c, SAC_EntidadProductora__c, SAC_EsPsd2__c, CC_Motivo__c, CC_Motivo__r.CC_Producto_Servicio__c, CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c, 
                                       CC_Motivo__r.CC_Producto_Servicio__r.Name, CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.CC_Codigo_Externo__c
                                       FROM CC_MCC__c 
                                       WHERE Id IN: setIdsDetalleAux 
                                       AND RecordType.DeveloperName = 'SAC_Detalle'];
        
        if(!listaMccAux.isEmpty()){
            for(CC_MCC__c detalle : listaMccAux){
                if(idsDetalle.contains(detalle.Id)){
                    listaMcc.add(detalle);    
                }else if(idsDetalleRepetidos.contains(detalle.Id)){
                    listaMccRepetidos.add(detalle);    
                }   
            }    
        }
        
        if(!listaMcc.isEmpty()){
            for(CC_MCC__c detalle : listaMcc){
                detalleMotivo.put(detalle.Id, detalle.CC_Motivo__c);
                detalleSubject.put(detalle.Id, detalle.Name);
                prodServSubject.put(detalle.Id, detalle.CC_Motivo__r.CC_Producto_Servicio__r.Name);
                motivoProdServ.put(detalle.CC_Motivo__c, detalle.CC_Motivo__r.CC_Producto_Servicio__c);
                prodServTematica.put(detalle.CC_Motivo__r.CC_Producto_Servicio__c, detalle.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c);
                mapaMcc.put(detalle.Id, detalle);
            }
        }
        
        if(!listaMccRepetidos.isEmpty()){
            for(CC_MCC__c detalle : listaMccRepetidos){
                detalleMotivoRepetidos.put(detalle.Id, detalle.CC_Motivo__c);
                motivoProdServRepetidos.put(detalle.CC_Motivo__c, detalle.CC_Motivo__r.CC_Producto_Servicio__c);
                prodServTematicaRepetidos.put(detalle.CC_Motivo__r.CC_Producto_Servicio__c, detalle.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c);
            }
        }
        
        if(!detalleMotivo.isEmpty()){
            Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];
            for(Id idDetalle : detalleMotivo.KeySet()){
                Id detalle = idDetalle;
                Id motivo = detalleMotivo.get(idDetalle);
                Id prodServ = motivoProdServ.get(motivo);
                Id tematica = prodServTematica.get(prodServ);
                String asunto = prodServSubject.get(detalle) + ' - ' + detalleSubject.get(detalle);
                
                Case nuevaPretension = camposPretension(reclamacionActual, detalle, motivo, prodServ, tematica, RECORDTYPEPRETENSION, asunto, mapaMcc);

                if (reclamacionActual.Status == 'SAC_001') { //Si la reclamación padre está en Alta, se crea la pretensión                     
                    //MOD --> US426108 Mejora: Vinculación reclamaciones MNR 25/085/2022
                    //Si la reclamación a la que se vinculó esta cerrada hay que asignar el mismo grupo letrado de las pretensiones anteriores a la nueva que vamos a crear
                    if(reclamacionActual.CC_CasoRelacionado__r.Status == 'Cerrado'){
                        nuevaPretension.SEG_Grupo__c = reclamacionActual.CC_CasoRelacionado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c;
                        
                        nuevaPretension.OwnerId = cola.Id;
                    }
                    nuevasPretensiones.add(nuevaPretension);    
                } else if (reclamacionActual.Status == 'SAC_002') { //Si la reclamación padre está en Análisis, se crea con el owner y el grupo de la pretensión principal
                    nuevaPretension.SEG_Grupo__c = reclamacionActual.SAC_PretensionPrincipal__r.SEG_Grupo__c;      
                    nuevaPretension.OwnerId = reclamacionActual.SAC_PretensionPrincipal__r.OwnerId;
                    nuevasPretensiones.add(nuevaPretension);
                } else if (reclamacionActual.Status == 'Cerrado') { //Si la reclamación padre está en Cerrado, se crea con el owner y el grupo de la pretensión principal
                    nuevaPretension.SEG_Grupo__c = reclamacionActual.SAC_PretensionPrincipal__r.SEG_Grupo__c;      
                    nuevaPretension.OwnerId = reclamacionActual.SAC_PretensionPrincipal__r.OwnerId;
                    nuevasPretensiones.add(nuevaPretension);
                    nuevasPretensionesCreadasCerradas.add(nuevaPretension);
                } else {
                    throwAuraHandledException('La reclamación debe estar en alta o análisis para poder crear una o varias pretensiones');
                    return false;
                }
            }
        }
        
        
        //si hay 1 o mas mccs repetidos
        if(!detalleMotivoRepetidos.isEmpty()){
            
            for(Id idDetalle : detalleMotivoRepetidos.KeySet()){
                
                Id detalle = idDetalle;
                Id motivo = detalleMotivoRepetidos.get(idDetalle);
                Id prodServ = motivoProdServRepetidos.get(motivo);
                Id tematica = prodServTematicaRepetidos.get(prodServ);
                String asunto = detalleSubject.get(detalle) + ' - ' + prodServSubject.get(detalle);
                
                Case nuevaPretension = camposPretension(reclamacionActual, detalle, motivo, prodServ, tematica, RECORDTYPEPRETENSION, asunto, mapaMcc);
                if (reclamacionActual.Status == 'SAC_001') { //Si la reclamación padre está en Alta, se crea la pretensión
                    nuevasPretensiones.add(nuevaPretension);    
                } else if (reclamacionActual.Status == 'SAC_002') { //Si la reclamación padre está en Análisis, se crea con el owner y el grupo de la pretensión principal
                    nuevaPretension.SEG_Grupo__c = reclamacionActual.SAC_PretensionPrincipal__r.SEG_Grupo__c;      
                    nuevaPretension.OwnerId = reclamacionActual.SAC_PretensionPrincipal__r.OwnerId;
                    nuevasPretensiones.add(nuevaPretension);
                } else if (reclamacionActual.Status == 'Cerrado') { //Si la reclamación padre está en Cerrado, se crea con el owner y el grupo de la pretensión principal
                    nuevaPretension.SEG_Grupo__c = reclamacionActual.SAC_PretensionPrincipal__r.SEG_Grupo__c;      
                    nuevaPretension.OwnerId = reclamacionActual.SAC_PretensionPrincipal__r.OwnerId;
                    nuevasPretensiones.add(nuevaPretension);
                    nuevasPretensionesCreadasCerradas.add(nuevaPretension);
                } else {
                    throwAuraHandledException('La reclamación debe estar en alta o análisis para poder crear una o varias pretensiones');
                    return false;
                }
            }
        }
        
        if(!nuevasPretensiones.isEmpty()){
            SAC_DatabaseDML.insertListDML(nuevasPretensiones, false);
            reclamacionActual.SAC_CheckResumen__c = false;
            SAC_DatabaseDML.updateDML(reclamacionActual, false);


        }

        if(!nuevasPretensionesCreadasCerradas.isEmpty()){
            List<Case> pretensionesCreadasCerradas = new List<Case>();
            for (Case caso : nuevasPretensionesCreadasCerradas) {
                caso.Status = 'Cerrado';
                caso.SAC_StatusAuxiliar__c = 'Cerrado';
                pretensionesCreadasCerradas.add(caso);
            } 
            if(!pretensionesCreadasCerradas.isEmpty()) {
                SAC_DatabaseDML.updateListDML(pretensionesCreadasCerradas, false);
            }
        }
        
        return true;
    }

    
    /*****************************************************************
    * Proposito: Método para controlar errores y lanzarlos por pantalla 
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US200298         Luis Mesa    16/04/21       Creación Método
    *****************************************************************/
    @TestVisible
    private static void throwAuraHandledException( String errorMsg ){
    
        AuraHandledException auraException = new AuraHandledException( errorMsg );
        auraException.setMessage( errorMsg );
        throw auraException;
    }
    
    //INI - MOD -> DE54906 y DE54903 | Marcela Neira
    /********************************************************************************************************
    * Proposito: Comprobar si puede tener el permiso de crear una nueva Pretensión o una Nueva Consulta
    *            Se llama desde el LWC sacInsertarPretension y LWC sacInsertarConsulta (Objeto Interacción)
    *            Comprueba desde la Reclamación si se tienen pretensiones y si alguno de los propietarios
    *            de esas pretensiones es el usuario que esta logueado 
    * ******************************************************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0       DE54906 y DE54903      Marcela Neira    15/12/2021      Creación
    *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static Boolean tienePermisos(String idCaso){ 
        Boolean tienePermiso= false;      
        try {
            
            List<Case> pretensiones = new List<Case>();
            pretensiones = [SELECT Id, SAC_Reclamacion__c, OwnerId 
                            FROM Case 
                            WHERE SAC_Reclamacion__c =: idCaso AND Status <> 'SAC_009' AND RecordTypeId =:RECORDTYPEPRETENSION];
            
            if(!pretensiones.isEmpty()){
                for (Case caso : pretensiones) {
                    if(caso.OwnerId == UserInfo.getUserId()){
                        tienePermiso=true;
                        break;
                    }
                }
            }           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return tienePermiso;
    }
    //FIN - MOD -> DE54906 y DE54903 | Marcela Neira
    
    //@TestVisible
    public static Case camposPretension(Case reclamacionActual, Id detalle, Id motivo, Id prodServ, Id tematica, Id tipoRegistro, String asunto, Map<Id, CC_MCC__c> mapaMcc){
        
        Case nuevaPretension = new Case();
        nuevaPretension.SAC_Reclamacion__c = reclamacionActual.Id;
        nuevaPretension.CC_SuppliedNIF__c = reclamacionActual.CC_SuppliedNIF__c;
        nuevaPretension.Subject = asunto;
        nuevaPretension.recordTypeId = tipoRegistro;
        if(reclamacionActual.Status == 'Cerrado') {
            nuevaPretension.status = 'SAC_003';
            nuevaPretension.SAC_StatusAuxiliar__c = 'SAC_003';
        } else {
            nuevaPretension.status = reclamacionActual.Status;
            nuevaPretension.SAC_StatusAuxiliar__c = reclamacionActual.Status;
        }
        nuevaPretension.Origin = reclamacionActual.Origin;
        nuevaPretension.SAC_TiempoSLARegulatorio__c = 30;
        nuevaPretension.SAC_TiempoSLALetradoAlta__c = 30;
        nuevaPretension.CC_No_Identificado__c  = true;
        nuevaPretension.CC_IdentCliente__c     = '0';      
        nuevaPretension.SEG_Detalle__c = detalle;
        nuevaPretension.CC_MCC_Motivo__c = motivo;
        nuevaPretension.CC_MCC_ProdServ__c = prodServ;
        nuevaPretension.CC_MCC_Tematica__c = tematica; 
        nuevaPretension.SAC_Entidad_Afectada__c = mapaMcc.get(detalle).SAC_EntidadAfectada__c;
        nuevaPretension.SAC_EntidadProductora__c = mapaMcc.get(detalle).SAC_EntidadProductora__c;
        nuevaPretension.SAC_CASE_esPSD2__c = mapaMcc.get(detalle).SAC_EsPsd2__c;
        nuevaPretension.CC_Codigo_Externo_Tematica__c = mapaMcc.get(detalle).CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.CC_Codigo_Externo__c;
        nuevaPretension.SAC_CasoEspecial__c = reclamacionActual.SAC_CasoEspecial__c;
        
        if(!String.isBlank(reclamacionActual.CC_Canal_Procedencia__c)){
            nuevaPretension.CC_Canal_Procedencia__c = reclamacionActual.CC_Canal_Procedencia__c;
        } 
        if(!String.isBlank(reclamacionActual.AccountId)){
            nuevaPretension.AccountId = reclamacionActual.AccountId;
        } 
        if(!String.isBlank(reclamacionActual.ContactId)){
            nuevaPretension.ContactId = reclamacionActual.ContactId;
        } 
        if(!String.isBlank(reclamacionActual.OS_Email__c)){
            nuevaPretension.OS_Email__c = reclamacionActual.OS_Email__c;
        }
        if(!String.isBlank(reclamacionActual.CC_Telefono_Contacto__c)){
            nuevaPretension.CC_Telefono_Contacto__c = reclamacionActual.CC_Telefono_Contacto__c;
        } 
        if(!String.isBlank(reclamacionActual.SAC_DireccionPostalNotificacion__c)){
            nuevaPretension.SAC_DireccionPostalNotificacion__c = reclamacionActual.SAC_DireccionPostalNotificacion__c;
        } 
        if(!String.isBlank(reclamacionActual.SuppliedEmail)){
            nuevaPretension.SuppliedEmail = reclamacionActual.SuppliedEmail;
        }
        return nuevaPretension;
        
    }
    
    @AuraEnabled
    public static void insertarPretensionPrincipal(String idCase, List<SObject> mccsPretension) {
        
        Case nuevaPretension = new Case();
        List<Id> idsDetalle = new List<Id>();
        Set<Id> setIdsDetalleAux = new  Set<Id>();
        List<CC_MCC__c> listaMcc = new List<CC_MCC__c>();
        Map<Id, String> detalleSubject = new Map<Id, String>();
        Map<Id, String> prodServSubject = new Map<Id, String>();
        Map<Id, Id> detalleMotivo = new Map<Id, Id>();
        Map<Id, Id> motivoProdServ = new Map<Id, Id>(); 
        Map<Id, Id> prodServTematica = new Map<Id, Id>();
        Map<Id, CC_MCC__c> mapaMcc = new Map<Id, CC_MCC__c>();
        List<Case> lstReclamacion = new List<Case>();
        Case pretensionPrincipal = new Case();
        
        Case reclamacionActual = [SELECT Id,CC_Canal_Procedencia__c, ContactId, AccountId, SAC_TiempoSLARegulatorio__c, SAC_TiempoSLALetradoAlta__c, Origin, Status,
                                  SAC_PretensionPrincipal__r.SEG_Grupo__c, SAC_PretensionPrincipal__r.OwnerId, OwnerId, SAC_CasoEspecial__c, CC_CasoRelacionado__c, CC_SuppliedNIF__c,
                                  CC_CasoRelacionado__r.Status, CC_CasoRelacionado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c, SAC_GrupoLetrado__c, OS_Email__c, CC_Telefono_Contacto__c, SAC_DireccionPostalNotificacion__c, SuppliedEmail, SAC_CheckResumen__c
                                  FROM Case Where RecordType.DeveloperName LIKE 'SAC_%' AND Id =: idCase];  
        
        for(SObject mcc : mccsPretension){
            if(!idsDetalle.contains(mcc.id)){
                idsDetalle.add(mcc.Id);
            }  
            setIdsDetalleAux.add(mcc.Id);      
        }
        
        List<CC_MCC__c> listaMccAux = [SELECT id, Name, SAC_EntidadAfectada__c, SAC_EntidadProductora__c, SAC_EsPsd2__c, CC_Motivo__c, CC_Motivo__r.CC_Producto_Servicio__c, CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c, 
                                       CC_Motivo__r.CC_Producto_Servicio__r.Name, CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.CC_Codigo_Externo__c
                                       FROM CC_MCC__c 
                                       WHERE Id IN: setIdsDetalleAux 
                                       AND RecordType.DeveloperName = 'SAC_Detalle'];
        
        if(!listaMccAux.isEmpty()){
            for(CC_MCC__c detalle : listaMccAux){
                if(idsDetalle.contains(detalle.Id)){
                    listaMcc.add(detalle);       
                }   
            }    
        }
        
        if(!listaMcc.isEmpty()){ 
            for(CC_MCC__c detalle : listaMcc){
                detalleMotivo.put(detalle.Id, detalle.CC_Motivo__c);
                detalleSubject.put(detalle.Id, detalle.Name);
                prodServSubject.put(detalle.Id, detalle.CC_Motivo__r.CC_Producto_Servicio__r.Name);
                motivoProdServ.put(detalle.CC_Motivo__c, detalle.CC_Motivo__r.CC_Producto_Servicio__c);
                prodServTematica.put(detalle.CC_Motivo__r.CC_Producto_Servicio__c, detalle.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c);
                mapaMcc.put(detalle.Id, detalle);
            }
        }
        
        if(!detalleMotivo.isEmpty()){
            for(Id idDetalle : detalleMotivo.KeySet()){
                Id detalle = idDetalle;
                Id motivo = detalleMotivo.get(idDetalle);
                Id prodServ = motivoProdServ.get(motivo);
                Id tematica = prodServTematica.get(prodServ);
                String asunto = prodServSubject.get(detalle) + ' - ' + detalleSubject.get(detalle);
                
                nuevaPretension = camposPretension(reclamacionActual, detalle, motivo, prodServ, tematica, RECORDTYPEPRETENSION, asunto, mapaMcc);
            }
        }
        
        if(reclamacionActual.SAC_PretensionPrincipal__c != null) {
            pretensionPrincipal = [SELECT id, status, SAC_EsPrincipal__c
                    FROM Case 
                    WHERE id = :reclamacionActual.SAC_PretensionPrincipal__c LIMIT 1];
        }

        if(nuevaPretension != null){
            //nuevaPretension.status = nuevaPretension.SAC_Reclamacion__r.Status;
            //nuevaPretension.SAC_StatusAuxiliar__c = nuevaPretension.Status;

            //DE92939 - Al crear una pretensión como principal en análisis, dejaba en vacío el grupo de trabajo de la nueva pretensión
            if(reclamacionActual.SAC_GrupoLetrado__c != null){
                nuevaPretension.SEG_Grupo__c = reclamacionActual.SAC_GrupoLetrado__c;
            }
            nuevaPretension.SAC_EsPrincipal__c = true;
            SAC_DatabaseDML.insertDML(nuevaPretension, false);  

                if(reclamacionActual.SAC_PretensionPrincipal__c != null) {
                    pretensionPrincipal.SAC_EsPrincipal__c = false;
                    lstReclamacion.add(pretensionPrincipal);
                }
                reclamacionActual.SAC_CheckResumen__c = false;
                reclamacionActual.SAC_PretensionPrincipal__c = nuevaPretension.id; 
                reclamacionActual.SAC_Entidad_Afectada__c = nuevaPretension.SAC_Entidad_Afectada__c;
                reclamacionActual.SAC_EntidadProductora__c = nuevaPretension.SAC_EntidadProductora__c;
    
            lstReclamacion.add(reclamacionActual); 
            DateTime dt = DateTime.now();
            Long dateInMilliseconds = dt.getTime();
            AsyncOptions options = new AsyncOptions();
            options.DuplicateSignature = QueueableDuplicateSignature.Builder().addId(UserInfo.getUserId()).addString(String.valueOf(dateInMilliseconds)).build();
            ID jobID;
            try {
                jobID = System.enqueueJob(new SAC_QueueableUpdateCase(lstReclamacion), options);    
            } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);                 } 
        }
    }


    /***********************************************************************************************************
    * Proposito: Comprobar si el usuario pertenece al public group SAC_GrupoCreacionPretensionCerrada para que
                    pueda insertar pretensiones una vez cerrada la reclamacion.
    * **********************************************************************************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR          DATE         Description
    * 1.0            US1132463      Sergio Martín   20/01/2024      Creación
    *************************************************************************************************************/
    @AuraEnabled
    public static Boolean tienePermisosReclamacionCerrada(String idCaso){ 
        Boolean tienePermiso= false;      
        try {
            List<GroupMember> listaMiembrosGrupo = [SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName ='SAC_GrupoCreacionPretensionCerrada'];       

            if(!listaMiembrosGrupo.isEmpty()) {
                for (GroupMember ide : listaMiembrosGrupo) {
                    if(ide.UserOrGroupId == UserInfo.getUserId()){
                        tienePermiso=true;
                        break;
                    }                
                }
            }     
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return tienePermiso;
    }
}