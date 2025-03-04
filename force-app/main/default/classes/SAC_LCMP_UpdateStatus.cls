/*****************************************************************
 * Name: SAC_LCMP_UpdateStatus
 * Copyright © 2021  CaixaBank
 * ***************************************************************
 * Proposito: Controlador  para poder modificar el estado de las reclamaciones desde la botonera 
 *              
 *   LWC asociado: sAC_EstadosReclamacion
 * ***************************************************************
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US213188         Luis Mesa     04/05/21      Creación Clase
 * 1.1            US242676         Marcela Neira 30/06/21      Modificación Creación de un nuevo método para
 *                                                             dejar un mensaje en el chatter
 * 1.2            US271700         Marcela Neira 29/10/21      Modificación, creación de un nuevo método para
 *                                                             guardar el motivo de la inadmisión
*****************************************************************/
public without sharing class SAC_LCMP_UpdateStatus {

    private static Set<String> objetos = new Set<String>{'Case', 'SAC_Accion__c', 'SAC_MaestroAccionesReclamacion__c', 'SAC_MaestroTemas__c', 'CC_Grupo_Colaborador__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final String MSG_ERROR_PERMISSIONS = 'No tienes permisos para realizar la acción.';
    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    private static final Id RECTYPECONSULTASAC = mapRTsObjects.get('Case').get('SAC_ConsultaSAC').getRecordTypeId();
    private static final String RECTYPEMAESTROACCIONES = mapRTsObjects.get('SAC_MaestroAccionesReclamacion__c').get('SAC_MaestroAcciones').getRecordTypeId();
    private static final String RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_MaestroDeTareas').getRecordTypeId();
    private static final String RECTYPEMAESTROTEMASFT = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_FastTrack').getRecordTypeId();
    private static final String RECTYPEGRUPOLETRADOS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_Letrados').getRecordTypeId();
    private static final String RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_BlackListEmails').getRecordTypeId();

    private static final String STATUS_ALTA = 'SAC_001';

    /*
    Wrapper para retornar datos relacionados con el fast track
    */
    public class WrapperFastTrack{
        public List<Case> listaCasosActualizar = new List<Case>();
        public List<SAC_Accion__c> listaAcciones = new List<SAC_Accion__c>();
        public Boolean mandarEmail = false;
        public Boolean enviarAcuseRecibo = false;
    }


    //Método en el que se verá si el campo consumidor de la reclamación está relleno en el momento en el que todas las pretensiones estén en resolución
    //El id de pretensión actual es la que se ha pulsado para que pase al estado de Resolución
    //Se devolverá false en caso de no estar informado
    @AuraEnabled
    public static Boolean comprobarConsumidorReclamacion(Id idReclamacionPadre, Id idPretensionActual){

        //Obtengo tanto la reclamación principal como las pretensiones
        List<Case> listaCasos = [SELECT Id, RecordTypeId, SAC_TipoConsumidor__c, Status FROM Case WHERE (Id = :idReclamacionPadre OR SAC_Reclamacion__c = :idReclamacionPadre)];

        //Separar la reclamación de las pretensiones
        Case reclamacion = new Case();
        List<Case> listaPretensiones = new List<Case>();
        Case pretensionActualizar = new Case();

        for(Case caso : listaCasos){
            if(caso.RecordTypeId == RECTYPERECLAMACION){
                reclamacion = caso; 
            }else if(caso.RecordTypeId == RECTYPEPRETENSION){
                if(caso.Id == idPretensionActual){
                    pretensionActualizar = caso;
                }
                listaPretensiones.add(caso);
            }
        }


        //Comprobar primero si con esta actualización de estado de pretensión, todas las pretensiones estarán en resolución o en baja
        Boolean todasPretResolucion = true;
        //Boolean alMenosUnaResolucion = false;
        for(Case pretension : listaPretensiones){
            //La pretensionActual es la que está pasando a resolución (porque ha entrado a este método), asique solo habrá que comprobar que el resto esté en resolución o baja
            if(pretension.Id != idPretensionActual && pretension.Status != 'SAC_003' && pretension.Status != 'SAC_009'){
                todasPretResolucion = false;    //Se pone a false si hay alguna que no está en resolución o baja
            }
            /*else{
                if((pretension.Id != idPretensionActual && pretension.Status == 'SAC_003') || (pretension.Id == idPretensionActual && nuevoEstado == 'SAC_003')){
                    alMenosUnaResolucion = true;    //Controlar que no estén todas en BAJA
                }
            }*/
        }

        //Si todas las pretensiones van a estar en resolución, entonces se comprueba que el campo consumidor de la reclamación esté relleno
        if(todasPretResolucion == true){

            //Si la pertensión está en estado de alta y entra a este método es que va a darse de baja
            //Solo se pueden poner TODAS en baja en estado de alta, después ya no, por eso no hace falta controlar que no estén todas en baja
            if(pretensionActualizar.Status == 'SAC_001' /*&& listaPretensiones.size() == 1*/){
                return true;    //Si la pretensión está en estado de alta, sí, se le permite  actualizarla a estado de Baja
            }

            if(reclamacion.SAC_TipoConsumidor__c == null || String.isBlank(reclamacion.SAC_TipoConsumidor__c)){
                return false;       //Si el campo no está informado, se devuelve false
            }else{
                return true;        
            }
        }else{
            //Si no todas las pretensiones están en resolución (o algunas en baja y otras en resolución), entonces se devuelve true, para permitir el update sin neceidad del campo consumidor relleno
            return true;
        }
    }


    @AuraEnabled
    public static void updateRecordStatus(Id record, String newStatus){
        /*****************************************************************
         * Proposito: Método para actualizar el estado de las reclamaciones y dejar cambios en BBDD
         * ***************************************************************
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0             US213188       Luis Mesa      04/05/21       Creación Método
         * 1.1             US994116      Raúl Santos     12/09/24       Modificación: Si la reclamación está en estado 'Alta' y no se ha enviado el acuse de recibo, se envia automáticamente al pasar a subsanación (tanto vía email como carta postal)
        *****************************************************************/
        
        if(!Schema.sObjectType.Case.isAccessible()){ throw new AuraHandledException( 'Fallo al actualizar.' ); }
        
        List<Case> listaCaso = [SELECT Id, Status, SAC_Reclamacion__c, SAC_Reclamacion__r.SAC_PretensionPrincipal__c, SAC_EsPrincipal__c, SAC_Reclamacion__r.SAC_NPretensionesActivas__c, SAC_IndicadorRevisado__c, RecordTypeId, CC_AcuseRecibo__c, Origin, CaseNumber, CC_Idioma__c, 
                                SuppliedEmail, OS_Email__c, CC_Canal_Respuesta__c, SAC_M2P__c, SAC_PaisContacto__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_NombreContacto__c, CreatedDate
                                FROM Case 
                                WHERE RecordTypeId IN (:RECTYPERECLAMACION, :RECTYPEPRETENSION) AND Id =: record];
        
        Boolean enviarAcuse = false;
        if(!listaCaso.isEmpty()){
            Case casoPorActualizar = listaCaso[0];
            if(casoPorActualizar.RecordTypeId == RECTYPERECLAMACION && casoPorActualizar.CC_AcuseRecibo__c != '2' && casoPorActualizar.Status == 'SAC_001'){
                if(casoPorActualizar.CC_Canal_Respuesta__c == 'SAC_CartaPostal' && (casoPorActualizar.SAC_DireccionContacto__c == null || casoPorActualizar.SAC_CodigoPostalContacto__c == null || casoPorActualizar.SAC_PoblacionContacto__c == null || casoPorActualizar.SAC_ProvinciaContacto__c == null || casoPorActualizar.SAC_PaisContacto__c == null)){
                    throw new AuraHandledException('Revise que están informados todos los campos de la dirección de contacto del reclamante para que se pueda crear la carta postal del acuse de recibo.');
                }else if(casoPorActualizar.CC_Canal_Respuesta__c == 'Email' && (casoPorActualizar.SuppliedEmail == null && casoPorActualizar.OS_Email__c == null)){
                    throw new AuraHandledException('Revise que hay informado un correo asociado al reclamante para que se pueda realizar el envío del acuse de recibo.');
                }else{
                    enviarAcuse = true;
                    casoPorActualizar.CC_AcuseRecibo__c = '2';
                }
            }
            
            casoPorActualizar.Status = newStatus;
            casoPorActualizar.SAC_StatusAuxiliar__c = newStatus;
            
            List<Case> listaCasosActualizar = new List<Case>();
            if(Case.SObjectType.getDescribe().isUpdateable()){
                try {
                    /*
01/12/22 Se ha añadido esta condición para cuando se esté dando de baja la pretension principal de la familia de casos.
Cuando esto ocurre, se manda a actualizar también la reclamación padre quitandole los campos del mcc y los campos que traía del mcc.
*/
                    if (casoPorActualizar.Status == 'SAC_009' && casoPorActualizar.SAC_Reclamacion__r.SAC_PretensionPrincipal__c == casoPorActualizar.Id) { 
                        casoPorActualizar.SAC_EsPrincipal__c = false;  
                        
                        Case reclamacionPadreActualizar = new Case();
                        reclamacionPadreActualizar.Id = casoPorActualizar.SAC_Reclamacion__c;
                        reclamacionPadreActualizar.CC_MCC_Tematica__c = null;
                        reclamacionPadreActualizar.CC_MCC_ProdServ__c = null;
                        reclamacionPadreActualizar.CC_MCC_Motivo__c = null;
                        reclamacionPadreActualizar.SEG_Detalle__c = null;
                        
                        reclamacionPadreActualizar.SAC_Motivo_BDE__c = null;
                        reclamacionPadreActualizar.SAC_FamiliaBdE__c = null;
                        reclamacionPadreActualizar.SAC_ProductoBDE__c = null;
                        reclamacionPadreActualizar.SAC_FamiliaMotivoBdE__c = null;
                        reclamacionPadreActualizar.SAC_DGS__c = null;
                        reclamacionPadreActualizar.SAC_Producto2BdE__c = null;
                        reclamacionPadreActualizar.SAC_MotivoReclamacion__c = null;
                        reclamacionPadreActualizar.SAC_AgrupacionesFamilias__c = null;
                        reclamacionPadreActualizar.SAC_ServicioInversion__c = null;
                        reclamacionPadreActualizar.SAC_PretensionPrincipal__c = null;
                        
                        listaCasosActualizar.add(reclamacionPadreActualizar);
                    }
                    
                    listaCasosActualizar.add(casoPorActualizar);
                    if(!listaCasosActualizar.isEmpty()){
                        SAC_DatabaseDML.updateListDML(listaCasosActualizar, true); 
                        //Database.update(listaCasosActualizar);
                    }
                    
                    if(enviarAcuse){
                        if(casoPorActualizar.CC_Canal_Respuesta__c == 'SAC_CartaPostal'){
                            String pais = '';
                            
                            if(casoPorActualizar.SAC_PaisContacto__c.trim().toLowerCase().contains('españa')){
                                pais = '011';
                            }else{
                                pais = '000';
                            }
                            
                            SAC_LCMP_AcuseReciboCartaPostal.envioCartaPostal(casoPorActualizar, casoPorActualizar.SAC_DireccionContacto__c, casoPorActualizar.SAC_CodigoPostalContacto__c, casoPorActualizar.SAC_PoblacionContacto__c, casoPorActualizar.SAC_ProvinciaContacto__c, pais);
                            
                        }else if(casoPorActualizar.CC_Canal_Respuesta__c == 'Email'){
                            List<Case> casos = new List<Case>();
                            casos.add(casoPorActualizar);
                            Map<Id, Case> mapa = new Map<Id, Case>();
                            SAC_AcuseRecibo_Email.envioAcuseRecibo(casos, mapa);
                        }else{
                            Case casoAcusePte = new Case(Id = casoPorActualizar.Id, CC_AcuseRecibo__c = '1');
                            SAC_DatabaseDML.updateDML(casoAcusePte, true);
                        }
                    } 
                    
                } catch (Exception e) { 
                    CBK_Log.error(e);
                    String errorMsg = e.getMessage();
                    String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
                    if (String.isNotBlank(pureErrorMsg)) {
                        pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-4));
                        throw new AuraHandledException(pureErrorMsg);
                    } else {
                        throw new AuraHandledException(e.getMessage());
                    }
                }
                
            } else{ throw new AuraHandledException( 'Fallo al actualizar.' ); }
        } else {
            throw new AuraHandledException( 'No se ha encontrado el caso' );
        }
    }

    /*****************************************************************
     * Proposito: Método para subsanar y enviar correo correspondiente a la vez
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                ---       Daniel Benito    09/11/21       Creación Método
     * 1.1             US994116      Raúl Santos     05/09/24       Modificación: Al subsanar envía el acuse de recibo (siempre y cuando no haya sido enviado previamente, y el estado actual de la reclamacion sea alta)
     * 1.2             US994116      Raúl Santos     12/09/24       Modificación: Si la reclamación está en estado 'Alta' y no se ha enviado el acuse de recibo, se envia automáticamente al pasar a subsanación (tanto vía email como carta postal)
    *****************************************************************/
    @AuraEnabled
    public static void subsanarCaso(Id record, String motivo, String newStatus, String para, String copia, String copiaOculta, String cuerpo, String asunto, String ficherosAdjuntos){

       // updateRecordStatus(record, newStatus);
        Case casoPorActualizar = [SELECT Id, Status, SAC_MotivoInadmision__c, CC_AcuseRecibo__c, Origin, CC_Idioma__c, SuppliedEmail, CaseNumber, OS_Email__c, SAC_M2P__c, RecordTypeId, CC_Canal_Respuesta__c
                                    FROM Case 
                                    WHERE RecordType.DeveloperName LIKE 'SAC_%' AND Id =: record];

        
        Boolean enviarAcuse = false;

        if(casoPorActualizar.RecordTypeId == RECTYPERECLAMACION && casoPorActualizar.CC_AcuseRecibo__c != '2' && casoPorActualizar.Status == 'SAC_001'){
            if(casoPorActualizar.SuppliedEmail == null && casoPorActualizar.OS_Email__c == null){
                throw new AuraHandledException('Revise que hay informado un correo asociado al reclamante para que se pueda realizar el envío del acuse de recibo.');
            }else{
                enviarAcuse = true;
                casoPorActualizar.CC_AcuseRecibo__c = '2';
            }
        }
        casoPorActualizar.Status = newStatus;
        casoPorActualizar.SAC_StatusAuxiliar__c = newStatus;
        casoPorActualizar.SAC_TipoSubsanacion__c = motivo;
        
        SAC_DatabaseDML.updateDML(casoPorActualizar, false); 
        //Database.update(casoPorActualizar);  

        // Si el correo electrónico web del caso no es nulo se tiene que enviar un email indicando que se ha enviado la subsanación del caso
        if(String.isNotBlank(casoPorActualizar.SuppliedEmail)) {  
            comunicarResolucion(casoPorActualizar);
        }
        
        SAC_LCMP_GestionEmails.enviarEmail(record, para, copia, copiaOculta,cuerpo, asunto, ficherosAdjuntos, null);

        if(enviarAcuse){
            List<Case> casos = new List<Case>();
            casos.add(casoPorActualizar);
            Map<Id, Case> mapa = new Map<Id, Case>();
            SAC_AcuseRecibo_Email.envioAcuseRecibo(casos, mapa);
        }   
    }

    @AuraEnabled
    public static String subsanarCasoCartaPostal(Id record, String motivo, String newStatus){
        string maestroTarea = '';
        List<Case> listaCasos = new List<Case>();
        List<SAC_DocumentoEnvio__c> listaDocumentoEnvio = new List<SAC_DocumentoEnvio__c>();

        Case casoPorActualizar = new Case();
       // updateRecordStatus(record, newStatus);
       listaCasos = [SELECT Id, Status, SAC_MotivoInadmision__c, CC_AcuseRecibo__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreContacto__c, CaseNumber, Origin, CC_Idioma__c, 
                                        SuppliedEmail, OS_Email__c, CreatedDate, RecordTypeId, SAC_CasoEspecial__c, CC_Canal_Procedencia__c, CC_Canal_Respuesta__c
                                    FROM Case 
                                    WHERE Id =: record LIMIT 1];

        if(!listaCasos.isEmpty()){

            casoPorActualizar = listaCasos[0];
            Boolean enviarAcuse = false;
    
            if(casoPorActualizar.RecordTypeId == RECTYPERECLAMACION && casoPorActualizar.CC_AcuseRecibo__c != '2'){
                if(casoPorActualizar.SAC_DireccionContacto__c == null || casoPorActualizar.SAC_CodigoPostalContacto__c == null || casoPorActualizar.SAC_PoblacionContacto__c == null || casoPorActualizar.SAC_ProvinciaContacto__c == null || casoPorActualizar.SAC_PaisContacto__c == null){
                    throw new AuraHandledException('Revise que están informados todos los campos de la dirección de contacto del reclamante para que se pueda crear la carta postal del acuse de recibo.');
                }else{
                    enviarAcuse = true;
                    casoPorActualizar.CC_AcuseRecibo__c = '2';
                }
            }
            casoPorActualizar.Status = newStatus;
            casoPorActualizar.SAC_StatusAuxiliar__c = newStatus;
            casoPorActualizar.SAC_TipoSubsanacion__c = motivo;

            SAC_DocumentoEnvio__c carta = new SAC_DocumentoEnvio__c();
            listaDocumentoEnvio = [SELECT id FROM SAC_DocumentoEnvio__c WHERE  SAC_Caso__c =:record  AND SAC_Documento__c = null AND SAC_TipoDocumento__c =: 'subsanación' LIMIT 1];
           
            if(!listaDocumentoEnvio.isEmpty()){
                carta = listaDocumentoEnvio[0];

                /*
                Ya no se utiliza, ahora sacamos la URL de visualforce directamente con la nueva clase DomainCreator
                String hostname = System.Url.getSalesforceBaseUrl().getHost();
                String myDomain = hostname.split('\\.')[0];
                */
        
                String vfHostname = DomainCreator.getVisualforceHostname(null);
                String urlVF = 'https://' + vfHostname + '/apex/SAC_CartaPDF?id=' + carta.Id;
        
                SAC_GeneracionCartas.adjuntarPDFaCaso2(urlVF, record, 'subsanación');
        
                SAC_DatabaseDML.updateDML(casoPorActualizar, false); 
                //Database.update(casoPorActualizar);  

                // Si el correo electrónico web del caso no es nulo se tiene que enviar un email indicando que se ha enviado la subsanación del caso
                if(String.isNotBlank(casoPorActualizar.SuppliedEmail)) {  
                    comunicarResolucion(casoPorActualizar);
                }
        
                if(enviarAcuse){
        
                    String pais = '';
        
                    if(casoPorActualizar.SAC_PaisContacto__c != null){
                        if(casoPorActualizar.SAC_PaisContacto__c.trim().toLowerCase().contains('españa')){
                            pais = '011';
                        }
                    }else{
                        pais = '000';
                    }
        
                    SAC_LCMP_AcuseReciboCartaPostal.envioCartaPostal(casoPorActualizar, casoPorActualizar.SAC_DireccionContacto__c, casoPorActualizar.SAC_CodigoPostalContacto__c, casoPorActualizar.SAC_PoblacionContacto__c, casoPorActualizar.SAC_ProvinciaContacto__c, pais);
                } 
                
                if(casoPorActualizar.SAC_CasoEspecial__c == 'SAC_Presidencia'){
                    maestroTarea = 'SAC_ImprimirCartasAD';
                }else if(casoPorActualizar.CC_Canal_Procedencia__c == 'Castilla la Mancha' || casoPorActualizar.CC_Canal_Procedencia__c == 'Junta Andalucia'){
                    maestroTarea = 'SAC_ImprimirCartasJACM';
                }else{
                    maestroTarea = 'SAC_ImprimirCartasOrdinario';
                }
                //US1101520 crear tarea al subsanar por carta postal
                SAC_MaestroAccionesReclamacion__c maestroTareaAutomatica = [SELECT Id, Name FROM SAC_MaestroAccionesReclamacion__c WHERE RecordTypeId = :RECTYPEMAESTROACCIONES AND SAC_Activo__c = true AND SAC_DeveloperName__c = :maestroTarea LIMIT 1];  

                SAC_Accion__c tarea = new SAC_Accion__c();

                tarea.SAC_MaestroAccionesReclamacion__c = maestroTareaAutomatica.Id;
                tarea.RecordTypeId = RECTYPEMAESTROTAREAS;
                tarea.SAC_Reclamacion__c = record;
                
                try {
                    if (!Schema.sObjectType.SAC_Accion__c.isCreateable()) { throw new AuraHandledException( 'No tienes permisos para realizar esta accion.' ); }
                    SAC_DatabaseDML.insertDML(tarea, true);
                } catch (Exception e) {
                    CBK_log.error(e);
                }

                // FALLA POR List has more than 1 row for assignment to SObject ya que recupera la carta del acuse de recibo y la del envio de subsanacion
                ContentVersion cv = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId =: record order by CreatedDate DESC LIMIT 1];
                ContentDocumentLink cdl = new ContentDocumentLink();

                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.LinkedEntityId = tarea.Id;
                cdl.ShareType = 'I';

                SAC_DatabaseDML.insertDML(cdl, true);

                return tarea.Id;

    
            }else{
                throw new AuraHandledException( 'Es necesario asociar un cliente y generar la carta correspondiente a la hora de subsanar.' );
            }
        }else{
            throw new AuraHandledException( 'No se ha podido encontrar el caso.' );
        }

       

    }

    /**
    * Proposito: Envio Comunicación Resolución Mail
    */
    public static void comunicarResolucion(Case casoActual){
        Boolean continuarProceso = true;

        //Recuperar los dominios activos en el metadata SAC_BlacklistDominioEmail__mdt
        List<SAC_BlacklistDominioEmail__mdt> listDominiosBloqueados = [SELECT SAC_DominioEmail__c FROM SAC_BlacklistDominioEmail__mdt WHERE SAC_DominioActivo__c = true];

        if(!listDominiosBloqueados.isEmpty()){
            Set<String> dominiosBloqueados = new Set<String>();

            for(SAC_BlacklistDominioEmail__mdt dominio : listDominiosBloqueados) {
                dominiosBloqueados.add(dominio.SAC_DominioEmail__c);
            }

            String webEmail = casoActual.SuppliedEmail;
            String dominioWebEmail = '@' + webEmail.substringAfter('@');

            //Si el dominio del web email, esta contenido en los dominios activos de la blacklist de dominios, no se envia la comunicación
            if(dominiosBloqueados.contains(dominioWebEmail)){
                continuarProceso = false;
            }
        }

        if(continuarProceso){
            //Recupero los emails no validos de envio (emails en la blackList)
            List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];

            //Compruebo la dirección de envio con las de la blackList
            List<String> listaDireccionesPara = new List<String>{ casoActual.SuppliedEmail };
            List<String> emailsValidos = SAC_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, listaDireccionesPara);

            //Si la dirección de envio es válida (no está en la blackList), continuo el proceso
            if(!emailsValidos.isEmpty()){
                List<String> body = new List<String>();
                Id idPlantillaAviso = null;
                List<SAC_PlantillaRedaccion__c> lstPlantillas = [SELECT Id, SAC_PlantillaCatalanId__c, SAC_PlantillaCastellanoId__c, SAC_PlantillaInglesId__c, SAC_PlantillaEuskeraId__c, SAC_PlantillaGallegoId__c, SAC_PlantillaValencianoId__c FROM SAC_PlantillaRedaccion__c WHERE SAC_TipoPlantilla__c = 'SAC_AvisoResolucionSubsanacion'];

                if(lstPlantillas != null && !lstPlantillas.isEmpty()){
                    for(SAC_PlantillaRedaccion__c plantilla : lstPlantillas){
                        if(casoActual.CC_Idioma__c == 'es'){ idPlantillaAviso = plantilla.SAC_PlantillaCastellanoId__c;
                        } else if(casoActual.CC_Idioma__c == 'ca'){ idPlantillaAviso = plantilla.SAC_PlantillaCatalanId__c;
                        } else if(casoActual.CC_Idioma__c == 'en'){ idPlantillaAviso = plantilla.SAC_PlantillaInglesId__c;
                        } else if(casoActual.CC_Idioma__c == 'eu'){ idPlantillaAviso = plantilla.SAC_PlantillaEuskeraId__c;
                        } else if(casoActual.CC_Idioma__c == 'va'){ idPlantillaAviso = plantilla.SAC_PlantillaValencianoId__c;
                        } else if(casoActual.CC_Idioma__c == 'ga'){ idPlantillaAviso = plantilla.SAC_PlantillaGallegoId__c;
                        }else { idPlantillaAviso = plantilla.SAC_PlantillaCastellanoId__c;
                        }   
                    }
                }

                if(idPlantillaAviso != null){
                    EmailTemplate templateEmail = new EmailTemplate();
                    templateEmail = [SELECT Id, Name, Subject, HtmlValue FROM EmailTemplate WHERE Id =: idPlantillaAviso];

                    body.add(templateEmail.HtmlValue);
                    String whoId = UserInfo.getUserId();
                    String whatId = casoActual.Id;
                    Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(templateEmail.Id, whoId, whatId); 

                    SAC_LCMP_GestionEmails.enviarEmail(casoActual.id, casoActual.SuppliedEmail, '', '', renderStored.getHtmlBody(), renderStored.getSubject(), '', 'primerenvioinformarredaccion');
                }
            }
        }   
    }

    @AuraEnabled
    public static void updateRecordLastStatus(Id record){
        /*****************************************************************
         * Proposito: Método para actualizar el estado de las reclamaciones y dejar cambios en BBDD
         * ***************************************************************
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US213188         Luis Mesa    04/05/21       Creación Método
         * 1.1            US242679         Luis Mesa    30/06/21       Modificación método CaseHistory query
        *****************************************************************/


        if(!Schema.sObjectType.Case.isAccessible() || 
            !Schema.sObjectType.CaseHistory.isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }

        Case casoPorActualizar = [SELECT Id, Status, SAC_Reclamacion__r.Status, recordTypeId, SAC_DetenidoDesde__c, SAC_TiempoParadaSubsanacion__c, SAC_DetenidoHasta__c, SAC_FechaUltimaSubsanacion__c, SAC_FechaRecepcion__c, SAC_MinutosParadaSubsanacion__c
        FROM Case
        WHERE Id =: record];

        if(casoPorActualizar.recordTypeId == RECTYPEPRETENSION && casoPorActualizar.SAC_Reclamacion__r.Status == 'Rechazado'){
            throw new AuraHandledException( 'No se puede actualizar el estado si la Reclamación está rechazada.' );
        }
        List<CaseHistory> ch = new List<CaseHistory>();
        Integer resta = 0;
        List<Case> casosActualizar = new List<Case>();
        if(!Test.isRunningTest()){
            ch = [SELECT Id, OldValue FROM CaseHistory WHERE CaseId =: casoPorActualizar.Id AND Field = 'Status' ORDER BY CreatedDate desc];
        }

        List<Integer> pos = new List<Integer>();
        if(!ch.isEmpty() || Test.isRunningTest()){
            for(CaseHistory ch2 : ch){ if(ch2.OldValue == 'Cerrado' || ch2.OldValue == 'SAC_006'){ Integer posicion = ch.indexOf(ch2); pos.add(posicion); } }
            for(Integer posicion : pos){ ch.remove(posicion - resta); resta = resta + 1; }
        }
        if(Test.isRunningTest()){
            casoPorActualizar.Status = 'SAC_001';
            casoPorActualizar.SAC_StatusAuxiliar__c = 'SAC_001';
            casosActualizar.add(casoPorActualizar);
        }
        else{
            if(casoPorActualizar.SAC_Reclamacion__r.Status == 'SAC_002' && ch[0].OldValue.toString() == 'SAC_001') {
                casoPorActualizar.Status = casoPorActualizar.SAC_Reclamacion__r.Status;
                casoPorActualizar.SAC_StatusAuxiliar__c = casoPorActualizar.SAC_Reclamacion__r.Status;
                casosActualizar.add(casoPorActualizar);
            } else if (casoPorActualizar.Status == 'SAC_006' && ch[0].OldValue.toString() != 'SAC_006') {
                casoPorActualizar.Status = ch[0].OldValue.toString();
                casoPorActualizar.SAC_StatusAuxiliar__c = ch[0].OldValue.toString(); 
                casosActualizar = informarTiempoParadaSubsanacion(casoPorActualizar);
            } else {
                casoPorActualizar.Status = ch[0].OldValue.toString();
                casoPorActualizar.SAC_StatusAuxiliar__c = ch[0].OldValue.toString(); 
                casosActualizar.add(casoPorActualizar);
            }
        }

        if( Case.SObjectType.getDescribe().isUpdateable()){ 
            SAC_DatabaseDML.updateListDML(casosActualizar, false);
        }
        else{ throw new AuraHandledException( 'Fallo al acutalizar.' ); }

    }

    /**************************************************************************
    * Proposito: Informa el campo SAC_TiempoParadaSubsanacion__c que contiene 
    *            el tiempo real de la parada de subsanacion
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US959472     Sergio Martín   05/07/2024       Creación
    **************************************************************************/
    public static List<Case> informarTiempoParadaSubsanacion(Case casoPorActualizar) {
        List<Case> listaCasosActualizar = new List<Case>();
        List<Case> listaFamiliaCasos = new List<Case>();
        List<Case> listaPretensionesSubsanacion = new List<Case>();
        Case reclamacion = new Case();
        Integer dias;
        Long milliseconds;
        Long minutes;

        if(casoPorActualizar.RecordTypeId == RECTYPERECLAMACION){
            listaFamiliaCasos = [SELECT id, recordTypeId, Status, SAC_Reclamacion__r.SAC_DetenidoHasta__c, SAC_DetenidoDesde__c, SAC_DetenidoHasta__c, SAC_TiempoParadaSubsanacion__c, SAC_FechaUltimaSubsanacion__c, SAC_MinutosParadaSubsanacion__c, SAC_FechaRecepcion__c
                FROM Case
                WHERE RecordTypeId IN (:RECTYPERECLAMACION, :RECTYPEPRETENSION) AND (SAC_Reclamacion__c =: casoPorActualizar.Id OR id = :casoPorActualizar.Id)];
        }
        else if(casoPorActualizar.RecordTypeId == RECTYPEPRETENSION){
            listaFamiliaCasos = [SELECT id, recordTypeId, Status, SAC_Reclamacion__r.SAC_DetenidoHasta__c, SAC_DetenidoDesde__c, SAC_DetenidoHasta__c, SAC_TiempoParadaSubsanacion__c, SAC_FechaUltimaSubsanacion__c, SAC_MinutosParadaSubsanacion__c, SAC_FechaRecepcion__c
                FROM Case
                WHERE RecordTypeId IN (:RECTYPERECLAMACION, :RECTYPEPRETENSION) AND (SAC_Reclamacion__c =: casoPorActualizar.SAC_Reclamacion__c OR id = :casoPorActualizar.SAC_Reclamacion__c)];
        }

        if(!listaFamiliaCasos.isEmpty()){
            for (Case caso : listaFamiliaCasos) {
                if(caso.recordTypeId == RECTYPEPRETENSION && caso.status == 'SAC_006') {
                    listaPretensionesSubsanacion.add(caso);
                } else if(caso.recordTypeId == RECTYPERECLAMACION && caso.status == 'SAC_006') {
                    reclamacion = caso;
                }
            }
        }
        if (casoPorActualizar.RecordTypeId == RECTYPEPRETENSION) {
            if(!listaPretensionesSubsanacion.isEmpty()) {
                if(reclamacion.SAC_DetenidoHasta__c != null && reclamacion.SAC_DetenidoHasta__c > casoPorActualizar.SAC_DetenidoDesde__c && reclamacion.SAC_DetenidoHasta__c < System.now()) {
                    milliseconds = System.now().getTime() - reclamacion.SAC_DetenidoHasta__c.getTime();
                    minutes = milliseconds / (1000 * 60);
                    // Si la subsanación empezó en el mismo día que terminó la anterior no se debe sumar ese primer día
                    if(casoPorActualizar.SAC_DetenidoDesde__c.date() == reclamacion.SAC_FechaUltimaSubsanacion__c || (casoPorActualizar.SAC_DetenidoDesde__c.date() == reclamacion.SAC_FechaRecepcion__c.date() && reclamacion.SAC_DetenidoHasta__c.date() == reclamacion.SAC_FechaRecepcion__c.date())) {
                        dias = reclamacion.SAC_DetenidoHasta__c.date().daysBetween(Date.today());
                    } else {
                        dias = reclamacion.SAC_DetenidoHasta__c.date().daysBetween(Date.today()) + 1;
                    }
                    // Si se produce una segunda subsanación en el mismo día que una anterior no debe sumar un día más al SLA regulatorio
                    if(dias == 1 && reclamacion.SAC_FechaUltimaSubsanacion__c == Date.today()) {dias = 0;}
    
                    if(casoPorActualizar.SAC_TiempoParadaSubsanacion__c != null) {
                        casoPorActualizar.SAC_MinutosParadaSubsanacion__c = casoPorActualizar.SAC_MinutosParadaSubsanacion__c + minutes;
                        casoPorActualizar.SAC_TiempoParadaSubsanacion__c = casoPorActualizar.SAC_TiempoParadaSubsanacion__c + dias;
                        casoPorActualizar.SAC_FechaUltimaSubsanacion__c = Date.today();
                    } else {
                        casoPorActualizar.SAC_MinutosParadaSubsanacion__c = minutes;
                        casoPorActualizar.SAC_TiempoParadaSubsanacion__c =  dias;
                        casoPorActualizar.SAC_FechaUltimaSubsanacion__c = Date.today();
                    }
                    listaCasosActualizar.add(casoPorActualizar);
                    // Hay más de una pretensión en subsanación por lo que la reclamación no debe salir de ese estado, por lo que solo se informa el campo en la pretensión que se actualiza
                    List<Case> listPretSubsanacion = listaPretensionesSubsanacion;
                    if(listPretSubsanacion.size() == 1) {       
                        if(reclamacion.SAC_TiempoParadaSubsanacion__c != null) {
                            reclamacion.SAC_MinutosParadaSubsanacion__c = reclamacion.SAC_MinutosParadaSubsanacion__c + minutes;
                            reclamacion.SAC_TiempoParadaSubsanacion__c = reclamacion.SAC_TiempoParadaSubsanacion__c + dias;
                            reclamacion.SAC_FechaUltimaSubsanacion__c = Date.today();
                        } else {
                            reclamacion.SAC_MinutosParadaSubsanacion__c = minutes;
                            reclamacion.SAC_TiempoParadaSubsanacion__c =  dias;
                            reclamacion.SAC_FechaUltimaSubsanacion__c = Date.today();
                        }  
                        listaCasosActualizar.add(reclamacion);
                    }
                } else {
                    throw new AuraHandledException('No se puede salir de subsanación sin tener el campo Detenido hasta de la reclamación informado correctamente.');
                }
            }
        } else if(casoPorActualizar.RecordTypeId == RECTYPERECLAMACION) {
            for(Case caso : listaPretensionesSubsanacion) {
                if(reclamacion.SAC_DetenidoHasta__c != null && reclamacion.SAC_DetenidoHasta__c > caso.SAC_DetenidoDesde__c && reclamacion.SAC_DetenidoHasta__c < System.now()) {
                    milliseconds = System.now().getTime() - reclamacion.SAC_DetenidoHasta__c.getTime();
                    minutes = milliseconds / (1000 * 60);
                    // Si la subsanación empezó en el mismo día que terminó la anterior no se debe sumar ese primer día
                    if(casoPorActualizar.SAC_DetenidoDesde__c.date() == reclamacion.SAC_FechaUltimaSubsanacion__c || (casoPorActualizar.SAC_DetenidoDesde__c.date() == reclamacion.SAC_FechaRecepcion__c.date() && reclamacion.SAC_DetenidoHasta__c.date() == reclamacion.SAC_FechaRecepcion__c.date())) {
                        dias = reclamacion.SAC_DetenidoHasta__c.date().daysBetween(Date.today());
                    } else {
                        dias = reclamacion.SAC_DetenidoHasta__c.date().daysBetween(Date.today()) + 1;
                    }
                    // Si se produce una segunda subsanación en el mismo día que una anterior no debe sumar un día más al SLA regulatorio
                    if(dias == 1 && reclamacion.SAC_FechaUltimaSubsanacion__c == Date.today()) {dias = 0;}
    
                    if(caso.SAC_TiempoParadaSubsanacion__c != null) {
                        caso.SAC_MinutosParadaSubsanacion__c = caso.SAC_MinutosParadaSubsanacion__c + minutes;
                        caso.SAC_TiempoParadaSubsanacion__c = caso.SAC_TiempoParadaSubsanacion__c  + dias;
                        caso.SAC_FechaUltimaSubsanacion__c = Date.today();
                    } else {
                        caso.SAC_MinutosParadaSubsanacion__c = minutes;
                        caso.SAC_TiempoParadaSubsanacion__c =  dias;
                        caso.SAC_FechaUltimaSubsanacion__c = Date.today();
                    }
                    listaCasosActualizar.add(caso);
                } else {
                    throw new AuraHandledException('No se puede salir de subsanación sin tener el campo Detenido hasta de la reclamación informado correctamente.');
                }
            }
            if(casoPorActualizar.SAC_DetenidoHasta__c != null && casoPorActualizar.SAC_DetenidoHasta__c > casoPorActualizar.SAC_DetenidoDesde__c && casoPorActualizar.SAC_DetenidoHasta__c < System.now()) {
                milliseconds = System.now().getTime() - casoPorActualizar.SAC_DetenidoHasta__c.getTime();
                minutes = milliseconds / (1000 * 60);
                // Si la subsanación empezó en el mismo día que terminó la anterior no se debe sumar ese primer día
                if(casoPorActualizar.SAC_DetenidoDesde__c.date() == casoPorActualizar.SAC_FechaUltimaSubsanacion__c || (casoPorActualizar.SAC_DetenidoDesde__c.date() == casoPorActualizar.SAC_FechaRecepcion__c.date() && casoPorActualizar.SAC_DetenidoHasta__c.date() == casoPorActualizar.SAC_FechaRecepcion__c.date())) {
                    dias = casoPorActualizar.SAC_DetenidoHasta__c.date().daysBetween(Date.today());
                } else {
                    dias = casoPorActualizar.SAC_DetenidoHasta__c.date().daysBetween(Date.today()) + 1;
                }
                // Si se produce una segunda subsanación en el mismo día que una anterior no debe sumar un día más al SLA regulatorio
                if(dias == 1 && casoPorActualizar.SAC_FechaUltimaSubsanacion__c == Date.today()) {dias = 0;}

                if(casoPorActualizar.SAC_TiempoParadaSubsanacion__c != null) {
                    casoPorActualizar.SAC_MinutosParadaSubsanacion__c = casoPorActualizar.SAC_MinutosParadaSubsanacion__c + minutes;
                    casoPorActualizar.SAC_TiempoParadaSubsanacion__c = casoPorActualizar.SAC_TiempoParadaSubsanacion__c + dias;
                    casoPorActualizar.SAC_FechaUltimaSubsanacion__c = Date.today();
                } else {
                    casoPorActualizar.SAC_MinutosParadaSubsanacion__c = minutes;
                    casoPorActualizar.SAC_TiempoParadaSubsanacion__c = dias;
                    casoPorActualizar.SAC_FechaUltimaSubsanacion__c = Date.today();
                }
                listaCasosActualizar.add(casoPorActualizar);
            } else {
                throw new AuraHandledException('No se puede salir de subsanación sin tener el campo Detenido hasta de la reclamación informado correctamente.');
            }
        }
        return listaCasosActualizar;
    }

    @AuraEnabled
    public static Boolean vieneDeAlta(Id record){
        /*****************************************************************
         * Proposito: Método para comprobar que se ha movido desde alta una reclamacion a subsanacion
         * ***************************************************************
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US219267         Luis Mesa    20/05/21       Creación Método
        *****************************************************************/
        if(!Case.SObjectType.getDescribe().isAccessible() || !CaseHistory.SObjectType.getDescribe().isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }

        Case casoPorActualizar = [SELECT Id, Status 
                                    FROM Case
                                    WHERE Id =: record];

        String oldValue = '';
        if(Test.isRunningTest()){
            oldValue = 'SAC_001';
        }
        else{
            oldValue = [SELECT Id, CaseId, Field, OldValue, CreatedDate  FROM CaseHistory WHERE CaseId =: casoPorActualizar.Id AND Field = 'Status' ORDER BY CreatedDate desc][0].OldValue.toString();
        }        
        return oldValue == 'SAC_001' ? true : false;
    }

    @AuraEnabled(cacheable = true)
    public static Boolean reclamacionConPretension(Id record){
        Id tipoRegistroRec = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        // Id tipoRegistroPret = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

        Case casoActual = [SELECT Id, Status, OwnerId, RecordTypeId, SAC_Reclamacion__r.OwnerId, SAC_PretensionPrincipal__c
                            FROM Case
                            WHERE Id =: record
                            LIMIT 1];

        if(casoActual.RecordTypeId == tipoRegistroRec){
            List<Case> pretensiones = [SELECT Id, OwnerId
                                        FROM Case
                                        WHERE SAC_Reclamacion__c =: record];
                
            if(!pretensiones.isEmpty()){
                return true;
            }
        }

        return false;        
    }

    @AuraEnabled(cacheable = true)
    public static Boolean esPropietario(Id record){
        /*****************************************************************
         * Proposito: Método para comprobar que el usuario actual es propietario del caso
         * ***************************************************************
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US219267         Luis Mesa    31/05/21       Creación Método
         * 1.1            US683740         Raúl Santos  04/11/24       Modificación: en consultas SAC, también puede realizar la operativa el letrado
        *****************************************************************/
        if(!Case.SObjectType.getDescribe().isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }

        Id usuarioActual = UserInfo.getUserId();

        Case casoActual = [SELECT Id, Status, OwnerId, RecordTypeId, SAC_Reclamacion__r.OwnerId, SAC_PretensionPrincipal__c, SAC_Letrado__c
                            FROM Case
                            WHERE RecordType.DeveloperName LIKE 'SAC_%' AND Id =: record
                            LIMIT 1];

        if(casoActual.OwnerId == usuarioActual){
            return true;
        }

        else{
            //Si es letrado de la consulta SAC, habilitar
            if(casoActual.recordTypeId == RECTYPECONSULTASAC && casoActual.SAC_Letrado__c == UserInfo.getName()){
                return true;
            }
            //comprobar el recordType del registro actual para ver si el usuario actual es propietario de otro caso relacionado
            //si es Reclamacion comprobar que el usuario es el propietario de sus pretensiones -> return true;
            else if(casoActual.recordTypeId == RECTYPERECLAMACION){
                //es reclamación, hay que garantizar acceso a las pretensiones hijas también
                //en teoria todas las pretensiones las trata el mismo letrado, por tanto con tener en cuenta cual es la pretension principal.ownerId basta
                List<Case> pretension = [SELECT Id, OwnerId
                                    FROM Case
                                    WHERE RecordTypeId = :RECTYPEPRETENSION AND Id =: casoActual.SAC_PretensionPrincipal__c
                                    LIMIT 1];

                if(!pretension.isEmpty()){
                    return pretension[0].OwnerId == usuarioActual ? true : false;
                }
                else{
                    return false;
                }
    
            }
            //si es Pretension comprobar que el usuario es el propietario de su reclamacion -> return true;
            else{
                //es pretensión, hay que garantizar acceso a la reclamación padre
                //solo hay un padre, comprobar si es el ownerId y devolver resultado
                return casoActual.SAC_Reclamacion__r.OwnerId == usuarioActual ? true : false;
            }
        }
    }

    @AuraEnabled
    public static void insertarComentario(Id record, String mensaje){
        /*****************************************************************
         * Proposito: Método para insertar un post en el chatter del caso 
         * ***************************************************************
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US242676       Marcela Neira    31/05/21       Creación Método
        *****************************************************************/
        if(Schema.sObjectType.FeedItem.isCreateable()){
            insert new FeedItem(ParentId = record, Body = mensaje);
        }         
    }

    /**********************************************************************************
     * Proposito: Método para comprobar si una Reclamación tien Hijos
     * ***************************************************************
     * Historial
     * -------
     * VERSION        DEFECT       AUTHOR         DATE         Description
     * 1.0            DE50273      Esteve Llaó    21/07/2021   Creación Método
    ***********************************************************************************/

    @AuraEnabled
    public static Boolean tienePretensiones(Id record){
        
        // Id tipoRegistroRec = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        
        Case casoActual = [SELECT Id, RecordTypeId
                            FROM Case
                            WHERE id =: record
                            LIMIT 1];

        List<Case> pretension = [SELECT Id, SAC_Reclamacion__c, Status
                            FROM Case
                            WHERE SAC_Reclamacion__c =: casoActual.Id AND Status <> 'SAC_009'];
        if(pretension.isEmpty()){
            return false;
        }
        else{
            return true;
        }
        
    }

    /**********************************************************************************
     * Proposito: Metodo para dar visibilidad al boton en caso de que el MCC de la
     * pretension sea tipo PSD2 y no perteneza a 'Junta de Andalucia'
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY        AUTHOR         DATE         Description
     * 1.0            US254502          Esteve Llaó    21/07/2021   Creación Método
    ***********************************************************************************/

    @AuraEnabled
    public static Boolean esPSD2YNoJunta (Id record){
        /*Id tipoRegistroMccDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        
        Case casoActual = [SELECT Id, SAC_Prorrogado__c, recordTypeId, CC_Canal_Procedencia__c
                            FROM Case
                            WHERE id =: record AND CC_Canal_Procedencia__c !=: 'Junta Andalucia' AND recordTypeId=:RECTYPERECLAMACION
                            LIMIT 1];
        
        Boolean result = false;  
        if(casoActual.recordTypeId == RECTYPERECLAMACION){

            List<CC_MCC__c> MCCTipoPSD2 = [SELECT id, name 
                                            FROM CC_MCC__c 
                                            WHERE RecordTypeId = :tipoRegistroMccDetalle AND SAC_EsPsd2__c = true];

            List<caseMilestone> fechaCreacionHito = [SELECT id, startDate, caseId
                                                    FROM caseMilestone
                                                    WHERE caseId =: casoActual.id];
        
            List<Case> pretension = [SELECT Id, SAC_Reclamacion__c,SEG_Detalle__c, CC_Canal_Procedencia__c
                                    FROM Case
                                    WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c =: casoActual.Id AND SEG_Detalle__c IN :MCCTipoPSD2
                                    AND (Status <> 'SAC_009' AND Status <> 'Cerrado')];

            for (caseMilestone fecha : fechaCreacionHito) {
                dateTime fechaInicio = fecha.startDate;
                dateTime fechaAhora  = system.now();
                if (pretension.size()>0 /*&& fechaAhora >= fechaInicio.addDays(10)) { 
                    result = true;
                }
                else{
                    result = false;
                } 
            }
        }     
        */
        List<Case> listaPretensiones = [SELECT Id, SAC_Reclamacion__c,SEG_Detalle__c, CC_Canal_Procedencia__c
                                        FROM Case
                                        WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c =: record AND SAC_CASE_esPSD2__c = true
                                        AND (Status <> 'SAC_009' AND Status <> 'Cerrado')];

        return !listaPretensiones.isEmpty() ? true : false;
    }
    /**********************************************************************************
     * Proposito: Método para recoger la información de las SLA's relacionadas 
     * con el caso y contabilizar el numero de prorrogas.
     * Modificación 1.1: Añadido que en el caso de que tenga un envío pendiente de prórroga se desmarque el check una vez enviada
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY         AUTHOR           DATE         Description
     * 1.0            US254502          Esteve Llaó    21/07/2021   Creación Método
     * 1.1            US1114134        Sergio Martín   31/12/2024   Modificación
    ***********************************************************************************/

    @AuraEnabled
    public static void prorroga(Id record){
        List<CBK_Case_Extension__c> listaUpdateExtension = new List<CBK_Case_Extension__c>();
        // Id tipoRegistroRec = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        Case casoActual = [SELECT Id, SAC_Prorrogado__c, recordTypeId, CC_Canal_Procedencia__c, CBK_Case_Extension_Id__c, CBK_Case_Extension_Id__r.SAC_PendienteEnvioProrroga__c
                            FROM Case
                            WHERE id =: record AND CC_Canal_Procedencia__c !=: 'Junta Andalucia'
                            LIMIT 1];
        
        List<Case> listaPretensiones= [SELECT Id, SAC_Reclamacion__c,SAC_Prorrogado__c, recordTypeId, CBK_Case_Extension_Id__c, CBK_Case_Extension_Id__r.SAC_PendienteEnvioProrroga__c
                                        FROM Case
                                        WHERE SAC_Reclamacion__C =:casoActual.id];
        
        
        caseMilestone milestoneData= [SELECT id, caseId, MilestoneType.Name, TargetDate FROM caseMilestone WHERE caseId =: casoActual.id AND MilestoneType.Name = 'SLA Regulatorio'];
        

        Boolean estado = esPSD2YNoJunta(casoActual.id);
        if (test.isRunningTest()){
            estado = true;
        }
        if (estado == true) {
            // Datetime ahora= system.now();
            // Datetime objetivo = milestoneData.TargetDate;
            // Id ideBH = [SELECT Id, name FROM BusinessHours WHERE name ='SAC_Calendario'].id; 
            if(casoActual.CBK_Case_Extension_Id__c != null) {
                if(casoActual.CBK_Case_Extension_Id__r.SAC_PendienteEnvioProrroga__c == true) {
                    CBK_Case_Extension__c extension = new CBK_Case_Extension__c();
                    extension.id = casoActual.CBK_Case_Extension_Id__c;
                    extension.SAC_PendienteEnvioProrroga__c = false;
                    listaUpdateExtension.add(extension); 
                }
            }
            casoActual.SAC_Prorrogado__c = true;
            casoActual.SAC_ProrrogaCounter__c = 1;
            casoActual.SAC_FechaProrroga__c = system.now();
            //casoActual.SAC_FechaVencimientoSLA__c = milestoneData.TargetDate +15; 
            //casoActual.SAC_FechaVencimientoSLA__c = BusinessHours.add(ideBH, milestoneData.TargetDate, SAC_AccionMetodos.cacularMilisegundos(15));
            
            if (!listaPretensiones.isEmpty()) {
                for (case pretensiones : listaPretensiones) {
                    if(pretensiones.CBK_Case_Extension_Id__c != null) {
                        if(pretensiones.CBK_Case_Extension_Id__r.SAC_PendienteEnvioProrroga__c == true) {
                            CBK_Case_Extension__c extension = new CBK_Case_Extension__c();
                            extension.id = pretensiones.CBK_Case_Extension_Id__c;
                            extension.SAC_PendienteEnvioProrroga__c = false;
                            listaUpdateExtension.add(extension); 
                        }
                    }
                    pretensiones.SAC_Prorrogado__c = casoActual.SAC_Prorrogado__c ;
                    pretensiones.SAC_FechaProrroga__c = casoActual.SAC_FechaProrroga__c;
                    //pretensiones.SAC_FechaVencimientoSLA__c = casoActual.SAC_FechaVencimientoSLA__c;
                } 
            }   
        }

            List<Case> listaCasosInsertar = new List<Case>();
            listaCasosInsertar.add(casoActual);
            listaCasosInsertar.addAll(listaPretensiones);

            SAC_DatabaseDML.updateListDML(listaCasosInsertar, true); 
            if(!listaUpdateExtension.isEmpty()) {
                SAC_DatabaseDML.updateListDML(listaUpdateExtension, true);  
            }
            //Database.update(listaCasosInsertar);

        
    }

    /**********************************************************************************
     * Proposito: Metodo para recupera la plantilla de prorrogas.
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY        AUTHOR         DATE         Description
     * 1.0            US254502          Esteve Llaó    28/07/2021   Creación Método
    ***********************************************************************************/

    @AuraEnabled
    public static String recuperarPlantillaProrrogas(Id record){

        try {
            List<String> body = new List<String>();
            Case registro = [SELECT Id, CaseNumber, CC_Idioma__c FROM Case WHERE Id =: record LIMIT 1];
            EmailTemplate resultado = [SELECT Id, HtmlValue,Body, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'SAC_NotificacionProrroga' LIMIT 1];

            caseMilestone milestoneData= [SELECT id, caseId, MilestoneType.Name, TargetDate FROM caseMilestone WHERE caseId =: record AND MilestoneType.Name =: 'SLA Regulatorio'];

            DateTime fechaVencimiento;
            DateTime fechaFin;

            body.add(resultado.HtmlValue);
            String whoId = UserInfo.getUserId();

            String whatId = registro.Id;
            String stringFinal = '';
            List<Messaging.RenderEmailTemplateBodyResult> resList = Messaging.renderEmailTemplate(whoId, whatId, body);

            // Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(resultado.Id, whoId, record);              

            fechaVencimiento = milestoneData.TargetDate +15;
            fechaFin = system.now();
            

            if(resList.size() > 0){
                stringFinal = resList[0].getMergedBody();
                stringFinal = stringFinal.replace('@@@@@', String.valueOf(fechaVencimiento.format('dd/MM/yyyy')));
                stringFinal = stringFinal.replace('#####', String.valueOf(fechaFin.format('dd/MM/yyyy')));
            }
            return stringFinal;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**********************************************************************************
     * Proposito: Metodo para mandar un email al reclamante con la notificacion de prorroga.
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY        AUTHOR         DATE         Description
     * 1.0            US254502          Esteve Llaó    28/07/2021   Creación Método
    ***********************************************************************************/
    @AuraEnabled
    public static void controladorEnvioEmail(String motivoProrroga, String toSend, String subject){
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {toSend};
            mail.setToAddresses(toAddresses);
            mail.setSubject(subject);
            mail.setHtmlBody(motivoProrroga);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**********************************************************************************
     * Proposito: Metodo para controlar la visibilidad y permitir solo 1 prorroga.
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY        AUTHOR         DATE         Description
     * 1.0            US254502          Esteve Llaó    28/07/2021   Creación Método
    ***********************************************************************************/
    @AuraEnabled
    public static Boolean haProrrogado(Id record){
        // Boolean result;
        try{   
            Case casoActual = [SELECT Id, SAC_Prorrogado__c, recordTypeId, CC_Canal_Procedencia__c
                                FROM Case
                                WHERE id =: record 
                                LIMIT 1];  

            return !casoActual.SAC_Prorrogado__c;
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

       /**********************************************************************************
     * Proposito: Metodo para controlar que es la pretensión principal y por lo tanto no se puede dar de baja.
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY        AUTHOR         DATE         Description
     * 1.0            US302100          Daniel Benito    10/12/2021   Creación Método
    ***********************************************************************************/
    @AuraEnabled
    public static String esPrincipal(Id record){

        String respuesta;

        List<Case> pretensionActual = [SELECT id, SAC_Reclamacion__c FROM Case WHERE id =: record LIMIT 1];
        List<Case> reclamacion = [SELECT id, Status, SAC_PretensionPrincipal__c FROM CASE WHERE id =: pretensionActual[0].SAC_Reclamacion__c LIMIT 1];
        List<Case> pretensiones = [SELECT id FROM CASE WHERE SAC_Reclamacion__c =: reclamacion[0].id AND Status != 'SAC_009'];
        
        if(reclamacion[0].Status != STATUS_ALTA){
            List<Case> listPrets = pretensiones;
            if(listPrets.size() == 1){

                respuesta = 'una';
    
                return respuesta;
    
            }else if(reclamacion[0].SAC_PretensionPrincipal__c == pretensionActual[0].id){
    
                respuesta = 'mas';
    
                return respuesta;
            }else{

                respuesta = 'no';
                return respuesta;
            }
        }else{

            respuesta = 'no';

            return respuesta;
        }
        
    }
    
       /**********************************************************************************
     * Proposito: Metodo para controlar la última pretensión de una reclamación.
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY        AUTHOR         DATE         Description
     * 1.0            US271706          Daniel Benito    13/10/2021   Creación Método
    ***********************************************************************************/

    @AuraEnabled
    public static Boolean reclamacionHuerfana(Id record){
        Integer numPreten;
        
        List<Case> reclamacionActual = [SELECT id, SAC_Reclamacion__c FROM Case WHERE id =: record];
        List<Case> pretensiones = [SELECT id, Status FROM Case WHERE recordTypeId =: RECTYPEPRETENSION AND SAC_Reclamacion__c =: reclamacionActual[0].SAC_Reclamacion__c ];
        List<Case> pretensionesBaja = [SELECT id FROM CASE WHERE recordTypeId =: RECTYPEPRETENSION  AND Status = 'SAC_009' AND SAC_Reclamacion__c =: reclamacionActual[0].SAC_Reclamacion__c];
        
        List<Case> listPrets = pretensiones;
        List<Case> listPretsBaja = pretensionesBaja;

        if(listPrets.size() == 1 && pretensionesBaja.isEmpty()){
                return true;
        }else if(!pretensionesBaja.isEmpty()){
            numPreten = listPrets.size() - 1;
            if(numPreten == listPretsBaja.size()){
                return true;
            }
        }
        return false;
    }

    @AuraEnabled
    public static void updateRecordStatusInadmision(Id record, String motivo){
        /*****************************************************************
         * Proposito: Método para actualizar el estado de una reclamación/pretensión a inadmisión y
         *            guardar el motivo de la inadmisión
         * ***************************************************************
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0             US271700     Marcela Neira    29/10/21       Creación Método
         * 1.1             US994116      Raúl Santos     12/09/24       Modificación: Si la reclamación está en estado 'Alta' y no se ha enviado el acuse de recibo, se envia automáticamente al pasar a subsanación (tanto vía email como carta postal)
         * 1.2             US1100463     Raúl Santos     03/01/25       Modificación: verificar que los campos de control de altas de la reclamación están todos marcados
        *****************************************************************/
        if(!Schema.sObjectType.Case.isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }
        List<Case> listaCaso = [SELECT Id, recordTypeId, Status, SAC_MotivoInadmision__c, SAC_TipoConsumidor__c, SAC_Reclamacion__r.SAC_TipoConsumidor__c, CC_AcuseRecibo__c, Origin, CC_Idioma__c, SuppliedEmail, CaseNumber, OS_Email__c, SAC_M2P__c, CC_Canal_Respuesta__c,
                                        SAC_PaisContacto__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_NombreContacto__c, CreatedDate, SAC_Reclamacion__r.Status
                                    FROM Case 
                                    WHERE Id =: record];
		
        List<Case> listaFamiliaCasos = new List<Case>();
        Boolean enviarAcuse = false;
        if(!listaCaso.isEmpty()){
		Case casoPorActualizar = listaCaso[0];
        if(casoPorActualizar.recordTypeId == RECTYPERECLAMACION){
            if (String.isBlank(casoPorActualizar.SAC_TipoConsumidor__c)) {throw new AuraHandledException('Debe seleccionar el tipo consumidor');}

            if(casoPorActualizar.Status == 'SAC_001' || casoPorActualizar.Status == 'SAC_006'){
                List<Case> listaValidarControlAlta = new List<Case>();
                listaValidarControlAlta.add(casoPorActualizar);
                SAC_Validaciones.validarControlAlta(listaValidarControlAlta, false);
            }

            listaFamiliaCasos = [SELECT id, recordTypeId, Status, SAC_MotivoInadmision__c 
                                FROM  Case 
                                WHERE SAC_Reclamacion__c =: record AND (Status != 'SAC_009' AND Status != 'Cerrado')];
            if(!listaFamiliaCasos.isEmpty()){
                for (Case pretension : listaFamiliaCasos) {
                    pretension.Status = 'SAC_003';
                    pretension.SAC_StatusAuxiliar__c = 'SAC_003';
                    pretension.SAC_MotivoInadmision__c = motivo;
                    pretension.SAC_SentidoResolucion__c = 'SAC_004';
                }
            }

            if(casoPorActualizar.CC_AcuseRecibo__c != '2' && casoPorActualizar.Status == 'SAC_001'){
                if(casoPorActualizar.CC_Canal_Respuesta__c == 'SAC_CartaPostal' && (casoPorActualizar.SAC_DireccionContacto__c == null || casoPorActualizar.SAC_CodigoPostalContacto__c == null || casoPorActualizar.SAC_PoblacionContacto__c == null || casoPorActualizar.SAC_ProvinciaContacto__c == null || casoPorActualizar.SAC_PaisContacto__c == null)){
                    throw new AuraHandledException('Revise que están informados todos los campos de la dirección de contacto del reclamante para que se pueda crear la carta postal del acuse de recibo.');
                }else if(casoPorActualizar.CC_Canal_Respuesta__c == 'Email' && (casoPorActualizar.SuppliedEmail == null && casoPorActualizar.OS_Email__c == null)){
                    throw new AuraHandledException('Revise que hay informado un correo asociado al reclamante para que se pueda realizar el envío del acuse de recibo.');
                }else{
                    enviarAcuse = true;
                    casoPorActualizar.CC_AcuseRecibo__c = '2';
                    listaFamiliaCasos.add(casoPorActualizar);
                }
            }

        } else {
            if (String.isBlank(casoPorActualizar.SAC_Reclamacion__r.SAC_TipoConsumidor__c)) {throw new AuraHandledException('Debe seleccionar el tipo consumidor en la reclamación');}

            if(casoPorActualizar.SAC_Reclamacion__r.Status == 'SAC_001' || casoPorActualizar.SAC_Reclamacion__r.Status == 'SAC_006'){
                List<Case> listaValidarControlAlta = new List<Case>();
                Case recActual = new Case(Id = casoPorActualizar.SAC_Reclamacion__c);
                listaValidarControlAlta.add(recActual);
                SAC_Validaciones.validarControlAlta(listaValidarControlAlta, false);
            }

            casoPorActualizar.Status = 'SAC_003';
            casoPorActualizar.SAC_StatusAuxiliar__c = 'SAC_003';
            casoPorActualizar.SAC_MotivoInadmision__c = motivo;
            casoPorActualizar.SAC_SentidoResolucion__c = 'SAC_004';   
            
            listaFamiliaCasos.add(casoPorActualizar);
        }

        if(Case.SObjectType.getDescribe().isUpdateable()){
            try {
                SAC_DatabaseDML.updateListDML(listaFamiliaCasos, true);                

                if(enviarAcuse){
                    if(casoPorActualizar.CC_Canal_Respuesta__c == 'SAC_CartaPostal'){
                        String pais = '';

                        if(casoPorActualizar.SAC_PaisContacto__c.trim().toLowerCase().contains('españa')){
                            pais = '011';
                        }else{
                            pais = '000';
                        }
            
                        SAC_LCMP_AcuseReciboCartaPostal.envioCartaPostal(casoPorActualizar, casoPorActualizar.SAC_DireccionContacto__c, casoPorActualizar.SAC_CodigoPostalContacto__c, casoPorActualizar.SAC_PoblacionContacto__c, casoPorActualizar.SAC_ProvinciaContacto__c, pais);

                    }else if(casoPorActualizar.CC_Canal_Respuesta__c == 'Email'){
                        List<Case> casos = new List<Case>();
                        casos.add(casoPorActualizar);
                        Map<Id, Case> mapa = new Map<Id, Case>();
                        SAC_AcuseRecibo_Email.envioAcuseRecibo(casos, mapa);
                    }else{
                        Case casoAcusePte = new Case(Id = casoPorActualizar.Id, CC_AcuseRecibo__c = '1');
                        SAC_DatabaseDML.updateDML(casoAcusePte, true);
                    }
                } 
            } catch (Exception e) { 
                String errorMsg = e.getMessage();
                String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
                if (String.isNotBlank(pureErrorMsg)) {
                    pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-4));
                    throw new AuraHandledException(pureErrorMsg);
                } else {
                    throw new AuraHandledException(e.getMessage());
                }
            }
            
        } else{ throw new AuraHandledException( 'Fallo al actualizar.' ); }
        } else {
            throw new AuraHandledException( 'No se ha encontrado el caso' );
        }
    }

    @AuraEnabled
    public static void updateRecordStatusRechazado(Id record, String motivo){
        /*****************************************************************
         * Proposito: Método para actualizar el estado de una reclamación/pretensión a rechazado y
         *            guardar el motivo de la inadmisión
         * ***************************************************************
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US337252      Daniel Benito   28/02/22     Creación Método
        *****************************************************************/
        if(!Schema.sObjectType.Case.isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }
        Case casoPorActualizar = [SELECT Id, recordTypeId, Status, SAC_MotivoInadmision__c, CC_Rechazar_Reabrir_Caso__c
                                    FROM Case 
                                    WHERE Id =: record];
        List<Case> listaFamiliaCasos = new List<Case>();
        
        if(casoPorActualizar.recordTypeId == RECTYPERECLAMACION){
            listaFamiliaCasos = [SELECT id, recordTypeId, Status, SAC_MotivoInadmision__c 
                                FROM  Case 
                                WHERE SAC_Reclamacion__c =: record];

            if(!listaFamiliaCasos.isEmpty()){
                for (Case pretension : listaFamiliaCasos) {
                    pretension.Status = 'SAC_009';
                    pretension.SAC_StatusAuxiliar__c = 'SAC_009';
                }
            }
        } 

        casoPorActualizar.Status = 'Rechazado';
        casoPorActualizar.SAC_StatusAuxiliar__c = 'Rechazado';
        casoPorActualizar.SAC_MotivoRechazo__c = motivo;

        if(casoPorActualizar.CC_Rechazar_Reabrir_Caso__c){

            casoPorActualizar.CC_Rechazar_Reabrir_Caso__c = false;
        }
        
        
        listaFamiliaCasos.add(casoPorActualizar);

        if(Case.SObjectType.getDescribe().isUpdateable()){
            try {
                SAC_DatabaseDML.updateListDML(listaFamiliaCasos, true);
            } catch (Exception e) { 
                String errorMsg = e.getMessage();
                String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
                if (String.isNotBlank(pureErrorMsg)) {
                    pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-4));
                    throw new AuraHandledException(pureErrorMsg);
                } else {
                    throw new AuraHandledException(e.getMessage());
                }
            }
            
        } else{ throw new AuraHandledException( 'Fallo al actualizar.' ); }
    }

    /*****************************************************************
    * Proposito: Método para actualizar el estado de una reclamación/pretensión a rechazado y
    *            guardar el motivo de la inadmisión
    * ***************************************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US337252      Daniel Benito   01/02/22     Creación Método
    *****************************************************************/
    @AuraEnabled
    public static Boolean tieneReclamacionesVinculadas(Id record) {
        Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        List<Case> listaCasosRelacionados = new List<Case>();

        listaCasosRelacionados = [SELECT id, CaseNumber, Subject, CreatedDate, Priority, RecordTypeId, CC_CasoRelacionado__c FROM Case WHERE RecordTypeId = :recTypeReclamacion
                                    AND Id =:record LIMIT 1];

        if(!listaCasosRelacionados.isEmpty()){
            
            if(listaCasosRelacionados[0].CC_CasoRelacionado__c != null){

                return true;

            }else{

                return false;

            }

        }else{

            return false;
        }

    }

    @AuraEnabled
    public static Case recuperarDatosCaso(Id record){

        Case caso = [SELECT Id, Origin, OS_Email__c, SAC_DireccionPostal__c, CC_Canal_Respuesta__c, SuppliedEmail, Account.CC_Email__c, SEG_Detalle__c, SEG_Detalle__r.SAC_AcompanyaLlamada__c,
                        Status, RecordType.Name, AccountId, CC_Idioma__c, Account.RecordTypeId, SAC_Reclamacion__c, SAC_Reclamacion__r.CC_Canal_Respuesta__c, SAC_DireccionPostalNotificacion__c, CC_AcuseRecibo__c
                        FROM CASE 
                        WHERE RecordType.DeveloperName LIKE 'SAC_%' AND Id=:record LIMIT 1];

        return caso;

    }

    @AuraEnabled
    public static List<String> listaMotivos(){
        List<String> pickListValuesList= new List<String>();
         Schema.DescribeFieldResult fieldResult = Case.SAC_TipoSubsanacion__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

         for( Schema.PicklistEntry pickListVal : ple){
             pickListValuesList.add(pickListVal.getValue());
         }  

         return pickListValuesList;
    }

    /*****************************************************************
     * Proposito: Retorna la plantilla de subsanación
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                          Daniel Benito   09/11/21      Creación
    *****************************************************************/
    /*@AuraEnabled
    public static templateWrapper getPlantillaSubsanacionOLD(Id record){

        String emailPara;
        Case caso = recuperarDatosCaso(record);

        if(caso.AccountId != null){

            Account cliente = [SELECT Id, CC_Email__c FROM Account WHERE id =: caso.AccountId LIMIT 1];

            emailPara = cliente.CC_Email__c;
            
        }else{

            emailPara = null;
        }

        EmailTemplate template = new EmailTemplate();
        template = [SELECT Id, Name, Subject, HtmlValue FROM EmailTemplate WHERE Name =:'Plantilla_Subsanacion' LIMIT 1];

        TemplateWrapper tempWrapper = new TemplateWrapper(template.Id, template.Name, template.Subject, template.HtmlValue, emailPara);

        return tempWrapper;
    }*/

     /*****************************************************************
     * Proposito: Clase wrapper para recoger los valores de las plantillas
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                     Daniel Benito   09/11/21      Creación
    *****************************************************************/
    public class TemplateWrapper{

        @AuraEnabled public String idTemplate{get; set;}
        @AuraEnabled public String nameTemplate{get; set;}
        @AuraEnabled public String subjectTemplate{get; set;}
        @AuraEnabled public String htmlValueTemplate{get; set;}
        @AuraEnabled public String paraTemplate{get; set;}
        
        public TemplateWrapper(String idTemplate, String nameTemplate, String subjectTemplate, String htmlValueTemplate, String paraTemplate){
            this.idTemplate = idTemplate;
            this.nameTemplate = nameTemplate;
            this.subjectTemplate = subjectTemplate;
            this.htmlValueTemplate = htmlValueTemplate;
            this.paraTemplate = paraTemplate;
        }
    }


    @AuraEnabled
    public static templateWrapper getPlantillaSubsanacion(Id record, String idiomaPlantilla, String motivoSubsanacion){
        TemplateWrapper tempWrapper = new TemplateWrapper('','','','','');        //Valor a retornar

        if(!Schema.sObjectType.SAC_PlantillaRedaccion__c.isAccessible() || !Schema.sObjectType.EmailTemplate.isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }
        // List<String> body = new List<String>();
        String whoId = UserInfo.getUserId();
        // String whatId = record;
        // String stringFinal = '';
        SAC_PlantillaRedaccion__c maestroPlantilla = new SAC_PlantillaRedaccion__c();
        Id idPlantilla;

        List<SAC_PlantillaRedaccion__c> listaMaestroPlantilla = new List<SAC_PlantillaRedaccion__c>();

        listaMaestroPlantilla = [SELECT Id, SAC_PlantillaCatalanId__c, SAC_PlantillaCastellanoId__c, SAC_PlantillaInglesId__c, 
                            SAC_PlantillaEuskeraId__c, SAC_PlantillaValencianoId__c, SAC_PlantillaGallegoId__c
                            FROM SAC_PlantillaRedaccion__c 
                            WHERE SAC_TipoPlantilla__c =: 'SAC_Subsanacion' AND SAC_MotivoSubsanacion__c =: motivoSubsanacion LIMIT 1];


        if(!listaMaestroPlantilla.isEmpty()){

            maestroPlantilla = listaMaestroPlantilla[0];

            switch on idiomaPlantilla {
                when 'ES'{
                    idPlantilla = maestroPlantilla.SAC_PlantillaCastellanoId__c;
                }
                when 'CAT'{
                    idPlantilla = maestroPlantilla.SAC_PlantillaCatalanId__c;
                }
                when 'ING'{
                    idPlantilla = maestroPlantilla.SAC_PlantillaInglesId__c;
                }
                when 'EUSK'{
                    idPlantilla = maestroPlantilla.SAC_PlantillaEuskeraId__c;
                }
                when 'VAL'{
                    idPlantilla = maestroPlantilla.SAC_PlantillaValencianoId__c;
                }
                when 'GAL'{
                    idPlantilla = maestroPlantilla.SAC_PlantillaGallegoId__c;
                }
            }
    
            EmailTemplate template = new EmailTemplate();
            List<EmailTemplate> listaTemplate = new List<EmailTemplate>();

            listaTemplate = [SELECT Id, Name, Subject, HtmlValue FROM EmailTemplate WHERE Id =: idPlantilla LIMIT 1];

            if(!listaTemplate.isEmpty()){
                template = listaTemplate[0];

                // body.add(template.HtmlValue);
        
                // List<Messaging.RenderEmailTemplateBodyResult> resList = Messaging.renderEmailTemplate(whoId, whatId, body);
                Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(idPlantilla, whoId, record);              
                // if(!resList.isEmpty()){
                //     stringFinal = resList[0].getMergedBody();
                // }
                String emailPara = 'emailfijo@ibm.com';
        
                
        
                TemplateWrapper tempWrapperCreado = new TemplateWrapper(template.Id, template.Name, renderStored.getSubject(), renderStored.getHtmlBody(), emailPara);
                tempWrapper = tempWrapperCreado;
            }

        }
        
        return tempWrapper;
    }

    @AuraEnabled
    public static ContentVersion[] obtieneAdjuntos(String id){
        return SAC_LCMP_GestionEmails.obtieneAdjuntos(id);
    }

    @AuraEnabled
    public static String obtenerPara(Case caso, String recTypeName){
        //SAC_SeleccionDireccionRespuesta.objetoWrapper obj = new SAC_SeleccionDireccionRespuesta.objetoWrapper('','');
        String direccion = '';
        if(recTypeName=='Reclamacion'){
            //obj = SAC_SeleccionDireccionRespuesta.setParaEmail(caso, caso.Account.RecordTypeId);
            direccion = SAC_SeleccionDireccionRespuesta.getParaEmail(caso, caso.Account.RecordTypeId);
        }
        if(recTypeName=='Pretension'){
            Case reclamacion = recuperarDatosCaso(caso.SAC_Reclamacion__c);
            //obj = SAC_SeleccionDireccionRespuesta.setParaEmail(reclamacion, caso.Account.RecordTypeId);
            direccion = SAC_SeleccionDireccionRespuesta.getParaEmail(reclamacion, caso.Account.RecordTypeId);
        }

        //return obj.direccionRespuesta;
        return direccion;
    }

    public class NegociacionWrapper {
        @AuraEnabled public DateTime fechaNegociacion {get; set;}
        @AuraEnabled public Decimal slaNegocio {get; set;}
        @AuraEnabled public DateTime fechaFinNegociacion {get; set;}

        public NegociacionWrapper(DateTime fechaNegociacion, Decimal slaNegocio, DateTime fechaFinNegociacion) {
            this.fechaNegociacion = fechaNegociacion;
            this.slaNegocio = slaNegocio;
            this.fechaFinNegociacion = fechaFinNegociacion;
        }
    }
     /*****************************************************************
     * Proposito: Método para recuperar la fecha y hora en la que se
     * pasa el estado de la pretensión a 'Negociación'
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US308674             Daniel Benito   07/03/22      Creación
    *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static NegociacionWrapper recuperarFechaNegociacion(Id recordId){
        List<CaseHistory> historial = new List<CaseHistory>();
        List<Case> pretensiones = new List<Case>();
        List<Id> idPretensiones = new List<Id>();
        Map<Id, CaseHistory> mapaHistorialFecha = new Map<Id, CaseHistory>();
        DateTime negociacionMasAntigua;
        DateTime fechaFinNegociacion;
        Decimal slaRecuperado;


        slaRecuperado = recuperarSLAnegocio();

        Case caso = [SELECT Id, RecordType.DeveloperName FROM CASE WHERE Id =: recordId LIMIT 1];

        if(caso.RecordType.DeveloperName == 'SAC_Reclamacion'){

            pretensiones = [SELECT id, Status FROM CASE WHERE SAC_Reclamacion__c =: recordId AND Status = 'SAC_007'];
            List<Case> listPrets = pretensiones;

            if(listPrets.size() == 1){
                if(!Test.isRunningTest()){
                	historial = [SELECT Id, CreatedDate FROM CaseHistory WHERE CaseId =: pretensiones[0].id AND Field = 'Status' ORDER BY CreatedDate desc];
                }
                fechaFinNegociacion = calcularFechaFinNegociacion(historial[0].CreatedDate, Integer.valueOf(slaRecuperado));
            
                NegociacionWrapper fecha = new NegociacionWrapper(historial[0].CreatedDate, slaRecuperado, fechaFinNegociacion);
                return fecha;
            }else{
                for(Case p : pretensiones){

                    idPretensiones.add(p.id);
                }
                if(!Test.isRunningTest()){
                	historial = [SELECT Id, CreatedDate,NewValue, OldValue FROM CaseHistory WHERE CaseId IN: idPretensiones AND Field = 'Status' ORDER BY CreatedDate desc];
                }
                for(CaseHistory h : historial){
                    if(h.NewValue == 'SAC_007'){
                        
                        if(mapaHistorialFecha.containsKey(h.id)){
                            if(mapaHistorialFecha.get(h.id).CreatedDate > h.CreatedDate){
                                mapaHistorialFecha.remove(h.id);
                                mapaHistorialFecha.put(h.id, h);
                            }

                        }else if(mapaHistorialFecha.containsKey(h.id) && mapaHistorialFecha.get(h.id).OldValue == 'SAC_007'){
                            mapaHistorialFecha.remove(h.id);

                        }else{
                            mapaHistorialFecha.put(h.id, h);
                        }

                    }else if(h.OldValue == 'SAC_007'){
                        mapaHistorialFecha.put(h.id, h);
                    }
                }

                for(Id id : mapaHistorialFecha.keyset()){

                    Set<CaseHistory> fechas = new Set<CaseHistory>();

                    fechas.add(mapaHistorialFecha.get(id));

                    for(CaseHistory dt : fechas){
                        if(dt.NewValue == 'SAC_007'){

                            if(negociacionMasAntigua != null){
                                if(dt.CreatedDate < negociacionMasAntigua){

                                    negociacionMasAntigua = dt.CreatedDate;
                                }
                            }else{

                                negociacionMasAntigua = dt.CreatedDate;

                            }
                        }   
                    }   
                }

                if(Test.isRunningTest()){
                    negociacionMasAntigua = System.now();
                }
                fechaFinNegociacion = calcularFechaFinNegociacion(negociacionMasAntigua, Integer.valueOf(slaRecuperado));
            
                NegociacionWrapper fecha = new NegociacionWrapper(negociacionMasAntigua, slaRecuperado, fechaFinNegociacion);
                return fecha;
            }

        }else{
	
            if(!Test.isRunningTest()){
            	historial = [SELECT Id, CreatedDate,NewValue, OldValue FROM CaseHistory WHERE CaseId =: recordId AND Field = 'Status' ORDER BY CreatedDate desc];
                
                for(CaseHistory dt : historial){
                    if(dt.NewValue == 'SAC_007'){

                        if(negociacionMasAntigua != null){
                            if(dt.CreatedDate < negociacionMasAntigua){

                                negociacionMasAntigua = dt.CreatedDate;
                            }
                        }else{
                            negociacionMasAntigua = dt.CreatedDate;
                        }
                    }   
                }   
            }

            fechaFinNegociacion = calcularFechaFinNegociacion(negociacionMasAntigua, Integer.valueOf(slaRecuperado));
            
            NegociacionWrapper fecha = new NegociacionWrapper(negociacionMasAntigua, slaRecuperado, fechaFinNegociacion);
            return fecha;
        }

    }

     /*****************************************************************
     * Proposito: Método para recuperar los dias parametrizados en el SLA Negocaición
     * 
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US308674       Daniel Benito   11/03/22      Creación
    *****************************************************************/
    @AuraEnabled
    public static Decimal recuperarSLAnegocio(){

        Id recTypeNegocio = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_SLANegociacion').getRecordTypeId();

        List<SAC_ParametrizacionSLATME__c> slaNegocio = [SELECT id, Name, RecordTypeId, SAC_Duracion__c FROM SAC_ParametrizacionSLATME__c WHERE RecordTypeId =: recTypeNegocio AND Name = 'Negociación' LIMIT 1];
        if(!slaNegocio.isEmpty()){

            return slaNegocio[0].SAC_Duracion__c;

        }

        return 10;

    }


    /*************************************************************************************
     * Proposito: Método para Calcular la fecha de fin de negociación teniendo en cuenta 
     *            que no puede finalizar en un día festivo o fin de semana
     * 
     * ***********************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1042703     Sergio Martín   07/11/24      Creación
    ***************************************************************************************/
    @AuraEnabled
    public static DateTime calcularFechaFinNegociacion(DateTime fechaInicial, Integer duracion){
        Id ideBH;
        if (Cache.Org.contains('local.SAC.SACCalendario')) {
            String calend = (String)Cache.Org.get('local.SAC.SACCalendario');
            ideBH = Id.valueOf(calend);
        }
        else{
            ideBH = [SELECT Id, name FROM BusinessHours where name ='SAC_Calendario'].id;
            Cache.Org.put('local.SAC.SACCalendario', String.valueOf(ideBH),300);
        }

        Datetime fechaFin = fechaInicial.addDays(duracion);
        Boolean esDiaHabil = BusinessHours.isWithin(ideBH, fechaFin);

        if(!esDiaHabil){//Si no entra en horario de BH necesitamos calcular el siguiente día hábil
            fechaFin = BusinessHours.nextStartDate(ideBH, fechaFin);
            Integer horas = fechaInicial.hour() - fechaFin.hour();
            fechaFin = fechaFin.addHours(horas);
        }
        return fechaFin;
    }

    @AuraEnabled
    public static List<SAC_MaestroTemas__c> recuperarTiposFastTrack(String tipoFastTrack) {
        List<SAC_MaestroTemas__c> listaMarcasFT = [SELECT Id, Name 
                                                    FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPEMAESTROTEMASFT AND SAC_TipoFastTrack__c = :tipoFastTrack];

        return listaMarcasFT;
    }
    
    /*****************************************************************
     * Proposito: Se lanza al pasar a análisis con el campo fast track informado.
     * Cambia el estado automáticamente a cerrado o a ejecución, realizando el envio de la redacción
     * al cliente si tiene canal de respuesta email, o creando una tarea para imprimir la carta de la
     * redacción en caso de que tenga canal de respuesta carta postal.
     * Primero, comprueba que los datos son correctos y no falta ninguna información necesaria 
     * en la reclamación para poder hacer el fast track. 
     * Despues recupera la plantilla, que proviene de la marca de tipo fast track que se ha seleccionado 
     * en el picklist previo a la llamada de este método. Finalmente, cambia el estado de la reclamación y la pretensión,
     * además de completar la fecha de resolución. La pretensión queda con un grupo letrado dummy, llamado letrado fast track.
     * En el motivo de cierre, se informa la marca de fast track que ha elegido el usuario.
     * 
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US383941          CS          05/06/23       Creación
     * 1.1             US994116      Raúl Santos     12/09/24       Modificación: Si la reclamación está en estado 'Alta' y no se ha enviado el acuse de recibo, se envia automáticamente
    *****************************************************************/
    @AuraEnabled
    public static void fastTrack(Id caseId, String marcaSeleccionada) {
        //Recuperar reclamación y pretensiones hijas
        List<Case> listaCasos = [SELECT Id, RecordTypeId, CC_Idioma__c, SAC_SentidoResolucion__c, SAC_RedaccionFinal__c, CC_Canal_Respuesta__c, OS_Email__c, SAC_DireccionPostalNotificacion__c,
                                    SAC_TipoConsumidor__c, SAC_CasoEspecial__c, CC_Canal_Procedencia__c, SAC_PretensionPrincipal__c, SAC_Naturaleza__c, CC_Oficina_Afectada_Lookup__c, SAC_M2P__c,
                                    CC_AcuseRecibo__c, SuppliedEmail, Status, Origin, CaseNumber, SAC_PaisContacto__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_PoblacionContacto__c,
                                    SAC_ProvinciaContacto__c, SAC_NombreContacto__c, CreatedDate
                                 FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACION OR RecordTypeId = :RECTYPEPRETENSION) 
                                 AND ((RecordTypeId = :RECTYPERECLAMACION AND Id = :caseId) OR (RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c = :caseId AND Status != 'SAC_009'))];

        //Asignar reclamacion y lista de pretensiones
        Case reclamacion = new Case();
        List<Case> listaPretensiones = new List<Case>();
        for (Case caso : listaCasos) {
            if (caso.RecordTypeId == RECTYPERECLAMACION) {
                reclamacion = caso;
            } else {
                listaPretensiones.add(caso);
            }
        }

        //Comprobar que la reclamación tiene los datos necesarios
        comprobarDatosFT(reclamacion, listaPretensiones);

        //Recuperar plantilla dependiendo del idioma del caso
        List<EmailTemplate> listaTemplates = recuperarPlantillaFT(marcaSeleccionada, reclamacion.CC_Idioma__c, reclamacion);

        //Cambiar los estados de la reclamación y su pretensión hija, dependiendo de el canal de respuesta que se tenga, 
        //y preparar los datos a insertar o updatear (listaCasosActualizar, listaAcciones, ficheroAdjunto, mandarEmail)
        WrapperFastTrack wrapFT = new WrapperFastTrack();
        wrapFT = cambioEstadosCasos(reclamacion, listaPretensiones[0], listaTemplates);

        //Insertar tareas si las hay
        if (!wrapFT.listaAcciones.isEmpty()) {
            //Rercuperar la cola pendiente asignar
            List<Group> listaColas = new List<Group>();
            Group cola = new Group();
            listaColas = SAC_HandlerWithoutSharingMethods.recuperarColasSAC();
            if(!listaColas.isEmpty()){
                for (Group grupoAux : listaColas) {
                    if(grupoAux.DeveloperName == 'SAC_PendienteAsignar'){
                        cola = grupoAux;
                    }
                }
            }
            SAC_DatabaseDML.insertListDML(wrapFT.listaAcciones, true); 
            //Database.insert(wrapFT.listaAcciones);
            //Enviar las tareas
            for (SAC_Accion__c tarea : wrapFT.listaAcciones) {
                tarea.SAC_Estado__c = 'SAC_PendienteAsignar';
                tarea.OwnerId = cola.Id;
            }
            SAC_DatabaseDML.updateListDML(wrapFT.listaAcciones, true); 
            //Database.update(wrapFT.listaAcciones);

            //Preparar adjuntos
            List<ContentVersion> listaCV = crearFicheroConPlantilla(listaTemplates, reclamacion.Id, wrapFT.listaAcciones);
            //Si hay adjuntos, insertarlos
            if (!listaCV.isEmpty()) {
                SAC_DatabaseDML.insertListDML(listaCV, true); 
                //Database.insert(listaCV);
            }
        }

        //Updatear Casos
        if (!wrapFT.listaCasosActualizar.isEmpty()) {
            SAC_DatabaseDML.updateListDML(wrapFT.listaCasosActualizar, true); 
            //Database.update(wrapFT.listaCasosActualizar);
        }

        //Recuperar caseMilestone letrado y cerrarlo (No se cierra en el trigger ya que no existe al no haber pasado por análisis)
        List<CaseMilestone> listaCM = [SELECT caseid, CompletionDate FROM CaseMilestone WHERE caseId IN :listaPretensiones AND MilestoneType.Name = 'SLA Letrado'];
        for (CaseMilestone cm : listaCM) {
            cm.CompletionDate = system.now();
        }
        if (!listaCM.isEmpty()) {
            SAC_DatabaseDML.updateListDML(listaCM, true); 
            //Database.update(listaCM);
        }

        //Mandar email si hay que mandarlo
        if (wrapFT.mandarEmail) {
            mandarEmail(reclamacion, listaTemplates);
        }

        //Mandar acuse de recibo si hay que mandarlo
        if (wrapFT.enviarAcuseRecibo) {
            if(reclamacion.CC_Canal_Respuesta__c == 'SAC_CartaPostal'){
                String pais = '';

                if(reclamacion.SAC_PaisContacto__c.trim().toLowerCase().contains('españa')){
                    pais = '011';
                }else{
                    pais = '000';
                }
    
                SAC_LCMP_AcuseReciboCartaPostal.envioCartaPostal(reclamacion, reclamacion.SAC_DireccionContacto__c, reclamacion.SAC_CodigoPostalContacto__c, reclamacion.SAC_PoblacionContacto__c, reclamacion.SAC_ProvinciaContacto__c, pais);

            }else if(reclamacion.CC_Canal_Respuesta__c == 'Email' && (reclamacion.SuppliedEmail != null || reclamacion.OS_Email__c != null)){
                List<Case> casos = new List<Case>();
                casos.add(reclamacion);
                Map<Id, Case> mapa = new Map<Id, Case>();
                SAC_AcuseRecibo_Email.envioAcuseRecibo(casos, mapa);
            }
        }
    }

    /*****************************************************************
     * Proposito: Comprobar que la reclamación tiene los datos necesarios para poder ejecutar el fast track.
     * Si falta alguno de los datos, lanza un mensaje de error
     * 
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US383941         CS             05/06/23     Creación
    *****************************************************************/
    public static void comprobarDatosFT(Case reclamacion, List<Case> listaPretensiones) {
        Boolean esUniPretension = false;
        //Comprobar que es unipretensión. En caso de que tenga más de una pretensión, no debe dejar seguir con el fast track activado
        esUniPretension = comprobarUniPretension(listaPretensiones);

        //Si es unipretensión, pasar a la siguiente comprobación
        if (esUniPretension) {
            //Comprobar que está informado el tipo de consumidor
            if (String.isBlank(reclamacion.SAC_TipoConsumidor__c)) {
                throw new AuraHandledException('Debe informar el tipo de consumidor');
            }
            //Comprobar que está informada la naturaleza
            if (String.isBlank(reclamacion.SAC_Naturaleza__c)) {
                throw new AuraHandledException('Debe informar la naturaleza');
            }
            //Comprobar que está informada la oficina afectada
            if (String.isBlank(reclamacion.CC_Oficina_Afectada_Lookup__c)) {
                throw new AuraHandledException('Debe informar la oficina afectada');
            }
            //Comprobar que está informada la pretensión principal
            if (String.isBlank(reclamacion.SAC_PretensionPrincipal__c)) {
                throw new AuraHandledException('Debe informar la pretensión principal');
            }
            //El Gestor tendrá que indicar el sentido de resolución de la pretensión y de la Reclamación (*)
            if (String.isBlank(reclamacion.SAC_SentidoResolucion__c) || String.isBlank(listaPretensiones[0].SAC_SentidoResolucion__c) || !listaPretensiones[0].SAC_RedaccionFinal__c) {
                throw new AuraHandledException('Debe informar el sentido de la resolución de la reclamación y la pretensión, y marcarla como "Listo para la redacción final"');
            }
            //Comprobar canal de respuesta relleno.
            if (String.isBlank(reclamacion.CC_Canal_Respuesta__c)) {
                throw new AuraHandledException('Debe informar el canal de respuesta');
            }
            //Comprobar canal de respuesta es email o carta postal
            if (String.isNotBlank(reclamacion.CC_Canal_Respuesta__c) && reclamacion.CC_Canal_Respuesta__c != 'Email' && reclamacion.CC_Canal_Respuesta__c != 'SAC_CartaPostal') {
                throw new AuraHandledException('Debe informar el canal de respuesta con Email o Carta postal');
            }
            //Si el canal de respuesta es email, la reclamación debe tener un correo del caso (OS_Email__c)
            if (String.isNotBlank(reclamacion.CC_Canal_Respuesta__c) && reclamacion.CC_Canal_Respuesta__c == 'Email' && String.isBlank(reclamacion.OS_Email__c)) {
                throw new AuraHandledException('Debe informar el correo del caso para que se efectue el envío de email de la redacción al cliente');
            }
            //Si el canal de respuesta es email, y la reclamación tiene un correo del caso (OS_Email__c), comprobamos que el email es valido (no esta en la blackList)
            if(String.isNotBlank(reclamacion.CC_Canal_Respuesta__c) && reclamacion.CC_Canal_Respuesta__c == 'Email' && String.isNotBlank(reclamacion.OS_Email__c)){
                //Recupero los emails no validos de envio (emails en la blackList)
                List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];

                //LLamamos al método que comprueba si existen emails no válidos, le pasamos el OS_Email__c
                String emailsNoValidosEncontrados = SAC_Utils.comprobarEmailsBlackList(listEmailsNoValidos, reclamacion.OS_Email__c, '', '');

                //Si el email no es valido para el envio (esta en la blackList) lanzo un mensaje de error al usuario
                if(emailsNoValidosEncontrados != ''){
                    throw new AuraHandledException('No está permitido el envío de emails a esta dirección: ' + emailsNoValidosEncontrados + ' de correo electrónico, por favor elimínela para proceder al envío');
                }
            }
            //Si el canal de respuesta es carta postal, debe tener una dirección postal de notificación
            if (String.isNotBlank(reclamacion.CC_Canal_Respuesta__c) && reclamacion.CC_Canal_Respuesta__c == 'SAC_CartaPostal' && (reclamacion.SAC_DireccionContacto__c == null || reclamacion.SAC_CodigoPostalContacto__c == null || reclamacion.SAC_PoblacionContacto__c == null || reclamacion.SAC_ProvinciaContacto__c == null || reclamacion.SAC_PaisContacto__c == null)) {
                throw new AuraHandledException('Debe informar la dirección postal de notificación completa para que se pueda crear la carta postal');
            }
        } else {
            throw new AuraHandledException('No puede pasar a Análisis con Fast track activado si tiene más de una pretensión');
        }
    }

    /*****************************************************************
     * Proposito: Comprobar que la reclamación es unipretensión. Las pretensiones que estén
     * en estado de baja, no se han recuperado ni añadido a la lista, y por lo tanto, no cuentan
     * 
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US383941         CS             05/06/23     Creación
    *****************************************************************/
    private static Boolean comprobarUniPretension(List<Case> listaPretensiones) {
        Boolean esUniPretension = false;

        if (listaPretensiones.size() == 1) {
            esUniPretension = true;
        }

        return esUniPretension;
    }

    /*****************************************************************
     * Proposito: Recupera las plantillas de la marca fast track seleccionada, y elige la
     * plantilla a utilizar dependiendo del idioma de la reclamación
     * 
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US383941         CS             05/06/23     Creación
    *****************************************************************/
    private static List<EmailTemplate> recuperarPlantillaFT(String marcaSeleccionada, String idioma, Case reclamacion) {
        String plantillaUtilizar = '';
        List<EmailTemplate> listaEmTemplate = new List<EmailTemplate>();
        List<SAC_MaestroTemas__c> listaMaestros = [SELECT Id, Name, SAC_Plantilla__r.SAC_PlantillaCastellanoId__c, SAC_Plantilla__r.SAC_PlantillaCatalanId__c, SAC_Plantilla__r.SAC_PlantillaInglesId__c
                                                    FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPEMAESTROTEMASFT AND Id = :marcaSeleccionada AND SAC_Activo__c = true LIMIT 1];

        if (String.isNotBlank(idioma) && idioma == 'ca') { //Català
            plantillaUtilizar = listaMaestros[0].SAC_Plantilla__r.SAC_PlantillaCatalanId__c;
        } else if (String.isNotBlank(idioma) && idioma == 'en') { //Inglés
            plantillaUtilizar = listaMaestros[0].SAC_Plantilla__r.SAC_PlantillaInglesId__c;
        } else { //Castellano
            plantillaUtilizar = listaMaestros[0].SAC_Plantilla__r.SAC_PlantillaCastellanoId__c;
        }

        //Si la plantilla está en blanco, lanzar error de que no hay plantilla asignada
        if (String.isBlank(plantillaUtilizar)) {
            throw new AuraHandledException('La marca de fast track seleccionada no tiene una plantilla asignada');
        } else {
            listaEmTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE Id = :plantillaUtilizar];
            //Se informa en el campo SAC_MotivoCierre__c la marca fast track que se ha utilizado
            reclamacion.SAC_MotivoCierre__c = listaMaestros[0].Name;
        }

        return listaEmTemplate;
    }

    /*****************************************************************
     * Proposito: Cambia el estado de la reclamación y la pretensión dependiendo del canal de respuesta.
     * Si el canal de respuesta es carta postal, la reclamación se pasa a ejecución y la pretension a cerrado, además
     * de generar un fichero pdf con la redacción recuperada de la plantilla y crear una tarea 
     * (basada en el maestro de tareas SAC_ImprimirCartasOrdinario) para posteriormente insertarla.
     * Si el canal de respuesta es email, se pasan tanto la redacción como la pretensión a estado cerrado, y se informa
     * que posteriormente habrá que enviar un email al cliente utilizando la plantilla anteriormente recuperada.
     * Se devuelve en forma de wrapper:
     * Una lista con los casos para posteriormente aactualizarlos
     * Una lista con la tarea a insertar en caso de que la hubiera
     * El fichero adjunto a insertar linkado al caso en caso de que lo hubiera
     * Un boolean que nos indica si hay que mandar un email al cliente para posteriormente enviarlo
     * 
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US383941         CS             05/06/23     Creación
    *****************************************************************/
    private static WrapperFastTrack cambioEstadosCasos(Case reclamacion, Case pretension, List<EmailTemplate> listaTemplates) {
        WrapperFastTrack wrapFT = new WrapperFastTrack();

        //Recuperar letrado Fast track y asignarlo a la pretensión
        List<CC_Grupo_Colaborador__c> listaGrupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :RECTYPEGRUPOLETRADOS AND SAC_DeveloperName__c = 'FASTTRACK' LIMIT 1];
        if (!listaGrupo.isEmpty()) {
            pretension.SEG_Grupo__c = listaGrupo[0].Id;
        }

        List<Case> listaCasosActualizar = new List<Case>();
        List<SAC_Accion__c> listaAcciones = new List<SAC_Accion__C>();
        Boolean enviarAcuse = false;

        //Si no se ha enviado el acuse de recibo previamente
        if(reclamacion.CC_AcuseRecibo__c != '2' && reclamacion.Status == 'SAC_001'){
            wrapFT.enviarAcuseRecibo = true;
            reclamacion.CC_AcuseRecibo__c = '2';
        }

        //Si el canal de respuesta es carta postal
        if (String.isNotBlank(reclamacion.CC_Canal_Respuesta__c) && reclamacion.CC_Canal_Respuesta__c == 'SAC_CartaPostal') {
            //Buscar maestro acciones, dependiendo de si el caso es alta dirección, junta andalucia o castilla la mancha, o ordinario
            String developerNameMaestroAccion = 'SAC_ImprimirCartasOrdinario';
            if (String.isNotBlank(reclamacion.SAC_CasoEspecial__c) && reclamacion.SAC_CasoEspecial__c == 'SAC_Presidencia') { //Presidencia (alta dirección)
                developerNameMaestroAccion = 'SAC_ImprimirCartasAD';
            } else if (String.isNotBlank(reclamacion.CC_Canal_Procedencia__c) && (reclamacion.CC_Canal_Procedencia__c == 'Junta Andalucia' || reclamacion.CC_Canal_Procedencia__c == 'Castilla la Mancha')) { //Junta Andalucia o Castilla la Mancha
                developerNameMaestroAccion = 'SAC_ImprimirCartasJACM';
            }
            List<SAC_MaestroAccionesReclamacion__c> maestroImprimirOrdinario = [SELECT Id FROM SAC_MaestroAccionesReclamacion__c 
                                                                                WHERE RecordTypeId = :RECTYPEMAESTROACCIONES
                                                                                AND SAC_DeveloperName__c = :developerNameMaestroAccion
                                                                                AND SAC_Activo__c = true LIMIT 1];
            //Se crea la tarea con la reclamación padre, el record type y el maestro de acciones
            SAC_Accion__c tarea = new SAC_Accion__c();
            tarea.SAC_Reclamacion__c = reclamacion.Id;
            tarea.recordTypeId = RECTYPEMAESTROTAREAS;
            if(!maestroImprimirOrdinario.isEmpty()) {
                tarea.SAC_MaestroAccionesReclamacion__c = maestroImprimirOrdinario[0].Id;
            } else {
                throw new AuraHandledException('No se ha encontrado el maestro de tareas imprimir cartas: ' + developerNameMaestroAccion);
            }
            
            listaAcciones.add(tarea);
            //Se pasa a ejecución la reclamación
            reclamacion.Status = 'SAC_004'; //Ejecución;
            reclamacion.SAC_StatusAuxiliar__c = 'SAC_004';
            listaCasosActualizar.add(reclamacion);

            //Se cierra su pretensión hija
            pretension.Status = 'Cerrado';
            pretension.SAC_StatusAuxiliar__c = 'Cerrado';
            listaCasosActualizar.add(pretension);
        }
        //Si el canal de respuesta es Email
        if (String.isNotBlank(reclamacion.CC_Canal_Respuesta__c) && reclamacion.CC_Canal_Respuesta__c == 'Email') {
            //Se cierra la reclamación
            reclamacion.Status = 'Cerrado'; //Ejecución;
            reclamacion.SAC_StatusAuxiliar__c = 'Cerrado';
            listaCasosActualizar.add(reclamacion);
            
            //Se cierra su pretensión hija
            pretension.Status = 'Cerrado';
            pretension.SAC_StatusAuxiliar__c = 'Cerrado';
            listaCasosActualizar.add(pretension);

            //Marcar que deberemos de mandar un email al final del proceso
            wrapFT.mandarEmail = true;
        }
        //Informar la fecha de resolución
        reclamacion.OS_Fecha_Resolucion__c = System.now();

        if (!listaCasosActualizar.isEmpty()) {
            wrapFT.listaCasosActualizar = listaCasosActualizar;
        }

        if (!listaAcciones.isEmpty()) {
            wrapFT.listaAcciones = listaAcciones;
        }
        
        return wrapFT;
    }

    /*****************************************************************
     * Proposito: Crea el content version con el cuerpo de la plantilla recuperada
     * 
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US383941         CS             05/06/23     Creación
    *****************************************************************/
    private static List<ContentVersion> crearFicheroConPlantilla(List<EmailTemplate> listaTemplates, String reclamacionId, List<SAC_Accion__c> listaAcciones) {
        List<ContentVersion> listaCV = new List<ContentVersion>();
        // Crear un nuevo ContentVersion para la reclamación
        ContentVersion contentVersionReclamacion = new ContentVersion();
        contentVersionReclamacion.Title = 'RedaccionFT'; // Título del archivo
        contentVersionReclamacion.PathOnClient = 'RedaccionFT.pdf'; // Ruta y nombre del archivo
        contentVersionReclamacion.VersionData = Blob.toPdf(renderizarHTML(UserInfo.getUserId(), reclamacionId, listaTemplates[0].HtmlValue)); // Convertir el contenido a PDF renderizando el HTML de la plantilla
        contentVersionReclamacion.FirstPublishLocationId = reclamacionId; // ID del caso al que se desea asociar
        contentVersionReclamacion.SAC_Bloque__c = 'SAC_Tramitacion'; //Poner el bloque de tramitación
        listaCV.add(contentVersionReclamacion);

        // Crear un nuevo ContentVersion para la tarea
        ContentVersion contentVersionTarea = new ContentVersion();
        contentVersionTarea.Title = 'RedaccionFT'; // Título del archivo
        contentVersionTarea.PathOnClient = 'RedaccionFT.pdf'; // Ruta y nombre del archivo
        contentVersionTarea.VersionData = Blob.toPdf(renderizarHTML(UserInfo.getUserId(), reclamacionId, listaTemplates[0].HtmlValue)); // Convertir el contenido a PDF renderizando el HTML de la plantilla
        contentVersionTarea.FirstPublishLocationId = listaAcciones[0].Id;
        contentVersionTarea.SAC_Bloque__c = 'SAC_Tramitacion'; //Poner el bloque de tramitación
        listaCV.add(contentVersionTarea);
    
        return listaCV;
    }

    /*****************************************************************
     * Proposito: Manda email al cliente con el valor de la plantilla recuperada
     * 
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US383941         CS             05/06/23     Creación
    *****************************************************************/
    private static void mandarEmail(Case reclamacion, List<EmailTemplate> listaTemplates) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress orgwideaddress = new OrgWideEmailAddress();
        if (reclamacion.SAC_M2P__c) {
            orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname = 'Servicio Atención Cliente M2P' LIMIT 1];
        } else {
            orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname = 'CaixaBank SAC' LIMIT 1];
        }
        List<String> listaDirecciones = new List<String>();
        listaDirecciones.add(reclamacion.OS_Email__c);
        message.toaddresses = listaDirecciones;
        if(String.isNotBlank(listaTemplates[0].Subject)) {
            message.subject = listaTemplates[0].Subject;
        }
        if(String.isNotBlank(listaTemplates[0].HtmlValue)) {
            message.htmlbody = renderizarHTML(UserInfo.getUserId(), reclamacion.Id, listaTemplates[0].HtmlValue);
        }
        message.setOrgWideEmailAddressId(orgwideaddress.Id);
        message.setWhatId(reclamacion.Id);
        //Mandamos el mail
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }

    private static string renderizarHTML(Id usuario, Id objetoId, string body) {
        List<String> bodies = new List<String>();
        bodies.add(body); 
        List<Messaging.RenderEmailTemplateBodyResult> resList = Messaging.renderEmailTemplate(usuario, objetoId, bodies);
        return resList[0].getMergedBody();
    }


    public class WrapperFinalizarNegociacion {
        @AuraEnabled public Boolean listoFinalizarNegociacion {get; set;}
        @AuraEnabled public Boolean tieneFechaResolucion {get; set;}

        public WrapperFinalizarNegociacion(Boolean listoFinalizarNegociacion, Boolean tieneFechaResolucion) {
            this.listoFinalizarNegociacion = listoFinalizarNegociacion;
            this.tieneFechaResolucion = tieneFechaResolucion;
        }
    }

    /*****************************************************************
     * Proposito: Verificar que todas las pretensiones tienen la negociación finalizada
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US392178      Sergio Martín   10/07/23     Creación
    *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static WrapperFinalizarNegociacion getListoFinalizarNegociacion(Id record){
        WrapperFinalizarNegociacion listoFinalizar = new WrapperFinalizarNegociacion(false, false);
        List<Case> pretensionesCaso = new List<Case>();
        Case casoActual = [SELECT Id, RecordTypeId, OS_Fecha_Resolucion__c FROM Case WHERE RecordType.DeveloperName LIKE 'SAC_%' AND Id =: record LIMIT 1];

        try {
            if(casoActual.RecordTypeId == RECTYPERECLAMACION){
                pretensionesCaso = [SELECT Id, SAC_NegociacionFinalizada__c, Status FROM Case WHERE RecordTypeId =: RECTYPEPRETENSION AND Status = 'SAC_007'AND SAC_Reclamacion__c =: record];
                for(Case pretension : pretensionesCaso) {
                    if(pretension.SAC_NegociacionFinalizada__c == true && pretension.Status != 'Cerrado' && pretension.Status != 'SAC_009') {
                        listoFinalizar.listoFinalizarNegociacion = true;
                    } else if(pretension.SAC_NegociacionFinalizada__c == false && pretension.Status != 'Cerrado' && pretension.Status != 'SAC_009') {
                        listoFinalizar.listoFinalizarNegociacion = false;
                        break;
                    }
                }
                if(casoActual.OS_Fecha_Resolucion__c != null) {
                    listoFinalizar.tieneFechaResolucion = true;
                }
            } else {
                listoFinalizar.listoFinalizarNegociacion = false;
            }
            
            return listoFinalizar;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
    }


    /*****************************************************************
     * Proposito: Método para actualizar el estado de una reclamación y 
     *          de sus pretensiones cuando están en negociación
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US392178      Sergio Martín    12/07/23         Creación
    *****************************************************************/
    @AuraEnabled
    public static void updateRecordStatusReclamacion(Id record, String estado){
        if(!Schema.sObjectType.Case.isAccessible()){ throw new AuraHandledException( 'Fallo al actualizar.' ); }
        List<Case> listaCaso = [SELECT Id, recordTypeId, Status FROM Case WHERE RecordTypeId =: RECTYPERECLAMACION AND Id =: record];
        if(!listaCaso.isEmpty()){
            Case casoPorActualizar = listaCaso[0];
            List<Case> listaFamiliaCasos = new List<Case>();
            
            if(casoPorActualizar.recordTypeId == RECTYPERECLAMACION){
                listaFamiliaCasos = [SELECT id, recordTypeId, Status, SAC_NegociacionFinalizada__c FROM  Case WHERE RecordTypeId =: RECTYPEPRETENSION AND SAC_Reclamacion__c =: record AND Status = 'SAC_007'];
                
                Boolean listoFinalizarNegociacion = comprobarNegociacionFinalizada(listaFamiliaCasos);
                if(!listoFinalizarNegociacion) {
                    throw new AuraHandledException('No todas las pretensiones están marcadas con el check Negociación finalizada');
                }
                
                if(!listaFamiliaCasos.isEmpty()){
                    for (Case pretension : listaFamiliaCasos) {
                        pretension.Status = estado;
                        pretension.SAC_StatusAuxiliar__c = estado;
                    }
                }
            } 
            
            casoPorActualizar.Status = estado;
            casoPorActualizar.SAC_StatusAuxiliar__c = estado;   
            
            // Informar la fecha de fin de negociacion
            casoPorActualizar.SAC_FechaFinNegociacion__c = system.now();
            
            listaFamiliaCasos.add(casoPorActualizar);
            
            if(Case.SObjectType.getDescribe().isUpdateable()){
                try {
                    SAC_DatabaseDML.updateListDML(listaFamiliaCasos, true); 
                    //Database.update(listaFamiliaCasos);
                } catch (Exception e) { 
                    String errorMsg = e.getMessage();
                    String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
                    if (String.isNotBlank(pureErrorMsg)) {
                        pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-4));
                        throw new AuraHandledException(pureErrorMsg);
                    } else {
                        throw new AuraHandledException(e.getMessage());
                    }
                }
                
            } else{ throw new AuraHandledException( 'Fallo al actualizar.' ); }
        } else {
            throw new AuraHandledException( 'No se ha encontrado el caso' );
        }
    }


    /*****************************************************************
     * Proposito: Método para actualizar el estado de una reclamación y 
     *          de sus pretensiones a negociación cuando están en ejecucion
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US392178      Sergio Martín    21/07/23         Creación
    *****************************************************************/
    @AuraEnabled
    public static void updateRecordStatusNegociacionReclamacion(Id record){
        if(!Schema.sObjectType.Case.isAccessible()){ throw new AuraHandledException( 'Fallo al actualizar.' ); }
        List<Case> listaCaso = [SELECT Id, recordTypeId, Status FROM Case WHERE RecordTypeId =: RECTYPERECLAMACION AND Id =: record];
        if(!listaCaso.isEmpty()){
            Case casoPorActualizar = listaCaso[0];
            List<Case> listaFamiliaCasos = new List<Case>();
            
            if(casoPorActualizar.recordTypeId == RECTYPERECLAMACION){
                listaFamiliaCasos = [SELECT id, recordTypeId, Status, SAC_NegociacionFinalizada__c FROM  Case WHERE RecordTypeId =: RECTYPEPRETENSION AND SAC_Reclamacion__c =: record AND Status = 'Cerrado'];
                
                if(!listaFamiliaCasos.isEmpty()){
                    for (Case pretension : listaFamiliaCasos) {
                        pretension.Status = 'SAC_007';
                        pretension.SAC_StatusAuxiliar__c = 'SAC_007';
                    }
                }
            } 
            
            casoPorActualizar.Status = 'SAC_007';
            casoPorActualizar.SAC_StatusAuxiliar__c = 'SAC_007';   
            
            listaFamiliaCasos.add(casoPorActualizar);
            
            if(Case.SObjectType.getDescribe().isUpdateable()){
                try {
                    SAC_DatabaseDML.updateListDML(listaFamiliaCasos, true); 
                    //Database.update(listaFamiliaCasos);
                } catch (Exception e) { 
                    String errorMsg = e.getMessage();
                    String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
                    if (String.isNotBlank(pureErrorMsg)) {
                        pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-4));
                        throw new AuraHandledException(pureErrorMsg);
                    } else {
                        throw new AuraHandledException(e.getMessage());
                    }
                }
                
            } else{ throw new AuraHandledException( 'Fallo al actualizar.' ); }
        } else {
            throw new AuraHandledException( 'No se ha encontrado el caso' );
        }
    }
    

    /*****************************************************************
    * Proposito: Finalizar la negociación de la reclamación y
    *     entrar en la fase de ejecucion o cerrar la reclamación.
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US392178      Sergio Martín    17/07/2023       Creación
    *****************************************************************/ 
    @AuraEnabled
    public static void finalizarNegociacion(String record){
        if(!Schema.sObjectType.Case.isAccessible() || !Schema.sObjectType.SAC_Accion__c.isAccessible() || !Schema.sObjectType.SAC_Accion__c.isUpdateable() || !Schema.sObjectType.Case.isUpdateable()){
            throw new AuraHandledException('No tienes privilegios para manipular la redacción.');
        }

        Case reclamacion = [SELECT Id, OS_Fecha_Resolucion__c, Status, SAC_Redaccion__c, OS_Email__c, CaseNumber, AccountId , CC_No_Identificado__c
                            FROM Case WHERE RecordTypeId =: RECTYPERECLAMACION AND Id =: record];
                            
        if(reclamacion.AccountId != null || reclamacion.CC_No_Identificado__c == true){
            List<Case> pretensiones = [SELECT Id, Status, SAC_NegociacionFinalizada__c FROM Case WHERE RecordTypeId =: RECTYPEPRETENSION AND SAC_Reclamacion__c =: reclamacion.Id];

            Boolean listoFinalizarNegociacion = comprobarNegociacionFinalizada(pretensiones);
            if(!listoFinalizarNegociacion) {
                throw new AuraHandledException('No todas las pretensiones están marcadas con el check Negociación finalizada');
            }

            // Informar la fecha de fin de negociacion
            reclamacion.SAC_FechaFinNegociacion__c = system.now();
            
            //actualizar estados de tareas + notificacion a los equipos ejecutores
             
            List<SAC_Accion__c> tareas = [SELECT Id, OwnerId, SAC_Estado__c, SAC_Pretension__c, SAC_Reclamacion__c, Name, SAC_EquipoResponsable__c,
                                            SAC_Reclamacion__r.SAC_CasoEspecial__c, SAC_Reclamacion__r.SAC_Entidad_Afectada__c, SAC_Reclamacion__r.SEG_Grupo__c,
                                            SAC_ImporteResuelto__c, SAC_Reclamacion__r.CC_Importe_Reclamado__c, SAC_Reclamacion__r.SAC_Importe_Resuelto__c,
                                            SAC_MaestroAccionesReclamacion__r.Name, SAC_Oficina__c, SAC_Oficina__r.CC_Email__c, SAC_Comentarios__c
                                            FROM SAC_Accion__c WHERE SAC_Reclamacion__c =: record 
                                            AND (SAC_Estado__c != 'SAC_Finalizada' AND SAC_Estado__c != 'SAC_FinalizadaIncompleta' AND SAC_Estado__c != 'SAC_Descartada')];

            SAC_Interaccion.ValidacionesEscalado validacion = SAC_Interaccion.validacionesEscalados(record);
            if(validacion.mensaje != '') {
                throw new AuraHandledException(validacion.mensaje);
            }
            
           
            if(!tareas.isEmpty()){
                reclamacion.Status = 'SAC_004';
                reclamacion.SAC_StatusAuxiliar__c = 'SAC_004';   
                SAC_LCMP_RedaccionFinal.gestionarTareas(tareas, reclamacion.CaseNumber); //Las tareas cambian de estado                
            }
            else{//cuando viene del reenvio de la redacción final
                reclamacion.Status = 'Cerrado';
                reclamacion.SAC_StatusAuxiliar__c = 'Cerrado';
            }

            for(Case pretension : pretensiones){
                if(pretension.Status != 'SAC_009') {
                    pretension.Status = 'Cerrado';
                    pretension.SAC_StatusAuxiliar__c = 'Cerrado';
                }
            }

            List<Case> listaCasosUpdatear = new List<Case>();
            listaCasosUpdatear.addAll(pretensiones);
            listaCasosUpdatear.add(reclamacion);
            SAC_DatabaseDML.updateListDML(listaCasosUpdatear, true); 
            //Database.update(listaCasosUpdatear);  

        } else{
            throw new AuraHandledException('Para resolver es necesario informar el cliente.');
        }
    }


    /*****************************************************************
    * Proposito: Comprobar que todas las pretensiones en negociación tienen el check de SAC_NegociacionFinalizada__c
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US392178      Sergio Martín    21/07/2023       Creación
    *****************************************************************/ 
    @AuraEnabled
    public static Boolean comprobarNegociacionFinalizada(List<Case> pretensiones){
        Boolean listoFinalizarNegociacion = true;
        for(Case pretension : pretensiones) {
            if(pretension.SAC_NegociacionFinalizada__c == false && pretension.Status == 'SAC_007') {
                listoFinalizarNegociacion = false;
            }
        }
        return listoFinalizarNegociacion;
    }


    /*****************************************************************
    * Proposito: Recuperar los emails de la blackList y pasar al SAC_Utils.comprobarEmailsBlackList las direcciones de envio. Aqui comprobará si son válidas
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US723742      Raúl Santos   05/03/2024       Creación
    *****************************************************************/
    @AuraEnabled
    public static String comprobarEmailsEnvio(String para, String copia, String copiaOculta) {

        //Recupero los emails no validos de envio (emails en la blackList)
        List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];

        //Compruebo las direcciones de envio con las de la blackList
        String emailsNoValidosEncontrados = SAC_Utils.comprobarEmailsBlackList(listEmailsNoValidos, para, copia, copiaOculta);

        //Devuelvo las direcciones de envio no válidas encontradas (están en la blackList) o si las direcciones son válidas devuelvo ''
        return emailsNoValidosEncontrados;
    }


    /*****************************************************************
    * Proposito: Recuperar los Milestone activos del caso para mostrarlos como 
    *        parados en el caso cuando se está en estado de subsanación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR           DATE         Description
    * 1.0            US959472      Sergio Martín    29/07/2024       Creación
    *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String, String> recuperarSLAActivos(Id recordId) {
        Map<String, String> mapaMilestone = new Map<String, String>();
        //Recupero los milestone del caso
        List<CaseMilestone> listaCaseMilestone = [SELECT caseid, IsCompleted, MilestoneType.Name, TargetDate, Case.SAC_DetenidoDesde__c
                                                    FROM CaseMilestone WHERE caseId =: recordId AND IsCompleted = false AND IsViolated = false];

        if (!listaCaseMilestone.isEmpty()) {
            for (CaseMilestone caseMil : listaCaseMilestone) {
                Long milliseconds = caseMil.TargetDate.getTime() - caseMil.Case.SAC_DetenidoDesde__c.getTime();
                Long days = Math.floor(milliseconds / (1000 * 60 * 60 * 24)).longValue();
                Long hours = Math.floor((Math.mod(milliseconds, (1000 * 60 * 60 * 24))) / (1000 * 60 * 60)).longValue();
                Long minutes = Math.floor((Math.mod(milliseconds, (1000 * 60 * 60))) / (1000 * 60)).longValue();
                Long seconds = Math.floor((Math.mod(milliseconds, (1000 * 60))) / 1000).longValue();
                String totalTime = '{0} días, {1} h, {2} min, {3} s restante';
                totalTime = String.format(totalTime,new List<Long>{days, hours, minutes, seconds});
                //Quitar cadenas innecesarias
                totalTime = ' restante';
                if(seconds > 0){
                    totalTime = ', ' + seconds + ' s' + totalTime;
                }
                if(minutes > 0){
                    totalTime =', ' +  minutes + ' min' + totalTime;
                }
                if(hours > 0){
                    totalTime = ', ' + hours + ' h'+ totalTime;
                }
                if(days > 0){
                    totalTime = days + ' días'+ totalTime;
                }
                if(totalTime.startsWith(', ')){
                    totalTime = totalTime.removeStart(', ');
                }
                mapaMilestone.put(caseMil.MilestoneType.Name, totalTime);
            }
        }
        return mapaMilestone;
    }

    @AuraEnabled
    public static void checkImportesGGHPretensiones(String record){
        // Get Pretensiones
        List<Case> pretensiones = [SELECT Id, SEG_Detalle__r.SAC_esGGH__c , SAC_ImpReclamadoGestoria__c, SAC_ImpReclamadoInteresesLegales__c, SAC_ImpReclamadoNotaria__c, SAC_ImpReclamadoRegistros__c, 
                                    SAC_ImpReclamadoTasacion__c, SAC_TasacionReclamado__c, SAC_RegistrosReclamado__c, SAC_NotariaReclamado__c, SAC_GestoriaReclamado__c, CaseNumber
                                    FROM Case
                                    WHERE SEG_Detalle__r.SAC_esGGH__c = true
                                    AND SAC_Reclamacion__c =: record];
        for (Case pret : pretensiones) {
            if ((pret.SAC_ImpReclamadoGestoria__c == null  && pret.SAC_ImpReclamadoInteresesLegales__c == null  
            && pret.SAC_ImpReclamadoNotaria__c == null  && pret.SAC_ImpReclamadoRegistros__c == null  && pret.SAC_ImpReclamadoTasacion__c == null) || 
            (pret.SAC_TasacionReclamado__c == null || pret.SAC_RegistrosReclamado__c == null || pret.SAC_NotariaReclamado__c == null || pret.SAC_GestoriaReclamado__c == null)){
                throw new AuraHandledException('No se puede pasar a Inadmisión, las siguientes pretensiones ' + pret.CaseNumber +  ' no tienen los importes reclamados informados');
            }
        }
    }
}