/*****************************************************************
 * Name: SAC_GenialView_Controller
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: controller para el LWC SAC_GenialView
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            genial           David Ramos       06/11/23     Creación
 * 1.1            US866228         David Ramos       17/04/24     Añadido funcion obtenerReclamantesSecundariosIA + corregir warnings qc de las querys
 * 1.2            US869509         Borja Lavesiera   22/04/24     Campo Resumen y su Valoración  
 * 1.3            US978023         Alex Perez        29/08/24     Asignación de reclamantes sugeridos
 * 1.4            US1032147        Alex Perez        10/10/24     Configuración de la ocultación de NIF y botón de asociar cliente
*****************************************************************/
public with sharing class SAC_GenialView_Controller {
    public static final String ICONMODIFICADOIA = 'utility:magicwand';
    public static final String ICONMODIFICADOUSER = 'utility:edit_gpt';
    public static final String ICONINFORMATIVO = 'utility:info_alt';
    public static final String ICONVACIO = '';

    //hacer wrapper con id, mapa de iconos con el tipo de icono para cada campo
	public class IdResGenialConIconos {
        @AuraEnabled
        public String id {get;set;}

        @AuraEnabled
        public Map<String, String> iconosCampos {get;set;}
    }

    //funcion para obtener el id del SAC_Genial_Resultado__c asociado al caso, a partir del Id del caso
    //y los iconos que se pondran en cada campo
    @AuraEnabled(cacheable=true)
    public static IdResGenialConIconos getResultadoGenial(Case casoOriginal) {
        String idCaso = casoOriginal.Id;
        SAC_Genial_Resultado__c result;
        IdResGenialConIconos wrapperResultado = new IdResGenialConIconos();
        wrapperResultado.iconosCampos = new Map<String, String>();
        if (idCaso != null){
            List<SAC_Genial_Resultado__c> listresult = new List<SAC_Genial_Resultado__c>();
            listresult = [SELECT Id, Name, RecordTypeId, SAC_Reclamacion__c, SAC_Pretension__c, SAC_AccountId__c, SAC_SuppliedNIF__c, 
                            SAC_UsarDatos__c, SAC_TipoDeRepresentante__c, SAC_TipoDeDocumento__c, SAC_NumeroDelDocumento__c, SAC_NombreRepresentante__c, 
                            SAC_TelefonoRepresentante__c, SAC_EmailRepresentante__c, SAC_DespachoRepresentante__c, SAC_DireccionRepresentante__c, 
                            SAC_CodigoPostalRepresentante__c, SAC_PoblacionRepresentante__c, SAC_ProvinciaRepresentante__c, SAC_PaisRepresentante__c, 
                            SAC_DireccionPostal__c, SAC_PoderRepresentante__c, SAC_Importe_Tipo__c, SAC_Importe_Reclamado__c, SAC_FechaRecepcion__c, 
                            SAC_Naturaleza__c, SAC_Idioma__c, SAC_Oficina_Afectada_Lookup__c, SAC_MCC_Tematica__c, SAC_MCC_Motivo__c, SAC_MCC_ProdServ__c, 
                            SAC_Detalle__c, SAC_EsPrincipal__c, SAC_Email__c, recordType.developerName, 
                            SAC_Telefono_Contacto__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, 
                            SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreContacto__c, SAC_Resumen__c
                            FROM SAC_Genial_Resultado__c 
                            WHERE (SAC_Reclamacion__c = :idCaso OR SAC_Pretension__c = :idCaso)
                            WITH SECURITY_ENFORCED];
            if (listresult != null){
                if (listresult.size() == 1){
                    //si solo coincide uno el id es de una pretension
                    result = listresult.get(0);
                }
                else{
                    //si hay mas de un resultado el id es de una reclamacion
                    for (SAC_Genial_Resultado__c resGenial : listresult){
                        //if (resGenial.SAC_Pretension__c == null){
                        if(resGenial.recordType.developerName == 'SAC_Reclamacion_IA'){
                            //es la reclamacion
                            result = resGenial;
                            break;
                        }
                    }
                }
            }
        }
        //si se encuentra un resultado IA hacer la comparacion de cada campo
        if (result != null){
            wrapperResultado.id = result.Id;

            //hacer las comparaciones de caso original con result
            Map<String, Boolean> comparacion = SAC_GenialUtils.comparaCampos(casoOriginal,result);

            //para saber si el campo original está en blanco casteo el casoOriginal con sus valores reales
            SAC_Genial_Resultado__c casoOriginalFormatoGR = SAC_GenialUtils.casteoCaseAgenialResultado(casoOriginal);

            //para ver si hay algun campo vacio en los datos que devuelve IA
            Map<String, Object> camposResult = result.getPopulatedFieldsAsMap();
            for (String nombreCampo : comparacion.keySet()){
                //si el campo de datos IA esta vacio no pintar icono
                if (camposResult.get(nombreCampo) == null){
                    wrapperResultado.iconosCampos.put(nombreCampo,ICONVACIO);
                }
                else{
                    if(casoOriginal.SAC_GenialEstado__c == 'SAC_002' && casoOriginalFormatoGR.get(nombreCampo) == null){
                        wrapperResultado.iconosCampos.put(nombreCampo,ICONINFORMATIVO);
                    }
                    else if(comparacion.get(nombreCampo)){
                        wrapperResultado.iconosCampos.put(nombreCampo,ICONMODIFICADOIA);
                    }
                    else{
                        //comprobar campos con default values
                        if(nombreCampo == 'SAC_Idioma__c'){
                            if(casoOriginal.CC_Idioma__c != null && casoOriginal.CC_Idioma__c.equals('es')){
                                //valor por defecto
                                wrapperResultado.iconosCampos.put(nombreCampo,ICONINFORMATIVO);
                            }
                            else{
                                wrapperResultado.iconosCampos.put(nombreCampo,ICONMODIFICADOUSER);
                            }
                        }
                        else if(nombreCampo == 'SAC_Importe_Reclamado__c'){
                            if(casoOriginal.CC_Importe_Reclamado__c != null && casoOriginal.CC_Importe_Reclamado__c == 0){
                                //valor por defecto
                                wrapperResultado.iconosCampos.put(nombreCampo,ICONINFORMATIVO);
                            }
                            else{
                                wrapperResultado.iconosCampos.put(nombreCampo,ICONMODIFICADOUSER);
                            }
                        }
                        //no son iguales, el usuario ha modificado el campo
                        else {
                            wrapperResultado.iconosCampos.put(nombreCampo,ICONMODIFICADOUSER);
                        }
                    }
                }
            }
        }
        wrapperResultado.iconosCampos.put('Informativo', ICONINFORMATIVO);
        return wrapperResultado;
    }

    /*En casos enviados a la IA, obtener las pretensiones generadas por la misma*/
    @AuraEnabled(cacheable=true)
    public Static list<SAC_Genial_Resultado__c> obtenerPretensionesIA(Id reclamacionId){
        list<SAC_Genial_Resultado__c> pretensionesIA = new list<SAC_Genial_Resultado__c>();
        integer contador = 1;
        for(SAC_Genial_Resultado__c pretensionIA : [SELECT Id, SAC_MCC_Motivo__c, SAC_MCC_ProdServ__c, SAC_Detalle__c, SAC_esPrincipal__c 
                                                    FROM SAC_Genial_Resultado__c 
                                                    WHERE SAC_Reclamacion__c = : reclamacionId and recordType.developerName = 'SAC_Pretension_IA'
                                                    WITH SECURITY_ENFORCED]) {
            //nombre temporal para usarlo en el accordion
            pretensionIA.name = 'Pretensión ' + contador;
            if(pretensionIA.SAC_esPrincipal__c ){
                pretensionIA.name += ' (Principal)';
            }
            pretensionesIA.add(pretensionIA);
            contador++;
        }

        return pretensionesIA;
    }

    /*En casos enviados a la IA, obtener los reclamantes secundarios generados por la misma*/
    @AuraEnabled(cacheable=true)
    public Static list<SAC_Genial_Resultado__c> obtenerReclamantesSecundariosIA(Id reclamacionId){
        list<SAC_Genial_Resultado__c> reclamantesSecundariosIA = new list<SAC_Genial_Resultado__c>();
        integer contador = 1;
        for(SAC_Genial_Resultado__c reclamanteSecundarioIA : [SELECT Id, SAC_AccountId__c, SAC_Email__c, SAC_SuppliedNIF__c,
                                                    SAC_Telefono_Contacto__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c,
                                                    SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c,
                                                    SAC_NombreContacto__c
                                                    FROM SAC_Genial_Resultado__c 
                                                    WHERE SAC_Reclamacion__c = : reclamacionId and recordType.developerName = 'SAC_Reclamante_IA'
													WITH SECURITY_ENFORCED]) {
            //nombre temporal para usarlo en el accordion
            reclamanteSecundarioIA.name = 'Reclamante secundario ' + contador;
            reclamantesSecundariosIA.add(reclamanteSecundarioIA);
            contador++;
        }

        return reclamantesSecundariosIA;
    }  

    @AuraEnabled(cacheable=true)
    public Static Id obtenerRecordTypeReclamacion() {
        List<RecordType> rtReclamacion = [SELECT Id FROM RecordType WHERE DeveloperName = 'SAC_Reclamacion' AND SobjectType = 'Case' 
                            WITH SECURITY_ENFORCED LIMIT 1];
        //por si devuelve lista vacia por el security enforced
        return rtReclamacion.isEmpty() ? null : rtReclamacion[0].Id;
    }

    @AuraEnabled(cacheable=true)
    public static string getValorResumen(Id casoId){
        SAC_Genial_Resultado__c resultadoGenial = [SELECT SAC_ValoracionResumen__c 
                                                         FROM SAC_Genial_Resultado__c 
                                                         WHERE SAC_Pretension__c = :casoId AND recordType.developerName = 'SAC_Pretension_IA'
                                                         WITH SECURITY_ENFORCED LIMIT 1];
        //por si devuelve sobject vacio por el security enforced
        return (resultadoGenial != null && resultadoGenial.SAC_ValoracionResumen__c != null) ? resultadoGenial.SAC_ValoracionResumen__c : null;
    }
    @AuraEnabled
    public static void guardarValorResumen(Id casoId, String valoracion){
        if (!Schema.sObjectType.SAC_Genial_Resultado__c.isAccessible() ||
            !Schema.sObjectType.SAC_Genial_Resultado__c.fields.SAC_ValoracionResumen__c.isUpdateable()) {
            throw new AuraHandledException('No tiene permisos suficientes para actualizar la valoración del Resumen.');
        }
        SAC_Genial_Resultado__c resultadoGenial = [SELECT Id, SAC_ValoracionResumen__c 
                                                            FROM SAC_Genial_Resultado__c 
                                                            WHERE SAC_Pretension__c = :casoId AND recordType.developerName = 'SAC_Pretension_IA'
                                                            WITH SECURITY_ENFORCED LIMIT 1]; 
        try {
            if (resultadoGenial != null) {       
                resultadoGenial.SAC_ValoracionResumen__c = valoracion;
                Database.update(resultadoGenial, false);
            } else {
                throw new AuraHandledException('No se encontró el registro de Pretensión asociado al caso.');
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error al guardar la valoración del Resumen: ' + e.getMessage());
        }
    }

     /**
     * @description                 Asigna los reclamantes en caso que el agente le haya dado al botón después de la comprobación
     * @param reclamante            account a construir el insert
     */
    @AuraEnabled
    public static void asignarReclamantes(Id casoId){
          
        try {
            //Id accountPrincipal;
            case reclamacion = new case(Id = casoId);
            //para crear no clientes en caso de que no exista en BBDD
            Account recPrincipal;
            //list<SAC_Genial_Resultado__c> listDocuSecundario;
            //list<Account> recSecundarios = new list<Account>();
            list<sobject> recSecundariosobj = new list<Account>();
            //list<sobject> recSecundariosobj = new list<Account>();

            //list<Id> listAccSecundario;
            //list<SAC_CaseReclamante__c> listCaseReclamante = new list<SAC_CaseReclamante__c>();
            list<SObject> listCaseReclamante = new list<SObject>();
            SAC_CaseReclamante__c caseReclamante;
            // el RT reclamación contiene el Acc principal
            list<SAC_Genial_Resultado__c> resultadoGenial = [SELECT Id, SAC_accountId__c, recordType.developerName,
                                                            SAC_SuppliedNIF__c, SAC_NombreContacto__c, SAC_NumPerso__c,
                                                            SAC_Email__c, SAC_Telefono_Contacto__c, SAC_DireccionContacto__c,
                                                            SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c,
                                                            SAC_FirstName__c, SAC_LastName__c, SAC_CodigoPostalContacto__c
                                                            FROM SAC_Genial_Resultado__c 
                                                            WHERE SAC_Reclamacion__c = :casoId AND 
                                                            (recordType.developerName = 'SAC_Reclamacion_IA' OR recordType.developerName = 'SAC_Reclamante_IA')]; 
            for(SAC_Genial_Resultado__c resultado : resultadoGenial){
                if(resultado.recordType.developerName == 'SAC_Reclamacion_IA'){
                    if(resultado.SAC_accountId__c != null){
                        reclamacion.accountId = resultado.SAC_accountId__c;
                    } else {
                        //en caso de no existir, crear el account principal
                        recPrincipal = construirInsertAccount(resultado);
                    }    
                } else {
                    if(resultado.SAC_accountId__c != null){
                        caseReclamante = new SAC_CaseReclamante__c(
                            SAC_case__c = reclamacion.Id,
                            SAC_Account__c = resultado.SAC_accountId__c
                        );
                        listCaseReclamante.add((sobject)caseReclamante);
                    } else {
                        //listDocuSecundario.add(resultado);
                        //recSecundarios.add(construirInsertAccount(resultado));
                        recSecundariosobj.add((sobject)construirInsertAccount(resultado));
                        
                    }
                }
            }
            
            if(recPrincipal != null){
                //database.insert recPrincipal;
                if(SAC_GenialUtils.modificarInsertarObjetos(new list<SObject>{recPrincipal}, 'insert') == 0){
                    throw new AuraHandledException('Error al crear el registro de cliente');
                }
                
                reclamacion.accountId = recPrincipal.Id;
            }
            if(SAC_GenialUtils.modificarInsertarObjetos(new list<SObject>{reclamacion}, 'update') == 0){
                throw new AuraHandledException('Error al asociar el reclamante');
            }
            //database.update reclamacion;
            if(!recSecundariosObj.isEmpty()){
                //insert recSecundarios;
                SAC_GenialUtils.modificarInsertarObjetos(recSecundariosObj, 'insert');
                //SAC_CaseReclamante__c caseReclamante;
                //list<SAC_CaseReclamante__c> listCaseReclamante = new list<SAC_CaseReclamante__c>();
                for(sobject secundario : recSecundariosObj){
                    caseReclamante = new SAC_CaseReclamante__c(
                        SAC_case__c = reclamacion.Id,
                        SAC_Account__c = secundario.Id
                    );
                }
                listCaseReclamante.add((sobject)caseReclamante);
            }

            //insert listCaseReclamante;
            SAC_GenialUtils.modificarInsertarObjetos(listCaseReclamante, 'insert');

        } catch (Exception e) {
            CBK_Log.error(e);
            throw new AuraHandledException('Error al transladar los reclamantes sugeridos por la IA a la reclamación: ' + e.getMessage());  
        }
    }

    /**
     * @description                 construye el insert del account dependiendo si es o no confidencia
     * @param reclamante            account a construir el insert
     */
    private static account construirInsertAccount(SAC_Genial_Resultado__c reclamante){
        Account recPrin;
        String ccCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        String noclientePART = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SAC_NoCliente_PA').getRecordTypeId();
        //Si en el proceso de SAC_GenialQueueable fue construido como confidencial, se creará aquí su registro en caso de no existir
        recPrin = new Account();
        if(reclamante.SAC_NombreContacto__c == 'CONFIDENCIAL'){
            //recPrin = new Account();
            recPrin.recordTypeId = ccCliente;
            recPrin.Name = 'CONFIDENCIAL';
            recPrin.CC_NumPerso__c = reclamante.SAC_NumPerso__c;
            recPrin.CC_Confidencial__c = true;
            recPrin.CC_Numero_Documento__c = reclamante.SAC_suppliedNif__c;
            //reclamante.av_confidencial__c = true;
        } else {
            //recPrin = reclamante;
            recPrin.recordtypeId = noclientePART;
            recPrin.PersonEmail = reclamante.SAC_Email__c;
            recPrin.PersonMobilePhone = reclamante.SAC_Telefono_Contacto__c;
            recPrin.BillingStreet = reclamante.SAC_DireccionContacto__c;
            recPrin.BillingPostalCode = reclamante.SAC_CodigoPostalContacto__c;
            recPrin.BillingCity = reclamante.SAC_PoblacionContacto__c;
            recPrin.BillingState = reclamante.SAC_ProvinciaContacto__c;
            recPrin.BillingCountry = reclamante.SAC_PaisContacto__c;
            recPrin.CC_Numero_Documento__c = reclamante.SAC_SuppliedNIF__c;
            recPrin.firstName  = reclamante.SAC_FirstName__c;
            recPrin.LastName = reclamante.SAC_LastName__c;
        }
        return recPrin;
    }

    // get custom settings (in aura enabled function to pass to LWC)
    @AuraEnabled(cacheable=true) 
    public static SAC_GenialSettingsCanal__c getCustomSettings(string canal){
        return SAC_GenialSettingsCanal__c.getInstance(canal);
    }
}