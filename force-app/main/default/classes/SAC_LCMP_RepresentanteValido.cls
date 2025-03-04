/*****************************************************************
 * Name: SAC_LCMP_RepresentanteValido
 * Copyright © 2021  CaixaBank
 *
 * Proposito: Controller del componente SAC_RepresentanteValido
 *
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US277143         Carlos Solis   19/11/21      Creación
*****************************************************************/
public without sharing class SAC_LCMP_RepresentanteValido {

    private static Set<String> objetos = new Set<String>{'CC_Caracteristica__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private final static Id RTREPRESENTANTECARACTERISTICA = mapRTsObjects.get('CC_Caracteristica__c').get('SAC_CaracteristicaRepresentante').getRecordTypeId();
    
    /*****************************************************************
     * Proposito: Recuperar datos del caso
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US277143         Carlos Solis   19/11/21      Creación
    *****************************************************************/
    @AuraEnabled
    public static Case getCase(String caseId){
        try {
            Case caso = [SELECT Id, SAC_TipoDeRepresentante__c, SAC_TipoDeDocumento__c, SAC_NombreRepresentante__c, SAC_EmailRepresentante__c,
                        toLabel(SAC_DespachoRepresentante__c), SAC_NumeroDelDocumento__c, CBK_Case_Extension_Id__c, CBK_Case_Extension_Id__r.SAC_DespachoRepresentante__c, SAC_DireccionPostal__c, SAC_TelefonoRepresentante__c,
                        SAC_NombreContacto__c, SAC_UsarDatos__c, SAC_DireccionRepresentante__c, SAC_CodigoPostalRepresentante__c, SAC_PoblacionRepresentante__c,
                        SAC_ProvinciaRepresentante__c, SAC_PaisRepresentante__c, SAC_PoderRepresentante__c, RecordType.DeveloperName 
                        FROM Case
                        WHERE (RecordType.DeveloperName = :'SAC_Reclamacion' OR RecordType.DeveloperName = :'SAC_Consulta' 
                        OR RecordType.DeveloperName = :'SAC_ConsultaSAC' OR RecordType.DeveloperName = :'SPV_Reclamacion') 
                        AND Id = :caseId LIMIT 1];

            return caso;

            //En caso de querer separarlo por perfiles, descomentar lo siguiente:
            /*
                        Id idPerfil = userInfo.getProfileId();
                        Profile perfil = [SELECT Id,Name FROM Profile WHERE Id=:idPerfil];
                        String nombrePerfil = perfil.Name;
                        
                        Case caso = new Case();
                        if(nombrePerfil.equals('SPV_General')){
                            caso = [SELECT Id, SAC_TipoDeRepresentante__c, SAC_TipoDeDocumento__c, SAC_NombreRepresentante__c, SAC_EmailRepresentante__c,
                            SAC_DespachoRepresentante__c, SAC_NumeroDelDocumento__c, SAC_DireccionPostal__c, SAC_TelefonoRepresentante__c,
                            SAC_NombreContacto__c, SAC_UsarDatos__c, SAC_DireccionRepresentante__c, SAC_CodigoPostalRepresentante__c, SAC_PoblacionRepresentante__c,
                            SAC_ProvinciaRepresentante__c, SAC_PaisRepresentante__c, SAC_PoderRepresentante__c
                            FROM Case
                            WHERE (RecordType.DeveloperName = :'SPV_Reclamacion') 
                            AND Id = :caseId LIMIT 1];

                            //return caso;
                        }else{
                            if(nombrePerfil.equals('SAC_General') || nombrePerfil.equals('SAC_GeneralSinIP')){
                                caso = [SELECT Id, SAC_TipoDeRepresentante__c, SAC_TipoDeDocumento__c, SAC_NombreRepresentante__c, SAC_EmailRepresentante__c,
                            SAC_DespachoRepresentante__c, SAC_NumeroDelDocumento__c, SAC_DireccionPostal__c, SAC_TelefonoRepresentante__c,
                            SAC_NombreContacto__c, SAC_UsarDatos__c, SAC_DireccionRepresentante__c, SAC_CodigoPostalRepresentante__c, SAC_PoblacionRepresentante__c,
                            SAC_ProvinciaRepresentante__c, SAC_PaisRepresentante__c, SAC_PoderRepresentante__c
                            FROM Case
                            WHERE (RecordType.DeveloperName = :'SAC_Reclamacion' OR RecordType.DeveloperName = :'SAC_Consulta' 
                            OR RecordType.DeveloperName = :'SAC_ConsultaSAC') 
                            AND Id = :caseId LIMIT 1];
            
                            // return caso;
                        }
                        } 
            */
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*****************************************************************
     * Proposito: Cuando alguno de los campos del representante cambia, se comprueba primero si el check 'usar los datos de ALF' está activo.
     * Si es así, se traen los datos del Account de el caso. Si el email, la direccion postal o el teléfono del representante estan informados
     * con el check de usar datos de alf en false, se traen los valores a los campos de datos de contacto de la reclamación
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US277143         Carlos Solis   01/12/21      Creación
    *****************************************************************/
    public static void camposRepresentanteValido(List<Case> listNewCase, List<Case> listaCasosSelect) {
        Map<Id, Case> mapaCasosSelect = new Map<Id, Case>(listaCasosSelect);
        for (Case caso : listNewCase) {
            //Si el check de ALF está activo, traemos los datos del Account
            if (mapaCasosSelect.containsKey(caso.Id) && caso.SAC_UsarDatos__c) {
                caso.OS_Email__c = mapaCasosSelect.get(caso.Id).Account.PersonEmail;
                //Traer datos teléfono
                if (mapaCasosSelect.containsKey(caso.Id) && String.isNotBlank(mapaCasosSelect.get(caso.Id).Account.Phone)) {
                    caso.CC_Telefono_Contacto__c = mapaCasosSelect.get(caso.Id).Account.Phone;
                } else if (mapaCasosSelect.containsKey(caso.Id) && String.isNotBlank(mapaCasosSelect.get(caso.Id).Account.PersonMobilePhone)) {
                    caso.CC_Telefono_Contacto__c = mapaCasosSelect.get(caso.Id).Account.PersonMobilePhone;
                } else {
                    caso.CC_Telefono_Contacto__c = null;
                }
                //Rellenar la dirección
                String direccion;
                String d;
                String cp;
                String poblacion;
                String provincia;
                String pais;
                if (String.isNotBlank(mapaCasosSelect.get(caso.Id).Account.BillingStreet)) {
                    direccion = mapaCasosSelect.get(caso.Id).Account.BillingStreet;
                    d = mapaCasosSelect.get(caso.Id).Account.BillingStreet;
                }
                if (String.isNotBlank(mapaCasosSelect.get(caso.Id).Account.BillingPostalCode)) {
                    if (String.isNotBlank(direccion)) {
                        direccion = direccion + ', ' + mapaCasosSelect.get(caso.Id).Account.BillingPostalCode;
                    } else {
                        direccion = mapaCasosSelect.get(caso.Id).Account.BillingPostalCode;
                    }
                    cp = mapaCasosSelect.get(caso.Id).Account.BillingPostalCode;
                }
                if (String.isNotBlank(mapaCasosSelect.get(caso.Id).Account.BillingCity)) {
                    if (String.isNotBlank(direccion)) {
                        direccion = direccion + ', ' + mapaCasosSelect.get(caso.Id).Account.BillingCity;
                    } else {
                        direccion = mapaCasosSelect.get(caso.Id).Account.BillingCity;
                    }
                    poblacion = mapaCasosSelect.get(caso.Id).Account.BillingCity;
                }
                if (String.isNotBlank(mapaCasosSelect.get(caso.Id).Account.BillingState)) {
                    if (String.isNotBlank(direccion)) {
                        direccion = direccion + ', ' + mapaCasosSelect.get(caso.Id).Account.BillingState;
                    } else {
                        direccion = mapaCasosSelect.get(caso.Id).Account.BillingState;
                    }
                    provincia = mapaCasosSelect.get(caso.Id).Account.BillingState;
                }
                if (String.isNotBlank(mapaCasosSelect.get(caso.Id).Account.BillingCountry)) {
                    if (String.isNotBlank(direccion)) {
                        direccion = direccion + ', ' + mapaCasosSelect.get(caso.Id).Account.BillingCountry;
                    } else {
                        direccion = mapaCasosSelect.get(caso.Id).Account.BillingCountry;
                    }
                    pais = mapaCasosSelect.get(caso.Id).Account.BillingCountry;
                }
                caso.SAC_DireccionPostalNotificacion__c = direccion;
                
                caso.SAC_DireccionContacto__c = d;
                caso.SAC_CodigoPostalContacto__c = cp;
                caso.SAC_PoblacionContacto__c = poblacion;
                caso.SAC_ProvinciaContacto__c = provincia;
                caso.SAC_PaisContacto__c = pais;

                //Rellenar nombre del contacto
                caso.SAC_NombreContacto__c = mapaCasosSelect.get(caso.Id).Account.Name;
            } else {
                caso.OS_Email__c = null;
                caso.CC_Telefono_Contacto__c = null;
                caso.SAC_DireccionPostalNotificacion__c = null;
                caso.SAC_NombreContacto__c = null;
                caso.SAC_DireccionContacto__c = null;
                caso.SAC_CodigoPostalContacto__c = null;
                caso.SAC_PoblacionContacto__c = null;
                caso.SAC_ProvinciaContacto__c = null;
                caso.SAC_PaisContacto__c = null;
            }
            //Si alguno de los campos del representante está informado, hay que empezar con las validaciones
            if (String.isNotBlank(caso.SAC_TipoDeRepresentante__c) || String.isNotBlank(caso.SAC_TipoDeDocumento__c) || String.isNotBlank(caso.SAC_NombreRepresentante__c) ||
                String.isNotBlank(caso.SAC_EmailRepresentante__c) || String.isNotBlank(caso.SAC_DespachoRepresentante__c) || String.isNotBlank(caso.CBK_Case_Extension_Id__r.SAC_DespachoRepresentante__c) || String.isNotBlank(caso.SAC_NumeroDelDocumento__c) ||
                String.isNotBlank(caso.SAC_DireccionPostal__c) || String.isNotBlank(caso.SAC_TelefonoRepresentante__c) || String.isNotBlank(caso.SAC_DireccionRepresentante__c) || 
                String.isNotBlank(caso.SAC_CodigoPostalRepresentante__c) || String.isNotBlank(caso.SAC_PoblacionRepresentante__c) || String.isNotBlank(caso.SAC_ProvinciaRepresentante__c) || 
                String.isNotBlank(caso.SAC_PaisRepresentante__c) ) {

                    String direccionNotificacion;

                    if(String.isNotBlank(caso.SAC_DireccionRepresentante__c)){
                        direccionNotificacion = caso.SAC_DireccionRepresentante__c;
                    }

                    if(String.isNotBlank(caso.SAC_CodigoPostalRepresentante__c)){
                        if(String.isNotBlank(direccionNotificacion)){
                            direccionNotificacion = direccionNotificacion + ', ' + caso.SAC_CodigoPostalRepresentante__c;
                        }
                        else{
                            direccionNotificacion = caso.SAC_CodigoPostalRepresentante__c;
                        }
                    }

                    if(String.isNotBlank(caso.SAC_PoblacionRepresentante__c)){
                        if(String.isNotBlank(direccionNotificacion)){
                            direccionNotificacion = direccionNotificacion + ', ' + caso.SAC_PoblacionRepresentante__c;
                        }
                        else{
                            direccionNotificacion = caso.SAC_PoblacionRepresentante__c;
                        }
                    }

                    if(String.isNotBlank(caso.SAC_ProvinciaRepresentante__c)){
                        if(String.isNotBlank(direccionNotificacion)){
                            direccionNotificacion = direccionNotificacion + ', ' + caso.SAC_ProvinciaRepresentante__c;
                        }
                        else{
                            direccionNotificacion = caso.SAC_ProvinciaRepresentante__c;
                        }
                    }

                    if(String.isNotBlank(caso.SAC_PaisRepresentante__c)){
                        if(String.isNotBlank(direccionNotificacion)){
                            direccionNotificacion = direccionNotificacion + ', ' + caso.SAC_PaisRepresentante__c;
                        }
                        else{
                            direccionNotificacion = caso.SAC_PaisRepresentante__c;
                        }
                    }

                    caso.SAC_DireccionPostal__c = direccionNotificacion;

                //Si el email, la direccion postal, el teléfono o el nombre del representante estan informados con el check de usar datos de alf en false, 
                //arrastro los valores a los campos de datos de contacto de la reclamación
                if ((String.isNotBlank(caso.SAC_EmailRepresentante__c) || String.isNotBlank(caso.SAC_DireccionPostal__c) || String.isNotBlank(caso.SAC_TelefonoRepresentante__c) || 
                    String.isNotBlank(caso.SAC_NombreRepresentante__c) || String.isNotBlank(caso.SAC_DireccionRepresentante__c) || String.isNotBlank(caso.SAC_CodigoPostalRepresentante__c) || 
                    String.isNotBlank(caso.SAC_PoblacionRepresentante__c) || String.isNotBlank(caso.SAC_ProvinciaRepresentante__c) || String.isNotBlank(caso.SAC_PaisRepresentante__c)) 
                    && !caso.SAC_UsarDatos__c) {

                    caso.OS_Email__c = caso.SAC_EmailRepresentante__c;
                    caso.CC_Telefono_Contacto__c = caso.SAC_TelefonoRepresentante__c;
                    caso.SAC_NombreContacto__c = caso.SAC_NombreRepresentante__c;

                    caso.SAC_DireccionContacto__c = caso.SAC_DireccionRepresentante__c;
                    caso.SAC_CodigoPostalContacto__c = caso.SAC_CodigoPostalRepresentante__c;
                    caso.SAC_PoblacionContacto__c = caso.SAC_PoblacionRepresentante__c;
                    caso.SAC_ProvinciaContacto__c = caso.SAC_ProvinciaRepresentante__c;
                    caso.SAC_PaisContacto__c = caso.SAC_PaisRepresentante__c;

                    //String direccionNotificacion;

                    if(String.isNotBlank(caso.SAC_DireccionRepresentante__c)){
                        direccionNotificacion = caso.SAC_DireccionRepresentante__c;
                    }

                    if(String.isNotBlank(caso.SAC_CodigoPostalRepresentante__c)){
                        if(String.isNotBlank(direccionNotificacion)){
                            direccionNotificacion = direccionNotificacion + ', ' + caso.SAC_CodigoPostalRepresentante__c;
                        }
                        else{
                            direccionNotificacion = caso.SAC_CodigoPostalRepresentante__c;
                        }
                    }

                    if(String.isNotBlank(caso.SAC_PoblacionRepresentante__c)){
                        if(String.isNotBlank(direccionNotificacion)){
                            direccionNotificacion = direccionNotificacion + ', ' + caso.SAC_PoblacionRepresentante__c;
                        }
                        else{
                            direccionNotificacion = caso.SAC_PoblacionRepresentante__c;
                        }
                    }

                    if(String.isNotBlank(caso.SAC_ProvinciaRepresentante__c)){
                        if(String.isNotBlank(direccionNotificacion)){
                            direccionNotificacion = direccionNotificacion + ', ' + caso.SAC_ProvinciaRepresentante__c;
                        }
                        else{
                            direccionNotificacion = caso.SAC_ProvinciaRepresentante__c;
                        }
                    }

                    if(String.isNotBlank(caso.SAC_PaisRepresentante__c)){
                        if(String.isNotBlank(direccionNotificacion)){
                            direccionNotificacion = direccionNotificacion + ', ' + caso.SAC_PaisRepresentante__c;
                        }
                        else{
                            direccionNotificacion = caso.SAC_PaisRepresentante__c;
                        }
                    }

                    caso.SAC_DireccionPostal__c = direccionNotificacion;

                    caso.SAC_DireccionPostalNotificacion__c = caso.SAC_DireccionPostal__c;
                }
            }
        }
    }

    /*****************************************************************
     * Proposito: Si cambia el account del caso y el check 'usar los datos de ALF' está activo,
     * traer los datos de la nueva Account informada
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US277143         Carlos Solis   13/12/21      Creación
    *****************************************************************/
    public static void usarDatosDeAlf(List<Case> listNewCase) {
        List<Id> listaAccountIds = new List<Id>();
        for (Case caso : listNewCase) {
            listaAccountIds.add(caso.AccountId);
        }
        
        if (!listaAccountIds.isEmpty()) {
            Map<Id, Account> mapaAccounts = new Map<Id, Account>([SELECT Id, PersonEmail, BillingStreet, BillingPostalCode, 
                                                                BillingCity, BillingState, BillingCountry, Phone, PersonMobilePhone, Name
                                                                FROM Account 
                                                                WHERE Id IN :listaAccountIds]);

            for (Case caso : listNewCase) {
                if (mapaAccounts.isEmpty()) {
                    caso.SAC_DireccionPostalNotificacion__c = null;
                    caso.SAC_DireccionContacto__c = null;
                    caso.SAC_CodigoPostalContacto__c = null;
                    caso.SAC_PoblacionContacto__c = null;
                    caso.SAC_ProvinciaContacto__c = null;
                    caso.SAC_PaisContacto__c = null;
                    caso.SAC_NombreContacto__c = null;
                } else {
                    if (mapaAccounts.containsKey(caso.AccountId)) {
                        caso.OS_Email__c = mapaAccounts.get(caso.AccountId).PersonEmail;
                        //Traer datos teléfono
                        if (mapaAccounts.containsKey(caso.AccountId) && String.isNotBlank(mapaAccounts.get(caso.AccountId).Phone)) {
                            caso.CC_Telefono_Contacto__c = mapaAccounts.get(caso.AccountId).Phone;
                        } else if (mapaAccounts.containsKey(caso.AccountId) && String.isNotBlank(mapaAccounts.get(caso.AccountId).PersonMobilePhone)) {
                            caso.CC_Telefono_Contacto__c = mapaAccounts.get(caso.AccountId).PersonMobilePhone;
                        } else {
                            caso.CC_Telefono_Contacto__c = null;
                        }
                        //Rellenar la dirección
                        String direccion;
                        String d;
                        String cp;
                        String poblacion;
                        String provincia;
                        String pais;
    
                        if (String.isNotBlank(mapaAccounts.get(caso.AccountId).BillingStreet)) {
                            direccion = mapaAccounts.get(caso.AccountId).BillingStreet;
                            d = mapaAccounts.get(caso.AccountId).BillingStreet;
                        }
                        if (String.isNotBlank(mapaAccounts.get(caso.AccountId).BillingPostalCode)) {
                            if (String.isNotBlank(direccion)) {
                                direccion = direccion + ', ' + mapaAccounts.get(caso.AccountId).BillingPostalCode;
                            } else {
                                direccion = mapaAccounts.get(caso.AccountId).BillingPostalCode;
                            }
                            cp = mapaAccounts.get(caso.AccountId).BillingPostalCode;
                        }
                        if (String.isNotBlank(mapaAccounts.get(caso.AccountId).BillingCity)) {
                            if (String.isNotBlank(direccion)) {
                                direccion = direccion + ', ' + mapaAccounts.get(caso.AccountId).BillingCity;
                            } else {
                                direccion = mapaAccounts.get(caso.AccountId).BillingCity;
                            }
                            poblacion = mapaAccounts.get(caso.AccountId).BillingCity;
                        }
                        if (String.isNotBlank(mapaAccounts.get(caso.AccountId).BillingState)) {
                            if (String.isNotBlank(direccion)) {
                                direccion = direccion + ', ' + mapaAccounts.get(caso.AccountId).BillingState;
                            } else {
                                direccion = mapaAccounts.get(caso.AccountId).BillingState;
                            }
                            provincia = mapaAccounts.get(caso.AccountId).BillingState;
                        }
                        if (String.isNotBlank(mapaAccounts.get(caso.AccountId).BillingCountry)) {
                            if (String.isNotBlank(direccion)) {
                                direccion = direccion + ', ' + mapaAccounts.get(caso.AccountId).BillingCountry;
                            } else {
                                direccion = mapaAccounts.get(caso.AccountId).BillingCountry;
                            }
                            pais = mapaAccounts.get(caso.AccountId).BillingCountry;
                        }
                        caso.SAC_DireccionPostalNotificacion__c = direccion;
                        caso.SAC_DireccionContacto__c = d;
                        caso.SAC_CodigoPostalContacto__c = cp;
                        caso.SAC_PoblacionContacto__c = poblacion;
                        caso.SAC_ProvinciaContacto__c = provincia;
                        caso.SAC_PaisContacto__c = pais;
                        //Rellenar nombre del contacto
                        caso.SAC_NombreContacto__c = mapaAccounts.get(caso.AccountId).Name;
                    }
                }
            }
        }
    }

    @AuraEnabled
    public static List<CC_Caracteristica_Detalle__c> comprobarCaractRepresentante(String documento, String despacho){

        List<CC_Caracteristica_Detalle__c> caracteristicasRepresentante = [SELECT Id, SAC_Identificador__c, CC_Caracteristica__r.Name, CC_Caracteristica__r.CC_Descripcion__c FROM CC_Caracteristica_Detalle__c WHERE CC_Caracteristica__r.RecordTypeId = :RTREPRESENTANTECARACTERISTICA AND (SAC_Identificador__c = :documento OR SAC_Identificador__c = :despacho) ORDER BY SAC_Identificador__c DESC];

        if(!caracteristicasRepresentante.isEmpty()){
            
            Set<String> caracteristicaIds = new Set<String>();
            List<CC_Caracteristica_Detalle__c> asignacionesUnicas = new List<CC_Caracteristica_Detalle__c>();

            for (CC_Caracteristica_Detalle__c asignacion : caracteristicasRepresentante) {
                if (!caracteristicaIds.contains(asignacion.CC_Caracteristica__c)) {
                    caracteristicaIds.add(asignacion.CC_Caracteristica__c);
                    asignacionesUnicas.add(asignacion);
                }
            }

            return asignacionesUnicas;
        }else{
            return null;
        }
        
    }
}