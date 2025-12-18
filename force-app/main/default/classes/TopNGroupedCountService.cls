public with sharing class TopNGroupedCountService {
    @InvocableMethod(
        label='Top N by Group Count'
        description='Returns Top N group values by COUNT(Id) for a given object/field with optional filters.'
        category='Custom Action'
        iconName = 'slds:custom:custom39'
    )
    public static List<TopNGroupedCountResponse> getTopN(List<Input> inputs) {
        validateInputs(inputs);
        List<TopNGroupedCountResponse> responses = new List<TopNGroupedCountResponse>();
        for(Input req: inputs){
            if(req.limitSize == null || req.limitSize <= 0){
                req.limitSize = 5;
            }
            Integer topN = normalizeLimit(req.limitSize);
            String whereClause = buildWhereClause(req);
            String soql = buildSQOL(req, whereClause, topN);
            TopNGroupedCountResponse o = new TopNGroupedCountResponse();
            o.rowValue = new List<TopNGroupedCountRow>();
            o.soql = soql;
            for(AggregateResult ar: Database.query(soql)){
                TopNGroupedCountRow row = new TopNGroupedCountRow();
                Object g = ar.get('grp');
                row.groupValue = (g == null) ? null : String.valueOf(g);
                row.recordCount = (Integer) ar.get('cnt');
                o.rowValue.add(row);
            }
            responses.add(o);
        }
        return responses;
    }
    private static void validateInputs(List<Input> inputs){
        if(inputs == null || inputs.isEmpty()){
            throw new IllegalArgumentException('No inputs provided.');
        }
        if(inputs.size() > 100){
            throw new IllegalArgumentException('Too many inputs provided. Max 100.');
        }
    }
    private static Integer normalizeLimit(Integer limitSize){
        return (limitSize == null || limitSize <= 0) ? 5 : Math.min(limitSize, 200);
    }
    private static String buildWhereClause(Input req) {
        List<String> conditions = new List<String>();
        if (String.isNotBlank(req.filterFieldApiName) && String.isNotBlank(req.filterValue)) {
            conditions.add(req.filterFieldApiName + ' = \'' + String.escapeSingleQuotes(req.filterValue.trim()) + '\'');
        }
        if (String.isNotBlank(req.additionalWhereClause)) {
            conditions.add('(' + req.additionalWhereClause.trim() + ')');
        }
        return conditions.isEmpty() ? '' : (' WHERE ' + String.join(conditions, ' AND '));
    }
    private static String buildSQOL(Input req, String whereClause, Integer topN) {
        return 'SELECT ' + req.groupByFieldApiName + ' grp, COUNT(Id) cnt ' +
                'FROM ' + req.sObjectApiName +
                whereClause + ' ' +
                'GROUP BY ' + req.groupByFieldApiName + ' ' +
                'ORDER BY COUNT(Id) DESC ' +
                'LIMIT ' + topN;
    }
    public class Input {
        @InvocableVariable(
            label = 'Object API Name'
            description = 'The object to query for the top N values.'
            required = true
        )
        public String sObjectApiName;

        @InvocableVariable(
            label = 'Field API Name'
            description = 'The field to query for the top N values.'
            required = true
        )
        public String groupByFieldApiName;

        @InvocableVariable(
            label = 'Where Clause Field API Name'
            description = 'The field to filter on.'
            required = false
        )
        public String filterFieldApiName;

        @InvocableVariable(
            label = 'Where Clause Value'
            description = 'The value to filter on.'
            required = false
        )
        public String filterValue;

        @InvocableVariable(
            label = 'Additional Where Clause'
            description = 'Additional complete where clause to apply to the query. EX: CreatedDate > LAST_N_DAYS:30'
            required = false
        )
        public String additionalWhereClause;

        @InvocableVariable(
            label = 'Limit Size'
            description = 'The maximum number of results to return.'
            defaultValue = '5'
            required = false
        )
        public Integer limitSize;
    }
    public class TopNGroupedCountResponse {
        @InvocableVariable(
            label = 'Top Results'
            description='The top N results for the query.'
        )
        public List<TopNGroupedCountRow> rowValue;

        @InvocableVariable(
            label = 'SOQL'
            description = 'The SOQL used to generate the results used for debug purposes.'
        )
        public String soql;
    }
}