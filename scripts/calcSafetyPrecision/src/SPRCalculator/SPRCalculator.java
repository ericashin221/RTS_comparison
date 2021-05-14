package SPRCalculator;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.HashSet;
import java.util.Scanner;

public class SPRCalculator {

		protected static HashSet<String> startsTests = new HashSet<String>();

		protected static HashSet<String> ekstaziTests = new HashSet<String>();

		protected static HashSet<String> hyrtsTests = new HashSet<String>();

		protected static HashSet<String> cloverTests = new HashSet<String>();

		public void readTests(String file, HashSet<String> testSet) throws IOException{
			Scanner sc = new Scanner(new File(file));

			while(sc.hasNext())
				testSet.add(sc.next().trim());
		}

		public double calcPrecisionWithRespectToEkstazi(HashSet<String> testSet) {
			HashSet<String> testOnlyToolSet = new HashSet<String>();
			testOnlyToolSet.addAll(testSet);
			testOnlyToolSet.removeAll(ekstaziTests);

			HashSet<String> unionSet = new HashSet<String>();
			unionSet.addAll(ekstaziTests);
			unionSet.addAll(testSet);

			double precision = ((double)testOnlyToolSet.size() / (double)unionSet.size()) * 100.0;

			if(Double.isNaN(precision))
				precision = 0.0;

			precision = Double.parseDouble(String.format("%.3f", precision));

			return precision;
		}

		public double calcSafetywithRespectToEkstazi(HashSet<String> testSet){

			HashSet<String> testOnlyStartsSet = new HashSet<String>(); // Test cases selected by Ekstazi but parameter tool
			testOnlyStartsSet.addAll(ekstaziTests);
			testOnlyStartsSet.removeAll(testSet);

			HashSet<String> unionSet = new HashSet<String>();
			unionSet.addAll(ekstaziTests);
			unionSet.addAll(testSet);

			double safety = ((double)testOnlyStartsSet.size() / (double)unionSet.size()) * 100.0;

			if(Double.isNaN(safety))
				safety = 0.0;

			safety = Double.parseDouble(String.format("%.3f", safety));

			return safety;
		}

		public double calcPrecisionWithRespectToStarts(HashSet<String> testSet) {
			HashSet<String> testOnlyToolSet = new HashSet<String>();
			testOnlyToolSet.addAll(testSet);
			testOnlyToolSet.removeAll(startsTests);

			HashSet<String> unionSet = new HashSet<String>();
			unionSet.addAll(startsTests);
			unionSet.addAll(testSet);

			double precision = ((double)testOnlyToolSet.size() / (double)unionSet.size()) * 100.0;

			if(Double.isNaN(precision))
				precision = 0.0;

			precision = Double.parseDouble(String.format("%.3f", precision));

			return precision;
		}

		public double calcSafetywithRespectToStarts(HashSet<String> testSet){

			HashSet<String> testOnlyStartsSet = new HashSet<String>(); // Test cases selected by Starts but parameter tool
			testOnlyStartsSet.addAll(startsTests);
			testOnlyStartsSet.removeAll(testSet);

			HashSet<String> unionSet = new HashSet<String>();
			unionSet.addAll(startsTests);
			unionSet.addAll(testSet);

			double safety = ((double)testOnlyStartsSet.size() / (double)unionSet.size()) * 100.0;

			if(Double.isNaN(safety))
				safety = 0.0;

			safety = Double.parseDouble(String.format("%.3f", safety));

			return safety;
		}
		
		public double calcPrecisionWithRespectToHyRTS(HashSet<String> testSet) {
			HashSet<String> testOnlyToolSet = new HashSet<String>();
			testOnlyToolSet.addAll(testSet);
			testOnlyToolSet.removeAll(hyrtsTests);

			HashSet<String> unionSet = new HashSet<String>();
			unionSet.addAll(hyrtsTests);
			unionSet.addAll(testSet);

			double precision = ((double)testOnlyToolSet.size() / (double)unionSet.size()) * 100.0;

			if(Double.isNaN(precision))
				precision = 0.0;

			precision = Double.parseDouble(String.format("%.3f", precision));

			return precision;
		}

