public with sharing class SPV_LCMP_Notas {


    //Wrapper para las Notes
    public class NoteWrapper {
        @AuraEnabled public Id id {get; set;}
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public String body {get; set;}
        @AuraEnabled public String createdByName {get; set;}
        @AuraEnabled public String createdDate {get; set;}
        @AuraEnabled public Id createdById {get; set;}
        @AuraEnabled public String lastModifiedByName {get; set;}
        @AuraEnabled public Id lastModifiedById {get; set;}
        @AuraEnabled public String lastModifiedDate {get; set;}
        @AuraEnabled public String tituloAcortado {get; set;}

        public NoteWrapper(ContentNote note){
            id = note.Id;
            title = note.Title;
            body = note.TextPreview;
            createdByName = note.createdBy.Name;
            createdDate = note.CreatedDate.format('dd/MM/yyyy HH:mm');
            createdById = note.CreatedBy.Id;
            lastModifiedByName = note.LastModifiedBy.Name;
            lastModifiedById = note.LastModifiedBy.Id;
            lastModifiedDate = note.LastModifiedDate.format('dd/MM/yyyy HH:mm');
            tituloAcortado = note.Title.length() > 30 ? note.Title.substring(0, 30) + '...' : note.Title;
        }
    }

    //Obtener las notas asociadas al caso
    @AuraEnabled(cacheable=true)
    public static List<NoteWrapper> obtenerNotasAsociadas(Id idRegistro){

        List<NoteWrapper> notasReturn = new List<NoteWrapper>();
        Set<Id> docsIds = new Set<Id>();
        List<ContentNote> listaNotas = new List<ContentNote>();

        List<ContentDocumentLink> links = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:idRegistro];

        for(ContentDocumentLink link : links){
            docsIds.add(link.ContentDocumentId);
        }

        if(!docsIds.isEmpty()){
            //listaNotas = [SELECT Id, Title, TextPreview, CreatedDate, createdBy.Name, CreatedBy.Id, LastModifiedBy.Name, LastModifiedBy.Id, LastModifiedDate FROM ContentNote WHERE FileType = 'SNOTE' AND LatestPublishedVersionId IN (SELECT LatestPublishedVersionId FROM ContentDocument WHERE Id IN :docsIds) ORDER BY CreatedDate DESC];
            listaNotas = [SELECT Id, Title, TextPreview, CreatedDate, createdBy.Name, CreatedBy.Id, LastModifiedBy.Name, LastModifiedBy.Id, LastModifiedDate FROM ContentNote WHERE FileType = 'SNOTE' AND Id IN :docsIds ORDER BY CreatedDate DESC];
            for(ContentNote nota : listaNotas){
                NoteWrapper nuevaNota = new NoteWrapper(nota);
                notasReturn.add(nuevaNota);
            }
        }

        return notasReturn;
    }

    //Método para comprobar si el User tiene el Permission Set: 'SPV_SystemAdmin'
    @AuraEnabled(cacheable=true)
    public static Boolean comprobarUserSystemAdmin(){
        try {
            String idUser = UserInfo.getUserId();
            List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :idUser AND PermissionSet.Name = 'SPV_SystemAdmin'];
            return !psa.isEmpty();  //Devuelve true si tiene el ps de system admin, y false si no

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    //Obtener el contenido de la nota, inclutendo imagenes y todo
    @AuraEnabled
    public static String obtenerContenido(Id contentNoteId){

        Id idRetornar;
        String htmlRetorno = '';

        List<ContentNote> cn = [SELECT Id, Content FROM ContentNote WHERE Id = :contentNoteId LIMIT 1];
        if(!cn.isEmpty()){
            htmlRetorno = cn[0].Content.toString();
        }
        return htmlRetorno;

    }


    //Crear nuevas notas
    @AuraEnabled
    public static void addNuevaNota(String titulo, String contenido, Id idRegistro){
        
        try{

            //Se crea la nota con el título y contenido rellenados
            ContentNote nota = new ContentNote();
            nota.Title = titulo;
            nota.Content = Blob.valueOf(contenido);
            SPV_DatabaseDML.insertDML(nota, true);

            //Se linka al caso
            ContentDocumentLink documentLink = new ContentDocumentLink();
            documentLink.LinkedEntityId = idRegistro;
            documentLink.ContentDocumentId = nota.Id;
            documentLink.ShareType = 'V';
            //documentLink.Visibility = 'AllUsers';
            SPV_DatabaseDML.insertDML(documentLink, true);

        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

    }



    //Recuperar las notas del objeto al pulsar en actualizar
    @AuraEnabled
    public static List<NoteWrapper> recuperarNotasAsociadasRefresh(Id idRegistro){
        try {
            
            List<NoteWrapper> notasReturn = new List<NoteWrapper>();
            Set<Id> docsIds = new Set<Id>();
            List<ContentNote> listaNotas = new List<ContentNote>();

            List<ContentDocumentLink> links = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:idRegistro];
            for(ContentDocumentLink link : links){
                docsIds.add(link.ContentDocumentId);
            }

            if(!docsIds.isEmpty()){
                listaNotas = [SELECT Id, Title, TextPreview, CreatedDate, createdBy.Name, CreatedBy.Id, LastModifiedBy.Name, LastModifiedBy.Id, LastModifiedDate FROM ContentNote WHERE FileType = 'SNOTE' AND Id IN :docsIds ORDER BY CreatedDate DESC];
                for(ContentNote nota : listaNotas){
                    NoteWrapper nuevaNota = new NoteWrapper(nota);
                    notasReturn.add(nuevaNota);
                }
            }

            return notasReturn;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //Eliminar nota: Solo para los system admin
    @AuraEnabled
    public static void eliminarNota(Id idNotaBorrar){
        try {
            ContentNote nota = new ContentNote();
            nota.Id = idNotaBorrar;
            SPV_DatabaseDML.deleteDML(nota, true);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //Obtener los posibles usuarios con los que compartir
    /*@AuraEnabled(cacheable=true)
    public static List<User> getUsuariosShare(){
        try {
            List<User> listaUsuarios = new List<User>();
            listaUsuarios = [SELECT Id, Name FROM User WHERE Profile.Name = 'SPV_General'];
            return listaUsuarios;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }*/
    
}