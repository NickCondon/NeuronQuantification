# NeuronQuantification
The following collection of scripts are used to quantify images of neurons using the ImageJ/Fiji macro coding language.
They were developed in partnership between Nicholas Condon & Sang Won Cheung (Simon).

## General Overview of the scripts
These scripts takes 4 channel images, segments NueN cells (CH4) and measures them, and quantifies intensity measurements from other channels

For the scripts the following user-input settings are available:
- File Extension (defaults to .lif, but can be changed on line 59)
- Band Size (microns) (defaults to 0.5 but can be changed to any float value)
- Number of bands (defaults to 6 but can be increased/decreased relative to the area required)

The output of the scripts is a csv file with the following columns
- Image name (the file name of the image being measured)
- Image number (the file number in sequence)
- Number of NeuN Cells Identified
- NueN Cell # (the cell relative to the corresponding measurements)
- Ch3 Mean Intensity (the intensity of Ch3 (in this case MMP9 intensity
- Area (area of the cell in microns squared)

Differences between the scripts include varying the cell area selection parameters and the channels being measured relative to the antibody/acquisition data

## Preventing the Bio-formats Importer window from displaying when running the scripts
1. Open FIJI
2. Navigate to Plugins > Bio-Formats > Bio-Formats Plugins Configuration
3. Select Formats
4. Select your desired file format (e.g. “Zeiss CZI”) and select “Windowless”
5. Close the Bio-Formats Plugins Configuration window

Now the importer window won’t open for this file-type. To restore this, simply untick ‘Windowless”
