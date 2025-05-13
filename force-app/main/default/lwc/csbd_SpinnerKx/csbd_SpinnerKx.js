import {LightningElement, api} from 'lwc';

const SIZE_CLASSES = {
	'x-small': 'slds-spinner_x-small',
	'small': 'slds-spinner_small',
	'medium': 'slds-spinner_medium',
	'large': 'slds-spinner_large',
	'x-large': 'slds-spinner_x-large'
};

export default class csbdSpinnerKx extends LightningElement {

	@api size = 'medium';

	@api variant = 'neutral';

	get spinnerClass() {
		const classes = ['slds-spinner'];
		classes.push(SIZE_CLASSES[this.size] ?? SIZE_CLASSES['medium']);
		this.variant === 'brand' && classes.push('slds-spinner_brand');
		return classes;
	}

	@api async fadeOut() {
		const spinner = this.template.querySelector('div.slds-spinner');
		spinner.addEventListener('animationend', () => {
			spinner.classList.remove('fadeout');
			return true;
		});
		spinner.classList.add('fadeout');
	}
}