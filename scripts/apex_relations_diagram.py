import graphviz

# Definición de nodos y relaciones
relaciones = [
	# Métodos de CSBD_Opportunity_Operativas_Controller que llaman a otros
	('CSBD_Opportunity_Operativas_Controller.actualizarOwnerOportunidad', 'CSBD_Opportunity.actualizarPropietarioOportunidadOmnichannel'),
	('CSBD_Opportunity_Operativas_Controller.prepararOportunidadParaEnvioCorreo', 'CSBD_Opportunity.prepararOportunidadParaEnvioCorreo'),
	('CSBD_Opportunity_Operativas_Controller.cerrarOportunidad', 'CSBD_Opportunity.cerrarOportunidad'),
	('CSBD_Opportunity_Operativas_Controller.reactivarOportunidad', 'CSBD_Opportunity.reactivarOportunidad'),
	('CSBD_Opportunity_Operativas_Controller.duplicarOportunidad', 'CSBD_Opportunity.duplicarOportunidad'),
	('CSBD_Opportunity_Operativas_Controller.trasladoImaginBank', 'CSBD_Opportunity.cerrarOportunidad'),
	('CSBD_Opportunity_Operativas_Controller.obtenerOportunidadesHijas', 'CSBD_ProductoOportunidadHija.obtenerOportunidadesHijasAbiertas'),
	('CSBD_Opportunity_Operativas_Controller.actualizarDatosRiesgoContacto', 'CSBD_SIR.actualizarDatosRiesgoCliente'),
	('CSBD_Opportunity_Operativas_Controller.obtenerResoluciones', 'CSBD_Utils.listaCampo'),
	('CSBD_Opportunity_Operativas_Controller.obtenerEntidades', 'CSBD_Utils.listaCampo'),
	('CSBD_Opportunity_Operativas_Controller.numeroOportunidadesAnteriores', 'CC_MetodosUtiles.getRecordTypeNameFromDeveloperName'),
	('CSBD_Opportunity_Operativas_Controller.numeroOportunidadesAnteriores', 'CC_MetodosUtiles.getRecordTypeNameFromDeveloperName'),
	('CSBD_Opportunity_Operativas_Controller.pluralRecordTypeName', 'CC_MetodosUtiles.getRecordTypeNameFromDeveloperName'),
	('CSBD_Opportunity_Operativas_Controller.crearTareaGestor', 'CSBD_MetodosComunes.buscarCentro'),
	# Manejo de errores
	('CSBD_Opportunity_Operativas_Controller', 'CBK_Log.error'),
]

# Creación del grafo
f = graphviz.Digraph('ApexRelations', filename='apex_relations_diagram', format='png')

# Añadir nodos y relaciones
for origen, destino in relaciones:
	f.edge(origen, destino)

# Exportar a PNG
def main():
	f.render(cleanup=True)

if __name__ == '__main__':
	main()