import java.util.HashMap;
import java.util.Map;

class DataSetImpl implements DataSet<Float> {
  private final String title;
  
  private final Map<String, Table> zAxisMap = new HashMap<String, Table>();
  
  public DataSetImpl(String title) {
    this.title = title;
  }
  
  void addTable(String zAxisAlias, Table table) {
    zAxisMap.put(zAxisAlias, table);
  }
  
  public String getDataSetTitle() {
    return this.title;
  }
  
  public String[] getXAxisNames(String zAxisName) {
    Table table = zAxisMap.get(zAxisName);
    return table.getColumnTitles();
  }
  
  public int getRowCount(String zAxisName) {
    Table table = zAxisMap.get(zAxisName);
    return table.getRowCount();
  }
  
  public String[] getZAxisNames() {
    return zAxisMap.keySet().toArray(new String[zAxisMap.size()]);
  }
  
  public Float getValue(String xAxisName, int rowNumber, String zAxisName) {
    Table table = zAxisMap.get(zAxisName);
    
    if (table != null) {
      return table.getFloat(rowNumber, xAxisName);
    }
    
    return null;
  }
  
  public String getRowName(String zAxisName, int rowNumber) {
    Table table = zAxisMap.get(zAxisName);
    
    if (table != null) {
      return table.getString(rowNumber, 0);
    }
    
    return "";
  }
  
  Float getRowMin(String zAxisName, int row) {
    Table table = zAxisMap.get(zAxisName); 
    FloatList floatList = new FloatList(table.getFloatRow(row));
    return floatList.min();
  }
  
  Float getRowMax(String zAxisName, int row) {
    Table table = zAxisMap.get(zAxisName);
    FloatList floatList = new FloatList(table.getFloatRow(row));
    return floatList.max();
  }
}