/*****************************************************************
 * Name: SAC_CargaMasiva
 * Copyright © 2021  CaixaBank
 * 
 * @description Proposito: Hacer copias masivas de una reclamación y sus pretensiones
 * Clase test que cubre el código: SAC_LCMP_CopiaMasivaCasos_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US308696         Carlos Solis   14/03/2022   Creación
*****************************************************************/
public with sharing class SAC_CargaMasiva implements Queueable {

    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    List<Case> listaCasosOriginales;
    Group cola;
    Map<Id, List<ContentDocumentLink>> mapaConDocLink;
    private Integer copiasAHacer;
    public Integer totalCopias;

    public SAC_CargaMasiva(List<Case> listaCasosOriginalesC, Group colaC, Map<Id, List<ContentDocumentLink>> mapaConDocLinkC, Integer copiasAHacerC, Integer totalCopiasC) {
        listaCasosOriginales = listaCasosOriginalesC;
        cola = colaC;
        mapaConDocLink = mapaConDocLinkC;
        copiasAHacer = copiasAHacerC;
        totalCopias = totalCopiasC;
        if (totalCopias < 6) {
            copiasAHacer = totalCopias;
        }
    }

    public void execute(QueueableContext context) {   
        try {
            //Creacion listas y mapas
            List<Case> listaReclamacionCopiar = new List<Case>();
            List<Case> listaPretensionesCopiar = new List<Case>();
            Map<Id, List<Case>> mapaRecOriginalCopias = new Map<Id, List<Case>>();
            Map<Id, List<Case>> mapaPretOriginalCopias = new Map<Id, List<Case>>();
            Map<Id, Map<Id, List<Case>>> mapaOriginalCopiaPretsCopias = new Map<Id, Map<Id, List<Case>>>();
            Map<Id, Id> mapaRecPretPrincipal = new Map<Id, Id>();
            Map<Id, Case> mapaRecPretPrincipalCopias = new Map<Id, Case>();
            Boolean reclamacionTieneCheckAdjuntos = false;

            //Bucle con las veces que queremos copiar cada reclamacion
            Integer contadorRec = 0;
            while (contadorRec < copiasAHacer) {
                //Reclamacion que va a copiarse, se hace la copia y se añade a la lista de reclamaciones para insertar
                for (Case caso : listaCasosOriginales) {
                    if (caso.RecordTypeId == RECORDTYPERECLAMACION) {
                        Case casoCopia = new Case();
                        casoCopia = caso.clone(false, false, false, false);
                        reclamacionTieneCheckAdjuntos = caso.CC_SuppliedFiles__c;

                        //Guardar pretension principal original
                        if (String.isNotBlank(caso.SAC_PretensionPrincipal__c)) {
                            mapaRecPretPrincipal.put(caso.Id, caso.SAC_PretensionPrincipal__c);
                        }

                        //Campos a cambiar
                        casoCopia.SAC_CasoRelacionado__c = caso.Id; //Poner la Id de la reclamación original
                        casoCopia.OwnerId = cola.Id; //Deberia de ser la cola pdte asignar
                        casoCopia.CC_CasoRelacionado__c = null;
                        casoCopia.SAC_PretensionPrincipal__c = null;
                        casoCopia.CC_Detalles_Solucion__c = null;

                        //Campos que no queremos que se copien
                        casoCopia.AccountId = null;
                        casoCopia.CC_SuppliedNIF__c = null;
                        //casoCopia.SAC_EsCliente__c = false;
                        casoCopia.SAC_MotivoRechazo__c = null;
                        casoCopia.SAC_TipoConsumidor__c = null;
                        casoCopia.SAC_ReclamanteConformeNegociacion__c = false;
                        casoCopia.SAC_Antecedentes_Revisados__c = false;
                        casoCopia.ContactId = null;
                        casoCopia.SAC_NombreContacto__c = null;
                        casoCopia.SAC_UsarDatos__c = false;
                        casoCopia.OS_Email__c = null;
                        casoCopia.CC_Telefono_Contacto__c = null;
                        casoCopia.SAC_DireccionContacto__c = null;
                        casoCopia.SAC_CodigoPostalContacto__c = null;
                        casoCopia.SAC_PoblacionContacto__c = null;
                        casoCopia.SAC_ProvinciaContacto__c = null;
                        casoCopia.SAC_PaisContacto__c = null;
                        casoCopia.SAC_DireccionPostalNotificacion__c = null;
                        casoCopia.CC_SuppliedFiles__c = false;
                        
                        //Guardar reclamacion en lista (para actualizar) y mapa (para acceder a los valores)
                        listaReclamacionCopiar.add(casoCopia);
                        if (mapaRecOriginalCopias.containsKey(caso.Id)) {
                            mapaRecOriginalCopias.get(caso.Id).add(casoCopia);
                        } else {
                            List<Case> listaCopias = new List<Case>();
                            listaCopias.add(casoCopia);
                            mapaRecOriginalCopias.put(caso.Id, listaCopias);
                        }

                        totalCopias = totalCopias - 1;
                    }
                }
                contadorRec++;
            }

            //Insert de la reclamacion para tener su id y poder insertar sus pretensiones hijas
            SAC_DatabaseDML.insertListDML(listaReclamacionCopiar, true);

            //Recorrer de nuevo la lista de originales para copiar las pretensiones apuntando a sus padres
            for (Case caso : listaCasosOriginales) {
                Integer contadorPret = 0;
                while (contadorPret < copiasAHacer) {
                    if (caso.RecordTypeId == RECORDTYPEPRETENSION && mapaRecOriginalCopias.containsKey(caso.SAC_Reclamacion__c)) {
                        Case casoCopia = new Case();
                        casoCopia = caso.clone(false, false, false, false);

                        //Campos a cambiar
                        casoCopia.SAC_CasoRelacionado__c = caso.Id; //Poner la Id de la pretensión original
                        casoCopia.SAC_Reclamacion__c = mapaRecOriginalCopias.get(caso.SAC_Reclamacion__c)[contadorPret].Id; //Tiene la Id de la copia padre
                        casoCopia.OwnerId = cola.Id; //Deberia de ser la cola pdte asignar
                        casoCopia.CC_Detalles_Solucion__c = null;

                        //Comprobar si es pret principal
                        if (mapaRecPretPrincipal.containsKey(caso.SAC_Reclamacion__c) && mapaRecPretPrincipal.get(caso.SAC_Reclamacion__c) == casoCopia.SAC_CasoRelacionado__c) {
                            //Asigno la pretension principal de la copia padre
                            mapaRecPretPrincipalCopias.put(mapaRecOriginalCopias.get(caso.SAC_Reclamacion__c)[contadorPret].Id, casoCopia);
                        }

                        //Campos que no queremos que se copien
                        casoCopia.AccountId = null;
                        casoCopia.CC_SuppliedNIF__c = null;
                        //casoCopia.SAC_EsCliente__c = false;
                        casoCopia.SAC_MotivoRechazo__c = null;
                        casoCopia.SAC_TipoConsumidor__c = null;
                        casoCopia.SAC_ReclamanteConformeNegociacion__c = false;
                        casoCopia.SAC_Antecedentes_Revisados__c = false;
                        casoCopia.ContactId = null;
                        casoCopia.SAC_NombreContacto__c = null;
                        casoCopia.SAC_UsarDatos__c = false;
                        casoCopia.OS_Email__c = null;
                        casoCopia.CC_Telefono_Contacto__c = null;
                        casoCopia.SAC_DireccionContacto__c = null;
                        casoCopia.SAC_CodigoPostalContacto__c = null;
                        casoCopia.SAC_PoblacionContacto__c = null;
                        casoCopia.SAC_ProvinciaContacto__c = null;
                        casoCopia.SAC_PaisContacto__c = null;
                        casoCopia.SAC_DireccionPostalNotificacion__c = null;
                        casoCopia.CC_SuppliedFiles__c = false;

                        //Guardar la pretension en una lista de pretensiones para insertar y en mapa para acceder a ellas y poder poner sus adjuntos
                        listaPretensionesCopiar.add(casoCopia);
                        if (mapaPretOriginalCopias.containsKey(caso.Id)) {
                            mapaPretOriginalCopias.get(caso.Id).add(casoCopia);
                        } else {
                            List<Case> listaCopias = new List<Case>();
                            listaCopias.add(casoCopia);
                            mapaPretOriginalCopias.put(caso.Id, listaCopias);
                        }
                    }
                    contadorPret++;
                }
                
            }

            //Insert de las pretensiones hijas
            SAC_DatabaseDML.insertListDML(listaPretensionesCopiar, true);

            //Asignar adjuntos a las reclamaciones y las pretensiones, si es que existen adjuntos
            if (!mapaConDocLink.isEmpty()) {
                List<ContentDocumentLink> listaCDLCopiar = new List<ContentDocumentLink>();

                //Reclamaciones
                for (Id idCaso : mapaRecOriginalCopias.keySet()) {
                    if (mapaConDocLink.containsKey(idCaso)) {
                        for (Case casoCopia : mapaRecOriginalCopias.get(idCaso)) {
                            for (ContentDocumentLink cdl : mapaConDocLink.get(idCaso)) {
                                ContentDocumentLink copiaCDL = new ContentDocumentLink();
                                copiaCDL.LinkedEntityId = casoCopia.Id;
                                copiaCDL.ContentDocumentId = cdl.ContentDocumentId;
                                copiaCDL.Visibility = cdl.Visibility;
                                copiaCDL.ShareType = cdl.ShareType;
                                listaCDLCopiar.add(copiaCDL);
                            }
                        }
                    }
                }
                //Pretensiones
                for (Id idCaso : mapaPretOriginalCopias.keySet()) {
                    if (mapaConDocLink.containsKey(idCaso)) {
                        for (Case casoCopia : mapaPretOriginalCopias.get(idCaso)) {
                            for (ContentDocumentLink cdl : mapaConDocLink.get(idCaso)) {
                                ContentDocumentLink copiaCDL = new ContentDocumentLink();
                                copiaCDL.LinkedEntityId = casoCopia.Id;
                                copiaCDL.ContentDocumentId = cdl.ContentDocumentId;
                                copiaCDL.Visibility = cdl.Visibility;
                                copiaCDL.ShareType = cdl.ShareType;
                                listaCDLCopiar.add(copiaCDL);
                            }
                        }
                    }
                }

                //Insertar archivos adjuntos
                SAC_DatabaseDML.insertListDML(listaCDLCopiar, true);
            }

            //Update reclamaciones con pretension principal y sus checks de adjuntos
            if (!mapaRecPretPrincipalCopias.isEmpty()) {
                List<Case> listaCasos = new List<Case>();

                for (Case caso : listaReclamacionCopiar) {

                    if (mapaRecPretPrincipalCopias.containsKey(caso.Id)) {
                        caso.SAC_PretensionPrincipal__c = mapaRecPretPrincipalCopias.get(caso.Id).Id;
                    }
                    if (reclamacionTieneCheckAdjuntos) {
                        caso.CC_SuppliedFiles__c = reclamacionTieneCheckAdjuntos;
                    }
                    caso.CC_SuppliedID__c = SAC_Utils.creacionThreadID(caso.Id);
                }

                for (Case pret : listaPretensionesCopiar) {
                    pret.CC_SuppliedID__c = SAC_Utils.creacionThreadID(pret.Id);
                }

                //Updatear reclamaciones copia
                listaCasos.addAll(listaReclamacionCopiar);
                listaCasos.addAll(listaPretensionesCopiar);

                //SAC_DatabaseDML.insertListDML(listaCasos, true);
                SAC_DatabaseDML.updateListDML(listaCasos, true);
            }
            
            
            //Encola el siguiente job si aún no ha acabado con todas las copias que debe hacer
            if (totalCopias > 0) {
                DateTime dt = DateTime.now();
		        Long dateInMilliseconds = dt.getTime();
                AsyncOptions options = new AsyncOptions();
                options.DuplicateSignature = QueueableDuplicateSignature.Builder().addId(UserInfo.getUserId()).addString(String.valueOf(dateInMilliseconds)).build();
                try {
                    System.enqueueJob(new SAC_CargaMasiva(listaCasosOriginales, cola, mapaConDocLink, copiasAHacer, totalCopias), options);    
                } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);                 } 
            } else if(!Test.isRunningTest()) {
                //Si ha acabado de hacer todas las copias, llamo a que finalice el proceso y mande el email de éxito
                DateTime dt = DateTime.now();
		        Long dateInMilliseconds = dt.getTime();
                AsyncOptions options = new AsyncOptions();
                options.DuplicateSignature = QueueableDuplicateSignature.Builder().addId(UserInfo.getUserId()).addString(String.valueOf(dateInMilliseconds)).build();
                try {
                    System.enqueueJob(new SAC_FinalizarProcesoCopia(listaCasosOriginales, false), options);    
                } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);                 }    
            }
        } catch (Exception e) {
            //Si hay un error, se mandará el correo de error
            DateTime dt = DateTime.now();
		    Long dateInMilliseconds = dt.getTime();
            AsyncOptions options = new AsyncOptions();
            options.DuplicateSignature = QueueableDuplicateSignature.Builder().addId(UserInfo.getUserId()).addString(String.valueOf(dateInMilliseconds)).build();
            try {
                System.enqueueJob(new SAC_FinalizarProcesoCopia(listaCasosOriginales, true), options);    
            } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);                 }      
        }
    
    }
}