public with sharing class SPV_LCMP_InsertarPretension {

    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    final static Id RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    final static Id RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();

    private static final String MSG_ERROR_PERMISSIONS = 'No tienes permisos para realizar la acción.';


    //Método para insertar la pretensión que se marcó como principal
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
        Set<string> lstReclamacionIds = new Set<string>();


        Case reclamacionActual = [SELECT Id,CC_Canal_Procedencia__c, SPV_VueltaAlta__c, ContactId, AccountId, SAC_TiempoSLARegulatorio__c, SAC_TiempoSLALetradoAlta__c, Origin, Status,
                                  SAC_PretensionPrincipal__r.SEG_Grupo__c, SAC_FechaRecepcion__c, SAC_PretensionPrincipal__r.OwnerId, OwnerId, SAC_CasoEspecial__c, CC_CasoRelacionado__c,
                                  CC_CasoRelacionado__r.Status, CC_CasoRelacionado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c, SAC_GrupoLetrado__c, SEG_Grupo__c
                                  FROM Case Where RecordType.DeveloperName LIKE 'SPV_%' AND Id =: idCase];  

                       
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
            if(reclamacionActual.SAC_GrupoLetrado__c != null){
                nuevaPretension.SEG_Grupo__c = reclamacionActual.SAC_GrupoLetrado__c;
            }

            //MOD-> US1036419-> si se ha vuelto a alta, y se añade una pretensión, tendrá el grupo y owner de la principal anterior
            if(reclamacionActual.Status == 'SAC_001' && reclamacionActual.SPV_VueltaAlta__c == true){
                nuevaPretension.OwnerId = reclamacionActual.SAC_PretensionPrincipal__r.OwnerId;
            }

            nuevaPretension.SAC_EsPrincipal__c = true;
            Database.insert(nuevaPretension);
          
                if(reclamacionActual.SAC_PretensionPrincipal__c != null && !lstReclamacionIds.contains(reclamacionActual.id)) {
                    pretensionPrincipal.SAC_EsPrincipal__c = false;
                    lstReclamacion.add(pretensionPrincipal);
                    lstReclamacionIds.add(pretensionPrincipal.id);
                }

                reclamacionActual.SAC_PretensionPrincipal__c = nuevaPretension.id; 
                // reclamacionActual.SAC_Entidad_Afectada__c = nuevaPretension.SAC_Entidad_Afectada__c; //Se informará en la creación del caso, se eliminan los automatismos que arrastren la Entidad Afectada desde las pretensiones
                reclamacionActual.SAC_EntidadProductora__c = nuevaPretension.SAC_EntidadProductora__c;
    
            lstReclamacion.add(reclamacionActual);
            lstReclamacionIds.add(reclamacionActual.id);
            if(!lstReclamacion.isEmpty()){
                AsyncOptions options = new AsyncOptions();
                options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                .addId(UserInfo.getUserId())
                .addString('lstReclamacionIds')
                .build();
                try {
                    System.enqueueJob(new SPV_QueueableUpdateCase(lstReclamacion), options);    
                } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);                 }                 
            }
           
        }
    }




    @TestVisible
    private static Case camposPretension(Case reclamacionActual, Id detalle, Id motivo, Id prodServ, Id tematica, Id tipoRegistro, String asunto, Map<Id, CC_MCC__c> mapaMcc){
        
        Case nuevaPretension = new Case();
     
        nuevaPretension.SAC_Reclamacion__c = reclamacionActual.Id;
        nuevaPretension.Subject = asunto;
        nuevaPretension.recordTypeId = tipoRegistro;
        nuevaPretension.status = reclamacionActual.Status;
        nuevaPretension.SAC_StatusAuxiliar__c = reclamacionActual.Status;
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
        

        //Añadido US963386
        nuevaPretension.SAC_FechaRecepcion__c = reclamacionActual.SAC_FechaRecepcion__c;

        //Quitar la siguiente linea luego
        nuevaPretension.OwnerId = reclamacionActual.OwnerId;




        if(!String.isBlank(reclamacionActual.CC_Canal_Procedencia__c)){
            nuevaPretension.CC_Canal_Procedencia__c = reclamacionActual.CC_Canal_Procedencia__c;
        } 
        if(!String.isBlank(reclamacionActual.AccountId)){
            nuevaPretension.AccountId = reclamacionActual.AccountId;
        } 
        if(!String.isBlank(reclamacionActual.ContactId)){
            nuevaPretension.ContactId = reclamacionActual.ContactId;
        } 
        return nuevaPretension;
        
    }


  @TestVisible
    private static void throwAuraHandledException( String errorMsg ){
    
        AuraHandledException auraException = new AuraHandledException( errorMsg );
        auraException.setMessage( errorMsg );
        throw auraException;
    }

    @AuraEnabled
    public static Boolean insertarPretensiones(String idCase, List<SObject> mccsPretension ) {
        
        List<Case> nuevasPretensiones = new List<Case>();
        List<Id> idsDetalle = new List<Id>();           //Lista donde no se guardan Mccs repetidos si los hay
        List<Id> idsDetalleRepetidos = new List<Id>();   //Lista donde se guardan aquellos Mccs que estén duplicados
        Set<Id> setIdsDetalleAux = new  Set<Id>();      //Copia de la lista pasada como parámetro, aquí van todos los mcc aunque estén duplicados entre ellos
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
        
        
        //Primero se comprueba que el objeto Case sea creable, si no, devuelve false directamente.
        if(!Schema.sObjectType.Case.isCreateable()){ 
             throwAuraHandledException( MSG_ERROR_PERMISSIONS );
              return false;          
             }
            
        

        //Se obtienen distintos campos de la reclamación a la que se añadirán pretensiones
        Case reclamacionActual = [SELECT Id,CC_Canal_Procedencia__c, ContactId, AccountId, SAC_TiempoSLARegulatorio__c, 
                                  SAC_TiempoSLALetradoAlta__c, Origin, Status, SPV_VueltaAlta__c,
                                  SAC_PretensionPrincipal__r.SEG_Grupo__c, SAC_PretensionPrincipal__r.OwnerId, OwnerId, SAC_CasoEspecial__c, 
                                  CC_CasoRelacionado__c, SAC_FechaRecepcion__c,
                                  CC_CasoRelacionado__r.Status, CC_CasoRelacionado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c
                                  FROM Case Where RecordType.DeveloperName LIKE 'SPV_%' AND Id =: idCase];
        
 

        //Para cada MCC pasado como parámetro
        for(SObject mcc : mccsPretension){
            if(!idsDetalle.contains(mcc.id)){   //Si el Mcc no está en la lista sin repetidos, se añade
                idsDetalle.add(mcc.Id);
            }else{
                idsDetalleRepetidos.add(mcc.Id);    //Si sí está, se añade a lista de repetidos
            }  
            setIdsDetalleAux.add(mcc.Id);      //Y se añade a la lista auxiliar de todos los Mccs
        }

        //Consulta para obtener distintos campos de las pretensiones cuyo id esté en setIdsDetalleAux
        List<CC_MCC__c> listaMccAux = [SELECT id, Name, SAC_EntidadAfectada__c, SAC_EntidadProductora__c, SAC_EsPsd2__c, CC_Motivo__c,
                                       CC_Motivo__r.CC_Producto_Servicio__c, CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c, 
                                       CC_Motivo__r.CC_Producto_Servicio__r.Name, 
                                       CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.CC_Codigo_Externo__c
                                       FROM CC_MCC__c 
                                       WHERE Id IN: setIdsDetalleAux 
                                       AND RecordType.DeveloperName = 'SAC_Detalle'];
        
                                       
                           
        //Para cada elemento MCC de la lista, se comprueba si su id está en la lista de repetidos o de no repetidos
        //En función de eso, se añade a la lista de CC_MCC__c correspondiente, a la de repetidos o a la de no
        if(!listaMccAux.isEmpty()){
            for(CC_MCC__c detalle : listaMccAux){
                if(idsDetalle.contains(detalle.Id)){
                    listaMcc.add(detalle);    
                }else if(idsDetalleRepetidos.contains(detalle.Id)){
                    listaMccRepetidos.add(detalle);    
                }   
            }    
        }
        

        //Para cada elemento de listaMCC, se rellenan los mapas
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
        
      //Para cada elemento de listaMccRepetidos, se rellenan los mapas
        if(!listaMccRepetidos.isEmpty()){
            for(CC_MCC__c detalle : listaMccRepetidos){
                detalleMotivoRepetidos.put(detalle.Id, detalle.CC_Motivo__c);
                motivoProdServRepetidos.put(detalle.CC_Motivo__c, detalle.CC_Motivo__r.CC_Producto_Servicio__c);
                prodServTematicaRepetidos.put(detalle.CC_Motivo__r.CC_Producto_Servicio__c, detalle.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c);
            }
        }
        
        if(!detalleMotivo.isEmpty()){
            Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
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
                        
                        // nuevaPretension.OwnerId = cola.Id;
                        nuevaPretension.OwnerId = reclamacionActual.OwnerId;

                    }

                    //MOD -> US1036419 -> Si la reclamación ha vuelto de análisis a alta, el owner y grupo de la nueva reclamación será igual que el de sus hermanas (igual que el de la principal)
                    if(reclamacionActual.SPV_VueltaAlta__c == true){
                        nuevaPretension.SEG_Grupo__c = reclamacionActual.SAC_PretensionPrincipal__r.SEG_Grupo__c;      
                        nuevaPretension.OwnerId = reclamacionActual.SAC_PretensionPrincipal__r.OwnerId; 
                    }else{
                    nuevaPretension.OwnerId = reclamacionActual.OwnerId;
                    }
                    nuevasPretensiones.add(nuevaPretension);    
                } else if (reclamacionActual.Status == 'SPV_AnalisisDecision') { //Si la reclamación padre está en Análisis, se crea con el owner y el grupo de la pretensión principal
                    nuevaPretension.SEG_Grupo__c = reclamacionActual.SAC_PretensionPrincipal__r.SEG_Grupo__c;      
                    nuevaPretension.OwnerId = reclamacionActual.SAC_PretensionPrincipal__r.OwnerId;
                    nuevasPretensiones.add(nuevaPretension);
                } else { throwAuraHandledException('La reclamación debe estar en alta o análisis para poder crear una o varias pretensiones');   return false;       }      
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

                    //MOD -> US1036419 -> Si la reclamación ha vuelto de análisis a alta, el owner y grupo de la nueva reclamación será igual que el de sus hermanas (igual que el de la principal)
                    if(reclamacionActual.SPV_VueltaAlta__c == true){
                        nuevaPretension.SEG_Grupo__c = reclamacionActual.SAC_PretensionPrincipal__r.SEG_Grupo__c;      
                        nuevaPretension.OwnerId = reclamacionActual.SAC_PretensionPrincipal__r.OwnerId; 
                    }

                    nuevasPretensiones.add(nuevaPretension);    
                } else if (reclamacionActual.Status == 'SPV_AnalisisDecision') { //Si la reclamación padre está en Análisis, se crea con el owner y el grupo de la pretensión principal
                    nuevaPretension.SEG_Grupo__c = reclamacionActual.SAC_PretensionPrincipal__r.SEG_Grupo__c;     
                    
                    //Descomentar la siguiente linea
                    //nuevaPretension.OwnerId = reclamacionActual.SAC_PretensionPrincipal__r.OwnerId;
                    nuevasPretensiones.add(nuevaPretension);
                } else {  throwAuraHandledException('La reclamación debe estar en alta o análisis para poder crear una o varias pretensiones');                     return false;}  
            }
        }
        

        if(!nuevasPretensiones.isEmpty()){
            Database.insert(nuevasPretensiones);
        }
        
       return true;
     }



     //Se comprueba si el id del usuario que realiza la operación, tiene permisos sobre alguna de las pretensiones del caso
     @AuraEnabled(cacheable=true)
     public static Boolean tienePermisos(String idCaso){ 
         Boolean tienePermiso= false;    
         Boolean tienePermisoEstado = false;
         try {
             
            //La pretensiones son casos
             List<Case> pretensiones = new List<Case>();
             List<Case> reclamacion = new List<Case>();
             //Se obtiene una lista con las pretensiones cuya reclamación (SAC_Rclamacion) sea el id de la reclamación bucada y el record type sea una pretensión.
             pretensiones = [SELECT Id, SAC_Reclamacion__c, OwnerId 
                             FROM Case 
                             WHERE SAC_Reclamacion__c =: idCaso AND Status <> 'SAC_009' AND RecordTypeId =:RECORDTYPEPRETENSION];


            reclamacion = [SELECT Status FROM Case WHERE Id =: idCaso];

            //Se reocrren las pretensiones, y si alguna tiene como owner el id del usuario, entonces se devolveerá true indicando que sí tiene permisos
             if(!pretensiones.isEmpty()){
                 for (Case caso : pretensiones) {
                     if(caso.OwnerId == UserInfo.getUserId()){
                         tienePermiso=true;
                         break;
                     }
                 }
             }    
             
             if(!reclamacion.isEmpty()){
                for(Case recla : reclamacion){
                    if(recla.Status == 'SAC_001' || recla.Status == 'SPV_AnalisisDecision'){
                        tienePermisoEstado = true;
                        break;
                    }
                }
             }
             
         } catch (Exception e) {
             throw new AuraHandledException(e.getMessage());
         }
         return  tienePermisoEstado; //tienePermiso &&
         //return tienePermiso;
     }


}