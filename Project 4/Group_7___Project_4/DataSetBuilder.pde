import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DataSetBuilder {
  private static final String TITLE_PATTERN = "Estimates of Monthly Retail and Food Services Sales by Kind of Business: %d";
  
  private int year;
  
  private final List<MaskPair> maskedRows = new ArrayList<MaskPair>();
  
  private final List<String> maskedColumns = new ArrayList<String>();
  
  private final Map<String, String> filenameAliasMap = new HashMap<String, String>();
  
  public DataSetBuilder year(int year) {
    this.year = year;
    return this;
  }
  
  public DataSetBuilder file(String filename, String alias) {
    filenameAliasMap.put(alias, filename);
    return this;
  }
  
  public DataSetBuilder rowMask(int firstRow) {
    this.rowMask(firstRow, 1);
    return this;
  }
  
  public DataSetBuilder rowMask(int firstRow, int rowCount) {
    MaskPair maskPair = new MaskPair();
    maskPair.start = firstRow;
    maskPair.size = rowCount;
    maskedRows.add(maskPair);
    return this;
  }
  
  public DataSetBuilder columnMask(String columnName) {
    maskedColumns.add(columnName);
    return this;
  }
  
  public DataSet get() {
    DataSetImpl dataSetImpl = new DataSetImpl(String.format(TITLE_PATTERN, year));
    
    for (String alias : filenameAliasMap.keySet()) {
      Table table = loadTable(filenameAliasMap.get(alias), "header");
      removeMaskedColumns(table);
      removeMaskedRows(table);
      dataSetImpl.addTable(alias, table);
    }
    
    return dataSetImpl;
  }
  
  private void removeMaskedColumns(Table table) {
    for (String columnName : maskedColumns) {
      try {
        table.removeColumn(columnName);
      } catch (Exception e) {
      }
    }
  }
  
  private void removeMaskedRows(Table table) {
    for (MaskPair maskPair : maskedRows) {
      if (maskPair.start > table.getRowCount() - 1) {
        continue;
      }
      
      int endIndex = (maskPair.start + maskPair.size) - 1;
    
      if (maskPair.size == 0) {
        endIndex = table.getRowCount();
      }
      
      for (int i = endIndex; i >= maskPair.start; i--) {
        table.removeRow(i - 1);
      }
    }
  }
  
  private class MaskPair {
    int start;
    int size;
  }
}