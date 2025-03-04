({
	callApex: function(component, methodName, params) {
		return new Promise((resolve, reject) => {
			//Create action
			let action = component.get('c.' + methodName);

			if (params) {
				action.setParams(params);
			}

			//Set callback
			action.setCallback(this, response => {
				let state = response.getState();
				if (state === 'SUCCESS') {
					resolve(response.getReturnValue());
				} else if (state === 'ERROR') {
					let errors = response.getError();
					if (errors && errors.length > 0) {
						reject(errors[0].message);
					} else {
						reject('Unknown error occurred.');
					}
				} else {
					reject('Unexpected response state: ' + state);
				}
			});

			//Enqueue the action
			$A.enqueueAction(action);
		});
	}
});