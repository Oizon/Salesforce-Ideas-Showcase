/* Author: William Galinat
 * Description:This method is invocable from a flow to parse a any multi-select picklist into an iterable list of strings for a flow.
 * Last Update: 20230629 by William Galinat
 */

 global class MultiSelectFlowParser {
    
    @InvocableMethod(label='Parse MultiSelect Picklist' 
                     description='Splits the chosen parts of a multiselect picklist into an interable list.' 
                     category= 'Custom Action')
    public static List<List<String>> checkValues(List<string>multiSelectPicklist){
        if (!multiSelectPicklist.isEmpty()) {
          String temporaryString = multiSelectPicklist[0];
          List<String> splitStringList = temporaryString.split(';');
          List<List<String>> listToReturn = new List<List<String>>();
          listToReturn.add(splitStringList);
          return listToReturn;
      } else {
         return null;
      }
	}
}