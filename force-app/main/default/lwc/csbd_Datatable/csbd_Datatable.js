import LightningDatatable from 'lightning/datatable';
import typeCustomTemplate from './templates/custom.html';

export default class csbdDatatable extends LightningDatatable {
	static customTypes = {
		custom: {
			template: typeCustomTemplate,
			standardCellLayout: true,
			typeAttributes: ['background-color']
		}
	};
}