public with sharing class CSBD_RunTestSuite_Queueable implements Queueable, Database.AllowsCallouts {

	private String modo = 'report'; //Se asigna en el constructor que se pasa como parámetro al System.enqueue()
    //'add' --> añadir clases a la test suite, 'report' --> enviar los resultados

	final static String sandboxName = System.DomainParser.parse(URL.getOrgDomainUrl()).getSandboxName().toUpperCase();
	final static String sandboxUrl = URL.getOrgDomainUrl().toExternalForm();
	private static CSBD_EjecucionProgramadaTests__mdt config;
	private static String testSuiteName;
	private static String accessToken;

	public CSBD_RunTestSuite_Queueable() {
		//Constructor sin parámetros dummy necesario para implementar Queueable
		this.modo = 'report';
	}

	public CSBD_RunTestSuite_Queueable(String modo) {
		//Constructor que se usa y con el que se asigna el modo de ejecución ("add" o "report")
		this.modo = modo ?? 'report';
	}

	public void execute(QueueableContext qc) {
		config = [SELECT CSBD_DEV_ModoDesarrollo__c, CSBD_TestSuiteName__c, CSBD_DEV_TestSuiteName__c, CSBD_PrefijoClases__c,
					CSBD_BuzonSalidaDisplayName__c, CSBD_DestinatariosResultado__c, CSBD_DEV_DestinatariosResultado__c, CSBD_DestinatariosError__c,
					CSBD_CoberturaSoloModificadasHaceNDias__c, CSBD_UmbralCoberturaError__c, CSBD_UmbralCoberturaAviso__c
					FROM CSBD_EjecucionProgramadaTests__mdt WHERE DeveloperName = 'CSBD_Parametros'];
		testSuiteName = config.CSBD_DEV_ModoDesarrollo__c ? config.CSBD_DEV_TestSuiteName__c : config.CSBD_TestSuiteName__c;

		try {
			if (this.modo == 'add') {
				//Añadir clases de test a la suite y reprogramar su ejecución
				addClasesTestSuite();
				CSBD_RunTestSuite_Schedulable.programar('run');

			} else if (this.modo == 'report') {
				//Enviar el correo de resultados

				//Para identificar el resultado del test run (ApexTestRunResult) correspondiente a la ejecución de la test suite se busca un
				//ApexTestRunResult con un número de classesEnqueued que coincida con el número de clases de test de la suite (-2 para dar margen)
				ApexTestRunResult testRun = [SELECT Status, StartTime, TestTime, TestSetupTime,
												ClassesEnqueued, ClassesCompleted, MethodsEnqueued, MethodsCompleted, MethodsFailed
												FROM ApexTestRunResult WHERE Status IN ('Processing', 'Completed', 'Failed', 'Aborted')
												AND Source = NULL AND StartTime > :System.now().addHours(config.CSBD_DEV_ModoDesarrollo__c ? -4 : -1)
												AND ClassesEnqueued > :CSBD_RunTestSuite_Schedulable.getClasesTestEjecutar().size() - 2
												ORDER BY StartTime DESC LIMIT 1] ?? null;
				if (testRun == null) {
					throw new CSBD_CustomException('No se ha encontrado ningún test run reciente para la test suite "' + testSuiteName + '"');
				}

				if (testRun.Status == 'Processing') {
					//La ejecución de la test suite aún no ha finalizado, se reprograma el job para dentro de unos minutos
					Integer clasesPendientes = testRun.ClassesEnqueued - testRun.ClassesCompleted;
					Integer segundos = Integer.valueOf(clasesPendientes * 25); //25 segundos por cada clase de test pendiente
					CSBD_RunTestSuite_Schedulable.programar('report', segundos > 120 ? segundos : 120); //Mínimo 2 minutos
					return;
				}

				if (testRun.Status == 'Completed' || testRun.Status == 'Failed') {
					//La ejecución de la test suite ha finalizado, se envía el correo con los resultados
					ResultadoTestRun resultado = new ResultadoTestRun(testRun);
					resultado.enviarResultados();
				}
			}
		} catch (Exception e) {
			CBK_Log.error(e);
			enviarCorreoError('Error procesando los resultados de la test suite "' + testSuiteName + '" en ' + sandboxName, e);
		}
	}

	private with sharing class ResultadoTestRun {
		public ApexTestRunResult testRun;
		public List<ClaseApex> clasesFail = new List<ClaseApex>();
		public List<ClaseApex> clasesCoberturaBaja = new List<ClaseApex>();
		public Map<String, Integer> outcomeCount = new Map<String, Integer>{
			'Pass' => 0, 'Fail' => 0, 'CompileFail' => 0
		};
		public Map<String, Integer> coberturaCount = new Map<String, Integer>{
			'Ok' => 0, 'Error' => 0, 'Aviso' => 0
		};

		public ResultadoTestRun(ApexTestRunResult testRun) {
			this.testRun = testRun;

			List<ApexTestResult> resultadoMetodos = [SELECT ApexClassId, ApexClass.Name, MethodName, Outcome, RunTime,
														FORMAT(ApexClass.LastModifiedDate), ApexClass.LastModifiedBy.Name, Message, StackTrace
														FROM ApexTestResult WHERE ApexTestRunResultId = :testRun.Id
														AND IsTestSetup = FALSE ORDER BY ApexClass.Name ASC];

			Map<String, List<ApexTestResult>> claseFailMetodos = new Map<String, List<ApexTestResult>>();
			for (ApexTestResult resultadoMetodo : resultadoMetodos) {
				if (!claseFailMetodos.containsKey(resultadoMetodo.ApexClass.Name)) {
					claseFailMetodos.put(resultadoMetodo.ApexClass.Name, new List<ApexTestResult>{resultadoMetodo});
				} else {
					claseFailMetodos.get(resultadoMetodo.ApexClass.Name).add(resultadoMetodo);
				}
				this.outcomeCount.put(resultadoMetodo.Outcome, this.outcomeCount.get(resultadoMetodo.Outcome) + 1);
			}
			for (String clase : claseFailMetodos.keySet()) {
				ClaseApex claseFail = new ClaseApex(claseFailMetodos.get(clase));
				this.clasesFail.add(claseFail);
				outcomeCount = new Map<String, Integer>{
					'Pass' => outcomeCount.get('Pass') + claseFail.outcomeCount.get('Pass'),
					'Fail' => outcomeCount.get('Fail') + claseFail.outcomeCount.get('Fail'),
					'CompileFail' => outcomeCount.get('CompileFail') + claseFail.outcomeCount.get('CompileFail')
				};
			}

			List<CoberturaClase> coberturaClases = getCoberturaClases(resultadoMetodos);
			coberturaClases.sort();

			for (CoberturaClase coberturaClase : coberturaClases) {
				if (coberturaClase.tipo != 'Ok') {
					this.clasesCoberturaBaja.add(new ClaseApex(coberturaClase));
				}
				this.coberturaCount.put(coberturaClase.tipo, this.coberturaCount.get(coberturaClase.tipo) + 1);
			}
		}

		public Messaging.SendEmailResult enviarResultados() {
			String testSuiteName = config.CSBD_DEV_ModoDesarrollo__c ? config.CSBD_DEV_TestSuiteName__c : config.CSBD_TestSuiteName__c;

			if (String.isBlank(config.CSBD_BuzonSalidaDisplayName__c)) {
				throw new CSBD_CustomException('No se ha indicado el buzón de salida para el envío del correo de resultados');
			} else {
				Id idBuzonSalida = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :config.CSBD_BuzonSalidaDisplayName__c LIMIT 1]?.Id;
				if (idBuzonSalida == null) {
					throw new CSBD_CustomException('No se ha encontrado el buzón de salida "' + config.CSBD_BuzonSalidaDisplayName__c + '" para el envío del correo de resultados');
				}

				String destinatarios = config.CSBD_DEV_ModoDesarrollo__c ? config.CSBD_DEV_DestinatariosResultado__c : config.CSBD_DestinatariosResultado__c;
				if (String.isBlank(destinatarios)) {
					throw new CSBD_CustomException('No se han indicado los destinatarios del correo de resultados');
				}

				String body = this.getCorreoResultadosBody(testRun);

				if (config.CSBD_DEV_ModoDesarrollo__c) {
					Messaging.SingleEmailMessage correoPlano = new Messaging.SingleEmailMessage();
					correoPlano.setOrgWideEmailAddressId(idBuzonSalida);
					correoPlano.setToAddresses(destinatarios.split('\n'));
					correoPlano.setSubject('(HTML) Resultado de la test suite "' + testSuiteName + '" en ' + sandboxName);
					correoPlano.setPlainTextBody(body);
					Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{correoPlano});
				}

				Messaging.SingleEmailMessage correoResultado = new Messaging.SingleEmailMessage();
				correoResultado.setOrgWideEmailAddressId(idBuzonSalida);
				correoResultado.setToAddresses(destinatarios.split('\n'));
				correoResultado.setSubject('Resultado de la test suite "' + testSuiteName + '" en ' + sandboxName);
				correoResultado.setHtmlBody(body);
				return Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{correoResultado})[0];
			}
		}

		private String getCorreoResultadosBody(ApexTestRunResult testRun) {
			String testSuiteName = config.CSBD_DEV_ModoDesarrollo__c ? config.CSBD_DEV_TestSuiteName__c : config.CSBD_TestSuiteName__c;
			String body = '<html><body>';
			body += '<div class="contenedor" style="max-width: 100%; margin: 0; padding: 0 10px; font-family: Helvetica, Arial, sans-serif; font-size: 13.8px;">';

			//Cabecera
			body += '<div style="font-size: 14.3px; text-align: center; line-height: 23px;">';
			body += '<div style="margin-top: 6px; font-size: 16px;">';
			body += '<span>Test suite <strong>' + testSuiteName + '</strong> finalizada en <strong>' + sandboxName + '</strong> con estado <strong>' + testRun.Status + '</strong>.</span>';
			body += '</div>';
			body += '<div style="margin-top: 4px; color: #464646; font-size: 13.4px;">';
			body += '<span>Inicio: <strong>' + formatFecha(testRun.StartTime) + '</strong> a las <strong>' + formatHora(testRun.StartTime) + '</strong>.</span>';
			body += '<span style="margin-left: 8px;">' + formatDuracion(testRun.TestTime + testRun.TestSetupTime) + '</span>';
			body += '<span style="margin-left: 8px;">TestRunId: ' + testRun.Id + '.</span>';
			body += '</div>';
			body += '<div style="margin-top: 6px; color: #444444; font-size: 13.6px;">';
			body += '<span>' + testRun.ClassesEnqueued + ' clases con ' + testRun.MethodsEnqueued  + ' tests (';
			body += '<span style="' + outcomeStyle('Pass', true) + '">' + (testRun.MethodsCompleted - testRun.MethodsFailed) + ' Pass</span>';
			body += '<span style="' + outcomeStyle('Fail', true) + '">' + testRun.MethodsFailed + ' Fail</span>';
			body += '<span style="' + outcomeStyle('CompileFail', true) + '">' + (testRun.MethodsEnqueued - testRun.MethodsCompleted) + ' CompileFail</span>';
			body += ') ejecutados.</span>';
			body += '<span style="margin-left: 3px;">Hay ';
			body += '<span style="' + coverageStyle('Error', true) + '">' + this.coberturaCount.get('Error') + ' clases</span>';
			body += ' con cobertura insuficiente.';
			body += '</span>';
			body += '</div></div>';

			//Inicio de la tabla
			body += '<div style="margin-top: 25px; border: solid 1px #c9c9c9; border-radius: 6px; font-size: 15px; overflow: hidden;">';
			body += '<table cellspacing="0" cellpadding="0" style="width: 100%; table-layout: fixed;">';

			//Fila 1: Subtítulos para las columnas
			body += '<tr style="font-size: 14px;">';
			body += '<td colspan="5" style="padding: 7px 9px 7px 15px; vertical-align: center; border-bottom: solid 1px #c9c9c9; background-color: #fbfbfb; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">';
			body += '<span><strong>Clases de test con problemas</strong></span>';
			body += '</td><td colspan="4" style="padding: 7px 9px 7px 15px; vertical-align: center; border-bottom: solid 1px #c9c9c9; background-color: #fbfbfb; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">';
			body += '<span><strong>Clases ';
			if ((config.CSBD_CoberturaSoloModificadasHaceNDias__c ?? 0) > 0) {
				body += 'modificadas en los últimos ' + (config.CSBD_CoberturaSoloModificadasHaceNDias__c ?? 0) + ' días ';
			}
			body += 'con baja cobertura</strong></span>';
			body += '</td></tr>';

			//Columna izquierda (tests con problemas)
			body += '<tr><td colspan="5" style="padding: 0 10px 10px 6px; vertical-align: top; width: 55.56%; overflow: hidden; text-overflow: ellipsis;">';
			body += '<ul style="padding: 0 4px 4px 4px; line-height: 22px; font-size: 13px; list-style: disc inside;">';
			for (ClaseApex claseFail : this.clasesFail) {
				//Clase
				if (claseFail.problema) {
					body += '<li style="margin: 0 0 27px 4px;">';
					body += '<span style="display: inline-block; vertical-align: middle; font-size: 14.4px;"><strong>';
					body += claseFail.name;
					body += '</strong></span>';
					body += enlaceDetalleApexClass('claseFail',claseFail.id);
					if (claseFail.outcomeCount.get('Pass') > 0) {
						body += '<span style="' + outcomeStyle('Pass', false) + '">' + claseFail.outcomeCount.get('Pass') + ' Pass</span>';
					}
					if (claseFail.outcomeCount.get('Fail') > 0) {
						body += '<span style="' + outcomeStyle('Fail', false) + '">' + claseFail.outcomeCount.get('Fail') + ' Fail</span>';
					}
					if (claseFail.outcomeCount.get('CompileFail') > 0) {
						body += '<span style="' + outcomeStyle('CompileFail', false) + '">CompileFail</span>';
					}
					body += '<div style="margin: 2px 0 8px 13px; font-size: 11.3px; color: #6a6a6a;">';
					body += 'Clase de test modificada el <strong>' + formatFecha(claseFail.lastModifiedDate) + '</strong> a las <strong>' + formatHora(claseFail.lastModifiedDate) + '</strong>';
					body += ' por <strong>' + claseFail.lastModifiedByName + '</strong>.';
					body += '</div>';

					//Métodos de la clase
					for (MetodoApex metodo : claseFail.metodos) {
						if (metodo.problema) {
							body += '<div style="margin: 0 0 19px 35px; padding: 7px 19px 10px 12px; border: solid 1px lightgray; border-radius: 6px; background-color: #fdfdfd; white-space: normal;">';
							if (metodo.name != '<compile>') {
								body += '<div>';
								body += '<span style="font-size: 13.1px;">';
								body += '<span style="color: #303030;">' + claseFail.name + '</span>';
								body += '<span style="margin: 0 2px 0 2px;">.</span>';
								body += '<span style="font-size: 13.6px; margin-right: 2px;"><strong>' + metodo.name +'</strong></span>';
								body += '<span style="' + metodo.outcomeStyle + '">' + metodo.outcome + '</span>';
								body += '</span>';
								body += '</div>';
							}
							if (metodo.problema) {
								body += '<div style="margin: 4px 0 0 16px; line-height: 19px; font-size: 11.8px; color: #707070;">';
								body += '<div style="color: #121212; letter-spacing: 0.3px;">Error</div>';
								body += '<div style="margin-left: 12px; line-height: 14px; font-family: \'Courier New\', monospace; font-size: 11px; color: #030303;">' + metodo.mensajeError + '</div>';
								body += '</div>';
								if (String.isNotBlank(metodo.stackTrace)) {
									body += '<div style="margin: 8px 0 0 16px; line-height: 20px; font-size: 11.9px; color: #757575;">';
									body += '<div style="color: #121212; letter-spacing: 0.3px;">Stacktrace</div>';
									body += formatStackTrace(metodo.stackTrace);
									body += '</div>';
								}
							}
						}
						body += '</div>';
					}
				}


				body += '</li>';
			}
			body += '</ul>';

			//Columna derecha (clases con baja cobertura)
			body += '</td><td colspan="4" style="padding: 3px 10px 10px 7px; vertical-align: top; width: 44.44%; overflow: hidden; text-overflow: ellipsis;">';
			body += '<ul style="margin-left: 0; padding-left: 28px; color: #111111;">';

			for (ClaseApex claseCoberturaBaja : this.clasesCoberturaBaja) {
				body += '<li style="padding-left: 2px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">';
				body += '<span style="font-size: 14px; color: #030303;"><strong>' + claseCoberturaBaja.name + '</strong></span>';
				body += enlaceDetalleApexClass('coberturaBaja', claseCoberturaBaja.id);
				body += '<span style="' + claseCoberturaBaja.coberturaStyle + '"> ' + claseCoberturaBaja.cobertura + '%</span>';
				body += '<div style="margin: 4px 2px 18px 1px; font-size: 11.3px; color: #6a6a6a; white-space: nowrap; ">';
				body += 'Clase modificada el <strong>' + formatFecha(claseCoberturaBaja.lastModifiedDate) + '</strong>';
				body += ' a las <strong>' + formatHora(claseCoberturaBaja.lastModifiedDate) + '</strong> por <strong>' + claseCoberturaBaja.lastModifiedByName + '</strong>.';
				body += '</div>';
				body += '</li>';
			}
			body += '</ul></td>';

			//Fin de la tabla
			body += '</tr></tbody></table></div></div></body></html>';
			return body;
		}

		private List<CoberturaClase> getCoberturaClases(List<ApexTestResult> resultadoMetodos) {
			try {
				Map<String, Object> queryBinds = new Map<String, Object>{
					'lastModifiedDate' => System.now().addDays(Integer.valueOf(-(config.CSBD_CoberturaSoloModificadasHaceNDias__c ?? 0))),
					'prefijoClases' => config.CSBD_PrefijoClases__c + '%',
					'nombreClasesExcluidas' => CSBD_RunTestSuite_Schedulable.getNombreClasesExcluidas()
				};
				String query = 'SELECT Name, LastModifiedDate, LastModifiedBy.Name FROM ApexClass';
				query += ' WHERE Name LIKE :prefijoClases AND Name NOT IN :nombreClasesExcluidas';
				if ((config.CSBD_CoberturaSoloModificadasHaceNDias__c ?? 0) > 0) {
					query += ' AND LastModifiedDate >= :lastModifiedDate';
				}
				Map<Id, ApexClass> clases = new Map<Id, ApexClass>((List<ApexClass>)Database.queryWithBinds(query, queryBinds, AccessLevel.USER_MODE));

				String soql = 'SELECT ApexClassOrTriggerId, ApexClassOrTrigger.Name, NumLinesCovered, NumLinesUncovered';
				soql += ' FROM ApexCodeCoverageAggregate';
				soql += ' WHERE ApexClassOrTriggerId IN (\'' + String.join(clases.keySet(), '\', \'') + '\')';
				soql += ' ORDER BY ApexClassOrTrigger.Name ASC';

				String toolingApiResponse = toolingApiQuery(soql);
				if (String.isBlank(toolingApiResponse)) {
					throw new CSBD_CustomException('Respuesta de Tooling API vacia');

				} else {
					Map<String, Object> apexCodeCoverageAggregates = (Map<String, Object>)JSON.deserializeUntyped(toolingApiResponse);

					List<CoberturaClase> coberturaClases = new List<CoberturaClase>();
					for (Object apexCodeCoverageAggregate : (List<Object>)apexCodeCoverageAggregates.get('records')) {
						Map<String, Object> record = (Map<String, Object>)apexCodeCoverageAggregate;
						ApexClass clase = clases.get(String.valueOf(record.get('ApexClassOrTriggerId')));
						coberturaClases.add(new CoberturaClase(
							String.valueOf(record.get('ApexClassOrTriggerId')),
							Integer.valueOf(record.get('NumLinesCovered')),
							Integer.valueOf(record.get('NumLinesUncovered')),
							clase
						));
					}
					return coberturaClases;
				}

			} catch (Exception e) {
				CBK_Log.error(e);
				throw new CSBD_CustomException(e.getMessage() + ' ' + e.getStackTraceString());
			}
		}

		private String formatFecha(Datetime startTime) {
			return startTime.date().format();
		}

		private String formatHora(Datetime startTime) {
			return startTime.format('HH:mm');
		}

		private String formatDuracion(Integer ms) {
			if (ms == null) {
				return '';
			}
			Decimal minutos = Decimal.valueOf(ms) / 60000;
			return 'Duración: <strong>' + minutos.setScale(0, RoundingMode.FLOOR) + ' min</strong>.';
		}

		private String formatStackTrace(String st) {
			String stackTrace = '<div style="margin: 1px 0 0 12px; font-size: 11.6px; letter-spacing: 0.26px;">';
			stackTrace += st.replaceAll('Class.', '<br/><span style="color: #363636;">').replaceAll(': line ', '</span>: line ');
			return stackTrace.removeStart('<br/>') + '</div>';
		}

		private String enlaceDetalleApexClass(String tipo, String idClase) {
			final String img = '<img style="width: 16px; height: 16px; vertical-align: ' + (tipo == 'claseFail' ? 'sub' : 'text-top') + ';" alt="Ver en Salesforce" src="' + iconoBase64 + '" />';
			return '<a href="' + URL.getOrgDomainUrl().toExternalForm() + '/' + idClase + '" target="_blank" style="margin: 0 7px; cursor: pointer;">' + img + '</a>';
		}
	}

	private class ClaseApex {
		public Id id;
		public String name;
		public Datetime lastModifiedDate;
		public String lastModifiedByName;
		public String outcome;
		public String outcomeStyle;
		public Decimal cobertura;
		public String coberturaStyle;
		public List<MetodoApex> metodos;
		public Map<String, Integer> outcomeCount = new Map<String, Integer>{
			'Pass' => 0, 'Fail' => 0, 'CompileFail' => 0
		};
		public Boolean problema = false;

		public ClaseApex(List<ApexTestResult> resultadoMetodos) {
			this.id = resultadoMetodos[0].ApexClassId;
			this.name = resultadoMetodos[0].ApexClass.Name;
			this.lastModifiedDate = resultadoMetodos[0].ApexClass.LastModifiedDate;
			this.lastModifiedByName = resultadoMetodos[0].ApexClass.LastModifiedBy.Name;
			// this.outcome = resultadoMetodos[0].Outcome;
			// this.outcomeStyle = outcomeStyle(this.outcome);

			this.metodos = new List<MetodoApex>();
			for (ApexTestResult resultadoMetodo : resultadoMetodos) {
				MetodoApex metodo = new MetodoApex(resultadoMetodo);
				this.metodos.add(metodo);
				this.problema = this.problema || metodo.problema;
				this.outcomeCount.put(metodo.outcome, this.outcomeCount.get(metodo.outcome) + 1);
			}
		}

		public ClaseApex(CoberturaClase coberturaClase) {
			this.id = coberturaClase.id;
			this.name = coberturaClase.name;
			this.lastModifiedDate = coberturaClase.lastModifiedDate;
			this.lastModifiedByName = coberturaClase.lastModifiedByName;
			this.cobertura = coberturaClase.valor;
			this.coberturaStyle = coverageStyle(coberturaClase.tipo, false);
		}
	}

	private class MetodoApex {
		public String name;
		public String outcome;
		public Boolean problema = false;
		public String outcomeStyle;
		public Integer duracion;
		public String mensajeError;
		public String stackTrace;

		public MetodoApex(ApexTestResult resultadoMetodo) {
			this.name = resultadoMetodo.MethodName;
			this.problema = resultadoMetodo.Outcome == 'Fail' || resultadoMetodo.Outcome == 'CompileFail';
			this.outcome = resultadoMetodo.Outcome;
			this.outcomeStyle = CSBD_RunTestSuite_Queueable.outcomeStyle(this.outcome, false);
			this.duracion = resultadoMetodo.RunTime;
			this.mensajeError = formatMessage(resultadoMetodo);
			this.stackTrace = resultadoMetodo.StackTrace;
		}

		private String formatMessage(ApexTestResult resultadoMetodo) {
			if (resultadoMetodo.Outcome == 'Fail') {
				Matcher exceptionMatcher = Pattern.compile('(System\\.[^:]+Exception)').matcher(resultadoMetodo.message);
				if (exceptionMatcher.find()) {
					String exceptionType = exceptionMatcher.group(1);
					String highlightedExceptionType = '<span style="color: #e40d0d;"><strong>' + exceptionType + '</strong></span>';
					String highlightedMessage = resultadoMetodo.message.replace(exceptionType, highlightedExceptionType);
					return highlightedMessage;
				}

			} else if (resultadoMetodo.Outcome == 'CompileFail') {
				Matcher classMatcher = Pattern.compile('Class (\\w+)').matcher(resultadoMetodo.message);
				if (classMatcher.find()) {
					String className = classMatcher.group(1);
					return resultadoMetodo.message.replace(className, '<span style="color: #502df8;"><strong>' + className + '</strong></span>');
				}
			}
			return resultadoMetodo.message;
		}
	}

	private class CoberturaClase implements Comparable {
		public Id id;
		public String name;
		public Datetime lastModifiedDate;
		public String lastModifiedByName;
		public Integer valor;
		public String tipo = 'Ok';

		public CoberturaClase(String id, Integer numLinesCovered, Integer numLinesUncovered, ApexClass clase) {
			this.id = id;
			this.name = clase.Name;
			this.lastModifiedDate = clase.LastModifiedDate;
			this.lastModifiedByName = clase.LastModifiedBy.Name;

			Integer numCovered = numLinesCovered ?? 0;
			Integer numUncovered = numLinesUncovered ?? 0;
			Integer totalLines = numCovered + numUncovered;
			this.valor = totalLines == 0 ? 0 : 100 * numCovered / totalLines;
			if (this.valor <= config.CSBD_UmbralCoberturaError__c) {
				this.tipo = 'Error';
			} else if (this.valor <= config.CSBD_UmbralCoberturaAviso__c) {
				this.tipo = 'Aviso';
			}
		}

		public Integer compareTo(Object compareTo) {
			CoberturaClase coberturaClase = (CoberturaClase)compareTo;
			if (this.tipo == 'Error' && coberturaClase.tipo != 'Error') {
				return -1;
			} else if (this.tipo != 'Error' && coberturaClase.tipo == 'Error') {
				return 1;
			} else if (this.tipo == 'Ok' && coberturaClase.tipo == 'Aviso') {
				return 1;
			} else if (this.tipo == 'Aviso' && coberturaClase.tipo == 'Ok') {
				return -1;
			}
			return this.valor - coberturaClase.valor; //Si el tipo es el mismo compara por cobertura
		}
	}

	private static String toolingApiQuery(String query) {
		try {
			HttpRequest request = new HttpRequest();
			request.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/data/v61.0/tooling/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8'));
			request.setMethod('GET');
			request.setHeader('Content-Type', 'application/json');
			request.setHeader('Authorization', 'Bearer ' + accessToken()); //NOPMD
			HttpResponse response = new Http().send(request);
			if (response.getStatusCode() == 200) {
				return response.getBody();
			} else {
				String mensajeError = 'Error: ' + response.getStatusCode() + ' - ' + response.getBody();
				CBK_Log.error(mensajeError);
				throw new CSBD_CustomException(mensajeError);
			}
		} catch (Exception e) {
			CBK_Log.error(e);
			throw new CSBD_CustomException(e.getMessage() + ' ' + e.getStackTraceString());
		}
	}

	private static String toolingApiPost(String body) {
		try {
			HttpRequest request = new HttpRequest();
			request.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/data/v61.0/tooling/composite');
			request.setMethod('POST');
			request.setHeader('Content-Type', 'application/json');
			request.setHeader('Authorization', 'Bearer ' + accessToken()); //NOPMD
			request.setBody(body);
			HttpResponse response = new Http().send(request);
			if (response.getStatusCode() == 200) {
				return response.getBody();
			} else {
				String mensajeError = 'Error: ' + response.getStatusCode() + ' - ' + response.getBody();
				CBK_Log.error(mensajeError);
				throw new CSBD_CustomException(mensajeError);
			}
		} catch (Exception e) {
			CBK_Log.error(e);
			throw new CSBD_CustomException(e.getMessage() + ' ' + e.getStackTraceString());
		}
	}

	private static String accessToken() {
		if (String.isNotBlank(accessToken)) {
			return accessToken;
		} else {
			try {
				CSBD_EjecucionProgramadaTests__mdt config = [SELECT CSBD_ClientId__c, CSBD_ClientSecret__c, CSBD_Username__c, CSBD_Password__c
																FROM CSBD_EjecucionProgramadaTests__mdt WHERE DeveloperName = 'CSBD_Parametros'];

				String endpoint = 'https://test.salesforce.com/services/oauth2/token?grant_type=password';
				endpoint += '&client_id=' + config.CSBD_ClientId__c + '&client_secret=' + config.CSBD_ClientSecret__c;
				endpoint += '&username=' + config.CSBD_Username__c + '&password=' + config.CSBD_Password__c;

				HttpRequest request = new HttpRequest();
				request.setEndpoint(endpoint);
				request.setMethod('POST');
				request.setHeader('Content-Type', 'application/json');
				HttpResponse response = new Http().send(request);
				if (response.getStatusCode() == 200) {
					Map<String, Object> responseObj = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
					return String.valueOf(responseObj.get('access_token'));
				} else {
					String mensajeError = 'Error: ' + response.getStatusCode() + ' - ' + response.getBody();
					CBK_Log.error(mensajeError);
					throw new CSBD_CustomException(mensajeError);
				}
			} catch (Exception e) {
				throw new CSBD_CustomException(e.getMessage() + ' ' + e.getStackTraceString());
			}
		}
	}

	private void enviarCorreoError(String subject, Exception e) {
		String formattedDate = System.now().format('yyyy-MM-dd HH:mm:ss');

		Messaging.SingleEmailMessage correoError = new Messaging.SingleEmailMessage();
		correoError.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE DisplayName LIKE 'CSBD%' LIMIT 1].Id);
		correoError.setToAddresses(config.CSBD_DestinatariosError__c.split('\n'));
		correoError.setSubject(subject);
		correoError.setHtmlBody(formattedDate + ': <strong>' + e.getMessage() + '</strong><br/><br/>' + e.getStackTraceString());
		Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{correoError});
	}

	private List<String> getClasesExcluidas() {
		List<String> clasesExcluidas = config.CSBD_ClasesExcluidas__c.split('\n');
		for (String claseExcluida : clasesExcluidas) {
			claseExcluida = claseExcluida.trim();
		}
		return clasesExcluidas;
	}

	private void addClasesTestSuite() {
		Id idTestSuite = [SELECT Id FROM ApexTestSuite WHERE TestSuiteName = :testSuiteName LIMIT 1].Id;

		//Buscar las clases que tienen el prefijo indicado y no pertenecen ya a la test suite
		List<ApexClass> clases = [SELECT Body FROM ApexClass WHERE Name LIKE :config.CSBD_PrefijoClases__c + '%'
									AND Name NOT IN :CSBD_RunTestSuite_Schedulable.getNombreClasesExcluidas()
									AND Id NOT IN (SELECT ApexClassId FROM TestSuiteMembership WHERE ApexTestSuiteId = :idTestSuite)];

		if (!clases.isEmpty()) {
			//Si son clases de test se añaden a la test suite
			List<ApexClass> clasesTest = new List<ApexClass>();
			for (Integer i = 0; i < clases.size() && clasesTest.size() < 25; i++) { //La tooling API no permite más de 25 operaciones en una petición composite
				ApexClass clase = clases[i];
				if (clase.Body.containsIgnoreCase('@istest')) {
					clasesTest.add(clase);
				}
			}
			if (!clasesTest.isEmpty()) {
				List<String> compositeRequests = new List<String>();
				for (ApexClass claseTest : clasesTest) {
					String requestBody = '{"method": "POST", "url": "/services/data/v61.0/tooling/sobjects/TestSuiteMembership",';
					requestBody += '"referenceId": "' + claseTest.Id + '",';
					requestBody += '"body": {"ApexTestSuiteId": "' + idTestSuite + '", "ApexClassId": "' + claseTest.Id + '"}}';
					compositeRequests.add(requestBody);
				}

				toolingApiPost('{"allOrNone": true, "compositeRequest": [' + String.join(compositeRequests, ',') + ']}');
			}
		}
	}

	private static String getToolingApiPostRequestBody(Id idTestSuite, Id idClase) {
		String requestBody = '{"method": "POST", "url": "/services/data/v61.0/tooling/sobjects/TestSuiteMembership",';
		requestBody += '"referenceId": "' + idClase + '",';
		requestBody += '"body": {"ApexTestSuiteId": "' + idTestSuite + '", "ApexClassId": "' + idClase + '"}}';
		return requestBody;
	}

	private static String outcomeStyle(String outcome, Boolean cabecera) {
		String outcomeColor = new Map<String, String>{'Pass' => '#06863a', 'CompileFail' => '#8757ff', 'Fail' => '#db0405'}.get(outcome);
		String outcomeStyle = 'white-space: nowrap; margin-left: ' + (cabecera && outcome == 'Pass' ? '0' : '3px') + '; padding: 2px 7px; ';
		outcomeStyle += 'border: solid 1px ' + outcomeColor + '03; border-radius: 6px; font-size: ' + (cabecera ? '11.8px' : '11.4px') + '; ';
		outcomeStyle += 'background-color: ' + outcomeColor + '21; color: ' + outcomeColor + ';';
		return outcomeStyle;
	}

	private static String coverageStyle(String tipoCobertura, Boolean cabecera) {
		String coverageColor =  new Map<String, String>{'Ok' => '#06863a', 'Error' => '#f76c00', 'Aviso' => '#088ea8'}.get(tipoCobertura);
		String coverageStyle = 'white-space: nowrap; margin-left: ' + (cabecera ? '0' : '2px') + '; padding: 2px 6px; ';
		coverageStyle += 'border: solid 1px ' + coverageColor + '03; border-radius: 6px; font-size: ' + (cabecera ? '11.8px' : '11.4px') + '; ';
		coverageStyle += 'background-color: ' + coverageColor + '22; color: ' + coverageColor + ';';
		return coverageStyle;
	}

	private final static String iconoBase64 = 'data:image/png;base64,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';

	private class CSBD_CustomException extends Exception {}
}