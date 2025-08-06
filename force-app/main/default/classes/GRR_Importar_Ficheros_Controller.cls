public with sharing class GRR_Importar_Ficheros_Controller {

  @AuraEnabled(cacheable=true)
  public static String getUrlImport(String tipoObjeto){
    String tipo=((tipoObjeto =='Lanzamiento')?'GRR_Lanzamiento__c':(tipoObjeto==('Stock')?'GRR_UR__c':'GRR_RegistroCarga__c'));
    Blob encodedPart =Blob.valueOf('{"componentDef":"one:alohaPage","attributes":{"address":"/dataImporter/dataImporter.app?objectSelection='+tipo+'"}}');
    return system.Url.getOrgDomainURL().toExternalForm()+'/one/one.app#' + EncodingUtil.base64Encode(encodedPart);
  }

}