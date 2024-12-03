({    
	onTabFocused: function(component, event) {
		component.find('workspace').getTabInfo({tabId: event.getParam('currentTabId')})
			.then(response => {
				if (response.pageReference.attributes.objectApiName === 'Contact'
				|| response.pageReference.attributes.objectApiName === 'Account') {
					$A.get('e.force:refreshView').fire(); //Refrescar pantalla.
				}
			});
	}
})