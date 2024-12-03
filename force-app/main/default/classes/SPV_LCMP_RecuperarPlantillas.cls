public with sharing class SPV_LCMP_RecuperarPlantillas {

    @AuraEnabled
    public static String recuperarPlantillas(){
        //Carpeta origen
        List<Folder> spv = [SELECT Id FROM Folder WHERE DeveloperName = 'PlantillasSPV'];
        if(!spv.isEmpty()){
            List<Items> subcarpetasYplantillas = new List<Items>();
            Items carpetaGlobal = new Items('Carpeta SPV', spv[0].Id, false, true, '', '', subcarpetasYplantillas);    
            
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
        return [SELECT Id FROM Folder WHERE DeveloperName = 'PlantillasSPV' LIMIT 1].Id;
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
        // String whatId = idObject;
        // String cuerpo = '';

        // String sRespuesta;

        try{
            Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(idTemplate, whoId, idObject);              
            String cuerpoEmail = renderStored.getHtmlBody();

            // Modificacion US567144 - Crear fecha para posteriormente recoger el valor fecha actual de la plantilla (FECHAACTUAL) y sustituirlo por el System.Today
            // De esta manera sacamos la fecha ya que no es posible obtenerla en el Email Template con el mergeo de datos
            // Datetime d = System.today();
            // String formattedDate = d.day() + '-' + d.month()  + '-' + d.year();
            
            // if(plantilla.Folder.DeveloperName == 'SAC_Prorroga' && cuerpoEmail.contains('(FECHAACTUAL)')){
            //     cuerpoEmail = renderStored.getHtmlBody().replace('(FECHAACTUAL)', formattedDate);
            // }

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
        // String whatId = idObject;

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