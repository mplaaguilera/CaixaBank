/*eslint-disable @lwc/lwc/no-async-await */
import {LightningElement, api} from 'lwc';
import {registerRefreshContainer, unregisterRefreshContainer, registerRefreshHandler, unregisterRefreshHandler, RefreshEvent, REFRESH_COMPLETE, REFRESH_COMPLETE_WITH_ERRORS, REFRESH_ERROR} from 'lightning/refresh';
import getActivityTimeline from '@salesforce/apex/CC_activityTimeline_Controller.getActivityTimeline';

//eslint-disable-next-line camelcase
export default class Cc_Contact_TimeLine extends LightningElement {
	@api recordId;

	@api objectApiName

	interacciones = [];

	refreshHandlerId;

	refreshContainerId;

	/*
	@wire(getActivityTimeline, {recordId: '$recordId', tipo: 'All', origen: '$objectApiName'})
	wiredInteracciones({error, data}) {
		if (data) {
			this.interacciones = data;
		} else if (error) {
			console.error(error);
		}
	}
	*/

	connectedCallback() {
		this.refreshHandlerId = registerRefreshHandler(
			this.template.host,
			this.refreshHandler.bind(this)
		);
		this.refreshContainerId = registerRefreshContainer(
			this.template.host,
			this.refreshContainer.bind(this)
		);

		getActivityTimeline({recordId: this.recordId, tipo: 'All', origen: this.objectApiName})
		.then(data => this.interacciones = data)
		.catch(error => console.error(error));
	}

	disconnectedCallback() {
		unregisterRefreshHandler(this.refreshHandlerId);
		unregisterRefreshContainer(this.refreshContainerId);
	}

	refreshContainer(refreshPromise) {
		console.log('refreshing');
		return refreshPromise.then(status => {
			if (status === REFRESH_COMPLETE) {
				console.log('Done!');
			} else if (status === REFRESH_COMPLETE_WITH_ERRORS) {
				console.warn('Done, with issues refreshing some components');
			} else if (status === REFRESH_ERROR) {
				console.error('Major error with refresh.');
			}
		});
	}

	refreshHandler() {
		return new Promise(resolve => {
			getActivityTimeline({recordId: this.recordId, tipo: 'All', origen: this.objectApiName})
			.then(data => this.interacciones = data)
			.catch(error => console.error(error));

			resolve(true);
		});
	}

	refresh() {
		this.dispatchEvent(new RefreshEvent());
	}
}