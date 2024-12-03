global class CC_LlamadasIZO_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    private Map<String, Auditoria> auditorias;
    private Set<Id> usuariosMarcados;
    public static Set<Id> usuariosMarcadosPointer;

    private Date diaInicio;
    private Date diaFin;
    private Date mesInicio; 
    private Date mesFin;

    // CONSTANTE: Numero de llamadas que necesita un agente para que se considere como válido para el envío
    public Integer LLAMADAS_TOTALES_POR_AGENTE = 50;

    global CC_LlamadasIZO_Batch(Integer year, Integer month, Integer day) {
        diaInicio = Date.newInstance(year, month, day);
    }

    // Si no se especifica dia entonces se coge el día anterior a la ejecución
    global CC_LlamadasIZO_Batch() {
        diaInicio = null;
    }

    private class Usuario implements Comparable {
        public Id id;
        public List<CC_Llamada__c> llamadasValidas;
        public List<CC_Llamada__c> llamadasMarcadas;
        public Integer llamadasValidasMes;
        public Integer prioridad;

        public Usuario(Id id) {
            this.id = id;
            this.llamadasValidas    = new List<CC_Llamada__c>();
            this.llamadasMarcadas   = new List<CC_Llamada__c>();
            this.llamadasValidasMes = 0;
            this.prioridad = -1;
        }

        public Integer getPrioridad() {
            if (prioridad == -1) {
                if (llamadasMarcadas.size() > 0) {
                    prioridad = Integer.valueOf(llamadasMarcadas[0].CC_Prioridad_IZO__c);
                }
                else {
                    prioridad = 3;
                    if (((User)llamadasValidas[0].Owner).CC_Auditoria_IZO__c){
                        prioridad = 2;

                    } 
                    if (CC_LlamadasIZO_Batch.usuariosMarcadosPointer.contains(id)){
                        prioridad = 1;

                    } 
                }
            }
            return prioridad;
        }

        // Compara los usuarios para ordenarlos por prioridad
        public Integer compareTo(Object compareTo) {
            Usuario usuario = (Usuario)compareTo;
            return this.getPrioridad() - usuario.getPrioridad();
        }
    }
    private class Auditoria implements Comparable{
        public String tipoCliente;
        public String canalProcedencia;
        public Integer llamadasMes;
        public Integer llamadasAgenteMes;
        public Map<Id, Usuario> usuarios;
		
        public Auditoria() {
            usuarios = new Map<Id, Usuario>();
        }

        // Compara las auditorias según el número de agentes validos para la auditoria que contienen
        public Integer compareTo(Object compareTo) {
            Auditoria auditoria = (Auditoria)compareTo;
            return this.usuarios.size() - auditoria.usuarios.size();
        }
    }

    private class ReemplazoUsuario {
        public Usuario usuarioAntiguo;
        public Usuario usuarioNuevo;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        if (Test.isRunningTest()) {
            LLAMADAS_TOTALES_POR_AGENTE = CC_LlamadasIZO_Batch_Test.LLAMADAS_TOTALES_POR_AGENTE;
        }
        
        List<CC_Lista_Valores__c> listaValores = [SELECT CC_Tipo_Cliente_Auditoria__c, CC_Canal_Procedencia_Auditoria__c, CC_Llamadas_Mes_Auditoria__c, CC_Llamadas_Agente_Mes_Auditoria__c FROM CC_Lista_Valores__c WHERE RecordType.DeveloperName = 'CC_Auditoria' ORDER BY Id];
        Set<String> canalesProcedencia = new Set<String>();
        Set<String> tiposCliente = new Set<String>();
        // Inicializamos con las combinaciones de tipo cliente y canal procedencia que necesitamos
        auditorias = new Map<String, Auditoria>();
        for (CC_Lista_Valores__c valor : listaValores) {
            Auditoria auditoria = new Auditoria();
            auditoria.tipoCliente       = valor.CC_Tipo_Cliente_Auditoria__c;
            auditoria.canalProcedencia  = valor.CC_Canal_Procedencia_Auditoria__c;
            auditoria.llamadasMes       = (Integer) valor.CC_Llamadas_Mes_Auditoria__c;
            auditoria.llamadasAgenteMes = (Integer) valor.CC_Llamadas_Agente_Mes_Auditoria__c;
            auditorias.put(auditoria.tipoCliente + '##' + auditoria.canalProcedencia, auditoria);
            String tipoCliente = tipoClienteLlamada(valor.CC_Tipo_Cliente_Auditoria__c);
            tiposCliente.add(tipoCliente);
            canalesProcedencia.add(valor.CC_Canal_Procedencia_Auditoria__c);
        }
        System.debug('auditorias'+auditorias);
        // Calculamos fecha inicio (si no la tenemos, es el dia anterior) y fecha fin
        if (diaInicio == null) {
            diaInicio = Date.today().addDays(-1);
        }
        diaFin = diaInicio.addDays(1);
        // Calculamos fechas inicio y fin para filtrar por mes
        mesInicio = diaInicio.toStartOfMonth();
        mesFin    = mesInicio.addMonths(1).toStartOfMonth();
        // Desmarcar llamadas que hemos ejecutado hoy (por si el batch falla y queremos ejecutarlo dos veces el mismo dia)
        List<CC_Llamada__c> llamadasMarcadasHoy = [SELECT Id, CC_Servicio_Genesys__r.CC_Codigo__c FROM CC_Llamada__c WHERE CC_Auditoria_IZO__c = :diaInicio AND CC_Servicio_Genesys__r.CC_Codigo__c != 'IMAGIN_LEADS'];
        for (CC_Llamada__c llamada : llamadasMarcadasHoy) {
            llamada.CC_Auditoria_IZO__c = null;
        }
        update llamadasMarcadasHoy;

        // Recuperamos las llamadas que ya están marcadas
        List<CC_Llamada__c> llamadasMarcadas =
        [SELECT OwnerId, CC_Prioridad_IZO__c, CC_Servicio_Genesys__r.CC_Tipo_Cliente__c, CC_Servicio_Genesys__r.CC_Canal_Procedencia__c, CC_Servicio_Genesys__r.CC_Codigo__c
        FROM CC_Llamada__c WHERE CC_Auditoria_IZO__c <> null AND CC_Fecha_Inicio__c >= :mesInicio AND CC_Fecha_Inicio__c < :mesFin AND CC_Servicio_Genesys__r.CC_Codigo__c != 'IMAGIN_LEADS'];
        usuariosMarcados = new Set<Id>();
        for (CC_Llamada__c llamada : llamadasMarcadas) {
            Auditoria auditoria = auditorias.get(tipoClienteAuditoria(llamada.CC_Servicio_Genesys__r.CC_Tipo_Cliente__c) + '##' + llamada.CC_Servicio_Genesys__r.CC_Canal_Procedencia__c);
            if (auditoria == null){
                continue;

            } 
            
            Usuario usuario = auditoria.usuarios.get(llamada.OwnerId);
            if (usuario == null) {
                usuario = new Usuario(llamada.OwnerId);
                auditoria.usuarios.put(llamada.OwnerId, usuario);
            }

            usuario.llamadasMarcadas.add(llamada);
            usuariosMarcados.add(llamada.OwnerId);
        }
        for (Auditoria auditoria : auditorias.values()) {
            auditoria.llamadasMes -= auditoria.usuarios.size() * auditoria.llamadasAgenteMes;
        }


        // Llamadas que sean de las empresas COMDATA, MST, MARKTEL, OESIA o DXC
        // Llamadas que sean en castellano o catalan
        return Database.getQueryLocator(
            [SELECT OwnerId, CC_Servicio_Genesys__r.CC_Tipo_Cliente__c, CC_Servicio_Genesys__r.CC_Canal_Procedencia__c, CC_Prioridad_IZO__c, CC_Servicio_Genesys__r.CC_Codigo__c,
            CC_Auditoria_IZO__c, TYPEOF Owner WHEN User THEN CC_Auditoria_IZO__c END, (SELECT Id FROM CC_Llamada_Padre__r)
            FROM CC_Llamada__c
            WHERE CC_Idioma__c IN ('es', 'ca') AND
                  CC_Nombre_Empresa__c IN ('COMDATA', 'MST', 'DXC', 'MARKTEL', 'OESIA') AND
                  CC_Servicio_Genesys__c <> null AND
                  CC_Servicio_Genesys__r.CC_Tipo_Cliente__c IN :tiposCliente AND
                  CC_Servicio_Genesys__r.CC_Canal_Procedencia__c IN :canalesProcedencia AND
                  Owner.IsActive = true AND
                  Owner.Type = 'User' AND
                  CC_Fecha_Inicio__c <> null AND
                  CC_Fecha_Inicio__c >= :diaInicio AND
                  CC_Fecha_Inicio__c <  :diaFin AND
                  CC_Fecha_Fin__c <> null AND
             	  CC_Servicio_Genesys__r.CC_Codigo__c != 'IMAGIN_LEADS' AND
                  CC_Llamada_Padre__c = null]
            );

    }

    global void execute(Database.BatchableContext bc, List<CC_Llamada__c> llamadas) {
        // Recogemos todas las llamadas que tengan un caso asociado
        List<CC_Llamada__c> llamadasActualizar = new List<CC_Llamada__c>();
        for (CC_Llamada__c llamada : llamadas) {
            if (llamada.CC_Llamada_Padre__r == null || llamada.CC_Llamada_Padre__r.size() == 0) {
                String tipoCliente = tipoClienteAuditoria(llamada.CC_Servicio_Genesys__r.CC_Tipo_Cliente__c);
                Auditoria auditoria = auditorias.get(tipoCliente + '##' + llamada.CC_Servicio_Genesys__r.CC_Canal_Procedencia__c);
                if (auditoria != null) {
                    Usuario usuario = auditoria.usuarios.get(llamada.OwnerId);
                    if (usuario == null) {
                        usuario = new Usuario(llamada.OwnerId);
                        auditoria.usuarios.put(llamada.OwnerId, usuario);
                    }
                    llamada.CC_Valida_IZO__c = true;
                    usuario.llamadasValidas.add(llamada);
                    llamadasActualizar.add(llamada);
                }
            }
        }
        update llamadasActualizar;
    }

    global void finish(Database.BatchableContext bc) {
        // Recuperamos el número de llamadas validas por los usuarios

        List<AggregateResult> llamadasValidasUsuarios =
        [SELECT OwnerId, CC_Servicio_Genesys__r.CC_Tipo_Cliente__c, CC_Servicio_Genesys__r.CC_Canal_Procedencia__c, COUNT(Id) llamadasValidasMes
        FROM CC_Llamada__c WHERE CC_Valida_IZO__c = true AND CC_Fecha_Inicio__c >= :mesInicio AND CC_Fecha_Inicio__c < :mesFin AND CC_Servicio_Genesys__r.CC_Codigo__c != 'IMAGIN_LEADS'
        GROUP BY OwnerId, CC_Servicio_Genesys__r.CC_Tipo_Cliente__c, CC_Servicio_Genesys__r.CC_Canal_Procedencia__c];

        for (AggregateResult result : llamadasValidasUsuarios) {
            String tipoCliente      = tipoClienteAuditoria((String) result.get('CC_Tipo_Cliente__c'));
            String canalProcedencia = (String) result.get('CC_Canal_Procedencia__c');
            Auditoria auditoria = auditorias.get(tipoCliente + '##' + canalProcedencia);
            if (auditoria == null){
                continue;  
            } 
            

            Id idUsuario = (Id) result.get('OwnerId'); 
            Usuario usuario = auditoria.usuarios.get(idUsuario);
            if (usuario == null){
                continue;
            }

            usuario.llamadasValidasMes = Integer.valueOf(result.get('llamadasValidasMes'));
        }

        for (Auditoria auditoria : auditorias.values()) {
            for (Id idUsuario : auditoria.usuarios.keySet()) {
                if (auditoria.usuarios.get(idUsuario).llamadasValidasMes < LLAMADAS_TOTALES_POR_AGENTE) {
                    auditoria.usuarios.remove(idUsuario);
                }
            }
        }

        // Ordenamos la lista de menos agentes disponibles a más. De esta forma
        // evitamos coger agentes duplicados para canales con más llamadas
        List<Auditoria> listaAuditorias = new List<Auditoria>();
        listaAuditorias.addAll(auditorias.values());
        listaAuditorias.sort();

        // Seleccionamos los usuarios a enviar
        Set<Id> idUsuariosActualizar = new Set<Id>();
        Map<Id, CC_Llamada__c> llamadasActualizar = new Map<Id, CC_Llamada__c>();

        // Si ya hemos marcado antes este usuario, solo miramos si podemos reemplazar alguna llamada
        for (Auditoria auditoria : auditorias.values()) {
            for (Id idUsuario : auditoria.usuarios.keySet()) {
                Usuario usuario = auditoria.usuarios.get(idUsuario);
                if (usuario.llamadasMarcadas.size() > 0 && usuario.llamadasValidas.size() > 0) {
                    Integer indiceLlamadaNueva = Integer.valueof((Math.random() * (usuario.llamadasValidasMes-1))) - (usuario.llamadasValidasMes - usuario.llamadasValidas.size());
                    if (Test.isRunningTest()) { indiceLlamadaNueva = 0; }
                    if (indiceLlamadaNueva >= 0 && indiceLlamadaNueva < usuario.llamadasValidas.size()) {
                        for (CC_Llamada__c llamada : usuario.llamadasMarcadas) {
                            llamada.CC_Auditoria_IZO__c = diaInicio;
                            llamadasActualizar.put(llamada.Id, llamada);
                        }

                        Integer indiceLlamadaAntigua = Integer.valueof((Math.random() * (usuario.llamadasMarcadas.size()-1)));
                        CC_Llamada__c llamadaAntigua = usuario.llamadasMarcadas[indiceLlamadaAntigua];
                        usuario.llamadasMarcadas.remove(indiceLlamadaAntigua);
                        llamadaAntigua.CC_Auditoria_IZO__c = null;
                        llamadaAntigua.CC_Valida_IZO__c = true;
                        llamadasActualizar.put(llamadaAntigua.Id, llamadaAntigua);

                        CC_Llamada__c llamadaNueva = usuario.llamadasValidas[indiceLlamadaNueva];
                        llamadaNueva.CC_Auditoria_IZO__c = diaInicio;
                        llamadaNueva.CC_Valida_IZO__c = true;
                        llamadaNueva.CC_Prioridad_IZO__c = llamadaAntigua.CC_Prioridad_IZO__c;
                        usuario.llamadasMarcadas.add(llamadaNueva);
                        llamadasActualizar.put(llamadaNueva.Id, llamadaNueva);
                    }
                }
            }
        }
        
        // Si no hemos marcado a este usuario y no hemos llegado al límite de llamadas de la auditoria lo añadimos
        // Hacemos un primer pase para saber cuales son los usuarios nuevos y cogemos las llamadas validas
        List<Id> nuevosUsuarios = new List<Id>();
        for (Auditoria auditoria : auditorias.values()) {
            if (auditoria.llamadasMes > 0) {
                Integer llamadasNecesarias = auditoria.llamadasMes;
                for (Id idUsuario : auditoria.usuarios.keySet()) {
                    if (auditoria.usuarios.get(idUsuario).llamadasMarcadas.size() == 0) {
                        nuevosUsuarios.add(idUsuario);
                        llamadasNecesarias -= auditoria.llamadasAgenteMes;
                        if (llamadasNecesarias <= 0){
                            break;

                        } 
                    }
                }
            }
        }

        obtenerLlamadasAntiguas(nuevosUsuarios);

        for (Auditoria auditoria : auditorias.values()) {
            for (Id idUsuario : auditoria.usuarios.keySet()) {
                Usuario usuario = auditoria.usuarios.get(idUsuario);
                if (usuario.llamadasMarcadas.size() == 0 && auditoria.llamadasMes > 0) {
                    // NOTE: PRIORIDADES
                    // 1-Mes pasado: -- / Mes actual: SI
                    // 2-Mes pasado: SI / Mes actual: NO
                    // 3-Mes pasado: NO / Mes actual: NO
                    Integer prioridad = 3;
                    if (((User)usuario.llamadasValidas[0].Owner).CC_Auditoria_IZO__c){
                        prioridad = 2;

                    } 
                    if (usuariosMarcados.contains(idUsuario)){
                        prioridad = 1;

                    } 
                    
                    Integer llamadasAgenteMes = auditoria.llamadasAgenteMes;
                    while (auditoria.llamadasMes > 0 && llamadasAgenteMes > 0) {
                        Integer indice = Integer.valueof((Math.random() * (usuario.llamadasValidas.size()-1)));
                        CC_Llamada__c llamada = usuario.llamadasValidas[indice];
                        usuario.llamadasValidas.remove(indice);
                        if (llamada.CC_Auditoria_IZO__c != null){
                            continue;

                        } 

                        llamada.CC_Auditoria_IZO__c = diaInicio;
                        llamada.CC_Prioridad_IZO__c = prioridad;
                        llamadasActualizar.put(llamada.Id, llamada);
                        usuario.llamadasMarcadas.add(llamada);
                        --auditoria.llamadasMes;
                        --llamadasAgenteMes;
                    }
                    usuariosMarcados.add(idUsuario);
                }
            }
        }

        // Comprobamos si un usuario se puede cambiar por otro con una prioridad menor
        // Igual que antes, hacemos un primer pase para obtener nuevas llamadas y luego las intercambiamos
        CC_LlamadasIZO_Batch.usuariosMarcadosPointer = usuariosMarcados;
        List<ReemplazoUsuario> reemplazosUsuario = new List<ReemplazoUsuario>();
        nuevosUsuarios.clear();
        for (Auditoria auditoria : auditorias.values()) {
            if (auditoria.llamadasMes > 0){
                continue;

            } 

            List<Usuario> usuariosMarcadosAuditoria = new List<Usuario>();
            List<Usuario> usuariosValidosAuditoria = new List<Usuario>();
            for (Usuario usuario : auditoria.usuarios.values()) {
                if (usuario.llamadasMarcadas.size() > 0) {
                    usuariosMarcadosAuditoria.add(usuario);
                }
                else {
                    usuariosValidosAuditoria.add(usuario);
                }
            }
            usuariosMarcadosAuditoria.sort();
            usuariosValidosAuditoria.sort();
            for (Integer i = 0; i < usuariosMarcadosAuditoria.size(); ++i) {
                Integer j = usuariosValidosAuditoria.size()-1 - i;
                if (j < 0 || usuariosMarcadosAuditoria[i].getPrioridad() >= usuariosValidosAuditoria[j].getPrioridad()){
                    break;

                } 
                
                ReemplazoUsuario reemplazo = new ReemplazoUsuario();
                reemplazo.usuarioAntiguo = usuariosMarcadosAuditoria[i];
                reemplazo.usuarioNuevo   = usuariosValidosAuditoria[j];
                reemplazosUsuario.add(reemplazo);
                nuevosUsuarios.add(usuariosValidosAuditoria[j].Id);
            }
        }
        
        obtenerLlamadasAntiguas(nuevosUsuarios);

        for (ReemplazoUsuario reemplazo : reemplazosUsuario) {
            Integer numeroLlamadas = reemplazo.usuarioAntiguo.llamadasMarcadas.size();
            for (CC_Llamada__c llamada : reemplazo.usuarioAntiguo.llamadasMarcadas) {
                llamada.CC_Auditoria_IZO__c = null;
                llamada.CC_Prioridad_IZO__c = 0;
                llamadasActualizar.put(llamada.Id, llamada);
            }

            // Si el usuario no se ha marcado 2 veces este mes lo eliminamos de la lista
            if (reemplazo.usuarioAntiguo.getPrioridad() > 1) {
                usuariosMarcados.remove(reemplazo.usuarioAntiguo.id);
            }

            for (Integer k = 0; k < numeroLlamadas;) {
                Integer indice = Integer.valueof((Math.random() * (reemplazo.usuarioNuevo.llamadasValidas.size()-1)));
                CC_Llamada__c llamada = reemplazo.usuarioNuevo.llamadasValidas[indice];
                reemplazo.usuarioNuevo.llamadasValidas.remove(indice);
                if (llamada.CC_Auditoria_IZO__c != null){
                    continue;

                } 

                llamada.CC_Auditoria_IZO__c = diaInicio;
                llamada.CC_Prioridad_IZO__c = reemplazo.usuarioNuevo.getPrioridad();
                llamadasActualizar.put(llamada.Id, llamada);

                ++k;
            }
            usuariosMarcados.add(reemplazo.usuarioNuevo.id);
        }

        // Actualizar llamadas
        List<CC_Llamada__c> listaLlamadasActualizar = llamadasActualizar.values();
        update listaLlamadasActualizar;

        // Desmarcamos los usuarios del mes pasado y marcamos los de este mes si esta es la última ejecución del batch del mes
        if (diaFin == mesFin) {
            Map<Id, User> usuariosActualizar = new Map<Id, User>();
            
            for (User usuario : [SELECT CC_Auditoria_IZO__c FROM User WHERE CC_Auditoria_IZO__c = true]) {
                usuario.CC_Auditoria_IZO__c = false;
                usuariosActualizar.put(usuario.Id, usuario);
            }
            for (Id idUsuario : usuariosMarcados) {
                usuariosActualizar.put(idUsuario, new User(Id = idUsuario, CC_Auditoria_IZO__c = true));
            }

            List<User> listaUsuariosActualizar = usuariosActualizar.values();
            update listaUsuariosActualizar;
        }
    }

    // Conversión de valores de tipo de clientes
    // CC_Lista_Valores__r.CC_Tipo_Cliente_Auditoria__c   <->   CC_Llamada__r.CC_Servicio_Genesys__r.CC_Tipo_Cliente__c
    private String tipoClienteAuditoria (String tipoClienteLlamada) {
        return (tipoClienteLlamada == 'Cliente') ? 'Clientes' : 'Oficinas';
    }
    private String tipoClienteLlamada (String tipoClienteAuditoria) {
        return (tipoClienteAuditoria == 'Clientes') ? 'Cliente' : 'Empleado';
    }

    // Obtiene llamadas validas de días anteriores de este mes y los añade al mapa de auditorias
    private void obtenerLlamadasAntiguas (List<Id> idUsuarios) {
        if (idUsuarios.size() == 0){
            return;

        } 

        List<CC_Llamada__c> llamadasAntiguas = 
        [SELECT OwnerId, CC_Servicio_Genesys__r.CC_Tipo_Cliente__c, CC_Servicio_Genesys__r.CC_Canal_Procedencia__c, CC_Prioridad_IZO__c, CC_Auditoria_IZO__c
        FROM CC_Llamada__c WHERE CC_Valida_IZO__c = true AND CC_Fecha_Inicio__c >= :mesInicio AND CC_Fecha_Inicio__c < :diaInicio AND CC_Servicio_Genesys__r.CC_Codigo__c != 'IMAGIN_LEADS'
        AND OwnerId IN :idUsuarios];
        for (CC_Llamada__c llamada : llamadasAntiguas) {
            String tipoCliente = tipoClienteAuditoria(llamada.CC_Servicio_Genesys__r.CC_Tipo_Cliente__c);
            Auditoria auditoria = auditorias.get(tipoCliente + '##' + llamada.CC_Servicio_Genesys__r.CC_Canal_Procedencia__c);
            if (auditoria == null){
                continue;

            } 

            Usuario usuario = auditoria.usuarios.get(llamada.OwnerId);
            if (usuario == null){
                continue;

            } 

            usuario.llamadasValidas.add(llamada);
        }
    }
}