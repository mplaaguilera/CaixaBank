public with sharing class CSBD_GenerarDocumento_Controller {

    public String origin {get{return getOrigin('vf');} set;}

    @AuraEnabled
    public static String getOrigin(String tipo) {
        if (tipo == 'vf') {
            return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0] + '.lightning.force.com';
        } else { //tipo == 'lwc'
            return 'https://' + DomainCreator.getVisualforceHostname(null);
        }
    }

    @AuraEnabled
    public static ContentVersion generarDocumento(Id recordId) {
        try {
            //Obtener cuerpo del nuevo documento
            //(el callout a la página VF debe hacerse antes que cualquier operación DML para evitar la
            // excepción "You have uncommitted work pending. Please commit or rollback before calling out")
            Blob versionData;
            if (Test.isRunningTest()) {
                versionData = Blob.valueOf('Unit.Test');
            } else {
                String urlVisualforce = 'https://' + DomainCreator.getVisualforceHostname(null) + '/apex/CSBD_DocumentoRedaccionPDF?id=' + recordId;
                versionData = new PageReference(urlVisualforce).getContentAsPDF();
            }

            //Borrado de documentos anteriores
            Database.delete([SELECT Id FROM ContentDocument WHERE Id IN
                            (SELECT ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId = :recordId
                                AND SAC_StringRedaccion_fileupload__c = 'CSBD_Documento')], false);

            //Generación de nuevo documento
            ContentVersion nuevoDocumento = new ContentVersion();
            nuevoDocumento.FirstPublishLocationId = recordId;
            nuevoDocumento.SAC_StringRedaccion_fileupload__c = 'CSBD_Documento';
            nuevoDocumento.PathOnClient = nuevoDocumento.Title + '.pdf';
            nuevoDocumento.Title = [SELECT Name FROM Opportunity WHERE Id = :recordId].Name + ' Documento generado';
            nuevoDocumento.VersionData = versionData;
            insert nuevoDocumento;

            CSBD_Activity.crearActividad(recordId, 'Generación de documento', 'Completed', 'Generación de documento', null);

            return [SELECT ContentDocumentId, Title FROM ContentVersion WHERE Id = :nuevoDocumento.Id];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}