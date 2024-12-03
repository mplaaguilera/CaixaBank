Global with sharing class FRA_GenesysCloud_CTIExtensions implements purecloud.CTIExtension.ClickToDial {
	public String onClickToDial(String data) {
		Map<String, Object> clickToDialData = (Map<String, Object>) JSON.deserializeUntyped(data);
		if (clickToDialData.get('object') != 'Case' && clickToDialData.get('object') != 'Opportunity') {
			return '';
		} else {
			Map<String, Object> attributes = new Map<String, Object>();
			attributes.put('casoIdFRA', clickToDialData.get('objectId'));
			clickToDialData.put('attributes', attributes);
			System.debug(clickToDialData);
			return JSON.serialize(clickToDialData);
		}
	}
}