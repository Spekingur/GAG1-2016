package project5;

import java.io.*;

public class FunctionalQueries {

	public static void main(String[] args) throws IOException, FileNotFoundException {
		
		/* VARIABLE DECLARATIONS */
		
		// The tables
		String TableNames [] = {"Persons", "Boats", "Projects", "Courses"};
		String Persons [] = {"ID", "PN", "DID", "DN", "SSN", "Z", "T"};
		String Boats [] = {"BL", "BNo", "Z", "T", "BN", "SSN"};
		String Projects [] = {"ID", "PID", "DID", "DN", "PN", "DM"};
		String Courses [] = {"CID", "TID", "BID", "SID", "TN", "SN", "SY"};
		String Tables [][] = {Persons, Boats, Projects, Courses};
		
		// Other variables
		String query;
		
		/* END OF VARIABLE DECLARATIONS */
		
		// Adding first lines to query.
		query = "/* Made by Hreiðar Ólafur Arnarsson and Maciej Sierzputowski, 2016-11-03 */" + System.lineSeparator() + System.lineSeparator();
		
		Writer writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream("FDQUERIES.txt"), "UTF-8"));
		
		writer.write(query);
		
		/*
		query = String.valueOf(Tables.length) + System.lineSeparator();
		writer.write(query);
		query = String.valueOf(Tables[0].length) + System.lineSeparator();
		writer.write(query);
		*/
		
		/* QUERY CREATION */
		
		// Going through the tables
		
		for (int i = 0; i < Tables.length; i++) {
			
			// Left hand side
			for (int j = 0; j < Tables[i].length; j++) {
				
				// Right hand side
				for (int k = 0; k < Tables[i].length; k++) {
					
					// Only write query when the left hand side ISN'T the same as the right hand side
					if (j != k) {
						query = "SELECT '" + TableNames[i] + ": " + Tables[i][j] + "-->" + Tables[i][k] + "' AS FD, "
								+ "CASE WHEN COUNT(*)=0 THEN 'Gildir' ELSE 'Gildir ekki' END AS VALIDITY" + System.lineSeparator()
								+ "FROM(" + System.lineSeparator()
								+ " SELECT " + Tables[i][j] + System.lineSeparator()
								+ "  FROM " + TableNames[i] + System.lineSeparator()
								+ " GROUP BY " + Tables[i][j] + System.lineSeparator()
								+ " HAVING COUNT(DISTINCT " + Tables[i][k] + ") > 1" + System.lineSeparator()
								+ ") X;" + System.lineSeparator();
						writer.write(query);
					}
				}
			}
		}
		
		/* END QUERY CREATION */
		
		writer.close();
	}
}
