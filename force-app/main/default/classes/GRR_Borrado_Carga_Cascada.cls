public with sharing class GRR_Borrado_Carga_Cascada {

   @AuraEnabled
   public static void eliminarCarga(Id idCarga){
      GRR_Carga__c carga = [SELECT GRR_TipoDeFichero__c FROM GRR_Carga__c WHERE Id = :idCarga WITH SECURITY_ENFORCED LIMIT 1];

      String rtMotivoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
      List<CC_MCC__c> lstMotivos = [SELECT Id, CC_Producto_Servicio__c, CC_Producto_Servicio__r.CC_Tematica__c 
                                    FROM CC_MCC__c 
                                    WHERE RecordTypeId = :rtMotivoId AND Name = 'Pendiente de clasificar' AND CC_Tipo_Cliente__c = 'Cliente (GRR)' AND CC_Activo__c = false 
                                    WITH SECURITY_ENFORCED LIMIT 1];
      
      if (!lstMotivos.isEmpty()){
         validarCarga(carga, lstMotivos[0]);
      } else {
         throw new AuraHandledException('No se ha encontrado el MCC de tipo motivo con el valor "Pendiente de clasificar".');
      }
   }

   public static void validarCarga(GRR_Carga__c carga, CC_MCC__c motivo) {
      List<String> lstCasosModificados = new List<String>();
      Set<Id> idTodosCasos = new Set<Id>();
      List<GRR_RegistroCarga__c> listaRegistrosConCaso = [SELECT Id, GRR_Caso__c, GRR_Caso__r.CaseNumber, GRR_Caso__r.Status, GRR_Caso__r.OwnerId, GRR_Caso__r.CreatedDate, GRR_Caso__r.LastModifiedDate 
                                                            FROM GRR_RegistroCarga__c 
                                                            WHERE GRR_Fichero__c = :carga.Id AND GRR_Caso__c != null 
                                                            WITH SECURITY_ENFORCED];
      
      if (!listaRegistrosConCaso.isEmpty()) {
         for (GRR_RegistroCarga__c registro : listaRegistrosConCaso) {
            idTodosCasos.add(registro.GRR_Caso__c);
            if (registro.GRR_Caso__r.Status != 'Rechazado') {
               if ((carga.GRR_TipoDeFichero__c == 'Acta de comité') && (String.valueOf(registro.GRR_Caso__r.OwnerId).startsWith('005'))) {
                  //Carga de Comités y caso asignado al usuario (modificado)
                  lstCasosModificados.add(registro.GRR_Caso__r.CaseNumber);
               } else if ((carga.GRR_TipoDeFichero__c == 'Recobro') && (registro.GRR_Caso__r.CreatedDate != registro.GRR_Caso__r.LastModifiedDate)){
                  //Carga de Recobros y caso modificado
                  lstCasosModificados.add(registro.GRR_Caso__r.CaseNumber);
               }
            }
         }
      }
      
      if(lstCasosModificados.isEmpty()){
         ejecutarBorrado(idTodosCasos, carga, motivo);
      } else {
         throw new AuraHandledException('Esta carga contiene los siguientes casos que se están trabajando: ' + lstCasosModificados);
      }
   }

   public static void ejecutarBorrado(Set<Id> idCasos, GRR_Carga__c carga, CC_MCC__c motivo) {
      List<Case> listaCasos = [SELECT Id, Status, CC_MCC_Motivo__c FROM Case WHERE Id IN :idCasos WITH SECURITY_ENFORCED];
      List<Case> listaCasosActualizar = new List<Case>();

      Database.delete(carga, true);
         if (!listaCasos.isEmpty()) {
            for (Case caso : listaCasos) {
               if (caso.Status != 'Rechazado') {
                  caso.Status = 'Rechazado';

                  if(String.isBlank(caso.CC_MCC_Motivo__c)){
                     caso.CC_MCC_Tematica__c = motivo.CC_Producto_Servicio__r.CC_Tematica__c;
                     caso.CC_MCC_ProdServ__c = motivo.CC_Producto_Servicio__c;
                     caso.CC_MCC_Motivo__c = motivo.Id;
                  }

               listaCasosActualizar.add(caso);
            }
         }
      }
      Database.update(listaCasosActualizar, true);
   }
}