public interface DataSet<T extends Number> {
  String getDataSetTitle();
  
  String[] getXAxisNames(String zAxisName);
  
  int getRowCount(String zAxisName);
  
  String getRowName(String zAxisName, int rowNumber);
  
  String[] getZAxisNames();
  
  T getValue(String xAxisName, int rowNumber, String zAxisName);
  
  T getRowMin(String zAxisName, int row);
  
  T getRowMax(String zAxisName, int row);
}