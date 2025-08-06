public with sharing class CBK_LWC_Controller_ParseJson {
	private final static String vExpr = '(\\{"[^{}]).*"}';

	@AuraEnabled(cacheable = true)
	public static Map<String, String> getStringbyRecordId(Id recordId, string vFieldName, string searchKey)
	{
		Map<String, String> mJson = new Map<String, String> ();
		Map<String, String> mJsonFilter = new Map<String, String> ();
		String vDesc = '';
		try {
			vDesc = getDescription(recordId, vFieldName);
			List<string> lstKeys = new List<string> ();
			Map<String, Object> fieldMap;

			if (string.isNotBlank(vDesc)) {
				fieldMap = (Map<String, Object>) JSON.deserializeUntyped(vDesc);
			}

			if (fieldMap != null && fieldMap.size() > 0) {

				CBK_log.debug('CBK_LWC_Controller_ParseJson - Map: ' + fieldMap, LoggingLevel.INFO);
				for (string sk : fieldMap.keySet())
				{
					lstKeys.add(sk);
				}

				string vStrvals;
				mJson = new Map<String, String> ();
				for (string sm : lstKeys)
				{
					vStrvals = string.valueOf(fieldMap.get(sm));
					if (string.isNotBlank(vStrvals))
					{
						mJson.put(sm, vStrvals);
					} 
				}

				if (string.isNotBlank(searchKey))
				{
					for(String str : mJson.keySet()){

						if (str.toUpperCase().contains(searchKey.toUpperCase())){
							mJsonFilter.put(str, mJson.get(str));
						}else if (mJson.get(str).toUpperCase().contains(searchKey.toUpperCase())){
							mJsonFilter.put(str, mJson.get(str));
						}
					}
				}
				CBK_log.debug('CBK_LWC_Controller_ParseJson - ' + mJson, LoggingLevel.INFO);
			}

		} catch(Exception e) {
			CBK_log.error(e, 'Error : CBK_LWC_Controller_PasrseJson - ' + e.getTypeName() + ': ' + e.getMessage());
		}
		if (String.isNotBlank(searchKey)){
			return mJsonFilter;
		}
		return mJson;
	}

	public static String getDescription(Id recordId, string vFieldName)
	{
		string objectType = String.valueOf(recordId.getSObjectType());
		String vDesc = '';

		String query = 'SELECT Id,' + vFieldName +
		' FROM ' + objectType + ' WHERE Id =\'' + recordId + '\'';

		List<SObject> lstObjs = Database.query(query);

		if (lstObjs != null && lstObjs.size() > 0) {

			for (SObject sO : lstObjs) {
				vDesc = string.valueOf(sO.get(vFieldName));
			}
			Pattern p = Pattern.compile(vExpr);
			Matcher pm = p.matcher(vDesc);

			vDesc = pm.find() ? pm.group() : '';
		}
		return vDesc;
	}
}