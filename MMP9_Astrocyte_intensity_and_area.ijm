print("\\Clear");
//	MIT License
//	Copyright (c) 2021 Nicholas Condon n.condon@uq.edu.au
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.
scripttitle= "MMP9_Astrocyte_intensity_and_area.ijm";
version= "0.2";
date= "12-03-2021";
description= "This script takes 4 channel images, segments NueN cells (CH4) and measures them, it also measures Bands for MMP9 positivity (CH3)";
showMessage("Institute for Molecular Biosciences ImageJ Script", "<html>
    +"<h1><font size=6 color=Teal>ACRF: Cancer Biology Imaging Facility</h1>
    +"<h1><font size=5 color=Purple><i>The University of Queensland</i></h1>
    +"<h4><a href=http://imb.uq.edu.au/Microscopy/>ACRF: Cancer Biology Imaging Facility</a><h4>
    +"<h1><font color=black>ImageJ Script Macro: "+scripttitle+"</h1> 
    +"<p1>Version: "+version+" ("+date+")</p1>"
    +"<H2><font size=3>Created by Nicholas Condon</H2>"
    +"<p1><font size=2> contact n.condon@uq.edu.au \n </p1>" 
    +"<P4><font size=2> Available for use/modification/sharing under the "+"<p4><a href=https://opensource.org/licenses/MIT/>MIT License</a><h4> </P4>"
    +"<h3>   <h3>"    
    +"<p1><font size=3  i>"+description+"</p1>
    +"<h1><font size=2> </h1>"  
	   +"<h0><font size=5> </h0>"
    +"");
print("");
print("FIJI Macro: "+scripttitle);
print("Version: "+version+" Version Date: "+date);
print("ACRF: Cancer Biology Imaging Facility");
print("By Nicholas Condon (2021) n.condon@uq.edu.au")
print("");
getDateAndTime(year, month, week, day, hour, min, sec, msec);
print("Script Run Date: "+day+"/"+(month+1)+"/"+year+"  Time: " +hour+":"+min+":"+sec);
print("");

//Directory Warning and Instruction panel     
Dialog.create("Choosing your working directory.");
 	Dialog.addMessage("Use the next window to navigate to the directory of your images.");
  	Dialog.addMessage("(Note a sub-directory will be made within this folder for output files) ");
  	Dialog.addMessage("Take note of your file extension (eg .tif, .czi)");
Dialog.show(); 

//Directory Location
path = getDirectory("Choose Source Directory ");
list = getFileList(path);
getDateAndTime(year, month, week, day, hour, min, sec, msec);

ext = ".lif";
Dialog.create("Settings");
Dialog.addString("File Extension: ", ext);
Dialog.addMessage("(For example .czi  .lsm  .nd2  .lif  .ims)");
Dialog.addNumber("Band Size (microns)", 0.5);
Dialog.addNumber("Numebr of Bands", 6);
Dialog.show();
ext = Dialog.getString();
BinVal = Dialog.getNumber();
numBins = Dialog.getNumber();

start = getTime();
roicheck =1;

//Creates Directory for output images/logs/results table
resultsDir = path+"_Results_"+"_"+year+"-"+(month+1)+"-"+day+"_at_"+hour+"."+min+"/"; 
File.makeDirectory(resultsDir);
print("Working Directory Location: "+path);
summaryFile = File.open(resultsDir+"Results_"+"_"+year+"-"+(month+1)+"-"+day+"_at_"+hour+"."+min+".csv");
print(summaryFile,"Image Name , Image Number, Number of NueN Cells Identified , NueN Cell # , Ch3 Mean Intensity , Area");
run("Set Measurements...", "area mean min perimeter shape redirect=None decimal=9");

for (z=0; z<list.length; z++) {
	if (endsWith(list[z],ext)){
		run("Bio-Formats Importer", "open=["+path+list[z]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		run("Clear Results");
		roiManager("reset");
		windowtitle = getTitle();
		windowtitlenoext = replace(windowtitle, ext, "");
		print("Filename: "+windowtitle);
		
		setTool("freehand");
		Stack.setDisplayMode("composite");
		getDimensions(width, height, channels, slices, frames);
		for (i = 1; i <= channels; i++) {
			setSlice(i);run("Enhance Contrast", "saturated=0.35");}
		if (roicheck ==1) {waitForUser("Draw around your area of interest, then click OK");}
			//roiManager("add");
		if (roiManager("count")>0){
			roiManager("Select",0);
			run("Make Inverse");
			setForegroundColor(0, 0, 0);
			for (i = 1; i <= channels; i++) {setSlice(i); run("Fill", "slice");}
			if (roiManager("count")>0){roiManager("select",0);}
			}
			run("Measure");
			workingArea = getResult("Area",0);
			run("Select None");
			run("Duplicate...", "title=NeuN duplicate channels=2");
			run("Median...", "radius=4");
			run("Subtract Background...", "rolling=150");
			setAutoThreshold("Default dark no-reset");
			setOption("BlackBackground", true);
			run("Convert to Mask");
			run("Analyze Particles...", "size=25-70=0.005-1.00 show=Masks exclude add");
			rename("NueN_Mask");
			NumNuen = roiManager("count");
			for (i = 0; i < NumNuen; i++) {
				roiManager("Select",i);
				roiManager("Rename", i+1);
				}
			selectWindow(windowtitle);
			Stack.setDisplayMode("grayscale");
			setSlice(2);
			roiManager("Show All");
			setTool("freehand");
			waitForUser("Delete, Change, Add ROIs then click ok to continue. Note the numbers may change as you delete or add them.");
			NumNuen = roiManager("count");
			print("Number of NueN Positive Cells found = "+NumNuen);
			for (i = 1; i <roiManager("count"); i++) {
				roiManager("Select",i);
				roiManager("Rename", i);
				}	
			selectWindow(windowtitle);
			run("Select None");
			selectWindow(windowtitle);
			run("Select None");
			run("Duplicate...", "title=MMP9 duplicate channels=2");
			numROIs = roiManager("count");
			MMP9IntA = newArray(numROIs);
			BinMeanArray = newArray(numBins);
			for (i = 0; i < numROIs; i++) {
				roiManager("Select",i);
				run("Clear Results");
				run("Measure");
				MMP9IntA[i] = getResult("Mean", 0);
				print(summaryFile,windowtitle+","+(z+1)+","+NumNuen+","+(i+1)+","+getResult("Mean",0)+","+getResult("Area", 0));
				}
		roiManager("save", resultsDir+windowtitle+"_roi.zip");
		while(nImages>0){close();}
		}
	}
selectWindow("Log");
saveAs("Text", resultsDir+"Log.txt");
//exit message to notify user that the script has finished.
title = "Batch Completed";
msg = "Put down that coffee! Your analysis is finished";
waitForUser(title, msg);