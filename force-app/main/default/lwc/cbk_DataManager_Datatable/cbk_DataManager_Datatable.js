import LightningDatatable from 'lightning/datatable';
import pillsTemplate from './pillsTemplate.html';

export default class cbkDataManagerDatatable extends LightningDatatable {
	static customTypes = {
		pills: {
			template: pillsTemplate,
			standardCellLayout: true,
			typeAttributes: ['proyectos', 'colores']
		}
	};
}