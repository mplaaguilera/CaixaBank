//SCRIPT A DESPLEGAR (Batch Apex per crear 100.000 comptes de prova):

public class BORRAR_BatchCreateMassiveAccounts implements Database.Batchable<Integer> {
    private Integer totalToCreate;
    private String recordTypeId;
    private Integer batchSize;

    public BORRAR_BatchCreateMassiveAccounts(Integer totalToCreate, String recordTypeId, Integer batchSize) {
        this.totalToCreate = totalToCreate;
        this.recordTypeId = recordTypeId;
        this.batchSize = batchSize;
    }

    public Iterable<Integer> start(Database.BatchableContext bc) {
        List<Integer> batches = new List<Integer>();
        Integer numBatches = (Integer)Math.ceil((Decimal)totalToCreate / batchSize);
        for (Integer i = 0; i < numBatches; i++) {
            batches.add(i);
        }
        return batches;
    }

    public void execute(Database.BatchableContext bc, List<Integer> scope) {
        List<Account> accs = new List<Account>();
        Integer startIdx = scope[0] * batchSize;
        Integer endIdx = Math.min(startIdx + batchSize, totalToCreate);
        for (Integer i = startIdx; i < endIdx; i++) {
            accs.add(new Account(
                Name = 'TestMassiveAccount',
                RecordTypeId = recordTypeId
            ));
        }
        insert accs;
        System.debug('Creats ' + accs.size() + ' comptes en aquest lot');
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Batch finalitzat');
    }
}