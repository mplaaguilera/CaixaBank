import LightningDatatable from 'lightning/datatable';
import iconoPrioridadTemplate from './iconoPrioridadTemplate.html';

//eslint-disable-next-line camelcase
export default class seg_Casos_Por_Grupo_Datatable extends LightningDatatable {
	static customTypes = {
		iconoPrioridad: {
			template: iconoPrioridadTemplate,
			standardCellLayout: true,
			typeAttributes: ['prioridad', 'tooltip']
		}
	}
}