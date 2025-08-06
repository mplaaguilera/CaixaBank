public class SEG_Marca_Case_AD_TRHan extends CC_TriggerHandlerBase {
	public override void mainEntry(CC_TriggerParameters tp) {

		System.debug('AfterDelete MarcaCase');
		// Quedarnos solo marcas eliminadas a casos de segmento
		Set<Id> caseIds = new Set<Id> ();
		Set<Id> caracteIds = new Set<Id> ();
		for (SEG_Marcasdeuncaso__c marcaCase : (List<SEG_Marcasdeuncaso__c>) tp.oldList) {
			caseIds.add(marcaCase.SEG_Caso__c);
			caracteIds.add(marcaCase.SEG_Caracteristica__c);
		}
		Set<Id> recordTypesSeg = new Set<Id> ();
		Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		Id recordTypeSeguimiento = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
		Id recordTypeMarcasCaso = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('SEG_Caracteristicacaso').getRecordTypeId();
		recordTypesSeg.add(recordTypeSEG);
		recordTypesSeg.add(recordTypeSEG);
		Map<Id, Case> mapCases = new Map<Id, Case> ([Select Id From Case Where RecordTypeId IN :recordTypesSeg and Id IN :caseIds]);
		Map<Id, CC_Caracteristica__c> mapCaractCase = new Map<Id, CC_Caracteristica__c> ([Select Id, RecordTypeId From CC_Caracteristica__c Where RecordTypeId = :recordTypeMarcasCaso and Id IN :caracteIds]);
		List<SEG_Marcasdeuncaso__c> lstMarcaCaseSeg = new List<SEG_Marcasdeuncaso__c> ();
		for (SEG_Marcasdeuncaso__c marcaCase : (List<SEG_Marcasdeuncaso__c>) tp.oldList)
		{
			if (mapCases.containsKey(marcaCase.SEG_Caso__c) && mapCaractCase.containsKey(marcaCase.SEG_Caracteristica__c)) {
				lstMarcaCaseSeg.add(marcaCase);
			}
		}
		if (lstMarcaCaseSeg.size() > 0)
		{
			process(lstMarcaCaseSeg, (List<SEG_Marcasdeuncaso__c>) tp.oldList);
		}
	}

	private void process(List<SEG_Marcasdeuncaso__c> lstMarcaCaseSeg, List<SEG_Marcasdeuncaso__c> listOldObj) {
		crearFotoFacturacion(lstMarcaCaseSeg);
	}

	private void crearFotoFacturacion(List<SEG_Marcasdeuncaso__c> lstMarcaCaseSeg) {
		Map<Id, List<SEG_Marcasdeuncaso__c>> caseMarcas = new Map<Id, List<SEG_Marcasdeuncaso__c>> ();
		List<Id> lstCaseIds = new List<Id> ();
		SEG_Marcasdeuncaso__c marc;
		for (SEG_Marcasdeuncaso__c marca : lstMarcaCaseSeg) {
			marc = marca.clone();
			if(caseMarcas.containsKey(marc.SEG_Caso__c)){
				caseMarcas.get(marc.SEG_Caso__c).add(marc);
			}else{
				caseMarcas.put(marc.SEG_Caso__c, new List<SEG_Marcasdeuncaso__c>{marc});
			}
			lstCaseIds.add(marc.SEG_Caso__c);
		}
		if (lstCaseIds.size() > 0) {
			SEG_FotoFacturacionHandler ffHandler = new SEG_FotoFacturacionHandler(lstCaseIds, SEG_FotoFacturacionHandler.Operativa.Marca, caseMarcas);
			System.enqueueJob(ffHandler);
		}
	}
}