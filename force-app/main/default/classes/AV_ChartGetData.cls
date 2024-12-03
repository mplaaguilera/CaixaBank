/**********************************************************************************************************************
 Name:	  AV_ChartGetData
 Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Clase para obtener los Datos requeridos.
=======================================================================================================================
Historial
---------------------
   VERSION		USER_STORY			AUTHOR				DATE				Description
   1.0			AV_ChartGetData		Carolina Alonso		20/04/2020		  	Init version
   1.1			AV_ChartGetData		David Rufo			29/04/2020		  	Update methods + Query's

***********************************************************************************************************************/
public with sharing class AV_ChartGetData {
	
	private static final String OFICINAGESTOR  	= '#oficinaGestor#';
	private static final String NUMERO_OFICINA 	= 'CC_Numero_Oficina__c';
	private static final String USERIDLOGIN  	= '#userloginid#';
	private static final String METADATA_DEVELOPERNAME  = '#mdt-developername#';
	private static String queryRetriveNumeroOficina 	= 'SELECT CC_Numero_Oficina__c FROM Contact where AV_UsuarioAsociado__c = \'' + USERIDLOGIN + '\' LIMIT 1';
	private static String queryRetireveMetadata 		= 'SELECT Id, DeveloperName, AV_Orden__c,AV_TipoGrafico__c, Label, AV_Data__c, ' + 
													'AV_FilterField__c, AV_BackgroundColor__c,AV_BorderColor__c, AV_UserFilterField__c, AV_UserBackgroundColor__c, AV_UserBorderColor__c ' +
													'from AV_ConfiguracionGrafico__mdt ' +
													'WHERE DeveloperName in (' + METADATA_DEVELOPERNAME + ')' + 
													'order by AV_Orden__c ASC';

	private static final String MT_FIELD_BACKGROUNDCOLOR 	= 'AV_BackgroundColor__c';
	private static final String MT_FIELD_BORDERCOLOR 		= 'AV_BorderColor__c';
	private static final String MT_FIELD_USERFILTER 		= 'AV_UserFilterField__c';
	private static final String MT_FIELD_USERBACKGROUND 	= 'AV_UserBackgroundColor__c';
	private static final String MT_FIELD_USERBACKBORDER 	= 'AV_UserBorderColor__c';
	private static final String MT_FIELD_FILTER 			= 'AV_FilterField__c';
	private static final String MT_FIELD_TYPECHART 			= 'AV_TipoGrafico__c';
	private static final String MT_FIELD_LABELCHART			= 'Label';
	private static final String MT_FIELD_QUERY 				= 'AV_Data__c';
	
	public class Response {
		@AuraEnabled
		public String[] listLabels;
		@AuraEnabled
		public DatasetModel[] dtsetModel;
		@AuraEnabled
		public String severity;
		@AuraEnabled
		public String descError;

		public Response() {
			listLabels = new List<String>();
			severity = AV_AppConstants.OK;
		}
	}

	public class DatasetModel {
		@AuraEnabled
		public String type;
		@AuraEnabled
		public String label;
		@AuraEnabled
		public Double[] data;
		@AuraEnabled
		public String[] backgroundColor;
		@AuraEnabled
		public String[] borderColor;
		@AuraEnabled
		public Double borderWidth;

		public DatasetModel(){
			data = new List<Double>();
			backgroundColor = new List<String>();
			borderColor = new List<String>();
		}
	}
	
	@AuraEnabled(cacheable=true)
	public static Response getData(String queryData, String queryLabel, String dtSetQuery) {
		String methodName = 'getData';
		Response resp = new Response();
		try{
			resp.listLabels = getLabels(queryData, queryLabel);
			resp.dtsetModel = getDataSets(dtSetQuery);
			if (resp.dtsetModel==null || resp.dtsetModel.isEmpty()){
				resp.severity = AV_AppConstants.ERROR;
				resp.descError = Label.AV_ChartJSNoData;
			}
		}catch(System.Exception e){
			AV_LogDebug.printException(methodName, e);
			resp.severity = AV_AppConstants.ERROR;
			resp.descError = Label.AV_UnknownError + AV_AppConstants.HTML_BREAKLINE + e.getMessage();
		}
		return resp;
	}

	private static DatasetModel[] getDataSets(String queryData) {
		String methodName = 'getDataSets';
		String queryDataExecute = queryRetireveMetadata.replace(METADATA_DEVELOPERNAME, queryData);
		AV_LogDebug.printLogDebug(methodName, 'Metadata - Query execute: ' + queryDataExecute);
		
		//Declare variables
		DatasetModel[] dtModelList = new List<DatasetModel>();

		//Get the list of the metadata from 'AV_ConfiguracionGrafico__mdt'
		List<SObject> getMetaData = Database.query(queryDataExecute);
		if (getMetaData!=null && !getMetaData.isEmpty()){
			//Parse the list of the dataset from the metadata
			for(SObject objMetadata : getMetaData){
				String strQueryData = (String)objMetadata.get(MT_FIELD_QUERY);
				
				//Execute the query
				List<SObject> listSObject = getDataQuery(strQueryData);
				DatasetModel dtsetModel = parseDatasetModel(listSObject, objMetadata);
				if (dtsetModel!=null){
					dtModelList.add(dtsetModel);
				}else{
					AV_LogDebug.printLogDebug(methodName, 'No data found: ' + strQueryData);
				}
			}
			AV_LogDebug.printLogDebug(methodName, 'dtModelList: ' + dtModelList);
			normalizeListDataset(dtModelList);
		}else{
			AV_LogDebug.printLogDebug(methodName, 'No data found: ' + queryData);
		}
		return dtModelList;
	}
	
	private static String[] getLabels(String queryData, String queryLabel) {	   
		String methodName = 'getLabels';
		String[] listLabels = new List<String>();
		AV_LogDebug.printLogDebug(methodName, 'Labels - Query execute: ' + queryData);
		
		//Check if the query label contains comma for the join the data
		Set<String> listNames = new Set<String>();
		if(queryLabel.contains(',')){
			listNames = new Set<String>(queryLabel.split(','));
		} else{
			listNames.add(queryLabel);
		}

		//Execute the query + parse the data for get the labels
		List<SObject> listSObject = getDataQuery(queryData);
		for(SObject dataObject : listSObject){
			String labelName = getLabelParserJson(dataObject, listNames);
			listLabels.add(labelName);
		}

		return listLabels;
	}

	private static List<SObject> getDataQuery(String queryData){
		String strQueryData = queryData;
		//Check if the query contains tag "#oficinagestor#"
		if(strQueryData.contains(OFICINAGESTOR)){
			SObject listOficina = Database.query(queryRetriveNumeroOficina.replace(USERIDLOGIN, UserInfo.getUserId()));
			if(String.isNotBlank((String) listOficina.get(NUMERO_OFICINA))){
				strQueryData = strQueryData.replace(OFICINAGESTOR, (String) listOficina.get(NUMERO_OFICINA));
			}
		}
		return Database.query(strQueryData);
	}

	private static String getLabelParserJson(SObject dataObject, Set<String> listNames){
		String strData = System.JSON.serialize(dataObject);
		//AV_LogDebug.printLogDebug(methodName, 'strData: ' + strData);
		JSONParser parser = JSON.createParser(strData);
		String labelName = '';
		String separator = '-';
		while (parser.nextToken() != null) {
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && listNames.contains(parser.getText())) {
				// Get the next value
				parser.nextToken();	
				if(parser.getText() != null && !'null'.equalsIgnoreCase(parser.getText()) && String.isNotBlank(parser.getText())){
					labelName += parser.getText() + separator;
				}
			}
		}
		labelName = labelName.removeEnd(separator);
		return labelName;
	}
	
	private static DatasetModel parseDatasetModel(List<SObject> listSObject, SObject objMetadata){
		String methodName = 'parseDatasetModel';
		DatasetModel dtsetModel = null;

		if (listSObject!=null && !listSObject.isEmpty()){
			dtsetModel = new DatasetModel();

			//Parse dataset
			for(SObject dataObject : listSObject){
				dtsetModel = setDataParseJson(dtsetModel, dataObject, objMetadata);
			}
	
			//Dataset type
			dtsetModel.type = (String)objMetadata.get(MT_FIELD_TYPECHART);
			//Dataset label		
			dtsetModel.label = (String)objMetadata.get(MT_FIELD_LABELCHART);
		}

		return dtsetModel;
	}

	private static DatasetModel setDataParseJson(DatasetModel dtsetModel, SObject dataObject, SObject objMetadata){
		String strData = System.JSON.serialize(dataObject);
		JSONParser parser = JSON.createParser(strData);
		Boolean addedColor = false;
		while (parser.nextToken() != null) {
			if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
				//Get the contente of the data to display in the chart
				if (parser.getText() == objMetadata.get(MT_FIELD_FILTER)){
					parser.nextToken();				
					dtsetModel.data.add(parser.getDoubleValue());
				}

				//Set the color only for running user
				if(String.isNotBlank(MT_FIELD_USERFILTER) && parser.getText() == objMetadata.get(MT_FIELD_USERFILTER)){
					parser.nextToken();
					if(parser.getText().equalsIgnoreCase(UserInfo.getUserId())){
						dtsetModel.backgroundColor.add((String)objMetadata.get(MT_FIELD_USERBACKGROUND));
						dtsetModel.borderColor.add((String)objMetadata.get(MT_FIELD_USERBACKBORDER));
						addedColor = true;
					}
				}
			} 
		}
		if(!addedColor){
			dtsetModel.backgroundColor.add((String)objMetadata.get(MT_FIELD_BACKGROUNDCOLOR));
			dtsetModel.borderColor.add((String)objMetadata.get(MT_FIELD_BORDERCOLOR));
		}

		return dtsetModel;
	}

	private static void normalizeListDataset(List<DatasetModel> dtModelList){
		//Check the size of arraylist
		Integer sizeData = getSizeArray(dtModelList);

		if (sizeData>0){
			//Fill the data array with the last value
			for(DatasetModel dtModel : dtModelList){
				if(dtModel.data.size() < sizeData) {
					Integer diffSize = sizeData - dtModel.data.size();
					fillArrayData(diffSize, dtModel);
				}
			}
		}
	}

	private static Integer getSizeArray(List<DatasetModel> dtModelList){
		Integer sizeData = 0;
		Boolean containsArrayDiffLength = false;
		for(DatasetModel dtModel : dtModelList){
			if(sizeData < dtModel.data.size()){
				sizeData = dtModel.data.size();
			}
			if (sizeData > dtModel.data.size()){
				containsArrayDiffLength = true;
			}
		}
		if (!containsArrayDiffLength){
			sizeData = -1;
		}
		return sizeData;
	}

	private static void fillArrayData(Integer sizeArray, DatasetModel dtModel){
		Double lastValue = dtModel.data.get(dtModel.data.size()-1);
		for(Integer i=0; i < sizeArray; i++){
			dtModel.data.add(lastValue);
			dtModel.backgroundColor.add(dtModel.backgroundColor.get(0));
			dtModel.borderColor.add(dtModel.borderColor.get(0));
		}
	}
}