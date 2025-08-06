public with sharing class CC_GenerarDocumento_Controller {

    @AuraEnabled
    public static ContentVersion generarDocumento(Id recordId, Id plantillaId) {
        try {
            //Obtener cuerpo del nuevo documento
            //(el callout a la página VF debe hacerse antes que cualquier operación DML para evitar la
            // excepción "You have uncommitted work pending. Please commit or rollback before calling out")
            Blob versionData;
            if (Test.isRunningTest()) {
                versionData = Blob.valueOf('Unit.Test');
            } else {
                String urlVisualforce = 'https://' + getVisualforceHostname() + '/apex/CC_DocumentoRedaccionPDF?id=' + recordId;
                versionData = new PageReference(urlVisualforce).getContentAsPDF();
            }

            //Borrado de documentos anteriores
           // Database.delete([SELECT Id FROM ContentDocument WHERE Id IN
             //               (SELECT ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId = :recordId
                              //  AND SAC_StringRedaccion_fileupload__c = 'CC_Documento')], false);

            //Generación de nuevo documento
            ContentVersion nuevoDocumento = new ContentVersion();
            nuevoDocumento.FirstPublishLocationId = recordId;
            nuevoDocumento.SAC_StringRedaccion_fileupload__c = 'CC_Documento';
            nuevoDocumento.PathOnClient = nuevoDocumento.Title + '.pdf';
            nuevoDocumento.Title = [SELECT CaseNumber FROM Case WHERE Id = :recordId].CaseNumber + ' Documento generado';
            nuevoDocumento.VersionData = versionData;
            insert nuevoDocumento;

            String nombrePlantilla;
            if(plantillaId !=null ){
                nombrePlantilla = [SELECT Name FROM EmailTemplate WHERE Id = :plantillaId LIMIT 1].Name;
                
            }           
            
            Task actividad = new Task();
			actividad.WhatId = recordId;
			actividad.Type = 'Generación Documento';
			actividad.Subject = 'Plantilla: '+ nombrePlantilla;
			actividad.Status = 'Completed';
			//insert actividad;
			CC_Activity.crearActividad(actividad);

            //CC_Activity.crearActividad(recordId, 'Generación de documento', 'Completed', 'Generación de documento', null);

            return [SELECT ContentDocumentId, Title FROM ContentVersion WHERE Id = :nuevoDocumento.Id];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } 

    @AuraEnabled(cacheable=true)
    public static string getVisualforceHostname() {
        try {
            String vfHostname = DomainCreator.getVisualforceHostname(null);
            return vfHostname;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        //return DomainCreator.getVisualforceHostname(null);
    }
}