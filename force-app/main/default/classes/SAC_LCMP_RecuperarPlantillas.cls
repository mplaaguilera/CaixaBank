public with sharing class SAC_LCMP_RecuperarPlantillas {

    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();

    /**
    Wrapper para retornar datos de la email template
    */
    public class WrapperTemplate{
        @AuraEnabled public String cuerpo{get;set;}
        @AuraEnabled public String header{get;set;}
        @AuraEnabled public String footer{get;set;}
        
        public WrapperTemplate(String miCuerpo, String miHeader, String miFooter){
            this.cuerpo = miCuerpo;
            this.header = miHeader;
            this.footer = miFooter;
        }  
    }

    /**
    Wrapper para retornar datos del directorio raiz
    */
    public class WrapperDirectorioRaiz{
        @AuraEnabled public Folder carpetaRaiz{get;set;}
        @AuraEnabled public String elementosDirectorio{get;set;}
        
        public WrapperDirectorioRaiz(Folder miCarpetaRaiz, String miElementosDirectorio){
            this.carpetaRaiz = miCarpetaRaiz;
            this.elementosDirectorio = miElementosDirectorio;
        }  
    }


    @AuraEnabled
    public static String recuperarPlantillas(){
        //Carpeta origen
        List<Folder> sac = [SELECT Id FROM Folder WHERE DeveloperName = 'PlantillasSAC'];
        if(!sac.isEmpty()){
            List<Items> subcarpetasYplantillas = new List<Items>();
            Items carpetaGlobal = new Items('Carpeta SAC', sac[0].Id, false, true, '', '', subcarpetasYplantillas);    
            
            String res = JSON.serializePretty(carpetaGlobal);
            List<String> aDevolver = new List<String>();
            aDevolver.add(res);
            return res;
        }
        else{
            return '';
        }        
    }

    @AuraEnabled
    public static string getRaiz(){
        return [SELECT Id FROM Folder WHERE DeveloperName = 'PlantillasSAC' LIMIT 1].Id;
    }

   
    /*********************************************************************************************
     * Proposito: Obtener los datos del directorio raiz                                     
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US783324           Sergio Martín         02/02/24       Creación
     * *******************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static WrapperDirectorioRaiz recuperarDirectorioRaiz(String carpetaRaiz){
        Folder padre = new Folder();
        List<Folder> carpetas = new List<Folder>();
        List<EmailTemplate> plantillas = new List<EmailTemplate>();
        if (Schema.sObjectType.Folder.isAccessible()){
            padre = [SELECT id, Name FROM Folder WHERE DeveloperName =: carpetaRaiz LIMIT 1];
            carpetas = [SELECT Id, Name, ParentId FROM Folder WHERE ParentId =: padre.id ORDER BY Name ASC];
        }
        if (Schema.sObjectType.EmailTemplate.isAccessible()){
            plantillas = [SELECT Id, Name, FolderId FROM EmailTemplate WHERE FolderId =: padre.id ORDER BY Name ASC];
        }
        List<Items> nuevoNivel = new List<Items>();
        for(Folder carpeta : carpetas){
            List<Items> subniveles = new List<Items>();
            Items carpetaActual = new Items(carpeta.Name, carpeta.Id, false, true, carpeta.ParentId, padre.Name, subniveles);
            nuevoNivel.add(carpetaActual);
        }
        for(EmailTemplate et : plantillas){
            List<Items> subniveles = new List<Items>();
            Items carpetaActual = new Items(et.Name, et.Id, false, false, et.FolderId, padre.Name, subniveles);
            nuevoNivel.add(carpetaActual);
        }
        if(nuevoNivel.isEmpty()){
            List<Items> subniveles = new List<Items>();
            Items carpetaActual = new Items('', '', false, false, padre.id, padre.Name, subniveles);
            nuevoNivel.add(carpetaActual);
        }
        String res = JSON.serializePretty(nuevoNivel);
        WrapperDirectorioRaiz datosDirectorioRaiz = new WrapperDirectorioRaiz(padre, res);
        return datosDirectorioRaiz;    
    }

 
    /*********************************************************************************************
     * Proposito: Obtener los datos del email template introducido, además del header y el footer                                       
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US783324           Sergio Martín         02/02/24       Creación
     * 1.1             US1005847            Álex Polo           31/10/24       Añadidos Footers de distitnos idiomas
     * *******************************************************************************************/
    @AuraEnabled
    public static WrapperTemplate obtenerDatosTemplate(String idTemplate, String idObject, String idioma){
        System.debug('El idioma ' + idioma);
        EmailTemplate plantillaSeleccionada = new EmailTemplate();
        EmailTemplate plantillaHeader = new EmailTemplate();
        EmailTemplate plantillaFooter = new EmailTemplate();
        List<EmailTemplate> lstPlantillas = new List<EmailTemplate>();

        if (Schema.sObjectType.EmailTemplate.isAccessible()){
            lstPlantillas = [SELECT Id, Name, HtmlValue, DeveloperName, Folder.DeveloperName FROM EmailTemplate WHERE Id =: idTemplate OR Developername IN ('SAC_Header','SAC_Footer', 'SAC_Footer_ENG', 'SAC_FOOTER_CAT', 'SAC_FOOTER_Valenciano', 'SAC_FOOTER_Gallego', 'SAC_FOOTER_Euskera')];
        }   
       


        if(lstPlantillas != null && !lstPlantillas.isEmpty()) {
            for(EmailTemplate em : lstPlantillas) {
                if(em.id == idTemplate) {
                    plantillaSeleccionada = em;
                } else if(em.DeveloperName == 'SAC_Header' && idioma == 'es') {
                    plantillaHeader = em;
                } else if(em.DeveloperName == 'SAC_Footer' && idioma == 'es') {
                    plantillaFooter = em;
                } else if(em.DeveloperName == 'SAC_Footer_ENG' && idioma == 'en'){
                    plantillaFooter = em;
                } else if(em.DeveloperName == 'SAC_Footer_CAT' && idioma == 'ca'){
                    plantillaFooter = em;
                } else if(em.DeveloperName == 'SAC_FOOTER_Valenciano' && idioma == 'va'){
                    plantillaFooter = em;
                } else if(em.DeveloperName == 'SAC_FOOTER_Gallego' && idioma == 'ga'){
                    plantillaFooter = em;
                } else if(em.DeveloperName == 'SAC_FOOTER_Euskera' && idioma == 'eu'){
                    plantillaFooter = em;
                }
            }
        }
       
        List<String> body = new List<String>();
        body.add(plantillaSeleccionada.HtmlValue);
        String whoId = UserInfo.getUserId();
        String whatId = idObject;

        try{
            Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(idTemplate, whoId, whatId); 
            String cuerpoEmail = renderStored.getHtmlBody();
            WrapperTemplate datosTemplate;
            if(!Test.isRunningTest()) {
                if(plantillaHeader != null && plantillaFooter != null) {
                    datosTemplate = new WrapperTemplate(cuerpoEmail, plantillaHeader.HtmlValue, plantillaFooter.HtmlValue);
                } else if(plantillaHeader == null && plantillaFooter == null) {
                    datosTemplate = new WrapperTemplate(cuerpoEmail, '', '');
                } else if(plantillaHeader == null && plantillaFooter != null) {
                    datosTemplate = new WrapperTemplate(cuerpoEmail, '', plantillaFooter.HtmlValue);
                } else if(plantillaHeader != null && plantillaFooter == null) {
                    datosTemplate = new WrapperTemplate(cuerpoEmail, plantillaHeader.HtmlValue, '');
                }
            } else {
                datosTemplate = new WrapperTemplate(cuerpoEmail, 'Header', 'Footer');
            }
            return datosTemplate;
        } catch (Exception e) {
            throw new AuraHandledException('La plantilla seleccionada no puede aplicarse debido a que no tiene relación con el objeto actual.');
        }
    }


    /*********************************************************************************************
     * Proposito: Buscar los email templates que coinciden con el valor de búsqueda introducido                                       
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US783324           Sergio Martín         09/02/24       Creación
     * *******************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static String buscarPlantillas(String valorBusqueda, String idCarpeta, String nombreCarpeta) {
        List<EmailTemplate> lstEmailTemplate = new List<sObject>();
        List<Id> lstIdBusquedaRaiz = new List<Id>();
        String cadenaBusqueda= '%'+valorBusqueda+'%';
        
        List<Items> nuevoNivel = new List<Items>();
        List<Items> resultadosNivel = new List<Items>();

        // Mapa que almacena la id de la Folder que contiene a la template
        Map<Id, EmailTemplate> mapIdForderEmailTemplate = new Map<Id, EmailTemplate>();
        // Mapa que almacena la id de email template y su ruta hasta la carpeta raiz
        Map<Id, String> mapIdTemplateRuta = new Map<Id, String>();

        String res;

        if (Schema.sObjectType.EmailTemplate.isAccessible()) {
            lstEmailTemplate = [SELECT Id, Name, FolderId, Folder.parentId, Folder.name FROM EmailTemplate WHERE Name LIKE :cadenaBusqueda ORDER BY Name ASC];

            for(EmailTemplate et : lstEmailTemplate) {
                // Si el directorio "padre" o directorio "abuelo" es el directorio raiz se almacena la email template
                if(et.FolderId == idCarpeta || et.Folder.parentId == idCarpeta) {
                    // Se construye la ruta de carpetas de la plantilla
                    String rutaCarpeta;
                    if(et.Folder.parentId == idCarpeta) {
                        rutaCarpeta = et.Folder.name + '\\' + nombreCarpeta;
                    } else {
                        rutaCarpeta = nombreCarpeta;
                    }

                    List<Items> subniveles = new List<Items>();
                    Items carpetaActual = new Items(et.Name, et.Id, false, false, et.FolderId, rutaCarpeta, subniveles);
                    nuevoNivel.add(carpetaActual);
                // Si el directorio "padre" y directorio "abuelo" NO es directorio raiz y no es nulo se almacena para la búsqueda del directorio raiz
                } else if(et.FolderId != null && et.Folder.parentId != null) {
                    lstIdBusquedaRaiz.add(et.Folder.parentId);
                    mapIdForderEmailTemplate.put(et.Folder.parentId, et);
                    mapIdTemplateRuta.put(et.Id, et.Folder.name);
                }
            }
            if(!lstIdBusquedaRaiz.isEmpty()) {
                resultadosNivel = buscarCarpetaRaiz(lstIdBusquedaRaiz, idCarpeta, nombreCarpeta, mapIdForderEmailTemplate, mapIdTemplateRuta);
                nuevoNivel.addAll(resultadosNivel);
            }
            res = JSON.serializePretty(nuevoNivel);
        }
        return res;
    }


    /*********************************************************************************************
     * Proposito: Buscar la carpeta raiz de un email template para verificar si está 
     *              en el directorio deseado                                      
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US783324           Sergio Martín         09/02/24       Creación
     * *******************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Items> buscarCarpetaRaiz(List<Id> listaBusqueda, String idCarpeta, String nombreCarpeta, Map<Id, EmailTemplate> mapIdForderEmailTemplate, Map<Id, String> mapIdTemplateRuta) {

        List<Id> lstIdBusquedaRaiz = new List<Id>();
        List<Folder> lstFolder = new List<sObject>();
        List<Items> nuevoNivel = new List<Items>();
        List<Items> resultadosNivel = new List<Items>();

        if (Schema.sObjectType.EmailTemplate.isAccessible()) {
            lstFolder = [SELECT Id, Name, ParentId FROM Folder WHERE ID IN :listaBusqueda ORDER BY Name ASC];
            for(Folder folder : lstFolder){
                // Si el directorio "padre" es el directorio raiz se almacena la email template
                if(folder.Id == idCarpeta || folder.ParentId == idCarpeta) {
                    // Se obtiene la email template relacionada con la Folder
                    EmailTemplate etEncontrado = mapIdForderEmailTemplate.get(folder.id);
                    
                    // Se construye la ruta de carpetas de la plantilla
                    String rutaCarpeta = mapIdTemplateRuta.get(etEncontrado.id);
                    rutaCarpeta = rutaCarpeta + '\\' + folder.name +'\\' + nombreCarpeta;

                    List<Items> subniveles = new List<Items>();
                    Items carpetaActual = new Items(etEncontrado.Name, etEncontrado.Id, false, false, etEncontrado.FolderId, rutaCarpeta, subniveles);
                    nuevoNivel.add(carpetaActual);
                // Si el directorio "padre" NO es directorio raiz y no es nulo se almacena para la búsqueda del directorio raiz
                } else if(folder.ParentId != null) {
                    // Se elimina el registro del mapa que contiene la id de la carpeta hija sustituyendo por un registro con la carpeta padre
                    EmailTemplate etEncontrado = mapIdForderEmailTemplate.get(folder.id);
                    mapIdForderEmailTemplate.remove(folder.id);
                    mapIdForderEmailTemplate.put(folder.ParentId, etEncontrado);
                    lstIdBusquedaRaiz.add(folder.ParentId);

                    // Se concatena la ruta de la email template con el nombre de la carpeta hija
                    String rutaCarpeta = mapIdTemplateRuta.get(etEncontrado.id);
                    mapIdTemplateRuta.clear();
                    rutaCarpeta = rutaCarpeta + '\\' + folder.name;
                    mapIdTemplateRuta.put(etEncontrado.id, rutaCarpeta);
                }
            }

            if(!lstIdBusquedaRaiz.isEmpty()) {
                resultadosNivel = buscarCarpetaRaiz(lstIdBusquedaRaiz, idCarpeta, nombreCarpeta, mapIdForderEmailTemplate, mapIdTemplateRuta);
                nuevoNivel.addAll(resultadosNivel);
            }
        }
        return nuevoNivel;
    }

    /*********************************************************************************************
     * Proposito: Validar si todas las pretensiones están listas para la redacción final                                    
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US783324           Sergio Martín         15/02/24       Creación
     * *******************************************************************************************/
    @AuraEnabled
    public static Boolean validarPretensiones(String idCaso){
        if(!Schema.sObjectType.Case.isAccessible()){
            throw new AuraHandledException( 'Fallo al recuperar el caso.');
        }

        List<Case> pretensiones = [SELECT Id, SuppliedCompany, SAC_Reclamacion__c, SAC_RedaccionFinal__c FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c =: idCaso AND Status != 'SAC_009'];
        Boolean valPretension = true;
        if(!pretensiones.isEmpty()){
            for(Case pretension : pretensiones){
                if(!pretension.SAC_RedaccionFinal__c){
                    valPretension = false;
                }
            }
        }
        return valPretension;
    }


    @AuraEnabled
    public static string cambioCarpeta(Id idPadre){
        Folder padre = [SELECT Name FROM Folder WHERE Id =: idPadre LIMIT 1];
        List<Folder> carpetas = [SELECT Id, Name, ParentId FROM Folder WHERE ParentId =: idPadre ORDER BY Name ASC];
        List<EmailTemplate> plantillas = [SELECT Id, Name, FolderId FROM EmailTemplate WHERE FolderId =: idPadre ORDER BY Name ASC];
        List<Items> nuevoNivel = new List<Items>();
        for(Folder carpeta : carpetas){
            List<Items> subniveles = new List<Items>();
            Items carpetaActual = new Items(carpeta.Name, carpeta.Id, false, true, carpeta.ParentId, padre.Name, subniveles);
            nuevoNivel.add(carpetaActual);
        }
        for(EmailTemplate et : plantillas){
            List<Items> subniveles = new List<Items>();
            Items carpetaActual = new Items(et.Name, et.Id, false, false, et.FolderId, padre.Name, subniveles);
            nuevoNivel.add(carpetaActual);
        }
        if(nuevoNivel.isEmpty()){
            List<Items> subniveles = new List<Items>();
            Items carpetaActual = new Items('', '', false, false, idPadre, padre.Name, subniveles);
            nuevoNivel.add(carpetaActual);
        }
        
        String res = JSON.serializePretty(nuevoNivel);
        return res;
    }

    @AuraEnabled
    public static string volverHaciaArriba(Id idPadre){
        Folder carpetaDeArriba = [SELECT Id, Name, ParentId FROM Folder WHERE Id =: idPadre LIMIT 1];

        List<Folder> carpetasLvlSuperior = [SELECT Id, Name, ParentId FROM Folder WHERE ParentId =: carpetaDeArriba.ParentId ORDER BY Name ASC];
        List<EmailTemplate> plantillas = [SELECT Id, Name, FolderId FROM EmailTemplate WHERE FolderId =: carpetaDeArriba.ParentId ORDER BY Name ASC];
        List<Items> nuevoNivel = new List<Items>();
        for(Folder carpeta : carpetasLvlSuperior){
            List<Items> subniveles = new List<Items>();
            Items carpetaActual = new Items(carpeta.Name, carpeta.Id, false, true, carpeta.ParentId, carpetaDeArriba.Name, subniveles);
            nuevoNivel.add(carpetaActual);
        }
        for(EmailTemplate et : plantillas){
            List<Items> subniveles = new List<Items>();
            Items carpetaActual = new Items(et.Name, et.Id, false, false, et.FolderId, carpetaDeArriba.Name, subniveles);
            nuevoNivel.add(carpetaActual);
        }
        
        String res = JSON.serializePretty(nuevoNivel);
        return res;
    }

    public class Items{
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String name{get;set;}
        @AuraEnabled public Boolean expanded{get;set;}
        @AuraEnabled public Boolean esCarpeta{get;set;}
        @AuraEnabled public String idParent{get;set;}
        @AuraEnabled public String labelParent{get;set;}
        @AuraEnabled public List<Items> items{get;set;}

        public Items(String nombre, String api, Boolean expandido, Boolean esCarpeta, String idParentM, String labelParentM, List<Items> subcarpetas){
            this.label = nombre;
            this.name = api;
            this.expanded = expandido;
            this.esCarpeta = esCarpeta;
            this.idParent = idParentM;
            this.labelParent = labelParentM;
            this.items = subcarpetas; 
        }

    }

    @AuraEnabled
    public static String obtenerTemplateBody(String idTemplate, String idObject, String  idObjectAux){
        EmailTemplate plantilla = [SELECT Id, Name, HtmlValue, Folder.DeveloperName FROM EmailTemplate WHERE Id =: idTemplate];

        List<String> body = new List<String>();
        body.add(plantilla.HtmlValue);
        String whoId = UserInfo.getUserId();
        String whatId = idObject;
        String cuerpo = '';

        String sRespuesta;

        try{
            Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(idTemplate, whoId, idObject);              
            String cuerpoEmail = renderStored.getHtmlBody();

            // Modificacion US567144 - Crear fecha para posteriormente recoger el valor fecha actual de la plantilla (FECHAACTUAL) y sustituirlo por el System.Today
            // De esta manera sacamos la fecha ya que no es posible obtenerla en el Email Template con el mergeo de datos
            Datetime d = System.today();
            String formattedDate = d.day() + '-' + d.month()  + '-' + d.year();
            
            if(plantilla.Folder.DeveloperName == 'SAC_Prorroga' && cuerpoEmail.contains('(FECHAACTUAL)')){
                cuerpoEmail = renderStored.getHtmlBody().replace('(FECHAACTUAL)', formattedDate);
            }

            return cuerpoEmail;
        }
        
        catch (Exception e) {
            try{
                Messaging.SingleEmailMessage renderStoredAux = Messaging.renderStoredEmailTemplate(idTemplate, whoId, idObjectAux);              
                return renderStoredAux.getHtmlBody();
            }
            
            catch (Exception se) {
                throw new AuraHandledException('La plantilla seleccionada no puede aplicarse debido a que no tiene relación con el objeto actual.');
            }
        }
        
    }

    @AuraEnabled
    public static String obtenerTemplateSubject(String idTemplate, String idObject, String idObjectAux){
        EmailTemplate plantilla = [SELECT Id, Name, HtmlValue FROM EmailTemplate WHERE Id =: idTemplate];

        List<String> body = new List<String>();
        body.add(plantilla.HtmlValue);
        String whoId = UserInfo.getUserId();
        String whatId = idObject;

        try{
            Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(idTemplate, whoId, idObject);              
            return renderStored.getSubject();
        }
        
        catch (Exception e) {
            try{
                
                Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(idTemplate, whoId, idObjectAux);              
                return renderStored.getSubject();
            }
            
            catch (Exception se) {
                    throw new AuraHandledException('La plantilla seleccionada no puede aplicarse debido a que no tiene relación con el objeto actual.');
            }
        }
        
    }
}