		public double calcSafetywithRespectToHyRTS(HashSet<String> testSet){

			HashSet<String> testOnlyStartsSet = new HashSet<String>(); // Test cases selected by Starts but parameter tool
			testOnlyStartsSet.addAll(hyrtsTests);
			testOnlyStartsSet.removeAll(testSet);

			HashSet<String> unionSet = new HashSet<String>();
			unionSet.addAll(hyrtsTests);
			unionSet.addAll(testSet);

			double safety = ((double)testOnlyStartsSet.size() / (double)unionSet.size()) * 100.0;

			if(Double.isNaN(safety))
				safety = 0.0;

			safety = Double.parseDouble(String.format("%.3f", safety));

			return safety;
		}

		public static void main(String[] args) throws Exception {

			// args[0]: Subject
			// args[1]: rev_num
			// args[2]-args[5]: tools
			// args[6]: save directory

			SPRCalculator spr = new SPRCalculator();

			spr.readTests(args[2], startsTests);
			spr.readTests(args[3], ekstaziTests);
			spr.readTests(args[4], hyrtsTests);
			spr.readTests(args[5], cloverTests);

			String precisionOutput = args[1] + " ,  "
					+ spr.calcPrecisionWithRespectToStarts(ekstaziTests)  +  " , "
					+ spr.calcPrecisionWithRespectToStarts(hyrtsTests)  +  " , "
					+ spr.calcPrecisionWithRespectToStarts(cloverTests)  +  " , "
					+ spr.calcPrecisionWithRespectToEkstazi(startsTests)  +  " , "
					+ spr.calcPrecisionWithRespectToEkstazi(hyrtsTests)  +  " , "
					+ spr.calcPrecisionWithRespectToEkstazi(cloverTests) + " , "
					+ spr.calcPrecisionWithRespectToHyRTS(startsTests)  +  " , "
					+ spr.calcPrecisionWithRespectToHyRTS(ekstaziTests)  +  " , "
					+ spr.calcPrecisionWithRespectToHyRTS(cloverTests)  +  "\n ";

			String safetyOutput = args[1] + " ,  "
					+ spr.calcSafetywithRespectToStarts(ekstaziTests)  +  " , "
					+ spr.calcSafetywithRespectToStarts(hyrtsTests)  +  " , "
					+ spr.calcSafetywithRespectToStarts(cloverTests)  +  " , "
					+ spr.calcSafetywithRespectToEkstazi(startsTests)  +  " , "
					+ spr.calcSafetywithRespectToEkstazi(hyrtsTests)  +  " , "
					+ spr.calcSafetywithRespectToEkstazi(cloverTests) + " , "
					+ spr.calcSafetywithRespectToHyRTS(startsTests)  +  " , "
					+ spr.calcSafetywithRespectToHyRTS(ekstaziTests)  +  " , "
					+ spr.calcSafetywithRespectToHyRTS(cloverTests)  +  "\n";

			Path precisionPath = Paths.get(args[6], args[0]+"_precision.txt");
			Path safetyPath = Paths.get(args[6], args[0]+"_safety.txt");

			try (BufferedWriter writer = Files.newBufferedWriter(precisionPath, StandardCharsets.UTF_8, StandardOpenOption.APPEND,StandardOpenOption.CREATE)) {
		        writer.write(precisionOutput);
		    } catch (IOException e) {
		        e.printStackTrace();
		    }

			try (BufferedWriter writer = Files.newBufferedWriter(safetyPath, StandardCharsets.UTF_8, StandardOpenOption.APPEND,StandardOpenOption.CREATE)) {
		        writer.write(safetyOutput);
		    } catch (IOException e) {
		        e.printStackTrace();
		    }
		}
}
