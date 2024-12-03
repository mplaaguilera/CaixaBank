import {LightningElement, api} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';

const CLASES_TIMELINE_ITEM = {
	'Task': 'slds-timeline__item_expandable slds-timeline__item_task',
	'Email': 'slds-timeline__item_expandable slds-timeline__item_email',
	'Case': 'slds-timeline__item_expandable timeline__item_case',
	'Chat-Agente': 'slds-timeline__item_expandable timeline__item_chat',
	'Chat-Chatbot': 'slds-timeline__item_expandable timeline__item_chat',
	'Other': 'slds-timeline__item_expandable timeline__item_social',
	'Twitter': 'slds-timeline__item_expandable timeline__item_twitter'
	//event: 'slds-timeline__item_expandable slds-timeline__item_event',
	//'call': 'slds-timeline__item_expandable slds-timeline__item_call',
};

//eslint-disable-next-line new-cap, camelcase
export default class Cc_Timeline_Item extends NavigationMixin(LightningElement) {
	@api
	get item() {
		return this._item;
	}

	set item(value) {
		this._item = {...value, timelineItemClass: CLASES_TIMELINE_ITEM[value.ActivityTimelineType]};
	}

	_item;

	isTask = false;

	isCase = false;

	isChat = false;

	isMailInbound = false;

	isMailOutbound = false;

	isSocial = false;

	isTwitter = false;

	incoming;

	connectedCallback() {
		this.incoming = this.item?.Entrante;

		switch (this.item.ActivityTimelineType) {
			case 'Case':
				this.isCase = true;
				break;
			case 'Chat-Agente':
				this.isChat = true;
				break;
			case 'Chat-Chatbot':
				this.isChat = true;
				break;
			case 'Email':
				if (this.item.Entrante) {
					this.isMailInbound = true;
				} else {
					this.isMailOutbound = true;
				}
				break;
			case 'Twitter':
				this.isTwitter = true;
				break;
			case 'Other':
				this.isSocial = true;
				break;
			default:
				this.isTask = true;
		}
	}

	navigate(event) {
		event.stopPropagation();
		event.preventDefault();
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: event.currentTarget.dataset.recordId,
				//objectApiName: 'Case',
				actionName: 'view'
			}
		});
	}

	expandirContraerItem(event) {
		this.template.querySelector('[data-item-id="' + event.currentTarget.dataset.id + '"]').classList.toggle('slds-is-open');
		event.stopPropagation();
	}
}