public without sharing class CC_MCC_Metodos {
	
	@InvocableMethod(label='CC_MCC_Metodos' description='Generar externalId MCC')
	public static void generaExternalId (List<Id> mccs) {
		if (!mccs.isEmpty()) {
			List<CC_MCC__c> listMccs = [SELECT CC_Codigo_Externo__c, RecordType.DeveloperName, CC_Tipo_Cliente__c FROM CC_MCC__c WHERE Id IN :mccs];
			List<CC_MCC__c> mccsUpdate = new List<CC_MCC__c>();
			
			Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
			Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
			Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
			Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
			Id recordTypeIdSolucion = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
			
			Boolean mccCSI = false;
			Boolean mccCAM = false;
			Boolean mccCOPS = false;
			Boolean mccSACH = false;
			Boolean mccHDT = false;
			Boolean mccFRA = false;
			Boolean mccGenerico = false;
            Boolean mccCC = false;
            Boolean mccGRR = false;
			
			for (CC_MCC__c mcc : listMccs) {
				if (mcc.CC_Tipo_Cliente__c == 'Cliente' || mcc.CC_Tipo_Cliente__c == 'Empleado' || mcc.CC_Tipo_Cliente__c == 'Cliente/Empleado' || mcc.CC_Tipo_Cliente__c == 'Prejubilado' || mcc.CC_Tipo_Cliente__c == 'Proveedor / Empleado') {
					mccCC = true;
				}else if (mcc.CC_Tipo_Cliente__c.contains('CSI')) {
					mccCSI = true;
				} else if (mcc.CC_Tipo_Cliente__c.contains('CAM')) {
					mccCAM = true;
				} else if (mcc.CC_Tipo_Cliente__c.contains('COPS')) {
					mccCOPS = true;
				}else if (mcc.CC_Tipo_Cliente__c.contains('SACH')) {
					mccSACH = true;
				}else if (mcc.CC_Tipo_Cliente__c.contains('HDT')){
					mccHDT = true;
				}else if (mcc.CC_Tipo_Cliente__c.contains('FRA')) {
					mccFRA = true;
				}else if (mcc.CC_Tipo_Cliente__c.contains('GRR')) {
					mccGRR = true;
				}else {
					mccGenerico = true;
				}
				
			}
			
			String codigoExternoTematica;
			String[] codExternoTematica;
                Integer numTematica = 0;
                String codigoExternoProducto;
                String[] codExternoProducto;
                Integer numProducto = 0;
                String codigoExternoMotivo;
                String[] codExternoMotivo;
                Integer numMotivo = 0;
                String codigoExternoCausa;
                String[] codExternoCausa;
                Integer numCausa = 0;
                String codigoExternoSolucion;
                String[] codExternoSolucion;
                Integer numSolucion = 0;

				if (mccGenerico){
                    List <CC_MCC__c> codigosExternosTematica = [SELECT CC_Codigo_Externo__c FROM CC_MCC__c WHERE RecordTypeId = :recordTypeIdTematica AND CC_Codigo_Externo__c <> null AND (NOT CC_Tipo_Cliente__c IN('Cliente','Empleado','Cliente/Empleado','Prejubilado','Proveedor / Empleado')) 
                                        AND (NOT CC_Tipo_Cliente__c like '%COPS%')AND (NOT CC_Tipo_Cliente__c like '%CSI%') AND (NOT CC_Tipo_Cliente__c like '%CAM%') AND (NOT CC_Tipo_Cliente__c like '%SACH%') AND (NOT CC_Tipo_Cliente__c like '%HDT%') AND (NOT CC_Tipo_Cliente__c = 'SAC') AND (NOT CC_Tipo_Cliente__c = 'Segmentos') AND (NOT CC_Tipo_Cliente__c = 'Cliente (FRA)') AND (NOT CC_Tipo_Cliente__c = 'Cliente (GRR)') ORDER BY CC_Codigo_Externo__c DESC LIMIT 1 ];
                    List <CC_MCC__c> codigosExternosProducto = [SELECT CC_Codigo_Externo__c FROM CC_MCC__c WHERE RecordTypeId = :recordTypeIdProducto AND CC_Codigo_Externo__c <> null AND (NOT CC_Tipo_Cliente__c IN('Cliente','Empleado','Cliente/Empleado','Prejubilado','Proveedor / Empleado'))
                                        AND (NOT CC_Tipo_Cliente__c like '%COPS%') AND (NOT CC_Tipo_Cliente__c like '%CSI%') AND (NOT CC_Tipo_Cliente__c like '%CAM%') AND (NOT CC_Tipo_Cliente__c like '%SACH%') AND (NOT CC_Tipo_Cliente__c like '%HDT%') AND (NOT CC_Tipo_Cliente__c = 'SAC') AND (NOT CC_Tipo_Cliente__c = 'Segmentos') AND (NOT CC_Tipo_Cliente__c = 'Cliente (FRA)') AND (NOT CC_Tipo_Cliente__c = 'Cliente (GRR)') ORDER BY CC_Codigo_Externo__c DESC LIMIT 1 ];
                    List <CC_MCC__c> codigosExternosMotivo = [SELECT CC_Codigo_Externo__c FROM CC_MCC__c WHERE RecordTypeId = :recordTypeIdMotivo AND CC_Codigo_Externo__c <> null AND (NOT CC_Tipo_Cliente__c IN('Cliente','Empleado','Cliente/Empleado','Prejubilado','Proveedor / Empleado'))
                                        AND (NOT CC_Tipo_Cliente__c like '%COPS%') AND (NOT CC_Tipo_Cliente__c like '%CSI%') AND (NOT CC_Tipo_Cliente__c like '%CAM%') AND (NOT CC_Tipo_Cliente__c like '%SACH%') AND (NOT CC_Tipo_Cliente__c like '%HDT%') AND (NOT CC_Tipo_Cliente__c = 'SAC') AND (NOT CC_Tipo_Cliente__c = 'Segmentos') AND (NOT CC_Tipo_Cliente__c = 'Cliente (FRA)') AND (NOT CC_Tipo_Cliente__c = 'Cliente (GRR)') ORDER BY CC_Codigo_Externo__c DESC LIMIT 1 ];
                    List <CC_MCC__c> codigosExternosCausa = [SELECT CC_Codigo_Externo__c FROM CC_MCC__c WHERE RecordTypeId = :recordTypeIdCausa AND CC_Codigo_Externo__c <> null AND (NOT CC_Tipo_Cliente__c IN('Cliente','Empleado','Cliente/Empleado','Prejubilado','Proveedor / Empleado'))
                                        AND (NOT CC_Tipo_Cliente__c like '%COPS%') AND (NOT CC_Tipo_Cliente__c like '%CSI%') AND (NOT CC_Tipo_Cliente__c like '%CAM%') AND (NOT CC_Tipo_Cliente__c like '%SACH%') AND (NOT CC_Tipo_Cliente__c like '%HDT%') AND (NOT CC_Tipo_Cliente__c = 'SAC') AND (NOT CC_Tipo_Cliente__c = 'Segmentos') AND (NOT CC_Tipo_Cliente__c = 'Cliente (FRA)') AND (NOT CC_Tipo_Cliente__c = 'Cliente (GRR)') ORDER BY CC_Codigo_Externo__c DESC LIMIT 1 ];
                    List <CC_MCC__c> codigosExternosSolucion = [SELECT CC_Codigo_Externo__c FROM CC_MCC__c WHERE RecordTypeId = :recordTypeIdSolucion AND CC_Codigo_Externo__c <> null AND (NOT CC_Tipo_Cliente__c IN('Cliente','Empleado','Cliente/Empleado','Prejubilado','Proveedor / Empleado'))
                                        AND (NOT CC_Tipo_Cliente__c like '%COPS%') AND (NOT CC_Tipo_Cliente__c like '%CSI%') AND (NOT CC_Tipo_Cliente__c like '%CAM%') AND (NOT CC_Tipo_Cliente__c like '%SACH%') AND (NOT CC_Tipo_Cliente__c like '%HDT%') AND (NOT CC_Tipo_Cliente__c = 'SAC') AND (NOT CC_Tipo_Cliente__c = 'Segmentos') AND (NOT CC_Tipo_Cliente__c = 'Cliente (FRA)') AND (NOT CC_Tipo_Cliente__c = 'Cliente (GRR)') ORDER BY CC_Codigo_Externo__c DESC LIMIT 1 ];
				
				//TEMÁTICA
				if (!codigosExternosTematica.isEmpty()) {
					codigoExternoTematica = codigosExternosTematica.get(0).CC_Codigo_Externo__c;
					if (codigoExternoTematica.contains('-')) {
						codExternoTematica = codigoExternoTematica.split('-');
						if(codExternoTematica[1].isNumeric()) {
							numTematica = Integer.ValueOf(codExternoTematica[1]);
						}
					}
				}
				//PRODUCTO
				if(!codigosExternosProducto.isEmpty()){
					codigoExternoProducto = codigosExternosProducto.get(0).CC_Codigo_Externo__c;
					if(codigoExternoProducto.contains('-')){
						codExternoProducto = codigoExternoProducto.split('-');
						if(codExternoProducto[1].isNumeric()){
							numProducto = Integer.ValueOf(codExternoProducto[1]);
						}
					}
				}
				//MOTIVO
				if(!codigosExternosMotivo.isEmpty()){
					codigoExternoMotivo = codigosExternosMotivo.get(0).CC_Codigo_Externo__c;
					if(codigoExternoMotivo.contains('-')){
						codExternoMotivo = codigoExternoMotivo.split('-');
						if(codExternoMotivo[1].isNumeric()){
							numMotivo = Integer.ValueOf(codExternoMotivo[1]);
						}
					}
				}
				//CAUSA
				if(!codigosExternosCausa.isEmpty()){
					codigoExternoCausa = codigosExternosCausa.get(0).CC_Codigo_Externo__c;
					if(codigoExternoCausa.contains('-')){
						codExternoCausa = codigoExternoCausa.split('-');
						if(codExternoCausa[1].isNumeric()){
							numCausa = Integer.ValueOf(codExternoCausa[1]);
						}
					}
				}
				//SOLUCIÓN
				if(!codigosExternosSolucion.isEmpty()){
					codigoExternoSolucion = codigosExternosSolucion.get(0).CC_Codigo_Externo__c;
					if(codigoExternoSolucion.contains('-')){
						codExternoSolucion = codigoExternoSolucion.split('-');
						if(codExternoSolucion[1].isNumeric()){
							numSolucion = Integer.ValueOf(codExternoSolucion[1]);
						}
					}
				}
			}
            
            //NowInContact
            String codigoExternoTematicaCC;
            String[] codExternoTematicaCC;
            Integer numTematicaCC = 0;
            String codigoExternoProductoCC;
            String[] codExternoProductoCC;
            Integer numProductoCC = 0;
            String codigoExternoMotivoCC;
            String[] codExternoMotivoCC;
            Integer numMotivoCC = 0;
            String codigoExternoCausaCC;
            String[] codExternoCausaCC;
            Integer numCausaCC = 0;
            String codigoExternoSolucionCC;
            String[] codExternoSolucionCC;
            Integer numSolucionCC = 0;
            
            if(mccCC){
                List<CC_MCC__c> codigosExternosTematicaCC = getMCCSCC(recordTypeIdTematica);
                List<CC_MCC__c> codigosExternosProductoCC = getMCCSCC(recordTypeIdProducto);
                List<CC_MCC__c> codigosExternosMotivoCC = getMCCSCC(recordTypeIdMotivo);
                List<CC_MCC__c> codigosExternosCausaCC = getMCCSCC(recordTypeIdCausa);
                List<CC_MCC__c> codigosExternosSolucionCC = getMCCSCC(recordTypeIdSolucion);
                
                //TEMÁTICAS
                if (!codigosExternosTematicaCC.isEmpty()){
                    codigoExternoTematicaCC = codigosExternosTematicaCC.get(0).CC_Codigo_Externo__c;
                    if(codigoExternoTematicaCC.contains('-')){
                        codExternoTematicaCC = codigoExternoTematicaCC.split('-');
                        if(codExternoTematicaCC[1].isNumeric()){
                            numTematicaCC = Integer.ValueOf(codExternoTematicaCC[1]);
                        }
					}
				}
				//PRODUCTOS
				if(!codigosExternosProductoCC.isEmpty()){
					codigoExternoProductoCC = codigosExternosProductoCC.get(0).CC_Codigo_Externo__c;
					if(codigoExternoProductoCC.contains('-')){
						codExternoProductoCC = codigoExternoProductoCC.split('-');
						if(codExternoProductoCC[1].isNumeric()){
							numProductoCC = Integer.ValueOf(codExternoProductoCC[1]);
						}
					}
				}
				//MOTIVOS
				if(!codigosExternosMotivoCC.isEmpty()){
					codigoExternoMotivoCC = codigosExternosMotivoCC.get(0).CC_Codigo_Externo__c;
					if(codigoExternoMotivoCC.contains('-')){
						codExternoMotivoCC = codigoExternoMotivoCC.split('-');
						if(codExternoMotivoCC[1].isNumeric()){
							numMotivoCC = Integer.ValueOf(codExternoMotivoCC[1]);
						}
					}
				}
				//CAUSA
				if(!codigosExternosCausaCC.isEmpty()){
					codigoExternoCausaCC = codigosExternosCausaCC.get(0).CC_Codigo_Externo__c;
					if(codigoExternoCausaCC.contains('-')){
						codExternoCausaCC = codigoExternoCausaCC.split('-');
						if(codExternoCausaCC[1].isNumeric()){
							numCausaCC = Integer.ValueOf(codExternoCausaCC[1]);
						}
					}
				}
				//SOLUCIÓN
				if(!codigosExternosSolucionCC.isEmpty()){
					codigoExternoSolucionCC = codigosExternosSolucionCC.get(0).CC_Codigo_Externo__c;
					if(codigoExternoSolucionCC.contains('-')){
						codExternoSolucionCC = codigoExternoSolucionCC.split('-');
						if(codExternoSolucionCC[1].isNumeric()){
							numSolucionCC = Integer.ValueOf(codExternoSolucionCC[1]);
						}
					}
				}				
			}
            
            //COPS			
			String codigoExternoTematicaCOPS;
			String[] codExternoTematicaCOPS;
                Integer numTematicaCOPS = 0;
                String codigoExternoProductoCOPS;
                String[] codExternoProductoCOPS;
                Integer numProductoCOPS = 0;
                String codigoExternoMotivoCOPS;
                String[] codExternoMotivoCOPS;
                Integer numMotivoCOPS = 0;
                String codigoExternoCausaCOPS;
                String[] codExternoCausaCOPS;
                Integer numCausaCOPS = 0;
                String codigoExternoSolucionCOPS;
                String[] codExternoSolucionCOPS;
                Integer numSolucionCOPS = 0;
			
			if(mccCOPS){
				
				String clienteCOPS = 'COPS';
				List<CC_MCC__c> codigosExternosTematicaCOPS = getMCCS(recordTypeIdTematica, clienteCOPS);
				List<CC_MCC__c> codigosExternosProductoCOPS = getMCCS(recordTypeIdProducto, clienteCOPS);
				List<CC_MCC__c> codigosExternosMotivoCOPS = getMCCS(recordTypeIdMotivo, clienteCOPS);
				List<CC_MCC__c> codigosExternosCausaCOPS = getMCCS(recordTypeIdCausa, clienteCOPS);
				List<CC_MCC__c> codigosExternosSolucionCOPS = getMCCS(recordTypeIdSolucion, clienteCOPS);
				
				//TEMÁTICAS
				if (!codigosExternosTematicaCOPS.isEmpty()){
					codigoExternoTematicaCOPS = codigosExternosTematicaCOPS.get(0).CC_Codigo_Externo__c;
					if(codigoExternoTematicaCOPS.contains('-')){
						codExternoTematicaCOPS = codigoExternoTematicaCOPS.split('-');
						if(codExternoTematicaCOPS[1].isNumeric()){
							numTematicaCOPS = Integer.ValueOf(codExternoTematicaCOPS[1]);
						}
					}
				}
				//PRODUCTOS
				if(!codigosExternosProductoCOPS.isEmpty()){
					codigoExternoProductoCOPS = codigosExternosProductoCOPS.get(0).CC_Codigo_Externo__c;
					if(codigoExternoProductoCOPS.contains('-')){
						codExternoProductoCOPS = codigoExternoProductoCOPS.split('-');
						if(codExternoProductoCOPS[1].isNumeric()){
							numProductoCOPS = Integer.ValueOf(codExternoProductoCOPS[1]);
						}
					}
				}
				//MOTIVOS
				if(!codigosExternosMotivoCOPS.isEmpty()){
					codigoExternoMotivoCOPS = codigosExternosMotivoCOPS.get(0).CC_Codigo_Externo__c;
					if(codigoExternoMotivoCOPS.contains('-')){
						codExternoMotivoCOPS = codigoExternoMotivoCOPS.split('-');
						if(codExternoMotivoCOPS[1].isNumeric()){
							numMotivoCOPS = Integer.ValueOf(codExternoMotivoCOPS[1]);
						}
					}
				}
				//CAUSA
				if(!codigosExternosCausaCOPS.isEmpty()){
					codigoExternoCausaCOPS = codigosExternosCausaCOPS.get(0).CC_Codigo_Externo__c;
					if(codigoExternoCausaCOPS.contains('-')){
						codExternoCausaCOPS = codigoExternoCausaCOPS.split('-');
						if(codExternoCausaCOPS[1].isNumeric()){
							numCausaCOPS = Integer.ValueOf(codExternoCausaCOPS[1]);
						}
					}
				}
				//SOLUCIÓN
				if(!codigosExternosSolucionCOPS.isEmpty()){
					codigoExternoSolucionCOPS = codigosExternosSolucionCOPS.get(0).CC_Codigo_Externo__c;
					if(codigoExternoSolucionCOPS.contains('-')){
						codExternoSolucionCOPS = codigoExternoSolucionCOPS.split('-');
						if(codExternoSolucionCOPS[1].isNumeric()){
							numSolucionCOPS = Integer.ValueOf(codExternoSolucionCOPS[1]);
						}
					}
				}
				
			}
			
			String codigoExternoTematicaCSI;
			String[] codExternoTematicaCSI;
                Integer numTematicaCSI = 0;
                String codigoExternoProductoCSI;
                String[] codExternoProductoCSI;
                Integer numProductoCSI = 0;
                String codigoExternoMotivoCSI;
                String[] codExternoMotivoCSI;
                Integer numMotivoCSI = 0;
                String codigoExternoCausaCSI;
                String[] codExternoCausaCSI;
                Integer numCausaCSI = 0;
                String codigoExternoSolucionCSI;
                String[] codExternoSolucionCSI;
                Integer numSolucionCSI = 0;
			
			
			if(mccCSI){
				String clienteCSI = 'CSI';
				List<CC_MCC__c> codigosExternosTematicaCSI = getMCCS(recordTypeIdTematica, clienteCSI);
				List<CC_MCC__c> codigosExternosProductoCSI = getMCCS(recordTypeIdProducto, clienteCSI);
				List<CC_MCC__c> codigosExternosMotivoCSI = getMCCS(recordTypeIdMotivo, clienteCSI);
				List<CC_MCC__c> codigosExternosCausaCSI = getMCCS(recordTypeIdCausa, clienteCSI);
				List<CC_MCC__c> codigosExternosSolucionCSI = getMCCS(recordTypeIdSolucion, clienteCSI);
				
				//TEMÁTICAS
				if (!codigosExternosTematicaCSI.isEmpty()){
					codigoExternoTematicaCSI = codigosExternosTematicaCSI.get(0).CC_Codigo_Externo__c;
					if(codigoExternoTematicaCSI.contains('-')){
						codExternoTematicaCSI = codigoExternoTematicaCSI.split('-');
						if(codExternoTematicaCSI[1].isNumeric()){
							numTematicaCSI = Integer.ValueOf(codExternoTematicaCSI[1]);
						}
					}
				}
				//PRODUCTOS
				if(!codigosExternosProductoCSI.isEmpty()){
					codigoExternoProductoCSI = codigosExternosProductoCSI.get(0).CC_Codigo_Externo__c;
					if(codigoExternoProductoCSI.contains('-')){
						codExternoProductoCSI = codigoExternoProductoCSI.split('-');
						if(codExternoProductoCSI[1].isNumeric()){
							numProductoCSI = Integer.ValueOf(codExternoProductoCSI[1]);
						}
					}
				}
				//MOTIVOS
				if(!codigosExternosMotivoCSI.isEmpty()){
					codigoExternoMotivoCSI = codigosExternosMotivoCSI.get(0).CC_Codigo_Externo__c;
					if(codigoExternoMotivoCSI.contains('-')){
						codExternoMotivoCSI = codigoExternoMotivoCSI.split('-');
						if(codExternoMotivoCSI[1].isNumeric()){
							numMotivoCSI = Integer.ValueOf(codExternoMotivoCSI[1]);
						}
					}
				}
				//CAUSA
				if(!codigosExternosCausaCSI.isEmpty()){
					codigoExternoCausaCSI = codigosExternosCausaCSI.get(0).CC_Codigo_Externo__c;
					if(codigoExternoCausaCSI.contains('-')){
						codExternoCausaCSI = codigoExternoCausaCSI.split('-');
						if(codExternoCausaCSI[1].isNumeric()){
							numCausaCSI = Integer.ValueOf(codExternoCausaCSI[1]);
						}
					}
				}
				//SOLUCIÓN
				if(!codigosExternosSolucionCSI.isEmpty()){
					codigoExternoSolucionCSI = codigosExternosSolucionCSI.get(0).CC_Codigo_Externo__c;
					if(codigoExternoSolucionCSI.contains('-')){
						codExternoSolucionCSI = codigoExternoSolucionCSI.split('-');
						if(codExternoSolucionCSI[1].isNumeric()){
							numSolucionCSI = Integer.ValueOf(codExternoSolucionCSI[1]);
						}
					}
				}
			}
			
			String codigoExternoTematicaCAM;
			String[] codExternoTematicaCAM;
                Integer numTematicaCAM = 0;
                String codigoExternoProductoCAM;
                String[] codExternoProductoCAM;
                Integer numProductoCAM = 0;
                String codigoExternoMotivoCAM;
                String[] codExternoMotivoCAM;
                Integer numMotivoCAM = 0;
                String codigoExternoCausaCAM;
                String[] codExternoCausaCAM;
                Integer numCausaCAM = 0;
			String codigoExternoSolucionCAM;
			String[] codExternoSolucionCAM;
                Integer numSolucionCAM = 0;
			
			if(mccCAM){
				
				String clienteCAM = 'CAM';
				List<CC_MCC__c> codigosExternosTematicaCAM = getMCCS(recordTypeIdTematica, clienteCAM);
				List<CC_MCC__c> codigosExternosProductoCAM = getMCCS(recordTypeIdProducto, clienteCAM);
				List<CC_MCC__c> codigosExternosMotivoCAM = getMCCS(recordTypeIdMotivo, clienteCAM);
				List<CC_MCC__c> codigosExternosCausaCAM = getMCCS(recordTypeIdCausa, clienteCAM);
				List<CC_MCC__c> codigosExternosSolucionCAM = getMCCS(recordTypeIdSolucion, clienteCAM);
				
				//TEMÁTICAS
				if (!codigosExternosTematicaCAM.isEmpty()){
					codigoExternoTematicaCAM = codigosExternosTematicaCAM.get(0).CC_Codigo_Externo__c;
					if(codigoExternoTematicaCAM.contains('-')){
						codExternoTematicaCAM= codigoExternoTematicaCAM.split('-');
						if(codExternoTematicaCAM[1].isNumeric()){
							numTematicaCAM = Integer.ValueOf(codExternoTematicaCAM[1]);
						}
					}
				}
				//PRODUCTOS
				if(!codigosExternosProductoCAM.isEmpty()){
					codigoExternoProductoCAM = codigosExternosProductoCAM.get(0).CC_Codigo_Externo__c;
					if(codigoExternoProductoCAM.contains('-')){
						codExternoProductoCAM = codigoExternoProductoCAM.split('-');
						if(codExternoProductoCAM[1].isNumeric()){
							numProductoCAM = Integer.ValueOf(codExternoProductoCAM[1]);
						}
					}
				}
				//MOTIVOS
				if(!codigosExternosMotivoCAM.isEmpty()){
					codigoExternoMotivoCAM = codigosExternosMotivoCAM.get(0).CC_Codigo_Externo__c;
					if(codigoExternoMotivoCAM.contains('-')){
						codExternoMotivoCAM = codigoExternoMotivoCAM.split('-');
						if(codExternoMotivoCAM[1].isNumeric()){
							numMotivoCAM = Integer.ValueOf(codExternoMotivoCAM[1]);
						}
					}
				}
				//CAUSA
				if(!codigosExternosCausaCAM.isEmpty()){
					codigoExternoCausaCAM = codigosExternosCausaCAM.get(0).CC_Codigo_Externo__c;
					if(codigoExternoCausaCAM.contains('-')){
						codExternoCausaCAM = codigoExternoCausaCAM.split('-');
						if(codExternoCausaCAM[1].isNumeric()){
							numCausaCAM = Integer.ValueOf(codExternoCausaCAM[1]);
						}
					}
				}
				//SOLUCIÓN
				if(!codigosExternosSolucionCAM.isEmpty()){
					codigoExternoSolucionCAM = codigosExternosSolucionCAM.get(0).CC_Codigo_Externo__c;
					if(codigoExternoSolucionCAM.contains('-')){
						codExternoSolucionCAM = codigoExternoSolucionCAM.split('-');
						if(codExternoSolucionCAM[1].isNumeric()){
							numSolucionCAM = Integer.ValueOf(codExternoSolucionCAM[1]);
						}
					}
				}
				
			}
			//
			String codigoExternoTematicaSACH;
			List<String> codExternoTematicaSACH;
                Integer numTematicaSACH = 0;
                String codigoExternoProductoSACH;
                List<String> codExternoProductoSACH;
                Integer numProductoSACH = 0;
                String codigoExternoMotivoSACH;
                List<String> codExternoMotivoSACH;
                Integer numMotivoSACH = 0;
                String codigoExternoCausaSACH;
                List<String> codExternoCausaSACH;
                Integer numCausaSACH = 0;
                String codigoExternoSolucionSACH;
                List<String> codExternoSolucionSACH;
                Integer numSolucionSACH = 0;
			
			if (mccSACH) {
				String clienteSACH = 'SACH';
				List<CC_MCC__c> codigosExternosTematicaSACH = getMCCS(recordTypeIdTematica, clienteSACH);
				List<CC_MCC__c> codigosExternosProductoSACH = getMCCS(recordTypeIdProducto, clienteSACH);
				List<CC_MCC__c> codigosExternosMotivoSACH = getMCCS(recordTypeIdMotivo, clienteSACH);
				List<CC_MCC__c> codigosExternosCausaSACH = getMCCS(recordTypeIdCausa, clienteSACH);
				List<CC_MCC__c> codigosExternosSolucionSACH = getMCCS(recordTypeIdSolucion, clienteSACH);
				
				//TEMÁTICAS
				if (!codigosExternosTematicaSACH.isEmpty()){
					codigoExternoTematicaSACH = codigosExternosTematicaSACH.get(0).CC_Codigo_Externo__c;
					if(codigoExternoTematicaSACH.contains('-')){
						codExternoTematicaSACH= codigoExternoTematicaSACH.split('-');
						if(codExternoTematicaSACH[1].isNumeric()){
							numTematicaSACH = Integer.ValueOf(codExternoTematicaSACH[1]);
						}
					}
				}
				//PRODUCTOS
				if(!codigosExternosProductoSACH.isEmpty()){
					codigoExternoProductoSACH = codigosExternosProductoSACH.get(0).CC_Codigo_Externo__c;
					if(codigoExternoProductoSACH.contains('-')){
						codExternoProductoSACH = codigoExternoProductoSACH.split('-');
						if(codExternoProductoSACH[1].isNumeric()){
							numProductoSACH = Integer.ValueOf(codExternoProductoSACH[1]);
						}
					}
				}
				//MOTIVOS
				if(!codigosExternosMotivoSACH.isEmpty()){
					codigoExternoMotivoSACH = codigosExternosMotivoSACH.get(0).CC_Codigo_Externo__c;
					if(codigoExternoMotivoSACH.contains('-')){
						codExternoMotivoSACH = codigoExternoMotivoSACH.split('-');
						if(codExternoMotivoSACH[1].isNumeric()){
							numMotivoSACH = Integer.ValueOf(codExternoMotivoSACH[1]);
						}
					}
				}
				//CAUSA
				if(!codigosExternosCausaSACH.isEmpty()){
					codigoExternoCausaSACH = codigosExternosCausaSACH.get(0).CC_Codigo_Externo__c;
					if(codigoExternoCausaSACH.contains('-')){
						codExternoCausaSACH = codigoExternoCausaSACH.split('-');
						if(codExternoCausaSACH[1].isNumeric()){
							numCausaSACH = Integer.ValueOf(codExternoCausaSACH[1]);
						}
					}
				}
				//SOLUCIÓN
				if(!codigosExternosSolucionSACH.isEmpty()){
					codigoExternoSolucionSACH = codigosExternosSolucionSACH.get(0).CC_Codigo_Externo__c;
					if(codigoExternoSolucionSACH.contains('-')){
						codExternoSolucionSACH = codigoExternoSolucionSACH.split('-');
						if(codExternoSolucionSACH[1].isNumeric()){
							numSolucionSACH = Integer.ValueOf(codExternoSolucionSACH[1]);
						}
					}
				}
				
			}

			String codigoExternoTematicaHDT;
			String[] codExternoTematicaHDT;
                Integer numTematicaHDT = 0;
                String codigoExternoProductoHDT;
                String[] codExternoProductoHDT;
                Integer numProductoHDT = 0;
                String codigoExternoMotivoHDT;
                String[] codExternoMotivoHDT;
                Integer numMotivoHDT = 0;
                String codigoExternoCausaHDT;
                String[] codExternoCausaHDT;
                Integer numCausaHDT = 0;
			String codigoExternoSolucionHDT;
			String[] codExternoSolucionHDT;
                Integer numSolucionHDT = 0;
			
			if(mccHDT){
				
				String clienteHDT = 'HDT';
				List<CC_MCC__c> codigosExternosTematicaHDT = getMCCS(recordTypeIdTematica, clienteHDT);
				List<CC_MCC__c> codigosExternosProductoHDT = getMCCS(recordTypeIdProducto, clienteHDT);
				List<CC_MCC__c> codigosExternosMotivoHDT = getMCCS(recordTypeIdMotivo, clienteHDT);
				List<CC_MCC__c> codigosExternosCausaHDT = getMCCS(recordTypeIdCausa, clienteHDT);
				List<CC_MCC__c> codigosExternosSolucionHDT = getMCCS(recordTypeIdSolucion, clienteHDT);
				
				//TEMÁTICAS
				if (!codigosExternosTematicaHDT.isEmpty()){
					codigoExternoTematicaHDT = codigosExternosTematicaHDT.get(0).CC_Codigo_Externo__c;
					if(codigoExternoTematicaHDT.contains('-')){
						codExternoTematicaHDT= codigoExternoTematicaHDT.split('-');
						if(codExternoTematicaHDT[1].isNumeric()){
							numTematicaHDT = Integer.ValueOf(codExternoTematicaHDT[1]);
						}
					}
				}
				//PRODUCTOS
				if(!codigosExternosProductoHDT.isEmpty()){
					codigoExternoProductoHDT = codigosExternosProductoHDT.get(0).CC_Codigo_Externo__c;
					if(codigoExternoProductoHDT.contains('-')){
						codExternoProductoHDT = codigoExternoProductoHDT.split('-');
						if(codExternoProductoHDT[1].isNumeric()){
							numProductoHDT = Integer.ValueOf(codExternoProductoHDT[1]);
						}
					}
				}
				//MOTIVOS
				if(!codigosExternosMotivoHDT.isEmpty()){
					codigoExternoMotivoHDT = codigosExternosMotivoHDT.get(0).CC_Codigo_Externo__c;
					if(codigoExternoMotivoHDT.contains('-')){
						codExternoMotivoHDT = codigoExternoMotivoHDT.split('-');
						if(codExternoMotivoHDT[1].isNumeric()){
							numMotivoHDT = Integer.ValueOf(codExternoMotivoHDT[1]);
						}
					}
				}
				//CAUSA
				if(!codigosExternosCausaHDT.isEmpty()){
					codigoExternoCausaHDT = codigosExternosCausaHDT.get(0).CC_Codigo_Externo__c;
					if(codigoExternoCausaHDT.contains('-')){
						codExternoCausaHDT = codigoExternoCausaHDT.split('-');
						if(codExternoCausaHDT[1].isNumeric()){
							numCausaHDT = Integer.ValueOf(codExternoCausaHDT[1]);
						}
					}
				}
				//SOLUCIÓN
				if(!codigosExternosSolucionHDT.isEmpty()){
					codigoExternoSolucionHDT = codigosExternosSolucionHDT.get(0).CC_Codigo_Externo__c;
					if(codigoExternoSolucionHDT.contains('-')){
						codExternoSolucionHDT = codigoExternoSolucionHDT.split('-');
						if(codExternoSolucionHDT[1].isNumeric()){
							numSolucionHDT = Integer.ValueOf(codExternoSolucionHDT[1]);
						}
					}
				}
				
			}

			String codigoExternoTematicaFRA;
			String[] codExternoTematicaFRA;
                Integer numTematicaFRA = 0;
                String codigoExternoProductoFRA;
                String[] codExternoProductoFRA;
                Integer numProductoFRA = 0;
                String codigoExternoMotivoFRA;
                String[] codExternoMotivoFRA;
                Integer numMotivoFRA = 0;
                String codigoExternoCausaFRA;
                String[] codExternoCausaFRA;
                Integer numCausaFRA = 0;
			String codigoExternoSolucionFRA;
			String[] codExternoSolucionFRA;
                Integer numSolucionFRA = 0;
			
			if(mccFRA){
				
				String clienteFRA = 'FRA';
				List<CC_MCC__c> codigosExternosTematicaFRA = getMCCS(recordTypeIdTematica, clienteFRA);
				List<CC_MCC__c> codigosExternosProductoFRA = getMCCS(recordTypeIdProducto, clienteFRA);
				List<CC_MCC__c> codigosExternosMotivoFRA = getMCCS(recordTypeIdMotivo, clienteFRA);
				List<CC_MCC__c> codigosExternosCausaFRA = getMCCS(recordTypeIdCausa, clienteFRA);
				List<CC_MCC__c> codigosExternosSolucionFRA = getMCCS(recordTypeIdSolucion, clienteFRA);
				
				//TEMÁTICAS
				if (!codigosExternosTematicaFRA.isEmpty()){
					codigoExternoTematicaFRA = codigosExternosTematicaFRA.get(0).CC_Codigo_Externo__c;
					if(codigoExternoTematicaFRA.contains('-')){
						codExternoTematicaFRA= codigoExternoTematicaFRA.split('-');
						if(codExternoTematicaFRA[1].isNumeric()){
							numTematicaFRA = Integer.ValueOf(codExternoTematicaFRA[1]);
						}
					}
				}
				//PRODUCTOS
				if(!codigosExternosProductoFRA.isEmpty()){
					codigoExternoProductoFRA = codigosExternosProductoFRA.get(0).CC_Codigo_Externo__c;
					if(codigoExternoProductoFRA.contains('-')){
						codExternoProductoFRA = codigoExternoProductoFRA.split('-');
						if(codExternoProductoFRA[1].isNumeric()){
							numProductoFRA = Integer.ValueOf(codExternoProductoFRA[1]);
						}
					}
				}
				//MOTIVOS
				if(!codigosExternosMotivoFRA.isEmpty()){
					codigoExternoMotivoFRA = codigosExternosMotivoFRA.get(0).CC_Codigo_Externo__c;
					if(codigoExternoMotivoFRA.contains('-')){
						codExternoMotivoFRA = codigoExternoMotivoFRA.split('-');
						if(codExternoMotivoFRA[1].isNumeric()){
							numMotivoFRA = Integer.ValueOf(codExternoMotivoFRA[1]);
						}
					}
				}
				//CAUSA
				if(!codigosExternosCausaFRA.isEmpty()){
					codigoExternoCausaFRA = codigosExternosCausaFRA.get(0).CC_Codigo_Externo__c;
					if(codigoExternoCausaFRA.contains('-')){
						codExternoCausaFRA = codigoExternoCausaFRA.split('-');
						if(codExternoCausaFRA[1].isNumeric()){
							numCausaFRA = Integer.ValueOf(codExternoCausaFRA[1]);
						}
					}
				}
				//SOLUCIÓN
				if(!codigosExternosSolucionFRA.isEmpty()){
					codigoExternoSolucionFRA = codigosExternosSolucionFRA.get(0).CC_Codigo_Externo__c;
					if(codigoExternoSolucionFRA.contains('-')){
						codExternoSolucionFRA = codigoExternoSolucionFRA.split('-');
						if(codExternoSolucionFRA[1].isNumeric()){
							numSolucionFRA = Integer.ValueOf(codExternoSolucionFRA[1]);
						}
					}
				}
				
			}
            
            String codigoExternoTematicaGRR;
			String[] codExternoTematicaGRR;
                Integer numTematicaGRR = 0;
                String codigoExternoProductoGRR;
                String[] codExternoProductoGRR;
                Integer numProductoGRR = 0;
                String codigoExternoMotivoGRR;
                String[] codExternoMotivoGRR;
                Integer numMotivoGRR = 0;
                
			
			if(mccGRR){
				
				String clienteGRR = 'GRR';
				List<CC_MCC__c> codigosExternosTematicaGRR = getMCCS(recordTypeIdTematica, clienteGRR);
				List<CC_MCC__c> codigosExternosProductoGRR = getMCCS(recordTypeIdProducto, clienteGRR);
				List<CC_MCC__c> codigosExternosMotivoGRR = getMCCS(recordTypeIdMotivo, clienteGRR);
				List<CC_MCC__c> codigosExternosCausaGRR = getMCCS(recordTypeIdCausa, clienteGRR);
				List<CC_MCC__c> codigosExternosSolucionGRR = getMCCS(recordTypeIdSolucion, clienteGRR);
				
				//TEMÁTICAS
				if (!codigosExternosTematicaGRR.isEmpty()){
					codigoExternoTematicaGRR = codigosExternosTematicaGRR.get(0).CC_Codigo_Externo__c;
					if(codigoExternoTematicaGRR.contains('-')){
						codExternoTematicaGRR= codigoExternoTematicaGRR.split('-');
						if(codExternoTematicaGRR[1].isNumeric()){
							numTematicaGRR = Integer.ValueOf(codExternoTematicaGRR[1]);
						}
					}
				}
				//PRODUCTOS
				if(!codigosExternosProductoGRR.isEmpty()){
					codigoExternoProductoGRR = codigosExternosProductoGRR.get(0).CC_Codigo_Externo__c;
					if(codigoExternoProductoGRR.contains('-')){
						codExternoProductoGRR = codigoExternoProductoGRR.split('-');
						if(codExternoProductoGRR[1].isNumeric()){
							numProductoGRR = Integer.ValueOf(codExternoProductoGRR[1]);
						}
					}
				}
				//MOTIVOS
				if(!codigosExternosMotivoGRR.isEmpty()){
					codigoExternoMotivoGRR = codigosExternosMotivoGRR.get(0).CC_Codigo_Externo__c;
					if(codigoExternoMotivoGRR.contains('-')){
						codExternoMotivoGRR = codigoExternoMotivoGRR.split('-');
						if(codExternoMotivoGRR[1].isNumeric()){
							numMotivoGRR = Integer.ValueOf(codExternoMotivoGRR[1]);
						}
					}
				}
				
			}

			
			for (CC_MCC__c mcc : listMccs) {
				if (mcc.RecordType.DeveloperName == 'CC_Tematica' && mcc.CC_Codigo_Externo__c == null){
					if (mcc.CC_Tipo_Cliente__c == 'Cliente' || mcc.CC_Tipo_Cliente__c == 'Empleado' || mcc.CC_Tipo_Cliente__c == 'Cliente/Empleado' || mcc.CC_Tipo_Cliente__c == 'Prejubilado' || mcc.CC_Tipo_Cliente__c == 'Proveedor / Empleado') {
						numTematicaCC = numTematicaCC+1;
						codigoExternoTematicaCC = String.valueOf(numTematicaCC).leftPad(6, '0');
						codigoExternoTematicaCC = codExternoTematicaCC[0] + '-' +codigoExternoTematicaCC;
						mcc.CC_Codigo_Externo__c = codigoExternoTematicaCC;
					}else if(mcc.CC_Tipo_Cliente__c.contains('COPS')){
						numTematicaCOPS = numTematicaCOPS+1;
						codigoExternoTematicaCOPS = String.valueOf(numTematicaCOPS).leftPad(6, '0');
						codigoExternoTematicaCOPS = codExternoTematicaCOPS[0] + '-' +codigoExternoTematicaCOPS;
						mcc.CC_Codigo_Externo__c = codigoExternoTematicaCOPS;
					}else if(mcc.CC_Tipo_Cliente__c.contains('CSI')){
						numTematicaCSI = numTematicaCSI+1;
						codigoExternoTematicaCSI = String.valueOf(numTematicaCSI).leftPad(6, '0');
						codigoExternoTematicaCSI = codExternoTematicaCSI[0] + '-' +codigoExternoTematicaCSI;
						mcc.CC_Codigo_Externo__c = codigoExternoTematicaCSI;
					}else if(mcc.CC_Tipo_Cliente__c.contains('CAM')){
						numTematicaCAM = numTematicaCAM+1;
						codigoExternoTematicaCAM = String.valueOf(numTematicaCAM).leftPad(6, '0');
						codigoExternoTematicaCAM = codExternoTematicaCAM[0] + '-' +codigoExternoTematicaCAM;
						mcc.CC_Codigo_Externo__c = codigoExternoTematicaCAM;
					}else if(mcc.CC_Tipo_Cliente__c.contains('SACH')){
						numTematicaSACH = numTematicaSACH+1;
						codigoExternoTematicaSACH = String.valueOf(numTematicaSACH).leftPad(6, '0');
						codigoExternoTematicaSACH = codExternoTematicaSACH[0] + '-' +codigoExternoTematicaSACH;
						mcc.CC_Codigo_Externo__c = codigoExternoTematicaSACH;
					}else if(mcc.CC_Tipo_Cliente__c.contains('HDT')){
						system.debug('1 ' + numTematicaHDT);
						numTematicaHDT = numTematicaHDT+1;
						codigoExternoTematicaHDT = String.valueOf(numTematicaHDT).leftPad(6, '0');
						system.debug('2 ' + codigoExternoTematicaHDT);
						codigoExternoTematicaHDT = codExternoTematicaHDT[0] + '-' + codigoExternoTematicaHDT;
						mcc.CC_Codigo_Externo__c = codigoExternoTematicaHDT;
						system.debug('3 ' + codigoExternoTematicaHDT);
					}else if(mcc.CC_Tipo_Cliente__c.contains('FRA')){
						numTematicaFRA = numTematicaFRA+1;
						codigoExternoTematicaFRA = String.valueOf(numTematicaFRA).leftPad(6, '0');
						codigoExternoTematicaFRA = codExternoTematicaFRA[0] + '-' +codigoExternoTematicaFRA;
						mcc.CC_Codigo_Externo__c = codigoExternoTematicaFRA;
					}else if(mcc.CC_Tipo_Cliente__c.contains('GRR')){
						numTematicaGRR = numTematicaGRR+1;
						codigoExternoTematicaGRR = String.valueOf(numTematicaGRR).leftPad(6, '0');
						codigoExternoTematicaGRR = codExternoTematicaGRR[0] + '-' +codigoExternoTematicaGRR;
						mcc.CC_Codigo_Externo__c = codigoExternoTematicaGRR;
					}else{
						numTematica = numTematica+1;
						codigoExternoTematica = String.valueOf(numTematica).leftPad(6, '0');
						codigoExternoTematica = codExternoTematica[0] + '-' +codigoExternoTematica;
						mcc.CC_Codigo_Externo__c = codigoExternoTematica;
					}
				}else if (mcc.RecordType.DeveloperName == 'CC_Producto_Servicio' && mcc.CC_Codigo_Externo__c == null){
					if (mcc.CC_Tipo_Cliente__c == 'Cliente' || mcc.CC_Tipo_Cliente__c == 'Empleado' || mcc.CC_Tipo_Cliente__c == 'Cliente/Empleado' || mcc.CC_Tipo_Cliente__c == 'Prejubilado' || mcc.CC_Tipo_Cliente__c == 'Proveedor / Empleado') {
						numProductoCC = numProductoCC+1;
						codigoExternoProductoCC = String.valueOf(numProductoCC).leftPad(6, '0');
						codigoExternoProductoCC = codExternoProductoCC[0] + '-' +codigoExternoProductoCC;
						mcc.CC_Codigo_Externo__c = codigoExternoProductoCC;
					}else if(mcc.CC_Tipo_Cliente__c.contains('COPS')){
						numProductoCOPS = numProductoCOPS+1;
						codigoExternoProductoCOPS = String.valueOf(numProductoCOPS).leftPad(6, '0');
						codigoExternoProductoCOPS = codExternoProductoCOPS[0] + '-' +codigoExternoProductoCOPS;
						mcc.CC_Codigo_Externo__c = codigoExternoProductoCOPS;
					}else if(mcc.CC_Tipo_Cliente__c.contains('CSI')){
						numProductoCSI = numProductoCSI+1;
						codigoExternoProductoCSI = String.valueOf(numProductoCSI).leftPad(6, '0');
						codigoExternoProductoCSI = codExternoProductoCSI[0] + '-' +codigoExternoProductoCSI;
						mcc.CC_Codigo_Externo__c = codigoExternoProductoCSI;
					}else if(mcc.CC_Tipo_Cliente__c.contains('CAM')){
						numProductoCAM = numProductoCAM+1;
						codigoExternoProductoCAM = String.valueOf(numProductoCAM).leftPad(6, '0');
						codigoExternoProductoCAM = codExternoProductoCAM[0] + '-' +codigoExternoProductoCAM;
						mcc.CC_Codigo_Externo__c = codigoExternoProductoCAM;
					}else if(mcc.CC_Tipo_Cliente__c.contains('SACH')){
						numProductoSACH = numProductoSACH+1;
						codigoExternoProductoSACH = String.valueOf(numProductoSACH).leftPad(6, '0');
						codigoExternoProductoSACH = codExternoProductoSACH[0] + '-' +codigoExternoProductoSACH;
						mcc.CC_Codigo_Externo__c = codigoExternoProductoSACH;
					}else if(mcc.CC_Tipo_Cliente__c.contains('HDT')){
						numProductoHDT = numProductoHDT+1;
						codigoExternoProductoHDT = String.valueOf(numProductoHDT).leftPad(6, '0');
						codigoExternoProductoHDT = codExternoProductoHDT[0] + '-' +codigoExternoProductoHDT;
						mcc.CC_Codigo_Externo__c = codigoExternoProductoHDT;
					}else if(mcc.CC_Tipo_Cliente__c.contains('FRA')){
						numProductoFRA = numProductoFRA+1;
						codigoExternoProductoFRA = String.valueOf(numProductoFRA).leftPad(6, '0');
						codigoExternoProductoFRA = codExternoProductoFRA[0] + '-' +codigoExternoProductoFRA;
						mcc.CC_Codigo_Externo__c = codigoExternoProductoFRA;
					}else if(mcc.CC_Tipo_Cliente__c.contains('GRR')){
						numProductoGRR = numProductoGRR+1;
						codigoExternoProductoGRR = String.valueOf(numProductoGRR).leftPad(6, '0');
						codigoExternoProductoGRR = codExternoProductoGRR[0] + '-' +codigoExternoProductoGRR;
						mcc.CC_Codigo_Externo__c = codigoExternoProductoGRR;
					}else{
						numProducto = numProducto+1;
						codigoExternoProducto = String.valueOf(numProducto).leftPad(6, '0');
						codigoExternoProducto = codExternoProducto[0] + '-' +codigoExternoProducto;
						mcc.CC_Codigo_Externo__c = codigoExternoProducto;
					}
				}else if (mcc.RecordType.DeveloperName == 'CC_Motivo' && mcc.CC_Codigo_Externo__c == null){
					if (mcc.CC_Tipo_Cliente__c == 'Cliente' || mcc.CC_Tipo_Cliente__c == 'Empleado' || mcc.CC_Tipo_Cliente__c == 'Cliente/Empleado' || mcc.CC_Tipo_Cliente__c == 'Prejubilado' || mcc.CC_Tipo_Cliente__c == 'Proveedor / Empleado') {
						System.debug(':::numMotivoCC ' + numMotivoCC);
						System.debug(':::codExternoMotivoCC ' + codExternoMotivoCC);
						System.debug(':::mcc ' + mcc);
						numMotivoCC = numMotivoCC+1;
						codigoExternoMotivoCC = String.valueOf(numMotivoCC).leftPad(6, '0');
						codigoExternoMotivoCC = codExternoMotivoCC[0] + '-' +codigoExternoMotivoCC;
						mcc.CC_Codigo_Externo__c = codigoExternoMotivoCC;
                    }else if(mcc.CC_Tipo_Cliente__c.contains('COPS')){
						numMotivoCOPS = numMotivoCOPS+1;
						codigoExternoMotivoCOPS = String.valueOf(numMotivoCOPS).leftPad(6, '0');
						codigoExternoMotivoCOPS = codExternoMotivoCOPS[0] + '-' +codigoExternoMotivoCOPS;
						mcc.CC_Codigo_Externo__c = codigoExternoMotivoCOPS;
					}else if(mcc.CC_Tipo_Cliente__c.contains('CSI')){
						numMotivoCSI = numMotivoCSI+1;
						codigoExternoMotivoCSI = String.valueOf(numMotivoCSI).leftPad(6, '0');
						codigoExternoMotivoCSI = codExternoMotivoCSI[0] + '-' +codigoExternoMotivoCSI;
						mcc.CC_Codigo_Externo__c = codigoExternoMotivoCSI;
					}else if(mcc.CC_Tipo_Cliente__c.contains('CAM')){
						numMotivoCAM = numMotivoCAM+1;
						codigoExternoMotivoCAM = String.valueOf(numMotivoCAM).leftPad(6, '0');
						codigoExternoMotivoCAM = codExternoMotivoCAM[0] + '-' +codigoExternoMotivoCAM;
						mcc.CC_Codigo_Externo__c = codigoExternoMotivoCAM;
					}else if(mcc.CC_Tipo_Cliente__c.contains('SACH')){
						numMotivoSACH = numMotivoSACH+1;
						codigoExternoMotivoSACH = String.valueOf(numMotivoSACH).leftPad(6, '0');
						codigoExternoMotivoSACH = codExternoMotivoSACH[0] + '-' +codigoExternoMotivoSACH;
						mcc.CC_Codigo_Externo__c = codigoExternoMotivoSACH;
					}else if(mcc.CC_Tipo_Cliente__c.contains('HDT')){
						numMotivoHDT = numMotivoHDT+1;
						codigoExternoMotivoHDT = String.valueOf(numMotivoHDT).leftPad(6, '0');
						codigoExternoMotivoHDT = codExternoMotivoHDT[0] + '-' +codigoExternoMotivoHDT;
						mcc.CC_Codigo_Externo__c = codigoExternoMotivoHDT;
					}else if(mcc.CC_Tipo_Cliente__c.contains('FRA')){
						numMotivoFRA = numMotivoFRA+1;
						codigoExternoMotivoFRA = String.valueOf(numMotivoFRA).leftPad(6, '0');
						codigoExternoMotivoFRA = codExternoMotivoFRA[0] + '-' +codigoExternoMotivoFRA;
						mcc.CC_Codigo_Externo__c = codigoExternoMotivoFRA;
					}else if(mcc.CC_Tipo_Cliente__c.contains('GRR')){
						numMotivoGRR = numMotivoGRR+1;
						codigoExternoMotivoGRR = String.valueOf(numMotivoGRR).leftPad(6, '0');
						codigoExternoMotivoGRR = codExternoMotivoGRR[0] + '-' +codigoExternoMotivoGRR;
						mcc.CC_Codigo_Externo__c = codigoExternoMotivoGRR;
					}else{
						numMotivo = numMotivo+1;
						codigoExternoMotivo = String.valueOf(numMotivo).leftPad(6, '0');
						codigoExternoMotivo = codExternoMotivo[0] + '-' +codigoExternoMotivo;
						mcc.CC_Codigo_Externo__c = codigoExternoMotivo;
					}
				}else if (mcc.RecordType.DeveloperName == 'CC_Causa' && mcc.CC_Codigo_Externo__c == null){
					if (mcc.CC_Tipo_Cliente__c == 'Cliente' || mcc.CC_Tipo_Cliente__c == 'Empleado' || mcc.CC_Tipo_Cliente__c == 'Cliente/Empleado' || mcc.CC_Tipo_Cliente__c == 'Prejubilado' || mcc.CC_Tipo_Cliente__c == 'Proveedor / Empleado') {
						numCausaCC = numCausaCC+1;
						codigoExternoCausaCC = String.valueOf(numCausaCC).leftPad(6, '0');
						codigoExternoCausaCC = codExternoCausaCC[0] + '-' +codigoExternoCausaCC;
						mcc.CC_Codigo_Externo__c = codigoExternoCausaCC;
                    }else if(mcc.CC_Tipo_Cliente__c.contains('COPS')){
						numCausaCOPS = numCausaCOPS+1;
						codigoExternoCausaCOPS = String.valueOf(numCausaCOPS).leftPad(6, '0');
						codigoExternoCausaCOPS = codExternoCausaCOPS[0] + '-' +codigoExternoCausaCOPS;
						mcc.CC_Codigo_Externo__c = codigoExternoCausaCOPS;
					} else if(mcc.CC_Tipo_Cliente__c.contains('CSI')){
						numCausaCSI = numCausaCSI+1;
						codigoExternoCausaCSI = String.valueOf(numCausaCSI).leftPad(6, '0');
						codigoExternoCausaCSI = codExternoCausaCSI[0] + '-' +codigoExternoCausaCSI;
						mcc.CC_Codigo_Externo__c = codigoExternoCausaCSI;
					}else if(mcc.CC_Tipo_Cliente__c.contains('CAM')){
						numCausaCAM = numCausaCAM+1;
						codigoExternoCausaCAM = String.valueOf(numCausaCAM).leftPad(6, '0');
						codigoExternoCausaCAM = codExternoCausaCAM[0] + '-' +codigoExternoCausaCAM;
						mcc.CC_Codigo_Externo__c = codigoExternoCausaCAM;
					}else if(mcc.CC_Tipo_Cliente__c.contains('SACH')){
						numCausaSACH = numCausaSACH+1;
						codigoExternoCausaSACH = String.valueOf(numCausaSACH).leftPad(6, '0');
						codigoExternoCausaSACH = codExternoCausaSACH[0] + '-' +codigoExternoCausaSACH;
						mcc.CC_Codigo_Externo__c = codigoExternoCausaSACH;
					}else if(mcc.CC_Tipo_Cliente__c.contains('HDT')){
						numCausaHDT = numCausaHDT+1;
						codigoExternoCausaHDT = String.valueOf(numCausaHDT).leftPad(6, '0');
						codigoExternoCausaHDT = codExternoCausaHDT[0] + '-' +codigoExternoCausaHDT;
						mcc.CC_Codigo_Externo__c = codigoExternoCausaHDT;
					}else if(mcc.CC_Tipo_Cliente__c.contains('FRA')){
						numCausaFRA = numCausaFRA+1;
						codigoExternoCausaFRA = String.valueOf(numCausaFRA).leftPad(6, '0');
						codigoExternoCausaFRA = codExternoCausaFRA[0] + '-' +codigoExternoCausaFRA;
						mcc.CC_Codigo_Externo__c = codigoExternoCausaFRA;
					}else {
						numCausa = numCausa+1;
						codigoExternoCausa = String.valueOf(numCausa).leftPad(6, '0');
						codigoExternoCausa = codExternoCausa[0] + '-' +codigoExternoCausa;
						mcc.CC_Codigo_Externo__c = codigoExternoCausa;
					}
				}else if (mcc.RecordType.DeveloperName == 'CC_Solucion' && mcc.CC_Codigo_Externo__c == null){
					if (mcc.CC_Tipo_Cliente__c == 'Cliente' || mcc.CC_Tipo_Cliente__c == 'Empleado' || mcc.CC_Tipo_Cliente__c == 'Cliente/Empleado' || mcc.CC_Tipo_Cliente__c == 'Prejubilado' || mcc.CC_Tipo_Cliente__c == 'Proveedor / Empleado') {
						numSolucionCC = numSolucionCC+1;
						codigoExternoSolucionCC = String.valueOf(numSolucionCC).leftPad(6, '0');
						codigoExternoSolucionCC = codExternoSolucionCC[0] + '-' +codigoExternoSolucionCC;
						mcc.CC_Codigo_Externo__c = codigoExternoSolucionCC;
                    }else if(mcc.CC_Tipo_Cliente__c.contains('COPS')){
						numSolucionCOPS = numSolucionCOPS+1;
						codigoExternoSolucionCOPS = String.valueOf(numSolucionCOPS).leftPad(6, '0');
						codigoExternoSolucionCOPS = codExternoSolucionCOPS[0] + '-' +codigoExternoSolucionCOPS;
						mcc.CC_Codigo_Externo__c = codigoExternoSolucionCOPS;
					}else if(mcc.CC_Tipo_Cliente__c.contains('CSI')){
						numSolucionCSI = numSolucionCSI+1;
						codigoExternoSolucionCSI = String.valueOf(numSolucionCSI).leftPad(6, '0');
						codigoExternoSolucionCSI = codExternoSolucionCSI[0] + '-' +codigoExternoSolucionCSI;
						mcc.CC_Codigo_Externo__c = codigoExternoSolucionCSI;
					}else if(mcc.CC_Tipo_Cliente__c.contains('CAM')){
						numSolucionCAM = numSolucionCAM+1;
						codigoExternoSolucionCAM = String.valueOf(numSolucionCAM).leftPad(6, '0');
						codigoExternoSolucionCAM = codExternoSolucionCAM[0] + '-' +codigoExternoSolucionCAM;
						mcc.CC_Codigo_Externo__c = codigoExternoSolucionCAM;
					}else if(mcc.CC_Tipo_Cliente__c.contains('SACH')){
						numSolucionSACH = numSolucionSACH+1;
						codigoExternoSolucionSACH = String.valueOf(numSolucionSACH).leftPad(6, '0');
						codigoExternoSolucionSACH = codExternoSolucionSACH[0] + '-' +codigoExternoSolucionSACH;
						mcc.CC_Codigo_Externo__c = codigoExternoSolucionSACH;
					}else if(mcc.CC_Tipo_Cliente__c.contains('HDT')){
						numSolucionHDT = numSolucionHDT+1;
						codigoExternoSolucionHDT = String.valueOf(numSolucionHDT).leftPad(6, '0');
						codigoExternoSolucionHDT = codExternoSolucionHDT[0] + '-' +codigoExternoSolucionHDT;
						mcc.CC_Codigo_Externo__c = codigoExternoSolucionHDT;
					}else if(mcc.CC_Tipo_Cliente__c.contains('FRA')){
						numSolucionFRA = numSolucionFRA+1;
						codigoExternoSolucionFRA = String.valueOf(numSolucionFRA).leftPad(6, '0');
						codigoExternoSolucionFRA = codExternoSolucionFRA[0] + '-' +codigoExternoSolucionFRA;
						mcc.CC_Codigo_Externo__c = codigoExternoSolucionFRA;
					}else{
						numSolucion = numSolucion+1;
						codigoExternoSolucion = String.valueOf(numSolucion).leftPad(6, '0');
						codigoExternoSolucion = codExternoSolucion[0] + '-' +codigoExternoSolucion;
						mcc.CC_Codigo_Externo__c = codigoExternoSolucion;
					}
				}
				mccsUpdate.add (mcc);
			}
			update mccsUpdate;
			//}
		}
	}
	
	public static Map<String, String> obtenerClasificacionEquivalente (String espacio, String categoria) {
		
		Map<String, String> mapaClasificacionEquivalente = new Map<String, String>();
		
		if (espacio == null) {
			espacio = '';
		}
		if (categoria == null) {
			categoria = '';
		}
		String clasificacionExterna = 'MC-' + espacio + '-' + categoria;
		String recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'Conversion_MCC_Cognitivo');
		List<CC_MCC__c> conversionMccList = [SELECT CC_WebMCCTematica__r.Id, CC_WebMCCProducto__r.Id, CC_Canal_Procedencia_Equivalente__c FROM CC_MCC__c WHERE CC_Activo__c = true AND RecordTypeId = :recordTypeId AND CC_Equivalencia_Formulario__c = :clasificacionExterna AND CC_Tipo_Cliente__c = 'Empleado' LIMIT 1];
		
		if (!conversionMccList.isEmpty()) {
			if (conversionMccList[0].CC_WebMCCTematica__r.Id != null) {
				mapaClasificacionEquivalente.put('Temática', conversionMccList[0].CC_WebMCCTematica__r.Id);
			}
			if (conversionMccList[0].CC_WebMCCProducto__r.Id != null) {
				mapaClasificacionEquivalente.put('Producto', conversionMccList[0].CC_WebMCCProducto__r.Id);
			}
			if (conversionMccList[0].CC_Canal_Procedencia_Equivalente__c != null) {
				mapaClasificacionEquivalente.put('Canal de procedencia', conversionMccList[0].CC_Canal_Procedencia_Equivalente__c);
			}
		}
		
		return mapaClasificacionEquivalente;
	}
	
	public static List<CC_MCC__c> getMCCS(String recordType, String tipoCliente) {
		
		List <CC_MCC__c> lstMCCs = new List <CC_MCC__c>();
		
		lstMCCs = [SELECT CC_Codigo_Externo__c FROM CC_MCC__c WHERE RecordTypeId = :recordType AND CC_Codigo_Externo__c <> null AND CC_Tipo_Cliente__c like :('%'+tipoCliente+'%') ORDER BY CC_Codigo_Externo__c DESC LIMIT 1 ];
		
		return lstMCCs;
	}
    
    public static List<CC_MCC__c> getMCCSCC(String recordType) {
		
		List <CC_MCC__c> lstMCCs = new List <CC_MCC__c>();
		
		lstMCCs = [SELECT CC_Codigo_Externo__c FROM CC_MCC__c WHERE RecordTypeId = :recordType AND CC_Codigo_Externo__c <> null 
                   AND CC_Tipo_Cliente__c IN('Cliente','Empleado','Cliente/Empleado','Prejubilado','Proveedor / Empleado') ORDER BY CC_Codigo_Externo__c DESC LIMIT 1 ];
		
		return lstMCCs;
		
	}
    
}