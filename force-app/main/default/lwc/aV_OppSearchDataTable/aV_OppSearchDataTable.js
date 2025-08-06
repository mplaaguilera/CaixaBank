import LightningDatatable from 'lightning/datatable';

import cumplimientoHtml from './cumplimiento.html';
import comentarioHtml from './comentario.html';

export default class AV_OppSearchDataTable extends LightningDatatable {
    static customTypes = {
		cumplimiento :{
			template: cumplimientoHtml,
			standardCellLayout:false,
			typeAttributes: ['img','texto']
		},
        comentario: {
            template: comentarioHtml,
			standardCellLayout:false,
			typeAttributes: ['tooltip','texto','isTooltip']
        }
	}
}