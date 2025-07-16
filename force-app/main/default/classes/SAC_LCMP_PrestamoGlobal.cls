/*
* @description: SAC_PrestamoGlobal aura component Controller
* @test: SAC_LCMP_PrestamoGlobalTest
* @author: iria.alvarez.novoa@ibm.com
* @date: september 2024
*/
public with sharing class SAC_LCMP_PrestamoGlobal {
    private static final Id RECTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    private static String noConsumidor = 'No consumidor';
    private static String empleados = 'Empleados';
    private static String antigReclamacion = 'Antigüedad Reclamación';
    private static String prescripcion = 'Prescripción';
    private static String prestamoRT = 'SAC_Prestamo';
    private static String statusAlta = 'SAC_001';
    private static String statusAnalisis = 'SAC_002';
    private static List<String> cnaeValues = new List<String>{'99', '0099'};
    private static Date navCancelation1 = Date.newInstance(1994, 10, 16);
    private static Date navCancelation2 = Date.newInstance(1994, 10, 17);
    private static Date navCancelation3 = Date.newInstance(2019, 10, 16);
    private static Date navCancelation4 = Date.newInstance(2024, 10, 16);
    private static String tipoPlantilla = 'SAC_ResolucionExpress';
    private static String carpetaAdjuntos = 'SAC_ResolucionExpressAdjuntos';
    private static String tipoDocumento = 'inadmision - prestamo';
    private static String castellano = 'es';
    private static String ingles = 'en';
    private static String catalan = 'ca';
    private static String valenciano = 'va';
    private static String euskera = 'eu';
    private static String gallego = 'ga';
    private static List<String> catProvinces = new List<String>{'Barcelona', 'Tarragona', 'Lleida', 'Girona'};
    private static List<String> navProvinces = new List<String>{'Navarra'};
    private static Set<String> objetos = new Set<String>{'Case','SAC_Antecedentes__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    private static Id reclamacionesHISTORICAS = mapRTsObjects.get('SAC_Antecedentes__c').get('SAC_ReclamacionesHistoricas').getRecordTypeId();
    private static Id reclamacionesCBPO = mapRTsObjects.get('SAC_Antecedentes__c').get('SAC_AntecedentesSupervisoresCBPO').getRecordTypeId();
    private static String profileName = 'SAC_General';
    private static String textSAC = 'SAC';
    private static String textCBPO = 'CBPO';
    private static String reclamanteText = 'reclamante';
    private static String cotitularText = 'cotitular';
    private static String encryption = 'XXXXX';

    /* @description: method that gets validations (in order)
     * @param prestamo: prestamo record
     * @param fechaRecActual: fecha recepción reclamación
     * @param recId: id reclamación
     * @param accountId: acocuntId reclamación
	 */
    @AuraEnabled (cacheable = true)
    public static String checkValidations(SAC_Prestamo__c prestamo, Date fechaRecActual, String recId, String accountId) {
        String validation;
        // Criteria "No consumidor"
        if(!cnaeValues.contains(prestamo.SAC_Codigo_CNAE__c)){
            validation = noConsumidor;
        }
        // Criteria "Empleados"
        else if(prestamo.SAC_Operacion_Empleado__c){
            validation = empleados;
        } else{
            Date fechaReciente = getAllAntecedentes(recId);
            if(catProvinces.contains(prestamo.SAC_Provincia_centro_gestor__c)){
                // Criteria "Antigüedad Reclamación" - Catalunya
                if(fechaReciente != null && fechaReciente.addYears(10) < fechaRecActual){
                    validation = antigReclamacion;
                }
                // Criteria "Prescripción" - Catalunya
                else if(prestamo.SAC_Fecha_cancelacion_real_prestamo__c != null && prestamo.SAC_Fecha_cancelacion_real_prestamo__c.addYears(10) < fechaRecActual){
                    validation = prescripcion;
                }
            } else if(navProvinces.contains(prestamo.SAC_Provincia_centro_gestor__c)){
                // Criteria "Antigüedad Reclamación" - Navarra
                if(fechaReciente != null && ((fechaReciente < navCancelation3 && fechaRecActual > navCancelation4) || (fechaReciente > navCancelation3 && fechaReciente.addYears(5) <= fechaRecActual))){
                    validation = antigReclamacion;
                }
                // Criteria "Prescripción" - Navarra
                else if(prestamo.SAC_Fecha_cancelacion_real_prestamo__c != null && ((prestamo.SAC_Fecha_cancelacion_real_prestamo__c < navCancelation1 && prestamo.SAC_Fecha_cancelacion_real_prestamo__c.addYears(30) < fechaRecActual) ||
                        (prestamo.SAC_Fecha_cancelacion_real_prestamo__c >= navCancelation2 && prestamo.SAC_Fecha_cancelacion_real_prestamo__c <= navCancelation3 && fechaRecActual > navCancelation4) ||
                        (prestamo.SAC_Fecha_cancelacion_real_prestamo__c > navCancelation3 && prestamo.SAC_Fecha_cancelacion_real_prestamo__c.addYears(5) < fechaRecActual))){
                            validation = prescripcion;
                        }
            } else{
                // Criteria "Antigüedad Reclamación" - Rest of Spain
                if(fechaReciente != null && fechaReciente.addYears(5).addDays(82) < fechaRecActual){
                    validation = antigReclamacion;
                }
                // Criteria "Prescripción" - Rest of Spain
                else if(prestamo.SAC_Fecha_cancelacion_real_prestamo__c != null && prestamo.SAC_Fecha_cancelacion_real_prestamo__c.addYears(5).addDays(82) < fechaRecActual){
                    validation = prescripcion;
                }
            }
        }
        return validation;
    }

    /* @description: method that gets MCC metadata
	 */
    @AuraEnabled (cacheable=true)
    public static List<SAC_MCC_Prestamos__mdt> getMetadataMCC(){
        // Get specific MCCs
        return [SELECT Id, SAC_Tematica__c, SAC_ProductoServicio__c, SAC_Motivo__c, SAC_Detalle__c FROM SAC_MCC_Prestamos__mdt];
    }

    /* @description: method that maps MCC metadata (SF)
	 */
    @AuraEnabled (cacheable=true)
    public static Map<String, List<SAC_MCC_Prestamos__mdt>> getSFMetadataMCC(){
		List<SAC_MCC_Prestamos__mdt> mccsToCheckList = getMetadataMCC();
        Map<String, List<SAC_MCC_Prestamos__mdt>> mccToCheckMapSF = new Map<String, List<SAC_MCC_Prestamos__mdt>>();
        for(SAC_MCC_Prestamos__mdt mccToCheck : mccsToCheckList){
            if(mccToCheckMapSF.containsKey(mccToCheck.SAC_Tematica__c)){
                List<SAC_MCC_Prestamos__mdt> mccList = mccToCheckMapSF.get(mccToCheck.SAC_Tematica__c);
                mccList.add(mccToCheck);
                mccToCheckMapSF.put(mccToCheck.SAC_Tematica__c, mccList);
            }else{
                List<SAC_MCC_Prestamos__mdt> mccList = new List<SAC_MCC_Prestamos__mdt>();
                mccList.add(mccToCheck);
                mccToCheckMapSF.put(mccToCheck.SAC_Tematica__c, mccList);
            }
        }
        return mccToCheckMapSF;
    }

    /* @description: method that maps MCC metadata (SIEBEL)
	 */
    @AuraEnabled (cacheable=true)
    public static Map<String, List<SAC_MCC_Prestamos__mdt>> getSBLMetadataMCC(){
        List<SAC_MCC_Prestamos__mdt> mccsToCheckList = getMetadataMCC();
        Map<String, List<SAC_MCC_Prestamos__mdt>> mccToCheckMapSBL = new Map<String, List<SAC_MCC_Prestamos__mdt>>();
        for(SAC_MCC_Prestamos__mdt mccToCheck : mccsToCheckList){
            if(mccToCheckMapSBL.containsKey(mccToCheck.SAC_ProductoServicio__c)){
                List<SAC_MCC_Prestamos__mdt> mccList = mccToCheckMapSBL.get(mccToCheck.SAC_ProductoServicio__c);
                mccList.add(mccToCheck);
                mccToCheckMapSBL.put(mccToCheck.SAC_ProductoServicio__c, mccList);
            }else{
                List<SAC_MCC_Prestamos__mdt> mccList = new List<SAC_MCC_Prestamos__mdt>();
                mccList.add(mccToCheck);
                mccToCheckMapSBL.put(mccToCheck.SAC_ProductoServicio__c, mccList);
            }
        }
        return mccToCheckMapSBL;
    }

    /* @description: method that checks if "Inadmitir Reclamación" button must be visible
     * @param recId: id reclamación
	 */
    @AuraEnabled
    public static Boolean inadmitirButtonVisibleOrHidden(Id recId, Boolean cumpleCriterio) {
        Boolean showButton = false;
        if(cumpleCriterio){
            // Get Case
            Case reclamacion = devolverCaso(recId);
            // Only if Status is "Alta" or "Análisis"
            if(reclamacion.Status == statusAlta || reclamacion.Status == statusAnalisis){
                showButton = true;
            }
        }
        return showButton;
    }

    /* @description: method that gets préstamos to show in lookup
     * @param searchKeyWord: written word
     * @param ObjectName: SAC_Prestamo__c
     * @param idReclamacion: id reclamación
	 */
    @AuraEnabled (cacheable=true)
    public static List<sObject> lookupValues(String reclamacionId) {
        List<sObject> returnList = new List<sObject>();
        List<String> reclamantesNumPerso = new List<String>();
        List<SAC_Prestamo__c> prestamosMCC = new List<SAC_Prestamo__c>();
        Case reclamacion = devolverCaso(reclamacionId);
        for(SAC_CaseReclamante__c reclamante : getReclamantes(reclamacion.Id)){
            reclamantesNumPerso.add(reclamante.SAC_Account__r.CC_NumPerso__c);
        }
        List<SAC_Prestamo__c> prestamoList = getPrestamosbyReclamantes(reclamantesNumPerso);
        for(SAC_Prestamo__c prestamo: prestamoList){
            String validation = checkValidations(prestamo, Date.valueOf(reclamacion.SAC_FechaRecepcion__c), reclamacion.Id, reclamacion.AccountId);
            if(validation != null){
                prestamosMCC.add(prestamo);
            }
        }
        for(sObject obj: prestamosMCC) {returnList.add(obj);}
        return returnList;
    }


	/* @description: method to create URL for Documento de Inadmisión
	 * @param caseId: Id de la reclamación
	 * param prestamoId: Id del préstamo
	 */
    @AuraEnabled
    public static String motivoInadmision(Id recId, Id prestamoId){
        String validation;
        Case reclamacion = devolverCaso(recId);
        // Get Préstamo records related to all reclamantes (only Prestamo RT)
		SAC_Prestamo__c prestamo =  [SELECT Id, SAC_Codigo_Contrato_TF7__c, CreatedDate, SAC_Codigo_CNAE__c, SAC_Operacion_Empleado__c, SAC_Provincia_centro_gestor__c, SAC_Fecha_cancelacion_real_prestamo__c
                                               FROM SAC_Prestamo__c
                                               WHERE Id =: prestamoId LIMIT 1];
        // Transform TF7 Code
        String transformedCode;
        if(prestamo.SAC_Codigo_Contrato_TF7__c != null && prestamo.SAC_Codigo_Contrato_TF7__c.length() == 19){
            String parte1 = prestamo.SAC_Codigo_Contrato_TF7__c.substring(0, 9);
            String parte2 = encryption;
            String parte3 = prestamo.SAC_Codigo_Contrato_TF7__c.substring(14, 19);
            transformedCode = parte1 + parte2 + parte3;
        }
        // Update reclamacion
        reclamacion.SAC_Prestamo_seleccionado__c = transformedCode;
        update reclamacion;
        // Check validations of all Préstamos
		validation = checkValidations(prestamo, Date.valueOf(reclamacion.SAC_FechaRecepcion__c), reclamacion.Id, reclamacion.AccountId);
        return validation;
    }

	/* @description: method that checks DocumentoEnvio "Inadmisión - Préstamo"
	 * @param caseId: id reclamación
	 */
     @AuraEnabled
     public static Boolean compruebaDocumentoInadmision(String caseId){
         List<SAC_DocumentoEnvio__c> docGuardado = [SELECT Id, SAC_Cuerpo__c, SAC_Header__c, SAC_Footer__c
                                                    FROM SAC_DocumentoEnvio__c
                                                    WHERE SAC_Caso__c = :caseId
                                                    AND SAC_TipoDocumento__c =: tipoDocumento ORDER by createdDate desc LIMIT 1];


         return !docGuardado.isEmpty() ? true : false;
     }

	/* @description: method that creates DocumentoEnvio "Inadmisión - Préstamo"
	 * @param caseId: id reclamación
	 * @param idioma: idioma
	 * @param motivoInadmisión: motivo inadmisión
	 */
    @AuraEnabled
    public static void generarDocumentoInadmision(Id caseId, String idioma){
        List<EmailTemplate> lstPlantillas = new List<EmailTemplate>();
        EmailTemplate plantillaHeader = new EmailTemplate();
        EmailTemplate plantillaFooter = new EmailTemplate();
        // Get Email Template
        String templateName = carpetaAdjuntos + '_' + idioma;
        List<EmailTemplate> etList = new List<EmailTemplate>();
        if(!Test.isRunningTest()){
            etList = [SELECT Id, HtmlValue, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName =: carpetaAdjuntos AND DeveloperName =: templateName LIMIT 1];
            if(etList.isEmpty()){
                templateName = carpetaAdjuntos + '_es';
                etList = [SELECT Id, HtmlValue, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName =: carpetaAdjuntos AND DeveloperName =: templateName LIMIT 1];
            }
        }else{
            etList = [SELECT Id, HtmlValue, DeveloperName FROM EmailTemplate LIMIT 1];
        }
        // Get Header and Footer
        if (Schema.sObjectType.EmailTemplate.isAccessible()){
            lstPlantillas = [SELECT Id, Name, HtmlValue, DeveloperName, Folder.DeveloperName FROM EmailTemplate WHERE Developername IN ('SAC_Header','SAC_Footer')];
        }
        if(lstPlantillas != null && !lstPlantillas.isEmpty()) {
            for(EmailTemplate em : lstPlantillas) {
                if(em.DeveloperName == 'SAC_Header') {
                    plantillaHeader = em;
                } else if(em.DeveloperName == 'SAC_Footer') {
                    plantillaFooter = em;
                }
            }
        }
        String docHTML = '';
        if(!etList.isEmpty()){
            Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(etList[0].Id, null, caseId);
            docHTML = renderStored.getHtmlBody();
        }
        SAC_DocumentoEnvio__c docEnvio = new SAC_DocumentoEnvio__c();
        docEnvio.SAC_Caso__c = caseId;
        docEnvio.SAC_Documento__c = null;
        docEnvio.SAC_DocPDF__c = docHTML;
        docEnvio.SAC_Header__c = plantillaHeader.HtmlValue;
        docEnvio.SAC_Footer__c = plantillaFooter.HtmlValue;
        docEnvio.SAC_Version__c = '1';
        docEnvio.SAC_TipoDocumento__c = tipoDocumento;
        insert docEnvio;
        if(!Test.isRunningTest()){
            SAC_LCMP_GeneracionDocumento.generarDocumentoInadmision(caseId);
        }
    }

   /* @description: method that checks Documento de Inadmisión
    * @param id: Id de la reclamación
    */
    @AuraEnabled
    public static Boolean compruebaPDFs(String id){
        return SAC_LCMP_RedaccionFinal.compruebaPDFs(id);
    }

   	/* @description: method that shows Documento de Inadmisión
	 * @param caseId: Id de la reclamación
	 */
     @AuraEnabled
     public static String visualizarDocumentoInadmision(Id caseId){
         String urlVF = 'https://';
         SAC_DocumentoEnvio__c docEnvio = [SELECT SAC_Caso__c, SAC_Documento__c, SAC_DocPDF__c, SAC_Version__c, Id
                                           FROM SAC_DocumentoEnvio__c
                                           WHERE SAC_Caso__c =: caseId and SAC_Documento__c = null
                                           ORDER BY CreatedDate DESC LIMIT 1];

         String vfHostname = DomainCreator.getVisualforceHostname(null);
         urlVF += vfHostname + '/apex/SAC_DocumentoRedaccionPDF?id=' + docEnvio.Id;
         return urlVF;
     }

   	/* @description: method that checks if user has permission
	 * @param reclamacion: reclamación
	 */
    @AuraEnabled
    public static Boolean recuperarPermiso(Case reclamacion){
        return SAC_LCMP_RedaccionFinal.recuperarPermiso(reclamacion);
    }

   	/* @description: method that saves sentido, motivo and argumento
	 * @param id: id reclamación
	 * @param sentido: sentido reclamación
	 * @param argumento: argumento reclamación
	 * @param motivoInad: motivo inadmisión reclamación
	 */
    @AuraEnabled
    public static void guardarResolucionApex(String id, String sentido, String argumento, String motivoInad){
        SAC_LCMP_RedaccionFinal.guardarResolucionApex(id, sentido, argumento, motivoInad);
    }

   	/* @description: method for inadmisión emails
	 * @param idCaso: id reclamación
	 * @param motivoInadmision: motivo inadmisión
 	 */
	@AuraEnabled
    public static SAC_LCMP_RedaccionFinal.DatosEmailWrapper obtenerDatosEmailInadmision(String idCaso){
        try {
                Case caso = devolverCaso(idCaso);
                Id idPlantilla;
            List<EmailTemplate> etList = new List<EmailTemplate>();
                if(!Test.isRunningTest()){
                    idPlantilla = obtenerPlantillaInadmision(caso.CC_Idioma__c);
                etList =[SELECT Id, Body, HtmlValue FROM EmailTemplate WHERE id =:idPlantilla LIMIT 1];
                }else{
                etList =[SELECT Id, Body, HtmlValue FROM EmailTemplate LIMIT 1];
                }
                ContentDocument[] documentos = null;
                String para = '';
                if(String.isNotBlank(caso.AccountId)){
                    para = SAC_SeleccionDireccionRespuesta.getParaEmail(caso, caso.Account.RecordTypeId);
                }
            if(!etList.isEmpty()){
                String whoId = UserInfo.getUserId();
                Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(etList[0].Id, whoId, idCaso);
                if(String.isBlank(para)){
                    return new SAC_LCMP_RedaccionFinal.DatosEmailWrapper(caso.OS_Email__c, renderStored.getSubject(), renderStored.getHtmlBody(), '', caso, documentos);
                }
                else{
                    return new SAC_LCMP_RedaccionFinal.DatosEmailWrapper(para, renderStored.getSubject(), renderStored.getHtmlBody(), '', caso, documentos);
                }
            }else {
                return new SAC_LCMP_RedaccionFinal.DatosEmailWrapper(para, '', '', '', caso, documentos);
                }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

   	/* @description: method to get email templates for inadmisión (préstamos)
	 * @param motivoInadmision: motivo inadmisión
	 * @param idioma: idioma reclamación
	 */
    public static Id obtenerPlantillaInadmision(String idioma){
        Id idPlantilla;
        List<SAC_PlantillaRedaccion__c> plantillaList = [SELECT id, SAC_PlantillaCastellanoId__c, SAC_PlantillaCatalanId__c, SAC_PlantillaInglesId__c, SAC_PlantillaValencianoId__c, SAC_PlantillaEuskeraId__c, SAC_PlantillaGallegoId__c FROM SAC_PlantillaRedaccion__c WHERE  SAC_TipoPlantilla__c =: tipoPlantilla LIMIT 1];
        if(!plantillaList.isEmpty()){
            switch on idioma {
                when 'es' {
                    idPlantilla = plantillaList[0].SAC_PlantillaCastellanoId__c;
                }
                when 'ca' {
                    idPlantilla = plantillaList[0].SAC_PlantillaCatalanId__c;
                }
                when 'en' {
                    idPlantilla = plantillaList[0].SAC_PlantillaInglesId__c;
                }
                when 'va' {
                    idPlantilla = plantillaList[0].SAC_PlantillaValencianoId__c;
                }
                when 'eu' {
                    idPlantilla = plantillaList[0].SAC_PlantillaEuskeraId__c;
                }
                when 'ga' {
                    idPlantilla = plantillaList[0].SAC_PlantillaGallegoId__c;
                }
                when else {
                    idPlantilla = plantillaList[0].SAC_PlantillaCastellanoId__c;
                }
            }
        }
        return idPlantilla;
    }

   /* @description: method that gets CV
	* @param recordId: id
	*/
    @AuraEnabled
    public static List<ContentVersion> getCVRespuestas(Id recordId){
        return SAC_LCMP_RedaccionFinal.getCVRespuestas(recordId);
    }

    /* @description: method that gets reclamantes
	* @param reclamacionId: reclamación id
	*/
    @AuraEnabled (cacheable=true)
    public static List<SAC_CaseReclamante__c> getReclamantes(Id reclamacionId) {
        return [SELECT SAC_Case__c, SAC_Account__c, SAC_Account__r.CC_NumPerso__c, SAC_Account__r.CC_Numero_Documento__c
                FROM SAC_CaseReclamante__c WHERE SAC_Case__c = :reclamacionId];
    }

   /* @description: method that gets all prestamos (prestamo RT) for all reclamantes
	* @param reclamantesNumPerso: numperso reclamantes
	*/
    @AuraEnabled(cacheable=true)
    public static List<SAC_Prestamo__c> getPrestamosbyReclamantes(List<String> reclamantesNumPerso){
        List<String> ids = SAC_Utils.listaCampo([SELECT SAC_Prestamo__c FROM SAC_Prestamo_Titular__c
                                                WHERE SAC_Titular__r.SAC_Id_persona_en_Origen__c
                                                IN :reclamantesNumPerso], 'SAC_Prestamo__c', true);

        return [SELECT CreatedDate, SAC_Codigo_CNAE__c, SAC_Operacion_Empleado__c, SAC_Provincia_centro_gestor__c,
                SAC_Fecha_cancelacion_real_prestamo__c, Name, SAC_Codigo_Contrato_TF7__c
                FROM SAC_Prestamo__c WHERE RecordType.DeveloperName = :prestamoRT
                AND Id IN: ids ORDER BY RecordType.Name ASC];
    }

   	/* @description: method that gets reclamación record
	 * param id: id reclamación
	 */
    @AuraEnabled (cacheable=true)
    public static Case devolverCaso(String id){
        Case reclamacion = [SELECT Id, CC_Canal_Respuesta__c, OS_Fecha_Resolucion__c, SAC_SentidoResolucion__c, SAC_MotivoSentidoResolucion__c, OwnerId, Status,
                                  SAC_FechaRecepcion__c, SAC_Entidad_Afectada__c, SAC_EntidadProductora__c, CC_Oficina_Afectada_Lookup__c, CC_Oficina_Afectada_Lookup__r.CC_Email__c,
                                  SAC_Naturaleza__c, SAC_MotivoDemora__c, SAC_ComentarioDemora__c, Origin, SAC_MotivoInadmision__c, CC_Idioma__c, Account.CC_NumPerso__c,
                                  SAC_DireccionPostalNotificacion__c, AccountId, Account.RecordTypeId, OS_Email__c, Account.CC_Email__c, SAC_DireccionPostal__c, RecordTypeId,
                                  SuppliedEmail, CaseNumber, Subject, SAC_OrigenConsulta__c, CC_No_Identificado__c, recordType.Name, SAC_Reclamacion__r.OS_Email__c,
                                  CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name, SEG_Detalle__r.Name, SAC_Prestamo_seleccionado__c, SAC_TipoConsumidor__c
                                  FROM Case
                                  WHERE Id =: id LIMIT 1];
        return reclamacion;
    }

   	/* @description: method that gets préstamos
	 * param id: id reclamación
	 */
    @AuraEnabled(cacheable=true)
    public static Boolean checkPrestamos(String recId) {
        List<String> numpersoReclamantes = SAC_Utils.listaCampo(
            [SELECT SAC_Account__r.CC_NumPerso__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c = :recId AND SAC_Account__r.CC_NumPerso__c != null],
            'SAC_Account__r.CC_NumPerso__c'
        );
        if (numpersoReclamantes.isEmpty()) {
            return false;
        }

        return ![SELECT Id FROM SAC_Prestamo_Titular__c
                    WHERE SAC_Titular__r.SAC_Id_persona_en_Origen__c IN :numpersoReclamantes
                    AND SAC_Prestamo__r.RecordType.DeveloperName = :prestamoRT
                    AND SAC_Prestamo__c != null LIMIT 1].isEmpty();
    }

   	/* @description: antecedente wrapper
	 */
    public class antecedenteWrapper{
        @AuraEnabled
        public string caseNumber;
        @AuraEnabled
        public string caseSubject;
        @AuraEnabled
        public string caseId;
        @AuraEnabled
        public string nif;
        @AuraEnabled
        public string productoServicio;
        @AuraEnabled
        public string contrato;
        @AuraEnabled
        public string oficinaAfectada;
        @AuraEnabled
        public string estado;
        @AuraEnabled
        public string resolucion;
        @AuraEnabled
        public date fechaAlta;
        @AuraEnabled
        public date fechaCierre;
        @AuraEnabled
        public Decimal importeRec;
        @AuraEnabled
        public Decimal importeResuelto;
        @AuraEnabled
        public Decimal importeAbonado;
        @AuraEnabled
        public string idReclamacion;
        @AuraEnabled
        public string producto;
        @AuraEnabled
        public string materia;
        @AuraEnabled
        public string oficinaGestora;
        @AuraEnabled
        public string numProcedimiento;
        @AuraEnabled
        public string docRec;
        @AuraEnabled
        public string docRes;
        @AuraEnabled
        public string tematica;
        @AuraEnabled
        public string motivo;
        @AuraEnabled
        public string detalle;
    }

    /* @description: method that gets numPerso from cotitulares
	 * param tf7Codigo: codigo tf7 préstamo
	 */
    /*@AuraEnabled(cacheable=true)
    public static List<SAC_Prestamo_titular__c> getnumPersoCotitulares(String tf7Codigo) {
        return [SELECT Id, SAC_Titular__r.SAC_Id_persona_en_Origen__c FROM SAC_Prestamo_titular__c WHERE SAC_Prestamo__r.SAC_Codigo_Contrato_TF7__c =: tf7Codigo];
    }*/

    /* @description: method that gets numPerso from cotitulares
	 * param tf7Codigo: codigo tf7 préstamo
	 */
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountbyNumPerso(List<String> numPersoCotitulares) {
        return [SELECT Id, CC_Numero_Documento__c FROM Account WHERE CC_NumPerso__c IN: numPersoCotitulares];
    }

   	/* @description: method that gets Status (Case) picklist labels
	 * param picklistValue: picklist api name
	 */
    public static String getCaseStatusPicklistLabel(String picklistValue) {
        Schema.DescribeFieldResult fieldResult = Case.Status.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries) {
            if (entry.getValue() == picklistValue) {
                return entry.getLabel();
            }
        }
        return null;
    }

    /* @description: method that gets DNIs from cotitulares
	 * param tf7Codigo: codigo tf7 préstamo
	 * param recId: id reclamación
	 */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getDNIsReclamantesCotitulares(String recId) {
        Map<String, String> rolNumDoc = new Map<String, String>();
        List<String> reclamantesNumPerso = new List<String>();
        List<String> numPersoCotitulares = new List<String>();
        List<String> numDocCotitulares = new List<String>();
        // Find reclamantes
        for(SAC_CaseReclamante__c reclamante : getReclamantes(recId)){
            reclamantesNumPerso.add(reclamante.SAC_Account__r.CC_NumPerso__c);
            rolNumDoc.put(reclamante.SAC_Account__r.CC_Numero_Documento__c, reclamanteText);
        }
        // Find co-titulares
        List<SAC_Prestamo__c> prestamoList =  getPrestamosbyReclamantes(reclamantesNumPerso);
        List<SAC_Prestamo_Titular__c> prestamoTitular = [SELECT Id, SAC_Titular__c,  SAC_Titular__r.SAC_Id_persona_en_Origen__c
                                                         FROM SAC_Prestamo_Titular__c
                                                         WHERE SAC_Prestamo__c IN: prestamoList
                                                         AND SAC_Titular__r.SAC_Id_persona_en_Origen__c NOT IN: reclamantesNumPerso];
        for(SAC_Prestamo_Titular__c pt: prestamoTitular){
            if(!reclamantesNumPerso.contains(pt.SAC_Titular__r.SAC_Id_persona_en_Origen__c)){
                numPersoCotitulares.add(pt.SAC_Titular__r.SAC_Id_persona_en_Origen__c);
            }
        }
        if(!numPersoCotitulares.isEmpty() && numPersoCotitulares != null){
            for(Account acc: [SELECT Id, CC_Numero_Documento__c FROM Account WHERE CC_NumPerso__c IN: numPersoCotitulares]){
                if(!numDocCotitulares.contains(acc.CC_Numero_Documento__c)){
                    numDocCotitulares.add(acc.CC_Numero_Documento__c);
                    rolNumDoc.put(acc.CC_Numero_Documento__c, cotitularText);
                }
            }
        }
        return rolNumDoc;
    }

    /* @description: method that gets antecedentes from reclamantes and cotitulares
    * salesforce cases (reclamaciones)
    * param recId: id reclamación
    */
    @AuraEnabled
    public static Map<String, List<antecedenteWrapper>> getReclamacionesAnterioresToShow(String recId) {
        Map<String, List<antecedenteWrapper>> rolAntecedenteWrapper = new Map<String, List<antecedenteWrapper>>();
        // Get DNIs from all reclamantes and cotitulares
        Map<String, String> rolNumDoc = getDNIsReclamantesCotitulares(recId);
        List<String> numDocumentos = new List<String>(rolNumDoc.keySet());
        // Get Reclamaciones Anteriores SF (Cases)
        List<Case> reclamacionesAnteriores = getReclamacionesAnteriores(numDocumentos, recId);
        for(Case reclAnterior: reclamacionesAnteriores){
            if(rolNumDoc.containsKey(reclAnterior.Account.CC_Numero_Documento__c)){
                String rol = rolNumDoc.get(reclAnterior.Account.CC_Numero_Documento__c);
                antecedenteWrapper wr = new antecedenteWrapper();
                wr.tematica = reclAnterior.CC_MCC_Tematica__c != null ? reclAnterior.CC_MCC_Tematica__r.Name : null;
                wr.productoServicio = reclAnterior.CC_MCC_ProdServ__c != null ? reclAnterior.CC_MCC_ProdServ__r.Name : null;
                wr.motivo = reclAnterior.CC_MCC_Motivo__c != null ? reclAnterior.CC_MCC_Motivo__r.Name : null;
                wr.detalle = reclAnterior.SEG_Detalle__c != null ? reclAnterior.SEG_Detalle__r.Name : null;
                wr.caseNumber = reclAnterior.CaseNumber;
                wr.caseSubject = reclAnterior.Subject;
                wr.caseId = reclAnterior.Id;
                wr.estado = getCaseStatusPicklistLabel(reclAnterior.Status);
                wr.fechaAlta = Date.valueOf(reclAnterior.SAC_FechaRecepcion__c);
                if(rolAntecedenteWrapper.containsKey(rol)){
                    List<antecedenteWrapper> awList = rolAntecedenteWrapper.get(rol);
                    awList.add(wr);
                    rolAntecedenteWrapper.put(rol, awList);
                }else{
                    List<antecedenteWrapper> awList = new List<antecedenteWrapper>();
                    awList.add(wr);
                    rolAntecedenteWrapper.put(rol, awList);
                }
            }
        }
        return rolAntecedenteWrapper;
    }

    /* @description: method that gets antecedentes from reclamantes and cotitulares
    * reclamaciones históricas SAC and CBPO
    * param recId: id reclamación
    */
    @AuraEnabled
    public static Map<String, Map<String, List<antecedenteWrapper>>> getAntecedentesToShow(String recId) {
        Map<String, Map<String, List<antecedenteWrapper>>> rolAntecedenteWrapper = new Map<String, Map<String, List<antecedenteWrapper>>>();
        // Get DNIs from all reclamantes and cotitulares
        Map<String, String> rolNumDoc = getDNIsReclamantesCotitulares(recId);
        List<String> numDocumentos = new List<String>(rolNumDoc.keySet());
        for(String numDoc: numDocumentos) {
            if(rolNumDoc.containsKey(numDoc)) {
                String rol = rolNumDoc.get(numDoc);
                Map<String, List<antecedenteWrapper>> mapTypeList;
                if(rolAntecedenteWrapper.containsKey(rol)){
                    mapTypeList = rolAntecedenteWrapper.get(rol);
                }else{
                    mapTypeList = new Map<String, List<antecedenteWrapper>>();
                    mapTypeList.put(textSAC, new List<antecedenteWrapper>());
                    mapTypeList.put(textCBPO, new List<antecedenteWrapper>());
                }
				List<antecedenteWrapper> listSAC = mapTypeList.get(textSAC);
                List<antecedenteWrapper> listCBPO = mapTypeList.get(textCBPO);
                // Call API Antecedentes
                SAC_WS_Antecedentes_RQ.RequestWrapper reqWrapperAntecedentes = new SAC_WS_Antecedentes_RQ.RequestWrapper(new List<String>{numDoc});
                SAC_WS_Antecedentes.AntecedentesResponse responseAntecedentes = SAC_WS_Antecedentes.sendRequest(reqWrapperAntecedentes, profileName);
                if(responseAntecedentes != null && responseAntecedentes.antecedentes != null && !responseAntecedentes.antecedentes.isEmpty()) {
                    for(SAC_WS_Antecedentes_RP.ClaimWrapper antecedente : responseAntecedentes.antecedentes) {
                        antecedenteWrapper wr = new antecedenteWrapper();
                        wr.productoServicio = antecedente.getProductService() != null ? antecedente.getProductService().abbreviate(255) : null;
                        wr.contrato = antecedente.getExpedient() != null ? antecedente.getExpedient().abbreviate(255) : null;
                        wr.idReclamacion = antecedente.getClaimCode() != null ? antecedente.getClaimCode().abbreviate(125) : null;
                        wr.oficinaAfectada = antecedente.getAffectedOffice() != null ? antecedente.getAffectedOffice().abbreviate(25) : null;
                        wr.estado = antecedente.getClaimStatus() != null ? antecedente.getClaimStatus().abbreviate(125) : null;
                        wr.resolucion = antecedente.getResolutionType() != null ? antecedente.getResolutionType() : null;
                        wr.fechaAlta = (antecedente.getReceptionDate() != null && antecedente.getReceptionDate() != 'null') ? Date.valueOf(antecedente.getCreationDate()) : null;
                        wr.fechaCierre = (antecedente.getDueDate() != null && antecedente.getDueDate() != 'null') ? Date.valueOf(antecedente.getDueDate()) : null;
                        wr.importeRec = antecedente.getClaimAmount() != null ? antecedente.getClaimAmount() : null;
                        wr.importeResuelto = antecedente.getReturnedAmount() != null ? antecedente.getReturnedAmount() : null;
                        // Put type
                        if(antecedente.getClaimType() == textSAC) {
                            listSAC.add(wr);
                        } else {
                            listCBPO.add(wr);
                        }
                    }
                    mapTypeList.put(textSAC, listSAC);
                    mapTypeList.put(textCBPO, listCBPO);
                    // Put rol and map
                    rolAntecedenteWrapper.put(rol, mapTypeList);
                }
            }
        }
        return rolAntecedenteWrapper;
    }

   	/* @description: method that gets antecedentes from reclamantes and cotitulares
	 * demandas judiciales contra la entidad
	 * param recId: id reclamación
	 */
    @AuraEnabled
    public static Map<String, List<antecedenteWrapper>> getDemandasEntidadToShow(String recId) {
        Map<String, List<antecedenteWrapper>> rolAntecedenteWrapper = new Map<String, List<antecedenteWrapper>>();
        // Get DNIs from all reclamantes and cotitulares
        Map<String, String> rolNumDoc = getDNIsReclamantesCotitulares(recId);
        List<String> numDocumentos = new List<String>(rolNumDoc.keySet());
        for(String numDoc: numDocumentos){
            if(rolNumDoc.containsKey(numDoc)) {
                String rol = rolNumDoc.get(numDoc);
                // Call API Antecedentes
                SAC_WS_Proesp_RQ.RequestWrapper reqWrapperProesp = new SAC_WS_Proesp_RQ.RequestWrapper(new List<String>{numDoc});
                List<SAC_WS_Proesp_RP.ClaimWrapper> proespResponses = SAC_WS_Proesp.sendRequest(reqWrapperProesp, profileName);
                if(Test.isRunningTest() || (proespResponses != null && !proespResponses.isEmpty() && proespResponses[0].getProcCode() != null)){
                    for(SAC_WS_Proesp_RP.ClaimWrapper antecedente: proespResponses){
                        // Check MCCs
                        String prodServ = antecedente.getProduct() != null ? antecedente.getProduct().abbreviate(255) : null;
                        antecedenteWrapper wr = new antecedenteWrapper();
                        wr.productoServicio = antecedente.getProduct() != null ? antecedente.getProduct().abbreviate(255) : null;
                        wr.numProcedimiento = antecedente.getProcCode() != null ? antecedente.getProcCode().abbreviate(25) : null;
                        wr.estado = antecedente.getProcStatus() != null ? antecedente.getProcStatus().abbreviate(125) : null;
                        //wr.resolucion = no hay mapeo;
                        wr.fechaAlta = (antecedente.getCreationDate() != null && antecedente.getCreationDate() != 'null') ? Date.valueOf(antecedente.getCreationDate()) : null;
                        wr.fechaCierre = (antecedente.getDueDate() != null && antecedente.getDueDate() != 'null') ? Date.valueOf(antecedente.getDueDate()) : null;
                        //wr.importeRec = no hay mapeo;
                        wr.nif = antecedente.getCustomerIds() != null ? String.join(antecedente.getCustomerIds(),', ').abbreviate(255) : null;
                        wr.materia = antecedente.getsubjects() != null ? String.join(antecedente.getSubjects(),', ') : null;
                        //wr.oficinaGestora = no hay mapeo;
                        if(rolAntecedenteWrapper.containsKey(rol)){
                            List<antecedenteWrapper> awList = rolAntecedenteWrapper.get(rol);
                            awList.add(wr);
                            rolAntecedenteWrapper.put(rol, awList);
                        }else{
                            List<antecedenteWrapper> awList = new List<antecedenteWrapper>();
                            awList.add(wr);
                            rolAntecedenteWrapper.put(rol, awList);
                        }
                    }
                }
            }
        }
        return rolAntecedenteWrapper;
    }

   	/* @description: method that gets antecedentes from reclamantes and cotitulares
	 * demandas judiciales morosidad
	 * param recId: id reclamación
	 */
    @AuraEnabled
    public static Map<String, List<antecedenteWrapper>> getDemandasMorosidadToShow(String recId) {
        Map<String, List<antecedenteWrapper>> rolAntecedenteWrapper = new Map<String, List<antecedenteWrapper>>();
        // Get DNIs from all reclamantes and cotitulares
        Map<String, String> rolNumDoc = getDNIsReclamantesCotitulares(recId);
        List<String> numDocumentos = new List<String>(rolNumDoc.keySet());
        for(String numDoc: numDocumentos){
            if(rolNumDoc.containsKey(numDoc)) {
                String rol = rolNumDoc.get(numDoc);
                // Call API Antecedentes
                SAC_WS_Promor_RQ.RequestWrapper reqWrapperPromor = new SAC_WS_Promor_RQ.RequestWrapper(new List<String>{numDoc});
                List<SAC_WS_Promor_RP.ClaimWrapper> promorResponses = SAC_WS_Promor.sendRequest(reqWrapperPromor, profileName);
                if(Test.isRunningTest() || (promorResponses != null && !promorResponses.isEmpty() && promorResponses[0].getClaimCode() != null)){
                    for(SAC_WS_Promor_RP.ClaimWrapper antecedente : promorResponses){
                        // Check MCCs
                        String prodServ = antecedente.getProduct() != null ? antecedente.getProduct().abbreviate(255) : null;
                        antecedenteWrapper wr = new antecedenteWrapper();
                        wr.fechaAlta = (antecedente.getCreationDate() != null && antecedente.getCreationDate() != 'null') ? Date.valueOf(antecedente.getCreationDate()) : null;
                        wr.fechaCierre = (antecedente.getDueDate() != null && antecedente.getCreationDate() != 'null') ? Date.valueOf(antecedente.getDueDate()) : null;
                        wr.nif = antecedente.getCustomerIds() != null ? String.join(antecedente.getCustomerIds(),', ').abbreviate(255) : null;
                        //wr.resolucion = no hay mapeo;
                        //wr.oficinaGestora = no hay mapeo;
                        wr.importeRec = antecedente.getClaimAmount() != null ? antecedente.getClaimAmount() : null;
                        wr.productoServicio = antecedente.getProduct() != null ? antecedente.getProduct().abbreviate(255) : null;
                        wr.contrato = antecedente.getContracts() != null ? String.join(antecedente.getContracts(),', ').abbreviate(125) : null;
                        wr.estado = antecedente.getClaimStatus() != null ? antecedente.getClaimStatus().abbreviate(125) : null;
                        if(rolAntecedenteWrapper.containsKey(rol)){
                            List<antecedenteWrapper> awList = rolAntecedenteWrapper.get(rol);
                            awList.add(wr);
                            rolAntecedenteWrapper.put(rol, awList);
                        }else{
                            List<antecedenteWrapper> awList = new List<antecedenteWrapper>();
                            awList.add(wr);
                            rolAntecedenteWrapper.put(rol, awList);
                        }
                    }
                }
            }
        }
        return rolAntecedenteWrapper;
    }

   	/* @description: method that gets antecedentes from reclamantes and cotitulares
	 * concursos
	 * param recId: id reclamación
	 */
    @AuraEnabled
    public static Map<String, List<antecedenteWrapper>> getConcursosToShow(String recId) {
        Map<String, List<antecedenteWrapper>> rolAntecedenteWrapper = new Map<String, List<antecedenteWrapper>>();
        // Get DNIs from all reclamantes and cotitulares
        Map<String, String> rolNumDoc = getDNIsReclamantesCotitulares(recId);
        List<String> numDocumentos = new List<String>(rolNumDoc.keySet());
        for(String numDoc: numDocumentos){
            if(rolNumDoc.containsKey(numDoc)) {
                String rol = rolNumDoc.get(numDoc);
                // Call API Antecedentes
                SAC_WS_Gescon_RQ.RequestWrapper reqWrapperGescon = new SAC_WS_Gescon_RQ.RequestWrapper(new List<String>{numDoc});
                List<SAC_WS_Gescon_RP.ClaimWrapper> gesconResponses = SAC_WS_Gescon.sendRequest(reqWrapperGescon, profileName);
                if(gesconResponses != null){
                    if(Test.isRunningTest() || (gesconResponses != null && !gesconResponses.isEmpty() && gesconResponses[0].getProcCode() != null)){
                        for(SAC_WS_Gescon_RP.ClaimWrapper antecedente : gesconResponses){
                            antecedenteWrapper wr = new antecedenteWrapper();
                            //wr.productoServicio = no hay mapeo;
                            //wr.docRec = no hay mapeo;
                            //wr.docRes = no hay mapeo;
                            wr.estado = antecedente.getProcStatus() != null ? antecedente.getProcStatus().abbreviate(125) : null;
                            wr.fechaAlta = (antecedente.getCreationDate() != null && antecedente.getCreationDate() != 'null') ? Date.valueOf(antecedente.getCreationDate()) : null;
                            wr.fechaCierre = (antecedente.getDueDate() != null && antecedente.getDueDate() != 'null') ? Date.valueOf(antecedente.getDueDate()) : null;
                            //wr.importeAbonado = no hay mapeo;
                            wr.idReclamacion = antecedente.getProcCode() != null ? antecedente.getProcCode().abbreviate(125) : null;
                            //wr.tematica = no hay mapeo;
                            if(rolAntecedenteWrapper.containsKey(rol)){
                                List<antecedenteWrapper> awList = rolAntecedenteWrapper.get(rol);
                                awList.add(wr);
                                rolAntecedenteWrapper.put(rol, awList);
                            }else{
                                List<antecedenteWrapper> awList = new List<antecedenteWrapper>();
                                awList.add(wr);
                                rolAntecedenteWrapper.put(rol, awList);
                            }
                        }
                    }
                }
            }
        }
        return rolAntecedenteWrapper;
    }

    /* @description: method that checks antecedentes (if they match MCCs)
     * @param atrResponses: antecedentes cotitulares
     * @param reclamacionesAnteriores: reclamaciones (SF) anteriores
	 */
    private static Date checkAllAntecedentes(List<SAC_WS_Antecedentes_RP.ClaimWrapper> atrResponses, List<Case> reclamacionesAnteriores){
        Date fechaAntecedente;
        // Map Salesforce MCCs
        Map<String, List<SAC_MCC_Prestamos__mdt>> mccToCheckMapSF = getSFMetadataMCC();
        for(Case reclAnterior: reclamacionesAnteriores){
            // Check MCCs
            if(mccToCheckMapSF.containsKey(reclAnterior.CC_MCC_Tematica__r.Name)){
                List<SAC_MCC_Prestamos__mdt> mccsList = mccToCheckMapSF.get(reclAnterior.CC_MCC_Tematica__r.Name);
                for(SAC_MCC_Prestamos__mdt mcc: mccsList){
                    if(mcc.SAC_ProductoServicio__c == reclAnterior.CC_MCC_ProdServ__r.Name && mcc.SAC_Motivo__c == reclAnterior.CC_MCC_Motivo__r.Name
                       && mcc.SAC_Detalle__c == reclAnterior.SEG_Detalle__r.Name){
                           fechaAntecedente = Date.valueOf(reclAnterior.SAC_FechaRecepcion__c);
                           break;
                       }
                }
            }
        }
        // Map Siebel MCCs
        Map<String, List<SAC_MCC_Prestamos__mdt>> mccToCheckMapSBL = getSBLMetadataMCC();
        for(SAC_WS_Antecedentes_RP.ClaimWrapper antecedente: atrResponses){
            // Check MCCs
            String prodServ = antecedente.getProductService() != null ? antecedente.getProductService().abbreviate(255) : null;
            String detalle = antecedente.getCauseDetail() != null ? antecedente.getCauseDetail().abbreviate(225) : null;
            Date fechaAlta = (antecedente.getReceptionDate() != null && antecedente.getReceptionDate() != 'null') ? Date.valueOf(antecedente.getReceptionDate()) : null;
            if(fechaAntecedente == null || fechaAntecedente < fechaAlta){
                if(mccToCheckMapSBL.containsKey(prodServ)){
                    List<SAC_MCC_Prestamos__mdt> mccsList = mccToCheckMapSBL.get(prodServ);
                    for(SAC_MCC_Prestamos__mdt mcc: mccsList){
                        if(mcc.SAC_ProductoServicio__c == prodServ && mcc.SAC_Detalle__c == detalle){
                            fechaAntecedente = fechaAlta;
                        }
                    }
                }
            }
        }
        return fechaAntecedente;
    }

    /* @description: method that gets all antecedentes from reclamantes and cotitulares
	 * param recId: id reclamación
	 */
    private static Date getAllAntecedentes(String recId){
       	List<SAC_WS_Antecedentes_RP.ClaimWrapper> allAntecedentes = new List<SAC_WS_Antecedentes_RP.ClaimWrapper>();
		// Get DNIs from all reclamantes and cotitulares
		List<String> numDocumentos = new List<String>();
        Map<String, String> numDocumentosMap = getDNIsReclamantesCotitulares(recId);
        for(String dni: numDocumentosMap.keySet()){
            numDocumentos.add(dni);
        }
        // Get Reclamaciones Anteriores SF (Cases)
        List<Case> reclamacionesAnteriores = getReclamacionesAnteriores(numDocumentos, recId);
        // Get Antecedentes (API)
        for(String numDoc: numDocumentos){
            // Get Reclamaciones Históricas SAC and CBPO
            SAC_WS_Antecedentes_RQ.RequestWrapper reqWrapperAntecedentes = new SAC_WS_Antecedentes_RQ.RequestWrapper(new List<String>{numDoc});
            List<SAC_WS_Antecedentes_RP.ClaimWrapper> atrResponses = new List<SAC_WS_Antecedentes_RP.ClaimWrapper>();
            SAC_WS_Antecedentes.AntecedentesResponse responseAntecedentes = SAC_WS_Antecedentes.sendRequest(reqWrapperAntecedentes, profileName);
            if(responseAntecedentes != null){
                atrResponses = responseAntecedentes.antecedentes;
                if(atrResponses != null && !atrResponses.isEmpty() && atrResponses[0].getClaimCode() != null){
                    for(SAC_WS_Antecedentes_RP.ClaimWrapper atrResponse: atrResponses){
                        allAntecedentes.add(atrResponse);
                    }
                }
            }
        }
        // Get most recent date
        Date fechaReciente = checkAllAntecedentes(allAntecedentes, reclamacionesAnteriores);
        return fechaReciente;
    }

    /* @description: method that gets reclamaciones anteriores from reclamantes and cotitulares
     * @param numDocumentos: dnis reclamantes and cotitulares
	 */
    private static List<Case> getReclamacionesAnteriores(List<String> numDocumentos, String recId){
        Set<String> reclamacionId = new Set<String>();
        List<SAC_CaseReclamante__c > reclamanteList = [SELECT Id, SAC_Case__c
                                                       FROM SAC_CaseReclamante__c
                                                       WHERE SAC_Account__r.CC_Numero_Documento__c IN: numDocumentos
                                                       AND SAC_Case__r.RecordTypeId =: RECTYPERECLAMACION
                                                       AND SAC_Case__c !=: recId];
        for(SAC_CaseReclamante__c reclamante: reclamanteList){
            reclamacionId.add(reclamante.SAC_Case__c);
        }
        List<Case> reclamacionesAnteriores = [SELECT Id, RecordTypeId, SAC_FechaRecepcion__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name,
                                              CC_MCC_Motivo__r.Name, SEG_Detalle__r.Name, CaseNumber, Subject, Status, Account.CC_Numero_Documento__c,
                                              CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c, SEG_Detalle__c
                                              FROM Case
                                              WHERE Id IN: reclamacionId
                                              ORDER BY SAC_FechaRecepcion__c DESC];
        return reclamacionesAnteriores;
    }
}