package project5;

import java.io.*;

public class MultiQueries {

	public static void main(String[] args) throws IOException, FileNotFoundException {
		
		/* VARIABLE DECLARATIONS */
		String tableName = "Courses";
		String columns [] = {"CID", "TID", "BID", "SID"};
		String query;
		
		/* END OF VARIABLE DECLARATIONS */
		
		/* SETTING UP WRITE TO FILE */
		Writer writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream("MVDQUERIES.txt"), "UTF-8"));
		
		/* END OF WRITE TO FILE SETUP */
		
		query = "/* Made by Hreiðar Ólafur Arnarsson and Maciej Sierzputowski, 2016-11-03 */"
				+ System.lineSeparator() + System.lineSeparator();
		
		writer.write(query);
		
		/* QUERY CREATION */
		// better solution would be to use recursion, allows for a variable length of columns without much change of code
		for (int i = 0; i < columns.length; i++) { // the left hand
			boolean runOnce = false; // making sure it only loops once
			
			for (int j = 0; j < columns.length; j++) { // first right hand check				
				for (int k = 0; k < columns.length; k++) { // second right hand check
					for (int l = 0; l < columns.length; l++) { // third right hand check
						if (i != j && i != k && i != l) { // i can't point to itself
							if (j != k && j != l & k != l && !runOnce) { // making sure there are no multiples
								
								runOnce = true;
								
								query = "SELECT '" + tableName + ": " + columns[i] + "-->>" + columns[j] + "; "
										+ columns[i] + "-->>" + columns[k] + "; " + columns[i] + "-->>" + columns[l] + "' AS MVD, "
										+ "CASE WHEN COUNT(*) = 0 THEN 'Gildir' ELSE 'Gildir ekki' END AS VALIDITY" + System.lineSeparator()
										+ "FROM(" + System.lineSeparator()
										+ " SELECT " + columns[i] + System.lineSeparator()
										+ "  FROM " + tableName + System.lineSeparator()
										+ " GROUP BY " + columns[i] + System.lineSeparator()
										+ " HAVING COUNT(*) > 1 AND COUNT(*) <> COUNT(DISTINCT " + columns[j] + ") * "
										+ "COUNT(DISTINCT " + columns[k] + ") * COUNT(DISTINCT " + columns[l] + ")" + System.lineSeparator()
										+ ") Y;" + System.lineSeparator();
								
								writer.write(query);							}
						}
					}
				}
			}
		}
		/* END QUERY CREATION */
		
		writer.close();
	}
}
