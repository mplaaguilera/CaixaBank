import LightningDatatable from 'lightning/datatable';

import interlocutorCustomBadge from './interlocutorBadge.html';

export default class Av_GrupoInterlocutorDatatable extends LightningDatatable {
static customTypes = {
		miembro :{
			template: interlocutorCustomBadge,
			standardCellLayout:false,
			typeAttributes: ['isInterloc','nameAccount']
		}
	}


}